import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Plus, Search } from "lucide-react";
import { api } from "@/lib/api";
import { money } from "@/lib/format";
import { Badge, Button, Card, Empty, ErrorBox, Input, Modal, Select, Spinner } from "@/components/ui";

interface Product {
  id: string; name: string; code: string | null; barcode: string | null; unit: string;
  retail_price: string; wholesale_price: string; cost_price: string; company: string | null;
  size: string | null; is_active: boolean; subcategory_id: string | null;
}
interface Subcategory { id: string; name: string; category_id: string }

export default function ProductsPage() {
  const qc = useQueryClient();
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [editing, setEditing] = useState<Partial<Product> | null>(null);
  const [form, setForm] = useState({ name: "", barcode: "", unit: "قطعة", retail_price: "", wholesale_price: "", cost_price: "", subcategory_id: "" });

  const list = useQuery({
    queryKey: ["products", search, page],
    queryFn: () => api.get<{ items: Product[]; total: number; pages: number }>("/products", { search: search || undefined, page, page_size: 25 }),
  });
  const subs = useQuery({ queryKey: ["subcategories"], queryFn: () => api.get<Subcategory[]>("/subcategories") });

  function openNew() {
    setForm({ name: "", barcode: "", unit: "قطعة", retail_price: "", wholesale_price: "", cost_price: "", subcategory_id: "" });
    setEditing({});
  }
  function openEdit(p: Product) {
    setForm({
      name: p.name, barcode: p.barcode ?? "", unit: p.unit,
      retail_price: p.retail_price, wholesale_price: p.wholesale_price,
      cost_price: p.cost_price, subcategory_id: p.subcategory_id ?? "",
    });
    setEditing(p);
  }

  const save = useMutation({
    mutationFn: () => {
      const body = {
        name: form.name, barcode: form.barcode || null, unit: form.unit,
        retail_price: form.retail_price, wholesale_price: form.wholesale_price,
        cost_price: form.cost_price, subcategory_id: form.subcategory_id || null,
      };
      return editing?.id
        ? api.put(`/products/${editing.id}`, body)
        : api.post("/products", body);
    },
    onSuccess: () => {
      setEditing(null);
      qc.invalidateQueries({ queryKey: ["products"] });
    },
  });

  const totalPages = list.data?.pages ?? 1;

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-xl font-extrabold">المنتجات</h1>
        <Button onClick={openNew}><Plus size={16} /> منتج جديد</Button>
      </div>

      <Card className="flex items-center gap-2 p-3">
        <Search size={16} className="text-muted" />
        <Input
          placeholder="ابحث بالاسم أو الكود أو الباركود…"
          value={search}
          onChange={(e) => { setSearch(e.target.value); setPage(1); }}
        />
      </Card>

      {list.isLoading ? (
        <Card className="grid place-items-center p-10"><Spinner /></Card>
      ) : list.isError ? (
        <ErrorBox message={(list.error as Error).message} onRetry={() => list.refetch()} />
      ) : !list.data!.items.length ? (
        <Empty text="لا توجد منتجات" hint="أضف أول منتج" />
      ) : (
        <Card className="overflow-x-auto p-0">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-line text-xs text-muted">
                <th className="p-3 text-start">الكود</th>
                <th className="p-3 text-start">الاسم</th>
                <th className="p-3 text-start">الشركة</th>
                <th className="p-3 text-start">تجزئة</th>
                <th className="p-3 text-start">جملة</th>
                <th className="p-3 text-start">الوحدة</th>
                <th className="p-3 text-start">الحالة</th>
              </tr>
            </thead>
            <tbody>
              {list.data!.items.map((p) => (
                <tr
                  key={p.id}
                  className="cursor-pointer border-b border-line/60 last:border-0 hover:bg-elevated"
                  onClick={() => openEdit(p)}
                >
                  <td className="num p-3 text-xs text-muted" dir="ltr">{p.code ?? "—"}</td>
                  <td className="p-3 font-semibold">{p.name}</td>
                  <td className="p-3 text-muted">{p.company ?? "—"}</td>
                  <td className="num p-3 font-bold">{money(p.retail_price)}</td>
                  <td className="num p-3">{money(p.wholesale_price)}</td>
                  <td className="p-3 text-muted">{p.unit}</td>
                  <td className="p-3">
                    <Badge tone={p.is_active ? "success" : "muted"}>{p.is_active ? "نشط" : "موقوف"}</Badge>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </Card>
      )}

      {totalPages > 1 && (
        <div className="flex items-center justify-center gap-3 text-sm">
          <Button variant="outline" disabled={page <= 1} onClick={() => setPage((p) => p - 1)}>السابق</Button>
          <span className="num text-muted">{page} / {totalPages}</span>
          <Button variant="outline" disabled={page >= totalPages} onClick={() => setPage((p) => p + 1)}>التالي</Button>
        </div>
      )}

      <Modal open={!!editing} onClose={() => setEditing(null)} title={editing?.id ? "تعديل منتج" : "منتج جديد"}>
        <div className="space-y-3">
          <div>
            <label className="mb-1 block text-sm font-medium">الاسم *</label>
            <Input value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="mb-1 block text-sm font-medium">الباركود</label>
              <Input className="num" dir="ltr" value={form.barcode} onChange={(e) => setForm({ ...form, barcode: e.target.value })} />
            </div>
            <div>
              <label className="mb-1 block text-sm font-medium">الوحدة</label>
              <Input value={form.unit} onChange={(e) => setForm({ ...form, unit: e.target.value })} />
            </div>
          </div>
          <div className="grid grid-cols-3 gap-3">
            <div>
              <label className="mb-1 block text-sm font-medium">تجزئة *</label>
              <Input className="num" inputMode="decimal" value={form.retail_price} onChange={(e) => setForm({ ...form, retail_price: e.target.value })} />
            </div>
            <div>
              <label className="mb-1 block text-sm font-medium">جملة</label>
              <Input className="num" inputMode="decimal" value={form.wholesale_price} onChange={(e) => setForm({ ...form, wholesale_price: e.target.value })} />
            </div>
            <div>
              <label className="mb-1 block text-sm font-medium">التكلفة</label>
              <Input className="num" inputMode="decimal" value={form.cost_price} onChange={(e) => setForm({ ...form, cost_price: e.target.value })} />
            </div>
          </div>
          <div>
            <label className="mb-1 block text-sm font-medium">التصنيف</label>
            <Select value={form.subcategory_id} onChange={(e) => setForm({ ...form, subcategory_id: e.target.value })}>
              <option value="">— بدون —</option>
              {subs.data?.map((s) => <option key={s.id} value={s.id}>{s.name}</option>)}
            </Select>
          </div>
          {save.isError && <ErrorBox message={(save.error as Error).message} />}
          <Button
            className="w-full"
            disabled={save.isPending || !form.name || !form.retail_price}
            onClick={() => save.mutate()}
          >
            {save.isPending ? <Spinner /> : "حفظ"}
          </Button>
        </div>
      </Modal>
    </div>
  );
}
