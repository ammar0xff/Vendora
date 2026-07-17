"""Central print system — shared utilities."""
from fastapi import APIRouter
from datetime import datetime

router = APIRouter(prefix="/print", tags=["print"])


async def get_settings(db):
    import json as _json
    from sqlalchemy import text
    rows = await db.execute(text("SELECT key, value FROM store_settings"))
    out = {}
    for r in rows.fetchall():
        try:
            out[r.key] = _json.loads(r.value) if r.value and r.value.startswith(('[', '{')) else r.value
        except Exception:
            out[r.key] = r.value
    return out


def ar_num(n, decimals=2):
    try:
        n = float(n)
        formatted = f'{n:,.{decimals}f}'
        arabic = str.maketrans('0123456789', '٠١٢٣٤٥٦٧٨٩')
        return formatted.translate(arabic)
    except Exception:
        return str(n)


def ar_egp(n, decimals=2):
    return f'{ar_num(n, decimals)} ج.م'


def fmt_date(v):
    try:
        return datetime.fromisoformat(str(v)).strftime('%d / %m / %Y')
    except Exception:
        return str(v) if v else ''


def fmt_dt(v):
    try:
        dt = datetime.fromisoformat(str(v))
        return dt.strftime('%d/%m/%Y  %I:%M %p').replace('AM', 'ص').replace('PM', 'م')
    except Exception:
        return str(v) if v else ''


