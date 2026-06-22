from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from decimal import Decimal
from app.db.base import get_db
from app.models.party import Customer
from app.models.sale import Sale, SaleItem, SaleStatus
from app.models.customer_payment import CustomerPayment
from app.dependencies import get_current_user, require_perm
from app.models.user import User
from app.core.exceptions import NotFoundError
from app.services.audit_service import log as audit_log
from app.schemas.party import CustomerCreate, CustomerUpdate, CustomerPaymentCreate
import uuid

router = APIRouter(tags=["parties"])


# ── Customers ────────────────────────────────────────────────────────────────
@router.get("/customers")
async def list_customers(search: str | None = None, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    from sqlalchemy import text as sqlt
    params: dict = {}
    where_parts = ["1=1"]
    if search:
        where_parts.append("c.name ILIKE :search")
        params["search"] = f"%{search}%"
    where = " AND ".join(where_parts)
    rows = await db.execute(sqlt(f"""
        SELECT c.*, c.balance AS balance_due
        FROM customers c
        WHERE {where}
        ORDER BY c.name
    """    ), params)
    return [dict(r._mapping) for r in rows.fetchall()]
# TODO: needs pagination — no limit/offset


@router.post("/customers")
async def create_customer(data: CustomerCreate, db: AsyncSession = Depends(get_db), _=Depends(require_perm("customers"))):
    c = Customer(**data.model_dump())
    db.add(c)
    await db.commit()
    await db.refresh(c)
    return c


@router.put("/customers/{cid}")
async def update_customer(cid: uuid.UUID, data: CustomerUpdate, db: AsyncSession = Depends(get_db), _=Depends(require_perm("customers"))):
    result = await db.execute(select(Customer).where(Customer.id == cid))
    c = result.scalar_one_or_none()
    if not c:
        raise NotFoundError()
    for k, v in data.model_dump(exclude_unset=True).items():
        setattr(c, k, v)
    await db.commit()
    await db.refresh(c)
    return c


@router.get("/customers/{cid}/account")
async def customer_account(cid: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    """Customer ledger: total invoiced, total paid, balance due."""
    from sqlalchemy import text as sqlt
    c = (await db.execute(select(Customer).where(Customer.id == cid))).scalar_one_or_none()
    if not c:
        raise NotFoundError()

    r = await db.execute(sqlt("""
        SELECT
            COALESCE((SELECT SUM(si.qty * si.unit_price - si.discount) - MAX(s.discount_amount)
                      FROM sales s JOIN sale_items si ON si.sale_id = s.id
                      WHERE s.customer_id = :cid AND s.is_credit = true AND s.status = 'confirmed'), 0)
            AS total_invoiced,
            COALESCE((SELECT SUM(si.qty * si.unit_price - si.discount)
                      FROM sales s JOIN sale_items si ON si.sale_id = s.id
                      WHERE s.customer_id = :cid AND s.status = 'returned' AND s.is_credit), 0)
            AS total_returned,
            COALESCE((SELECT SUM(amount) FROM customer_payments WHERE customer_id = :cid), 0)
            AS total_paid
    """), {"cid": cid})
    agg = dict(r.fetchone()._mapping)

    return {
        "customer_id": str(cid),
        "customer_name": c.name,
        "phone": c.phone,
        "total_invoiced": float(agg["total_invoiced"]),
        "total_returned": float(agg["total_returned"]),
        "total_paid": float(agg["total_paid"]),
        "balance_due": float(c.balance),
        "credit_limit": float(c.credit_limit) if c.credit_limit else None,
    }


@router.get("/customers/{cid}/ledger")
async def customer_ledger(cid: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    """Full chronological ledger: invoices + returns + payments."""
    from sqlalchemy.orm import selectinload

    sales = (await db.execute(
        select(Sale).options(selectinload(Sale.items))
        .where(Sale.customer_id == cid,
               Sale.status.in_([SaleStatus.confirmed, SaleStatus.returned]),
               Sale.is_credit)
        .order_by(Sale.created_at.asc())  # oldest first for debt payment order
    )).scalars().all()

    payments = (await db.execute(
        select(CustomerPayment).where(CustomerPayment.customer_id == cid).order_by(CustomerPayment.created_at.desc())
    )).scalars().all()

    entries = []
    for s in sales:
        total = sum(float(i.qty) * float(i.unit_price) - float(i.discount) for i in s.items)
        entries.append({
            "type": "invoice" if s.status == SaleStatus.confirmed else "return",
            "ref": s.invoice_number,
            "amount": total,
            "date": s.created_at.isoformat(),
            "items_count": len(s.items),
        })
    for p in payments:
        entries.append({
            "type": "payment",
            "ref": str(p.id)[:8],
            "amount": float(p.amount),
            "note": p.note,
            "date": p.created_at.isoformat(),
        })

    entries.sort(key=lambda x: x["date"], reverse=True)
    return entries


@router.put("/customers/{cid}/balance")
async def set_customer_balance(cid: uuid.UUID, data: dict, db: AsyncSession = Depends(get_db), _=Depends(require_perm("customers"))):
    result = await db.execute(select(Customer).where(Customer.id == cid))
    c = result.scalar_one_or_none()
    if not c:
        raise NotFoundError()
    balance = Decimal(str(data.get("balance", 0)))
    c.balance = balance
    await db.commit()
    return {"id": str(cid), "balance": float(balance)}


@router.delete("/customers/{cid}")
async def delete_customer(cid: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(require_perm("customers"))):
    result = await db.execute(select(Customer).where(Customer.id == cid))
    c = result.scalar_one_or_none()
    if not c:
        raise NotFoundError()
    await db.delete(c)
    await db.commit()
    return {"ok": True}


@router.post("/customers/{cid}/payments")
async def add_payment(cid: uuid.UUID, data: CustomerPaymentCreate, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("customers"))):
    """Record a payment received from customer."""
    if data.amount <= 0:
        raise HTTPException(400, "المبلغ يجب أن يكون أكبر من 0")
    c = (await db.execute(select(Customer).where(Customer.id == cid))).scalar_one_or_none()
    if not c:
        raise NotFoundError()
    p = CustomerPayment(customer_id=cid, amount=data.amount, note=data.note, created_by=current_user.id)
    db.add(p)
    c.balance = (c.balance or 0) - data.amount
    await audit_log(db, "customer_payment", "create", current_user.id, current_user.full_name, p.id, {"customer_id": str(cid), "amount": float(data.amount)}, f"دفعة من {c.name}")
    await db.commit()
    await db.refresh(p)
    return {"id": str(p.id), "amount": float(p.amount), "note": p.note, "created_at": p.created_at.isoformat()}


