import uuid
from decimal import Decimal
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from app.models.sale import Sale, SaleItem, SaleStatus
from app.models.shift import DrawerTransaction, DrawerTxType
from app.models.stock import MovementType
from app.schemas.stock import StockMovementCreate
from app.services.stock_service import record_movement, get_balance
from app.core.exceptions import BusinessError


async def _invoice_number(db) -> str:
    from sqlalchemy import text
    seq = (await db.execute(text("SELECT nextval('invoice_seq')"))).scalar()
    return f"INV-{seq:06d}"

async def _quotation_number(db) -> str:
    from sqlalchemy import text
    seq = (await db.execute(text("SELECT nextval('quotation_seq')"))).scalar()
    return f"QUO-{seq:06d}"



async def _is_untracked(db, product_id) -> bool:
    from sqlalchemy import text as sqlt
    row = await db.execute(sqlt("SELECT stock_status FROM products WHERE id=:id"), {"id": product_id})
    status = row.scalar()
    return status == 'untracked'

async def create_quotation(db: AsyncSession, data, cashier_id: uuid.UUID) -> Sale:
    """Create a quotation (عرض سعر) — no stock deduction, status=quotation."""
    gross_total = sum(float(i.qty) * float(i.unit_price) for i in data.items)
    total_discount = sum(float(i.discount) for i in data.items)
    net_total = gross_total - total_discount - float(data.discount_amount)

    sale = Sale(
        invoice_number=await _quotation_number(db),
        customer_id=data.customer_id,
        warehouse_id=data.warehouse_id,
        cashier_id=cashier_id,
        shift_id=data.shift_id,
        sale_mode=data.sale_mode,
        discount_amount=data.discount_amount,
        total=Decimal(str(gross_total)),
        net_total=Decimal(str(net_total)),
        notes=data.notes,
        status=SaleStatus.quotation,
        created_by=cashier_id,
    )
    db.add(sale)
    await db.flush()
    for item in data.items:
        db.add(SaleItem(sale_id=sale.id, product_id=item.product_id, qty=item.qty,
                        unit_price=item.unit_price, unit_cost=item.unit_cost, discount=item.discount))
    # Auto-archive within same transaction
    from app.models.archive import ArchivedDocument, DocType
    db.add(ArchivedDocument(doc_number=sale.invoice_number, doc_type=DocType.quotation,
                            ref_id=sale.id, created_by=cashier_id,
                            metadata_={"items_count": len(data.items), "mode": data.sale_mode}))
    await db.commit()
    result = await db.execute(select(Sale).options(selectinload(Sale.items)).where(Sale.id == sale.id))
    return result.scalar_one()


async def confirm_quotation(db: AsyncSession, sale_id: uuid.UUID, user_id: uuid.UUID) -> Sale:
    """Convert a quotation to a confirmed sale — deducts stock."""
    result = await db.execute(select(Sale).options(selectinload(Sale.items)).where(Sale.id == sale_id).with_for_update())
    sale = result.scalar_one_or_none()
    if not sale:
        from app.core.exceptions import NotFoundError
        raise NotFoundError("Quotation not found")
    if sale.status != SaleStatus.quotation:
        raise BusinessError("Only quotations can be confirmed this way")

    for item in sale.items:
        if not await _is_untracked(db, item.product_id):
            balance = await get_balance(db, item.product_id, sale.warehouse_id, for_update=True)
            if balance < item.qty:
                raise BusinessError(f"Insufficient stock for product {item.product_id}")

    for item in sale.items:
        mv = StockMovementCreate(product_id=item.product_id, warehouse_id=sale.warehouse_id,
                                  movement_type=MovementType.sale, qty=item.qty,
                                  unit_cost=item.unit_cost, unit_price=item.unit_price)
        await record_movement(db, mv, user_id, ref_id=sale.id, ref_type="sale")

    sale.status = SaleStatus.confirmed
    sale.invoice_number = await _invoice_number(db)
    await db.commit()
    await db.refresh(sale)
    return sale


async def create_draft_sale(db: AsyncSession, data, cashier_id: uuid.UUID) -> Sale:
    """Create a draft sale — no stock deduction, status=draft, no archive."""
    gross_total = sum(float(i.qty) * float(i.unit_price) for i in data.items)
    total_discount = sum(float(i.discount) for i in data.items)
    net_total = gross_total - total_discount - float(data.discount_amount)

    sale = Sale(
        invoice_number=await _invoice_number(db),
        customer_id=data.customer_id,
        warehouse_id=data.warehouse_id,
        cashier_id=cashier_id,
        shift_id=data.shift_id,
        sale_mode=data.sale_mode,
        discount_amount=data.discount_amount,
        total=Decimal(str(gross_total)),
        net_total=Decimal(str(net_total)),
        paid_amount=Decimal(str(net_total)),
        notes=data.notes,
        is_credit=data.is_credit,
        payment_method=data.payment_method,
        status=SaleStatus.draft,
        created_by=cashier_id,
    )
    db.add(sale)
    await db.flush()
    for item in data.items:
        db.add(SaleItem(sale_id=sale.id, product_id=item.product_id, qty=item.qty,
                        unit_price=item.unit_price, unit_cost=item.unit_cost,
                        discount=item.discount))
    await db.commit()
    result = await db.execute(select(Sale).options(selectinload(Sale.items)).where(Sale.id == sale.id))
    return result.scalar_one()