def css():
    return """
<style>
*{margin:0;padding:0;box-sizing:border-box}
html,body{background:#e8e8e8;font-family:'Segoe UI',Tahoma,sans-serif;direction:rtl;color:#111;font-size:13px}

.sheet{width:210mm;min-height:297mm;margin:6mm auto;background:#fff;box-shadow:0 2px 12px rgba(0,0,0,.15);display:flex;flex-direction:column}

.top-band{padding:12px 18px;display:flex;justify-content:space-between;align-items:center;border-bottom:2px solid #111}
.brand{display:flex;align-items:center;gap:10px}
.brand-logo{width:44px;height:44px;object-fit:contain;flex-shrink:0}
.brand-initials{width:44px;height:44px;background:#111;display:flex;align-items:center;justify-content:center;font-size:18px;font-weight:900;color:#fff;flex-shrink:0}
.brand-text .co-name{font-size:16px;font-weight:900;color:#111;line-height:1.2}
.brand-text .co-sub{font-size:11px;color:#666;margin-top:1px}
.doc-id{text-align:left}
.doc-id .doc-type{font-size:10px;font-weight:700;color:#666;letter-spacing:1.5px;text-transform:uppercase;margin-bottom:2px}
.doc-id .doc-num{font-size:20px;font-weight:900;color:#111}
.doc-id .doc-date{font-size:11px;color:#666;margin-top:1px}
.ribbon{height:2px;background:#111}

.body{padding:14px 18px;flex:1;display:flex;flex-direction:column}

.parties{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:12px}
.party-card{padding:8px 12px;border:1px solid #ccc}
.party-card.buyer{border-right:2px solid #111}
.party-label{font-size:9px;font-weight:700;color:#999;text-transform:uppercase;letter-spacing:1px;margin-bottom:3px}
.party-name{font-size:13px;font-weight:800;color:#111}
.party-detail{font-size:11px;color:#555;margin-top:2px;line-height:1.4}

.meta-row{display:flex;gap:0;margin-bottom:12px;border:1px solid #ccc}
.meta-cell{flex:1;padding:6px 10px;border-left:1px solid #ccc}
.meta-cell:last-child{border-left:none}
.meta-cell .m-lbl{font-size:9px;font-weight:700;color:#999;text-transform:uppercase;letter-spacing:.8px;margin-bottom:2px}
.meta-cell .m-val{font-size:12px;font-weight:700;color:#111}

.badge{display:inline-block;padding:2px 6px;font-size:10px;font-weight:700;border:1px solid currentColor}
.b-green{color:#166534;border-color:#166534}
.b-yellow{color:#854d0e;border-color:#854d0e}
.b-red{color:#991b1b;border-color:#991b1b}
.b-blue{color:#1e40af;border-color:#1e40af}

.tbl-label{font-size:10px;font-weight:700;color:#666;text-transform:uppercase;letter-spacing:.8px;margin-bottom:5px}
table{width:100%;border-collapse:collapse;border:1px solid #ccc;table-layout:auto}
thead tr{background:#111}
thead th{padding:7px 9px;color:#fff;font-size:11px;font-weight:700;text-align:right;white-space:nowrap}
thead th:last-child{text-align:left}
tbody tr{border-bottom:1px solid #e8e8e8}
tbody tr:last-child{border-bottom:none}
tbody tr:nth-child(even){background:#f9f9f9}
tbody td{padding:7px 9px;font-size:12px;vertical-align:middle}
tbody td:last-child{text-align:left;font-weight:700;white-space:nowrap}
.td-name{font-weight:600;color:#111;word-break:break-word}
.td-sub{font-size:10px;color:#999;margin-top:1px}
.col-num{width:24px;text-align:center!important;color:#999;font-size:11px}
.col-price,.col-qty,.col-unit,.col-total{white-space:nowrap;width:1%}

.totals-section{display:flex;justify-content:flex-end;margin-top:12px}
.totals-box{min-width:220px;border:1px solid #ccc}
.t-line{display:flex;justify-content:space-between;padding:5px 12px;border-bottom:1px solid #e8e8e8;font-size:12px}
.t-line:last-child{border-bottom:none}
.t-lbl{color:#555}
.t-val{font-weight:700;color:#111;white-space:nowrap}
.t-val.neg{color:#991b1b}
.t-grand{padding:10px 14px;background:#111;display:flex;justify-content:space-between;align-items:center}
.t-grand .t-lbl{color:rgba(255,255,255,.7);font-size:12px;font-weight:600}
.t-grand .t-val{color:#fff;font-size:17px;font-weight:900}

.notes-box{margin-top:12px;padding:8px 12px;border-right:2px solid #111;background:#f9f9f9}
.notes-box .n-lbl{font-size:10px;font-weight:700;color:#111;margin-bottom:3px}
.notes-box .n-txt{font-size:12px;color:#333;line-height:1.5}
.note-section{font-size:11px;color:#555;margin-bottom:8px;line-height:1.6}

.doc-footer{border-top:2px solid #111;padding:12px 18px;display:grid;grid-template-columns:1fr auto 1fr;align-items:end;gap:12px;background:#f9f9f9}
.sig{text-align:center}
.sig .sig-name{font-size:11px;font-weight:700;color:#333;margin-bottom:26px}
.sig .sig-line{border-top:1px solid #999;padding-top:5px;font-size:10px;color:#999}
.footer-mid{text-align:center}
.stamp-circle{width:56px;height:56px;border-radius:50%;border:1px dashed #ccc;display:flex;align-items:center;justify-content:center;margin:0 auto 5px;font-size:9px;color:#ccc}
.footer-meta{font-size:10px;color:#999;line-height:1.7;margin-top:2px}

.signatures{display:grid;grid-template-columns:1fr 1fr 1fr;gap:10px;margin-top:auto;padding-top:12px;border-top:1px solid #ccc}
.signature-item{text-align:center}
.signature-item .label{font-size:9px;font-weight:700;color:#999;text-transform:uppercase;letter-spacing:.5px;margin-bottom:4px}
.signature-line{height:36px;border-bottom:1px solid #111;margin-bottom:4px}
.signature-item .name{font-size:11px;font-weight:700}

.sale-footer-info{font-size:11px;color:#888;margin-top:10px;line-height:1.8}

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
</style>"""


def pdf_css(paper_size="A4"):
    is_a4 = paper_size and paper_size.upper() == "A4"
    w = "210mm" if is_a4 else "80mm"
    css_ = css()
    css_ = css_.replace("width:210mm", f"width:{w}")
    if not is_a4:
        css_ = css_.replace(".sheet{", ".sheet{margin:0 auto;padding:0;min-height:auto;box-shadow:none;")
        css_ = css_.replace(
            "html,body{background:#e8e8e8;font-family:'Segoe UI',Tahoma,sans-serif;direction:rtl;color:#111;font-size:11px}",
            "html,body{background:#fff;font-family:'Segoe UI',Tahoma,sans-serif;direction:rtl;color:#111;font-size:10px}"
        )
    return css_


