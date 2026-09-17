"""security / permission matrix: role gating per module and auth requirements."""
import httpx

from helpers import BASE, Api

from conftest import admin_api, owner_api, cashier_api, reg  # noqa: F401


def test_unauthenticated_is_rejected():
    with httpx.Client(base_url=BASE, timeout=30) as c:
        for path in ("/sales", "/users", "/products", "/admin/overview"):
            r = c.get(path)
            assert r.status_code in (401, 403), f"{path}: {r.status_code}"


def test_invalid_token_rejected():
    a = Api(token="not-a-real-token")
    r = a.get("/auth/me")
    assert r.status_code in (401, 403), r.text[:200]


def test_cashier_allowed_and_denied(cashier_api, wh, product):
    # allowed: sales (list) + customers
    assert cashier_api.get("/sales").status_code == 200
    assert cashier_api.get("/customers").status_code in (200,)

    # denied: inventory writes, user management, settings, finance, payroll
    cases = [
        ("post", "/products", {"subcategory_id": None, "name": "x",
                               "retail_price": "1", "cost_price": "1"}),
        ("post", "/stock/warehouses", {"code": "x", "name": "x"}),
        ("get", "/users", None),
        ("post", "/wallets", {"name": "x", "type": "y"}),
        ("post", "/hr/employees", {"name": "x", "position": "x"}),
        ("post", "/financial-categories", {"name": "x", "type": "expense"}),
    ]
    for method, path, body in cases:
        r = getattr(cashier_api, method)(path, json=body) if body is not None \
            else getattr(cashier_api, method)(path)
        assert r.status_code == 403, f"{method} {path} -> {r.status_code}: {r.text[:150]}"


def test_admin_without_finance_is_denied(admin_api):
    r = admin_api.post("/wallets", json={"name": "x", "type": "y"})
    assert r.status_code == 403, r.text[:200]


def test_owner_with_finance_is_allowed(owner_api):
    r = owner_api.get("/wallets")
    assert r.status_code == 200


def test_self_delete_forbidden(owner_api, reg):
    me = owner_api.ok(owner_api.get("/auth/me"))
    r = owner_api.delete(f"/users/{me['id']}")
    assert r.status_code in (400, 403), r.text[:200]