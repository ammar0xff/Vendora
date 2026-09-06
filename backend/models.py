import json
import os
from collections import defaultdict
from datetime import datetime, timedelta

SETTINGS = {}
def load_app_settings():
    global SETTINGS
    try:
        settings_path = os.path.join(os.path.dirname(__file__), 'settings.json')
        if os.path.exists(settings_path):
            with open(settings_path, encoding="utf-8") as f:
                SETTINGS = json.load(f)
    except Exception:
        pass
load_app_settings()

class Employee:
    def __init__(self, emp_id: str, name: str, position: str, monthly_salary: float, shift: str,
                 max_lateness_before_overtime_cancellation: int = 30, hire_date: str = None,
                 ignore_lateness: bool = False):
        self.emp_id = emp_id
        self.name = name
        self.position = position
        self.monthly_salary = monthly_salary
        self.shift = shift  # e.g., "8:00-16:00" or "9:00-17:00"
        self.max_lateness_before_overtime_cancellation = max_lateness_before_overtime_cancellation
        self.hire_date = hire_date # YYYY-MM-DD
        self.ignore_lateness = ignore_lateness

    def to_dict(self):
        return {
            "emp_id": self.emp_id,
            "name": self.name,
            "position": self.position,
            "monthly_salary": self.monthly_salary,
            "shift": self.shift,
            "max_lateness_before_overtime_cancellation": self.max_lateness_before_overtime_cancellation,
            "hire_date": self.hire_date,
            "ignore_lateness": self.ignore_lateness
        }

    @staticmethod
    def from_dict(data):
        # Be tolerant of older or partial records that may miss fields
        emp_id = data.get("emp_id")
        name = data.get("name", "")
        position = data.get("position", "")
        monthly_salary = data.get("monthly_salary", 0.0) if data.get("monthly_salary") is not None else 0.0
        shift = data.get("shift", "")
        max_lateness_before_overtime_cancellation = data.get("max_lateness_before_overtime_cancellation", 30)
        hire_date = data.get("hire_date")
        ignore_lateness = data.get("ignore_lateness", False)
        return Employee(emp_id, name, position, monthly_salary, shift, max_lateness_before_overtime_cancellation, hire_date, ignore_lateness)


def attendance_day(dt: datetime, shift_start_hour: int = 9):
    """Map a timestamp to the logical attendance day.
    Rollover at 5 AM: Times from 00:00 to 04:59 belong to the previous day.
    """
    if not dt:
        return None
    try:
        # Fixed 5 AM rollover is safer for both day and night shifts
        if dt.hour < 5:
            return (dt - timedelta(days=1)).date()
        return dt.date()
    except Exception:
        return dt.date() if hasattr(dt, 'date') else None


class Attendance:
    def __init__(self, emp_id: str, check_in: datetime = None, check_out: datetime = None,
                 edited=False, edited_at=None, edited_by=None, edit_reason=None,
                 status="regular", excuse_no_late=False, excuse_no_early=False, excuse_allow_overtime=False,
                 shift_override=None):
        self.emp_id = emp_id
        self.check_in = check_in
        self.check_out = check_out
        # Manual edit metadata
        self.edited = edited
        self.edited_at = edited_at
        self.edited_by = edited_by
        self.edit_reason = edit_reason
        # Special statuses: regular, leave, mission, excuse
        self.status = status
        # Excuse options
        self.excuse_no_late = excuse_no_late  # Cancel late arrival penalty
        self.excuse_no_early = excuse_no_early  # Cancel early leave penalty
        self.excuse_allow_overtime = excuse_allow_overtime  # Allow overtime on excuse days
        self.shift_override = shift_override  # Temporary shift for this day (e.g., "09:00-17:00")

    def to_dict(self):
        return {
            "emp_id": self.emp_id,
            "check_in": self.check_in.isoformat() if self.check_in else None,
            "check_out": self.check_out.isoformat() if self.check_out else None,
            "edited": bool(self.edited),
            "edited_at": self.edited_at,
            "edited_by": self.edited_by,
            "edit_reason": self.edit_reason,
            "status": self.status,
            "excuse_no_late": self.excuse_no_late,
            "excuse_no_early": getattr(self, 'excuse_no_early', False),
            "excuse_allow_overtime": getattr(self, 'excuse_allow_overtime', False),
            "shift_override": getattr(self, 'shift_override', None)
        }

    @staticmethod
    def from_dict(data):
        check_in = datetime.fromisoformat(data["check_in"]) if data["check_in"] else None
        check_out = datetime.fromisoformat(data["check_out"]) if data["check_out"] else None
        return Attendance(
            data["emp_id"], check_in, check_out,
            edited=data.get('edited', False),
            edited_at=data.get('edited_at'),
            edited_by=data.get('edited_by'),
            edit_reason=data.get('edit_reason'),
            status=data.get('status', 'regular'),
            excuse_no_late=data.get('excuse_no_late', False),
            excuse_no_early=data.get('excuse_no_early', False),
            excuse_allow_overtime=data.get('excuse_allow_overtime', False),
            shift_override=data.get('shift_override')
        )


