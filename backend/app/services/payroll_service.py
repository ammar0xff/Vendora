"""Payroll service — business logic extracted from hr.py router."""
import asyncio
import json
from datetime import UTC, date
from functools import partial
from typing import Any

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import BusinessError
from app.services.payroll_engine import calculate_payroll as calc_engine


async def get_or_create_period(db: AsyncSession, month: str) -> str:
    """Get period_id for month, creating if needed. Returns period_id."""
    period_row = await db.execute(
        text("SELECT id FROM hr_payroll_periods WHERE month=:m"), {"m": month}
    )
    if not period_row:
        await db.execute(
            text("INSERT INTO hr_payroll_periods (month, status) VALUES (:m, 'draft')"),
            {"m": month},
        )
        await db.commit()
        period_row = await db.execute(
            text("SELECT id FROM hr_payroll_periods WHERE month=:m"), {"m": month}
        )
    return period_row.fetchone()[0]


async def get_period_status(db: AsyncSession, month: str) -> str | None:
    """Get status of a payroll period."""
    return await db.execute(
        text("SELECT status FROM hr_payroll_periods WHERE month=:m"), {"m": month}
    ).scalar_one_or_none()


async def load_hr_settings(db: AsyncSession) -> dict:
    rows = await db.execute(text("SELECT key, value FROM hr_settings"))
    return {r[0]: r[1] for r in rows.fetchall()}


async def load_shifts_map(db: AsyncSession) -> dict:
    shifts_rows = await db.execute(
        text("SELECT id, name, start_time, end_time FROM hr_shifts")
    )
    return {
        r[0]: {"id": r[0], "name": r[1], "start_time": r[2], "end_time": r[3]}
        for r in shifts_rows.fetchall()
    }


async def load_active_employees(db: AsyncSession, employee_id: str | None = None) -> list[dict]:
    emp_q = """
        SELECT id, emp_code, name, position, monthly_salary, shift_schedule, shift_id,
               hire_date, ignore_lateness, max_lateness_before_overtime_cancellation
        FROM hr_employees WHERE is_active=TRUE
    """
    if employee_id:
        emp_q += " AND id=:eid"
        emps = await db.execute(text(emp_q), {"eid": employee_id})
    else:
        emps = await db.execute(text(emp_q))
    emp_cols = [
        "id", "emp_code", "name", "position", "monthly_salary", "shift_schedule",
        "shift_id", "hire_date", "ignore_lateness", "max_lateness_before_overtime_cancellation"
    ]
    return [dict(zip(emp_cols, r, strict=False)) for r in emps.fetchall()]


async def load_attendance_for_month(
    db: AsyncSession, employee_id: str, month: str
) -> list[dict]:
    att_rows = await db.execute(
        text("""
            SELECT check_in, check_out, status, edited, edited_by, edit_reason,
                   excuse_no_late, excuse_no_early, excuse_allow_overtime, shift_override
            FROM hr_attendance WHERE employee_id=:eid AND TO_CHAR(work_date,'YYYY-MM')=:month
        """),
        {"eid": employee_id, "month": month},
    )
    att_cols = [
        "check_in", "check_out", "status", "edited", "edited_by", "edit_reason",
        "excuse_no_late", "excuse_no_early", "excuse_allow_overtime", "shift_override"
    ]
    return [dict(zip(att_cols, r, strict=False)) for r in att_rows.fetchall()]


async def load_advances_for_month(
    db: AsyncSession, employee_id: str, month: str
) -> float:
    return (
        await db.execute(
            text("""
                SELECT COALESCE(SUM(amount),0) FROM hr_advances
                WHERE employee_id=:eid AND TO_CHAR(date,'YYYY-MM')=:month
            """),
            {"eid": employee_id, "month": month},
        )
    ).scalar() or 0


async def calculate_employee_payroll(
    emp: dict,
    attendances: list[dict],
    settings: dict,
    shifts_map: dict,
    advance: float,
    month: str,
) -> dict:
    """Run payroll engine for a single employee."""
    return await asyncio.get_running_loop().run_in_executor(
        None,
        partial(calc_engine, emp, attendances, settings, shifts_map, advance=advance, month=month),
    )


