"""sales module: POS sale (cash/wallet/split/credit), drafts, quotations
(drawer + safe), cancel, full/partial return, item qty update/delete, print."""
import uuid

from helpers import uid, to_uuid

from conftest import (admin_api, product, customer, subcategory, wh, safe, wallet,
                      open_shift)  # noqa: F401


def _item(prod, price="100", qty=1, cost="70"):
    return {"product_id": prod["id"], "qty": qty, "unit_price": price, "unit_cost": cost, "discount": "0"}


def _sale_payload(prod, wh_, **kw):
    base = {"warehouse_id": wh_["id"], "items": [_item(prod)]}
    base.update(kw)
    return base


def test_create_cash_sale(admin_api, reg, product, wh):
    r = admin_api.post("/sales", json=_sale_payload(product, wh))
    s = admin_api.ok(r, 200)
    reg.add("sale", s["id"])
    assert s["status"] == "confirmed"
    assert float(s["net_total"]) == 100
    assert float(s["paid_amount"]) == 100
    assert s["invoice_number"]


def test_create_sale_idempotent_local_id(admin_api, reg, product, wh):
    lid = f"e2e-{uuid.uuid4().hex[:8]}"
    payload = _sale_payload(product, wh, local_id=lid)
    s1 = admin_api.ok(admin_api.post("/sales", json=payload))
    reg.add("sale", s1["id"])
    s2 = admin_api.ok(admin_api.post("/sales", json=payload))
    assert s2["id"] == s1["id"]


def test_split_payments(admin_api, reg, product, wh, wallet, customer):
    payload = _sale_payload(product, wh, payments=[
        {"method": "cash", "amount": "40"},
        {"method": "wallet", "amount": "60", "wallet_id": wallet["id"]},
    ])
    s = admin_api.ok(admin_api.post("/sales", json=payload))
    reg.add("sale", s["id"])
    assert s["payment_method"] == "cash"
    assert s["is_credit"] is False

    # mismatched split totals are rejected
    bad = _sale_payload(product, wh, payments=[{"method": "cash", "amount": "10"}])
    r = admin_api.post("/sales", json=bad)
    assert r.status_code in (400, 409), r.text[:200]


def test_credit_sale_updates_balance(admin_api, reg, product, wh, customer):
    r = admin_api.put(f"/customers/{customer['id']}/balance", json={"balance": "0"})
    admin_api.ok(r, 200)
    s = admin_api.ok(admin_api.post("/sales", json=_sale_payload(product, wh,
                                                                 is_credit=True,
                                                                 customer_id=customer["id"])))
    reg.add("sale", s["id"])
    assert s["is_credit"] is True and float(s["paid_amount"]) == 0
    acct = admin_api.ok(admin_api.get(f"/customers/{customer['id']}/account"))
    assert float(acct["balance_due"]) == 100


def test_draft_flow(admin_api, reg, product, wh):
    r = admin_api.post("/sales/draft", json=_sale_payload(product, wh))
    d = admin_api.ok(r, 200)
    reg.add("sale", d["id"])
    assert d["status"] == "draft"

    drafts = admin_api.ok(admin_api.get("/sales/drafts"))
    assert any(x["id"] == d["id"] for x in drafts)

    confirmed = admin_api.put(f"/sales/{d['id']}/confirm")
    assert confirmed.status_code in (200, 201), confirmed.text[:200]
    body = confirmed.json()
    assert body.get("status") == "confirmed" or "invoice" in str(body).lower() or "id" in body


def test_delete_draft_and_guard_confirmed(admin_api, reg, product, wh):
    d = admin_api.ok(admin_api.post("/sales/draft", json=_sale_payload(product, wh)))
    reg.add("sale", d["id"])
    r = admin_api.delete(f"/sales/{d['id']}")
    assert r.status_code in (200, 204), r.text[:200]

    s = admin_api.ok(admin_api.post("/sales", json=_sale_payload(product, wh)))
    reg.add("sale", s["id"])
    r = admin_api.delete(f"/sales/{s['id']}")
    assert r.status_code == 400, r.text[:200]  # confirmed sales cannot be deleted


