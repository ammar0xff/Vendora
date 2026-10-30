/**
 * PAGE CONTRACT
 * Page: لوحة التحكم (/)
 * User: مدير الفرع يفتح النظام في بداية اليوم (أو بعد عودة من العمل الميداني)
 * Outcome: تشخيص حالة اليوم (مبيعات/نواقص/وردية) والانتقال إلى الإجراء التالي
 * Primary information: مبيعات اليوم، مبيعات الشهر، النواقص، حالة الوردية — بهذا الترتيب
 * Primary action (per state): populated → «فاتورة جديدة»؛ empty-no-sales → «ابدأ البيع»؛ error → «إعادة المحاولة»
 * Secondary action: مراجعة النواقص / كل الفواتير / اقتراح طلب شراء
 * Required states: loading (skeletons), error (retry), populated — empty handled per-card
 * Responsive: 1440 شبكة 4 مؤشرات + رسمان؛ 768 عمودان؛ 390 عمود واحد، الإجراء الأساسي ثابت
 */
import { Link } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { AlertTriangle, CalendarRange, Clock, Receipt, ShoppingCart, TrendingUp } from "lucide-react";
import { Area, AreaChart, CartesianGrid, XAxis, YAxis } from "recharts";
import { api } from "@/lib/api";
import { useBranch } from "@/components/AppShell";
import { ListState, Money, Num, PageHeader, StatCard, StatusBadge, TableShell } from "@/components/app/shared";
import { Badge } from "@/components/kit/badge";
import { Button } from "@/components/kit/button";
import { Card, CardAction, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/kit/card";
import { type ChartConfig, ChartContainer, ChartTooltip, ChartTooltipContent } from "@/components/kit/chart";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/kit/table";
import { formatDateTime, formatNumber } from "@/lib/format";

const chartConfig = {
  sales: { label: "المبيعات", color: "var(--chart-1)" },
} satisfies ChartConfig;

interface DailyReport {
  date: string;
  total_sales: number;
  total_items: number;
  invoice_count: number;
}
interface MonthlyReport {
  total_sales?: string | number;
  [k: string]: unknown;
}
interface SaleRow {
  id: string;
  invoice_number: string;
  customer_name: string | null;
  total: string;
  status: string;
  created_at: string;
}
interface LowStockRow {
  id: string;
  name: string;
  code?: string;
  sku?: string;
  quantity?: number;
  min_quantity?: number;
}

/** Build a 14-day series (oldest → newest) from the recent-sales list. */
function buildTrend(sales: SaleRow[]): { day: string; sales: number }[] {
  const byDay = new Map<string, number>();
  for (const s of sales) {
    const key = (s.created_at ?? "").slice(0, 10);
    if (byDay.has(key) && s.status !== "cancelled" && s.status !== "quotation") {
      byDay.set(key, (byDay.get(key) ?? 0) + Number(s.total));
    }
  }
  const days: { day: string; sales: number }[] = [];
  const today = new Date();
  for (let back = 13; back >= 0; back--) {
    const d = new Date(today);
    d.setDate(d.getDate() - back);
    const key = d.toISOString().slice(0, 10);
    days.push({
      day: `${d.getDate()}/${d.getMonth() + 1}`,
      sales: Math.round((byDay.get(key) ?? 0) * 100) / 100,
    });
  }
  return days;
}

export default function DashboardPage() {
  const { branchId, branchName } = useBranch();

  const daily = useQuery({
    queryKey: ["report", "daily"],
    queryFn: () => api.get<DailyReport>("/reports/sales/daily"),
  });
  const monthly = useQuery({
    queryKey: ["report", "monthly"],
    queryFn: () =>
      api.get<MonthlyReport>("/reports/sales/monthly", {
        year: new Date().getFullYear(),
        month: new Date().getMonth() + 1,
      }),
  });
  const lowStock = useQuery({
    queryKey: ["dash", "low", branchId],
    queryFn: () => api.get<LowStockRow[]>("/stock/low-stock", { warehouse_id: branchId! }),
    enabled: !!branchId,
  });
  const shift = useQuery({
    queryKey: ["shift", "dash", branchId],
    queryFn: () => api.get<{ id: string; started_at: string }>("/shifts/current", { warehouse_id: branchId! }),
    enabled: !!branchId,
    retry: false,
  });
  const recent = useQuery({
    queryKey: ["dash", "recent"],
    queryFn: () => api.get<SaleRow[]>("/sales", { page: 1, page_size: 14 }),
  });

  const trend = buildTrend(recent.data ?? []);
  const trendTotal = trend.reduce((s, d) => s + d.sales, 0);
  const monthTotal = Number(monthly.data?.total_sales ?? 0);
  const today = new Intl.DateTimeFormat("ar-EG-u-nu-latn", { dateStyle: "full", timeZone: "Africa/Cairo" }).format(new Date());

  return (
    <div className="flex flex-col gap-6">
      <PageHeader
        title="لوحة التحكم"
        description={`نظرة عامة على ${branchName} — ${today}`}
        actions={
          <Button nativeButton={false} render={<Link to="/pos" />}>
            <ShoppingCart data-icon="inline-start" />
            فاتورة جديدة
          </Button>
        }
      />

      <section aria-label="المؤشرات الرئيسية" className="grid grid-cols-2 gap-4 xl:grid-cols-4">
        <StatCard
          label="مبيعات اليوم"
          icon={Receipt}
          value={<Money value={daily.data?.total_sales ?? 0} />}
          hint={
            <span>
              <Num value={daily.data?.invoice_count ?? 0} /> فاتورة · <Num value={daily.data?.total_items ?? 0} /> قطعة
            </span>
          }
        />
        <StatCard
          label="مبيعات الشهر"
          icon={CalendarRange}
          value={<Money value={monthTotal} />}
          hint={<span>حتى تاريخ اليوم</span>}
        />
        <StatCard
          label="منتجات تحت الحد"
          icon={AlertTriangle}
          tone={(lowStock.data?.length ?? 0) > 0 ? "warning" : "success"}
          value={<Num value={lowStock.data?.length ?? 0} />}
          hint={
            <Link to="/inventory" className="inline-flex min-h-8 items-center underline-offset-4 hover:underline">
              عرض قائمة النواقص
            </Link>
          }
        />
        <StatCard
          label="حالة الوردية"
          icon={Clock}
          tone={shift.data ? "success" : "destructive"}
          value={shift.data ? "مفتوحة" : "مغلقة"}
          hint={
            shift.data ? (
              <span>
                منذ <span className="num">{formatDateTime(shift.data.started_at)}</span>
              </span>
            ) : (
              <Link to="/shifts" className="inline-flex min-h-8 items-center underline-offset-4 hover:underline">
                افتح وردية لبدء البيع
              </Link>
            )
          }
        />
      </section>

      <div className="grid gap-6 xl:grid-cols-[1.4fr_1fr]">
        <Card>
          <CardHeader>
            <CardTitle>المبيعات — آخر 14 يومًا</CardTitle>
            <CardDescription>
              إجمالي الفترة <Money value={trendTotal} />
            </CardDescription>
            <CardAction>
              <Badge variant="secondary">
                <TrendingUp data-icon="inline-start" />
                {branchName}
              </Badge>
            </CardAction>
          </CardHeader>
          <CardContent>
            <ChartContainer config={chartConfig} className="aspect-auto h-72 w-full" dir="ltr">
              <AreaChart data={trend} margin={{ left: 8, right: 8, top: 8 }}>
                <defs>
                  <linearGradient id="fillSales" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="var(--color-sales)" stopOpacity={0.35} />
                    <stop offset="95%" stopColor="var(--color-sales)" stopOpacity={0.02} />
                  </linearGradient>
                </defs>
                <CartesianGrid vertical={false} />
                <XAxis dataKey="day" tickLine={false} axisLine={false} tickMargin={8} reversed />
                <YAxis
                  orientation="right"
                  tickLine={false}
                  axisLine={false}
                  width={48}
                  tickFormatter={(v: number) => `${formatNumber(v / 1000)}k`}
                />
                <ChartTooltip content={<ChartTooltipContent indicator="line" />} />
                <Area dataKey="sales" type="monotone" stroke="var(--color-sales)" fill="url(#fillSales)" strokeWidth={2} />
              </AreaChart>
            </ChartContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>نواقص {branchName}</CardTitle>
            <CardDescription>أصناف وصلت أقل من حد الطلب</CardDescription>
            <CardAction>
              <Button variant="outline" size="sm" nativeButton={false} render={<Link to="/purchases" />}>
                اقتراح طلب شراء
              </Button>
            </CardAction>
          </CardHeader>
          <CardContent>
            <ListState
              status={lowStock.isLoading ? "loading" : lowStock.isError ? "error" : "ready"}
              isEmpty={(lowStock.data?.length ?? 0) === 0}
              onRetry={() => lowStock.refetch()}
              emptyTitle="لا توجد نواقص"
              emptyDescription="كل الأصناف فوق حد الطلب في هذا الفرع."
              emptyAction={
                <Button variant="outline" nativeButton={false} render={<Link to="/inventory" />}>
                  مراجعة المخزون
                </Button>
              }
            >
              <ul className="flex flex-col divide-y">
                {(lowStock.data ?? []).slice(0, 6).map((p) => (
                  <li key={p.id} className="flex items-center justify-between gap-3 py-2.5">
                    <div className="flex min-w-0 flex-col">
                      <span className="truncate text-sm font-medium">{p.name}</span>
                      <span className="num text-xs text-muted-foreground">{p.code ?? p.sku ?? ""}</span>
                    </div>
                    <div className="flex shrink-0 items-center gap-2 text-sm">
                      <Num value={p.quantity ?? 0} className="font-semibold text-destructive" />
                      <span className="text-muted-foreground">/ <Num value={p.min_quantity ?? 0} /></span>
                    </div>
                  </li>
                ))}
              </ul>
            </ListState>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>أحدث المبيعات</CardTitle>
          <CardDescription>آخر الفواتير المسجلة</CardDescription>
          <CardAction>
            <Button variant="outline" size="sm" nativeButton={false} render={<Link to="/sales" />}>
              كل الفواتير
            </Button>
          </CardAction>
        </CardHeader>
        <CardContent>
          <ListState
            status={recent.isLoading ? "loading" : recent.isError ? "error" : "ready"}
            isEmpty={(recent.data?.length ?? 0) === 0}
            onRetry={() => recent.refetch()}
            emptyTitle="لا توجد مبيعات بعد"
            emptyDescription="ستظهر الفواتير هنا بمجرد تسجيل أول عملية بيع."
            emptyAction={
              <Button nativeButton={false} render={<Link to="/pos" />}>
                <ShoppingCart data-icon="inline-start" />
                ابدأ البيع
              </Button>
            }
          >
            <TableShell>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>الفاتورة</TableHead>
                    <TableHead>العميل</TableHead>
                    <TableHead className="text-end">الإجمالي</TableHead>
                    <TableHead>الحالة</TableHead>
                    <TableHead>التاريخ</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {(recent.data ?? []).slice(0, 7).map((inv) => (
                    <TableRow key={inv.id}>
                      <TableCell className="num font-medium">{inv.invoice_number}</TableCell>
                      <TableCell>{inv.customer_name ?? "عميل نقدي"}</TableCell>
                      <TableCell className="text-end">
                        <Money value={Number(inv.total)} />
                      </TableCell>
                      <TableCell>
                        <StatusBadge status={inv.status} />
                      </TableCell>
                      <TableCell className="num text-muted-foreground">{formatDateTime(inv.created_at)}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableShell>
          </ListState>
        </CardContent>
      </Card>
    </div>
  );
}
