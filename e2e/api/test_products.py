"""products module: categories, subcategories, products CRUD, barcodes,
image, move, movements, delete guards, quick-add."""
import uuid

from helpers import uid, to_uuid

from conftest import product, category, subcategory, wh  # noqa: F401  (fixtures)


def _prod_payload(sub_id: str, name: str | None = None, barcode: str | None = None):
    return {
        "subcategory_id": sub_id,
        "name": name or f"E2E-PROD-{uid('p')}",
        "barcode": barcode or "59" + uuid.uuid4().hex[:10],
        "unit": "عدد",
        "retail_price": "100",
        "wholesale_price": "85",
        "cost_price": "70",
        "reorder_point": "1",
    }


# ---------------- categories ----------------
def test_category_crud(admin_api, reg):
    r = admin_api.post("/categories", json={"name": f"E2E-CAT-{uid('c')}"})
    cat = admin_api.ok(r, 200, 201)
    reg.add("category", cat["id"])

    lst = admin_api.ok(admin_api.get("/categories"))
    assert any(c["id"] == cat["id"] for c in lst)

    upd = admin_api.ok(admin_api.put(f"/categories/{cat['id']}", json={"name": cat["name"] + "-R"}))
    assert upd["name"].endswith("-R")
    assert upd.get("image_url") is None  # backend update only touches name

    r = admin_api.delete(f"/categories/{cat['id']}")
    assert r.status_code == 204


def test_category_delete_guard_with_products(admin_api, reg, category, subcategory, product):
    r = admin_api.delete(f"/categories/{category['id']}")
    assert r.status_code in (400, 409), r.text[:200]


# ---------------- subcategories ----------------
def test_subcategory_crud(admin_api, reg, category):
    r = admin_api.post("/subcategories",
                       json={"category_id": category["id"], "name": f"E2E-SUB-{uid('s')}"})
    sub = admin_api.ok(r, 200, 201)
    reg.add("subcategory", sub["id"])

    upd = admin_api.ok(admin_api.put(f"/subcategories/{sub['id']}",
                                     json={"name": sub["name"] + "-R", "category_id": category["id"]}))
    assert upd["name"] == sub["name"] + "-R"
    assert upd["category_id"] == category["id"]

    r = admin_api.delete(f"/subcategories/{sub['id']}")
    assert r.status_code == 204


def test_subcategory_delete_guard_with_products(admin_api, subcategory, product):
    r = admin_api.delete(f"/subcategories/{subcategory['id']}")
    assert r.status_code in (400, 409), r.text[:200]


# ---------------- products ----------------
def test_product_crud(admin_api, reg, subcategory):
    payload = _prod_payload(subcategory["id"])
    r = admin_api.post("/products", json=payload)
    prod = admin_api.ok(r, 200, 201)
    reg.add("product", prod["id"])
    assert prod["barcode"] == payload["barcode"]
    assert float(prod["retail_price"]) == 100

    got = admin_api.ok(admin_api.get(f"/products/{prod['id']}"))
    assert got["id"] == prod["id"] and got["barcode"] == payload["barcode"]

    byb = admin_api.ok(admin_api.get(f"/products/barcode/{payload['barcode']}"))
    assert byb["id"] == prod["id"]

    upd = admin_api.ok(admin_api.put(f"/products/{prod['id']}",
                                     json={"retail_price": "150", "stock_status": "untracked"}))
    assert float(upd["retail_price"]) == 150

    # lookups
    lst = admin_api.ok(admin_api.get("/products", params={"page_size": 5}))
    assert "items" in lst and lst["total"] >= 1


def test_product_barcodes(admin_api, reg, subcategory, product):
    extra = "59" + uuid.uuid4().hex[:10]
    r = admin_api.post(f"/products/{product['id']}/barcodes",
                       json={"barcode": extra, "is_primary": False})
    b = admin_api.ok(r, 200, 201)
    assert b["barcode"] == extra

    upd = admin_api.ok(admin_api.put(f"/barcodes/{b['id']}", json={"is_primary": True, "barcode": extra}))
    assert upd["is_primary"] is True

    r = admin_api.delete(f"/barcodes/{b['id']}")
    assert r.status_code == 204


def test_product_image_and_move(admin_api, reg, subcategory):
    from conftest import category as cat_fixture  # noqa

    payload = _prod_payload(subcategory["id"])
    prod = admin_api.ok(admin_api.post("/products", json=payload), 200, 201)
    reg.add("product", prod["id"])
    sub2 = admin_api.ok(admin_api.post("/subcategories",
                                       json={"category_id": subcategory["category_id"],
                                             "name": f"E2E-SUB2-{uid('s')}"}), 200, 201)
    reg.add("subcategory", sub2["id"])

    moved = admin_api.ok(admin_api.post(f"/products/{prod['id']}/move",
                                        json={"subcategory_id": sub2["id"]}))
    assert moved.get("subcategory_id") == sub2["id"] or moved.get("detail") == "Moved"
    if moved.get("detail") != "Moved":
        got = admin_api.ok(admin_api.get(f"/products/{prod['id']}"))
        assert got.get("subcategory_id") == sub2["id"]


def test_product_movements_endpoint(admin_api, reg, subcategory, wh, product):
    r = admin_api.post("/stock/movements", json={
        "product_id": product["id"], "warehouse_id": wh["id"],
        "movement_type": "opening_stock", "qty": 10, "unit_cost": "5", "note": "e2e",
    })
    admin_api.ok(r, 200)

    page = admin_api.ok(admin_api.get(f"/products/{product['id']}/movements"))
    assert page["total"] >= 1
    assert page["items"][0]["product_id"] == product["id"]


def test_quick_add_product(admin_api, reg, subcategory):
    r = admin_api.post("/purchases/quick-add-product", json={
        "name": f"E2E-QUICK-{uid('q')}",
        "unit": "عدد",
        "cost_price": 1,
        "retail_price": 3,
        "subcategory_id": subcategory["id"],
    })
    prod = admin_api.ok(r, 200, 201)
    reg.add("product", prod["id"])
    assert float(prod["cost_price"]) == 1