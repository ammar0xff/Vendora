"""users module: list/staff/managers, CRUD, warehouses assignment, reset password."""
from helpers import uid


def test_managers_and_staff(admin_api):
    mgrs = admin_api.ok(admin_api.get("/users/managers"))
    assert isinstance(mgrs, list) and {"id", "full_name"} <= set(mgrs[0].keys()) if mgrs else True

    staff = admin_api.ok(admin_api.get("/users/staff"))
    assert isinstance(staff, list) and len(staff) >= 1
    assert {"id", "full_name", "role"} <= set(staff[0].keys())


def test_user_crud(admin_api, reg, wh):
    uname = f"e2e__{uid('u')}"
    r = admin_api.post("/users", json={
        "username": uname, "full_name": "E2E Cashier", "role": "cashier",
        "password": "SeedPass9!",
    })
    user = admin_api.ok(r, 200, 201)
    reg.add("user", user["id"])
    assert user["username"] == uname and user["role"] == "cashier"

    lst = admin_api.ok(admin_api.get("/users"))
    assert any(x["username"] == uname for x in lst)

    got = admin_api.ok(admin_api.get(f"/users/{user['id']}"))
    assert got["id"] == user["id"]

    upd = admin_api.ok(admin_api.put(f"/users/{user['id']}",
                                     json={"full_name": "E2E Cashier RENAMED", "role": "manager"}))
    assert upd["full_name"].endswith("RENAMED") and upd["role"] == "manager"

    # warehouses assignment
    r = admin_api.put(f"/users/{user['id']}/warehouses", json={"warehouse_ids": [wh["id"]]})
    admin_api.ok(r, 200)
    assigned = admin_api.ok(admin_api.get(f"/users/{user['id']}/warehouses"))
    assert str(wh["id"]) in assigned

    def _no_self_delete():
        me = admin_api.ok(admin_api.get("/auth/me"))
        r = admin_api.delete(f"/users/{me['id']}")
        assert r.status_code in (400, 409, 422)

    _no_self_delete()

    r = admin_api.post(f"/users/{user['id']}/reset-password", json={"password": "NewSeed999!"})
    assert r.status_code == 204, r.text[:200]

    r = admin_api.delete(f"/users/{user['id']}")
    assert r.status_code == 204, r.text[:200]


def test_invalid_user_role_rejected(admin_api):
    r = admin_api.post("/users", json={
        "username": f"e2e__{uid('u')}", "full_name": "Bad", "role": "boss",
        "password": "SeedPass9!",
    })
    assert r.status_code == 422, r.text[:200]


def test_archived_users_excluded_from_list(admin_api, reg):
    uname = f"e2e__{uid('u')}"
    r = admin_api.post("/users", json={
        "username": uname, "full_name": "E2E Gone", "role": "cashier",
        "password": "SeedPass9!",
    })
    user = admin_api.ok(r, 200, 201)
    reg.add("user", user["id"])
    admin_api.ok(admin_api.delete(f"/users/{user['id']}"), 204)
    lst = admin_api.ok(admin_api.get("/users"))
    assert all(x["username"] != uname for x in lst)