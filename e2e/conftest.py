"""Shared pytest fixtures: live API client (session-scoped auth to dodge
rate limits), provisioned test users (owner = all perms, cashier = limited),
direct DB pool for verification/cleanup, and an autouse session teardown that
removes every row the suite created.

Usage:
    pytest e2e/api/ -v
"""
from __future__ import annotations

import json
import uuid

import pytest

from helpers import Api, DB, Registry, load_database_url, uid

ADMIN = ("ammar", "changeme")
OWNER_USER = "e2e_owner"


@pytest.fixture(scope="session")
def db() -> DB:
    url = load_database_url()
    assert url, "E2E_DATABASE_URL not set and unable to read backend env file"
    d = DB(url)
    yield d
    d.close()


@pytest.fixture(scope="session")
def reg() -> Registry:
    return Registry()


@pytest.fixture(scope="session")
def admin_api() -> Api:
    a = Api()
    a.login(*ADMIN)
    return a


def _ensure_user(admin_api: Api, username: str, full_name: str, role: str, password: str, reg: Registry) -> str:
    lst = admin_api.ok(admin_api.get("/users"))
    existing = next((u for u in lst if u["username"] == username), None)
    if existing:
        reg.add("user", existing["id"])
        return existing["id"]
    r = admin_api.post("/users", json={
        "username": username, "full_name": full_name, "role": role, "password": password,
    })
    if r.status_code in (200, 201):
        u = r.json()
        reg.add("user", u["id"])
        return u["id"]
    raise RuntimeError(f"Unable to provision {username}: {r.status_code} {r.text[:200]}")


FULL_PERMS = [
    "pos", "sales", "quotations", "inventory", "operations", "purchases",
    "customers", "reports", "archive", "payroll", "users", "settings",
    "admin", "shifts", "finance",
]


@pytest.fixture(scope="session")
def owner(admin_api: Api, reg: Registry, db: DB):
    """A user with every permission (incl. 'finance' + 'purchases')."""
    uid_owner = _ensure_user(admin_api, OWNER_USER, "E2E Owner", "admin", "E2eOwner9!", reg)
    db.q(
        "UPDATE users SET permissions = %s::jsonb, is_manager = TRUE WHERE id = %s",
        (json.dumps(FULL_PERMS), uid_owner),
    )
    return uid_owner


@pytest.fixture(scope="session")
def owner_api(owner, reg: Registry) -> Api:
    a = Api()
    a.login(OWNER_USER, "E2eOwner9!")
    return a


@pytest.fixture(scope="session")
def cashier_api(admin_api: Api, reg: Registry) -> Api:
    uname = f"e2e_cashier_{uuid.uuid4().hex[:6]}"
    _ensure_user(admin_api, uname, "E2E Cashier", "cashier", "E2eCash8!", reg)
    a = Api()
    a.login(uname, "E2eCash8!")
    return a


@pytest.fixture(autouse=True, scope="session")
def _cleanup(db: DB, reg: Registry):
    yield
    db.cleanup(reg)


# --------------------------------------------------------------------------
# Small domain fixtures ------------------------------------------------------
# --------------------------------------------------------------------------

@pytest.fixture()
def wh(admin_api: Api, reg: Registry):
    """A uniquely-named active warehouse."""
    name = "E2E-WH-" + uid("w")
    r = admin_api.post("/stock/warehouses",
                       json={"code": name, "name": name, "warehouse_type": "warehouse"})
    data = admin_api.ok(r, 200, 201)
    reg.add("warehouse", data["id"])
    return data


@pytest.fixture()
def category(admin_api: Api, reg: Registry):
    name = "E2E-CAT-" + uid("c")
    r = admin_api.post("/categories", json={"name": name})
    cat = admin_api.ok(r, 200, 201)
    reg.add("category", cat["id"])
    return cat


@pytest.fixture()
def subcategory(admin_api: Api, category, reg: Registry):
    name = "E2E-SUB-" + uid("s")
    r = admin_api.post("/subcategories",
                       json={"category_id": category["id"], "name": name})
    sub = admin_api.ok(r, 200, 201)
    reg.add("subcategory", sub["id"])
    return sub


@pytest.fixture()
def product(admin_api: Api, subcategory, reg: Registry):
    """Uniquely named product (untracked stock by default)."""
    name = "E2E-PROD-" + uid("p")
    barcode = "59" + uuid.uuid4().hex[:10]
    r = admin_api.post("/products", json={
        "subcategory_id": subcategory["id"],
        "name": name,
        "barcode": barcode,
        "unit": "عدد",
        "retail_price": "100",
        "wholesale_price": "85",
        "cost_price": "70",
        "reorder_point": "1",
    })
    prod = admin_api.ok(r, 200, 201)
    reg.add("product", prod["id"])
    return prod


@pytest.fixture()
def customer(admin_api: Api, reg: Registry):
    name = "E2E-CUST-" + uid("c")
    r = admin_api.post("/customers", json={"name": name, "phone": "01012345678"})
    c = admin_api.ok(r, 200, 201)
    reg.add("customer", c["id"])
    return c


@pytest.fixture()
def supplier(admin_api: Api, reg: Registry):
    name = "E2E-SUPP-" + uid("s")
    r = admin_api.post("/suppliers", json={"name": name, "phone": "01012345678"})
    s = admin_api.ok(r, 200, 201)
    reg.add("supplier", s["id"])
    return s


@pytest.fixture()
def wallet(owner_api: Api, reg: Registry):
    name = "E2E-WALLET-" + uid("w")
    r = owner_api.post("/wallets", json={"name": name, "type": "vodafone_cash", "phone": "010"})
    w = owner_api.ok(r, 200, 201)
    reg.add("wallet", w["id"])
    bal = w.get("balance")
    if bal is not None:
        reg.snapshot("payment_wallets", w["id"], "balance", bal)
    return w


@pytest.fixture()
def safe(owner_api: Api, reg: Registry):
    name = "E2E-SAFE-" + uid("s")
    r = owner_api.post("/safes", json={"name": name, "location": "e2e"})
    s = owner_api.ok(r, 200, 201)
    reg.add("safe", s["id"])
    bal = s.get("balance")
    if bal is not None:
        reg.snapshot("safes", s["id"], "balance", bal)
    return s


def open_shift(api: Api, reg: Registry, warehouse_id: str, initial: str = "100"):
    r = api.post("/shifts/open", json={"initial_amount": initial, "warehouse_id": warehouse_id})
    sh = api.ok(r, 200, 201)
    reg.add("shift", sh["id"])
    return sh