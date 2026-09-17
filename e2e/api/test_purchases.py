"""purchases module: PO CRUD, receive (stock in, cost update, prices),
supplier prices + history + comparison, quick-add, purchase suggestions."""
from helpers import uid

from conftest import (admin_api, owner_api, product, supplier, wh,
                      reg)  # noqa: F401


def _po_payload(prod, wh_, supplier_, qty=5, cost="60"):
    return {
        "supplier_id": supplier_["id"],
        "warehouse_id": wh_["id"],
        "items": [{"product_id": prod["id"], "qty": qty, "unit_cost": cost}],
    }


def test_purchase_order_crud_and_receive(owner_api, admin_api, reg, product, supplier, wh):
    payload = _po_payload(product, wh, supplier)
    po = owner_api.ok(owner_api.post("/purchases", json=payload))
    reg.add("purchase_order", po["id"])
    assert po["status"].lower() in ("draft", "pending", "ordered")

    lst = owner_api.ok(owner_api.get("/purchases"))
    rows = lst if isinstance(lst, list) else lst.get("items", [])
    assert any(x["id"] == po["id"] for x in rows)

    upd = owner_api.ok(owner_api.put(f"/purchases/{po['id']}",
                                     json={"supplier_id": supplier["id"],
                                           "warehouse_id": wh["id"],
                                           "items": [{"product_id": product["id"], "qty": 7,
                                                      "unit_cost": "60"}]}))
    assert isinstance(upd, dict)

    rec = owner_api.ok(owner_api.post(f"/purchases/{po['id']}/receive"))
    assert rec.get("detail") == "Received"

    bal = admin_api.ok(admin_api.post("/stock/balance/bulk",
                                      params={"warehouse_id": wh["id"]},
                                      json=[product["id"]]))
    assert float(bal.get(str(product["id"]), 0)) == 7

    mv = admin_api.ok(admin_api.get(f"/products/{product['id']}/movements"))
    items = mv.get("items", mv if isinstance(mv, list) else [])
    assert any(m["movement_type"] == "purchase" for m in items)


def test_purchase_reject_receive_twice(owner_api, admin_api, reg, product, supplier, wh):
    po = owner_api.ok(owner_api.post("/purchases", json=_po_payload(product, wh, supplier)))
    reg.add("purchase_order", po["id"])
    owner_api.ok(owner_api.post(f"/purchases/{po['id']}/receive"))
    r = admin_api.post(f"/purchases/{po['id']}/receive")
    assert r.status_code in (400, 409), r.text[:200]


def test_supplier_price_and_history(owner_api, admin_api, reg, product, supplier):
    sp = owner_api.ok(owner_api.post("/purchases/supplier-prices",
                                     json={"supplier_id": supplier["id"],
                                           "product_id": product["id"],
                                           "price": "55"}))
    reg.add("supplier_price", sp.get("id") or "")
    assert float(sp["price"]) == 55

    upd = owner_api.ok(owner_api.put(f"/purchases/supplier-prices/{sp['id']}",
                                     json={"price": "53"}))
    assert float(upd["price"]) == 53

    hist = admin_api.ok(owner_api.get(f"/purchases/price-history/{product['id']}"))
    assert isinstance(hist, list)

    comp = admin_api.ok(owner_api.get(f"/purchases/supplier-prices/product/{product['id']}"))
    assert comp["product_name"] and any(s["id"] == sp["id"] for s in comp["suppliers"])


def test_purchase_quick_add_and_suggestions(owner_api, reg, wh, supplier, product):
    # price suggestions for products with reorder point set
    sug = owner_api.ok(owner_api.get("/purchases/suggestions"))
    assert isinstance(sug, list)

    quick = owner_api.ok(owner_api.post("/purchases/quick-add-product", json={
        "name": f"E2E-QUICK-{uid('p')}", "unit": "عدد", "cost_price": 1, "retail_price": 3}))
    reg.add("product", quick["id"])
    assert float(quick["cost_price"]) == 1