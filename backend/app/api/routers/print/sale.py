from fastapi import Depends
from fastapi.responses import HTMLResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from app.db.base import get_db
from app.dependencies import get_print_user
from . import router, get_settings, _make_pdf, wrap, top_band, ar_egp, ar_num, fmt_date, fmt_dt
from datetime import datetime
import uuid


@router.get("/sale/{sale_id}", response_class=HTMLResponse)
async def print_sale(sale_id: uuid.UUID,
                     db: AsyncSession = Depends(get_db), _=Depends(get_print_user)):
    s = await get_settings(db)
    store = {"name": s.get("store_name",""), "address": s.get("store_address",""),
             "phone": s.get("store_phone",""), "logo_url": s.get("logo_url",""),
             "contacts": s.get("contact_phones") or []}

    row = await db.execute(text("""
        SELECT sa.*, c.name as customer_name, c.phone as customer_phone, c.address as customer_address,
               w.name as warehouse_name, u.full_name as created_by_name,
               cashier.full_name as cashier_name
        FROM sales sa
        LEFT JOIN customers c ON c.id = sa.customer_id
        LEFT JOIN warehouses w ON w.id = sa.warehouse_id
        LEFT JOIN users u ON u.id = sa.created_by
        LEFT JOIN users cashier ON cashier.id = sa.cashier_id
        WHERE sa.id = :id
    """), {"id": sale_id})
    sale = row.fetchone()
    if not sale:
        return HTMLResponse("Not found", 404)
    sale = dict(sale._mapping)

    items_row = await db.execute(text("""
        SELECT si.*, p.name as product_name, p.unit
        FROM sale_items si JOIN products p ON p.id = si.product_id
        WHERE si.sale_id = :id ORDER BY si.id
    """), {"id": sale_id})
    items = [dict(r._mapping) for r in items_row.fetchall()]

    is_q = sale['status'] == 'quotation'
    is_return = sale['status'] == 'returned'

    if is_return:
        doc_label = "مستند مرتجع"
        orig_inv = None
        if str(sale['invoice_number']).startswith("RET-"):
            for ln in (sale.get('notes') or '').split(','):
                if 'مرتجع جزئي من' in ln:
                    orig_inv = ln.split('مرتجع جزئي من')[-1].strip()
                    break
        else:
            orig_inv = sale['invoice_number']

        subtotal = sum(float(i['qty']) * float(i['unit_price']) - float(i.get('discount',0)) for i in items)
        total = subtotal

        rows_html = ""
        for idx, it in enumerate(items, 1):
            line = float(it['qty']) * float(it['unit_price']) - float(it.get('discount',0))
            rows_html += f"""<tr>
              <td style="color:#9ca3af;font-size:9px;text-align:center;white-space:nowrap">{idx}</td>
              <td><div class="td-name">{it['product_name']}</div></td>
              <td style="text-align:center;white-space:nowrap;color:#374151">{ar_egp(float(it['unit_price']))}</td>
              <td style="text-align:center;white-space:nowrap;color:#374151">{ar_num(float(it['qty']), 0)}</td>
              <td style="text-align:center;white-space:nowrap;color:#6b7280">{it.get('unit','')}</td>
              <td style="text-align:left;white-space:nowrap">{ar_egp(line)}</td>
            </tr>"""

        customer_name = sale.get('customer_name') or 'عميل نقدي'
        customer_detail = '  ·  '.join(filter(None, [sale.get('customer_phone',''), sale.get('customer_address','')]))

        pmt_html = ""
        if sale.get('is_credit') or sale.get('payment_method') == 'credit':
            net = float(sale.get('net_total', 0))
            paid = float(sale.get('paid_amount', 0))
            pmt_html = f"""
            <div style="margin-top:8px;border:1px solid #e2e8f0;border-radius:6px;padding:8px 12px;background:#f8fafc">
              <div style="font-size:9px;font-weight:700;color:#475569;margin-bottom:4px">ملخص الدفع</div>
              <table style="width:100%;border-collapse:collapse;font-size:10px">
                <tr><td style="padding:2px 0;color:#555">طريقة الدفع</td><td style="font-weight:700;text-align:left">آجل</td></tr>
                <tr><td style="padding:2px 0;color:#555">المدفوع</td><td style="font-weight:700;text-align:left;color:#16a34a">{ar_egp(paid)}</td></tr>
                <tr><td style="padding:2px 0;color:#555">المتبقي</td><td style="font-weight:700;text-align:left;color:#dc2626">{ar_egp(max(0, net - paid))}</td></tr>
              </table>
            </div>"""

        emp = sale.get('created_by_name') or sale.get('cashier_name') or '—'
        now = datetime.now().strftime('%d/%m/%Y  %I:%M %p').replace('AM', 'ص').replace('PM', 'م')
        header_meta = f"""
        <div style="font-size:9px;color:#6b7280;text-align:left;margin-bottom:6px;line-height:1.6">
          التاريخ: {fmt_dt(sale['created_at'])} &nbsp;|&nbsp; الموظف: {emp}
          {f'&nbsp;|&nbsp; الفاتورة الأصلية: {orig_inv}' if orig_inv else ''}
        </div>"""

        body = f"""
{top_band(store, doc_label, sale['invoice_number'], fmt_date(sale['created_at']))}
<div class="body">
  {header_meta}
  <table style="width:100%;border-collapse:collapse;margin-bottom:6px">
    <tr>
      <td style="width:100%;padding:6px 10px;border:1px solid #ccc;border-right:2px solid #111;vertical-align:top">
        <div class="party-label">العميل</div>
        <div class="party-name">{customer_name}</div>
        {f'<div class="party-detail">{customer_detail}</div>' if customer_detail else ''}
      </td>
    </tr>
  </table>
  <div class="tbl-label">الأصناف المرتجعة</div>
  <table>
    <thead><tr>
      <th style="text-align:center;white-space:nowrap">#</th>
      <th style="width:100%">اسم الصنف</th>
      <th style="text-align:center;white-space:nowrap">سعر الوحدة</th>
      <th style="text-align:center;white-space:nowrap">الكمية</th>
      <th style="text-align:center;white-space:nowrap">الوحدة</th>
      <th style="text-align:left;white-space:nowrap">الإجمالي</th>
    </tr></thead>
    <tbody>{rows_html}</tbody>
  </table>
  {pmt_html}
  <div class="totals-section" style="margin-top:6px">
    <table style="border-collapse:collapse;border:1px solid #ccc;width:auto">
      <tr style="background:#111">
        <td style="padding:6px 12px;font-size:10px;font-weight:600;color:rgba(255,255,255,.7);white-space:nowrap">إجمالي المرتجع</td>
        <td style="padding:6px 12px;font-size:13px;font-weight:900;color:#fff;white-space:nowrap;text-align:left">{ar_egp(total)}</td>
      </tr>
    </table>
  </div>
  <div class="sale-footer-info"><table style="width:100%;border-collapse:collapse;font-size:inherit"><tr><td style="text-align:right;white-space:nowrap;padding:2pt 0">طُبع: {now}</td><td style="text-align:left;white-space:nowrap;padding:2pt 0">{'  '.join(c.get('name','') + ': ' + c.get('phone','') for c in store.get('contacts',[]) if c.get('phone'))}</td></tr></table></div>
</div>"""
        return HTMLResponse(wrap(body, f"{doc_label} — {sale['invoice_number']}"))

    doc_label = "عرض سعر" if is_q else "فاتورة مبيعات"
    "جملة" if sale.get('sale_mode') == 'wholesale' else "قطاعي"
    st_map = {"confirmed": ("مؤكدة","b-green"), "quotation": ("عرض سعر","b-yellow"),
              "returned": ("مرتجعة","b-red"), "cancelled": ("ملغاة","b-red")}
    st_lbl, st_cls = st_map.get(sale['status'], (sale['status'], "b-blue"))

    subtotal = sum(float(i['qty']) * float(i['unit_price']) - float(i.get('discount',0)) for i in items)
    disc = float(sale.get('discount_amount', 0))
    total = subtotal - disc

    rows_html = ""
    for idx, it in enumerate(items, 1):
        line = float(it['qty']) * float(it['unit_price']) - float(it.get('discount',0))
        rows_html += f"""<tr>
          <td style="color:#9ca3af;font-size:9px;text-align:center;white-space:nowrap">{idx}</td>
          <td><div class="td-name">{it['product_name']}</div></td>
          <td style="text-align:center;white-space:nowrap;color:#374151">{ar_egp(float(it['unit_price']))}</td>
          <td style="text-align:center;white-space:nowrap;color:#374151">{ar_num(float(it['qty']), 0)}</td>
          <td style="text-align:center;white-space:nowrap;color:#6b7280">{it.get('unit','')}</td>
          {f'<td style="text-align:center;white-space:nowrap;color:#dc2626">({ar_egp(float(it["discount"]))})</td>' if float(it.get('discount',0)) else ''}
          <td style="text-align:left;white-space:nowrap">{ar_egp(line)}</td>
        </tr>"""

    customer_name = sale.get('customer_name') or 'عميل نقدي'
    customer_detail = '  ·  '.join(filter(None, [sale.get('customer_phone',''), sale.get('customer_address','')]))

    body = f"""
{top_band(store, doc_label, sale['invoice_number'], fmt_date(sale['created_at']))}
<div class="body">
  <table style="width:100%;border-collapse:collapse;margin-bottom:6px">
    <tr>
      <td style="width:42%;padding:6px 10px;border:1px solid #ccc;border-right:2px solid #111;vertical-align:top">
        <div class="party-label">{'عرض سعر لـ' if is_q else 'فاتورة إلى'}</div>
        <div class="party-name">{customer_name}</div>
        {f'<div class="party-detail">{customer_detail}</div>' if customer_detail else ''}
      </td>
      <td style="width:42%;padding:6px 10px;border:1px solid #ccc;border-right:none;vertical-align:top">
        <div class="party-label">صادرة من</div>
        <div class="party-name">{sale.get('warehouse_name','—')}</div>
        <div class="party-detail">{store['name']}</div>
      </td>
      <td style="width:16%;padding:6px 10px;border:1px solid #ccc;border-right:none;vertical-align:middle;text-align:center">
        <div class="party-label">الحالة</div>
        <div style="margin-top:3px"><span class="badge {st_cls}">{st_lbl}</span></div>
      </td>
    </tr>
  </table>
  <div class="tbl-label">بيان الأصناف</div>
  <table>
    <thead><tr>
      <th style="text-align:center;white-space:nowrap">#</th>
      <th style="width:100%">اسم الصنف</th>
      <th style="text-align:center;white-space:nowrap">سعر الوحدة</th>
      <th style="text-align:center;white-space:nowrap">الكمية</th>
      <th style="text-align:center;white-space:nowrap">الوحدة</th>
      <th style="text-align:center;white-space:nowrap">الخصم</th>
      <th style="text-align:left;white-space:nowrap">الإجمالي</th>
    </tr></thead>
    <tbody>{rows_html}</tbody>
  </table>
  {f'<div class="notes-box"><div class="n-lbl">ملاحظات</div><div class="n-txt">{sale["notes"]}</div></div>' if sale.get('notes') else ''}
  <div class="totals-section" style="margin-top:6px">
    <table style="border-collapse:collapse;border:1px solid #ccc;width:auto">
      <tr>
        <td style="padding:4px 12px;font-size:10px;border-bottom:1px solid #e8e8e8;color:#555;white-space:nowrap">المجموع الفرعي</td>
        <td style="padding:4px 12px;font-size:10px;border-bottom:1px solid #e8e8e8;font-weight:700;white-space:nowrap;min-width:90px;text-align:left">{ar_egp(subtotal)}</td>
      </tr>
      {f'<tr><td style="padding:4px 12px;font-size:10px;border-bottom:1px solid #e8e8e8;color:#555;white-space:nowrap">الخصم{f" ({round(disc/subtotal*100, 1):.1f}%)" if subtotal > 0 else ""}</td><td style="padding:4px 12px;font-size:10px;border-bottom:1px solid #e8e8e8;font-weight:700;white-space:nowrap;color:#dc2626;text-align:left">({ar_egp(disc)})</td></tr>' if disc else ''}
      <tr style="background:#111">
        <td style="padding:6px 12px;font-size:10px;font-weight:600;color:rgba(255,255,255,.7);white-space:nowrap">الإجمالي</td>
        <td style="padding:6px 12px;font-size:13px;font-weight:900;color:#fff;white-space:nowrap;text-align:left">{ar_egp(total)}</td>
      </tr>
    </table>
  </div>
  <div class="sale-footer-info"><table style="width:100%;border-collapse:collapse;font-size:inherit"><tr><td style="text-align:right;white-space:nowrap;padding:2pt 0">{(sale.get('created_by_name','') + ' · ' if sale.get('created_by_name') else '') + fmt_dt(sale['created_at'])}</td><td style="text-align:left;white-space:nowrap;padding:2pt 0">{'  '.join(c.get('name','') + ': ' + c.get('phone','') for c in store.get('contacts',[]) if c.get('phone'))}</td></tr></table></div>
</div>"""
    return HTMLResponse(wrap(body, f"{doc_label} — {sale['invoice_number']}"))


@router.get("/pdf/sale/{sale_id}")
async def pdf_sale(sale_id: uuid.UUID, paper_size: str = None,
                   db: AsyncSession = Depends(get_db), user=Depends(get_print_user)):
    html_resp = await print_sale(sale_id, db, user)
    return await _make_pdf(html_resp, "فاتورة مبيعات", f"sale_{sale_id}.pdf", db, paper_size)
