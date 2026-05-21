from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, text
from datetime import datetime
from app.db.base import get_db
from app.schemas.shift import ShiftOpen, ShiftClose, DrawerTxCreate, DrawerTxOut, ShiftOut, ShiftSummary
from app.models.shift import Shift, DrawerTransaction, ShiftStatus
from app.services import shift_service
from app.dependencies import get_current_user, require_role, require_perm
from app.models.user import User
from app.core.exceptions import NotFoundError
from pydantic import BaseModel
from decimal import Decimal
from typing import Optional
import uuid

router = APIRouter(prefix="/shifts", tags=["shifts"])


class TransferDrawerRequest(BaseModel):
    to_user_id: uuid.UUID
    amount: Decimal
    notes: Optional[str] = None


@router.post("/open", response_model=ShiftOut)
async def open_shift(data: ShiftOpen, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("shifts"))):
    return await shift_service.open_shift(db, current_user.id, data)


@router.get("/last-drawer")
async def last_drawer_amount(warehouse_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    result = await db.execute(
        select(Shift.next_day_drawer)
        .where(Shift.status == ShiftStatus.closed, Shift.next_day_drawer != None,
               Shift.warehouse_id == warehouse_id)
        .order_by(Shift.closed_at.desc()).limit(1)
    )
    val = result.scalar_one_or_none()
    return {"amount": float(val) if val is not None else 0.0}


async def current_shift(db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    result = await db.execute(select(Shift).where(Shift.cashier_id == current_user.id, Shift.status == ShiftStatus.open))
    shift = result.scalar_one_or_none()
    if not shift:
        raise NotFoundError("No open shift")
    return shift


@router.get("/current", response_model=ShiftOut)
async def current_shift(warehouse_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    """Get the open shift for a specific warehouse."""
    result = await db.execute(
        select(Shift).where(Shift.warehouse_id == warehouse_id, Shift.status == ShiftStatus.open)
        .order_by(Shift.started_at.desc()).limit(1)
    )
    shift = result.scalar_one_or_none()
    if not shift:
        raise NotFoundError("No open shift")
    # attach cashier_name
    out = ShiftOut.model_validate(shift)
    if shift.cashier_id:
        name = (await db.execute(text("SELECT full_name FROM users WHERE id=:id"), {"id": shift.cashier_id})).scalar()
        out.cashier_name = name
    return out

@router.post("/{shift_id}/close", response_model=ShiftOut)
async def close_shift(shift_id: uuid.UUID, data: ShiftClose, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("shifts"))):
    return await shift_service.close_shift(db, shift_id, data, current_user.id)


class CloseWithManagerRequest(BaseModel):
    closing_balance: Decimal
    next_day_drawer: Decimal
    notes: Optional[str] = None
    manager_id: uuid.UUID
    manager_password: str


@router.post("/{shift_id}/close-with-manager")
async def close_with_manager(shift_id: uuid.UUID, data: CloseWithManagerRequest, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("shifts"))):
    from app.core.security import verify_password
    from sqlalchemy import text

    # Verify manager
    mgr_row = await db.execute(select(User).where(User.id == data.manager_id, User.is_manager == True))
    manager = mgr_row.scalar_one_or_none()
    if not manager:
        from app.core.exceptions import BusinessError
        raise BusinessError("المدير غير موجود أو ليس لديه صلاحية المدير")
    if not verify_password(data.manager_password, manager.password_hash):
        from app.core.exceptions import ForbiddenError
        raise ForbiddenError("كلمة مرور المدير غير صحيحة")

    # Close shift
    shift_row = await db.execute(select(Shift).where(Shift.id == shift_id))
    shift = shift_row.scalar_one_or_none()
    if not shift:
        raise NotFoundError()
    if shift.status != ShiftStatus.open:
        from app.core.exceptions import BusinessError
        raise BusinessError("الوردية مغلقة بالفعل")

    # Compute variance
    summary = await shift_service.compute_summary(db, shift_id)
    expected = summary["expected_balance"]
    variance = float(data.closing_balance) - float(expected)

    deposit = float(data.closing_balance) - float(data.next_day_drawer)

    shift.status = ShiftStatus.closed
    shift.closing_balance = data.closing_balance
    shift.next_day_drawer = data.next_day_drawer
    shift.notes = data.notes
    shift.closed_by = current_user.id
    shift.supervisor_id = data.manager_id
    shift.closed_at = datetime.utcnow()
    await db.execute(text("UPDATE shifts SET deposit_received_by=:mgr, deposit_amount=:dep WHERE id=:id"),
                     {"mgr": data.manager_id, "dep": deposit, "id": shift_id})

    # Apply variance to payroll as deduction/bonus
    if variance != 0 and shift.cashier_id:
        note = f"فرق عجز الدرج — وردية {shift_id}"
        record_type = "خصم" if variance < 0 else "مكافأة"
        await db.execute(text("""
            INSERT INTO hr_advances (employee_id, amount, note, record_type, date)
            SELECT e.id, :amount, :note, :rtype, NOW()
            FROM hr_employees e
            JOIN users u ON u.full_name = e.name
            WHERE u.id = :uid
            LIMIT 1
        """), {"amount": abs(variance), "note": note, "rtype": record_type, "uid": shift.cashier_id})

    await db.commit()
    await db.refresh(shift)
    return {**{c.name: getattr(shift, c.name) for c in shift.__table__.columns},
            "variance": variance, "expected_balance": float(expected)}


@router.post("/{shift_id}/transfer", response_model=ShiftOut)
async def transfer_drawer(shift_id: uuid.UUID, data: TransferDrawerRequest, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("shifts"))):
    """Hand over the cash drawer to another user — closes current shift and opens a new one."""
    return await shift_service.transfer_drawer(db, shift_id, data.to_user_id, data.amount, current_user.id, data.notes)


