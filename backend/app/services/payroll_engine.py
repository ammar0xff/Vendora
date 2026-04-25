"""
payroll_engine.py — Full payroll calculation matching the Qt موظفين system.
Logic ported directly from models.py PayrollCalculator.calculate_payroll()
"""
from datetime import datetime, timedelta, date, timezone
from typing import List, Dict, Optional
from collections import defaultdict
import calendar

# Egypt timezone offset
LOCAL_TZ_OFFSET = timedelta(hours=2)

def to_local(dt):
    """Return naive local datetime. DB stores Cairo time as UTC-marked — strip timezone only."""
    if dt is None:
        return None
    if hasattr(dt, 'tzinfo') and dt.tzinfo is not None:
        # Strip timezone — times are already in local Cairo time stored with UTC marker
        return dt.replace(tzinfo=None)
    return dt


def parse_shift(shift_str: str, shifts_map: dict = None) -> tuple:
    """Parse shift string → (start_hour, end_hour).
    Handles: '11:00-23:00', '9-21', '11 صباحاً الى 11 مساءً', shift name/id lookup.
    """
    if not shift_str:
        return 9, 21  # default 9am-9pm

    # Try direct HH:MM-HH:MM or H-H
    try:
        parts = shift_str.replace('–', '-').replace('—', '-').split('-')
        if len(parts) == 2:
            s = int(parts[0].strip().split(':')[0])
            e = int(parts[1].strip().split(':')[0])
            return s, e
    except Exception:
        pass

    # Try Arabic format: "9 صباحا الى 9 مساءً" or "11 صباحاً الى 11 مساءً"
    import re
    nums = re.findall(r'\d+', shift_str)
    if len(nums) >= 2:
        s, e = int(nums[0]), int(nums[1])
        # Detect AM/PM from Arabic keywords
        lower = shift_str.lower()
        parts_ar = shift_str.split('الى') if 'الى' in shift_str else shift_str.split('إلى')
        if len(parts_ar) == 2:
            start_part, end_part = parts_ar[0], parts_ar[1]
            # Start hour
            if 'مساء' in start_part or 'pm' in start_part.lower():
                if s < 12: s += 12
            elif 'صباح' in start_part or 'am' in start_part.lower():
                if s == 12: s = 0
            # End hour
            if 'مساء' in end_part or 'pm' in end_part.lower():
                if e < 12: e += 12
            elif 'صباح' in end_part or 'am' in end_part.lower():
                if e == 12: e = 0
        return s, e

    # Try resolving by name or id from shifts_map
    if shifts_map:
        for s_obj in shifts_map.values():
            if s_obj.get('name') == shift_str or str(s_obj.get('id')) == str(shift_str):
                try:
                    return int(s_obj['start_time'].split(':')[0]), int(s_obj['end_time'].split(':')[0])
                except Exception:
                    pass

    return 9, 21  # fallback


def attendance_day(dt: datetime) -> Optional[date]:
    """5am rollover: timestamps before 5am belong to previous day."""
    if not dt:
        return None
    if dt.hour < 5:
        return (dt - timedelta(days=1)).date()
    return dt.date()


