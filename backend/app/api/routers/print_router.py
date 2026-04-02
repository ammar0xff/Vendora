"""Central print system."""
from fastapi import APIRouter, Depends, Query
from fastapi.responses import HTMLResponse, Response
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from app.db.base import get_db
from app.dependencies import get_print_user
from datetime import datetime
import uuid

router = APIRouter(prefix="/print", tags=["print"])


async def get_settings(db):
    import json as _json
    rows = await db.execute(text("SELECT key, value FROM store_settings"))
    out = {}
    for r in rows.fetchall():
        try:
            out[r.key] = _json.loads(r.value) if r.value and r.value.startswith(('[', '{')) else r.value
        except Exception:
            out[r.key] = r.value
    return out


def ar_num(n, decimals=2):
    """Format number with Arabic-Indic digits."""
    try:
        n = float(n)
        # Format with commas
        formatted = f'{n:,.{decimals}f}'
        # Convert Western digits to Arabic-Indic
        arabic = str.maketrans('0123456789', '٠١٢٣٤٥٦٧٨٩')
        return formatted.translate(arabic)
    except:
        return str(n)

def ar_egp(n, decimals=2):
    return f'{ar_num(n, decimals)} ج.م'

def fmt_date(v):
    try: return datetime.fromisoformat(str(v)).strftime('%d / %m / %Y')
    except: return str(v) if v else ''

def fmt_dt(v):
    try:
        dt = datetime.fromisoformat(str(v))
        return dt.strftime('%d/%m/%Y  %I:%M %p').replace('AM','ص').replace('PM','م')
    except: return str(v) if v else ''

