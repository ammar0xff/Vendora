"""HR / Payroll router"""
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from datetime import date
from decimal import Decimal
from typing import Optional
from pydantic import BaseModel
from app.db.base import get_db
from app.dependencies import get_current_user, require_role
from app.models.user import User
from app.core.exceptions import NotFoundError
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
    return [dict(zip(cols, row)) for row in r.fetchall()]


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
async def create_employee(data: dict, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    r = await db.execute(text("""
        INSERT INTO hr_employees (emp_code, name, position, monthly_salary, shift_schedule, hire_date)
        VALUES (:code, :name, :pos, :sal, :shift, :hire) RETURNING *
    """), {'code': data.get('emp_code'), 'name': data['name'], 'pos': data.get('position',''),
           'sal': data.get('monthly_salary', 0), 'shift': data.get('shift_schedule',''),
           'hire': data.get('hire_date')})
    await db.commit()
    row = r.fetchone()
    return dict(zip(r.keys(), row))


@router.put("/employees/{emp_id}")
async def update_employee(emp_id: uuid.UUID, data: dict, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    await db.execute(text("""
        UPDATE hr_employees SET name=:name, position=:pos, monthly_salary=:sal,
        shift_schedule=:shift, hire_date=:hire WHERE id=:id
    """), {'id': emp_id, 'name': data['name'], 'pos': data.get('position',''),
           'sal': data.get('monthly_salary',0), 'shift': data.get('shift_schedule',''),
           'hire': data.get('hire_date')})
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
        q += " AND a.employee_id=:eid"; params['eid'] = uuid.UUID(employee_id)
    if month:
        q += " AND TO_CHAR(a.work_date,'YYYY-MM')=:month"; params['month'] = month
    q += " ORDER BY a.work_date DESC"
    r = await db.execute(text(q), params)
    cols = r.keys()
    return [dict(zip(cols, row)) for row in r.fetchall()]


@router.post("/attendance")
async def add_attendance(data: dict, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    await db.execute(text("""
        INSERT INTO hr_attendance (employee_id, work_date, check_in, check_out, status, notes)
        VALUES (:eid, :dt, :ci, :co, :st, :notes)
        ON CONFLICT (employee_id, work_date) DO UPDATE
        SET check_in=EXCLUDED.check_in, check_out=EXCLUDED.check_out,
            status=EXCLUDED.status, notes=EXCLUDED.notes
    """), {'eid': uuid.UUID(data['employee_id']), 'dt': data['work_date'],
           'ci': data.get('check_in'), 'co': data.get('check_out'),
           'st': data.get('status','present'), 'notes': data.get('notes','')})
    await db.commit()
    return {"detail": "saved"}


# ── Payroll ────────────────────────────────────────────────────────────────
@router.get("/payroll")
async def list_payroll(month: Optional[str] = None, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    q = "SELECT p.*, e.name as emp_name, e.position FROM hr_payroll p JOIN hr_employees e ON p.employee_id=e.id WHERE 1=1"
    params = {}
    if month:
        q += " AND p.month=:month"; params['month'] = month
    q += " ORDER BY e.name"
    r = await db.execute(text(q), params)
    cols = r.keys()
    return [dict(zip(cols, row)) for row in r.fetchall()]


@router.post("/payroll/calculate")
async def calculate_payroll(data: dict, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_role("admin"))):
    """Calculate payroll for all (or one) employee using the full engine."""
    from app.services.payroll_engine import calculate_payroll as calc
    import json as _json

    month = data['month']  # YYYY-MM

    # Load settings
    settings_rows = (await db.execute(text("SELECT key, value FROM hr_settings"))).fetchall()
    settings = {r[0]: r[1] for r in settings_rows}

    # Load shifts
    shifts_rows = (await db.execute(text("SELECT id, name, start_time, end_time FROM hr_shifts"))).fetchall()
    shifts_map = {r[0]: {'id': r[0], 'name': r[1], 'start_time': r[2], 'end_time': r[3]} for r in shifts_rows}

    # Load employees
    emp_q = "SELECT id, emp_code, name, position, monthly_salary, shift_schedule, shift_id, hire_date, ignore_lateness, max_lateness_before_overtime_cancellation FROM hr_employees WHERE is_active=TRUE"
    if data.get('emp_code'):
        emp_q += f" AND emp_code=:ec"
        emps = (await db.execute(text(emp_q), {'ec': data['emp_code']})).fetchall()
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


@router.get("/payroll/{payroll_id}/breakdown")
async def get_daily_breakdown(payroll_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    """Get daily attendance breakdown for a payroll record."""
    r = await db.execute(text("SELECT p.daily_breakdown, e.name FROM hr_payroll p JOIN hr_employees e ON p.employee_id=e.id WHERE p.id=:id"), {'id': payroll_id})
    row = r.fetchone()
    if not row: raise NotFoundError()
    return {'employee': row[1], 'breakdown': row[0]}


@router.put("/payroll/{payroll_id}")
async def update_payroll(payroll_id: uuid.UUID, data: dict, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    await db.execute(text("""
        UPDATE hr_payroll SET bonus=:bonus, deductions=:ded, drawer_variance=:var,
        net_salary=base_salary - (absent_days*(base_salary/26.0)) - advances + :bonus - :ded + :var,
        status=:status, notes=:notes WHERE id=:id
    """), {'id': payroll_id, 'bonus': data.get('bonus',0), 'ded': data.get('deductions',0),
           'var': data.get('drawer_variance',0), 'status': data.get('status','draft'), 'notes': data.get('notes','')})
    await db.commit()
    return {"detail": "updated"}


# ── Advances ───────────────────────────────────────────────────────────────
@router.get("/advances")
async def list_advances(employee_id: Optional[str] = None, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    q = "SELECT a.*, e.name as emp_name FROM hr_advances a JOIN hr_employees e ON a.employee_id=e.id WHERE 1=1"
    params = {}
    if employee_id:
        q += " AND a.employee_id=:eid"; params['eid'] = uuid.UUID(employee_id)
    q += " ORDER BY a.date DESC"
    r = await db.execute(text(q), params)
    cols = r.keys()
    return [dict(zip(cols, row)) for row in r.fetchall()]


@router.post("/advances")
async def add_advance(data: dict, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    record_type = data.get('record_type', 'سلفة')  # سلفة | مكافأة | خصم
    await db.execute(text("""
        INSERT INTO hr_advances (employee_id, amount, date, note, created_by, record_type)
        VALUES (:eid, :amt, :dt, :note, :by, :rt)
    """), {'eid': uuid.UUID(data['employee_id']), 'amt': data['amount'],
           'dt': data.get('date', date.today().isoformat()), 'note': data.get('note',''),
           'by': current_user.id, 'rt': record_type})
    # Audit log
    await db.execute(text("""
        INSERT INTO hr_audit_log (action_type, entity_type, entity_id, performed_by, reason, details)
        VALUES ('create', 'advance', :eid, :by, :note, :det::jsonb)
    """), {'eid': str(data['employee_id']), 'by': current_user.id,
           'note': data.get('note',''), 'det': f'{{"type":"{record_type}","amount":{data["amount"]}}}'})
    await db.commit()
    return {"detail": "saved"}


async def _report_auth(token: str | None = None, db: AsyncSession = Depends(get_db)):
    """Accept JWT as query param for browser-opened HTML reports."""
    if not token:
        from fastapi import HTTPException
        raise HTTPException(401, "Not authenticated")
    from app.core.security import decode_token
    from sqlalchemy import select
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
    import sys, os
    sys.path.insert(0, '/home/ammar/Desktop/AMMAR/موظفين')
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
        shift_len = result.get('total_hours', 0) / max(result.get('working_days', 1), 1)
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
    sys.path.insert(0, '/home/ammar/Desktop/AMMAR/موظفين')
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
    if not emp_row: raise NotFoundError()
    emp_cols = ['id','emp_code','name','position','monthly_salary','shift_schedule','shift_id','hire_date','ignore_lateness','max_lateness_before_overtime_cancellation']
    emp = dict(zip(emp_cols, emp_row))

    att_rows = (await db.execute(text("""
        SELECT check_in,check_out,status,edited,edited_by,edit_reason,
               excuse_no_late,excuse_no_early,excuse_allow_overtime,shift_override
        FROM hr_attendance WHERE employee_id=:eid AND TO_CHAR(work_date,'YYYY-MM')=:month
    """), {'eid': emp_id, 'month': month})).fetchall()
    att_cols = ['check_in','check_out','status','edited','edited_by','edit_reason','excuse_no_late','excuse_no_early','excuse_allow_overtime','shift_override']
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
    from datetime import datetime as _dt
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
        if ci and hasattr(ci, 'replace'): ci = ci.replace(tzinfo=None)
        if co and hasattr(co, 'replace'): co = co.replace(tzinfo=None)
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
    sys.path.insert(0, '/home/ammar/Desktop/AMMAR/موظفين')
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
        if ci and hasattr(ci, 'replace'): ci = ci.replace(tzinfo=None)
        if co and hasattr(co, 'replace'): co = co.replace(tzinfo=None)
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
