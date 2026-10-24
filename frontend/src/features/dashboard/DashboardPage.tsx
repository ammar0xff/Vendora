import { useQuery } from "@tanstack/react-query";
import { AlertTriangle, ArrowLeft, Receipt, TrendingUp, Wallet } from "lucide-react";
import { api } from "@/lib/api";
import { moneyEGP, dateTime } from "@/lib/format";
import { Badge, Card, Empty, ErrorBox, Spinner } from "@/components/ui";
import { useAuth } from "@/stores/auth";

interface DailyReport { date: string; total_sales: string; total_items: number; invoice_count: number }
interface MonthlyReport { year: number; month: number; total_sales: string; invoice_count: number }
interface Warehouse { id: string; name: string }
interface SaleRow {
  id: string; invoice_number: string; total: string; paid_amount: string;
  status: string; is_credit: boolean; created_at: string; customer_name: string | null;
}

function Kpi({ icon, label, value, sub }: { icon: React.ReactNode; label: string; value: string; sub?: string }) {
  return (
    <Card className="flex items-center gap-4">
      <div className="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-brand/15 text-brand">{icon}</div>
      <div className="min-w-0">
        <p className="text-xs font-medium text-muted">{label}</p>
        <p className="num truncate text-lg font-extrabold">{value}</p>
        {sub && <p className="text-xs text-muted">{sub}</p>}
      </div>
    </Card>
  );
}

export default function DashboardPage() {
  const { can, user } = useAuth();

  const wh = useQuery({
    queryKey: ["warehouses"],
    queryFn: () => api.get<Warehouse[]>("/stock/warehouses"),
  });
  const whId = wh.data?.[0]?.id;

  const daily = useQuery({
    queryKey: ["report", "daily"],
    queryFn: () => api.get<DailyReport>("/reports/sales/daily"),
  });
  const monthly = useQuery({
    queryKey: ["report", "monthly"],
    queryFn: () => api.get<MonthlyReport>("/reports/sales/monthly", { year: new Date().getFullYear(), month: new Date().getMonth() + 1 }),
  });
  const lowStock = useQuery({
    queryKey: ["low-stock", whId],
    queryFn: () => api.get<unknown[]>("/stock/low-stock", { warehouse_id: whId }),
    enabled: !!whId && can("inventory"),
  });
  const recent = useQuery({
    queryKey: ["sales", "recent"],
    queryFn: () => api.get<SaleRow[]>("/sales", { page: 1, page_size: 10 }),
    enabled: can("sales"),
  });


  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-extrabold">مرحباً، {user?.full_name?.split(" ")[0]} 👋</h1>
          <p className="text-sm text-muted">نظرة عامة على أداء المتجر اليوم</p>
        </div>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {daily.isLoading ? (
          <Card><Spinner /></Card>
        ) : daily.isError ? (
          <Card><ErrorBox message={(daily.error as Error).message} onRetry={() => daily.refetch()} /></Card>
        ) : (
          <Kpi icon={<Receipt size={20} />} label="مبيعات اليوم" value={moneyEGP(daily.data?.total_sales ?? 0)} sub={`${daily.data?.invoice_count ?? 0} فاتورة`} />
        )}
        {monthly.isLoading ? (
          <Card><Spinner /></Card>
        ) : monthly.isError ? (
          <Card><p className="text-sm text-muted">التقرير الشهري غير متاح</p></Card>
        ) : (
          <Kpi icon={<TrendingUp size={20} />} label="مبيعات الشهر" value={moneyEGP(monthly.data?.total_sales ?? 0)} sub={`${monthly.data?.invoice_count ?? 0} فاتورة`} />
        )}
        {can("inventory") && (
          <Kpi
            icon={<AlertTriangle size={20} />}
            label="منتجات تحت الحد"
            value={lowStock.data ? String(lowStock.data.length) : "…"}
            sub="تحتاج إعادة طلب"
          />
        )}
        {can("finance") && (
          <Kpi icon={<Wallet size={20} />} label="محافظ الدفع" value="—" sub="تفاصيل في قسم المالية" />
        )}
      </div>

      {can("sales") && (
        <Card>
          <div className="mb-4 flex items-center justify-between">
            <h2 className="font-bold">آخر المبيعات</h2>
            <a href="#/sales" className="flex items-center gap-1 text-sm font-semibold text-brand">
              عرض الكل <ArrowLeft size={14} />
            </a>
          </div>
          {recent.isLoading ? (
            <div className="grid place-items-center p-8"><Spinner /></div>
          ) : recent.isError ? (
            <ErrorBox message={(recent.error as Error).message} onRetry={() => recent.refetch()} />
          ) : !recent.data?.length ? (
            <Empty text="لا توجد مبيعات بعد" hint="ابدأ من نقطة البيع" />
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-line text-start text-xs text-muted">
                    <th className="p-2 text-start">الفاتورة</th>
                    <th className="p-2 text-start">العميل</th>
                    <th className="p-2 text-start">الإجمالي</th>
                    <th className="p-2 text-start">الحالة</th>
                    <th className="p-2 text-start">التاريخ</th>
                  </tr>
                </thead>
                <tbody>
                  {recent.data.map((s) => (
                    <tr key={s.id} className="border-b border-line/60 last:border-0">
                      <td className="num p-2 font-semibold" dir="ltr">{s.invoice_number}</td>
                      <td className="p-2 text-muted">{s.customer_name ?? "نقدي"}</td>
                      <td className="num p-2 font-bold">{moneyEGP(s.total)}</td>
                      <td className="p-2">
                        <Badge tone={s.status === "cancelled" ? "danger" : s.is_credit ? "warning" : "success"}>
                          {s.status === "cancelled" ? "ملغاة" : s.is_credit ? "آجل" : "مكتملة"}
                        </Badge>
                      </td>
                      <td className="p-2 text-xs text-muted">{dateTime(s.created_at)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </Card>
      )}
    </div>
  );
}