def wrap(body, title="مستند"):
    return f"""<!DOCTYPE html><html dir="rtl" lang="ar"><head><meta charset="utf-8">{css()}</head><body><div class="sheet">{body}</div></body></html>"""


def wrap_pdf(body, title="مستند", paper_size="A4", company_name="EG-CO", doc_number="", footer_html=""):
    extra = ""
    if footer_html:
        extra = f"""@page{{@bottom-left{{content:"{footer_html}";font-size:7px;color:#999;font-family:'Segoe UI',Tahoma,sans-serif}}}}"""
    return f"""<!DOCTYPE html><html dir="rtl" lang="ar"><head><meta charset="utf-8"><title>{title}</title>{pdf_css(paper_size)}<style>{extra}</style></head><body><div class="sheet">{body}</div></body></html>"""


async def html_to_pdf(html: str, zoom: float = 1.0) -> bytes:
    import asyncio
    loop = asyncio.get_running_loop()
    from weasyprint import HTML
    return await loop.run_in_executor(None, lambda: HTML(string=html).write_pdf(zoom=zoom))


async def get_paper_size(db, override: str = None) -> str:
    if override:
        return override
    try:
        settings_ = await get_settings(db)
        return settings_.get("paper_size", "A4")
    except (ValueError, AttributeError):
        return "A4"


def top_band(store, doc_type_label, doc_number, date_str):
    import html as _html
    logo = store.get('logo_url', '') if store else ''
    logo_html = f'<img class="brand-logo" src="{_html.escape(logo)}" alt=""/>' if logo else '<div class="brand-initials">EG</div>'
    co_name = _html.escape((store or {}).get('store_name', 'EG-CO'))
    co_sub = _html.escape((store or {}).get('address', '') or '')
    return f'''<div class="top-band"><div class="brand">{logo_html}<div class="brand-text"><div class="co-name">{co_name}</div><div class="co-sub">{co_sub}</div></div></div><div class="doc-id"><div class="doc-type">{doc_type_label}</div><div class="doc-num">{doc_number}</div><div class="doc-date">{date_str}</div></div></div><div class="ribbon"></div>'''


def _extract_body(html_response) -> str:
    body = html_response.body if hasattr(html_response, 'body') else str(html_response)
    if isinstance(body, bytes):
        body = body.decode()
    start = body.find('<div class="sheet">')
    end = body.find('</div></body></html>')
    if start >= 0 and end >= 0:
        return body[start + len('<div class="sheet">'):end]
    return body


def _extract_meta(html_response) -> tuple:
    company = "EG-CO"
    doc_num = ""
    body = html_response.body if hasattr(html_response, 'body') else str(html_response)
    if isinstance(body, bytes):
        body = body.decode()
    import re
    m = re.search(r'<div class="co-name">([^<]+)</div>', body)
    if m:
        company = m.group(1)
    m2 = re.search(r'<div class="doc-num">([^<]*)</div>', body)
    if m2:
        doc_num = m2.group(1).strip()
    return company, doc_num


async def _make_pdf(html_response, title: str, filename: str, db, paper_size_override: str = None) -> "Response":
    from fastapi.responses import Response
    body = _extract_body(html_response)
    company, doc_num = _extract_meta(html_response)
    ps = await get_paper_size(db, paper_size_override)
    invoice_footer = f"{company} | {title} | {doc_num}"
    html = wrap_pdf(body, title, ps, company, doc_num, invoice_footer)
    pdf_bytes = await html_to_pdf(html, zoom=1.0 if ps.upper() == "A4" else 2.0)
    return Response(content=pdf_bytes, media_type="application/pdf",
                    headers={"Content-Disposition": f'inline; filename="{filename}"'})


# Import sub-modules to register endpoints on the shared router
from . import sale  # noqa: F401
from . import dispatch  # noqa: F401
from . import purchase  # noqa: F401
from . import archive  # noqa: F401
from . import inventory  # noqa: F401
from . import shift  # noqa: F401
