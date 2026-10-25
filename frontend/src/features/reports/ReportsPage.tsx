import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { api, docUrl } from "@/lib/api";
import { money, moneyEGP, qty as fq } from "@/lib/format";
import { Card, Empty, ErrorBox, Input, Select, Spinner } from "@/components/ui";

interface Warehouse { id: string; name: string }
interface DailyRow { date: string; total_sales: string; invoice_count: number }
interface MonthlyRow { year: number; month: number; total_sales: string; invoice_count: number }
interface TopProduct { product_name?: string; name?: string; qty?: string; total?: string; revenue?: string }
interface CashierRow { cashier_name: string; invoice_count: number; total_sales: string }

const iso = (d: Date) => d.toISOString().slice(0, 10);
const daysAgo = (n: number) => { const d = new Date(); d.setDate(d.getDate() - n); return iso(d); };

/** Lightweight pure-CSS bar chart (no chart lib needed for these sizes). */
function Bars({ data, label }: { data: { k: string; v: number }[]; label: (v: number) => string }) {
  const max = Math.max(...data.map((d) => d.v), 1);
  return (
    <div className="flex h-44 items-end gap-1.5 overflow-x-auto rounded-xl border border-line bg-surface p-3" role="img" aria-label="مخطط أعمدة">
      {data.map((d) => (
        <div key={d.k} className="flex min-w-6 flex-1 flex-col items-center gap-1">
          <div
            className="w-full rounded-t bg-brand transition-all hover:opacity-80"
            style={{ height: `${Math.max(2, (d.v / max) * 120)}px` }}
            title={`${d.k}: ${label(d.v)}`}
          />
          <span className="num text-[9px] text-muted">{d.k}</span>
        </div>
      ))}
    </div>
  );
}