class Database:
    def __init__(self):
        self.employees_file = "data/employees.json"
        self.attendance_file = "data/attendance.json"
        self.payroll_file = "data/payroll.json"
        self.shifts_file = "data/shifts.json"
        self._ensure_data_directory()

    def _ensure_data_directory(self):
        os.makedirs("data", exist_ok=True)

    def _load_json(self, filepath):
        if os.path.exists(filepath):
            with open(filepath, encoding='utf-8') as f:
                return json.load(f)
        return []

    def _save_json(self, filepath, data):
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

    # Employee Management
    def add_employee(self, employee: Employee):
        employees = self._load_json(self.employees_file)
        emp_dict = employee.to_dict()

        # Check if employee already exists
        for i, emp in enumerate(employees):
            if emp["emp_id"] == employee.emp_id:
                employees[i] = emp_dict
                self._save_json(self.employees_file, employees)
                return

        employees.append(emp_dict)
        self._save_json(self.employees_file, employees)

    def get_employee(self, emp_id: str) -> Employee | None:
        employees = self._load_json(self.employees_file)
        for emp in employees:
            if emp["emp_id"] == emp_id:
                return Employee.from_dict(emp)
        return None

    def get_all_employees(self) -> list[Employee]:
        employees = self._load_json(self.employees_file)
        return [Employee.from_dict(emp) for emp in employees]

    def delete_employee(self, emp_id: str):
        employees = self._load_json(self.employees_file)
        employees = [emp for emp in employees if emp["emp_id"] != emp_id]
        self._save_json(self.employees_file, employees)

    # Attendance Management
    def add_attendance(self, attendance: Attendance):
        attendances = self._load_json(self.attendance_file)

        def same_day(a_dict, b_att: Attendance):
            try:
                # parse stored record timestamp and map to attendance-day
                a_ts = None
                if a_dict.get('check_in'):
                    try:
                        a_ts = datetime.fromisoformat(a_dict.get('check_in'))
                    except Exception:
                        a_ts = None
                if not a_ts and a_dict.get('check_out'):
                    try:
                        a_ts = datetime.fromisoformat(a_dict.get('check_out'))
                    except Exception:
                        a_ts = None

                b_ts = None
                if b_att.check_in:
                    b_ts = b_att.check_in
                elif b_att.check_out:
                    b_ts = b_att.check_out

                # Try to use employee shift start when available to determine logical day
                shift_start = None
                try:
                    emp = self.get_employee(b_att.emp_id)
                    if emp and getattr(emp, 'shift', None):
                        try:
                            shift_start, _ = PayrollCalculator.parse_shift(emp.shift)
                        except Exception:
                            shift_start = None
                except Exception:
                    shift_start = None

                a_day = attendance_day(a_ts, shift_start if shift_start is not None else 9)
                b_day = attendance_day(b_ts, shift_start if shift_start is not None else 9)

                return a_dict.get('emp_id') == b_att.emp_id and a_day == b_day
            except Exception:
                return False

        replaced = False
        for i, a in enumerate(attendances):
            if same_day(a, attendance):
                try:
                    # Existing stored record
                    existing_att = Attendance.from_dict(a)

                    # If this is a manual edit, we should prioritize the incoming values
                    # especially if they were explicitly changed in the dialog.
                    if attendance.edited:
                        # For manual edits, we trust the incoming object completely
                        merged_check_in = attendance.check_in
                        merged_check_out = attendance.check_out

                        merged_att = Attendance(
                            attendance.emp_id,
                            merged_check_in,
                            merged_check_out,
                            edited=True,
                            edited_at=attendance.edited_at or existing_att.edited_at,
                            edited_by=attendance.edited_by or existing_att.edited_by,
                            edit_reason=attendance.edit_reason or existing_att.edit_reason,
                            status=attendance.status,
                            excuse_no_late=attendance.excuse_no_late,
                            excuse_no_early=getattr(attendance, 'excuse_no_early', False),
                            excuse_allow_overtime=getattr(attendance, 'excuse_allow_overtime', False),
                            shift_override=getattr(attendance, 'shift_override', None)
                        )
                    else:
                        # Device sync merging: combine timestamps to find In and Out
                        all_ts = []
                        if existing_att.check_in:
                            all_ts.append(existing_att.check_in)
                        if existing_att.check_out:
                            all_ts.append(existing_att.check_out)
                        if attendance.check_in:
                            all_ts.append(attendance.check_in)
                        if attendance.check_out:
                            all_ts.append(attendance.check_out)

                        # Dedupe and sort
                        all_ts = sorted(set(all_ts))

                        merged_check_in = all_ts[0] if all_ts else None
                        merged_check_out = all_ts[-1] if len(all_ts) > 1 else None

                        merged_att = Attendance(
                            attendance.emp_id,
                            merged_check_in,
                            merged_check_out,
                            edited=existing_att.edited,
                            edited_at=existing_att.edited_at,
                            status=existing_att.status,
                            excuse_no_late=getattr(existing_att, 'excuse_no_late', False),
                            excuse_no_early=getattr(existing_att, 'excuse_no_early', False),
                            excuse_allow_overtime=getattr(existing_att, 'excuse_allow_overtime', False),
                            shift_override=getattr(existing_att, 'shift_override', None)
                        )

                    attendances[i] = merged_att.to_dict()
                    replaced = True
                    break
                except Exception:
                    attendances[i] = attendance.to_dict()
                    replaced = True
                    break

        if not replaced:
            attendances.append(attendance.to_dict())

        self._save_json(self.attendance_file, attendances)

    def get_employee_attendance(self, emp_id: str) -> list[Attendance]:
        attendances = self._load_json(self.attendance_file)
        emp_attendances = [att for att in attendances if att["emp_id"] == emp_id]
        return [Attendance.from_dict(att) for att in emp_attendances]

    def get_all_attendances(self) -> list[Attendance]:
        """Return all attendance records as Attendance objects (normalized)."""
        attendances = self._load_json(self.attendance_file)
        result = []
        for att in attendances:
            try:
                result.append(Attendance.from_dict(att))
            except Exception:
                # skip malformed entries
                continue
        return result

    def get_attendance_by_date(self, emp_id: str, date: datetime) -> Attendance | None:
        attendances = self.get_employee_attendance(emp_id)
        # The 'date' passed from GUI is already the logical day (e.g. 2026-01-26 00:00:00)
        # We should use its date() part directly as target comparison.
        target_day = date.date()
        for att in attendances:
            try:
                # check both in and out to identify the logical day
                ref_ts = att.check_in or att.check_out
                if ref_ts and attendance_day(ref_ts) == target_day:
                    return att
            except Exception:
                continue
        return None

    # Payroll Management
    def save_payroll(self, emp_id: str, payroll_data: dict):
        payrolls = self._load_json(self.payroll_file)

        # Check if payroll exists for this month
        month_key = datetime.now().strftime("%Y-%m")
        for i, payroll in enumerate(payrolls):
            if payroll.get("emp_id") == emp_id and payroll.get("month") == month_key:
                payroll_data["month"] = month_key
                payroll_data["emp_id"] = emp_id
                payrolls[i] = payroll_data
                self._save_json(self.payroll_file, payrolls)
                return

        payroll_data["month"] = month_key
        payroll_data["emp_id"] = emp_id
        payrolls.append(payroll_data)
        self._save_json(self.payroll_file, payrolls)

    def get_employee_payroll(self, emp_id: str) -> list[dict]:
        payrolls = self._load_json(self.payroll_file)
        return [p for p in payrolls if p.get("emp_id") == emp_id]

    def get_current_month_payroll(self, emp_id: str) -> dict | None:
        month_key = datetime.now().strftime("%Y-%m")
        payrolls = self._load_json(self.payroll_file)
        for payroll in payrolls:
            if payroll.get("emp_id") == emp_id and payroll.get("month") == month_key:
                return payroll
        return None

    # Shift management
    def load_shifts(self) -> list[dict]:
        return self._load_json(self.shifts_file)

    def save_shifts(self, shifts: list[dict]):
        return self._save_json(self.shifts_file, shifts)

    def get_shifts(self) -> list[dict]:
        return self.load_shifts()

    def add_shift(self, shift: dict):
        shifts = self.load_shifts()
        shifts.append(shift)
        self.save_shifts(shifts)

    def update_shift(self, shift_id: str, new_shift: dict):
        shifts = self.load_shifts()
        for i, s in enumerate(shifts):
            if str(s.get('id')) == str(shift_id):
                shifts[i] = new_shift
                self.save_shifts(shifts)
                return
        # not found -> append
        shifts.append(new_shift)
        self.save_shifts(shifts)

    def delete_shift(self, shift_id: str):
        shifts = self.load_shifts()
        shifts = [s for s in shifts if str(s.get('id')) != str(shift_id)]
        self.save_shifts(shifts)

    # Finance records: advances, bonuses, deductions (cash), stored with date
    def _finances_file(self):
        return os.path.join('data', 'finances.json')

    def add_finance(self, record: dict):
        finances = self._load_json(self._finances_file())
        finances.append(record)
        self._save_json(self._finances_file(), finances)

    def get_finances(self) -> list[dict]:
        return self._load_json(self._finances_file())

    def get_finances_for_emp_month(self, emp_id: str, month: str) -> list[dict]:
        # month format: YYYY-MM
        finances = self.get_finances()
        result = []
        for f in finances:
            try:
                if str(f.get('emp_id')) != str(emp_id):
                    continue
                dt = f.get('date')
                if not dt:
                    continue
                if str(dt)[:7] == str(month):
                    result.append(f)
            except Exception:
                continue
        return result

    def update_finance(self, record: dict):
        """Update an existing finance record by its ID."""
        finances = self.get_finances()
        rec_id = str(record.get('id', ''))
        for i, f in enumerate(finances):
            if str(f.get('id')) == rec_id:
                finances[i] = record
                self._save_json(self._finances_file(), finances)
                return
        # If not found, append as new
        finances.append(record)
        self._save_json(self._finances_file(), finances)

    def delete_finance(self, record_id: str):
        finances = self.get_finances()
        finances = [f for f in finances if str(f.get('id')) != str(record_id)]
        self._save_json(self._finances_file(), finances)


