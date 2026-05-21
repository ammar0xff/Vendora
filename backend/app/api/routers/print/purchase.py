from fastapi import Depends, Query
from fastapi.responses import HTMLResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from app.db.base import get_db
from app.dependencies import get_print_user
from . import router, get_settings, _make_pdf, wrap, top_band, ar_egp, ar_num, fmt_date
from datetime import datetime
import uuid


@router.get("/purchase/{po_id}", response_class=HTMLResponse)
async def print_purchase(po_id: uuid.UUID, token: str = Query(None),
                         db: AsyncSession = Depends(get_db), _=Depends(get_print_user)):
    s = await get_settings(db)
    store = {"name": s.get("store_name",""), "address": s.get("store_address",""),
             "phone": s.get("store_phone",""), "logo_url": s.get("logo_url",""),
             "contacts": s.get("contact_phones") or []}
    row = await db.execute(text("""
        SELECT po.*, sup.name as supplier_name, sup.phone as supplier_phone, sup.address as supplier_address,
               w.name as warehouse_name, u.full_name as created_by_name,
               po.amount_paid, po.received_by_name, po.invoice_image_url
        FROM purchase_orders po
        LEFT JOIN suppliers sup ON sup.id = po.supplier_id
        LEFT JOIN warehouses w ON w.id = po.warehouse_id
        LEFT JOIN users u ON u.id = po.created_by
        WHERE po.id = :id
    """), {"id": po_id})
    po = row.fetchone()
    if not po:
        return HTMLResponse("Not found", 404)
    po = dict(po._mapping)
    items_row = await db.execute(text("""
        SELECT poi.*, p.name as product_name, p.unit
        FROM purchase_order_items poi JOIN products p ON p.id = poi.product_id
        WHERE poi.po_id = :id ORDER BY poi.id
    """), {"id": po_id})
    items = [dict(r._mapping) for r in items_row.fetchall()]
    total = sum(float(i['qty_ordered']) * float(i['unit_cost']) for i in items)
    st_map = {"draft": ("مسودة","b-yellow"), "received": ("مستلم","b-green"), "cancelled": ("ملغي","b-red")}
    st_lbl, st_cls = st_map.get(po.get('status',''), (po.get('status',''), 'b-blue'))

    rows_html = ""
    for idx, it in enumerate(items, 1):
        line = float(it['qty_ordered']) * float(it['unit_cost'])
        rows_html += f"""<tr>
          <td style="color:#9ca3af;font-size:9px;text-align:center;white-space:nowrap">{idx}</td>
          <td><div class="td-name">{it['product_name']}</div></td>
          <td style="text-align:center;width:90px;color:#374151">{ar_num(float(it['qty_ordered']), 0)} {it.get('unit','')}</td>
          <td style="text-align:center;width:110px;color:#374151">{ar_egp(float(it['unit_cost']))}</td>
          <td style="text-align:left;white-space:nowrap">{ar_egp(line)}</td>
        </tr>"""

    body = f"""
{top_band(store, "فاتورة مشتريات", po['po_number'], fmt_date(po['created_at']))}
<div class="body">
  <div class="parties">
    <div class="party-card buyer">
      <div class="party-label">المورد</div>
      <div class="party-name">{po.get('supplier_name') or '— غير محدد —'}</div>
      <div class="party-detail">{'  ·  '.join(filter(None,[po.get('supplier_phone',''),po.get('supplier_address','')]))}</div>
    </div>
    <div class="party-card">
      <div class="party-label">الجهة المُشترية</div>
      <div class="party-name">{store['name']}</div>
      <div class="party-detail">{'  ·  '.join(filter(None,[store.get('phone',''),store.get('address','')]))}</div>
    </div>
  </div>
  <div class="meta-row">
    <div class="meta-cell"><div class="m-lbl">الحالة</div><div class="m-val"><span class="badge {st_cls}">{st_lbl}</span></div></div>
    <div class="meta-cell"><div class="m-lbl">المخزن</div><div class="m-val">{po.get('warehouse_name','—')}</div></div>
    {f'<div class="meta-cell"><div class="m-lbl">أنشأه</div><div class="m-val">{po["created_by_name"]}</div></div>' if po.get('created_by_name') else ''}
  {f'<div class="meta-cell"><div class="m-lbl">المبلغ المدفوع</div><div class="m-val" style="color:#16a34a;font-weight:900">{ar_egp(float(po["amount_paid"] or 0))}</div></div>' if po.get('amount_paid') else ''}
  </div>
  <div class="tbl-label">الأصناف المطلوبة</div>
  <table>
    <thead><tr>
      <th style="width:36px;text-align:center">#</th><th>الصنف</th>
      <th style="text-align:center;width:90px">الكمية</th>
      <th style="text-align:center;width:110px">سعر الوحدة</th>
      <th style="text-align:left;width:120px">الإجمالي</th>
    </tr></thead>
    <tbody>{rows_html}</tbody>
  </table>
  <div class="totals-section"><div class="totals-box">
    <div class="t-grand"><span class="t-lbl">إجمالي أمر الشراء</span><span class="t-val">{ar_egp(total)}</span></div>
  </div></div>
  {f'<div class="notes-box"><div class="n-lbl">ملاحظات</div><div class="n-txt">{po["notes"]}</div></div>' if po.get('notes') else ''}
</div>
<div class="doc-footer">
  <div class="sig"><div class="sig-name">توقيع المورد</div><div class="sig-line">الاسم والتوقيع</div></div>
  <div class="footer-mid"><div class="stamp-circle">الختم</div><div class="footer-meta">طُبع: {datetime.now().strftime('%Y/%m/%d  %H:%M')}</div></div>
  <div class="sig"><div class="sig-name">{po.get("received_by_name") or "المستلم"}</div><div class="sig-line">الاسم والتوقيع</div></div>
</div>
{f'<div style="margin:0 36px 16px;padding:12px 16px;background:#f0fdf4;border:1.5px solid #94a3b8;border-radius:10px;display:flex;justify-content:space-between"><span style="font-size:11px;color:#6b7280">المبلغ المدفوع</span><span style="font-size:15px;font-weight:900;color:#16a34a">{ar_egp(float(po["amount_paid"] or 0))}</span></div>' if po.get("amount_paid") else ''}
{f'<div style="margin:0 36px 16px"><img src="{po["invoice_image_url"]}" style="max-width:100%;border-radius:8px;border:1px solid #e2e8f0" /><p style="font-size:10px;color:#9ca3af;margin-top:4px">صورة الفاتورة المستلمة</p></div>' if po.get("invoice_image_url") else ''}
"""
    return HTMLResponse(wrap(body, f"فاتورة مشتريات — {po['po_number']}"))


@router.get("/pdf/purchase/{po_id}")
async def pdf_purchase(po_id: uuid.UUID, paper_size: str = None, token: str = Query(None),
                       db: AsyncSession = Depends(get_db), user=Depends(get_print_user)):
    html_resp = await print_purchase(po_id, token, db, user)
    return await _make_pdf(html_resp, "فاتورة مشتريات", f"purchase_{po_id}.pdf", db, paper_size)
