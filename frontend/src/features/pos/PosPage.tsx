import { useEffect, useMemo, useRef, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Minus, Plus, Printer, Search, ShoppingCart, Trash2, X } from "lucide-react";
import { api, ApiError, docUrl } from "@/lib/api";
import { D, money } from "@/lib/format";
import { Button, Card, ErrorBox, Input, Modal, Select, Spinner } from "@/components/ui";

interface Warehouse { id: string; name: string }
interface Product {
  id: string; name: string; barcode: string | null; code: string | null; unit: string;
  retail_price: string; wholesale_price: string; image_url: string | null;
}
interface CartItem { product: Product; qty: number; discount: string }
interface SaleResult { id: string; invoice_number: string }

export default function PosPage() {
  const qc = useQueryClient();
  const [search, setSearch] = useState("");
  const [cart, setCart] = useState<CartItem[]>([]);
  const [mode, setMode] = useState<"retail" | "wholesale">("retail");
  const [payOpen, setPayOpen] = useState(false);
  const [payMethod, setPayMethod] = useState("cash");
  const [paidInput, setPaidInput] = useState("");
  const [saleDone, setSaleDone] = useState<SaleResult | null>(null);
  const [openShiftFor, setOpenShiftFor] = useState<Warehouse | null>(null);
  const [initialAmount, setInitialAmount] = useState("0");
  const barcodeRef = useRef<HTMLInputElement>(null);

  const wh = useQuery({ queryKey: ["warehouses"], queryFn: () => api.get<Warehouse[]>("/stock/warehouses") });
  const [warehouseId, setWarehouseId] = useState<string>("");
  useEffect(() => {
    if (!warehouseId && wh.data?.length) setWarehouseId(wh.data[0].id);
  }, [wh.data, warehouseId]);

  const shift = useQuery({
    queryKey: ["shift", "current", warehouseId],
    queryFn: async () => {
      try {
        return await api.get<{ id: string }>("/shifts/current", { warehouse_id: warehouseId });
      } catch (e) {
        if (e instanceof ApiError && e.status === 404) return null;
        throw e;
      }
    },
    enabled: !!warehouseId,
    retry: false,
  });

  const products = useQuery({
    queryKey: ["pos-products", search],
    queryFn: () => api.get<{ items: Product[] }>("/products", { search: search || undefined, page: 1, page_size: 40, is_active: "true" }),
  });

  function addToCart(p: Product) {
    setCart((c) => {
      const i = c.findIndex((x) => x.product.id === p.id);
      if (i >= 0) {
        const next = [...c];
        next[i] = { ...next[i], qty: next[i].qty + 1 };
        return next;
      }
      return [...c, { product: p, qty: 1, discount: "0" }];
    });
  }

  async function onBarcode(e: React.FormEvent) {
    e.preventDefault();
    const code = (barcodeRef.current?.value ?? "").trim();
    if (!code) return;
    try {
      const p = await api.get<Product>(`/products/barcode/${encodeURIComponent(code)}`);
      if (p) addToCart(p);
    } catch {
      /* unknown barcode — non-disruptive */
    }
    if (barcodeRef.current) barcodeRef.current.value = "";
    barcodeRef.current?.focus();
  }

  const unitPrice = (p: Product) => D(mode === "wholesale" ? p.wholesale_price : p.retail_price);
  const subtotal = useMemo(() => cart.reduce((s, i) => s.plus(unitPrice(i.product).times(i.qty).minus(D(i.discount))), D(0)), [cart, mode]);
  const total = subtotal;

  const checkout = useMutation({
    mutationFn: () =>
      api.post<SaleResult>("/sales", {
        warehouse_id: warehouseId,
        shift_id: shift.data?.id ?? null,
        sale_mode: mode,
        items: cart.map((i) => ({
          product_id: i.product.id,
          qty: i.qty,
          unit_price: unitPrice(i.product).toNumber(),
          discount: D(i.discount).toNumber(),
        })),
        payment_method: payMethod,
        paid_amount: paidInput ? D(paidInput).toNumber() : undefined,
      }),
    onSuccess: (r) => {
      setSaleDone(r);
      setCart([]);
      setPayOpen(false);
      setPaidInput("");
      qc.invalidateQueries({ queryKey: ["sales"] });
      qc.invalidateQueries({ queryKey: ["report"] });
    },
  });

  const openShift = useMutation({
    mutationFn: () => api.post("/shifts/open", { warehouse_id: openShiftFor!.id, initial_amount: D(initialAmount).toNumber() }),
    onSuccess: () => {
      setOpenShiftFor(null);
      setInitialAmount("0");
      qc.invalidateQueries({ queryKey: ["shift"] });
    },
  });

  const shiftMissing = shift.data === null;

  return (
    <div className="grid gap-4 lg:grid-cols-[1fr_400px]">
      {/* Catalog side */}
      <div className="min-w-0 space-y-3">
        <Card className="flex flex-wrap items-center gap-2 p-3">
          <form onSubmit={onBarcode} className="flex min-w-[220px] flex-1 items-center gap-2">
            <Input ref={barcodeRef} placeholder="امسح الباركود هنا…" className="font-mono" autoFocus />
            <Button type="submit" variant="outline" aria-label="إضافة بالباركود"><Search size={16} /></Button>
          </form>
          <Select value={warehouseId} onChange={(e) => setWarehouseId(e.target.value)} className="w-auto">
            {wh.data?.map((w) => <option key={w.id} value={w.id}>{w.name}</option>)}
          </Select>
          <div className="flex overflow-hidden rounded-lg border border-line">
            {(["retail", "wholesale"] as const).map((m) => (
              <button
                key={m}
                onClick={() => setMode(m)}
                className={`px-3 py-2 text-sm font-semibold ${mode === m ? "bg-brand text-brand-ink" : "text-muted hover:bg-elevated"}`}
              >
                {m === "retail" ? "تجزئة" : "جملة"}
              </button>
            ))}
          </div>
        </Card>

        <Card className="flex items-center gap-2 p-3">
          <Input placeholder="ابحث عن منتج بالاسم…" value={search} onChange={(e) => setSearch(e.target.value)} />
        </Card>

        {products.isLoading ? (
          <Card className="grid place-items-center p-10"><Spinner /></Card>
        ) : products.isError ? (
          <ErrorBox message={(products.error as Error).message} onRetry={() => products.refetch()} />
        ) : !products.data!.items.length ? (
          <Card className="p-10 text-center text-muted">لا توجد منتجات مطابقة</Card>
        ) : (
          <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 xl:grid-cols-4">
            {products.data!.items.map((p) => (
              <button
                key={p.id}
                onClick={() => addToCart(p)}
                className="group flex flex-col overflow-hidden rounded-xl border border-line bg-surface text-start transition hover:border-brand hover:shadow-lg"
              >
                <div className="aspect-square bg-elevated">
                  {p.image_url ? (
                    <img src={p.image_url} alt="" className="h-full w-full object-cover" loading="lazy" />
                  ) : (
                    <div className="grid h-full place-items-center text-3xl opacity-30">🛍️</div>
                  )}
                </div>
                <div className="flex flex-col gap-1 p-3">
                  <span className="line-clamp-2 min-h-10 text-sm font-bold">{p.name}</span>
                  <span className="num text-sm font-extrabold text-brand">{money(mode === "wholesale" ? p.wholesale_price : p.retail_price)} ج.م</span>
                  <span className="text-xs text-muted">{p.unit} {p.code ? `· ${p.code}` : ""}</span>
                </div>
              </button>
            ))}
          </div>
        )}
      </div>

      {/* Cart side */}
      <div className="flex flex-col gap-3">
        <Card className="flex items-center justify-between p-4">
          <span className="flex items-center gap-2 font-bold"><ShoppingCart size={18} /> الفاتورة</span>
          {cart.length > 0 && (
            <button onClick={() => setCart([])} className="flex items-center gap-1 text-xs font-semibold text-danger">
              <Trash2 size={14} /> تفريغ
            </button>
          )}
        </Card>

        {shiftMissing && (
          <Card className="border-warning/40 bg-warning/10 p-4 text-sm">
            <p className="mb-2 font-bold">لا توجد وردية مفتوحة لهذا الفرع</p>
            <p className="mb-3 text-muted">يجب فتح وردية قبل إتمام البيع.</p>
            <Button onClick={() => setOpenShiftFor(wh.data?.find((w) => w.id === warehouseId) ?? null)}>
              فتح وردية
            </Button>
          </Card>
        )}

        <Card className="flex-1 overflow-auto p-0">
          {!cart.length ? (
            <div className="grid place-items-center p-10 text-center text-sm text-muted">
              الفاتورة فارغة — امسح باركود أو اختر منتجاً
            </div>
          ) : (
            <ul className="divide-y divide-line">
              {cart.map((i, idx) => (
                <li key={i.product.id} className="flex items-center gap-2 p-3">
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-bold">{i.product.name}</p>
                    <p className="num text-xs text-muted">{money(unitPrice(i.product))} × {i.qty} = {money(unitPrice(i.product).times(i.qty))}</p>
                  </div>
                  <div className="flex items-center gap-1">
                    <button
                      className="rounded-md border border-line p-1 hover:bg-elevated"
                      onClick={() => setCart((c) => c.map((x, j) => j === idx ? { ...x, qty: Math.max(1, x.qty - 1) } : x))}
                      aria-label="تقليل الكمية"
                    ><Minus size={14} /></button>
                    <input
                      className="num w-12 rounded-md border border-line bg-surface p-1 text-center text-sm"
                      value={i.qty}
                      onChange={(e) => {
                        const v = Math.max(1, parseInt(e.target.value || "1", 10) || 1);
                        setCart((c) => c.map((x, j) => j === idx ? { ...x, qty: v } : x));
                      }}
                      aria-label="الكمية"
                    />
                    <button
                      className="rounded-md border border-line p-1 hover:bg-elevated"
                      onClick={() => setCart((c) => c.map((x, j) => j === idx ? { ...x, qty: x.qty + 1 } : x))}
                      aria-label="زيادة الكمية"
                    ><Plus size={14} /></button>
                    <button
                      className="rounded-md p-1 text-danger hover:bg-elevated"
                      onClick={() => setCart((c) => c.filter((_, j) => j !== idx))}
                      aria-label="حذف"
                    ><X size={14} /></button>
                  </div>
                </li>
              ))}
            </ul>
          )}
        </Card>

        <Card className="space-y-3 p-4">
          <div className="flex items-baseline justify-between">
            <span className="text-sm text-muted">الإجمالي</span>
            <span className="num text-2xl font-black text-brand">{money(total)} ج.م</span>
          </div>
          <Button
            className="w-full py-3 text-base"
            disabled={!cart.length || shiftMissing || shift.isLoading}
            onClick={() => { setPaidInput(total.toFixed(2)); setPayOpen(true); }}
          >
            إتمام الدفع (F2)
          </Button>
        </Card>
      </div>

      {/* Payment modal */}
      <Modal open={payOpen} onClose={() => setPayOpen(false)} title="إتمام الدفع">
        <div className="space-y-4">
          <div className="rounded-xl bg-elevated p-4 text-center">
            <p className="text-sm text-muted">المطلوب</p>
            <p className="num text-3xl font-black text-brand">{money(total)} ج.م</p>
          </div>
          <div>
            <label className="mb-1 block text-sm font-medium">طريقة الدفع</label>
            <Select value={payMethod} onChange={(e) => setPayMethod(e.target.value)}>
              <option value="cash">نقدي</option>
              <option value="wallet">محفظة</option>
              <option value="bank">تحويل بنكي</option>
              <option value="cheque">شيك</option>
            </Select>
          </div>
          <div>
            <label className="mb-1 block text-sm font-medium">المبلغ المدفوع</label>
            <Input
              className="num text-lg"
              inputMode="decimal"
              value={paidInput}
              onChange={(e) => setPaidInput(e.target.value)}
            />
            <p className="mt-1 text-xs text-muted">
              الباقي: <span className="num font-bold">{money(D(paidInput || "0").minus(total))}</span>
            </p>
          </div>
          {checkout.isError && <ErrorBox message={(checkout.error as Error).message} />}
          <Button
            className="w-full py-3"
            disabled={checkout.isPending || D(paidInput || "0").lt(0)}
            onClick={() => checkout.mutate()}
          >
            {checkout.isPending ? <Spinner /> : "تأكيد البيع"}
          </Button>
        </div>
      </Modal>

      {/* Shift-open modal */}
      <Modal open={!!openShiftFor} onClose={() => setOpenShiftFor(null)} title="فتح وردية">
        <div className="space-y-4">
          <p className="text-sm text-muted">الفرع: <strong>{openShiftFor?.name}</strong></p>
          <div>
            <label className="mb-1 block text-sm font-medium">العهدة الافتتاحية (ج.م)</label>
            <Input className="num" inputMode="decimal" value={initialAmount} onChange={(e) => setInitialAmount(e.target.value)} />
          </div>
          {openShift.isError && <ErrorBox message={(openShift.error as Error).message} />}
          <Button className="w-full" disabled={openShift.isPending} onClick={() => openShift.mutate()}>
            {openShift.isPending ? <Spinner /> : "فتح الوردية"}
          </Button>
        </div>
      </Modal>

      {/* Success modal */}
      <Modal open={!!saleDone} onClose={() => setSaleDone(null)} title="تم البيع بنجاح">
        <div className="space-y-4 text-center">
          <p className="text-sm text-muted">رقم الفاتورة</p>
          <p className="num text-2xl font-black">{saleDone?.invoice_number}</p>
          <a
            href={docUrl(`/print/sale/${saleDone?.id}`)}
            target="_blank"
            rel="noreferrer"
            className="inline-flex items-center gap-2 rounded-lg bg-brand px-5 py-2.5 font-semibold text-brand-ink"
          >
            <Printer size={16} /> طباعة الفاتورة
          </a>
        </div>
      </Modal>
    </div>
  );
}
