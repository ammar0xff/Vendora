"""notifications + updater + health: endpoint smoke coverage and validation."""
from helpers import uid

from conftest import admin_api, owner_api, reg  # noqa: F401


def test_notifications_register_unregister(admin_api, reg):
    token = "E2E-FCM-" + uid("t", 10)
    r = admin_api.post("/notifications/register", json={"token": token, "platform": "web"})
    if r.status_code in (200, 201):
        admin_api.ok(r)
        tokens = admin_api.ok(admin_api.get("/notifications/tokens"))
        assert isinstance(tokens, list)
        un = admin_api.post("/notifications/unregister", params={"token": token})
        assert un.status_code in (200, 204), un.text[:200]
    else:
        assert r.status_code in (400, 422), r.text[:200]


def test_notifications_send(admin_api):
    r = admin_api.post("/notifications/send", json={
        "title": "E2E", "body": "e2e test", "token": "E2E-nonexistent"})
    assert r.status_code in (200, 400, 404, 422), r.text[:200]


def test_updater_unauthenticated_or_supported():
    import httpx
    from helpers import BASE
    with httpx.Client(base_url=BASE, timeout=30) as c:
        r = c.get("/updater/desktop/0.0.0")
        assert r.status_code in (200, 204, 404), r.text[:200]


def test_health():
    import httpx
    from helpers import BASE
    with httpx.Client(base_url=BASE, timeout=30) as c:
        r = c.get("/health")
        assert r.status_code == 200, r.text[:200]