export default function ReportsPage() {
  const [tab, setTab] = useState("daily");
  const now = new Date();
  const [targetDate, setTargetDate] = useState(iso(now));
  const [year, setYear] = useState(now.getFullYear());
  const [month, setMonth] = useState(now.getMonth() + 1);
  const [from, setFrom] = useState(daysAgo(13));
  const [to, setTo] = useState(iso(now));
  const [wid, setWid] = useState("");

  const wh = useQuery({ queryKey: ["warehouses"], queryFn: () => api.get<Warehouse[]>("/stock/warehouses") });

  const daily = useQuery({
    queryKey: ["rep-daily", targetDate, wid],
    queryFn: () => api.get<DailyRow>("/reports/sales/daily", { target_date: targetDate, warehouse_id: wid || undefined }),
    enabled: tab === "daily",
  });
  const monthly = useQuery({
    queryKey: ["rep-monthly", year, month],
    queryFn: () => api.get<MonthlyRow>("/reports/sales/monthly", { year, month }),
    enabled: tab === "monthly",
  });
  const top = useQuery({
    queryKey: ["rep-top", from, to],
    queryFn: () => api.get<TopProduct[]>("/reports/sales/top-products", { from_date: from, to_date: to, limit: 12 }),
    enabled: tab === "top",
  });
  const byCashier = useQuery({
    queryKey: ["rep-cashier", from, to, wid],
    queryFn: () => api.get<CashierRow[]>("/reports/sales/by-cashier", { from_date: from, to_date: to, warehouse_id: wid || undefined }),
    enabled: tab === "cashier",
  });

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-extrabold">التقارير</h1>
      <div className="flex flex-wrap gap-2">
        {[
          { k: "daily", l: "يومي" },
          { k: "monthly", l: "شهري" },
          { k: "top", l: "الأكثر مبيعاً" },
          { k: "cashier", l: "حسب الكاشير" },
        ].map((t) => (
          <button
            key={t.k}
            onClick={() => setTab(t.k)}
            className={`rounded-full px-4 py-2 text-sm font-semibold ${tab === t.k ? "bg-brand text-brand-ink" : "border border-line text-muted hover:text-ink"}`}
          >
            {t.l}
          </button>
        ))}
      </div>

      {tab === "daily" && (
        <div className="space-y-4">
          <Card className="flex flex-wrap items-end gap-3">
            <div>
              <label className="mb-1 block text-sm font-medium">اليوم</label>
              <Input type="date" className="num w-44" value={targetDate} onChange={(e) => setTargetDate(e.target.value)} />
            </div>
            <div>
              <label className="mb-1 block text-sm font-medium">الفرع</label>
              <Select className="w-auto" value={wid} onChange={(e) => setWid(e.target.value)}>
                <option value="">كل الفروع</option>
                {wh.data?.map((w) => <option key={w.id} value={w.id}>{w.name}</option>)}
              </Select>
            </div>
          </Card>
          {daily.isLoading ? <Card className="grid place-items-center p-10"><Spinner /></Card>
          : daily.isError ? <ErrorBox message={(daily.error as Error).message} />
          : (
            <div className="grid gap-4 sm:grid-cols-3">
              <Card><p className="text-xs text-muted">إجمالي المبيعات</p><p className="num text-xl font-black text-brand">{moneyEGP(daily.data?.total_sales ?? 0)}</p></Card>
              <Card><p className="text-xs text-muted">عدد الفواتير</p><p className="num text-xl font-black">{daily.data?.invoice_count ?? 0}</p></Card>
              <Card><p className="text-xs text-muted">اليوم</p><p className="num text-lg font-bold">{daily.data?.date ?? "—"}</p></Card>
            </div>
          )}
        </div>
      )}

      {tab === "monthly" && (
        <div className="space-y-4">
          <Card className="flex flex-wrap items-end gap-3">
            <div>
              <label className="mb-1 block text-sm font-medium">السنة</label>
              <Input className="num w-28" inputMode="numeric" value={year} onChange={(e) => setYear(Number(e.target.value) || now.getFullYear())} />
            </div>
            <div>
              <label className="mb-1 block text-sm font-medium">الشهر</label>
              <Select className="w-auto" value={month} onChange={(e) => setMonth(Number(e.target.value))}>
                {Array.from({ length: 12 }, (_, i) => i + 1).map((m) => <option key={m} value={m}>{m}</option>)}
              </Select>
            </div>
          </Card>
          {monthly.isLoading ? <Card className="grid place-items-center p-10"><Spinner /></Card>
          : monthly.isError ? <ErrorBox message={(monthly.error as Error).message} />
          : (
            <div className="grid gap-4 sm:grid-cols-2">
              <Card><p className="text-xs text-muted">إجمالي مبيعات الشهر</p><p className="num text-xl font-black text-brand">{moneyEGP(monthly.data?.total_sales ?? 0)}</p></Card>
              <Card><p className="text-xs text-muted">عدد الفواتير</p><p className="num text-xl font-black">{monthly.data?.invoice_count ?? 0}</p></Card>
            </div>
          )}
        </div>
      )}

      {tab === "top" && (
        <div className="space-y-4">
          <Card className="flex flex-wrap items-end gap-3">
            <div>
              <label className="mb-1 block text-sm font-medium">من</label>
              <Input type="date" className="num w-40" value={from} onChange={(e) => setFrom(e.target.value)} />
            </div>
            <div>
              <label className="mb-1 block text-sm font-medium">إلى</label>
              <Input type="date" className="num w-40" value={to} onChange={(e) => setTo(e.target.value)} />
            </div>
          </Card>
          {top.isLoading ? <Card className="grid place-items-center p-10"><Spinner /></Card>
          : top.isError ? <ErrorBox message={(top.error as Error).message} />
          : !top.data?.length ? <Empty text="لا توجد مبيعات في هذه الفترة" />
          : (
            <>
              <Bars data={top.data.map((p, i) => ({ k: String(i + 1), v: Number(p.total ?? p.revenue ?? 0) }))} label={(v) => money(v)} />
              <Card className="overflow-x-auto p-0">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="border-b border-line text-xs text-muted">
                      <th className="p-3 text-start">#</th>
                      <th className="p-3 text-start">المنتج</th>
                      <th className="p-3 text-start">الكمية</th>
                      <th className="p-3 text-start">الإيراد</th>
                    </tr>
                  </thead>
                  <tbody>
                    {top.data.map((p, i) => (
                      <tr key={i} className="border-b border-line/60 last:border-0">
                        <td className="num p-3 text-muted">{i + 1}</td>
                        <td className="p-3 font-bold">{p.product_name ?? p.name ?? "—"}</td>
                        <td className="num p-3">{fq(p.qty ?? 0)}</td>
                        <td className="num p-3 font-bold text-brand">{moneyEGP(p.total ?? p.revenue ?? 0)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </Card>
            </>
          )}
        </div>
      )}

      {tab === "cashier" && (
        <div className="space-y-4">
          <Card className="flex flex-wrap items-end gap-3">
            <div>
              <label className="mb-1 block text-sm font-medium">من</label>
              <Input type="date" className="num w-40" value={from} onChange={(e) => setFrom(e.target.value)} />
            </div>
            <div>
              <label className="mb-1 block text-sm font-medium">إلى</label>
              <Input type="date" className="num w-40" value={to} onChange={(e) => setTo(e.target.value)} />
            </div>
            <div>
              <label className="mb-1 block text-sm font-medium">الفرع</label>
              <Select className="w-auto" value={wid} onChange={(e) => setWid(e.target.value)}>
                <option value="">كل الفروع</option>
                {wh.data?.map((w) => <option key={w.id} value={w.id}>{w.name}</option>)}
              </Select>
            </div>
          </Card>
          {byCashier.isLoading ? <Card className="grid place-items-center p-10"><Spinner /></Card>
          : byCashier.isError ? <ErrorBox message={(byCashier.error as Error).message} />
          : !byCashier.data?.length ? <Empty text="لا توجد بيانات" />
          : (
            <Card className="overflow-x-auto p-0">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-line text-xs text-muted">
                    <th className="p-3 text-start">الكاشير</th>
                    <th className="p-3 text-start">عدد الفواتير</th>
                    <th className="p-3 text-start">إجمالي المبيعات</th>
                  </tr>
                </thead>
                <tbody>
                  {byCashier.data.map((c, i) => (
                    <tr key={i} className="border-b border-line/60 last:border-0">
                      <td className="p-3 font-bold">{c.cashier_name}</td>
                      <td className="num p-3">{c.invoice_count}</td>
                      <td className="num p-3 font-bold text-brand">{moneyEGP(c.total_sales)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </Card>
          )}
        </div>
      )}

      <Card className="flex items-center justify-between text-sm">
        <span className="text-muted">تقرير جرد printable لكل فرع:</span>
        <a href={docUrl("/reports/inventory/print", { warehouse_id: wid || wh.data?.[0]?.id })} target="_blank" rel="noreferrer" className="font-semibold text-brand hover:underline">
          فتح تقرير الجرد ↗
        </a>
      </Card>
    </div>
  );
}
