"""auth module: login, me, roles, password change, print-token, reauthenticate."""
from helpers import Api, uid

from conftest import admin_api, reg  # noqa: F401


def test_login_and_me(admin_api):
    body = admin_api.ok(admin_api.post("/auth/login",
                                       json={"username": "ammar", "password": "changeme"}))
    assert body["token_type"] == "bearer"
    assert body["username"] == "ammar"
    assert "access_token" in body and len(body["access_token"]) > 20
    assert set(body.keys()) >= {"user_id", "full_name", "role"}

    me = admin_api.ok(admin_api.get("/auth/me"))
    assert me["username"] == "ammar"
    assert me["role"] == "admin"
    assert isinstance(me["permissions"], list)
    assert "is_manager" in me


def test_invalid_login_401():
    a = Api()
    r = a.post("/auth/login", json={"username": "ammar", "password": "wrong-pass"})
    assert r.status_code in (401, 400, 429), r.text[:200]


def test_roles(admin_api):
    roles = admin_api.ok(admin_api.get("/auth/roles"))
    labels = {x["value"] for x in roles}
    assert {"admin", "manager", "cashier"} <= labels


def test_change_password_cycle(admin_api, reg):
    r = admin_api.post("/users", json={
        "username": f"e2e__{uid('u')}",
        "full_name": "E2E Tmp",
        "role": "cashier",
        "password": "TempPass1!",
    })
    user = admin_api.ok(r, 200, 201)
    reg.add("user", user["id"])

    a = Api()
    a.login(user["username"], "TempPass1!")
    assert a.username == user["username"]

    r = a.put("/auth/me/password", json={
        "current_password": "TempPass1!", "new_password": "TempPass2!"})
    admin_api.ok(r, 200)

    a2 = Api()
    a2.login(user["username"], "TempPass2!")
    assert a2.ok(a2.get("/auth/me"))["username"] == user["username"]


def test_print_token(admin_api):
    body = admin_api.ok(admin_api.post("/auth/print-token"))
    assert "token" in body and len(body["token"]) > 20


def test_reauthenticate(admin_api):
    body = admin_api.ok(admin_api.post("/auth/reauthenticate",
                                       json={"username": "ammar", "password": "changeme"}))
    assert body["username"] == "ammar"
    assert "user_id" in body