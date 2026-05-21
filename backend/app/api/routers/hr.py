"""HR / Payroll router"""
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import date
from typing import Optional
from app.db.base import get_db
from app.dependencies import get_current_user, require_role, require_perm
from app.models.user import User
from app.core.exceptions import NotFoundError, BusinessError
from app.schemas.hr import EmployeeCreate, EmployeeUpdate, AttendanceCreate, PayrollCalculate, PayrollUpdate, AdvanceCreate
from sqlalchemy import text
import uuid

router = APIRouter(prefix="/hr", tags=["hr"])


@router.get("/audit-log")
async def get_audit_log(db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    r = await db.execute(text("""
        SELECT a.id, a.action_type, a.entity_type, a.entity_id, a.reason, a.details, a.created_at,
               u.full_name as performed_by_name
        FROM hr_audit_log a LEFT JOIN users u ON a.performed_by=u.id
        ORDER BY a.created_at DESC LIMIT 500
    """))
    cols = ['id','action_type','entity_type','entity_id','reason','details','created_at','performed_by_name']
    rows = r.fetchall()
    result = []
    for row in rows:
        d = dict(zip(cols, row))
        d['created_at'] = d['created_at'].isoformat() if d['created_at'] else None
        result.append(d)
    return result


@router.get("/shifts")
async def list_shifts(db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    r = await db.execute(text("SELECT * FROM hr_shifts ORDER BY start_time"))
    cols = r.keys()
    return [dict(zip(cols, row)) for row in r.fetchall()]


@router.post("/shifts")
async def create_shift(data: dict, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    import uuid as _uuid
    sid = str(int(_uuid.uuid4().int % 10**10))
    await db.execute(text("INSERT INTO hr_shifts (id, name, start_time, end_time, description) VALUES (:id,:name,:st,:et,:desc)"),
                     {'id': sid, 'name': data['name'], 'st': data['start_time'], 'et': data['end_time'], 'desc': data.get('description','')})
    await db.commit()
    return {'id': sid, 'name': data['name']}


@router.get("/settings")
async def get_hr_settings(db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    r = await db.execute(text("SELECT key, value FROM hr_settings"))
    return {row[0]: row[1] for row in r.fetchall()}


@router.put("/settings")
async def update_hr_settings(data: dict, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    for k, v in data.items():
        await db.execute(text("INSERT INTO hr_settings (key, value) VALUES (:k,:v) ON CONFLICT (key) DO UPDATE SET value=EXCLUDED.value"),
                         {'k': k, 'v': str(v)})
    await db.commit()
    return {"detail": "saved"}


# ── Employees ─────────────────────────────────────────────────────────────
@router.get("/employees")
async def list_employees(db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    r = await db.execute(text("SELECT * FROM hr_employees WHERE is_active=TRUE ORDER BY name"))
    cols = r.keys()
    return [dict(zip(cols, row)) for row in r.fetchall()]


@router.post("/employees")
async def create_employee(data: EmployeeCreate, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    r = await db.execute(text("""
        INSERT INTO hr_employees (emp_code, name, position, monthly_salary, shift_schedule, hire_date)
        VALUES (:code, :name, :pos, :sal, :shift, :hire) RETURNING *
    """), {'code': data.emp_code, 'name': data.name, 'pos': data.position or '',
           'sal': data.monthly_salary, 'shift': data.shift_schedule or '',
           'hire': data.hire_date})
    await db.commit()
    row = r.fetchone()
    return dict(zip(r.keys(), row))


@router.put("/employees/{emp_id}")
async def update_employee(emp_id: uuid.UUID, data: EmployeeUpdate, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    vals = data.model_dump(exclude_unset=True)
    if not vals:
        return {"detail": "no changes"}
    cols = []
    params: dict = {"id": emp_id}
    col_map = {"name": "name", "position": "pos", "monthly_salary": "sal",
               "shift_schedule": "shift", "hire_date": "hire"}
    for k, v in vals.items():
        c = col_map.get(k)
        if c is None:
            continue
        cols.append(f"{c}=:{k}")
        params[k] = v
    if not cols:
        return {"detail": "no changes"}
    await db.execute(text(f"UPDATE hr_employees SET {','.join(cols)} WHERE id=:id"), params)
    await db.commit()
    return {"detail": "updated"}


@router.delete("/employees/{emp_id}", status_code=204)
async def delete_employee(emp_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    await db.execute(text("UPDATE hr_employees SET is_active=FALSE WHERE id=:id"), {'id': emp_id})
    await db.commit()


# ── Attendance ─────────────────────────────────────────────────────────────
@router.get("/attendance")
async def list_attendance(employee_id: Optional[str] = None, month: Optional[str] = None,
                          db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    q = "SELECT a.*, e.name as emp_name FROM hr_attendance a JOIN hr_employees e ON a.employee_id=e.id WHERE 1=1"
    params = {}
    if employee_id:
        q += " AND a.employee_id=:eid"
        params['eid'] = uuid.UUID(employee_id)
    if month:
        q += " AND TO_CHAR(a.work_date,'YYYY-MM')=:month"
        params['month'] = month
    q += " ORDER BY a.work_date DESC"
    r = await db.execute(text(q), params)
    cols = r.keys()
    return [dict(zip(cols, row)) for row in r.fetchall()]


@router.post("/attendance")
async def add_attendance(data: AttendanceCreate, db: AsyncSession = Depends(get_db), _=Depends(require_perm("payroll"))):
    await db.execute(text("""
        INSERT INTO hr_attendance (employee_id, work_date, check_in, check_out, status, notes)
        VALUES (:eid, :dt, :ci, :co, :st, :notes)
        ON CONFLICT (employee_id, work_date) DO UPDATE
        SET check_in=EXCLUDED.check_in, check_out=EXCLUDED.check_out,
            status=EXCLUDED.status, notes=EXCLUDED.notes
    """), {'eid': data.employee_id, 'dt': data.work_date,
           'ci': data.check_in, 'co': data.check_out,
           'st': data.status, 'notes': data.notes or ''})
    await db.commit()
    return {"detail": "saved"}


@router.post("/attendance/import-csv")
async def import_attendance_csv(file: UploadFile = File(...), db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("payroll"))):
    import csv
    import io
    content = await file.read()
    text_content = content.decode('utf-8-sig')
    reader = csv.DictReader(io.StringIO(text_content))

    if not reader.fieldnames:
        raise HTTPException(400, "Empty CSV or no headers found")

    col_map = {}
    for h in reader.fieldnames:
        hl = h.lower().strip()
        if hl in ('employee_code', 'emp_code', 'uid', 'employee id', 'employee_id', 'emp id'):
            col_map[h] = 'emp_code'
        elif hl in ('date', 'work_date', 'attendance_date', 'day'):
            col_map[h] = 'date'
        elif hl in ('check_in', 'clock_in', 'time_in', 'in', 'checkin'):
            col_map[h] = 'check_in'
        elif hl in ('check_out', 'clock_out', 'time_out', 'out', 'checkout'):
            col_map[h] = 'check_out'
        elif hl in ('status', 'attendance_status'):
            col_map[h] = 'status'

    if 'emp_code' not in col_map.values() or 'date' not in col_map.values():
        raise HTTPException(400, f"CSV must have employee_code and date columns. Found: {reader.fieldnames}")

    from datetime import date as _date, datetime as _dt

    added = updated = skipped = 0
    errors = []

    for row in reader:
        try:
            emp_code = str(row.get([k for k, v in col_map.items() if v == 'emp_code'][0], '')).strip()
            date_str = str(row.get([k for k, v in col_map.items() if v == 'date'][0], '')).strip()
            check_in_raw = row.get([k for k, v in col_map.items() if v == 'check_in'][0], '').strip() if 'check_in' in col_map.values() else ''
            check_out_raw = row.get([k for k, v in col_map.items() if v == 'check_out'][0], '').strip() if 'check_out' in col_map.values() else ''
            status_raw = row.get([k for k, v in col_map.items() if v == 'status'][0], '').strip() if 'status' in col_map.values() else 'present'
        except (IndexError, KeyError):
            skipped += 1
            continue

        if not emp_code or not date_str:
            skipped += 1
            continue

        emp = (await db.execute(text("SELECT id FROM hr_employees WHERE emp_code=:code"), {"code": emp_code})).fetchone()
        if not emp:
            errors.append(f"رمز '{emp_code}' غير موجود")
            skipped += 1
            continue

        try:
            work_date = _date.fromisoformat(date_str[:10])
        except ValueError:
            errors.append(f"تاريخ غير صالح '{date_str}'")
            skipped += 1
            continue

        check_in = None
        if check_in_raw:
            try:
                check_in = _dt.fromisoformat(check_in_raw.replace('Z', '+00:00').replace(' ', 'T')).replace(tzinfo=None)
            except ValueError:
                try:
                    check_in = _dt.strptime(check_in_raw.strip(), '%H:%M').time()
                    check_in = _dt.combine(work_date, check_in)
                except ValueError:
                    errors.append(f"وقت غير صالح '{check_in_raw}'")

        check_out = None
        if check_out_raw:
            try:
                check_out = _dt.fromisoformat(check_out_raw.replace('Z', '+00:00').replace(' ', 'T')).replace(tzinfo=None)
            except ValueError:
                try:
                    check_out = _dt.strptime(check_out_raw.strip(), '%H:%M').time()
                    check_out = _dt.combine(work_date, check_out)
                except ValueError:
                    errors.append(f"وقت غير صالح '{check_out_raw}'")

        status = status_raw.lower() if status_raw else 'present'

        existing = (await db.execute(text(
            "SELECT id, edited FROM hr_attendance WHERE employee_id=:e AND work_date=:d"
        ), {"e": emp[0], "d": work_date})).fetchone()

        if existing:
            if existing[1]:
                skipped += 1
                continue
            await db.execute(text(
                "UPDATE hr_attendance SET check_in=:ci, check_out=:co, status=:st WHERE id=:id"
            ), {"ci": check_in, "co": check_out, "st": status, "id": existing[0]})
            updated += 1
        else:
            await db.execute(text(
                "INSERT INTO hr_attendance (employee_id, work_date, check_in, check_out, status, created_by) VALUES (:e,:d,:ci,:co,:st,:by)"
            ), {"e": emp[0], "d": work_date, "ci": check_in, "co": check_out, "st": status, "by": current_user.id})
            added += 1

    await db.commit()
    return {
        "added": added,
        "updated": updated,
        "skipped": skipped,
        "errors": errors[:20],
        "total": added + updated + skipped,
    }


# ── Payroll ────────────────────────────────────────────────────────────────
@router.get("/payroll")
async def list_payroll(month: Optional[str] = None, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    q = "SELECT p.*, e.name as emp_name, e.position FROM hr_payroll p JOIN hr_employees e ON p.employee_id=e.id WHERE 1=1"
    params = {}
    if month:
        q += " AND p.month=:month"
        params['month'] = month
    q += " ORDER BY e.name"
    r = await db.execute(text(q), params)
    cols = r.keys()
    return [dict(zip(cols, row)) for row in r.fetchall()]


@router.post("/payroll/calculate")
async def calculate_payroll(data: PayrollCalculate, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("payroll"))):
    """Calculate payroll for all (or one) employee using the full engine."""
    from app.services.payroll_engine import calculate_payroll as calc
    import json as _json

    month = data.month  # YYYY-MM

    # Workflow: do not allow recalculation after approval/payment.
    period = (await db.execute(text("SELECT status FROM hr_payroll_periods WHERE month=:m"), {"m": month})).scalar_one_or_none()
    if period == "paid":
        raise BusinessError("تم صرف رواتب هذا الشهر بالفعل — لا يمكن إعادة الحساب")
    if period == "approved":
        raise BusinessError("تم اعتماد رواتب هذا الشهر — لا يمكن إعادة الحساب إلا بعد إعادة فتح الشهر")

    # Load settings
    settings_rows = (await db.execute(text("SELECT key, value FROM hr_settings"))).fetchall()
    settings = {r[0]: r[1] for r in settings_rows}

    # Load shifts
    shifts_rows = (await db.execute(text("SELECT id, name, start_time, end_time FROM hr_shifts"))).fetchall()
    shifts_map = {r[0]: {'id': r[0], 'name': r[1], 'start_time': r[2], 'end_time': r[3]} for r in shifts_rows}

    # Load employees
    emp_q = "SELECT id, emp_code, name, position, monthly_salary, shift_schedule, shift_id, hire_date, ignore_lateness, max_lateness_before_overtime_cancellation FROM hr_employees WHERE is_active=TRUE"
    if data.employee_id:
        emp_q += " AND id=:eid"
        emps = (await db.execute(text(emp_q), {'eid': data.employee_id})).fetchall()
    else:
        emps = (await db.execute(text(emp_q))).fetchall()
    emp_cols = ['id','emp_code','name','position','monthly_salary','shift_schedule','shift_id','hire_date','ignore_lateness','max_lateness_before_overtime_cancellation']

    results = []
    for emp_row in emps:
        emp = dict(zip(emp_cols, emp_row))
        eid = emp['id']

        # Load attendance for this month
        att_rows = (await db.execute(text("""
            SELECT check_in, check_out, status, edited, edited_by, edit_reason,
                   excuse_no_late, excuse_no_early, excuse_allow_overtime, shift_override
            FROM hr_attendance WHERE employee_id=:eid AND TO_CHAR(work_date,'YYYY-MM')=:month
        """), {'eid': eid, 'month': month})).fetchall()
        att_cols = ['check_in','check_out','status','edited','edited_by','edit_reason',
                    'excuse_no_late','excuse_no_early','excuse_allow_overtime','shift_override']
        attendances = [dict(zip(att_cols, r)) for r in att_rows]

        # Load advances for this month
        adv = (await db.execute(text("""
            SELECT COALESCE(SUM(amount),0) FROM hr_advances
            WHERE employee_id=:eid AND TO_CHAR(date,'YYYY-MM')=:month
        """), {'eid': eid, 'month': month})).scalar() or 0

        result = calc(emp, attendances, settings, shifts_map, advance=float(adv), month=month)

        # Save to DB
        await db.execute(text("""
            INSERT INTO hr_payroll (employee_id, month, base_salary, working_days, actual_working_days,
                absent_days, vacation_days, total_hours, lateness_minutes, early_leave_minutes,
                missing_scan_minutes, lateness_deduction, overtime_hours, overtime_pay,
                bonus_days, bonus_payment, bonus, deductions, advances, drawer_variance, net_salary,
                hourly_rate, daily_breakdown, created_by)
            VALUES (:eid,:month,:base,:wd,:awd,:abd,:vd,:th,:lm,:elm,:msm,:ld,:oth,:otp,
                    :bd,:bp,:bonus,:ded,:adv,0,:net,:hr,CAST(:db AS jsonb),:by)
            ON CONFLICT (employee_id, month) DO UPDATE SET
                working_days=EXCLUDED.working_days, actual_working_days=EXCLUDED.actual_working_days,
                absent_days=EXCLUDED.absent_days, total_hours=EXCLUDED.total_hours,
                lateness_minutes=EXCLUDED.lateness_minutes, lateness_deduction=EXCLUDED.lateness_deduction,
                overtime_hours=EXCLUDED.overtime_hours, overtime_pay=EXCLUDED.overtime_pay,
                advances=EXCLUDED.advances, net_salary=EXCLUDED.net_salary,
                hourly_rate=EXCLUDED.hourly_rate, daily_breakdown=EXCLUDED.daily_breakdown
        """), {
            'eid': eid, 'month': month, 'base': result['base_salary'],
            'wd': result['working_days'], 'awd': result['actual_working_days'],
            'abd': result['absent_days'], 'vd': result['vacation_days'],
            'th': result['total_hours'], 'lm': result['lateness_minutes'],
            'elm': result['early_leave_minutes'], 'msm': result['missing_scan_minutes'],
            'ld': result['lateness_deduction'], 'oth': result['overtime_hours'],
            'otp': result['overtime_pay'], 'bd': result['bonus_days'],
            'bp': result['bonus_payment'], 'bonus': result['bonus'],
            'ded': result['deductions'], 'adv': result['advances'],
            'net': result['net_salary'], 'hr': result['hourly_rate'],
            'db': _json.dumps(result['daily_breakdown'], ensure_ascii=False),
            'by': current_user.id,
        })
        results.append({'name': emp['name'], 'net': result['net_salary'],
                        'working_days': result['working_days'], 'lateness_min': result['lateness_minutes'],
                        'overtime_h': result['overtime_hours']})

    await db.commit()
    return {'month': month, 'employees': len(results), 'total': sum(r['net'] for r in results), 'detail': results}


@router.get("/payroll/period")
async def get_payroll_period(month: str, db: AsyncSession = Depends(get_db), _=Depends(require_perm("payroll"))):
    row = (await db.execute(text("SELECT * FROM hr_payroll_periods WHERE month=:m"), {"m": month})).mappings().fetchone()
    if not row:
        await db.execute(text("INSERT INTO hr_payroll_periods (month, status) VALUES (:m, 'draft')"), {"m": month})
        await db.commit()
        row = (await db.execute(text("SELECT * FROM hr_payroll_periods WHERE month=:m"), {"m": month})).mappings().fetchone()
    return dict(row)


@router.post("/payroll/period/submit")
async def submit_payroll_period(month: str, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("payroll"))):
    status = (await db.execute(text("SELECT status FROM hr_payroll_periods WHERE month=:m"), {"m": month})).scalar_one_or_none() or "draft"
    if status != "draft":
        raise BusinessError("لا يمكن إرسال الشهر للمراجعة إلا من حالة مسودة")
    await db.execute(text("""
        INSERT INTO hr_payroll_periods (month, status, submitted_by, submitted_at)
        VALUES (:m, 'review', :by, now())
        ON CONFLICT (month) DO UPDATE SET status='review', submitted_by=:by, submitted_at=now(), updated_at=now()
    """), {"m": month, "by": current_user.id})
    await db.execute(text("UPDATE hr_payroll SET status='draft' WHERE month=:m"), {"m": month})
    await db.commit()
    return {"detail": "submitted"}


@router.post("/payroll/period/approve")
async def approve_payroll_period(month: str, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_role("admin", "manager"))):
    status = (await db.execute(text("SELECT status FROM hr_payroll_periods WHERE month=:m"), {"m": month})).scalar_one_or_none() or "draft"
    if status != "review":
        raise BusinessError("لا يمكن اعتماد الشهر إلا بعد المراجعة")

    total = (await db.execute(text("SELECT COALESCE(SUM(net_salary),0) FROM hr_payroll WHERE month=:m"), {"m": month})).scalar() or 0
    # Ensure expense category exists
    cat_id = (await db.execute(text("SELECT id FROM financial_categories WHERE name='رواتب' AND type='expense'"))).scalar_one_or_none()
    if not cat_id:
        cat_id = (await db.execute(text("""
            INSERT INTO financial_categories (name, type, color) VALUES ('رواتب','expense','#dc2626') RETURNING id
        """))).scalar_one()

    # Record monthly payroll as approved expense (idempotent by notes marker).
    marker = f"HR payroll month {month}"
    exists = (await db.execute(text("SELECT 1 FROM expenses WHERE notes=:n LIMIT 1"), {"n": marker})).scalar_one_or_none()
    if not exists and float(total) > 0:
        await db.execute(text("""
            INSERT INTO expenses (category_id, amount, description, date, status, created_by, notes)
            VALUES (:cid, :amt, :desc, :dt, 'approved', :by, :notes)
        """), {
            "cid": cat_id,
            "amt": float(total),
            "desc": f"رواتب شهر {month}",
            "dt": f"{month}-01",
            "by": current_user.id,
            "notes": marker,
        })

    await db.execute(text("""
        INSERT INTO hr_payroll_periods (month, status, approved_by, approved_at)
        VALUES (:m, 'approved', :by, now())
        ON CONFLICT (month) DO UPDATE SET status='approved', approved_by=:by, approved_at=now(), updated_at=now()
    """), {"m": month, "by": current_user.id})
    await db.execute(text("UPDATE hr_payroll SET status='approved' WHERE month=:m"), {"m": month})
    await db.commit()
    return {"detail": "approved", "total": float(total)}


@router.post("/payroll/period/pay")
async def pay_payroll_period(month: str, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_role("admin", "manager"))):
    status = (await db.execute(text("SELECT status FROM hr_payroll_periods WHERE month=:m"), {"m": month})).scalar_one_or_none() or "draft"
    if status != "approved":
        raise BusinessError("لا يمكن صرف الشهر إلا بعد الاعتماد")
    await db.execute(text("""
        UPDATE hr_payroll_periods SET status='paid', paid_by=:by, paid_at=now(), updated_at=now() WHERE month=:m
    """), {"m": month, "by": current_user.id})
    await db.execute(text("UPDATE hr_payroll SET status='paid' WHERE month=:m"), {"m": month})
    await db.commit()
    return {"detail": "paid"}


@router.post("/payroll/period/reopen")
async def reopen_payroll_period(month: str, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    status = (await db.execute(text("SELECT status FROM hr_payroll_periods WHERE month=:m"), {"m": month})).scalar_one_or_none()
    if status == "paid":
        raise BusinessError("لا يمكن إعادة فتح شهر تم صرفه")
    await db.execute(text("""
        INSERT INTO hr_payroll_periods (month, status) VALUES (:m, 'draft')
        ON CONFLICT (month) DO UPDATE SET status='draft', updated_at=now()
    """), {"m": month})
    await db.execute(text("UPDATE hr_payroll SET status='draft' WHERE month=:m"), {"m": month})
    await db.commit()
    return {"detail": "reopened"}


@router.get("/payroll/{payroll_id}/breakdown")
async def get_daily_breakdown(payroll_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    """Get daily attendance breakdown for a payroll record."""
    r = await db.execute(text("SELECT p.daily_breakdown, e.name FROM hr_payroll p JOIN hr_employees e ON p.employee_id=e.id WHERE p.id=:id"), {'id': payroll_id})
    row = r.fetchone()
    if not row:
        raise NotFoundError()
    return {'employee': row[1], 'breakdown': row[0]}


@router.put("/payroll/{payroll_id}")
async def update_payroll(payroll_id: uuid.UUID, data: PayrollUpdate, db: AsyncSession = Depends(get_db), _=Depends(require_perm("payroll"))):
    await db.execute(text("""
        UPDATE hr_payroll SET bonus=:bonus, deductions=:ded, drawer_variance=:var,
        net_salary=base_salary - (absent_days*(base_salary/26.0)) - advances + :bonus - :ded + :var,
        status=:status, notes=:notes WHERE id=:id
    """), {'id': payroll_id, 'bonus': data.bonus, 'ded': data.deductions,
           'var': data.drawer_variance, 'status': data.status, 'notes': data.notes or ''})
    await db.commit()
    return {"detail": "updated"}


# ── Advances ───────────────────────────────────────────────────────────────
@router.get("/advances")
async def list_advances(employee_id: Optional[str] = None, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    q = "SELECT a.*, e.name as emp_name FROM hr_advances a JOIN hr_employees e ON a.employee_id=e.id WHERE 1=1"
    params = {}
    if employee_id:
        q += " AND a.employee_id=:eid"
        params['eid'] = uuid.UUID(employee_id)
    q += " ORDER BY a.date DESC"
    r = await db.execute(text(q), params)
    cols = r.keys()
    return [dict(zip(cols, row)) for row in r.fetchall()]


@router.post("/advances")
async def add_advance(data: AdvanceCreate, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("payroll"))):
    record_type = data.record_type
    adv_date = data.date or date.today()
    await db.execute(text("""
        INSERT INTO hr_advances (employee_id, amount, date, note, created_by, record_type)
        VALUES (:eid, :amt, :dt, :note, :by, :rt)
    """), {'eid': data.employee_id, 'amt': data.amount,
           'dt': adv_date.isoformat(), 'note': data.note or '',
           'by': current_user.id, 'rt': record_type})
    await db.execute(text("""
        INSERT INTO hr_audit_log (action_type, entity_type, entity_id, performed_by, reason, details)
        VALUES ('create', 'advance', :eid, :by, :note, :det::jsonb)
    """), {'eid': str(data.employee_id), 'by': current_user.id,
           'note': data.note or '', 'det': f'{{"type":"{record_type}","amount":{data.amount}}}'})
    await db.commit()
    return {"detail": "saved"}


async def _report_auth(token: str | None = None, db: AsyncSession = Depends(get_db)):
    """Accept JWT as query param for browser-opened HTML reports."""
    if not token:
        from fastapi import HTTPException
        raise HTTPException(401, "Not authenticated")
    from app.core.security import decode_token
    from app.models.user import User
    import uuid
    payload = decode_token(token)
    result = await db.execute(select(User).where(User.id == uuid.UUID(payload["sub"])))
    user = result.scalar_one_or_none()
    if not user or not user.is_active:
        from fastapi import HTTPException
        raise HTTPException(401)
    return user

@router.get("/payroll/report/monthly")
async def payroll_monthly_report(month: str, db: AsyncSession = Depends(get_db), _=Depends(_report_auth)):
    """Generate HTML payroll report for all employees — matches Qt ReportGenerator.generate_payroll_report()"""
    import sys
    sys.path.insert(0, '/app')
    from report_generator import ReportGenerator
    from app.services.payroll_engine import calculate_payroll

    settings = {r[0]: r[1] for r in (await db.execute(text("SELECT key, value FROM hr_settings"))).fetchall()}
    shifts_map = {r[0]: {'id': r[0], 'name': r[1], 'start_time': r[2], 'end_time': r[3]}
                  for r in (await db.execute(text("SELECT id, name, start_time, end_time FROM hr_shifts"))).fetchall()}

    emps = (await db.execute(text("""
        SELECT id,emp_code,name,position,monthly_salary,shift_schedule,shift_id,hire_date,
               ignore_lateness,max_lateness_before_overtime_cancellation FROM hr_employees WHERE is_active=TRUE
    """))).fetchall()
    emp_cols = ['id','emp_code','name','position','monthly_salary','shift_schedule','shift_id','hire_date','ignore_lateness','max_lateness_before_overtime_cancellation']

    payrolls = []
    for emp_row in emps:
        emp = dict(zip(emp_cols, emp_row))
        att_rows = (await db.execute(text("""
            SELECT check_in,check_out,status,edited,edited_by,edit_reason,
                   excuse_no_late,excuse_no_early,excuse_allow_overtime,shift_override
            FROM hr_attendance WHERE employee_id=:eid AND TO_CHAR(work_date,'YYYY-MM')=:month
        """), {'eid': emp['id'], 'month': month})).fetchall()
        att_cols = ['check_in','check_out','status','edited','edited_by','edit_reason','excuse_no_late','excuse_no_early','excuse_allow_overtime','shift_override']
        attendances = [dict(zip(att_cols, r)) for r in att_rows]
        adv = float((await db.execute(text("SELECT COALESCE(SUM(amount),0) FROM hr_advances WHERE employee_id=:eid AND TO_CHAR(date,'YYYY-MM')=:month"), {'eid': emp['id'], 'month': month})).scalar() or 0)
        result = calculate_payroll(emp, attendances, settings, shifts_map, advance=adv, month=month)
        result['emp_id'] = str(emp.get('emp_code') or emp['id'])
        result['emp_name'] = emp['name']
        result['position'] = emp['position']
        result['base_salary'] = float(emp['monthly_salary'])
        result['month'] = month
        # Map field names to Qt format
        result['final_salary'] = result['net_salary']
        result['overtime_payment'] = result['overtime_pay']
        result['bonus_payment'] = result.get('bonus_payment', 0)
        result['deduction'] = result.get('deductions', 0)
        result['advance'] = result.get('advances', 0)
        # Qt ReportGenerator required fields
        days = 26
        result.get('total_hours', 0) / max(result.get('working_days', 1), 1)
        result['scheduled_month_hours'] = days * 12  # default 12h shift
        result['effective_days_in_month'] = days
        result['days_in_month'] = days
        result['shift_length'] = 12
        result['hourly_rate'] = result.get('hourly_rate', 0)
        result['actual_working_days'] = result.get('actual_working_days', result.get('working_days', 0))
        result['vacation_days'] = result.get('vacation_days', 0)
        result['normal_hours_worked'] = result.get('total_hours', 0) - result.get('overtime_hours', 0)
        result['lateness_deduction'] = result.get('lateness_deduction', 0)
        result['late_penalty_multiplier'] = 2.0
        result['early_leave_minutes'] = result.get('early_leave_minutes', 0)
        result['missing_scan_minutes'] = result.get('missing_scan_minutes', 0)
        result['penalty_hours'] = 0
        result['bonus_days'] = result.get('bonus_days', 0)
        result['base_pay_prorated'] = result['net_salary'] + result.get('advances', 0) + result.get('lateness_deduction', 0) - result.get('overtime_pay', 0)
        result['ignore_lateness'] = bool(emp.get('ignore_lateness', False))
        payrolls.append(result)

    html = ReportGenerator.generate_payroll_report(payrolls, month)
    from fastapi.responses import HTMLResponse
    return HTMLResponse(content=html)


@router.get("/payroll/report/employee/{emp_id}")
async def employee_report(emp_id: uuid.UUID, month: str, report_type: str = 'detailed',
                          db: AsyncSession = Depends(get_db), _=Depends(_report_auth)):
    """Generate individual employee HTML report — matches Qt generate_employee_report() and generate_payslip_ticket()"""
    import sys
    sys.path.insert(0, '/app')
    from report_generator import ReportGenerator
    from models import Employee, Attendance
    from app.services.payroll_engine import calculate_payroll

    settings = {r[0]: r[1] for r in (await db.execute(text("SELECT key, value FROM hr_settings"))).fetchall()}
    shifts_map = {r[0]: {'id': r[0], 'name': r[1], 'start_time': r[2], 'end_time': r[3]}
                  for r in (await db.execute(text("SELECT id, name, start_time, end_time FROM hr_shifts"))).fetchall()}

    emp_row = (await db.execute(text("""
        SELECT id,emp_code,name,position,monthly_salary,shift_schedule,shift_id,hire_date,
               ignore_lateness,max_lateness_before_overtime_cancellation FROM hr_employees WHERE id=:id
    """), {'id': emp_id})).fetchone()
    if not emp_row:
        raise NotFoundError()
    emp_cols = ['id','emp_code','name','position','monthly_salary','shift_schedule','shift_id','hire_date','ignore_lateness','max_lateness_before_overtime_cancellation']
    emp = dict(zip(emp_cols, emp_row))

    att_rows = (await db.execute(text("""
        SELECT work_date,check_in,check_out,status,edited,edited_by,edit_reason,
               excuse_no_late,excuse_no_early,excuse_allow_overtime,shift_override
        FROM hr_attendance WHERE employee_id=:eid AND TO_CHAR(work_date,'YYYY-MM')=:month
        ORDER BY work_date
    """), {'eid': emp_id, 'month': month})).fetchall()
    att_cols = ['work_date','check_in','check_out','status','edited','edited_by','edit_reason','excuse_no_late','excuse_no_early','excuse_allow_overtime','shift_override']
    attendances = [dict(zip(att_cols, r)) for r in att_rows]

    adv_rows = (await db.execute(text("SELECT amount, date, note FROM hr_advances WHERE employee_id=:eid AND TO_CHAR(date,'YYYY-MM')=:month"), {'eid': emp_id, 'month': month})).fetchall()
    adv_total = sum(float(r[0]) for r in adv_rows)
    finances = [{'type': 'سلفة', 'amount': float(r[0]), 'date': str(r[1]), 'note': r[2] or ''} for r in adv_rows]

    result = calculate_payroll(emp, attendances, settings, shifts_map, advance=adv_total, month=month)
    result['emp_name'] = emp['name']
    result['position'] = emp['position']
    result['base_salary'] = float(emp['monthly_salary'])
    result['month'] = month
    result['final_salary'] = result['net_salary']
    result['overtime_payment'] = result['overtime_pay']
    result['deduction'] = result.get('deductions', 0)
    result['advance'] = adv_total
    result['scheduled_month_hours'] = 26 * 12
    result['effective_days_in_month'] = 26
    result['days_in_month'] = 26
    result['shift_length'] = 12
    result['actual_working_days'] = result.get('actual_working_days', result.get('working_days', 0))
    result['vacation_days'] = result.get('vacation_days', 0)
    result['normal_hours_worked'] = result.get('total_hours', 0) - result.get('overtime_hours', 0)
    result['lateness_deduction'] = result.get('lateness_deduction', 0)
    result['late_penalty_multiplier'] = 2.0
    result['early_leave_minutes'] = result.get('early_leave_minutes', 0)
    result['missing_scan_minutes'] = result.get('missing_scan_minutes', 0)
    result['penalty_hours'] = 0
    result['bonus_days'] = result.get('bonus_days', 0)
    result['bonus_payment'] = result.get('bonus_payment', 0)
    result['base_pay_prorated'] = result['net_salary'] + adv_total + result.get('lateness_deduction', 0) - result.get('overtime_pay', 0)
    result['ignore_lateness'] = bool(emp.get('ignore_lateness', False))

    # Build Employee and Attendance objects for Qt ReportGenerator
    employee_obj = Employee(
        emp_id=str(emp['emp_code'] or emp['id']),
        name=emp['name'], position=emp['position'],
        monthly_salary=float(emp['monthly_salary']),
        shift=emp['shift_schedule'] or '',
        hire_date=str(emp['hire_date']) if emp['hire_date'] else None,
        ignore_lateness=bool(emp['ignore_lateness'])
    )
    att_objs = []
    for a in attendances:
        ci = a['check_in']
        co = a['check_out']
        wd = a.get('work_date')
        if ci and hasattr(ci, 'replace'):
            ci = ci.replace(tzinfo=None)
        elif wd:
            # No check_in recorded — use work_date at midnight so the day appears in report
            from datetime import datetime as _dt2, date as _d2
            ci = _dt2.combine(wd if isinstance(wd, _d2) else _d2.fromisoformat(str(wd)), _dt2.min.time())
        if co and hasattr(co, 'replace'):
            co = co.replace(tzinfo=None)
        att_objs.append(Attendance(
            str(emp['emp_code'] or emp['id']), ci, co,
            status=a.get('status','present') if a.get('status') != 'present' else 'regular',
            excuse_no_late=bool(a.get('excuse_no_late', False)),
            excuse_no_early=bool(a.get('excuse_no_early', False)),
            excuse_allow_overtime=bool(a.get('excuse_allow_overtime', False)),
            edited=bool(a.get('edited', False)),
            edit_reason=a.get('edit_reason', '')
        ))

    if report_type == 'ticket':
        html = ReportGenerator.generate_payslip_ticket(employee_obj, result, finances=finances)
    else:
        html = ReportGenerator.generate_employee_report(employee_obj, att_objs, result, finances=finances)

    from fastapi.responses import HTMLResponse
    return HTMLResponse(content=html)


@router.get("/attendance/report")
async def attendance_report(month: str, db: AsyncSession = Depends(get_db), _=Depends(_report_auth)):
    """Generate HTML attendance report — matches Qt generate_attendance_report()"""
    import sys
    sys.path.insert(0, '/app')
    from report_generator import ReportGenerator

    rows = (await db.execute(text("""
        SELECT e.name, e.emp_code, a.work_date, a.check_in, a.check_out, a.status,
               a.edited, a.edit_reason
        FROM hr_attendance a JOIN hr_employees e ON a.employee_id=e.id
        WHERE TO_CHAR(a.work_date,'YYYY-MM')=:month
        ORDER BY e.name, a.work_date
    """), {'month': month})).fetchall()

    report_rows = []
    for r in rows:
        ci = r[3]
        co = r[4]
        if ci and hasattr(ci, 'replace'):
            ci = ci.replace(tzinfo=None)
        if co and hasattr(co, 'replace'):
            co = co.replace(tzinfo=None)
        report_rows.append({
            'name': r[0], 'uid': r[1] or '', 'date': str(r[2]),
            'checkin': ci.isoformat() if ci else None,
            'checkout': co.isoformat() if co else None,
            'status': r[5] or 'present',
            'edited': bool(r[6]), 'edit_reason': r[7] or ''
        })

    html = ReportGenerator.generate_attendance_report(report_rows, month)
    from fastapi.responses import HTMLResponse
    return HTMLResponse(content=html)


# ── ZK Device Sync ────────────────────────────────────────────────────────────

@router.get("/sync-log")
async def get_sync_log(db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    rows = (await db.execute(text(
        "SELECT id, synced_at, status, fetched, added, updated, message FROM hr_sync_log ORDER BY synced_at DESC LIMIT 50"
    ))).fetchall()
    return [{"id": str(r[0]), "synced_at": r[1], "status": r[2], "fetched": r[3],
             "added": r[4], "updated": r[5], "message": r[6]} for r in rows]


@router.post("/attendance/from-device")
async def attendance_from_device(data: dict, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    """Accept a single attendance record from the host-side zk_sync.py script."""
    uid = str(data.get('emp_id', ''))
    from datetime import date as _date, datetime as _dt
    check_in_raw = data.get('check_in')
    check_out_raw = data.get('check_out')
    date_str = str(check_in_raw or '')[:10]
    try:
        work_date = _date.fromisoformat(date_str)
    except ValueError:
        return {"action": "skipped", "reason": f"invalid date {date_str}"}
    check_in = _dt.fromisoformat(check_in_raw).replace(tzinfo=None) if check_in_raw else None
    check_out = _dt.fromisoformat(check_out_raw).replace(tzinfo=None) if check_out_raw else None

    emp = (await db.execute(text(
        "SELECT id FROM hr_employees WHERE emp_code=:uid"
    ), {"uid": uid})).fetchone()
    if not emp:
        return {"action": "skipped", "reason": f"unknown uid {uid}"}

    existing = (await db.execute(text(
        "SELECT id, edited FROM hr_attendance WHERE employee_id=:e AND work_date=:d"
    ), {"e": emp[0], "d": work_date})).fetchone()

    if existing:
        if existing[1]:  # manually edited — preserve
            return {"action": "skipped", "reason": "manually edited"}
        await db.execute(text(
            "UPDATE hr_attendance SET check_in=:ci, check_out=:co WHERE id=:id"
        ), {"ci": check_in, "co": check_out, "id": existing[0]})
        await db.commit()
        return {"action": "updated"}
    else:
        await db.execute(text(
            "INSERT INTO hr_attendance (employee_id, work_date, check_in, check_out, status) VALUES (:e,:d,:ci,:co,'present')"
        ), {"e": emp[0], "d": work_date, "ci": check_in, "co": check_out})
        await db.commit()
        return {"action": "added"}


@router.post("/sync-device")
async def sync_device(db: AsyncSession = Depends(get_db), current_user: User = Depends(require_role("admin"))):
    """Trigger sync from ZK device — only works if backend can reach the device directly."""
    settings = {r[0]: r[1] for r in (await db.execute(text("SELECT key, value FROM hr_settings"))).fetchall()}
    host = settings.get("device_host")
    port = int(settings.get("device_port", 4370))
    timeout = int(settings.get("device_timeout", 5))
    if not host:
        raise HTTPException(400, "ZK device host not configured — set device_host in hr_settings")

    try:
        from zk import ZK
    except ImportError:
        raise HTTPException(500, "pyzk not installed")

    try:
        zk = ZK(host, port=port, timeout=timeout, force_udp=False, ommit_ping=False)
        conn = zk.connect()
        conn.disable_device()
        punches = conn.get_attendance()
        conn.enable_device()
        conn.disconnect()
    except Exception as e:
        await db.execute(text(
            "INSERT INTO hr_sync_log (status, message) VALUES ('failure', :m)"
        ), {"m": str(e)})
        await db.commit()
        raise HTTPException(502, f"Device connection failed: {e}")

    from collections import defaultdict
    from datetime import timezone
    groups: dict = defaultdict(list)
    for p in punches:
        dt = p.timestamp
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        groups[(str(p.user_id), dt.date())].append(dt)

    emp_rows = (await db.execute(text("SELECT id, emp_code FROM hr_employees WHERE emp_code IS NOT NULL"))).fetchall()
    code_map = {r[1]: r[0] for r in emp_rows}

    added = updated = 0
    for (uid, work_date), times in groups.items():
        emp_id = code_map.get(uid)
        if not emp_id:
            continue
        times.sort()
        check_in = times[0]
        check_out = times[-1] if len(times) > 1 else None

        existing = (await db.execute(text(
            "SELECT id, edited FROM hr_attendance WHERE employee_id=:e AND work_date=:d"
        ), {"e": emp_id, "d": work_date})).fetchone()

        if existing:
            if existing[1]:
                continue
            await db.execute(text(
                "UPDATE hr_attendance SET check_in=:ci, check_out=:co WHERE id=:id"
            ), {"ci": check_in, "co": check_out, "id": existing[0]})
            updated += 1
        else:
            await db.execute(text(
                "INSERT INTO hr_attendance (employee_id, work_date, check_in, check_out, status) VALUES (:e,:d,:ci,:co,'present')"
            ), {"e": emp_id, "d": work_date, "ci": check_in, "co": check_out})
            added += 1

    await db.execute(text(
        "INSERT INTO hr_sync_log (status, fetched, added, updated) VALUES ('success',:f,:a,:u)"
    ), {"f": len(punches), "a": added, "u": updated})
    await db.commit()
    return {"fetched": len(punches), "added": added, "updated": updated}
