from fastapi import Depends, Query
from fastapi.responses import HTMLResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from app.db.base import get_db
from app.dependencies import get_print_user
from . import router, get_settings, _make_pdf, wrap, top_band, ar_egp, fmt_date, fmt_dt
from datetime import datetime
import uuid


@router.get("/archive/{doc_id}", response_class=HTMLResponse)
async def print_archive_doc(doc_id: uuid.UUID, token: str = Query(None),
                             db: AsyncSession = Depends(get_db), _=Depends(get_print_user)):
    s = await get_settings(db)
    store = {"name": s.get("store_name",""), "address": s.get("store_address",""),
             "phone": s.get("store_phone",""), "logo_url": s.get("logo_url",""),
             "contacts": s.get("contact_phones") or []}
    row = await db.execute(text("""
        SELECT ad.*, u.full_name as created_by_name
        FROM archived_documents ad LEFT JOIN users u ON u.id = ad.created_by
        WHERE ad.id = :id
    """), {"id": doc_id})
    doc = row.fetchone()
    if not doc:
        return HTMLResponse("Not found", 404)
    doc = dict(doc._mapping)
    _raw_meta = doc.get('metadata_') or doc.get('metadata') or {}
    if isinstance(_raw_meta, str):
        import json as _json
        try:
            meta = _json.loads(_raw_meta)
        except Exception:
            meta = {}
    else:
        meta = _raw_meta or {}

    type_labels = {
        'sale_invoice': 'فاتورة مبيعات', 'quotation': 'عرض سعر',
        'purchase_invoice': 'فاتورة مشتريات', 'dispatch_order': 'إذن صرف',
        'goods_receipt': 'استلام بضاعة', 'stock_request': 'طلب نواقص',
        'shift_handover': 'تسليم عهدة', 'shift_report': 'تقرير وردية',
        'inventory_report': 'تقرير مخزون',
    }
    doc_label = type_labels.get(doc['doc_type'], doc['doc_type'])

    details_html = ""
    for k, v in meta.items():
        if v and k not in ('warehouse_id',):
            label_map = {'supplier': 'المورد', 'from_warehouse': 'من مخزن', 'to_warehouse': 'إلى مخزن',
                         'items_count': 'عدد الأصناف', 'received_by': 'استلم', 'from_user_name': 'المُسلِّم',
                         'to_user_name': 'المُستلِم', 'amount': 'المبلغ', 'notes': 'ملاحظات'}
            label = label_map.get(k, k)
            details_html += f'<div class="meta-cell"><div class="m-lbl">{label}</div><div class="m-val">{v}</div></div>'

    body = f"""
{top_band(store, doc_label, doc['doc_number'], fmt_date(doc['created_at']))}
<div class="body">
  <div class="meta-row" style="flex-wrap:wrap">
    <div class="meta-cell"><div class="m-lbl">التاريخ</div><div class="m-val">{fmt_dt(doc['created_at'])}</div></div>
    {f'<div class="meta-cell"><div class="m-lbl">أنشأه</div><div class="m-val">{doc["created_by_name"]}</div></div>' if doc.get('created_by_name') else ''}
    {f'<div class="meta-cell"><div class="m-lbl">المبلغ</div><div class="m-val" style="color:#1e3a5f;font-weight:900">{ar_egp(float(doc["amount"] or 0))}</div></div>' if doc.get('amount') else ''}
    {details_html}
  </div>
  {f'<div class="notes-box"><div class="n-lbl">ملاحظات</div><div class="n-txt">{meta.get("notes","")}</div></div>' if meta.get('notes') else ''}
</div>
<div style="border-top:2px solid #94a3b8;padding:12px 36px;background:#f8fafc;display:flex;justify-content:space-between">
  <div style="font-size:10px;color:#6b7280">طُبع: {datetime.now().strftime('%Y/%m/%d  %H:%M')}</div>
  <div style="font-size:10px;color:#6b7280">{store.get('name','')}</div>
</div>"""
    return HTMLResponse(wrap(body, f"{doc_label} — {doc['doc_number']}"))


@router.get("/pdf/archive/{doc_id}")
async def pdf_archive(doc_id: uuid.UUID, paper_size: str = None, token: str = Query(None),
                      db: AsyncSession = Depends(get_db), user=Depends(get_print_user)):
    html_resp = await print_archive_doc(doc_id, token, db, user)
    return await _make_pdf(html_resp, "مستند أرشيف", f"archive_{doc_id}.pdf", db, paper_size)