async def save_payroll_entry(
    db: AsyncSession,
    period_id: str,
    employee_id: str,
    result: dict,
    current_user_id: str,
) -> None:
    """Upsert payroll entry for an employee in a period."""
    await db.execute(
        text("""
            INSERT INTO hr_payroll_entries (
                period_id, employee_id, base_salary, working_days, actual_working_days,
                absent_days, vacation_days, total_hours, lateness_minutes, early_leave_minutes,
                missing_scan_minutes, lateness_deduction, overtime_hours, overtime_pay,
                bonus_days, bonus_payment, bonuses, deductions, advances, drawer_variance, net_salary,
                hourly_rate, daily_breakdown, created_by, status
            ) VALUES (
                :pid, :eid, :base, :wd, :awd, :abd, :vd, :th, :lm, :elm, :msm, :ld, :oth, :otp,
                :bd, :bp, :bonus, :ded, :adv, 0, :net, :hr, CAST(:db AS jsonb), :by, 'draft'
            )
            ON CONFLICT (period_id, employee_id) DO UPDATE SET
                working_days=EXCLUDED.working_days, actual_working_days=EXCLUDED.actual_working_days,
                absent_days=EXCLUDED.absent_days, total_hours=EXCLUDED.total_hours,
                lateness_minutes=EXCLUDED.lateness_minutes, lateness_deduction=EXCLUDED.lateness_deduction,
                overtime_hours=EXCLUDED.overtime_hours, overtime_pay=EXCLUDED.overtime_pay,
                bonus_days=EXCLUDED.bonus_days, bonus_payment=EXCLUDED.bonus_payment,
                bonuses=EXCLUDED.bonuses, deductions=EXCLUDED.deductions,
                advances=EXCLUDED.advances, net_salary=EXCLUDED.net_salary,
                hourly_rate=EXCLUDED.hourly_rate, daily_breakdown=EXCLUDED.daily_breakdown,
                status=EXCLUDED.status
        """),
        {
            "pid": period_id, "eid": employee_id, "base": result["base_salary"],
            "wd": result["working_days"], "awd": result["actual_working_days"],
            "abd": result["absent_days"], "vd": result["vacation_days"],
            "th": result["total_hours"], "lm": result["lateness_minutes"],
            "elm": result["early_leave_minutes"], "msm": result["missing_scan_minutes"],
            "ld": result["lateness_deduction"], "oth": result["overtime_hours"],
            "otp": result["overtime_pay"], "bd": result["bonus_days"],
            "bp": result["bonus_payment"], "bonus": result["bonus"],
            "ded": result["deductions"], "adv": result["advances"],
            "net": result["net_salary"], "hr": result["hourly_rate"],
            "db": json.dumps(result["daily_breakdown"], ensure_ascii=False),
            "by": current_user_id,
        },
    )


async def calculate_payroll_month(
    db: AsyncSession,
    month: str,
    current_user_id: str,
    employee_id: str | None = None,
) -> dict:
    """Calculate payroll for all (or one) employee(s) for a month."""
    # Check period status
    period_status = await get_period_status(db, month)
    if period_status == "paid":
        raise BusinessError("تم صرف رواتب هذا الشهر بالفعل — لا يمكن إعادة الحساب")
    if period_status == "approved":
        raise BusinessError("تم اعتماد رواتب هذا الشهر — لا يمكن إعادة الحساب إلا بعد إعادة فتح الشهر")

    period_id = await get_or_create_period(db, month)

    settings = await load_hr_settings(db)
    shifts_map = await load_shifts_map(db)
    employees = await load_active_employees(db, employee_id)

    results = []
    for emp in employees:
        eid = emp["id"]
        attendances = await load_attendance_for_month(db, eid, month)
        advance = await load_advances_for_month(db, eid, month)

        result = await calculate_employee_payroll(emp, attendances, settings, shifts_map, float(advance), month)
        await save_payroll_entry(db, period_id, eid, result, current_user_id)

        results.append({
            "name": emp["name"], "net": result["net_salary"],
            "working_days": result["working_days"], "lateness_min": result["lateness_minutes"],
            "overtime_h": result["overtime_hours"]
        })

    await db.commit()
    return {"month": month, "employees": len(results), "total": sum(r["net"] for r in results), "detail": results}


async def update_period_status(
    db: AsyncSession, month: str, new_status: str, current_user_id: str
) -> None:
    """Update period status and all related payroll entries."""
    await db.execute(
        text(f"""
            INSERT INTO hr_payroll_periods (month, status, {new_status}_by, {new_status}_at)
            VALUES (:m, '{new_status}', :by, now())
            ON CONFLICT (month) DO UPDATE SET status='{new_status}', {new_status}_by=:by, {new_status}_at=now(), updated_at=now()
        """),
        {"m": month, "by": current_user_id},
    )
    await db.execute(
        text("""
            UPDATE hr_payroll_entries SET status=:st
            WHERE period_id = (SELECT id FROM hr_payroll_periods WHERE month=:m)
        """),
        {"st": new_status, "m": month},
    )
    await db.commit()


