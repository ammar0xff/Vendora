"""reports module: sales reports, profit, inventory print, ledger,
cash-flow, aging, admin overview."""
from datetime import date, datetime

from conftest import admin_api, owner_api, wh  # noqa: F401


def _month() -> str:
    return datetime.now().strftime("%Y-%m")


def _from() -> str:
    return date.today().replace(day=1).isoformat()


def _to() -> str:
    return date.today().isoformat()


def test_sales_reports(owner_api, wh):
    for path, params in (
        ("/reports/sales/daily", {"month": _month()}),
        ("/reports/sales/monthly", {"year": datetime.now().year, "month": datetime.now().month}),
        ("/reports/sales/top-products", {"from_date": _from(), "to_date": _to()}),
        ("/reports/sales/by-cashier", {"from_date": _from(), "to_date": _to()}),
    ):
        r = owner_api.get(path, params=params)
        assert r.status_code in (200, 400), f"{path}: {r.text[:200]}"


def test_profit_report(owner_api, wh):
    r = owner_api.get("/reports/profit",
                      params={"from_date": _from(), "to_date": _to(), "warehouse_id": wh["id"]})
    if r.status_code in (200,):
        owner_api.ok(r)
    else:
        assert r.status_code in (200, 400), r.text[:200]


def test_inventory_print(owner_api, wh):
    r = owner_api.get("/reports/inventory/print", params={"warehouse_id": wh["id"]})
    assert r.status_code == 200
    body = owner_api.ok(r)
    assert isinstance(body, dict)


def test_ledger_reports(owner_api, wh):
    for path, params in (
        ("/reports/ledger", {"from_date": _from(), "to_date": _to()}),
        ("/reports/ledger/daily-items", {"from_date": _from(), "to_date": _to()}),
        ("/reports/ledger/periodic", {"from_date": _from(), "to_date": _to()}),
    ):
        r = owner_api.get(path, params=params)
        assert r.status_code in (200, 400), f"{path}: {r.text[:200]}"


def test_cash_flow_and_aging(owner_api):
    r = owner_api.get("/reports/cash-flow",
                      params={"from_date": _from(), "to_date": _to()})
    assert r.status_code in (200, 400), r.text[:200]
    r = owner_api.get("/reports/aging")
    assert r.status_code in (200, 400), r.text[:200]


def test_admin_overview(owner_api):
    body = owner_api.ok(owner_api.get("/admin/overview"))
    assert isinstance(body, dict) or "items" in body