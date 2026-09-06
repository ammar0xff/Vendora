import uuid

from fastapi import Depends
from fastapi.responses import HTMLResponse
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.base import get_db
from app.dependencies import get_print_user
from app.services.shift_service import compute_summary

from . import _make_pdf, ar_egp, ar_num, fmt_date, fmt_dt, get_settings, router, top_band, wrap


@router.get("/shift/{shift_id}", response_class=HTMLResponse)
async def print_shift_summary(shift_id: uuid.UUID,
                               db: AsyncSession = Depends(get_db), _=Depends(get_print_user)):
    s = await get_settings(db)
    store = {"name": s.get("store_name", ""), "phone": s.get("store_phone", ""),
             "logo_url": s.get("logo_url", ""), "contacts": s.get("contact_phones") or []}

    summary = await compute_summary(db, shift_id)

    shift_row = await db.execute(text("""
        SELECT sh.*, u.full_name as cashier_name, w.name as wh_name,
               m.full_name as receiver_name
        FROM shifts sh
        LEFT JOIN users u ON u.id = sh.cashier_id
        LEFT JOIN users m ON m.id = sh.closed_by
        LEFT JOIN warehouses w ON w.id = sh.warehouse_id
        WHERE sh.id = :id
    """), {"id": shift_id})
    shift = dict(shift_row.fetchone()._mapping)

    handover_row = await db.execute(text("""
        SELECT metadata FROM archived_documents
        WHERE doc_type = 'shift_handover'
        AND ref_id = :sid
        ORDER BY created_at DESC LIMIT 1
    """), {"sid": shift_id})
    handover = handover_row.fetchone()
    if handover and handover[0]:
        import json as _j
        meta = handover[0] if isinstance(handover[0], dict) else _j.loads(handover[0])
        if meta.get("to_user_name"):
            shift["receiver_name"] = meta["to_user_name"]

    tx_rows = await db.execute(text("""
        SELECT dt.type, dt.amount, dt.note, dt.payment_method,
               pw.name as wallet_name, dt.created_at
        FROM drawer_transactions dt
        LEFT JOIN payment_wallets pw ON pw.id = dt.wallet_id
        WHERE dt.shift_id = :sid AND dt.type IN ('deposit','expense','withdrawal')
        ORDER BY dt.created_at
    """), {"sid": shift_id})
    txns = [dict(r._mapping) for r in tx_rows.fetchall()]

    sales_rows = await db.execute(text("""
        SELECT s.id, s.invoice_number, s.created_at,
               COALESCE(c.name,'عميل عادي') as customer,
               COALESCE(s.payment_method,'cash') as payment_method,
               pw.name as wallet_name,
               COALESCE(SUM(si.qty * si.unit_price - si.discount),0) - COALESCE(SUM(s.discount_amount),0) as total
        FROM sales s
        LEFT JOIN customers c ON c.id = s.customer_id
        LEFT JOIN payment_wallets pw ON pw.id = s.wallet_id
        LEFT JOIN sale_items si ON si.sale_id = s.id
        WHERE s.shift_id = :sid AND s.status = 'confirmed'
        GROUP BY s.id, c.name, pw.name ORDER BY s.created_at
    """), {"sid": shift_id})
    sales = [dict(r._mapping) for r in sales_rows.fetchall()]

    if sales:
        sale_ids = [s["id"] for s in sales]
        items_rows = await db.execute(text("""
            SELECT si.sale_id, p.name as product_name, p.unit, si.qty, si.unit_price,
                   (si.qty * si.unit_price - si.discount) as line_total
            FROM sale_items si JOIN products p ON p.id = si.product_id
            WHERE si.sale_id = ANY(:sale_ids)
            ORDER BY si.id
        """), {"sale_ids": sale_ids})
        items_by_sale: dict = {}
        for r in items_rows.fetchall():
            d = dict(r._mapping)
            sid = str(d["sale_id"])
            items_by_sale.setdefault(sid, []).append(d)
        for s2 in sales:
            s2["items"] = items_by_sale.get(str(s2["id"]), [])

    ret_rows = await db.execute(text("""
        SELECT s.invoice_number, s.created_at,
               COALESCE(SUM(si.qty * si.unit_price),0) as total
        FROM sales s LEFT JOIN sale_items si ON si.sale_id = s.id
        WHERE s.shift_id = :sid AND s.status = 'returned'
        GROUP BY s.id ORDER BY s.created_at
    """), {"sid": shift_id})
    returns = [dict(r._mapping) for r in ret_rows.fetchall()]

    wallet_totals: dict = {}
    pb = summary.get("payment_breakdown", [])
    for p in pb:
        if p["method"] != "cash" and p.get("wallet_name"):
            wn = p["wallet_name"]
            wallet_totals[wn] = wallet_totals.get(wn, 0) + float(p["total"])
    for t in txns:
        if t["payment_method"] == "wallet" and t["wallet_name"]:
            wn = t["wallet_name"]
            wallet_totals[wn] = wallet_totals.get(wn, 0) + (float(t["amount"]) if t["type"] == "deposit" else -float(t["amount"]))

    cash_in = float(summary.get("cash_in_drawer", 0))
    total_all = cash_in + sum(wallet_totals.values())
    TX_AR = {"deposit": "دواخل", "expense": "خوارج", "withdrawal": "سحب"}

    all_ops = []
    for s2 in sales:
        items = s2.get("items", [])
        if len(items) == 1:
            it = items[0]
            all_ops.append({"time": s2["created_at"], "type": "مبيعات",
                            "ref": f"{it['product_name']} ({ar_num(float(it['qty']),0)} {it['unit']} × {ar_egp(float(it['unit_price']))})",
                            "party": s2["customer"], "payment": s2["wallet_name"] or "نقدي",
                            "credit": float(s2["total"]), "debit": 0, "sub": []})
        else:
            all_ops.append({"time": s2["created_at"], "type": "مبيعات",
                            "ref": s2["invoice_number"], "party": s2["customer"],
                            "payment": s2["wallet_name"] or "نقدي",
                            "credit": float(s2["total"]), "debit": 0, "sub": items})
    for r2 in returns:
        all_ops.append({"time": r2["created_at"], "type": "مرتجع", "ref": r2["invoice_number"],
                        "party": "", "payment": "—", "credit": 0, "debit": float(r2["total"]), "sub": []})
    for t2 in txns:
        is_in = t2["type"] == "deposit"
        all_ops.append({"time": t2["created_at"], "type": TX_AR.get(t2["type"], t2["type"]),
                        "ref": t2.get("note") or "—", "party": "",
                        "payment": t2.get("wallet_name") or "نقدي",
                        "credit": float(t2["amount"]) if is_in else 0,
                        "debit": float(t2["amount"]) if not is_in else 0, "sub": []})
    all_ops.sort(key=lambda x: x["time"])

    def op_row(op):
        rows = f"""
        <tr>
          <td style="font-size:9px;color:#555;white-space:nowrap">{fmt_dt(op['time'])}</td>
          <td><span style="font-size:9px;font-weight:700;padding:1px 5px;border:1px solid {'#166534' if op['credit']>0 else '#991b1b'};color:{'#166534' if op['credit']>0 else '#991b1b'}">{op['type']}</span></td>
          <td style="font-size:10px">{op['ref']}</td>
          <td style="font-size:10px;color:#555">{op['party'] or '—'}</td>
          <td style="font-size:10px;color:#555">{op['payment']}</td>
          <td style="text-align:left;font-weight:700;font-size:10px;color:#166534;white-space:nowrap">{ar_egp(op['credit']) if op['credit'] else ''}</td>
          <td style="text-align:left;font-weight:700;font-size:10px;color:#991b1b;white-space:nowrap">{ar_egp(op['debit']) if op['debit'] else ''}</td>
        </tr>"""
        for it in op.get("sub", []):
            rows += f"""
        <tr style="background:#f9f9f9">
          <td></td><td></td>
          <td style="font-size:9px;color:#555;padding-right:16px">↳ {it['product_name']}</td>
          <td style="font-size:9px;color:#555;text-align:center">{ar_num(float(it['qty']),0)} {it['unit']}</td>
          <td style="font-size:9px;color:#555">{ar_egp(float(it['unit_price']))}</td>
          <td style="text-align:left;font-size:9px;color:#166534;white-space:nowrap">{ar_egp(float(it['line_total']))}</td>
          <td></td>
        </tr>"""
        return rows

    "".join(op_row(op) for op in all_ops)

    wallet_summary_html = "".join(f"""
        <tr><td style="padding:3px 10px;font-size:10px;border-bottom:1px solid #eee">{wn}</td>
        <td style="padding:3px 10px;text-align:left;font-weight:700;font-size:10px;border-bottom:1px solid #eee;white-space:nowrap">{ar_egp(v)}</td></tr>
    """ for wn, v in wallet_totals.items())

    cash_sales_total = sum(float(p["total"]) for p in pb if p["method"] == "cash")
    total_returns = float(summary.get('returns_total', 0))
    total_expenses = float(summary.get('expenses_total', 0))

    flat_rows = []
    for s2 in sales:
        items = s2.get("items", [])
        pm = s2.get("wallet_name") or "نقدي"
        for it in items:
            flat_rows.append({
                "time": s2["created_at"],
                "name": it["product_name"],
                "qty": ar_num(float(it["qty"]), 0),
                "unit": it["unit"],
                "price": ar_egp(float(it["unit_price"])),
                "total": ar_egp(float(it["line_total"])),
                "expense": "",
                "ret": "",
                "note": pm if pm != "نقدي" else "",
                "row_type": "sale"
            })
    for r2 in returns:
        flat_rows.append({
            "time": r2["created_at"],
            "name": r2["invoice_number"],
            "qty": "", "unit": "", "price": "",
            "total": "",
            "expense": "",
            "ret": ar_egp(float(r2["total"])),
            "note": "مرتجع",
            "row_type": "return"
        })
    for t2 in txns:
        is_exp = t2["type"] in ("expense", "withdrawal")
        flat_rows.append({
            "time": t2["created_at"],
            "name": t2.get("note") or TX_AR.get(t2["type"], t2["type"]),
            "qty": "", "unit": "", "price": "",
            "total": "" if is_exp else ar_egp(float(t2["amount"])),
            "expense": ar_egp(float(t2["amount"])) if is_exp else "",
            "ret": "",
            "note": t2.get("wallet_name") or "نقدي",
            "row_type": "expense" if is_exp else "deposit"
        })
    flat_rows.sort(key=lambda x: x["time"])

    def row_style(rt):
        if rt == "return":
            return "background:#fff5f5"
        if rt == "expense":
            return "background:#fffbf0"
        if rt == "deposit":
            return "background:#f0fff4"
        return ""

    B = "border-left:1px solid #ccc"
    flat_rows_html = "".join(f"""
        <tr style="{row_style(r['row_type'])};border-bottom:1px solid #e8e8e8">
          <td style="padding:4px 6px;font-size:10px;word-break:break-word;{B}">{r['name']}</td>
          <td style="padding:4px 4px;text-align:center;font-size:10px;white-space:nowrap;{B}">{r['qty']}</td>
          <td style="padding:4px 4px;text-align:center;font-size:9px;color:#666;white-space:nowrap;{B}">{r['unit']}</td>
          <td style="padding:4px 6px;text-align:left;font-size:10px;white-space:nowrap;{B}">{r['price']}</td>
          <td style="padding:4px 6px;text-align:left;font-weight:700;font-size:10px;white-space:nowrap;color:#166534;{B}">{r['total']}</td>
          <td style="padding:4px 6px;text-align:left;font-weight:700;font-size:10px;white-space:nowrap;color:#991b1b;{B}">{r['expense']}</td>
          <td style="padding:4px 6px;text-align:left;font-weight:700;font-size:10px;white-space:nowrap;color:#dc2626;{B}">{r['ret']}</td>
          <td style="padding:4px 4px;font-size:8px;color:#888;text-align:center;white-space:nowrap">{r['note']}</td>
        </tr>
    """ for r in flat_rows)

    body = f"""
{top_band(store, "تسليم عهدة الوردية", "", fmt_date(shift.get('started_at')))}
<div class="body">

  <table style="width:100%;border-collapse:collapse;border:1px solid #ccc;margin-bottom:8px">
    <tr>
      <td colspan="2" style="padding:6px 10px;text-align:center;border-bottom:1px solid #ccc;font-size:13px;font-weight:900;color:#111">{shift.get('wh_name','—')}</td>
    </tr>
    <tr>
      <td style="padding:5px 10px;border-left:1px solid #ccc;border-bottom:1px solid #ccc;width:50%">
        <div style="font-size:8px;color:#999;margin-bottom:2px">فتح الوردية</div>
        <div style="font-size:10px;font-weight:700">{fmt_dt(shift.get('started_at'))}</div>
      </td>
      <td style="padding:5px 10px;border-bottom:1px solid #ccc">
        <div style="font-size:8px;color:#999;margin-bottom:2px">إغلاق الوردية</div>
        <div style="font-size:10px;font-weight:700">{"مفتوحة" if not shift.get('closed_at') else fmt_dt(shift.get('closed_at'))}</div>
      </td>
    </tr>
    <tr>
      <td style="padding:5px 10px;border-left:1px solid #ccc">
        <div style="font-size:8px;color:#999;margin-bottom:2px">من (الكاشير)</div>
        <div style="font-size:10px;font-weight:700">{shift.get('cashier_name','—')}</div>
      </td>
      <td style="padding:5px 10px">
        <div style="font-size:8px;color:#999;margin-bottom:2px">إلى (المستلم)</div>
        <div style="font-size:10px;font-weight:700">{shift.get('receiver_name') or '_________________'}</div>
      </td>
    </tr>
  </table>

  <table style="width:100%;border-collapse:collapse;border:1px solid #ccc">
    <thead>
      <tr style="background:#111">
        <th style="padding:5px 6px;color:#fff;font-size:9px;text-align:right;border-left:1px solid #333;width:100%">اسم الصنف / البيان</th>
        <th style="padding:5px 4px;color:#fff;font-size:9px;text-align:center;border-left:1px solid #333;white-space:nowrap">الكمية</th>
        <th style="padding:5px 4px;color:#fff;font-size:9px;text-align:center;border-left:1px solid #333;white-space:nowrap">الوحدة</th>
        <th style="padding:5px 6px;color:#fff;font-size:9px;text-align:left;border-left:1px solid #333;white-space:nowrap">السعر</th>
        <th style="padding:5px 6px;color:#fff;font-size:9px;text-align:left;border-left:1px solid #333;white-space:nowrap">الإجمالي</th>
        <th style="padding:5px 6px;color:#fff;font-size:9px;text-align:left;border-left:1px solid #333;white-space:nowrap">الخوارج</th>
        <th style="padding:5px 6px;color:#fff;font-size:9px;text-align:left;border-left:1px solid #333;white-space:nowrap">المرتجعات</th>
        <th style="padding:5px 4px;color:#fff;font-size:9px;text-align:right;white-space:nowrap">ملاحظات</th>
      </tr>
    </thead>
    <tbody>
      {flat_rows_html}
    </tbody>
    <tfoot>
      <tr style="border-top:2px solid #111;background:#f5f5f5">
        <td colspan="4" style="padding:5px 6px;font-weight:800;font-size:10px;border-left:1px solid #ccc">المجموع</td>
        <td style="padding:5px 6px;font-weight:900;font-size:11px;color:#166534;white-space:nowrap;border-left:1px solid #ccc">{ar_egp(float(summary.get('sales_total',0)))}</td>
        <td style="padding:5px 6px;font-weight:900;font-size:11px;color:#991b1b;white-space:nowrap;border-left:1px solid #ccc">{ar_egp(total_expenses)}</td>
        <td style="padding:5px 6px;font-weight:900;font-size:11px;color:#dc2626;white-space:nowrap;border-left:1px solid #ccc">{ar_egp(total_returns)}</td>
        <td></td>
      </tr>
    </tfoot>
  </table>

  <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-top:10px;page-break-inside:avoid;break-inside:avoid">
    <table style="border-collapse:collapse;border:1px solid #ccc;font-size:10px">
      <thead><tr><th colspan="2" style="padding:4px 8px;text-align:right;border-bottom:1.5px solid #111;background:#f5f5f5;font-size:9px">ملخص النقدي</th></tr></thead>
      <tbody>
        <tr><td style="padding:3px 8px;border-bottom:1px solid #eee;font-size:10px">الرصيد الافتتاحي</td><td style="padding:3px 8px;text-align:left;font-weight:700;border-bottom:1px solid #eee;font-size:10px">{ar_egp(float(shift.get('initial_amount',0)))}</td></tr>
        <tr><td style="padding:3px 8px;border-bottom:1px solid #eee;font-size:10px">مبيعات نقدي</td><td style="padding:3px 8px;text-align:left;font-weight:700;color:#166534;border-bottom:1px solid #eee;font-size:10px">{ar_egp(cash_sales_total)}</td></tr>
        <tr><td style="padding:3px 8px;border-bottom:1px solid #eee;font-size:10px">مرتجعات</td><td style="padding:3px 8px;text-align:left;font-weight:700;color:#991b1b;border-bottom:1px solid #eee;font-size:10px">({ar_egp(total_returns)})</td></tr>
        <tr><td style="padding:3px 8px;border-bottom:1.5px solid #111;font-size:10px">مصروفات</td><td style="padding:3px 8px;text-align:left;font-weight:700;color:#991b1b;border-bottom:1.5px solid #111;font-size:10px">({ar_egp(total_expenses)})</td></tr>
        <tr><td style="padding:5px 8px;font-weight:800;font-size:11px">💵 صافي النقدي</td><td style="padding:5px 8px;text-align:left;font-weight:900;font-size:14px;white-space:nowrap">{ar_egp(cash_in)}</td></tr>
      </tbody>
    </table>
    <div style="display:flex;flex-direction:column;gap:6px">
      {"" if not wallet_totals else '<table style="border-collapse:collapse;border:1px solid #ccc;font-size:10px;width:100%"><thead><tr><th colspan="2" style="padding:4px 8px;text-align:right;border-bottom:1.5px solid #111;background:#f5f5f5;font-size:9px">المحافظ الإلكترونية</th></tr></thead><tbody>' + wallet_summary_html + '</tbody></table>'}
      <div style="border:2px solid #111;padding:10px 14px;display:flex;justify-content:space-between;align-items:center;margin-top:auto">
        <span style="font-size:11px;font-weight:700">الإجمالي الكلي</span>
        <span style="font-size:20px;font-weight:900">{ar_egp(total_all)}</span>
      </div>
    </div>
  </div>

</div>"""
    return HTMLResponse(wrap(body, "تسليم عهدة الوردية"))


@router.get("/pdf/shift/{shift_id}")
async def pdf_shift(shift_id: uuid.UUID, paper_size: str = None,
                    db: AsyncSession = Depends(get_db), user=Depends(get_print_user)):
    html_resp = await print_shift_summary(shift_id, db, user)
    return await _make_pdf(html_resp, "تسليم عهدة الوردية", f"shift_{shift_id}.pdf", db, paper_size)
