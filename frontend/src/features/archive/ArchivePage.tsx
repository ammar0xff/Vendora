import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { FileText, Printer , FileDown } from "lucide-react";
import { Skeleton } from "@/components/kit/skeleton";
import { api, openPrintDoc } from "@/lib/api";
import { dateTime } from "@/lib/format";
import {Card, Empty, ErrorBox, Input, Select} from "@/components/ui";

interface Doc {
  id: string; doc_number: string; doc_type: string; created_at: string;
  summary?: string | null;
}

const TYPES = [
  { v: "", l: "كل الأنواع" },
  { v: "sale_invoice", l: "فاتورة بيع" },
  { v: "purchase_order", l: "أمر شراء" },
  { v: "purchase_invoice", l: "فاتورة شراء" },
  { v: "dispatch_order", l: "إذن صرف" },
  { v: "goods_receipt", l: "استلام بضاعة" },
  { v: "shift_report", l: "تقرير وردية" },
  { v: "shift_handover", l: "تسليم عهدة" },
  { v: "inventory_report", l: "جرد مخزون" },
  { v: "quotation", l: "عرض سعر" },
];

export default function ArchivePage() {
  const [docType, setDocType] = useState("");
  const [search, setSearch] = useState("");

  const q = useQuery({
    queryKey: ["archive", docType, search],
    queryFn: () => api.get<Doc[]>("/archive", { doc_type: docType || undefined, search: search || undefined, limit: 60 }),
  });

  return (
    <div className="flex flex-col gap-6">
      <h1 className="text-2xl font-semibold tracking-tight">الأرشيف</h1>
      <Card className="flex flex-wrap gap-3 p-3">
        <Select className="w-auto" value={docType} onChange={(e) => setDocType(e.target.value)}>
          {TYPES.map((t) => <option key={t.v} value={t.v}>{t.l}</option>)}
        </Select>
        <Input placeholder="ابحث برقم المستند…" value={search} onChange={(e) => setSearch(e.target.value)} />
      </Card>

      {q.isLoading ? (
        <div className="flex flex-col gap-2" aria-busy="true" aria-label="جارٍ التحميل">
            <Skeleton className="h-10 w-full" />
            {Array.from({ length: 6 }).map((_, i) => <Skeleton key={i} className="h-12 w-full" />)}
          </div>
      ) : q.isError ? (
        <ErrorBox message={(q.error as Error).message} onRetry={() => q.refetch()} />
      ) : !q.data?.length ? (
        <Empty text="لا توجد مستندات مطابقة" hint="كل عملية بيع أو شراء أو صرف تؤرشف تلقائياً" />
      ) : (
        <Card className="overflow-x-auto p-0">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-line text-xs text-muted">
                <th className="p-3 text-start">المستند</th>
                <th className="hidden p-3 text-start sm:table-cell">النوع</th>
                <th className="p-3 text-start">التاريخ</th>
                <th className="p-3 text-start"></th>
              </tr>
            </thead>
            <tbody>
              {q.data.map((d) => (
                <tr key={d.id} className="border-b border-line/60 last:border-0 hover:bg-elevated">
                  <td className="num w-full max-w-0 truncate p-3 font-bold" dir="ltr">{d.doc_number}</td>
                  <td className="hidden p-3 sm:table-cell">
                    <span className="inline-flex items-center gap-1.5 text-muted">
                      <FileText size={16} />
                      {TYPES.find((t) => t.v === d.doc_type)?.l ?? d.doc_type}
                    </span>
                  </td>
                  <td className="p-3 text-xs text-muted">{dateTime(d.created_at)}</td>
                  <td className="p-3">
                    <div className="flex gap-1">
                      <button
                        onClick={() => openPrintDoc(`/print/archive/${d.id}`)}
                        className="rounded-md p-2 text-muted-foreground transition hover:bg-accent hover:text-accent-foreground"
                        aria-label="طباعة"
                      ><Printer size={16} /></button>
                      <button
                        onClick={() => openPrintDoc(`/print/pdf/archive/${d.id}`)}
                        className="rounded-md p-2 text-muted-foreground transition hover:bg-accent hover:text-accent-foreground"
                        aria-label="PDF"
                      ><FileDown size={16} /></button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </Card>
      )}
    </div>
  );
}
