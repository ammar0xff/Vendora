"""parties module: customers (CRUD, account, ledger, payments, balance) and
suppliers (CRUD, ledger, transactions)."""
import uuid

from helpers import uid, to_uuid

from conftest import customer, supplier, wh, product, subcategory  # noqa: F401


# ---------------- customers ----------------
def test_customer_crud(admin_api, reg):
    name = f"E2E-CUST-{uid('c')}"
    r = admin_api.post("/customers", json={"name": name, "phone": "01000000001",
                                           "credit_limit": "500"})
    cu = admin_api.ok(r, 200, 201)
    reg.add("customer", cu["id"])
    assert cu["name"] == name

    lst = admin_api.ok(admin_api.get("/customers", params={"search": name[:10]}))
    assert any(x["id"] == cu["id"] for x in (lst if isinstance(lst, list) else lst.get("items", [])))

    upd = admin_api.ok(admin_api.put(f"/customers/{cu['id']}",
                                     json={"name": name + "-R", "credit_limit": "1000"}))
    assert upd["name"].endswith("-R")

    acct = admin_api.ok(admin_api.get(f"/customers/{cu['id']}/account"))
    assert acct["customer_id"] == cu["id"] or "balance" in acct

    ledger = admin_api.ok(admin_api.get(f"/customers/{cu['id']}/ledger"))
    assert "items" in ledger or isinstance(ledger, list)

    r = admin_api.delete(f"/customers/{cu['id']}")
    assert r.status_code in (200, 204), r.text[:200]


def test_customer_balance_and_payment(admin_api, reg, customer):
    r = admin_api.put(f"/customers/{customer['id']}/balance",
                      json={"balance": "250", "note": "e2e-set"})
    admin_api.ok(r, 200)

    p = admin_api.post(f"/customers/{customer['id']}/payments",
                       json={"amount": "100", "note": "e2e-pay"})
    pay = admin_api.ok(p, 200, 201)
    reg.add("payment", pay.get("id", to_uuid(pay)) if pay else uuid.uuid4())

    acct = admin_api.ok(admin_api.get(f"/customers/{customer['id']}/account"))
    assert acct["customer_id"] == customer["id"] or "balance" in acct

    lst = admin_api.ok(admin_api.get("/customers", params={"search": customer["name"][:10]}))
    rows = lst if isinstance(lst, list) else lst.get("items", [])
    row = next(x for x in rows if x["id"] == customer["id"])
    assert 0 <= float(row.get("balance", 0)) <= 250


# ---------------- suppliers ----------------
def test_supplier_crud(admin_api, reg):
    name = f"E2E-SUPP-{uid('s')}"
    r = admin_api.post("/suppliers", json={"name": name, "phone": "01000000002", "notes": "e2e"})
    su = admin_api.ok(r, 200, 201)
    reg.add("supplier", su["id"])

    lst = admin_api.ok(admin_api.get("/suppliers"))
    rows = lst if isinstance(lst, list) else lst.get("items", [])
    assert any(x["id"] == su["id"] for x in rows)

    upd = admin_api.ok(admin_api.put(f"/suppliers/{su['id']}", json={"name": name + "-R"}))
    assert upd["name"].endswith("-R")

    ledger = admin_api.ok(admin_api.get(f"/suppliers/{su['id']}/ledger"))
    assert "transactions" in ledger or "items" in ledger or isinstance(ledger, list)

    tx = admin_api.ok(admin_api.post(f"/suppliers/{su['id']}/transactions",
                                     json={"amount": 50, "type": "debit", "notes": "e2e"}), 200, 201)

    r = admin_api.delete(f"/suppliers/{su['id']}")
    assert r.status_code == 204, r.text[:200]


def test_supplier_transaction_type_validation(admin_api, supplier):
    r = admin_api.post(f"/suppliers/{supplier['id']}/transactions",
                       json={"amount": 1, "type": "bad"})
    assert r.status_code == 422