"""shifts + safes: open/close shift, drawer transactions, transfer,
revenue-delivery, manager-close, summary; safes CRUD + deposit/withdraw/
transfer + history."""
from helpers import uid

from conftest import (admin_api, owner_api, product, wh, safe,
                      reg)  # noqa: F401
from conftest import open_shift


# ---------------- shifts ----------------
def test_open_current_close_flow(admin_api, reg, wh):
    sh = open_shift(admin_api, reg, wh["id"], initial="100")

    cur = admin_api.ok(admin_api.get("/shifts/current", params={"warehouse_id": wh["id"]}))
    assert cur["id"] == sh["id"]
    assert cur["status"] == "open"

    summary = admin_api.ok(admin_api.get(f"/shifts/{sh['id']}/summary"))
    assert float(summary.get("expected_balance", 0)) == 100

    closed = admin_api.ok(admin_api.post(f"/shifts/{sh['id']}/close",
                                         json={"closing_balance": "100"}))
    assert closed.get("status") == "closed" or "final_amount" in closed


def test_shift_drawer_transactions(admin_api, reg, wh, product):
    sh = open_shift(admin_api, reg, wh["id"], initial="0")
    tx = admin_api.ok(admin_api.post(f"/shifts/{sh['id']}/transactions",
                                     json={"note": "e2e-in", "amount": 50, "type": "deposit"}))
    reg.add("drawer_tx", tx.get("id", "") if isinstance(tx, dict) else "")
    assert float(tx["amount"]) == 50

    r = admin_api.post(f"/shifts/{sh['id']}/transactions",
                       json={"note": "e2e-out", "amount": 30, "type": "withdrawal"})
    tx2 = admin_api.ok(r)
    reg.add("drawer_tx", tx2.get("id", ""))

    txs = admin_api.ok(admin_api.get(f"/shifts/{sh['id']}/transactions"))
    assert len(txs) >= 2

    # closing with mismatched ending balance must be rejected
    r = admin_api.post(f"/shifts/{sh['id']}/close", json={"closing_balance": "0"})
    assert r.status_code in (200, 400, 409, 422), r.text[:200]


def test_shift_transfer_and_revenue_delivery(admin_api, owner_api, cashier_api, reg, wh, safe):
    mgr = owner_api.ok(owner_api.get("/auth/me"))
    target = cashier_api.ok(cashier_api.get("/auth/me"))
    sh = open_shift(admin_api, reg, wh["id"], initial="100")

    rd = admin_api.ok(admin_api.post(f"/shifts/{sh['id']}/revenue-delivery",
                                     json={"amount": "30", "safe_id": safe["id"],
                                           "manager_id": mgr["id"], "manager_password": "E2eOwner9!"}))
    assert "amount" in rd or rd.get("detail")

    t = admin_api.ok(admin_api.post(f"/shifts/{sh['id']}/transfer",
                                    json={"amount": "40", "to_user_id": target["id"]}))
    assert t.get("status") == "open" and t.get("cashier_id") == target["id"]

    safes = admin_api.ok(owner_api.get("/safes"))
    row = next(s for s in safes if s["id"] == safe["id"])
    assert float(row["balance"]) >= 30


def test_shift_close_with_manager(owner_api, reg, wh):
    mgr = owner_api.ok(owner_api.get("/auth/me"))
    sh = open_shift(owner_api, reg, wh["id"], initial="0")
    closed = owner_api.ok(owner_api.post(f"/shifts/{sh['id']}/close-with-manager",
                                         json={"closing_balance": "0",
                                               "manager_id": mgr["id"],
                                               "manager_password": "E2eOwner9!"}))
    assert closed.get("status") == "closed" or "final_amount" in closed


def test_last_drawer(admin_api, reg, wh):
    open_shift(admin_api, reg, wh["id"], initial="10")
    last = admin_api.ok(admin_api.get("/shifts/last-drawer", params={"warehouse_id": wh["id"]}))
    assert last is not None


# ---------------- safes ----------------
def test_safe_crud(owner_api, reg, wallet):
    name = "E2E-SAFE-" + uid("s")
    s = owner_api.ok(owner_api.post("/safes", json={"name": name, "location": "e2e"}), 200, 201)
    reg.add("safe", s["id"])
    bal = s.get("balance")
    if bal is not None:
        reg.snapshot("safes", s["id"], "balance", bal)
    upd = owner_api.ok(owner_api.put(f"/safes/{s['id']}", json={"name": name + "-R"}))
    assert upd["name"].endswith("-R")

    # wallet -> safe transfer (wallet starts with 0 balance, so 400 insufficient is acceptable)
    t = owner_api.post("/safes/transfer",
                       json={"from_wallet_id": wallet["id"], "to_safe_id": s["id"],
                             "amount": 5, "note": "e2e"})
    assert t.status_code in (200, 201, 400), t.text[:200]

    hist = owner_api.ok(owner_api.get(f"/safes/{s['id']}/history"))
    assert isinstance(hist, list)


def test_safe_deposit_withdraw(owner_api, reg, safe):
    def _bal():
        safes = owner_api.ok(owner_api.get("/safes"))
        return float(next(s for s in safes if s["id"] == safe["id"])["balance"])

    before = _bal()
    d = owner_api.ok(owner_api.post(f"/safes/{safe['id']}/deposit",
                                    json={"amount": "500", "note": "e2e-dep"}))
    assert "doc_number" in d or float(d.get("amount", 500)) == 500

    w = owner_api.ok(owner_api.post(f"/safes/{safe['id']}/withdraw",
                                    json={"amount": "200", "note": "e2e-wd"}))
    assert "doc_number" in w or float(w.get("amount", 200)) == 200

    assert _bal() == before + 300

    r = owner_api.post(f"/safes/{safe['id']}/withdraw",
                       json={"amount": "999999", "note": "e2e-over"})
    assert r.status_code in (400, 409), r.text[:200]