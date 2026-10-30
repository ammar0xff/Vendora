import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Bar, BarChart, CartesianGrid, XAxis, YAxis } from "recharts";
import { CalendarRange, Printer, Receipt } from "lucide-react";
import { api, openPrintDoc } from "@/lib/api";
import { qty as fq } from "@/lib/format";
import { Money, Num, PageHeader, StatCard, TableShell } from "@/components/app/shared";
import { Button } from "@/components/kit/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/kit/card";
import { type ChartConfig, ChartContainer, ChartTooltip, ChartTooltipContent } from "@/components/kit/chart";
import { Input, Select } from "@/components/ui";
import { Skeleton } from "@/components/kit/skeleton";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/kit/table";
import { Tabs, TabsList, TabsTrigger } from "@/components/kit/tabs";
import { Empty, ErrorBox } from "@/components/ui";

interface Warehouse { id: string; name: string }
interface DailyRow { date: string; total_sales: string; invoice_count: number }
interface MonthlyRow { year: number; month: number; total_sales: string; invoice_count: number }
interface TopProduct { product_name?: string; name?: string; qty?: string; total?: string; revenue?: string }
interface CashierRow { cashier_name: string; invoice_count: number; total_sales: string }

const chartConfig = { revenue: { label: "الإيراد", color: "var(--chart-1)" } } satisfies ChartConfig;

const iso = (d: Date) => d.toISOString().slice(0, 10);
const daysAgo = (n: number) => { const d = new Date(); d.setDate(d.getDate() - n); return iso(d); };