def css():
    return """
<style>
@import url('https://fonts.googleapis.com/css2?family=Cairo:wght@300;400;500;600;700;800;900&display=swap');
*{margin:0;padding:0;box-sizing:border-box}
html,body{background:#e8e8e8;font-family:'Cairo',sans-serif;direction:rtl;color:#111;font-size:10px}

.sheet{
  width:210mm;min-height:297mm;margin:6mm auto;
  background:#fff;
  box-shadow:0 2px 12px rgba(0,0,0,.15);
  display:flex;flex-direction:column;
}

/* ── HEADER ── */
.top-band{
  padding:10px 16px;
  display:flex;justify-content:space-between;align-items:center;
  border-bottom:2px solid #111;
}
.brand{display:flex;align-items:center;gap:8px}
.brand-logo{width:36px;height:36px;object-fit:contain;flex-shrink:0}
.brand-initials{
  width:36px;height:36px;
  background:#111;display:flex;align-items:center;justify-content:center;
  font-size:14px;font-weight:900;color:#fff;flex-shrink:0;
}
.brand-text .co-name{font-size:13px;font-weight:900;color:#111;line-height:1.2}
.brand-text .co-sub{font-size:9px;color:#666;margin-top:1px}

.doc-id{text-align:left}
.doc-id .doc-type{font-size:8px;font-weight:700;color:#666;letter-spacing:1.5px;text-transform:uppercase;margin-bottom:2px}
.doc-id .doc-num{font-size:16px;font-weight:900;color:#111}
.doc-id .doc-date{font-size:9px;color:#666;margin-top:1px}

.ribbon{height:2px;background:#111}

/* ── BODY ── */
.body{padding:12px 16px;flex:1;display:flex;flex-direction:column}

/* ── PARTIES ── */
.parties{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:10px}
.party-card{padding:7px 10px;border:1px solid #ccc}
.party-card.buyer{border-right:2px solid #111}
.party-label{font-size:7px;font-weight:700;color:#999;text-transform:uppercase;letter-spacing:1px;margin-bottom:3px}
.party-name{font-size:11px;font-weight:800;color:#111}
.party-detail{font-size:9px;color:#555;margin-top:2px;line-height:1.4}

/* ── META ROW ── */
.meta-row{display:flex;gap:0;margin-bottom:10px;border:1px solid #ccc}
.meta-cell{flex:1;padding:5px 8px;border-left:1px solid #ccc}
.meta-cell:last-child{border-left:none}
.meta-cell .m-lbl{font-size:7px;font-weight:700;color:#999;text-transform:uppercase;letter-spacing:.8px;margin-bottom:2px}
.meta-cell .m-val{font-size:10px;font-weight:700;color:#111}
.badge{display:inline-block;padding:1px 5px;font-size:8px;font-weight:700;border:1px solid currentColor}
.b-green{color:#166534;border-color:#166534}
.b-yellow{color:#854d0e;border-color:#854d0e}
.b-red{color:#991b1b;border-color:#991b1b}
.b-blue{color:#1e40af;border-color:#1e40af}

/* ── TABLE ── */
.tbl-label{font-size:8px;font-weight:700;color:#666;text-transform:uppercase;letter-spacing:.8px;margin-bottom:4px}
table{width:100%;border-collapse:collapse;border:1px solid #ccc;table-layout:auto}
thead tr{background:#111}
thead th{padding:5px 7px;color:#fff;font-size:9px;font-weight:700;text-align:right;white-space:nowrap}
thead th:last-child{text-align:left}
tbody tr{border-bottom:1px solid #e8e8e8}
tbody tr:last-child{border-bottom:none}
tbody tr:nth-child(even){background:#f9f9f9}
tbody td{padding:5px 7px;font-size:10px;vertical-align:middle}
tbody td:last-child{text-align:left;font-weight:700;white-space:nowrap}
.td-name{font-weight:600;color:#111;word-break:break-word}
.td-sub{font-size:8px;color:#999;margin-top:1px}
/* Fixed-width columns — only name column stretches */
.col-num{width:24px;text-align:center!important;color:#999;font-size:9px}
.col-price,.col-qty,.col-unit,.col-total{white-space:nowrap;width:1%}

/* ── TOTALS ── */
.totals-section{display:flex;justify-content:flex-end;margin-top:10px}
.totals-box{min-width:200px;border:1px solid #ccc}
.t-line{display:flex;justify-content:space-between;padding:4px 10px;border-bottom:1px solid #e8e8e8;font-size:10px}
.t-line:last-child{border-bottom:none}
.t-lbl{color:#555}
.t-val{font-weight:700;color:#111;white-space:nowrap}
.t-val.neg{color:#991b1b}
.t-grand{padding:8px 12px;background:#111;display:flex;justify-content:space-between;align-items:center}
.t-grand .t-lbl{color:rgba(255,255,255,.7);font-size:10px;font-weight:600}
.t-grand .t-val{color:#fff;font-size:15px;font-weight:900}

/* ── NOTES ── */
.notes-box{margin-top:10px;padding:7px 10px;border-right:2px solid #111;background:#f9f9f9}
.notes-box .n-lbl{font-size:8px;font-weight:700;color:#111;margin-bottom:3px}
.notes-box .n-txt{font-size:10px;color:#333;line-height:1.5}

/* ── FOOTER ── */
.doc-footer{
  border-top:2px solid #111;
  padding:10px 16px;
  display:grid;grid-template-columns:1fr auto 1fr;
  align-items:end;gap:12px;
  background:#f9f9f9;
}
.sig{text-align:center}
.sig .sig-name{font-size:9px;font-weight:700;color:#333;margin-bottom:22px}
.sig .sig-line{border-top:1px solid #999;padding-top:5px;font-size:8px;color:#999}
.footer-mid{text-align:center}
.stamp-circle{
  width:50px;height:50px;border-radius:50%;
  border:1px dashed #ccc;
  display:flex;align-items:center;justify-content:center;
  margin:0 auto 5px;font-size:8px;color:#ccc;
}
.footer-meta{font-size:8px;color:#999;line-height:1.7;margin-top:2px}

/* ── PRINT ── */
@media print{
  *{-webkit-print-color-adjust:exact;print-color-adjust:exact}
  html,body{background:white}
  .sheet{margin:0;box-shadow:none;width:100%;min-height:unset;display:block}
  .no-print{display:none!important}
  tr{page-break-inside:avoid;break-inside:avoid}
  thead{display:table-header-group}
  .parties,.meta-row,.doc-footer,.totals-section{page-break-inside:avoid;break-inside:avoid}
  @page{margin:8mm 6mm;size:A4}
}
.fab{
  position:fixed;bottom:16px;left:16px;
  background:#111;color:white;border:none;
  padding:8px 18px;
  font-family:'Cairo',sans-serif;font-size:12px;font-weight:700;
  cursor:pointer;box-shadow:0 2px 10px rgba(0,0,0,.3);
  display:flex;align-items:center;gap:6px;z-index:999;
}
</style>"""


