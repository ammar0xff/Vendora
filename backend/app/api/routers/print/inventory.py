from fastapi import Depends, Query
from fastapi.responses import HTMLResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from app.db.base import get_db
from app.dependencies import get_print_user
from . import router, get_settings, _make_pdf, wrap, top_band, ar_egp, ar_num, fmt_date
from datetime import datetime
import uuid


@router.get("/inventory/{warehouse_id}", response_class=HTMLResponse)
async def print_inventory(warehouse_id: uuid.UUID, token: str = Query(None),
                           db: AsyncSession = Depends(get_db), _=Depends(get_print_user)):
    s = await get_settings(db)
    store = {"name": s.get("store_name",""), "address": s.get("store_address",""),
             "phone": s.get("store_phone",""), "logo_url": s.get("logo_url",""),
             "contacts": s.get("contact_phones") or []}

    wh_row = await db.execute(text("SELECT name FROM warehouses WHERE id=:id"), {"id": warehouse_id})
    wh = wh_row.scalar() or str(warehouse_id)

    rows = await db.execute(text("""
        SELECT p.name, p.unit, p.cost_price, p.retail_price,
               cat.name as category, sub.name as subcategory,
               COALESCE(SUM(CASE WHEN sm.movement_type IN ('opening_stock','purchase','return_in','adjustment_in','transfer_in')
                                THEN sm.qty ELSE -sm.qty END), 0) as qty
        FROM products p
        JOIN subcategories sub ON sub.id = p.subcategory_id
        JOIN categories cat ON cat.id = sub.category_id
        LEFT JOIN stock_movements sm ON sm.product_id = p.id AND sm.warehouse_id = :wid
        WHERE p.is_active = true
        GROUP BY p.id, p.name, p.unit, p.cost_price, p.retail_price, cat.name, sub.name
        ORDER BY cat.name, sub.name, p.name
    """), {"wid": warehouse_id})
    items = [dict(r._mapping) for r in rows.fetchall()]

    total_cost = sum(float(i['qty'] or 0) * float(i['cost_price'] or 0) for i in items)
    total_retail = sum(float(i['qty'] or 0) * float(i['retail_price'] or 0) for i in items)
    total_units = sum(float(i['qty'] or 0) for i in items if float(i['qty'] or 0) > 0)

    rows_html = ""
    current_cat = ""
    for idx, item in enumerate(items, 1):
        qty = float(item['qty'] or 0)
        if item['category'] != current_cat:
            current_cat = item['category']
            rows_html += f'<tr style="background:#1e3a5f"><td colspan="6" style="color:white;font-weight:700;padding:8px 14px;font-size:12px">{current_cat}</td></tr>'
        rows_html += f"""<tr>
          <td style="color:#9ca3af;font-size:11px;text-align:center">{idx}</td>
          <td><div class="td-name">{item['name']}</div><div style="font-size:10px;color:#9ca3af">{item['subcategory']}</div></td>
          <td style="text-align:center;color:#374151">{ar_num(qty, 0)} {item['unit']}</td>
          <td style="text-align:center;color:#374151">{ar_egp(float(item['cost_price']))}</td>
          <td style="text-align:center;color:#374151">{ar_egp(float(item['retail_price']))}</td>
          <td style="text-align:left;{'color:#dc2626' if qty <= 0 else 'color:#1e3a5f'};font-weight:700">{ar_egp(qty * float(item['cost_price']))}</td>
        </tr>"""

    body = f"""
{top_band(store, f"تقرير المخزون — {wh}", f"INV-RPT-{datetime.now().strftime('%Y%m%d')}", fmt_date(datetime.now()))}
<div class="body">
  <div class="meta-row">
    <div class="meta-cell"><div class="m-lbl">الفرع</div><div class="m-val">{wh}</div></div>
    <div class="meta-cell"><div class="m-lbl">عدد الأصناف</div><div class="m-val">{ar_num(len(items), 0)}</div></div>
    <div class="meta-cell"><div class="m-lbl">قيمة التكلفة</div><div class="m-val" style="color:#1e3a5f;font-weight:900">{ar_egp(total_cost)}</div></div>
    <div class="meta-cell"><div class="m-lbl">قيمة البيع</div><div class="m-val" style="color:#16a34a;font-weight:900">{ar_egp(total_retail)}</div></div>
  </div>
  <div class="tbl-label">بيان الأصناف</div>
  <table>
    <thead><tr>
      <th style="width:36px;text-align:center">#</th>
      <th>الصنف</th>
      <th style="text-align:center;width:90px">الكمية</th>
      <th style="text-align:center;width:100px">سعر التكلفة</th>
      <th style="text-align:center;width:100px">سعر البيع</th>
      <th style="text-align:left;width:120px">القيمة</th>
    </tr></thead>
    <tbody>{rows_html}</tbody>
    <tfoot><tr style="background:#f1f5f9;font-weight:700">
      <td colspan="2" style="padding:10px 14px">الإجمالي</td>
      <td style="text-align:center;padding:10px 14px">{ar_num(total_units, 0)}</td>
      <td colspan="2"></td>
      <td style="text-align:left;padding:10px 14px;font-weight:900;color:#1e3a5f">{ar_egp(total_cost)}</td>
    </tr></tfoot>
  </table>
</div>
<div style="border-top:2px solid #94a3b8;padding:10px 36px;background:#f8fafc;display:flex;justify-content:space-between">
  <div style="font-size:10px;color:#6b7280">طُبع: {datetime.now().strftime('%Y/%m/%d  %H:%M')}</div>
  <div style="font-size:10px;color:#6b7280">{store.get('name','')}</div>
</div>"""
    return HTMLResponse(wrap(body, f"تقرير المخزون — {wh}"))


@router.get("/pdf/inventory/{warehouse_id}")
async def pdf_inventory(warehouse_id: uuid.UUID, paper_size: str = None, token: str = Query(None),
                        db: AsyncSession = Depends(get_db), user=Depends(get_print_user)):
    html_resp = await print_inventory(warehouse_id, token, db, user)
    return await _make_pdf(html_resp, "تقرير المخزون", f"inventory_{warehouse_id}.pdf", db, paper_size)