async def submit_payroll_period(db: AsyncSession, month: str, current_user_id: str) -> None:
    status = await get_period_status(db, month) or "draft"
    if status != "draft":
        raise BusinessError("لا يمكن إرسال الشهر للمراجعة إلا من حالة مسودة")
    await update_period_status(db, month, "review", current_user_id)


async def approve_payroll_period(db: AsyncSession, month: str, current_user_id: str) -> float:
    status = await get_period_status(db, month) or "draft"
    if status != "review":
        raise BusinessError("لا يمكن اعتماد الشهر إلا بعد المراجعة")

    total = await db.execute(
        text("""
            SELECT COALESCE(SUM(pe.net_salary),0)
            FROM hr_payroll_entries pe
            JOIN hr_payroll_periods p ON pe.period_id = p.id
            WHERE p.month = :m
        """),
        {"m": month},
    )
    total = float(total.scalar() or 0)

    # Ensure expense category exists
    cat_id = await db.execute(
        text("SELECT id FROM financial_categories WHERE name='رواتب' AND type='expense'")
    ).scalar_one_or_none()
    if not cat_id:
        cat_id = await db.execute(
            text("INSERT INTO financial_categories (name, type, color) VALUES ('رواتب','expense','#dc2626') RETURNING id")
        ).scalar_one()

    # Record monthly payroll as approved expense
    marker = f"HR payroll month {month}"
    exists = await db.execute(
        text("SELECT 1 FROM expenses WHERE notes=:n LIMIT 1"), {"n": marker}
    ).scalar_one_or_none()
    if not exists and total > 0:
        await db.execute(
            text("""
                INSERT INTO expenses (category_id, amount, description, date, status, created_by, notes)
                VALUES (:cid, :amt, :desc, :dt, 'approved', :by, :notes)
            """),
            {
                "cid": cat_id,
                "amt": total,
                "desc": f"رواتب شهر {month}",
                "dt": date(int(month[:4]), int(month[5:7]), 1),
                "by": current_user_id,
                "notes": marker,
            },
        )

    await update_period_status(db, month, "approved", current_user_id)
    return total


async def pay_payroll_period(db: AsyncSession, month: str, current_user_id: str) -> None:
    status = await get_period_status(db, month) or "draft"
    if status != "approved":
        raise BusinessError("لا يمكن صرف الشهر إلا بعد الاعتماد")
    await update_period_status(db, month, "paid", current_user_id)


async def reopen_payroll_period(db: AsyncSession, month: str) -> None:
    status = await get_period_status(db, month)
    if status == "paid":
        raise BusinessError("لا يمكن إعادة فتح شهر تم صرفه")
    await update_period_status(db, month, "draft", "")


async def update_payroll_entry(
    db: AsyncSession,
    payroll_id: str,
    bonus: float,
    deductions: float,
    drawer_variance: float,
    status: str,
    notes: str,
) -> float:
    """Update manual adjustments on a payroll entry."""
    row = await db.execute(
        text("""
            SELECT base_salary, lateness_deduction, overtime_pay, bonus_payment, advances
            FROM hr_payroll_entries WHERE id=:id
        """),
        {"id": payroll_id},
    ).mappings().fetchone()
    if not row:
        raise BusinessError("سجل الراتب غير موجود")

    base_salary = float(row["base_salary"] or 0)
    lateness_deduction = float(row["lateness_deduction"] or 0)
    overtime_pay = float(row["overtime_pay"] or 0)
    engine_bonus = float(row["bonus_payment"] or 0)
    advances = float(row["advances"] or 0)

    net_salary = (
        base_salary
        - lateness_deduction
        - float(deductions)
        - advances
        + overtime_pay
        + engine_bonus
        + float(bonus)
        + float(drawer_variance)
    )
    net_salary = max(0, round(net_salary, 2))

    await db.execute(
        text("""
            UPDATE hr_payroll_entries
            SET bonus=:bonus, deductions=:ded, drawer_variance=:var,
                net_salary=:net, status=:status, notes=:notes
            WHERE id=:id
        """),
        {
            "id": payroll_id,
            "bonus": bonus,
            "ded": deductions,
            "var": drawer_variance,
            "net": net_salary,
            "status": status,
            "notes": notes or "",
        },
    )
    await db.commit()
    return net_salary


async def get_daily_breakdown(db: AsyncSession, payroll_id: str) -> dict:
    """Get daily attendance breakdown for a payroll record."""
    r = await db.execute(
        text("SELECT pe.daily_breakdown, e.name FROM hr_payroll_entries pe JOIN hr_employees e ON pe.employee_id=e.id WHERE pe.id=:id"),
        {"id": payroll_id},
    )
    row = r.fetchone()
    if not row:
        raise BusinessError("سجل الراتب غير موجود")
    return {"employee": row[1], "breakdown": row[0]}