def pdf_css(paper_size="A4"):
    is_a5 = paper_size.upper() == "A5"
    f = lambda a4, a5: a5 if is_a5 else a4

    return f"""
<style>
@page {{
  size: {paper_size};
  margin: {f("12mm","8mm")} {f("10mm","7mm")} {f("14mm","10mm")} {f("10mm","7mm")};
  margin-top: calc({f("12mm","8mm")} + {f("16mm","12mm")});

  @top-left {{
    content: element(pdf-running-header);
    width: 100%;
  }}
  @bottom-center {{
    content: "";
  }}
  @bottom-right {{
    content: "";
  }}
}}

.pdf-running-header {{
  position: running(pdf-running-header);
  width: 100%;
  background: #111;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: {f("5pt","4pt")} {f("10pt","7pt")};
  font-family: 'Cairo', sans-serif;
}}
.pdf-running-header .rh-brand {{ color: #fff; font-size: {f("10pt","8pt")}; font-weight: 900; }}
.pdf-running-header .rh-doc   {{ color: #ccc; font-size: {f("9pt","7pt")}; font-weight: 600; text-align: left; }}

.pdf-doc-number {{ string-set: doc-number-str content(); position: absolute; visibility: hidden; }}
.pdf-doc-title  {{ string-set: doc-title-str  content(); position: absolute; visibility: hidden; }}
.sale-footer-info {{ font-family: 'Cairo', sans-serif; font-size: {f("7pt","6pt")}; color: #333; }}

html, body {{ background: white !important; font-family: 'Cairo', sans-serif; direction: rtl; }}
.sheet {{ box-shadow: none !important; margin: 0 !important; width: 100% !important; min-height: 0 !important; height: auto !important; display: block !important; }}
.body  {{ flex: none !important; }}
.top-band {{ display: none !important; }}
.ribbon   {{ display: none !important; }}
.no-print, .fab {{ display: none !important; }}

{"" if not is_a5 else """
body { font-size: 7pt; }
.party-name { font-size: 9pt !important; }
.party-detail, .party-label { font-size: 7pt !important; }
.meta-cell .m-lbl { font-size: 6pt !important; }
.meta-cell .m-val { font-size: 8pt !important; }
.tbl-label { font-size: 6pt !important; }
thead th { font-size: 7pt !important; padding: 3px 5px !important; }
tbody td { font-size: 7pt !important; padding: 3px 5px !important; }
.td-sub { font-size: 6pt !important; }
.t-line { font-size: 8pt !important; padding: 3px 8px !important; }
.t-grand .t-val { font-size: 12pt !important; }
.totals-box { min-width: 150px !important; }
.sig .sig-name { font-size: 7pt !important; margin-bottom: 16px !important; }
.footer-meta { font-size: 6pt !important; }
.stamp-circle { width: 40px !important; height: 40px !important; }
.body { padding: 10px 12px !important; }
.parties { margin-bottom: 7px !important; gap: 6px !important; }
.meta-row { margin-bottom: 7px !important; }
.doc-footer { padding: 7px 12px !important; }
"""}

table {{ page-break-inside: auto; width: 100%; }}
tr    {{ page-break-inside: avoid; break-inside: avoid; }}
thead {{ display: table-header-group; }}
tfoot {{ display: table-footer-group; }}
.parties, .meta-row, .doc-footer, .totals-section {{ page-break-inside: avoid; break-inside: avoid; }}
.doc-footer {{ margin-top: 10pt; }}
</style>"""


def wrap(body, title="مستند"):
    return f"""<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<title>{title}</title>
{css()}
</head>
<body>
<div class="sheet">
{body}
</div>
<button class="fab no-print" onclick="window.print()">🖨️ طباعة</button>
</body>
</html>"""


def wrap_pdf(body, title="مستند", paper_size="A4", company_name="EG-CO", doc_number=""):
    """HTML wrapper optimised for WeasyPrint — running header/footer on every page."""
    return f"""<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta charset="UTF-8"/>
<title>{title}</title>
{css()}
{pdf_css(paper_size)}
</head>
<body>
<div class="pdf-running-header">
  <span class="rh-brand">{company_name}</span>
  <span class="rh-doc">{title}</span>
</div>
<span class="pdf-doc-number">{doc_number}</span>
<span class="pdf-doc-title">{title}</span>
{body}
</body>
</html>"""


async def html_to_pdf(html: str, zoom: float = 1.0) -> bytes:
    from weasyprint import HTML as WP
    return WP(string=html, base_url=None).write_pdf(zoom=zoom)


async def get_paper_size(db, override: str = None) -> str:
    if override:
        return override
    row = await db.execute(text("SELECT value FROM store_settings WHERE key='paper_size'"))
    val = row.scalar()
    if val:
        import json as _j
        try:
            return _j.loads(val)
        except Exception:
            return val
    return "A4"


def top_band(store, doc_type_label, doc_number, date_str):
    logo = store.get('logo_url','')
    logo_html = (f'<img src="{logo}" class="brand-logo"/>'
                 if logo else
                 f'<div class="brand-initials">{(store.get("name") or "م")[0]}</div>')
    sub_parts = [p for p in [store.get('address',''), store.get('phone','')] if p]
    contacts = store.get('contacts') or []
    return f"""
<div class="top-band">
  <div class="brand">
    {logo_html}
    <div class="brand-text">
      <div class="co-name">{store.get('name','')}</div>
      <div class="co-sub">{'  ·  '.join(sub_parts)}</div>
    </div>
  </div>
  <div class="doc-id">
    <div class="doc-type">{doc_type_label}</div>
    <div class="doc-num">{doc_number}</div>
    <div class="doc-date">{date_str}</div>
  </div>
</div>
<div class="ribbon"></div>"""