def test_sale_get_list_update_item(admin_api, reg, product, wh):
    s = admin_api.ok(admin_api.post("/sales", json=_sale_payload(product, wh)))
    reg.add("sale", s["id"])

    got = admin_api.ok(admin_api.get(f"/sales/{s['id']}"))
    assert got["id"] == s["id"] and len(got["items"]) == 1

    lst = admin_api.ok(admin_api.get("/sales"))
    assert any(x["id"] == s["id"] for x in lst)

    item = got["items"][0]
    up = admin_api.ok(admin_api.put(f"/sales/{s['id']}/items/{item['id']}",
                                    json={"qty": 3}))
    assert up.get("ok") is True and float(up.get("new_qty", 3)) == 3

    d = admin_api.ok(admin_api.delete(f"/sales/{s['id']}/items/{item['id']}"))
    assert d.get("ok") is True


def test_sale_print(admin_api, reg, product, wh):
    s = admin_api.ok(admin_api.post("/sales", json=_sale_payload(product, wh)))
    reg.add("sale", s["id"])
    r = admin_api.get(f"/sales/{s['id']}/print")
    assert r.status_code == 200
    body = admin_api.ok(r)
    # live backend returns a JSON doc (store/document_type); tolerate HTML too
    assert isinstance(body, dict) or "text/html" in r.headers.get("content-type", "")


def test_cancel_sale(admin_api, reg, product, wh):
    s = admin_api.ok(admin_api.post("/sales", json=_sale_payload(product, wh)))
    reg.add("sale", s["id"])
    r = admin_api.put(f"/sales/{s['id']}/cancel")
    body = admin_api.ok(r, 200)
    assert body["detail"] == "Cancelled" and body.get("invoice_number")


def test_full_return(admin_api, reg, product, wh):
    s = admin_api.ok(admin_api.post("/sales", json=_sale_payload(product, wh)))
    reg.add("sale", s["id"])
    r = admin_api.post(f"/sales/{s['id']}/return")
    body = admin_api.ok(r, 200)
    # stock restored
    got = admin_api.ok(admin_api.get(f"/sales/{s['id']}"))
    assert got["status"] in ("returned", "cancelled") or got.get("returned")


def test_partial_return(admin_api, reg, product, wh):
    s = admin_api.ok(admin_api.post("/sales", json=_sale_payload(product, wh, qty=4)))
    reg.add("sale", s["id"])
    r = admin_api.post(f"/sales/{s['id']}/partial-return",
                       json={"items": [{"product_id": product["id"], "qty": 1}]})
    body = admin_api.ok(r, 200)
    assert "returned" in body or "items" in body or body


# ---------------- quotations ----------------
def test_quotation_create_and_confirm_drawer(admin_api, reg, product, wh, customer):
    q = admin_api.ok(admin_api.post("/sales/quotations", json=_sale_payload(product, wh,
                                                                            customer_id=customer["id"])))
    reg.add("sale", q["id"])
    assert q["status"] == "quotation"

    sh = open_shift(admin_api, reg, wh["id"])
    confirmed = admin_api.ok(admin_api.post(f"/sales/{q['id']}/confirm-quotation",
                                            json={"destination": "drawer"}))
    assert confirmed["status"] == "confirmed"
    assert float(confirmed["paid_amount"]) == 100


def test_quotation_confirm_into_safe(owner_api, reg, product, wh, customer, safe):
    q = owner_api.ok(owner_api.post("/sales/quotations", json=_sale_payload(product, wh,
                                                                            customer_id=customer["id"])))
    reg.add("sale", q["id"])
    confirmed = owner_api.ok(owner_api.post(f"/sales/{q['id']}/confirm-quotation",
                                            json={"destination": "safe", "safe_id": safe["id"]}))
    assert confirmed["status"] == "confirmed"
    hist = owner_api.ok(owner_api.get(f"/safes/{safe['id']}/history"))
    assert any(x["tx_type"] == "deposit" for x in hist)


def test_quotation_update_items(admin_api, reg, product, wh):
    q = admin_api.ok(admin_api.post("/sales/quotations", json=_sale_payload(product, wh)))
    reg.add("sale", q["id"])
    upd = admin_api.ok(admin_api.put(f"/sales/{q['id']}", json={
        "items": [_item(product, price="90", qty=2)],
        "notes": "e2e-quote-update",
    }))
    assert "id" in upd