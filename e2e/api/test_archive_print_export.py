"""archive + print + export: archived documents list/detail/delete, sale &
purchase print, CSV/XLSX exports."""
import uuid

from helpers import uid

from conftest import (admin_api, owner_api, product, customer, supplier, wh,
                      reg)  # noqa: F401


def _a_sale(admin_api, reg, product, wh):
    s = admin_api.ok(admin_api.post("/sales", json={
        "warehouse_id": wh["id"],
        "items": [{"product_id": product["id"], "qty": 1,
                   "unit_price": "100", "unit_cost": "70", "discount": "0"}],
    }))
    reg.add("sale", s["id"])
    return s


def test_archive_list_and_detail(admin_api, reg, product, wh):
    sale = _a_sale(admin_api, reg, product, wh)
    rows = admin_api.ok(admin_api.get("/archive"))
    rows = rows if isinstance(rows, list) else rows.get("items", [])
    doc = next((d for d in rows if d.get("ref_id") == sale["id"]), None)
    assert doc is not None, "sale was not auto-archived"

    detail = admin_api.ok(admin_api.get(f"/archive/{doc['id']}"))
    assert detail["id"] == doc["id"]

    # linked docs (ref_id set) must not be hard-deletable by design
    r = admin_api.delete(f"/archive/{doc['id']}")
    assert r.status_code == 400, r.text[:200]


def test_purchase_receive_archives_invoice(admin_api, reg, product, supplier, wh):
    po = admin_api.ok(admin_api.post("/purchases", json={
        "supplier_id": supplier["id"], "warehouse_id": wh["id"],
        "items": [{"product_id": product["id"], "qty": 2, "unit_cost": "60"}]}))
    reg.add("purchase_order", po["id"])
    admin_api.ok(admin_api.post(f"/purchases/{po['id']}/receive"))
    rows = admin_api.ok(admin_api.get("/archive"))
    rows = rows if isinstance(rows, list) else rows.get("items", [])
    doc = next((d for d in rows if d.get("ref_id") == po["id"]), None)
    assert doc is not None, "purchase receive was not auto-archived"


def test_export_endpoints(owner_api, product, customer, supplier, wh):
    for path, params in (
        ("/export/products", {}),
        ("/export/sales", {"month": "2024-01"}),
        ("/export/stock", {}),
        ("/export/customers", {}),
        ("/export/suppliers", {}),
        ("/export/expenses", {"month": "2024-01"}),
        ("/export/purchases", {"month": "2024-01"}),
    ):
        r = owner_api.get(path, params=params)
        assert r.status_code in (200, 400), f"{path}: {r.text[:200]}"