@router.get("/sale/{sale_id}", response_class=HTMLResponse)
async def print_sale(sale_id: uuid.UUID, token: str = Query(None),
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
    if not sale: return HTMLResponse("Not found", 404)
    sale = dict(sale._mapping)

    items_row = await db.execute(text("""
        SELECT si.*, p.name as product_name, p.unit
        FROM sale_items si JOIN products p ON p.id = si.product_id
        WHERE si.sale_id = :id ORDER BY si.id
    """), {"id": sale_id})
    items = [dict(r._mapping) for r in items_row.fetchall()]

    is_q = sale['status'] == 'quotation'
    doc_label = "عرض سعر" if is_q else "فاتورة مبيعات"
    mode_label = "جملة" if sale.get('sale_mode') == 'wholesale' else "قطاعي"
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
          {f'<td style="text-align:center;white-space:nowrap;color:#dc2626">({ar_egp(float(it["discount"]))})</td>' if disc else ''}
          <td style="text-align:left;white-space:nowrap">{ar_egp(line)}</td>
        </tr>"""

    totals_html = f"""
    <div class="t-line"><span class="t-lbl">المجموع الفرعي</span><span class="t-val">{ar_egp(subtotal)}</span></div>
    {f'<div class="t-line"><span class="t-lbl">الخصم</span><span class="t-val neg">({ar_egp(disc)})</span></div>' if disc else ''}
    <div class="t-grand"><span class="t-lbl">الإجمالي</span><span class="t-val">{ar_egp(total)}</span></div>"""

    customer_name = sale.get('customer_name') or 'عميل نقدي'
    customer_detail = '  ·  '.join(filter(None, [sale.get('customer_phone',''), sale.get('customer_address','')]))

    body = f"""
{top_band(store, doc_label, sale['invoice_number'], fmt_date(sale['created_at']))}

<div class="body">

  <table style="width:100%;border-collapse:collapse;margin-bottom:6px">
    <tr>
      <td style="width:42%;padding:6px 10px;border:1px solid #ccc;border-right:2px solid #111;vertical-align:top">
        <div class="party-label">فاتورة إلى</div>
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
      {f'<th style="text-align:center;white-space:nowrap">الخصم</th>' if disc else ''}
      <th style="text-align:left;white-space:nowrap">الإجمالي</th>
    </tr></thead>
    <tbody>{rows_html}</tbody>
  </table>

  {f'<div class="notes-box"><div class="n-lbl">ملاحظات</div><div class="n-txt">{sale["notes"]}</div></div>' if sale.get('notes') else ''}

  <div style="margin-top:6px;display:flex;justify-content:flex-end">
    <table style="border-collapse:collapse;border:1px solid #ccc;width:auto">
      <tr>
        <td style="padding:4px 12px;font-size:10px;border-bottom:1px solid #e8e8e8;color:#555;white-space:nowrap">المجموع الفرعي</td>
        <td style="padding:4px 12px;font-size:10px;border-bottom:1px solid #e8e8e8;font-weight:700;white-space:nowrap;min-width:90px;text-align:left">{ar_egp(subtotal)}</td>
      </tr>
      {f'<tr><td style="padding:4px 12px;font-size:10px;border-bottom:1px solid #e8e8e8;color:#555;white-space:nowrap">الخصم</td><td style="padding:4px 12px;font-size:10px;border-bottom:1px solid #e8e8e8;font-weight:700;white-space:nowrap;text-align:left">({ar_egp(disc)})</td></tr>' if disc else ''}
      <tr style="background:#111">
        <td style="padding:6px 12px;font-size:10px;font-weight:600;color:rgba(255,255,255,.7);white-space:nowrap">الإجمالي</td>
        <td style="padding:6px 12px;font-size:13px;font-weight:900;color:#fff;white-space:nowrap;text-align:left">{ar_egp(total)}</td>
      </tr>
    </table>
  </div>

</div>

<div class="sale-footer-info"><table style="width:100%;border-collapse:collapse;font-size:inherit;border-top:1px solid #ccc;padding-top:4pt"><tr><td style="text-align:right;white-space:nowrap;padding:4pt 0 2pt">{(sale.get('created_by_name','') + ' · ' if sale.get('created_by_name') else '') + fmt_dt(sale['created_at'])}</td><td style="text-align:left;white-space:nowrap;padding:4pt 0 2pt">{'  '.join(c.get('name','') + ': ' + c.get('phone','') for c in store.get('contacts',[]) if c.get('phone'))}</td></tr><tr><td colspan="2" style="text-align:center;color:#888;font-size:90%;padding-bottom:2pt">{doc_label} · {sale['invoice_number']} · صفحة 1 من 1</td></tr></table></div>"""

    return HTMLResponse(wrap(body, f"{doc_label} — {sale['invoice_number']}"))
    return HTMLResponse(wrap(body, f"{doc_label} — {sale['invoice_number']}"))


@router.get("/dispatch/{doc_number}", response_class=HTMLResponse)
async def print_dispatch(doc_number: str, token: str = Query(None),
                         db: AsyncSession = Depends(get_db), _=Depends(get_print_user)):
    s = await get_settings(db)
    store = {"name": s.get("store_name",""), "address": s.get("store_address",""),
             "phone": s.get("store_phone",""), "logo_url": s.get("logo_url",""),
             "contacts": s.get("contact_phones") or []}
    row = await db.execute(text("SELECT * FROM archived_documents WHERE doc_number=:n"), {"n": doc_number})
    doc = row.fetchone()
    if not doc: return HTMLResponse("Not found", 404)
    doc = dict(doc._mapping)
    _raw_meta = doc.get('metadata_') or doc.get('metadata') or {}
    if isinstance(_raw_meta, str):
        import json as _json
        try: meta = _json.loads(_raw_meta)
        except: meta = {}
    else:
        meta = _raw_meta or {}
    items = meta.get('items', [])

    rows_html = ""
    for idx, it in enumerate(items, 1):
        rows_html += f"""<tr>
          <td style="color:#9ca3af;font-size:9px;text-align:center;white-space:nowrap">{idx}</td>
          <td><div class="td-name">{it.get('product_name', it.get('product_id',''))}</div></td>
          <td style="text-align:center;width:100px;color:#374151">{float(it.get('qty',0)):g} {it.get('unit','')}</td>
          <td style="color:#6b7280;font-size:11px">{it.get('note','')}</td>
        </tr>"""

    body = f"""
{top_band(store, "إذن صرف بضاعة", doc_number, fmt_date(doc['created_at']))}
<div class="body">
  <div class="parties">
    <div class="party-card buyer">
      <div class="party-label">من مخزن</div>
      <div class="party-name">{meta.get('from_warehouse','—')}</div>
    </div>
    <div class="party-card">
      <div class="party-label">إلى مخزن</div>
      <div class="party-name">{meta.get('to_warehouse','—')}</div>
    </div>
  </div>
  <div class="tbl-label">الأصناف المُصرَفة</div>
  <table>
    <thead><tr>
      <th style="width:36px;text-align:center">#</th><th>الصنف</th>
      <th style="text-align:center;width:100px">الكمية</th><th>ملاحظة</th>
    </tr></thead>
    <tbody>{rows_html}</tbody>
  </table>
</div>
<div class="doc-footer">
  <div class="sig"><div class="sig-name">توقيع المُسلِّم</div><div class="sig-line">الاسم والتوقيع</div></div>
  <div class="footer-mid"><div class="stamp-circle">الختم</div><div class="footer-meta">طُبع: {datetime.now().strftime('%Y/%m/%d  %H:%M')}</div></div>
  <div class="sig"><div class="sig-name">توقيع المُستلِم</div><div class="sig-line">الاسم والتوقيع</div></div>
</div>"""
    return HTMLResponse(wrap(body, f"إذن صرف — {doc_number}"))


@router.get("/handover/{doc_number}", response_class=HTMLResponse)
async def print_handover(doc_number: str, token: str = Query(None),
                         db: AsyncSession = Depends(get_db), _=Depends(get_print_user)):
    s = await get_settings(db)
    store = {"name": s.get("store_name",""), "address": s.get("store_address",""),
             "phone": s.get("store_phone",""), "logo_url": s.get("logo_url",""),
             "contacts": s.get("contact_phones") or []}
    row = await db.execute(text("SELECT * FROM archived_documents WHERE doc_number=:n"), {"n": doc_number})
    doc = row.fetchone()
    if not doc: return HTMLResponse("Not found", 404)
    doc = dict(doc._mapping)
    _raw_meta = doc.get('metadata_') or doc.get('metadata') or {}
    if isinstance(_raw_meta, str):
        import json as _json
        try: meta = _json.loads(_raw_meta)
        except: meta = {}
    else:
        meta = _raw_meta or {}
    amount = float(doc.get('amount', 0))
    shift_id = doc.get('ref_id')

    # Fetch full shift data
    shift_row = await db.execute(text("""
        SELECT s.*, w.name as warehouse_name, u.full_name as cashier_name
        FROM shifts s
        LEFT JOIN warehouses w ON w.id = s.warehouse_id
        LEFT JOIN users u ON u.id = s.cashier_id
        WHERE s.id = :id
    """), {"id": shift_id}) if shift_id else None
    shift = dict(shift_row.fetchone()._mapping) if shift_row else {}

    # Fetch all sales during this shift
    sales_rows = await db.execute(text("""
        SELECT sa.id, sa.invoice_number, sa.sale_mode, sa.status, sa.created_at,
               c.name as customer_name,
               COALESCE(SUM(si.qty * si.unit_price - si.discount), 0) - sa.discount_amount as total_amount
        FROM sales sa
        LEFT JOIN customers c ON c.id = sa.customer_id
        LEFT JOIN sale_items si ON si.sale_id = sa.id
        WHERE sa.shift_id = :sid AND sa.status IN ('confirmed','returned')
        GROUP BY sa.id, c.name
        ORDER BY sa.created_at
    """), {"sid": shift_id}) if shift_id else None
    sales = [dict(r._mapping) for r in sales_rows.fetchall()] if sales_rows else []

    # Fetch drawer transactions
    txn_rows = await db.execute(text("""
        SELECT type, amount, note, created_at
        FROM drawer_transactions
        WHERE shift_id = :sid
        ORDER BY created_at
    """), {"sid": shift_id}) if shift_id else None
    txns = [dict(r._mapping) for r in txn_rows.fetchall()] if txn_rows else []

    # Compute totals
    total_sales = sum(float(s['total_amount'] or 0) for s in sales if s['status'] == 'confirmed')
    total_returns = sum(float(s['total_amount'] or 0) for s in sales if s['status'] == 'returned')
    total_expenses = sum(float(t['amount']) for t in txns if t['type'] == 'expense')
    total_deposits = sum(float(t['amount']) for t in txns if t['type'] == 'deposit')
    expected = float(shift.get('initial_amount') or 0) + total_sales - total_returns - total_expenses

    # Fetch items for each sale
    sale_items_map = {}
    if sales and shift_id:
        sale_ids = [str(s['id']) for s in sales]
        items_data = await db.execute(text("""
            SELECT si.sale_id, p.name as product_name, p.unit,
                   si.qty, si.unit_price, (si.qty * si.unit_price - si.discount) as line_total
            FROM sale_items si JOIN products p ON p.id = si.product_id
            WHERE si.sale_id = ANY(:ids)
            ORDER BY si.sale_id, si.id
        """), {"ids": sale_ids})
        for row in items_data.fetchall():
            r = dict(row._mapping)
            sid = str(r['sale_id'])
            sale_items_map.setdefault(sid, []).append(r)

    # Build sales table rows with items
    sales_rows_html = ""
    for i, sale in enumerate(sales, 1):
        is_return = sale['status'] == 'returned'
        time_str = fmt_dt(sale['created_at']).split('  ')[1] if '  ' in fmt_dt(sale['created_at']) else ''
        items = sale_items_map.get(str(sale['id']), [])
        # Sale header row
        sales_rows_html += f"""<tr style="background:{'#fff5f5' if is_return else '#f0f4ff'}">
          <td style="color:#9ca3af;font-size:11px;text-align:center;border-bottom:none">{i}</td>
          <td style="border-bottom:none"><div class="td-name">{sale['invoice_number']}</div></td>
          <td style="color:#6b7280;border-bottom:none">{sale.get('customer_name') or 'نقدي'}</td>
          <td style="text-align:center;color:#6b7280;border-bottom:none">{time_str}</td>
          <td style="text-align:left;{'color:#dc2626' if is_return else 'color:#1e3a5f'};font-weight:700;border-bottom:none">
            {ar_egp(float(sale['total_amount'] or 0))}{'  ↩ مرتجع' if is_return else ''}
          </td>
        </tr>"""
        # Item detail rows
        for item in items:
            sales_rows_html += f"""<tr style="background:{'#fff5f5' if is_return else '#fafbff'}">
              <td style="color:#9ca3af;font-size:10px;text-align:center;padding:4px 14px"></td>
              <td colspan="2" style="padding:4px 14px;font-size:11px;color:#374151;padding-right:28px">
                ↳ {item['product_name']}
              </td>
              <td style="text-align:center;font-size:11px;color:#6b7280;padding:4px 14px">{ar_num(float(item['qty']),0)} {item.get('unit','')}</td>
              <td style="text-align:left;font-size:11px;color:#6b7280;padding:4px 14px">{ar_egp(float(item['line_total']))}</td>
            </tr>"""

    # Build transactions rows
    txn_type_labels = {'sale': 'مبيعات', 'expense': 'مصروف', 'deposit': 'إيداع', 'return': 'مرتجع', 'withdrawal': 'سحب'}
    txn_rows_html = ""
    for t in txns:
        txn_rows_html += f"""<tr>
          <td style="color:#6b7280">{txn_type_labels.get(t['type'], t['type'])}</td>
          <td style="color:#6b7280">{t.get('note') or '—'}</td>
          <td style="text-align:center;color:#6b7280">{fmt_dt(t['created_at']).split('  ')[1] if '  ' in fmt_dt(t['created_at']) else ''}</td>
          <td style="text-align:left;font-weight:700;{'color:#dc2626' if t['type'] in ('expense','withdrawal') else 'color:#16a34a'}">
            {ar_egp(float(t['amount']))}
          </td>
        </tr>"""

    variance = amount - expected
    variance_color = '#dc2626' if variance < 0 else '#16a34a' if variance > 0 else '#6b7280'

    body = f"""
{top_band(store, "محضر تسليم عهدة الدرج", doc_number, fmt_dt(doc['created_at']))}
<div class="body">

  <div class="parties">
    <div class="party-card buyer">
      <div class="party-label">المُسلِّم</div>
      <div class="party-name">{meta.get('from_user_name', '—')}</div>
      {f'<div class="party-detail">{shift.get("warehouse_name","")}</div>' if shift.get('warehouse_name') else ''}
    </div>
    <div class="party-card">
      <div class="party-label">المُستلِم</div>
      <div class="party-name">{meta.get('to_user_name', '—')}</div>
    </div>
  </div>

  <div class="meta-row">
    <div class="meta-cell"><div class="m-lbl">بداية الوردية</div><div class="m-val">{fmt_dt(shift.get('started_at','')) if shift.get('started_at') else '—'}</div></div>
    <div class="meta-cell"><div class="m-lbl">نهاية الوردية</div><div class="m-val">{fmt_dt(doc['created_at'])}</div></div>
    <div class="meta-cell"><div class="m-lbl">رصيد الاستلام</div><div class="m-val">{ar_egp(float(shift.get('initial_amount') or 0))}</div></div>
    <div class="meta-cell"><div class="m-lbl">عدد الفواتير</div><div class="m-val">{ar_num(len([s for s in sales if s['status']=='confirmed']), 0)}</div></div>
  </div>

  {'<div class="tbl-label">سجل المبيعات</div><table><thead><tr><th style="width:36px;text-align:center">#</th><th>رقم الفاتورة</th><th>العميل</th><th style="text-align:center;width:80px">الوقت</th><th style="text-align:left;width:120px">المبلغ</th></tr></thead><tbody>' + sales_rows_html + '</tbody></table>' if sales else '<div style="text-align:center;padding:20px;color:#9ca3af;font-size:12px">لا توجد مبيعات في هذه الوردية</div>'}

  {'<div class="tbl-label" style="margin-top:20px">حركات الدرج</div><table><thead><tr><th>النوع</th><th>البيان</th><th style="text-align:center;width:80px">الوقت</th><th style="text-align:left;width:120px">المبلغ</th></tr></thead><tbody>' + txn_rows_html + '</tbody></table>' if txns else ''}

  <div style="margin-top:32px;page-break-before:auto;break-before:auto">
    <div style="page-break-inside:avoid;break-inside:avoid"><div class="summary-grid" style="display:grid;grid-template-columns:1fr 1fr 1fr 1fr;gap:12px;margin-bottom:20px">
      <div style="background:#f0fdf4;border:1.5px solid #94a3b8;border-radius:10px;padding:12px;text-align:center">
        <div style="font-size:10px;color:#6b7280;margin-bottom:4px">إجمالي المبيعات</div>
        <div style="font-size:16px;font-weight:900;color:#16a34a">{ar_egp(total_sales)}</div>
      </div>
      <div style="background:#fef2f2;border:1.5px solid #94a3b8;border-radius:10px;padding:12px;text-align:center">
        <div style="font-size:10px;color:#6b7280;margin-bottom:4px">المصروفات</div>
        <div style="font-size:16px;font-weight:900;color:#dc2626">{ar_egp(total_expenses)}</div>
      </div>
      <div style="background:#f0f9ff;border:1.5px solid #94a3b8;border-radius:10px;padding:12px;text-align:center">
        <div style="font-size:10px;color:#6b7280;margin-bottom:4px">الرصيد المتوقع</div>
        <div style="font-size:16px;font-weight:900;color:#1e3a5f">{ar_egp(expected)}</div>
      </div>
      <div style="background:#{'fef2f2' if variance < 0 else 'f0fdf4' if variance > 0 else 'f8fafc'};border:1.5px solid #94a3b8;border-radius:10px;padding:12px;text-align:center">
        <div style="font-size:10px;color:#6b7280;margin-bottom:4px">الفرق</div>
        <div style="font-size:16px;font-weight:900;color:{variance_color}">{ar_egp(abs(variance))} {'عجز' if variance < 0 else 'زيادة' if variance > 0 else 'متوازن'}</div>
      </div>
    </div>

    <div style="border:2px solid #1e3a5f;border-radius:12px;overflow:hidden">
      <div style="background:#1e3a5f;padding:14px 20px;display:flex;justify-content:space-between;align-items:center">
        <span style="color:rgba(255,255,255,.75);font-size:13px;font-weight:600">مبلغ العهدة المُسلَّمة</span>
        <span style="color:#fff;font-size:24px;font-weight:900">{ar_egp(amount)}</span>
      </div>
    </div>
  </div></div>

  {f'<div class="notes-box" style="margin-top:16px"><div class="n-lbl">ملاحظات</div><div class="n-txt">{meta.get("notes","")}</div></div>' if meta.get('notes') else ''}

</div>
<div class="doc-footer">
  <div class="sig"><div class="sig-name">توقيع المُسلِّم</div><div class="sig-line">الاسم والتوقيع</div></div>
  <div class="footer-mid"><div class="stamp-circle">الختم</div><div class="footer-meta">طُبع: {datetime.now().strftime('%Y/%m/%d  %H:%M')}</div></div>
  <div class="sig"><div class="sig-name">توقيع المُستلِم</div><div class="sig-line">الاسم والتوقيع</div></div>
</div>"""
    return HTMLResponse(wrap(body, f"تسليم عهدة — {doc_number}"))


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
    if not po: return HTMLResponse("Not found", 404)
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


@router.get("/archive/{doc_id}", response_class=HTMLResponse)
async def print_archive_doc(doc_id: uuid.UUID, token: str = Query(None),
                             db: AsyncSession = Depends(get_db), _=Depends(get_print_user)):
    """Generic print for any archived document."""
    s = await get_settings(db)
    store = {"name": s.get("store_name",""), "address": s.get("store_address",""),
             "phone": s.get("store_phone",""), "logo_url": s.get("logo_url",""),
             "contacts": s.get("contact_phones") or []}
    row = await db.execute(text("SELECT ad.*, u.full_name as created_by_name FROM archived_documents ad LEFT JOIN users u ON u.id = ad.created_by WHERE ad.id = :id"), {"id": doc_id})
    doc = row.fetchone()
    if not doc: return HTMLResponse("Not found", 404)
    doc = dict(doc._mapping)
    _raw_meta = doc.get('metadata_') or doc.get('metadata') or {}
    if isinstance(_raw_meta, str):
        import json as _json
        try: meta = _json.loads(_raw_meta)
        except: meta = {}
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

    # Build details from metadata
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


@router.get("/inventory/{warehouse_id}", response_class=HTMLResponse)
async def print_inventory(warehouse_id: uuid.UUID, token: str = Query(None),
                           db: AsyncSession = Depends(get_db), _=Depends(get_print_user)):
    s = await get_settings(db)
    store = {"name": s.get("store_name",""), "address": s.get("store_address",""),
             "phone": s.get("store_phone",""), "logo_url": s.get("logo_url",""),
             "contacts": s.get("contact_phones") or []}

    from sqlalchemy import text as sqlt
    wh_row = await db.execute(sqlt("SELECT name FROM warehouses WHERE id=:id"), {"id": warehouse_id})
    wh = wh_row.scalar() or str(warehouse_id)

    rows = await db.execute(sqlt("""
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
            rows_html += f'<tr style="background:#1e3a5f"><td colspan="7" style="color:white;font-weight:700;padding:8px 14px;font-size:12px">{current_cat}</td></tr>'
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



import re as _re

def _extract_body(html_response) -> str:
    """Extract inner body from wrap() HTMLResponse."""
    raw = html_response.body.decode('utf-8') if isinstance(html_response.body, bytes) else str(html_response.body)
    m = _re.search(r'<div class="sheet">(.*?)</div>\s*<button', raw, _re.DOTALL)
    return m.group(1) if m else raw

def _extract_meta(html_response) -> tuple[str, str]:
    """Extract (company_name, doc_number) from rendered HTML."""
    raw = html_response.body.decode('utf-8') if isinstance(html_response.body, bytes) else str(html_response.body)
    co = _re.search(r'class="co-name"[^>]*>([^<]+)<', raw)
    dn = _re.search(r'class="doc-num"[^>]*>([^<]+)<', raw)
    return (co.group(1).strip() if co else "EG-CO"), (dn.group(1).strip() if dn else "")

async def _make_pdf(html_response, title: str, filename: str, db, paper_size_override: str = None) -> Response:
    size = await get_paper_size(db, paper_size_override)
    body = _extract_body(html_response)
    company, doc_num = _extract_meta(html_response)
    pdf = await html_to_pdf(wrap_pdf(body, title, size, company, doc_num))
    return Response(content=pdf, media_type="application/pdf",
                    headers={"Content-Disposition": f"inline; filename={filename}"})


@router.get("/pdf/sale/{sale_id}")
async def pdf_sale(sale_id: uuid.UUID, paper_size: str = None, token: str = Query(None), db: AsyncSession = Depends(get_db), user=Depends(get_print_user)):
    return await _make_pdf(await print_sale(sale_id, token, db, user), "فاتورة", f"sale_{sale_id}.pdf", db, paper_size)


@router.get("/pdf/purchase/{po_id}")
async def pdf_purchase(po_id: uuid.UUID, paper_size: str = None, token: str = Query(None), db: AsyncSession = Depends(get_db), user=Depends(get_print_user)):
    return await _make_pdf(await print_purchase(po_id, token, db, user), "أمر شراء", f"purchase_{po_id}.pdf", db, paper_size)


@router.get("/pdf/dispatch/{doc_number}")
async def pdf_dispatch(doc_number: str, paper_size: str = None, token: str = Query(None), db: AsyncSession = Depends(get_db), user=Depends(get_print_user)):
    return await _make_pdf(await print_dispatch(doc_number, token, db, user), "إذن صرف", f"dispatch_{doc_number}.pdf", db, paper_size)


@router.get("/pdf/handover/{doc_number}")
async def pdf_handover(doc_number: str, paper_size: str = None, token: str = Query(None), db: AsyncSession = Depends(get_db), user=Depends(get_print_user)):
    return await _make_pdf(await print_handover(doc_number, token, db, user), "تسليم عهدة", f"handover_{doc_number}.pdf", db, paper_size)


@router.get("/pdf/archive/{doc_id}")
async def pdf_archive(doc_id: uuid.UUID, paper_size: str = None, token: str = Query(None), db: AsyncSession = Depends(get_db), user=Depends(get_print_user)):
    return await _make_pdf(await print_archive_doc(doc_id, token, db, user), "مستند أرشيف", f"archive_{doc_id}.pdf", db, paper_size)


@router.get("/pdf/inventory/{warehouse_id}")
async def pdf_inventory(warehouse_id: uuid.UUID, paper_size: str = None, token: str = Query(None), db: AsyncSession = Depends(get_db), user=Depends(get_print_user)):
    return await _make_pdf(await print_inventory(warehouse_id, token, db, user), "تقرير المخزون", f"inventory_{warehouse_id}.pdf", db, paper_size)

