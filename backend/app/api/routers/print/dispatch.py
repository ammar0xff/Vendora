from fastapi import Depends, Query
from fastapi.responses import HTMLResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from app.db.base import get_db
from app.dependencies import get_print_user
from . import router, get_settings, _make_pdf, wrap, top_band, ar_num, fmt_date


@router.get("/dispatch/{doc_number}", response_class=HTMLResponse)
async def print_dispatch(doc_number: str, token: str = Query(None),
                         db: AsyncSession = Depends(get_db), _=Depends(get_print_user)):
    s = await get_settings(db)
    store = {"name": s.get("store_name",""), "address": s.get("store_address",""),
             "phone": s.get("store_phone",""), "logo_url": s.get("logo_url",""),
             "contacts": s.get("contact_phones") or []}

    row = await db.execute(text("""
        SELECT dm.*, w_from.name as from_warehouse, w_to.name as to_warehouse,
               u.full_name as created_by_name
        FROM dispatch_movements dm
        LEFT JOIN warehouses w_from ON w_from.id = dm.from_warehouse_id
        LEFT JOIN warehouses w_to ON w_to.id = dm.to_warehouse_id
        LEFT JOIN users u ON u.id = dm.created_by
        WHERE dm.doc_number = :doc
    """), {"doc": doc_number})
    dm = row.fetchone()
    if not dm:
        return HTMLResponse("Not found", 404)
    dm = dict(dm._mapping)

    items_row = await db.execute(text("""
        SELECT di.*, p.name as product_name, p.unit
        FROM dispatch_items di JOIN products p ON p.id = di.product_id
        WHERE di.dispatch_id = :id ORDER BY di.id
    """), {"id": dm['id']})
    items = [dict(r._mapping) for r in items_row.fetchall()]

    rows_html = ""
    for idx, it in enumerate(items, 1):
        rows_html += f"""<tr>
          <td style="color:#9ca3af;font-size:9px;text-align:center">{idx}</td>
          <td><div class="td-name">{it['product_name']}</div></td>
          <td style="text-align:center;white-space:nowrap">{ar_num(float(it['qty']), 0)}</td>
          <td style="text-align:center;white-space:nowrap">{it.get('unit','')}</td>
        </tr>"""

    body = f"""
{top_band(store, 'أمر صرف', dm['doc_number'], fmt_date(dm['created_at']))}
<div class="body">
  <div class="parties">
    <div class="party-card buyer">
      <div class="party-label">صادر من</div>
      <div class="party-name">{dm.get('from_warehouse','—')}</div>
    </div>
    <div class="party-card">
      <div class="party-label">وارد إلى</div>
      <div class="party-name">{dm.get('to_warehouse','—')}</div>
    </div>
  </div>
  {f'<div class="note-section">{dm["notes"]}</div>' if dm.get('notes') else ''}
  <div class="tbl-label">الأصناف</div>
  <table>
    <thead><tr><th style="text-align:center">#</th><th style="width:100%">اسم الصنف</th><th style="text-align:center">الكمية</th><th style="text-align:center">الوحدة</th></tr></thead>
    <tbody>{rows_html}</tbody>
  </table>
  <div style="margin-top:6px;font-size:11px;font-weight:700;text-align:left">إجمالي الأصناف: {ar_num(len(items), 0)}</div>
  <div class="signatures">
    <div class="signature-item"><div class="label">أمين المخازن</div><div class="signature-line"></div></div>
    <div class="signature-item"><div class="label">المستلم</div><div class="signature-line"></div></div>
    <div class="signature-item"><div class="label">مدير الفرع</div><div class="signature-line"></div></div>
  </div>
</div>"""
    return HTMLResponse(wrap(body, f"أمر صرف — {dm['doc_number']}"))


