"""payroll: the standalone /payroll/* router was retired in production (legacy
duplicate of /hr/payroll/*; its tables were dropped). Guard it stays gone.
Real payroll coverage lives in test_hr.py::test_payroll_full_flow."""
from conftest import owner_api  # noqa: F401


def test_legacy_payroll_router_retired(owner_api):
    r = owner_api.get("/payroll/employees")
    assert r.status_code == 404, r.text[:200]