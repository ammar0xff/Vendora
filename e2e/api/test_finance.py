"""finance module: financial categories, user permissions, financial ledger,
audit log; expense categories are exercised too."""
from helpers import uid

from conftest import (admin_api, owner_api, product, wh,
                      reg)  # noqa: F401


def test_permissions_get_and_update(owner_api, reg):
    # create a throwaway user to set its permissions
    uname = "e2e_perm_" + uid("u", 6)
    u = owner_api.ok(owner_api.post("/users", json={
        "username": uname, "full_name": "perm test", "role": "cashier",
        "password": "E2ePerm7!"}))
    reg.add("user", u["id"])

    got = owner_api.ok(owner_api.get(f"/permissions/{u['id']}"))
    assert "permissions" in got

    upd = owner_api.ok(owner_api.put(f"/permissions/{u['id']}",
                                     json={"permissions": ["pos", "sales"]}))
    assert "permissions" in upd or upd.get("detail") == "updated"

    got2 = owner_api.ok(owner_api.get(f"/permissions/{u['id']}"))
    assert set(got2["permissions"]) == {"pos", "sales"}


def test_financial_categories_expense(owner_api, reg):
    c = owner_api.ok(owner_api.post("/financial-categories",
                                    json={"name": "E2E-" + uid("f"), "type": "expense"}))
    reg.add("financial_category", c["id"])
    cats = owner_api.ok(owner_api.get("/financial-categories"))
    assert any(x["id"] == c["id"] for x in cats)
    owner_api.ok(owner_api.delete(f"/financial-categories/{c['id']}"), 200, 204)


def test_financial_ledger(owner_api):
    r = owner_api.get("/financial-ledger",
                      params={"from_date": "2026-01-01", "to_date": "2026-12-31"})
    if r.status_code in (200, 400):
        body = owner_api.ok(r, 200, 400)
        assert body is not None
    else:
        assert r.status_code in (200, 400), r.text[:200]


def test_audit_log(owner_api):
    r = owner_api.get("/audit-log")
    body = owner_api.ok(r)
    assert isinstance(body, list) or "items" in body