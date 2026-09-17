"""settings module: store settings, product options, manifest, logo upload."""
from helpers import uid


def test_get_settings(admin_api):
    s = admin_api.ok(admin_api.get("/settings"))
    assert "store_name" in s or "currency" in s or "settings" in s, s


def test_update_settings_roundtrip(admin_api):
    r = admin_api.put("/settings", json={"settings": {"store_name": f"E2E عربية {uid('s')}"}})
    body = admin_api.ok(r, 200)
    assert isinstance(body, dict)


def test_product_options_roundtrip(admin_api):
    opts = admin_api.ok(admin_api.get("/settings/product-options"))
    assert isinstance(opts, dict)

    r = admin_api.put("/settings/product-options", json={
        "units": ["عدد", "كجم", "لتر", "متر"],
        "types": ["نوع اختبار"],
    })
    body = admin_api.ok(r, 200)
    assert isinstance(body, dict)

    again = admin_api.ok(admin_api.get("/settings/product-options"))
    assert isinstance(again, dict)


def test_manifest_served(admin_api):
    r = admin_api.get("/settings/manifest.json")
    assert r.status_code == 200
    assert "json" in r.headers.get("content-type", "").lower() or "manifest" in r.text[:200]


def test_upload_logo_accepts_image(admin_api, db):
    import base64
    one_px_png = base64.b64decode(
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
    )
    r = admin_api.client.post(
        "/settings/upload-logo",
        files={"file": ("logo.png", one_px_png, "image/png")},
    )
    assert r.status_code in (200, 201), r.text[:300]
    assert r.json().get("logo_url")


def test_upload_logo_rejects_invalid_image(admin_api):
    r = admin_api.client.post(
        "/settings/upload-logo",
        files={"file": ("logo.png", b"\x89PNG\r\n\x1a\n" + b"\x00" * 64, "image/png")},
    )
    assert r.status_code in (400, 422), r.text[:300]