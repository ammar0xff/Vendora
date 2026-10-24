import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Printer } from "lucide-react";
import { api, docUrl } from "@/lib/api";
import { dateTime, moneyEGP } from "@/lib/format";
import { Badge, Button, Card, Empty, ErrorBox, Input, Modal, Spinner } from "@/components/ui";

interface SaleRow {
  id: string; invoice_number: string; total: string; net_total: string; paid_amount: string;
  status: string; is_credit: boolean; created_at: string; customer_name: string | null;
  payment_method: string | null; sale_mode: string;
}
interface SaleDetail extends SaleRow {
  items?: { product_name: string; qty: number; unit_price: string; discount: string }[];
}

export default function SalesPage() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState("");
  const [detailId, setDetailId] = useState<string | null>(null);

  const list = useQuery({
    queryKey: ["sales", page],
    queryFn: () => api.get<SaleRow[]>("/sales", { page, page_size: 25, search: search || undefined }),
  });

  const detail = useQuery({
    queryKey: ["sale", detailId],
    queryFn: () => api.get<SaleDetail>(`/sales/${detailId}`),
    enabled: !!detailId,
  });

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-xl font-extrabold">المبيعات</h1>
        <a href={docUrl("/export/sales")} className="text-sm font-semibold text-brand">تصدير Excel</a>
      </div>

      <Card className="flex items-center gap-2 p-3">
        <Input placeholder="ابحث برقم الفاتورة…" value={search} onChange={(e) => setSearch(e.target.value)} />
      </Card>

      {list.isLoading ? (
        <Card className="grid place-items-center p-10"><Spinner /></Card>
      ) : list.isError ? (
        <ErrorBox message={(list.error as Error).message} onRetry={() => list.refetch()} />
      ) : !list.data?.length ? (
        <Empty text="لا توجد مبيعات" />
      ) : (
        <Card className="overflow-x-auto p-0">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-line text-xs text-muted">
                <th className="p-3 text-start">الفاتورة</th>
                <th className="p-3 text-start">العميل</th>
                <th className="p-3 text-start">الإجمالي</th>
                <th className="p-3 text-start">المدفوع</th>
                <th className="p-3 text-start">الحالة</th>
                <th className="p-3 text-start">التاريخ</th>
                <th className="p-3 text-start"></th>
              </tr>
            </thead>
            <tbody>
              {list.data.map((s) => (
                <tr key={s.id} className="border-b border-line/60 last:border-0 hover:bg-elevated">
                  <td className="num p-3 font-bold" dir="ltr">{s.invoice_number}</td>
                  <td className="p-3">{s.customer_name ?? "نقدي"}</td>
                  <td className="num p-3 font-bold">{moneyEGP(s.total)}</td>
                  <td className="num p-3">{moneyEGP(s.paid_amount)}</td>
                  <td className="p-3">
                    <Badge tone={s.status === "cancelled" ? "danger" : s.is_credit ? "warning" : "success"}>
                      {s.status === "cancelled" ? "ملغاة" : s.is_credit ? "آجل" : "مكتملة"}
                    </Badge>
                  </td>
                  <td className="p-3 text-xs text-muted">{dateTime(s.created_at)}</td>
                  <td className="p-3">
                    <div className="flex gap-1">
                      <button
                        className="rounded-md p-1.5 text-muted hover:bg-elevated hover:text-ink"
                        onClick={() => setDetailId(s.id)}
                        aria-label="تفاصيل"
                      >👁️</button>
                      <a
                        href={docUrl(`/print/sale/${s.id}`)}
                        target="_blank"
                        rel="noreferrer"
                        className="rounded-md p-1.5 text-muted hover:bg-elevated hover:text-ink"
                        aria-label="طباعة"
                      ><Printer size={16} /></a>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </Card>
      )}

      {list.data && list.data.length === 25 && (
        <div className="flex items-center justify-center gap-3 text-sm">
          <Button variant="outline" disabled={page <= 1} onClick={() => setPage((p) => p - 1)}>السابق</Button>
          <span className="num text-muted">صفحة {page}</span>
          <Button variant="outline" onClick={() => setPage((p) => p + 1)}>التالي</Button>
        </div>
      )}

      <Modal open={!!detailId} onClose={() => setDetailId(null)} title={`فاتورة ${detail.data?.invoice_number ?? ""}`} wide>
        {detail.isLoading ? (
          <div className="grid place-items-center p-8"><Spinner /></div>
        ) : detail.isError ? (
          <ErrorBox message={(detail.error as Error).message} />
        ) : (
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-2 text-sm sm:grid-cols-4">
              <div><p className="text-muted">الإجمالي</p><p className="num font-bold">{moneyEGP(detail.data!.total)}</p></div>
              <div><p className="text-muted">المدفوع</p><p className="num font-bold">{moneyEGP(detail.data!.paid_amount)}</p></div>
              <div><p className="text-muted">النوع</p><p>{detail.data!.sale_mode === "retail" ? "تجزئة" : "جملة"}</p></div>
              <div><p className="text-muted">التاريخ</p><p className="text-xs">{dateTime(detail.data!.created_at)}</p></div>
            </div>
            {!!detail.data!.items?.length && (
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-line text-xs text-muted">
                    <th className="p-2 text-start">المنتج</th>
                    <th className="p-2 text-start">الكمية</th>
                    <th className="p-2 text-start">السعر</th>
                    <th className="p-2 text-start">الخصم</th>
                  </tr>
                </thead>
                <tbody>
                  {detail.data!.items.map((it, i) => (
                    <tr key={i} className="border-b border-line/60 last:border-0">
                      <td className="p-2 font-semibold">{it.product_name}</td>
                      <td className="num p-2">{it.qty}</td>
                      <td className="num p-2">{moneyEGP(it.unit_price)}</td>
                      <td className="num p-2">{moneyEGP(it.discount ?? "0")}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
            <a
              href={docUrl(`/print/sale/${detailId}`)}
              target="_blank"
              rel="noreferrer"
              className="inline-flex items-center gap-2 rounded-lg bg-brand px-4 py-2 text-sm font-semibold text-brand-ink"
            >
              <Printer size={16} /> طباعة الفاتورة
            </a>
          </div>
        )}
      </Modal>
    </div>
  );
}