def calculate_payroll(employee: dict, attendances: List[dict], settings: dict,
                      shifts_map: dict, bonus: float = 0, deduction: float = 0,
                      advance: float = 0, month: str = None) -> dict:
    """
    Full payroll calculation.
    employee: dict with name, monthly_salary, shift_schedule, ignore_lateness, max_lateness_before_overtime_cancellation
    attendances: list of dicts with check_in, check_out, status, excuse_*, shift_override, edited
    settings: dict from hr_settings table
    shifts_map: {id: {name, start_time, end_time}}
    month: 'YYYY-MM' string
    """
    monthly_salary = float(employee.get('monthly_salary', 0))
    # days_in_month from settings, default 26
    days_in_month = int(float(settings.get('days_in_month', 26)))
    emp_shift = employee.get('shift_schedule', '') or ''
    ignore_lateness = bool(employee.get('ignore_lateness', False))
    max_late_for_ot = int(employee.get('max_lateness_before_overtime_cancellation', 30))

    grace_period = int(float(settings.get('grace_period_minutes', 10)))
    multiplier = float(settings.get('late_penalty_multiplier', 2.0))
    missing_penalty_hours = float(settings.get('missing_checkout_penalty_hours', 2.0))
    apply_missing_penalty = settings.get('apply_missing_checkout_penalty', 'True') == 'True'
    overtime_enabled = settings.get('overtime_enabled', 'True') == 'True'
    weekend_paid = settings.get('weekend_paid', 'True') == 'True'

    start_h, end_h = parse_shift(emp_shift, shifts_map)
    shift_length = (end_h - start_h) if end_h > start_h else (24 - start_h + end_h)

    # Determine month range
    if month:
        year, mon = int(month.split('-')[0]), int(month.split('-')[1])
        month_start = date(year, mon, 1)
        _, last_day = calendar.monthrange(year, mon)
        month_end = date(year, mon, last_day)
    else:
        now = datetime.now()
        month_start = now.date().replace(day=1)
        _, last_day = calendar.monthrange(now.year, now.month)
        month_end = now.date().replace(day=last_day)

    now = datetime.now()
    end_date_for_loop = month_end if month_end < now.date() else now.date()

    # Group attendances by logical day
    grouped: dict = defaultdict(list)
    for att in attendances:
        ci = att.get('check_in')
        co = att.get('check_out')
        ref_ts = None
        if ci:
            ref_ts = to_local(ci if isinstance(ci, datetime) else datetime.fromisoformat(str(ci)))
        elif co:
            ref_ts = to_local(co if isinstance(co, datetime) else datetime.fromisoformat(str(co)))
        if ref_ts:
            day = attendance_day(ref_ts)
            if day:
                grouped[day].append(att)

    scheduled_hours = days_in_month * shift_length if shift_length > 0 else 0
    hourly_rate = (monthly_salary / scheduled_hours) if scheduled_hours > 0 else 0

    total_hours = 0.0
    total_late_min = 0
    total_early_min = 0
    total_missing_min = 0
    s_len = shift_length  # default — overridden per-day inside loop
    working_days = 0
    actual_working_days = 0
    vacation_days = 0
    leave_days_count = 0
    daily_breakdown = []

    hire_date = None
    if employee.get('hire_date'):
        try:
            hd = employee['hire_date']
            hire_date = hd if isinstance(hd, date) else date.fromisoformat(str(hd))
        except Exception:
            pass

    current_day = month_start
    while current_day <= end_date_for_loop:
        # Pre-hire
        if hire_date and current_day < hire_date:
            daily_breakdown.append({'date': current_day.isoformat(), 'status': 'pre-hire', 'note': 'قبل تاريخ التعيين',
                                     'work_hours': 0, 'late_minutes': 0, 'overtime_hours': 0})
            current_day += timedelta(days=1)
            continue

        day_items = grouped.get(current_day, [])

        if not day_items:
            # Weekend (Friday = weekday 4)
            if current_day.weekday() == 4 and weekend_paid:
                daily_breakdown.append({'date': current_day.isoformat(), 'status': 'weekend', 'note': 'عطلة أسبوعية',
                                         'work_hours': 0, 'late_minutes': 0, 'overtime_hours': 0})
                current_day += timedelta(days=1)
                continue
            # Absent
            note = 'لم يتم تسجيل حضور اليوم' if current_day == now.date() else 'غياب'
            daily_breakdown.append({'date': current_day.isoformat(), 'status': 'absent', 'note': note,
                                     'work_hours': 0, 'late_minutes': 0, 'overtime_hours': 0})
            current_day += timedelta(days=1)
            continue

        primary = day_items[0]
        status = primary.get('status', 'present')
        if status == 'regular': status = 'present'
        excuse_no_late = bool(primary.get('excuse_no_late', False))
        excuse_no_early = bool(primary.get('excuse_no_early', False))
        excuse_allow_ot = bool(primary.get('excuse_allow_overtime', False))
        shift_override = primary.get('shift_override')
        is_edited = any(a.get('edited', False) for a in day_items)
        edit_reason = next((a.get('edit_reason', '') for a in day_items if a.get('edit_reason')), '')

        eff_shift = shift_override if shift_override else emp_shift
        s_h, e_h = parse_shift(eff_shift, shifts_map)
        s_len = (e_h - s_h) if e_h > s_h else (24 - s_h + e_h)

        # Collect all timestamps
        all_ts = []
        for item in day_items:
            for k in ('check_in', 'check_out'):
                v = item.get(k)
                if v:
                    all_ts.append(to_local(v if isinstance(v, datetime) else datetime.fromisoformat(str(v))))
        all_ts = sorted(set(all_ts))
        eff_in = all_ts[0] if all_ts else None
        eff_out = all_ts[-1] if len(all_ts) > 1 else None

        work_hours = 0.0
        late_mins = 0
        early_mins = 0
        missing_mins = 0
        daily_ot = 0.0
        note_parts = []
        if edit_reason: note_parts.append(f'[{edit_reason}]')
        if shift_override: note_parts.append(f'شيفت مؤقت: {shift_override}')

        if status == 'leave':
            if leave_days_count < 4:
                work_hours = s_len
                leave_days_count += 1
                note_parts.append('إجازة مدفوعة')
            else:
                note_parts.append('إجازة (تجاوز الحد 4 أيام)')
        elif status == 'mission':
            work_hours = s_len
            note_parts.append('مأمورية عمل')
        else:
            # Handle missing check-in
            if not eff_in and eff_out and not is_edited:
                shift_start = eff_out.replace(hour=s_h, minute=0, second=0, microsecond=0)
                if s_h > e_h and shift_start > eff_out:
                    shift_start -= timedelta(days=1)
                eff_in = shift_start
                missing_mins += int(missing_penalty_hours * 60)
                note_parts.append(f'افتراض دخول وخصم {missing_penalty_hours:.0f} ساعة')

            # Lateness
            if eff_in and status not in ('leave', 'mission'):
                shift_start_t = eff_in.replace(hour=s_h, minute=0, second=0, microsecond=0)
                if eff_in > shift_start_t:
                    raw_late = int((eff_in - shift_start_t).total_seconds() / 60)
                    if not ignore_lateness:
                        late_mins = 0 if raw_late <= grace_period else raw_late
                    if status == 'excuse' and excuse_no_late:
                        late_mins = 0
                        note_parts.append('عذر (إلغاء التأخير)')
                    elif status == 'excuse':
                        note_parts.append('عذر')

            # Handle missing check-out
            if not eff_out and eff_in and not is_edited and status not in ('leave', 'mission'):
                shift_end_t = eff_in.replace(hour=e_h, minute=0, second=0, microsecond=0)
                if e_h <= s_h: shift_end_t += timedelta(days=1)
                if current_day == now.date() and now < (shift_end_t + timedelta(hours=2)):
                    note_parts.append('قيد العمل')
                else:
                    if apply_missing_penalty:
                        eff_out = shift_end_t - timedelta(hours=missing_penalty_hours)
                        missing_mins += int(missing_penalty_hours * 60)
                        note_parts.append(f'افتراض خروج مبكر {missing_penalty_hours:.0f} ساعة')
                    else:
                        eff_out = shift_end_t  # assume full shift, no penalty
                        note_parts.append('لم يسجل خروج')

            if eff_in and eff_out:
                work_hours = (eff_out - eff_in).total_seconds() / 3600
                # Early leave
                shift_end_t = eff_in.replace(hour=e_h, minute=0, second=0, microsecond=0)
                if e_h <= s_h: shift_end_t += timedelta(days=1)
                if eff_out < shift_end_t:
                    gross_early = int((shift_end_t - eff_out).total_seconds() / 60)
                    penalty_from_co = int(missing_penalty_hours * 60) if 'افتراض خروج' in ' '.join(note_parts) else 0
                    early_mins = max(0, gross_early - penalty_from_co)
                    if status == 'excuse' and excuse_no_early:
                        early_mins = 0
                        note_parts.append('عذر (إلغاء الانصراف المبكر)')
                # Overtime
                if overtime_enabled:
                    daily_ot = max(0.0, work_hours - s_len)
                    if late_mins > max_late_for_ot:
                        if not (status == 'excuse' and excuse_allow_ot):
                            daily_ot = 0.0
                            note_parts.append('إلغاء الإضافي')

        if work_hours > 0:
            working_days += 1
            if status == 'leave':
                vacation_days += 1
            else:
                actual_working_days += 1

        total_hours += work_hours
        total_late_min += late_mins
        total_early_min += early_mins
        total_missing_min += missing_mins

        daily_breakdown.append({
            'date': current_day.isoformat(),
            'check_in': eff_in.isoformat() if eff_in else None,
            'check_out': eff_out.isoformat() if eff_out else None,
            'work_hours': round(work_hours, 2),
            'late_minutes': late_mins,
            'early_minutes': early_mins,
            'overtime_hours': round(daily_ot, 2),
            'status': status,
            'note': ' / '.join(note_parts) if note_parts else '',
        })
        current_day += timedelta(days=1)

    # Final calculations
    overtime_hours = sum(d.get('overtime_hours', 0) for d in daily_breakdown)
    doubled = (total_late_min / 60) * multiplier
    single = (total_early_min / 60) + (total_missing_min / 60)
    lateness_deduction = (doubled + single) * hourly_rate if hourly_rate > 0 else 0
    overtime_payment = overtime_hours * hourly_rate if hourly_rate > 0 else 0
    bonus_days = max(0, working_days - days_in_month)
    bonus_payment = bonus_days * s_len * hourly_rate if hourly_rate > 0 else 0
    normal_hours = max(0.0, total_hours - overtime_hours)
    base_pay = monthly_salary if normal_hours >= scheduled_hours else (monthly_salary * normal_hours / scheduled_hours if scheduled_hours > 0 else 0)
    final_salary = base_pay - lateness_deduction - deduction - advance + overtime_payment + bonus_payment + bonus

    return {
        'base_salary': monthly_salary,
        'hourly_rate': round(hourly_rate, 4),
        'working_days': working_days,
        'actual_working_days': actual_working_days,
        'vacation_days': vacation_days,
        'absent_days': max(0, days_in_month - working_days),
        'total_hours': round(total_hours, 2),
        'lateness_minutes': total_late_min,
        'early_leave_minutes': total_early_min,
        'missing_scan_minutes': total_missing_min,
        'lateness_deduction': round(lateness_deduction, 2),
        'overtime_hours': round(overtime_hours, 2),
        'overtime_pay': round(overtime_payment, 2),
        'bonus_days': bonus_days,
        'bonus_payment': round(bonus_payment, 2),
        'bonus': bonus,
        'deductions': deduction,
        'advances': advance,
        'net_salary': round(max(0, final_salary), 2),
        'daily_breakdown': daily_breakdown,
    }