class PayrollCalculator:
    @staticmethod
    def parse_shift(shift_str: str) -> tuple:
        """Parse shift string like '8:00-16:00' to return (start_hour, end_hour)"""
        try:
            start, end = shift_str.split("-")
            start_h = int(start.split(":")[0])
            end_h = int(end.split(":")[0])
            return start_h, end_h
        except Exception:
            # If shift_str is a shift name (e.g., 'ندى'), try to resolve from data/shifts.json
            try:
                import json
                import os
                shifts_path = os.path.join(os.getcwd(), 'data', 'shifts.json')
                if os.path.exists(shifts_path):
                    with open(shifts_path, encoding='utf-8') as f:
                        shifts = json.load(f)
                    for s in shifts:
                        if str(s.get('name')) == str(shift_str) or str(s.get('id')) == str(shift_str):
                            start = s.get('start')
                            end = s.get('end')
                            try:
                                start_h = int(str(start).split(':')[0])
                                end_h = int(str(end).split(':')[0])
                                return start_h, end_h
                            except Exception:
                                continue
            except Exception:
                pass
            return 8, 16

    @staticmethod
    def calculate_lateness(check_in: datetime, shift: str) -> tuple:
        """Calculate lateness in minutes and return (minutes_late, is_late)"""
        start_h, _ = PayrollCalculator.parse_shift(shift)
        shift_start = check_in.replace(hour=start_h, minute=0, second=0, microsecond=0)

        if check_in > shift_start:
            lateness_minutes = int((check_in - shift_start).total_seconds() / 60)
            return lateness_minutes, True
        return 0, False

    @staticmethod
    def calculate_overtime(check_in: datetime, check_out: datetime, shift: str) -> float:
        """Calculate overtime hours"""
        start_h, end_h = PayrollCalculator.parse_shift(shift)

        shift_end = check_in.replace(hour=end_h, minute=0, second=0, microsecond=0)
        if end_h <= start_h:
            shift_end += timedelta(days=1)

        if check_out and check_out > shift_end:
            overtime_seconds = (check_out - shift_end).total_seconds()
            overtime_hours = overtime_seconds / 3600
            return overtime_hours
        return 0

    @staticmethod
    def calculate_early_leave(check_in: datetime, check_out: datetime, shift: str) -> int:
        """Calculate early leave in minutes and return minutes_early"""
        start_h, end_h = PayrollCalculator.parse_shift(shift)

        shift_end = check_in.replace(hour=end_h, minute=0, second=0, microsecond=0)
        if end_h <= start_h:
            shift_end += timedelta(days=1)

        if check_out and check_out < shift_end:
            early_minutes = int((shift_end - check_out).total_seconds() / 60)
            return max(0, early_minutes)
        return 0

    @staticmethod
    def calculate_payroll(employee: Employee, attendances: list[Attendance],
                         bonus: float = 0, deduction: float = 0, advance: float = 0) -> dict:
        """Calculate complete payroll for an employee"""
        load_app_settings()

        monthly_salary = employee.monthly_salary
        # company policy: month counts as 26 working days
        days_in_month = 26

        # Determine shift length (hours) from employee.shift
        start_h, end_h = PayrollCalculator.parse_shift(employee.shift)
        shift_length = end_h - start_h if end_h > start_h else (24 - start_h + end_h)

        # Determine the payroll month target from attendances (if present) or default to today
        target_date = None
        for att in attendances:
            if att.check_in:
                target_date = att.check_in
                break
            if att.check_out:
                target_date = att.check_out
                break
        if not target_date:
            target_date = datetime.now()

        # Group attendances by logical day to handle multiple sessions or duplicates
        grouped_attendances = defaultdict(list)
        for att in attendances:
            ref_ts = att.check_in or att.check_out
            if not ref_ts:
                continue

            # Map to logical day using our fixed rollover
            day = attendance_day(ref_ts)
            if day:
                grouped_attendances[day].append(att)

        # Scheduled month hours: month (26 days) * shift length
        scheduled_month_hours = days_in_month * shift_length if shift_length > 0 else 0

        # Determine the range of the month for hire_date checking
        # Assuming we are calculating for a specific month (usually the month of the first/last attendance)
        # If no attendance, we can't easily know the month, but usually this is called within a month context.
        # For simplicity, we'll use the month of the first attendance or current month.
        ref_date = sorted(grouped_attendances.keys())[0] if grouped_attendances else datetime.now().date()
        month_start = ref_date.replace(day=1)
        import calendar
        _, last_day = calendar.monthrange(month_start.year, month_start.month)
        month_end = month_start.replace(day=last_day)

        # Adjusted scheduled hours if hired mid-month (DISABLED based on user request)
        effective_days_in_month = days_in_month
        # if employee.hire_date:
        #     try:
        #         h_date = datetime.strptime(employee.hire_date, '%Y-%m-%d').date()
        #         if month_start <= h_date <= month_end:
        #             total_days_in_month = (month_end - month_start).days + 1
        #             days_since_hire = (month_end - h_date).days + 1
        #             effective_days_in_month = (days_since_hire / total_days_in_month) * days_in_month
        #     except Exception:
        #         pass

        scheduled_month_hours = effective_days_in_month * shift_length if shift_length > 0 else 0
        hourly_rate = (monthly_salary / scheduled_month_hours) if scheduled_month_hours > 0 else 0

        total_hours = 0.0
        total_late_minutes = 0
        total_early_minutes = 0
        total_missing_scan_minutes = 0
        total_penalty_hours = 0.0
        working_days = 0 # Total days to be paid (including paid leave)
        actual_working_days = 0 # Days physically present or on mission
        vacation_days = 0 # Paid leave days
        daily_breakdown = []

        leave_days_count = 0
        now = datetime.now()

        # Determine date range to display in the report
        # We process from month_start to (month_end or today)
        end_date_for_loop = month_end
        if target_date.year == now.year and target_date.month == now.month:
            # For current month, we usually only care about days up to today
            end_date_for_loop = now.date()

        # Always start from month_start to handle pre-hiring days in the table
        start_date_for_loop = month_start
        h_dt = None
        if employee.hire_date:
            try:
                h_dt = datetime.strptime(employee.hire_date, '%Y-%m-%d').date()
            except Exception:
                pass

        # Process each day in the date range
        current_day = start_date_for_loop
        while current_day <= end_date_for_loop:
            if h_dt and current_day < h_dt:
                # Pre-hiring Day
                daily_breakdown.append({
                    'date': current_day.isoformat(),
                    'check_in': None,
                    'check_out': None,
                    'work_hours': 0.0,
                    'late_minutes': 0,
                    'late_compensated': False,
                    'overtime_hours': 0.0,
                    'note': 'قبل تاريخ التعيين',
                    'status': 'pre-hire'
                })
                current_day += timedelta(days=1)
                continue

            day_items = grouped_attendances.get(current_day, [])
            if not day_items:
                # Check for Weekend (Friday = 4 in Python date.weekday())
                # If weekend is paid (or just treated as valid off day), don't mark absent
                if current_day.weekday() == 4 and SETTINGS.get('weekend_paid', True):
                    daily_breakdown.append({
                        'date': current_day.isoformat(),
                        'check_in': None,
                        'check_out': None,
                        'work_hours': 0.0,
                        'late_minutes': 0,
                        'late_compensated': False,
                        'overtime_hours': 0.0,
                        'note': 'عطلة أسبوعية',
                        'status': 'weekend'
                    })
                    current_day += timedelta(days=1)
                    continue

                # Absent Day
                is_today = (current_day == now.date())

                # If it's today and shift hasn't potentially ended, use a different note
                # This avoids definitively marking as "Absent" while shift might be active/syncing
                absent_note = 'غياب'
                if is_today:
                    absent_note = 'لم يتم تسجيل حضور اليوم (أو لم يتم المزامنة)'

                daily_breakdown.append({
                    'date': current_day.isoformat(),
                    'check_in': None,
                    'check_out': None,
                    'work_hours': 0.0,
                    'late_minutes': 0,
                    'late_compensated': False,
                    'overtime_hours': 0.0,
                    'note': absent_note,
                    'status': 'absent'
                })
                current_day += timedelta(days=1)
                continue

            # Use the status of the first item (or primary item)
            primary_att = day_items[0]
            status = getattr(primary_att, 'status', 'regular')
            excuse_no_late = getattr(primary_att, 'excuse_no_late', False)
            excuse_no_early = getattr(primary_att, 'excuse_no_early', False)
            excuse_allow_overtime = getattr(primary_att, 'excuse_allow_overtime', False)
            shift_override = getattr(primary_att, 'shift_override', None)

            # Determine effective shift for this day
            effective_shift = shift_override if shift_override else employee.shift
            start_h, end_h = PayrollCalculator.parse_shift(effective_shift)
            shift_length = (end_h - start_h) if end_h > start_h else (24 - start_h + end_h)

            is_edited = any(getattr(att, 'edited', False) for att in day_items)
            edit_reason = next((getattr(att, 'edit_reason', '') for att in day_items if getattr(att, 'edit_reason', '')), '')

            # Gather all timestamps for this day
            all_ts = []
            for item in day_items:
                if item.check_in:
                    all_ts.append(item.check_in)
                if item.check_out:
                    all_ts.append(item.check_out)

            # Use extreme timestamps as effective In and Out
            all_ts = sorted(set(all_ts))
            effective_in = all_ts[0] if all_ts else None
            effective_out = all_ts[-1] if len(all_ts) > 1 else None

            assumed_penalty_hours = 0
            assumed_note = ''

            if shift_override:
                assumed_note += f'[شيفت مؤقت: {shift_override}] '

            work_hours = 0.0
            late_mins = 0
            early_mins = 0
            missing_scan_mins = 0
            daily_overtime = 0.0

            if status == 'leave':
                # Paid leave
                if leave_days_count < 4:
                    work_hours = shift_length
                    late_mins = 0
                    early_mins = 0
                    assumed_note = 'إجازة مدفوعة'
                    leave_days_count += 1
                else:
                    work_hours = 0
                    late_mins = 0
                    early_mins = 0
                    assumed_note = 'إجازة (تجاوز الحد الأقصى 4 أيام)'
            elif status == 'mission':
                # Mission - full pay, no penalty
                work_hours = shift_length
                late_mins = 0
                early_mins = 0
                assumed_note = 'مأمورية عمل'
            else:
                # regular or excuse
                # Handle missing check-in: try to assume start-of-shift
                # FIXED: Skip assumption if explicitly edited by admin
                if not effective_in and not is_edited:
                    try:
                        # Only assume if we have some other event (checkout exists)
                        # Assume check-in at SHIFT START to avoid Lateness (x2)
                        # And add the penalty to early_leave (x1)
                        shift_start_time = effective_out.replace(hour=start_h, minute=0, second=0, microsecond=0)
                        if start_h > end_h and shift_start_time > effective_out:
                            shift_start_time = shift_start_time - timedelta(days=1)

                        effective_in = shift_start_time

                        # Missing check-in penalty: Track separately
                        assumed_penalty_hours = SETTINGS.get('missing_checkout_penalty_hours', 2)
                        missing_scan_mins += int(assumed_penalty_hours * 60)
                        assumed_note = f'افتراض دخول وخصم {assumed_penalty_hours} ساعة'
                    except Exception:
                        pass

                # Calculate lateness - SKIP for paid leave/mission
                if effective_in and status not in ('leave', 'mission'):
                    late_mins, _is_late = PayrollCalculator.calculate_lateness(effective_in, effective_shift)

                    # Apply Employee Lateness Exclusion
                    if getattr(employee, 'ignore_lateness', False):
                        late_mins = 0
                    else:
                        # Apply Grace Period
                        grace_period = int(SETTINGS.get('grace_period_minutes', 10))
                        if late_mins <= grace_period:
                            late_mins = 0

                    if status == 'excuse' and excuse_no_late:
                        late_mins = 0
                        assumed_note = (assumed_note + ' / ' if assumed_note else '') + 'عذر (إلغاء التأخير)'
                    elif status == 'excuse':
                        assumed_note = (assumed_note + ' / ' if assumed_note else '') + 'عذر (ساعات العمل طبيعية)'

                # Handle missing check-out: Skip assumption if explicitly edited by admin or if special status
                if not effective_out and effective_in and not is_edited and status not in ('leave', 'mission'):
                    try:
                        # Improved 'Today' logic:
                        # Don't assume checkout if it's today and the shift end hasn't passed by 2+ hours
                        is_today = (current_day == now.date())
                        shift_end_time = effective_in.replace(hour=end_h, minute=0, second=0, microsecond=0)
                        if end_h <= start_h: # overnight
                            shift_end_time = shift_end_time + timedelta(days=1)

                        # If it's today and we haven't reached shift_end + 2 hours yet, don't penalize
                        if is_today and now < (shift_end_time + timedelta(hours=2)):
                            effective_out = None
                            assumed_note = (assumed_note + ' / ' if assumed_note else '') + 'قيد العمل / لم يوقع خروج بعد'
                        else:
                            # Assume checkout BEFORE shift end by penalty hours
                            # This way calculate_early_leave will compute the penalty
                            # We will later separate this penalty from actual early leave
                            penalty_hours = SETTINGS.get('missing_checkout_penalty_hours', 2)
                            effective_out = shift_end_time - timedelta(hours=penalty_hours)

                            # Mark that we have a missing checkout penalty to separate it later
                            missing_scan_mins += int(penalty_hours * 60)

                            assumed_note = (assumed_note + ' / ' if assumed_note else '') + f'افتراض خروج بدري {penalty_hours} ساعة'
                    except Exception:
                        effective_out = None

                if effective_out and effective_in:
                    calculated_hours = (effective_out - effective_in).total_seconds() / 3600

                    # For special paid statuses, take the maximum of assigned or calculated hours
                    if work_hours > 0:
                        work_hours = max(work_hours, calculated_hours)
                    else:
                        work_hours = calculated_hours

                    # Calculate early leave
                    # Calculate GROSS early leave (includes missing checkout penalty if any)
                    calculated_early = PayrollCalculator.calculate_early_leave(effective_in, effective_out, effective_shift)

                    # Separate regular early leave from missing scan penalty
                    # If we have missing_scan_mins from checkout, subtract it from calculated_early to avoid double counting
                    # CAUTION: missing_scan_mins might include check-in penalty which is NOT in calculated_early
                    # We need to only subtract the part related to checkout.

                    # Let's verify:
                    # 1. Missing Check-in: added to missing_scan_mins directly. Not in calculated_early.
                    # 2. Missing Check-out: effective_out adjusted. calculated_early HAS the minutes. missing_scan_mins HAS the minutes.
                    #    So we should take `regular_early = calculated_early - (missing_scan_mins_from_checkout)`

                    # Logic:
                    # If we assumed checkout, the calculated_early is fully attributed to missing scan (conceptually).
                    # Any extra early leave on top of assumption? No, because we force-set the time.

                    # Simplification:
                    # If we forced effective_out due to missing checkout, calculated_early IS the missing penalty.
                    # So regular_early should be 0 (or whatever remains).

                    # Re-calculating proper distribution
                    penalty_from_checkout = 0
                    if 'افتراض خروج' in assumed_note: # A bit hacky but we know we set it above
                         penalty_hours = SETTINGS.get('missing_checkout_penalty_hours', 2)
                         penalty_from_checkout = int(penalty_hours * 60)

                    regular_early = max(0, calculated_early - penalty_from_checkout)
                    early_mins += regular_early

                    # Apply excuse_no_early if applicable
                    if status == 'excuse' and excuse_no_early:
                        early_mins = 0
                        assumed_note = (assumed_note + ' / ' if assumed_note else '') + 'عذر (إلغاء الانصراف المبكر)'

                    if SETTINGS.get('overtime_enabled', True):
                        daily_ot = max(0.0, work_hours - shift_length)
                    else:
                        daily_ot = 0.0

                    # Check overtime cancellation rules
                    threshold = getattr(employee, 'max_lateness_before_overtime_cancellation', 30)
                    if threshold >= 0 and late_mins > threshold:
                        # Cancel overtime due to lateness, UNLESS excuse_allow_overtime is enabled
                        if not (status == 'excuse' and excuse_allow_overtime):
                            daily_ot = 0.0
                            assumed_note = (assumed_note + ' / ' if assumed_note else '') + 'إلغاء الإضافي'
                        else:
                            assumed_note = (assumed_note + ' / ' if assumed_note else '') + 'عذر (تفعيل الإضافي)'

                    daily_overtime = daily_ot
                else:
                    # If no clock-in/out, keep the work_hours assigned by status (e.g. mission/leave)
                    # if work_hours is still 0, then it's a real absence
                    if work_hours == 0:
                        daily_overtime = 0.0
                    else:
                        # work_hours is already set (mission/leave), daily_overtime is 0
                        daily_overtime = 0.0

            if work_hours > 0:
                working_days += 1
                if status == 'leave':
                    vacation_days += 1
                else:
                    actual_working_days += 1

            total_late_minutes += late_mins
            total_early_minutes += early_mins
            total_missing_scan_minutes += missing_scan_mins
            total_hours += work_hours

            daily_breakdown.append({
                'date': current_day.isoformat(),
                'check_in': effective_in.isoformat() if effective_in else None,
                'check_out': effective_out.isoformat() if effective_out else None,
                'work_hours': round(work_hours, 2),
                'late_minutes': late_mins,
                'early_minutes': early_mins,
                'late_compensated': False,
                'overtime_hours': round(daily_overtime, 2),
                'note': (f"[{edit_reason}] " if edit_reason else "") + assumed_note,
                'status': status
            })
            current_day += timedelta(days=1)

        # Compute daily overtime sum
        daily_overtime_sum = sum(d.get('overtime_hours', 0) for d in daily_breakdown)
        overtime_hours = daily_overtime_sum

        # Overtime no longer compensates for lateness
        for d in daily_breakdown:
            d['late_compensated'] = False

        # Lateness & Missing Checkout deduction calculation: Use multiplier from settings
        # EARLY LEAVE is calculated as delay but NOT doubled (multiplier 1.0)
        multiplier = SETTINGS.get('late_penalty_multiplier', 2.0)

        # Doubled part: Lateness ONLY
        doubled_penalty_units = (total_late_minutes / 60)

        # Single part: Early Leave + Missing Scan
        single_penalty_units = (total_early_minutes / 60) + (total_missing_scan_minutes / 60)

        lateness_deduction = (doubled_penalty_units * multiplier + single_penalty_units) * hourly_rate if hourly_rate > 0 else 0

        # Overtime payment: treated as normal work hour (no multiplier)
        overtime_payment = overtime_hours * hourly_rate if hourly_rate > 0 else 0

        # Bonus days: if employee worked more days than the standard month (26), pay extra days as normal days
        bonus_days = max(0, working_days - days_in_month)
        bonus_hours = bonus_days * shift_length
        bonus_payment = bonus_hours * hourly_rate if hourly_rate > 0 else 0

        # Base pay: full monthly salary if worked at least scheduled_month_hours (excluding OT),
        # otherwise prorated based on NORMAL hours worked.
        # Fix: We must subtract overtime hours from total_hours to get "Normal Hours"
        # so that we don't pay for OT twice (once in base, once in OT).
        normal_hours_worked = max(0.0, total_hours - daily_overtime_sum)

        if scheduled_month_hours > 0:
            if normal_hours_worked >= scheduled_month_hours:
                base_pay = monthly_salary
            else:
                base_pay = monthly_salary * (normal_hours_worked / scheduled_month_hours)
        else:
            base_pay = 0

        final_salary = base_pay - lateness_deduction - deduction - advance + overtime_payment + bonus_payment + bonus

        return {
            "emp_id": employee.emp_id,
            "emp_name": employee.name,
            "position": employee.position,
            "base_salary": monthly_salary,
            "scheduled_month_hours": round(scheduled_month_hours, 2),
            "effective_days_in_month": round(effective_days_in_month, 2),
            "days_in_month": days_in_month,
            "shift_length": shift_length,
            "hourly_rate": round(hourly_rate, 4),
            "working_days": working_days,
            "actual_working_days": actual_working_days,
            "vacation_days": vacation_days,
            "total_hours": round(total_hours, 2),
            "normal_hours_worked": round(normal_hours_worked, 2),
            "lateness_minutes": total_late_minutes,
            "ignore_lateness": getattr(employee, 'ignore_lateness', False),
            "early_leave_minutes": total_early_minutes,
            "missing_scan_minutes": total_missing_scan_minutes,
            "penalty_hours": round(total_penalty_hours, 2),
            "lateness_deduction": round(lateness_deduction, 2),
            "late_penalty_multiplier": multiplier,
            "overtime_hours": round(overtime_hours, 2),
            "overtime_payment": round(overtime_payment, 2),
            "bonus_days": bonus_days,
            "bonus_payment": round(bonus_payment, 2),
            "bonus": bonus,
            "deduction": deduction,
            "advance": advance,
            "base_pay_prorated": round(base_pay, 2),
            "final_salary": round(final_salary, 2),
            "daily": daily_breakdown,
            "calculated_at": datetime.now().isoformat()
        }