async def confirm_draft_sale(db: AsyncSession, sale_id: uuid.UUID, user_id: uuid.UUID) -> Sale:
    """Convert a draft sale to confirmed — assigns real invoice number, deducts stock."""
    from app.core.exceptions import NotFoundError
    from app.models.archive import ArchivedDocument, DocType
    result = await db.execute(select(Sale).options(selectinload(Sale.items)).where(Sale.id == sale_id).with_for_update())
    sale = result.scalar_one_or_none()
    if not sale:
        raise NotFoundError("Draft sale not found")
    if sale.status != SaleStatus.draft:
        raise BusinessError("Only draft sales can be confirmed")

    for item in sale.items:
        if not await _is_untracked(db, item.product_id):
            balance = await get_balance(db, item.product_id, sale.warehouse_id, for_update=True)
            if balance < item.qty:
                raise BusinessError(f"Insufficient stock for product {item.product_id}")

    for item in sale.items:
        mv = StockMovementCreate(product_id=item.product_id, warehouse_id=sale.warehouse_id,
                                  movement_type=MovementType.sale, qty=item.qty,
                                  unit_cost=item.unit_cost, unit_price=item.unit_price)
        await record_movement(db, mv, user_id, ref_id=sale.id, ref_type="sale")

    new_inv = await _invoice_number(db)
    sale.status = SaleStatus.confirmed
    sale.invoice_number = new_inv
    db.add(ArchivedDocument(doc_number=new_inv, doc_type=DocType.sale_invoice,
                            ref_id=sale.id, created_by=user_id,
                            metadata_={"items_count": len(sale.items)}))
    await db.commit()
    await db.refresh(sale)
    return sale


async def create_sale(db: AsyncSession, data, cashier_id: uuid.UUID) -> Sale:
    for item in data.items:
        if not await _is_untracked(db, item.product_id):
            balance = await get_balance(db, item.product_id, data.warehouse_id, for_update=True)
            if balance < item.qty:
                raise BusinessError(f"Insufficient stock for product {item.product_id}: available {balance}")

    if data.is_credit and data.customer_id:
        from sqlalchemy import text as sqlt
        c = await db.execute(sqlt("SELECT credit_limit, balance FROM customers WHERE id=:id FOR UPDATE"), {"id": data.customer_id})
        c = c.one_or_none()
        if c and c.credit_limit is not None:
            total = sum(float(i.qty) * float(i.unit_price) - float(i.discount) for i in data.items)
            total -= float(data.discount_amount)
            new_balance = float(c.balance or 0) + total
            if new_balance > float(c.credit_limit):
                remaining = float(c.credit_limit) - float(c.balance or 0)
                raise BusinessError(f"تجاوز حد الائتمان (الحد: {c.credit_limit:.2f}, المتبقي: {remaining:.2f})")

    sale = Sale(
        invoice_number=await _invoice_number(db),
        customer_id=data.customer_id,
        warehouse_id=data.warehouse_id,
        cashier_id=cashier_id,
        shift_id=data.shift_id,
        sale_mode=data.sale_mode,
        discount_amount=data.discount_amount,
        is_credit=data.is_credit,
        payment_method=getattr(data, 'payment_method', 'cash') or 'cash',
        wallet_id=getattr(data, 'wallet_id', None),
        notes=data.notes,
        created_by=cashier_id,
    )
    db.add(sale)
    await db.flush()

    gross_total = 0
    total_discount = 0
    for item in data.items:
        si = SaleItem(
            sale_id=sale.id,
            product_id=item.product_id,
            qty=item.qty,
            unit_price=item.unit_price,
            unit_cost=item.unit_cost,
            discount=item.discount,
        )
        db.add(si)
        gross_total += float(item.qty) * float(item.unit_price)
        total_discount += float(item.discount)

        mv = StockMovementCreate(
            product_id=item.product_id,
            warehouse_id=data.warehouse_id,
            movement_type=MovementType.sale,
            qty=item.qty,
            unit_cost=item.unit_cost,
            unit_price=item.unit_price,
        )
        await record_movement(db, mv, cashier_id, ref_id=sale.id, ref_type="sale")

    net_total = gross_total - total_discount - float(data.discount_amount)
    sale.total = Decimal(str(gross_total))
    sale.net_total = Decimal(str(net_total))
    paid = getattr(data, 'paid_amount', None)
    if paid is not None:
        sale.paid_amount = Decimal(str(paid))
    elif data.is_credit:
        sale.paid_amount = Decimal("0")
    else:
        sale.paid_amount = Decimal(str(net_total))

    # ── Split Payments ──────────────────────────────────────────────────
    from sqlalchemy import text as sqlt
    payments = getattr(data, 'payments', None)
    if payments:
        pmt_sum = sum(float(p.amount) for p in payments)
        if abs(pmt_sum - total) > 0.01:
            raise BusinessError(f"مجموع المدفوعات ({pmt_sum:.2f}) لا يساوي إجمالي الفاتورة ({total:.2f})")
        is_credit = any(p.method == 'credit' for p in payments)
        sale.is_credit = is_credit
        sale.payment_method = payments[0].method
        for p in payments:
            await db.execute(sqlt(
                "INSERT INTO sale_payments (sale_id, method, amount, wallet_id) VALUES (:sid, :m, :amt, :wid)"
            ), {"sid": sale.id, "m": p.method, "amt": p.amount, "wid": p.wallet_id})
            if p.method == 'cash' and data.shift_id:
                db.add(DrawerTransaction(
                    shift_id=data.shift_id, type=DrawerTxType.sale,
                    amount=float(p.amount), ref_id=sale.id, created_by=cashier_id,
                    note=f"قسط نقدي - {sale.invoice_number}",
                ))
            elif p.method == 'wallet' and p.wallet_id:
                from app.services.wallet_service import record_wallet_tx
                await record_wallet_tx(db, p.wallet_id, float(p.amount), "sale", sale.id,
                                       f"قسط محفظة - {sale.invoice_number}", cashier_id)
            elif p.method == 'credit' and data.customer_id:
                await db.execute(sqlt(
                    "UPDATE customers SET balance = COALESCE(balance,0) + :amt WHERE id = :cid"
                ), {"amt": float(p.amount), "cid": data.customer_id})
    else:
        # Legacy single payment
        if data.shift_id:
            db.add(DrawerTransaction(
                shift_id=data.shift_id, type=DrawerTxType.sale,
                amount=total, ref_id=sale.id, created_by=cashier_id,
            ))
        if data.is_credit and data.customer_id:
            await db.execute(sqlt(
                "UPDATE customers SET balance = COALESCE(balance,0) + :amt WHERE id = :cid"
            ), {"amt": total, "cid": data.customer_id})
        if getattr(data, 'wallet_id', None) and not data.is_credit:
            from app.services.wallet_service import record_wallet_tx
            await record_wallet_tx(db, data.wallet_id, total, "sale", sale.id,
                                   f"بيع {sale.invoice_number}", cashier_id)

    # Auto-archive within the same transaction
    from app.models.archive import ArchivedDocument, DocType
    db.add(ArchivedDocument(doc_number=sale.invoice_number, doc_type=DocType.sale_invoice,
                            amount=Decimal(str(total)), ref_id=sale.id, created_by=cashier_id,
                            metadata_={"items_count": len(data.items), "mode": str(data.sale_mode)}))

    await db.commit()
    result = await db.execute(select(Sale).options(selectinload(Sale.items)).where(Sale.id == sale.id))
    return result.scalar_one()


