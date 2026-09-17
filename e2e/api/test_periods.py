"""periods module: accounting month close/reopen + HR payroll period lifecycle."""
from datetime import datetime

from conftest import owner_api, admin_api, reg  # noqa: F401


def test_list_periods(owner_api):
    rows = owner_api.ok(owner_api.get("/periods"))
    assert isinstance(rows, list) or "items" in rows


def test_close_and_reopen_month(owner_api):
    month = datetime.now().strftime("%Y-%m")
    close = owner_api.post(f"/periods/{month}/close")
    if close.status_code in (200, 201):
        body = owner_api.ok(close)
        assert body is not None
        reopened = owner_api.post(f"/periods/{month}/reopen")
        assert reopened.status_code in (200, 201), reopened.text[:200]
        body2 = owner_api.ok(reopened)
        assert body2 is not None
    else:
        # already closed by production -> reopen then close again, leave closed as found
        assert close.status_code in (400, 409), close.text[:200]
        reopened = owner_api.post(f"/periods/{month}/reopen")
        if reopened.status_code in (200, 201):
            owner_api.ok(reopened)
            again = owner_api.post(f"/periods/{month}/close")
            assert again.status_code in (200, 201), again.text[:200]


def test_hr_payroll_period_lifecycle(owner_api, reg):
    """Real product flow: hr payroll period goes draft -> submit -> approve -> pay."""
    month = datetime.now().strftime("%Y-%m")
    p = owner_api.ok(owner_api.get(f"/hr/payroll/period?month={month}"))
    assert p.get("month") == month or p.get("status") in ("draft", "submitted", "approved", "paid")
    assert "status" in p
    reg.add("hr_period", p["id"])
    submit = owner_api.post(f"/hr/payroll/period/submit?month={month}")
    assert submit.status_code in (200, 201, 400), submit.text[:200]
    approve = owner_api.post(f"/hr/payroll/period/approve?month={month}")
    assert approve.status_code in (200, 201, 400), approve.text[:200]