function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="flex flex-col gap-1">
      <label className="text-xs font-medium text-muted-foreground">{label}</label>
      {children}
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

  const branchSelect = (
    <Select className="w-auto min-w-36" value={wid} onChange={(e) => setWid(e.target.value)}>
      <option value="">كل الفروع</option>
      {wh.data?.map((w) => <option key={w.id} value={w.id}>{w.name}</option>)}
    </Select>
  );

  return (
    <div className="flex flex-col gap-6">
      <PageHeader
        title="التقارير"
        description="مبيعات ومخزون وأداء الكاشيرين"
        actions={
          <Button variant="outline" onClick={() => openPrintDoc("/reports/inventory/print", { warehouse_id: wid || wh.data?.[0]?.id })}>
            <Printer data-icon="inline-start" />
            تقرير الجرد
          </Button>
        }
      />

      <Tabs value={tab} onValueChange={setTab}>
        <TabsList>
          <TabsTrigger value="daily">يومي</TabsTrigger>
          <TabsTrigger value="monthly">شهري</TabsTrigger>
          <TabsTrigger value="top">الأكثر مبيعاً</TabsTrigger>
          <TabsTrigger value="cashier">حسب الكاشير</TabsTrigger>
        </TabsList>
      </Tabs>

      {tab === "daily" && (
        <div className="flex flex-col gap-6">
          <Card className="flex flex-wrap items-end gap-3 p-4">
            <Field label="اليوم">
              <Input type="date" className="num w-44" value={targetDate} onChange={(e) => setTargetDate(e.target.value)} />
            </Field>
            <Field label="الفرع">{branchSelect}</Field>
          </Card>
          {daily.isLoading ? (
            <div className="grid gap-4 sm:grid-cols-3">{[0, 1, 2].map((i) => <Skeleton key={i} className="h-28 rounded-xl" />)}</div>
          ) : daily.isError ? (
            <ErrorBox message={(daily.error as Error).message} onRetry={() => daily.refetch()} />
          ) : (
            <div className="grid gap-4 sm:grid-cols-3">
              <StatCard label="إجمالي المبيعات" icon={Receipt} value={<Money value={Number(daily.data?.total_sales ?? 0)} />} />
              <StatCard label="عدد الفواتير" icon={CalendarRange} value={<Num value={daily.data?.invoice_count ?? 0} />} />
              <StatCard label="اليوم" icon={CalendarRange} value={<span className="num text-xl">{daily.data?.date ?? "—"}</span>} />
            </div>
          )}
        </div>
      )}

      {tab === "monthly" && (
        <div className="flex flex-col gap-6">
          <Card className="flex flex-wrap items-end gap-3 p-4">
            <Field label="السنة">
              <Input className="num w-28" inputMode="numeric" value={year} onChange={(e) => setYear(Number(e.target.value) || now.getFullYear())} />
            </Field>
            <Field label="الشهر">
              <Select className="w-auto" value={month} onChange={(e) => setMonth(Number(e.target.value))}>
                {Array.from({ length: 12 }, (_, i) => i + 1).map((m) => <option key={m} value={m}>{m}</option>)}
              </Select>
            </Field>
          </Card>
          {monthly.isLoading ? (
            <div className="grid gap-4 sm:grid-cols-2">{[0, 1].map((i) => <Skeleton key={i} className="h-28 rounded-xl" />)}</div>
          ) : monthly.isError ? (
            <ErrorBox message={(monthly.error as Error).message} onRetry={() => monthly.refetch()} />
          ) : (
            <div className="grid gap-4 sm:grid-cols-2">
              <StatCard label="إجمالي مبيعات الشهر" icon={CalendarRange} value={<Money value={Number(monthly.data?.total_sales ?? 0)} />} />
              <StatCard label="عدد الفواتير" icon={Receipt} value={<Num value={monthly.data?.invoice_count ?? 0} />} />
            </div>
          )}
        </div>
      )}

      {tab === "top" && (
        <div className="flex flex-col gap-6">
          <Card className="flex flex-wrap items-end gap-3 p-4">
            <Field label="من">
              <Input type="date" className="num w-40" value={from} onChange={(e) => setFrom(e.target.value)} />
            </Field>
            <Field label="إلى">
              <Input type="date" className="num w-40" value={to} onChange={(e) => setTo(e.target.value)} />
            </Field>
          </Card>
          {top.isLoading ? (
            <Skeleton className="h-72 rounded-xl" />
          ) : top.isError ? (
            <ErrorBox message={(top.error as Error).message} onRetry={() => top.refetch()} />
          ) : !top.data?.length ? (
            <Empty text="لا توجد مبيعات في هذه الفترة" />
          ) : (
            <>
              <Card>
                <CardHeader>
                  <CardTitle>الأكثر مبيعاً — الإيراد</CardTitle>
                  <CardDescription>أعلى 12 صنفاً في الفترة المحددة</CardDescription>
                </CardHeader>
                <CardContent>
                  <ChartContainer config={chartConfig} className="aspect-auto h-80 w-full" dir="ltr">
                    <BarChart data={top.data.map((p, i) => ({ name: (p.product_name ?? p.name ?? "—").slice(0, 18), rank: i + 1, revenue: Number(p.total ?? p.revenue ?? 0) }))} layout="vertical" margin={{ left: 8, right: 16 }}>
                      <CartesianGrid horizontal={false} />
                      <XAxis type="number" tickLine={false} axisLine={false} tickFormatter={(v: number) => `${v / 1000}k`} />
                      <YAxis type="category" dataKey="name" tickLine={false} axisLine={false} width={130} orientation="right" />
                      <ChartTooltip content={<ChartTooltipContent indicator="line" />} />
                      <Bar dataKey="revenue" fill="var(--color-revenue)" radius={4} barSize={18} />
                    </BarChart>
                  </ChartContainer>
                </CardContent>
              </Card>
              <TableShell>
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>#</TableHead>
                      <TableHead>المنتج</TableHead>
                      <TableHead className="text-end">الكمية</TableHead>
                      <TableHead className="text-end">الإيراد</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {top.data.map((p, i) => (
                      <TableRow key={i}>
                        <TableCell className="num text-muted-foreground">{i + 1}</TableCell>
                        <TableCell className="w-full max-w-0 truncate font-medium">{p.product_name ?? p.name ?? "—"}</TableCell>
                        <TableCell className="num text-end">{fq(p.qty ?? 0)}</TableCell>
                        <TableCell className="num text-end font-semibold">
                          <Money value={Number(p.total ?? p.revenue ?? 0)} />
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableShell>
            </>
          )}
        </div>
      )}

      {tab === "cashier" && (
        <div className="flex flex-col gap-6">
          <Card className="flex flex-wrap items-end gap-3 p-4">
            <Field label="من">
              <Input type="date" className="num w-40" value={from} onChange={(e) => setFrom(e.target.value)} />
            </Field>
            <Field label="إلى">
              <Input type="date" className="num w-40" value={to} onChange={(e) => setTo(e.target.value)} />
            </Field>
            <Field label="الفرع">{branchSelect}</Field>
          </Card>
          {byCashier.isLoading ? (
            <div className="flex flex-col gap-2">
              <Skeleton className="h-10 w-full" />
              {Array.from({ length: 5 }).map((_, i) => <Skeleton key={i} className="h-12 w-full" />)}
            </div>
          ) : byCashier.isError ? (
            <ErrorBox message={(byCashier.error as Error).message} onRetry={() => byCashier.refetch()} />
          ) : !byCashier.data?.length ? (
            <Empty text="لا توجد بيانات" />
          ) : (
            <TableShell>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>الكاشير</TableHead>
                    <TableHead className="text-end">عدد الفواتير</TableHead>
                    <TableHead className="text-end">إجمالي المبيعات</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {byCashier.data.map((c, i) => (
                    <TableRow key={i}>
                      <TableCell className="w-full max-w-0 truncate font-medium">{c.cashier_name}</TableCell>
                      <TableCell className="num text-end">{c.invoice_count}</TableCell>
                      <TableCell className="num text-end font-semibold">
                        <Money value={Number(c.total_sales)} />
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableShell>
          )}
        </div>
      )}
    </div>
  );
}
