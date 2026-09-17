"""operations module: dispatch, goods-receipt, stock-request, list, PDF."""
from helpers import uid

from conftest import (admin_api, owner_api, product, supplier, customer,
                      wh, reg)  # noqa: F401


def test_dispatch_receipt_request_flow(owner_api, reg, wh, product):
    # second warehouse so dispatch/stock-request have distinct endpoints
    twh = owner_api.ok(owner_api.post("/stock/warehouses", json={
        "code": f"E2E-WH-{uid('w')}", "name": f"E2E-WH-{uid('w')}", "warehouse_type": "warehouse"}))
    reg.add("warehouse", twh["id"])

    # seed stock so the transfer has something to move
    mv = owner_api.ok(owner_api.post("/stock/movements", json={
        "product_id": product["id"], "warehouse_id": wh["id"],
        "movement_type": "opening_stock", "qty": "10", "unit_cost": "70"}))
    assert mv.get("qty") or mv.get("id")

    dispatch = owner_api.ok(owner_api.post("/operations/dispatch", json={
        "from_warehouse_id": wh["id"], "to_warehouse_id": twh["id"],
        "items": [{"product_id": product["id"], "qty": 2, "unit_cost": "70"}]}))
    assert dispatch["doc_type"] == "dispatch_order" and dispatch.get("doc_number")

    gr = owner_api.ok(owner_api.post("/operations/goods-receipt", json={
        "warehouse_id": twh["id"], "supplier_name": "e2e",
        "items": [{"product_id": product["id"], "qty": 2, "unit_cost": "70"}]}))
    assert gr["doc_type"] == "goods_receipt" and gr.get("doc_number")

    sr = owner_api.ok(owner_api.post("/operations/stock-request", json={
        "from_warehouse_id": wh["id"], "to_warehouse_id": twh["id"],
        "items": [{"product_id": product["id"], "qty": 2}]}))
    assert sr["doc_type"] == "stock_request" and sr.get("doc_number")

    rows = owner_api.ok(owner_api.get("/operations"))
    assert isinstance(rows, list)