@router.get("/{shift_id}/summary", response_model=ShiftSummary)
async def shift_summary(shift_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    return await shift_service.compute_summary(db, shift_id)


@router.post("/{shift_id}/transactions", response_model=DrawerTxOut)
async def add_transaction(shift_id: uuid.UUID, data: DrawerTxCreate, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("shifts"))):
    return await shift_service.add_transaction(db, shift_id, data, current_user.id)


@router.get("/{shift_id}/transactions", response_model=list[DrawerTxOut])
async def list_transactions(shift_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    result = await db.execute(select(DrawerTransaction).where(DrawerTransaction.shift_id == shift_id).order_by(DrawerTransaction.created_at))
    return result.scalars().all()


@router.get("", response_model=list[ShiftOut])
async def list_shifts(
    limit: int = Query(default=100, ge=1, le=500),
    offset: int = Query(default=0, ge=0),
    warehouse_id: uuid.UUID | None = None,
    db: AsyncSession = Depends(get_db),
    _=Depends(get_current_user),
):
    q = select(Shift)
    if warehouse_id:
        q = q.where(Shift.warehouse_id == warehouse_id)
    q = q.order_by(Shift.started_at.desc()).limit(limit).offset(offset)
    result = await db.execute(q)
    return result.scalars().all()


@router.delete("/transactions/{tx_id}", status_code=204)
async def delete_drawer_transaction(
    tx_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_role("admin", "manager"))
):
    """Delete a drawer transaction. Reverses wallet balance if applicable."""
    from sqlalchemy import text as sqlt

    # Check shift is not closed
    shift_row = await db.execute(sqlt("""
        SELECT sh.status FROM shifts sh
        JOIN drawer_transactions dt ON dt.shift_id = sh.id
        WHERE dt.id = :id
    """), {"id": tx_id})
    shift_status = shift_row.scalar_one_or_none()
    if shift_status == "closed":
        raise HTTPException(400, "لا يمكن حذف معاملة من وردية مغلقة")

    row = await db.execute(sqlt("SELECT * FROM drawer_transactions WHERE id=:id"), {"id": tx_id})
    tx = row.fetchone()
    if not tx:
        raise HTTPException(404, "العملية غير موجودة")
    tx = dict(tx._mapping)

    # Reverse wallet balance
    if tx.get("wallet_id") and tx.get("payment_method") == "wallet":
        from app.services.wallet_service import record_wallet_tx
        from decimal import Decimal as D
        if tx["type"] == "deposit":
            await record_wallet_tx(db, tx["wallet_id"], -D(str(tx["amount"])), "deposit_reversed",
                                   tx_id, "حذف دواخل", current_user.id)
        elif tx["type"] in ("expense", "withdrawal"):
            await record_wallet_tx(db, tx["wallet_id"], D(str(tx["amount"])), "expense_reversed",
                                   tx_id, "حذف خوارج", current_user.id)

    await db.execute(sqlt("DELETE FROM drawer_transactions WHERE id=:id"), {"id": tx_id})
    await db.commit()