async def return_sale(db: AsyncSession, sale_id: uuid.UUID, user_id: uuid.UUID) -> dict:
    """Full return: restore stock + record drawer return transaction."""
    result = await db.execute(select(Sale).options(selectinload(Sale.items)).where(Sale.id == sale_id).with_for_update())
    sale = result.scalar_one_or_none()
    if not sale:
        from app.core.exceptions import NotFoundError
        raise NotFoundError("Sale not found")
    if sale.status != SaleStatus.confirmed:
        raise BusinessError("Only confirmed sales can be returned")

    total = 0
    for item in sale.items:
        mv = StockMovementCreate(
            product_id=item.product_id,
            warehouse_id=sale.warehouse_id,
            movement_type=MovementType.return_in,
            qty=item.qty,
            unit_cost=item.unit_cost,
            unit_price=item.unit_price,
        )
        await record_movement(db, mv, user_id, ref_id=sale.id, ref_type="return")
        total += float(item.qty) * float(item.unit_price) - float(item.discount)

    total -= float(sale.discount_amount)
    sale.status = SaleStatus.returned

    if sale.shift_id:
        dt = DrawerTransaction(
            shift_id=sale.shift_id,
            type=DrawerTxType.return_,
            amount=total,
            ref_id=sale.id,
            created_by=user_id,
        )
        db.add(dt)

    # Reverse wallet balance if paid by wallet
    if sale.wallet_id:
        from app.services.wallet_service import record_wallet_tx
        await record_wallet_tx(db, sale.wallet_id, -Decimal(str(total)), "return",
                               sale.id, f"مرتجع {sale.invoice_number}", user_id)

    await db.commit()
    return {"detail": "Returned", "invoice_number": sale.invoice_number, "amount": total}


async def cancel_sale(db: AsyncSession, sale_id: uuid.UUID, user_id: uuid.UUID) -> Sale:
    result = await db.execute(select(Sale).where(Sale.id == sale_id).with_for_update())
    sale = result.scalar_one_or_none()
    if not sale:
        from app.core.exceptions import NotFoundError
        raise NotFoundError("Sale not found")
    if sale.status != SaleStatus.confirmed:
        raise BusinessError("Only confirmed sales can be cancelled")
    sale.status = SaleStatus.cancelled
    await db.commit()
    await db.refresh(sale)
    return sale
