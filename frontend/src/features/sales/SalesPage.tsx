import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Printer, Undo2 } from "lucide-react";
import { api, docUrl } from "@/lib/api";
import { dateTime, moneyEGP } from "@/lib/format";
import { Badge, Button, Card, Empty, ErrorBox, Input, Modal, Spinner } from "@/components/ui";

interface SaleRow {
  id: string; invoice_number: string; total: string; net_total: string; paid_amount: string;
  status: string; is_credit: boolean; created_at: string; customer_name: string | null;
  payment_method: string | null; sale_mode: string;
}
interface SaleItemRow {
  product_id?: string; product_name: string; qty: number;
  unit_price: string; discount: string; returned_qty?: number;
}
interface SaleDetail extends SaleRow {
  items?: SaleItemRow[];
}

export default function SalesPage() {
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState("");
  const [detailId, setDetailId] = useState<string | null>(null);
  const [returnQty, setReturnQty] = useState<Record<string, string>>({});

  const cancelSale = useMutation({
    mutationFn: (id: string) => api.put(`/sales/${id}/cancel`),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["sales"] }); qc.invalidateQueries({ queryKey: ["sale"] }); },
  });

  const fullReturn = useMutation({
    mutationFn: (id: string) => api.post(`/sales/${id}/return`),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["sales"] }); qc.invalidateQueries({ queryKey: ["sale"] }); },
  });

  const partialReturn = useMutation({
    mutationFn: (id: string) =>
      api.post(`/sales/${id}/partial-return`, {
        items: Object.entries(returnQty)
          .map(([product_id, q]) => ({ product_id, qty: Number(q) }))
          .filter((i) => i.qty > 0),
      }),
    onSuccess: () => { setReturnQty({}); qc.invalidateQueries({ queryKey: ["sales"] }); qc.invalidateQueries({ queryKey: ["sale"] }); },
  });

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
            {!!detail.data!.items?.length && detail.data!.status !== "cancelled" && (
              <div className="rounded-xl border border-line p-3">
                <p className="mb-2 flex items-center gap-2 text-sm font-bold"><Undo2 size={15} /> مرتجع جزئي</p>
                <div className="space-y-2">
                  {detail.data!.items.map((it, i) => (
                    <div key={i} className="flex items-center justify-between gap-2 text-sm">
                      <span className="min-w-0 flex-1 truncate">{it.product_name} <span className="num text-muted">(مبيع {it.qty})</span></span>
                      <input
                        className="num w-20 rounded-md border border-line bg-surface p-1.5 text-center"
                        inputMode="decimal"
                        placeholder="0"
                        value={returnQty[it.product_id ?? ""] ?? ""}
                        onChange={(e) => setReturnQty((r) => ({ ...r, [it.product_id ?? ""]: e.target.value }))}
                        aria-label={`كمية مرتجع ${it.product_name}`}
                      />
                    </div>
                  ))}
                </div>
                {partialReturn.isError && <p className="mt-2 text-sm text-danger">{(partialReturn.error as Error).message}</p>}
                <Button
                  className="mt-3 w-full"
                  disabled={partialReturn.isPending || !Object.values(returnQty).some((v) => Number(v) > 0)}
                  onClick={() => detailId && partialReturn.mutate(detailId)}
                >
                  {partialReturn.isPending ? <Spinner /> : "تنفيذ المرتجع الجزئي"}
                </Button>
              </div>
            )}
            {detail.data!.status !== "cancelled" && (
              <div className="flex gap-2">
                <Button variant="outline" onClick={() => detailId && fullReturn.mutate(detailId)} disabled={fullReturn.isPending}>
                  {fullReturn.isPending ? <Spinner /> : "مرتجع كامل"}
                </Button>
                <Button variant="danger" onClick={() => detailId && cancelSale.mutate(detailId)} disabled={cancelSale.isPending}>
                  {cancelSale.isPending ? <Spinner /> : "إلغاء الفاتورة"}
                </Button>
              </div>
            )}
            {(cancelSale.isError || fullReturn.isError) && (
              <ErrorBox message={((cancelSale.error ?? fullReturn.error) as Error).message} />
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