@router.get("/handover/{doc_number}", response_class=HTMLResponse)
async def print_handover(doc_number: str, token: str = Query(None),
                         db: AsyncSession = Depends(get_db), _=Depends(get_print_user)):
    s = await get_settings(db)
    store = {"name": s.get("store_name",""), "address": s.get("store_address",""),
             "phone": s.get("store_phone",""), "logo_url": s.get("logo_url",""),
             "contacts": s.get("contact_phones") or []}

    row = await db.execute(text("""
        SELECT dm.*, w_from.name as from_warehouse, w_to.name as to_warehouse,
               u.full_name as created_by_name,
               assignee.full_name as assignee_name
        FROM dispatch_movements dm
        LEFT JOIN warehouses w_from ON w_from.id = dm.from_warehouse_id
        LEFT JOIN warehouses w_to ON w_to.id = dm.to_warehouse_id
        LEFT JOIN users u ON u.id = dm.created_by
        LEFT JOIN users assignee ON assignee.id = dm.assignee_id
        WHERE dm.doc_number = :doc AND dm.type = 'handover'
    """), {"doc": doc_number})
    hm = row.fetchone()
    if not hm:
        return HTMLResponse("Not found", 404)
    hm = dict(hm._mapping)

    items_row = await db.execute(text("""
        SELECT di.*, p.name as product_name, p.unit
        FROM dispatch_items di JOIN products p ON p.id = di.product_id
        WHERE di.dispatch_id = :id ORDER BY di.id
    """), {"id": hm['id']})
    items = [dict(r._mapping) for r in items_row.fetchall()]

    rows_html = ""
    for idx, it in enumerate(items, 1):
        qty = ar_num(float(it['qty']), 0)
        rows_html += f"""<tr>
          <td style="color:#9ca3af;font-size:9px;text-align:center">{idx}</td>
          <td><div class="td-name">{it['product_name']}</div></td>
          <td style="text-align:center;white-space:nowrap">{qty}</td>
          <td style="text-align:center;white-space:nowrap">{it.get('unit','')}</td>
        </tr>"""

    body = f"""
{top_band(store, 'تسليم عهدة', hm['doc_number'], fmt_date(hm['created_at']))}
<div class="body">
  <div class="parties">
    <div class="party-card buyer">
      <div class="party-label">المسَلِّم</div>
      <div class="party-name">{hm.get('created_by_name','—')}</div>
    </div>
    <div class="party-card">
      <div class="party-label">المسَلَّم إليه</div>
      <div class="party-name">{hm.get('assignee_name','—')}</div>
    </div>
  </div>
  {f'<div class="note-section">{hm["notes"]}</div>' if hm.get('notes') else ''}
  <div class="tbl-label">الأصناف المسلَّمة</div>
  <table>
    <thead><tr><th style="text-align:center">#</th><th style="width:100%">اسم الصنف</th><th style="text-align:center">الكمية</th><th style="text-align:center">الوحدة</th></tr></thead>
    <tbody>{rows_html}</tbody>
  </table>
  <div style="margin-top:6px;font-size:11px;font-weight:700;text-align:left">إجمالي الأصناف: {ar_num(len(items), 0)}</div>
  <div class="signatures">
    <div class="signature-item"><div class="label">المسَلِّم</div><div class="signature-line"></div><div class="name">{hm.get('created_by_name','')}</div></div>
    <div class="signature-item"><div class="label">المسَلَّم إليه</div><div class="signature-line"></div><div class="name">{hm.get('assignee_name','')}</div></div>
    <div class="signature-item"><div class="label">مدير الفرع</div><div class="signature-line"></div></div>
  </div>
</div>"""
    return HTMLResponse(wrap(body, f"تسليم عهدة — {hm['doc_number']}"))


@router.get("/pdf/dispatch/{doc_number}")
async def pdf_dispatch(doc_number: str, paper_size: str = None, token: str = Query(None),
                       db: AsyncSession = Depends(get_db), user=Depends(get_print_user)):
    html_resp = await print_dispatch(doc_number, token, db, user)
    return await _make_pdf(html_resp, "أمر صرف", f"dispatch_{doc_number}.pdf", db, paper_size)


@router.get("/pdf/handover/{doc_number}")
async def pdf_handover(doc_number: str, paper_size: str = None, token: str = Query(None),
                       db: AsyncSession = Depends(get_db), user=Depends(get_print_user)):
    html_resp = await print_handover(doc_number, token, db, user)
    return await _make_pdf(html_resp, "تسليم عهدة", f"handover_{doc_number}.pdf", db, paper_size)
