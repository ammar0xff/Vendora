"""storefront (/store): public product catalog, product detail, categories."""
import httpx

from helpers import BASE

from conftest import product  # noqa: F401
from conftest import admin_api, reg  # noqa: F401


def test_store_products():
    with httpx.Client(base_url=BASE, timeout=30) as c:
        r = c.get("/store/products")
        assert r.status_code == 200, r.text[:200]
        body = r.json()
        rows = body if isinstance(body, list) else body.get("items", [])
        assert isinstance(rows, list)


def test_store_categories():
    with httpx.Client(base_url=BASE, timeout=30) as c:
        r = c.get("/store/categories")
        assert r.status_code == 200
        assert isinstance(r.json(), (list, dict))


def test_store_product_detail(reg, product):
    with httpx.Client(base_url=BASE, timeout=30) as c:
        r = c.get(f"/store/products/{product['id']}")
        assert r.status_code == 200, r.text[:200]
        assert r.json()["id"] == product["id"]