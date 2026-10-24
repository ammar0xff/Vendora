import { useQuery } from "@tanstack/react-query";
import { api, docUrl } from "@/lib/api";
import { dateTime, moneyEGP } from "@/lib/format";
import { Badge, Card, Empty, ErrorBox, Spinner } from "@/components/ui";

/**
 * Generic real-data list pages for the secondary modules. Each module maps to
 * verified endpoints; column renderers are shared per value kind.
 */
type Row = Record<string, unknown>;

interface Column {
  key: string;
  label: string;
  kind?: "money" | "num" | "date" | "bool" | "badge" | "text";
}

interface ModuleDef {
  title: string;
  path: string;
  params?: Record<string, string | number | undefined>;
  listKey?: "items" | "data" | null; // null = plain array
  columns: Column[];
  note?: string;
}

const MODULES: Record<string, ModuleDef> = {
  inventory: {
    title: "المخزون", path: "/stock/valuation", listKey: null,
    columns: [
      { key: "product_name", label: "المنتج" },
      { key: "total_qty", label: "الكمية", kind: "num" },
      { key: "cost_value", label: "قيمة التكلفة", kind: "money" },
    ],
    note: "التقييم عبر جميع الفروع",
  },
  operations: {
    title: "سجل العمليات", path: "/operations/", listKey: null,
    columns: [
      { key: "doc_number", label: "المستند" },
      { key: "doc_type", label: "النوع" },
      { key: "created_at", label: "التاريخ", kind: "date" },
    ],
  },
  purchases: {
    title: "المشتريات", path: "/purchases", listKey: null,
    columns: [
      { key: "doc_number", label: "أمر الشراء" },
      { key: "supplier_name", label: "المورد" },
      { key: "total", label: "الإجمالي", kind: "money" },
      { key: "status", label: "الحالة", kind: "badge" },
      { key: "created_at", label: "التاريخ", kind: "date" },
    ],
  },
  customers: {
    title: "العملاء", path: "/customers", listKey: null,
    columns: [
      { key: "name", label: "الاسم" },
      { key: "phone", label: "الهاتف", kind: "num" },
      { key: "balance", label: "الرصيد", kind: "money" },
    ],
  },
  suppliers: {
    title: "الموردون", path: "/suppliers", listKey: null,
    columns: [
      { key: "name", label: "الاسم" },
      { key: "phone", label: "الهاتف", kind: "num" },
      { key: "balance", label: "الرصيد", kind: "money" },
    ],
  },
  finance: {
    title: "المالية", path: "/safes", listKey: null,
    columns: [
      { key: "name", label: "الخزنة" },
      { key: "safe_type", label: "النوع" },
      { key: "balance", label: "الرصيد", kind: "money" },
    ],
    note: "الخزائن — المحافظ والمصروفات والتقارير التفصيلية في المراحل القادمة",
  },
  hr: {
    title: "الموظفون", path: "/hr/employees", listKey: null,
    columns: [
      { key: "emp_code", label: "الكود", kind: "num" },
      { key: "name", label: "الاسم" },
      { key: "position", label: "الوظيفة" },
      { key: "monthly_salary", label: "الراتب", kind: "money" },
    ],
  },
  shifts: {
    title: "الورديات", path: "/shifts", listKey: null,
    columns: [
      { key: "warehouse_name", label: "الفرع" },
      { key: "status", label: "الحالة", kind: "badge" },
      { key: "opened_at", label: "الفتح", kind: "date" },
      { key: "closing_balance", label: "رصيد الإغلاق", kind: "money" },
    ],
  },
  archive: {
    title: "الأرشيف", path: "/archive", listKey: "items",
    columns: [
      { key: "doc_number", label: "المستند" },
      { key: "doc_type", label: "النوع" },
      { key: "created_at", label: "التاريخ", kind: "date" },
    ],
  },
  reports: {
    title: "التقارير", path: "/reports/sales/daily", listKey: null,
    columns: [
      { key: "date", label: "اليوم" },
      { key: "total_sales", label: "المبيعات", kind: "money" },
      { key: "invoice_count", label: "عدد الفواتير", kind: "num" },
    ],
    note: "تقرير المبيعات اليومية — تقارير أعمق في المراحل القادمة",
  },
  users: {
    title: "المستخدمون", path: "/users", listKey: null,
    columns: [
      { key: "username", label: "اسم المستخدم" },
      { key: "full_name", label: "الاسم" },
      { key: "role", label: "الدور", kind: "badge" },
      { key: "is_active", label: "نشط", kind: "bool" },
    ],
  },
  settings: {
    title: "الإعدادات", path: "/settings", listKey: null,
    columns: [
      { key: "store_name", label: "اسم المتجر" },
      { key: "store_phone", label: "الهاتف", kind: "num" },
      { key: "currency", label: "العملة" },
    ],
    note: "قراءة فقط في هذه المرحلة — التحرير الكامل قادم",
  },
};

function Cell({ col, row }: { col: Column; row: Row }) {
  const v = row[col.key];
  if (v === null || v === undefined) return <span className="text-muted">—</span>;
  switch (col.kind) {
    case "money":
      return <span className="num font-bold">{moneyEGP(String(v))}</span>;
    case "num":
      return <span className="num">{String(v)}</span>;
    case "date":
      return <span className="text-xs text-muted">{dateTime(String(v))}</span>;
    case "bool":
      return <Badge tone={v ? "success" : "muted"}>{v ? "نعم" : "لا"}</Badge>;
    case "badge":
      return <Badge tone="brand">{String(v)}</Badge>;
    default:
      return <span className="font-semibold">{String(v)}</span>;
  }
}

export default function ListPage({ module }: { module: string }) {
  const def = MODULES[module];
  const q = useQuery({
    queryKey: ["list", module],
    queryFn: async () => {
      const res = await api.get<unknown>(def.path, def.params);
      if (Array.isArray(res)) return res as Row[];
      const r = res as Record<string, unknown>;
      if (def.listKey && Array.isArray(r[def.listKey])) return r[def.listKey] as Row[];
      if (Array.isArray(r.items)) return r.items as Row[];
      if (Array.isArray(r.data)) return r.data as Row[];
      return [res as Row]; // single object (e.g. settings)
    },
  });

  const rows = q.data ?? [];

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-xl font-extrabold">{def.title}</h1>
        {(module === "customers" || module === "suppliers" || module === "purchases" || module === "sales") && (
          <a href={docUrl(`/export/${module === "purchases" ? "purchases" : module}`)} className="text-sm font-semibold text-brand">
            تصدير Excel
          </a>
        )}
      </div>
      {def.note && <p className="text-sm text-muted">{def.note}</p>}

      {q.isLoading ? (
        <Card className="grid place-items-center p-10"><Spinner /></Card>
      ) : q.isError ? (
        <ErrorBox message={(q.error as Error).message} onRetry={() => q.refetch()} />
      ) : !rows.length ? (
        <Empty text={`لا توجد بيانات في ${def.title}`} />
      ) : (
        <Card className="overflow-x-auto p-0">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-line text-xs text-muted">
                {def.columns.map((c) => <th key={c.key} className="p-3 text-start">{c.label}</th>)}
              </tr>
            </thead>
            <tbody>
              {rows.slice(0, 100).map((row, i) => (
                <tr key={(row.id as string) ?? i} className="border-b border-line/60 last:border-0 hover:bg-elevated">
                  {def.columns.map((c) => (
                    <td key={c.key} className="p-3"><Cell col={c} row={row} /></td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </Card>
      )}
    </div>
  );
}
