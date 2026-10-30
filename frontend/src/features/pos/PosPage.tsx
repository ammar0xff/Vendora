import { useEffect, useMemo, useRef, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { CloudUpload, Minus, Package, Pause, Play, Plus, Printer, ScanBarcode, ShoppingCart, Trash2, TriangleAlert, X } from "lucide-react";
import { Skeleton } from "@/components/kit/skeleton";
import { api, ApiError, openPrintDoc } from "@/lib/api";
import { D, money } from "@/lib/format";
import { Button, Card, ConfirmDialog, ErrorBox, Input, Modal, Select, Spinner, useToast } from "@/components/ui";
import { Stagger, StaggerItem } from "@/components/motion";
import { InputGroup, InputGroupAddon, InputGroupInput } from "@/components/kit/input-group";
import { Kbd } from "@/components/kit/kbd";
import { Separator } from "@/components/kit/separator";
import { Badge as KitBadge } from "@/components/kit/badge";
import { PageHeader } from "@/components/app/shared";
import { enqueueSale, listQueue, replayQueue, removeSale, type QueuedSale } from "@/lib/offline";

interface Warehouse { id: string; name: string }
interface Product {
  id: string; name: string; barcode: string | null; code: string | null; unit: string;
  retail_price: string; wholesale_price: string; image_url: string | null;
}
interface Customer { id: string; name: string; balance: string; credit_limit: string | null }
interface Wallet { id: string; name: string; type: string }
interface CartItem { product: Product; qty: number; discount: string }
interface SplitPart { method: string; amount: string; wallet_id: string }
interface SaleResult { id: string; invoice_number: string }
interface HeldBill { id: string; cart: CartItem[]; mode: "retail" | "wholesale"; at: string }

const HELD_KEY = "vendora.held_bills";

function buildSaleBody(args: {
  warehouseId: string; shiftId: string | null; mode: "retail" | "wholesale";
  customerId: string; cart: CartItem[]; isCredit: boolean; cashInput: string;
  split: SplitPart[]; walletId: string; paidSoFar: { toString: () => string }; total: { toString: () => string };
}) {
  const payments = args.split.length
    ? [
        ...(D(args.cashInput || "0").gt(0) ? [{ method: "cash", amount: D(args.cashInput).toNumber() }] : []),
        ...args.split
            .filter((p) => D(p.amount || "0").gt(0))
            .map((p) => ({
              method: p.method,
              amount: D(p.amount).toNumber(),
              wallet_id: p.method === "wallet" && p.wallet_id ? p.wallet_id : undefined,
            })),
      ]
    : undefined;
  return {
    warehouse_id: args.warehouseId,
    shift_id: args.shiftId,
    sale_mode: args.mode,
    customer_id: args.customerId || null,
    items: args.cart.map((i) => ({
      product_id: i.product.id,
      qty: i.qty,
      unit_price: D(args.mode === "wholesale" ? i.product.wholesale_price : i.product.retail_price).toNumber(),
      discount: D(i.discount).toNumber(),
    })),
    is_credit: args.isCredit,
    payment_method: args.isCredit ? "credit" : payments ? "cash" : args.walletId ? "wallet" : "cash",
    wallet_id: !args.isCredit && !payments && args.walletId ? args.walletId : null,
    paid_amount: Number(args.paidSoFar.toString()),
    payments,
  };
}

export default function PosPage() {
  const qc = useQueryClient();
  const [search, setSearch] = useState("");
  const [cart, setCart] = useState<CartItem[]>([]);
  const [mode, setMode] = useState<"retail" | "wholesale">("retail");
  const [payOpen, setPayOpen] = useState(false);
  const [isCredit, setIsCredit] = useState(false);
  const [customerId, setCustomerId] = useState("");
  const [split, setSplit] = useState<SplitPart[]>([]);
  const [cashInput, setCashInput] = useState("");
  const [walletId, setWalletId] = useState("");
  const [saleDone, setSaleDone] = useState<SaleResult | null>(null);
  const [held, setHeld] = useState<HeldBill[]>(() => {
    try { return JSON.parse(localStorage.getItem(HELD_KEY) ?? "[]"); } catch { return []; }
  });
  const [resumeOpen, setResumeOpen] = useState(false);
  const [openShiftFor, setOpenShiftFor] = useState<Warehouse | null>(null);
  const [initialAmount, setInitialAmount] = useState("0");
  const barcodeRef = useRef<HTMLInputElement>(null);
  const [confirmClear, setConfirmClear] = useState(false);
  const { toast } = useToast();

  const wh = useQuery({ queryKey: ["warehouses"], queryFn: () => api.get<Warehouse[]>("/stock/warehouses") });
  const [warehouseId, setWarehouseId] = useState("");
  useEffect(() => {
    if (!warehouseId && wh.data?.length) setWarehouseId(wh.data[0].id);
  }, [wh.data, warehouseId]);

  const customers = useQuery({ queryKey: ["pos-customers"], queryFn: () => api.get<Customer[]>("/customers"), enabled: payOpen });
  const wallets = useQuery({ queryKey: ["pos-wallets"], queryFn: () => api.get<Wallet[]>("/wallets"), enabled: payOpen });

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

  const customer = customers.data?.find((c) => c.id === customerId) ?? null;
  const shiftMissing = shift.data === null;

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

  async function scanBarcode(code: string) {
    if (!code) return;
    try {
      const p = await api.get<Product>(`/products/barcode/${encodeURIComponent(code)}`);
      if (p) addToCart(p);
    } catch {
      /* unknown barcode — non-disruptive */
    }
    setSearch("");
    barcodeRef.current?.focus();
  }

  const unitPrice = (p: Product) => D(mode === "wholesale" ? p.wholesale_price : p.retail_price);
  const total = useMemo(
    () => cart.reduce((s, i) => s.plus(unitPrice(i.product).times(i.qty).minus(D(i.discount))), D(0)),
    [cart, mode],
  );

  const splitTotal = split.reduce((s, p) => s.plus(D(p.amount || "0")), D(0));
  const paidSoFar = D(cashInput || "0").plus(splitTotal);
  const remaining = total.minus(paidSoFar);

  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      const tag = (e.target as HTMLElement)?.tagName;
      const typing = tag === "INPUT" || tag === "SELECT" || tag === "TEXTAREA";
      if (e.key === "F2") {
        e.preventDefault();
        if (cart.length && !shiftMissing) { setCashInput(total.toFixed(2)); setSplit([]); setPayOpen(true); }
      } else if (e.key === "F3") {
        e.preventDefault();
        barcodeRef.current?.focus();
      } else if (e.key === "Escape" && !payOpen && !typing && cart.length) {
        setConfirmClear(true);
      }
    }
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  });

  function persistHeld(bills: HeldBill[]) {
    setHeld(bills);
    localStorage.setItem(HELD_KEY, JSON.stringify(bills));
  }

  const body = () =>
    buildSaleBody({
      warehouseId, shiftId: shift.data?.id ?? null, mode, customerId, cart,
      isCredit, cashInput, split, walletId, paidSoFar, total,
    });

  const checkout = useMutation({
    mutationFn: async (): Promise<SaleResult> => {
      try {
        return await api.post<SaleResult>("/sales", body());
      } catch (err) {
        // network failure (no HTTP status) → queue offline for replay
        if (typeof err === "object" && err !== null && !("status" in err)) {
          await enqueueSale(body());
          throw new ApiError(0, "لا يوجد اتصال — تم حفظ الفاتورة محلياً وستُزامن تلقائياً");
        }
        throw err;
      }
    },
    onSuccess: (r) => {
      setSaleDone(r);
      setCart([]); setPayOpen(false); setCashInput(""); setSplit([]);
      setIsCredit(false); setCustomerId(""); setWalletId("");
      toast("success", `تم البيع — فاتورة ${r.invoice_number}`);
      qc.invalidateQueries({ queryKey: ["sales"] });
      qc.invalidateQueries({ queryKey: ["report"] });
    },
  });

  const saveQuotation = useMutation({
    mutationFn: () => api.post<SaleResult>("/sales/quotations", body()),
    onSuccess: (r) => {
      setSaleDone(r);
      setCart([]); setPayOpen(false); setCashInput(""); setSplit([]);
      setIsCredit(false); setCustomerId(""); setWalletId("");
      toast("success", `تم حفظ عرض السعر ${r.invoice_number}`);
      qc.invalidateQueries({ queryKey: ["sales"] });
    },
  });

  const openShift = useMutation({
    mutationFn: () => api.post("/shifts/open", { warehouse_id: openShiftFor!.id, initial_amount: D(initialAmount).toNumber() }),
    onSuccess: () => { setOpenShiftFor(null); setInitialAmount("0"); qc.invalidateQueries({ queryKey: ["shift"] }); },
  });

  const [queue, setQueue] = useState<QueuedSale[]>([]);
  const [queueOpen, setQueueOpen] = useState(false);

  async function refreshQueue() { setQueue(await listQueue()); }
  async function tryReplay() {
    const { synced } = await replayQueue((payload) => api.post("/sales", payload));
    if (synced > 0) qc.invalidateQueries({ queryKey: ["sales"] });
    await refreshQueue();
  }
  useEffect(() => {
    refreshQueue();
    tryReplay();
    window.addEventListener("online", tryReplay);
    return () => window.removeEventListener("online", tryReplay);
  }, []);

  const creditWarning =
    isCredit && customer && customer.credit_limit
      ? D(customer.balance).plus(total).gt(D(customer.credit_limit))
      : false;

  return (
    <div className="flex flex-col gap-4 pb-24 lg:grid lg:grid-cols-[1fr_400px] lg:pb-0">
      <div className="lg:hidden">
        <PageHeader title="نقطة البيع" description="امسح الباركود أو اختر منتجًا لبدء الفاتورة" />
      </div>
      {/* Catalog side */}
      <div className="min-w-0 space-y-3">
        <Card className="flex flex-col gap-3 p-3">
          <div className="flex flex-wrap items-center gap-2">
            <form
              onSubmit={(e) => { e.preventDefault(); scanBarcode(search.trim()); }}
              className="flex min-w-[240px] flex-1 items-center gap-2"
            >
              <InputGroup className="h-11 bg-card">
                <InputGroupInput
                  ref={barcodeRef}
                  autoFocus
                  placeholder="امسح الباركود أو ابحث بالاسم / الكود"
                  aria-label="بحث أو باركود"
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                />
                <InputGroupAddon>
                  <ScanBarcode className="size-4 text-muted-foreground" />
                </InputGroupAddon>
              </InputGroup>
              <Select value={warehouseId} onChange={(e) => setWarehouseId(e.target.value)} className="w-auto">
                {wh.data?.map((w) => <option key={w.id} value={w.id}>{w.name}</option>)}
              </Select>
            </form>
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
          </div>
          <div className="flex flex-wrap items-center justify-between gap-2">
            <p className="text-xs text-muted">
              <Kbd>Enter</Kbd> مطابقة الباركود · <Kbd>F3</Kbd> تركيز البحث · <Kbd>F2</Kbd> الدفع
            </p>
            <div className="flex gap-2">
              <Button variant="outline" className="text-xs" onClick={() => setResumeOpen(true)} disabled={!held.length}>
                <Pause size={16} /> استئناف {held.length ? `(${held.length})` : ""}
              </Button>
              <Button variant={queue.length ? "default" : "outline"} className="text-xs" onClick={() => { setQueueOpen(true); refreshQueue(); }}>
                <CloudUpload size={16} /> {queue.length ? `بانتظار المزامنة (${queue.length})` : "المزامنة"}
              </Button>
            </div>
          </div>
        </Card>

        {products.isLoading ? (
          <div className="flex flex-col gap-2" aria-busy="true" aria-label="جارٍ التحميل">
            <Skeleton className="h-10 w-full" />
            {Array.from({ length: 6 }).map((_, i) => <Skeleton key={i} className="h-12 w-full" />)}
          </div>
        ) : products.isError ? (
          <ErrorBox message={(products.error as Error).message} onRetry={() => products.refetch()} />
        ) : !products.data!.items.length ? (
          <Card className="p-10 text-center text-muted">لا توجد منتجات مطابقة</Card>
        ) : (
          <Stagger className="grid grid-cols-2 gap-3 sm:grid-cols-3 xl:grid-cols-4" key={search}>
            {products.data!.items.map((p) => (
              <StaggerItem key={p.id} className="h-full">
              <button
                onClick={() => addToCart(p)}
                className="group flex h-full w-full flex-col overflow-hidden rounded-xl border border-line bg-surface text-start transition hover:-translate-y-0.5 hover:border-brand hover:shadow-lg"
              >
                <div className="relative aspect-square bg-elevated">
                  {p.image_url ? (
                    <img src={p.image_url} alt="" className="h-full w-full object-cover transition duration-300 group-hover:scale-[1.03]" loading="lazy" />
                  ) : (
                    <div className="grid h-full place-items-center text-muted/50">
                      <Package size={40} strokeWidth={1.25} />
                    </div>
                  )}
                </div>
                <div className="flex flex-1 flex-col gap-1 p-3">
                  <span className="line-clamp-2 min-h-10 text-sm font-bold">{p.name}</span>
                  <div className="mt-auto flex items-center justify-between gap-2">
                    <span className="num rounded-md bg-brand/10 px-2 py-0.5 text-sm font-extrabold text-brand">
                      {money(mode === "wholesale" ? p.wholesale_price : p.retail_price)} ج.م
                    </span>
                    <span className="text-xs text-muted-foreground">{p.unit}{p.code ? ` · ${p.code}` : ""}</span>
                  </div>
                </div>
              </button>
              </StaggerItem>
            ))}
          </Stagger>
        )}
      </div>

      {/* Cart side */}
      <div className="flex min-w-0 flex-col gap-3">
        <Card className="overflow-hidden p-0">
          <header className="flex items-center justify-between gap-2 border-b border-line p-4">
            <h2 className="flex items-center gap-2 font-semibold">
              <ShoppingCart className="size-4" /> الفاتورة الحالية
              <KitBadge variant="secondary" className="num">{cart.reduce((s, i) => s + i.qty, 0)}</KitBadge>
            </h2>
            <div className="flex items-center gap-1">
              <Button variant="ghost" className="text-xs" onClick={() => setResumeOpen(true)}>
                <Pause size={16} />
                المعلقة
                {held.length > 0 && <KitBadge variant="warning" className="num">{held.length}</KitBadge>}
              </Button>
              {cart.length > 0 && (
                <Button variant="ghost" className="p-1.5" onClick={() => setConfirmClear(true)} aria-label="تفريغ الفاتورة">
                  <Trash2 size={16} />
                </Button>
              )}
            </div>
          </header>
        </Card>

        {shiftMissing && (
          <Card className="border-warning/40 bg-warning/10 p-4 text-sm">
            <p className="mb-2 font-bold">لا توجد وردية مفتوحة لهذا الفرع</p>
            <p className="mb-3 text-muted">يجب فتح وردية قبل إتمام البيع.</p>
            <Button onClick={() => setOpenShiftFor(wh.data?.find((w) => w.id === warehouseId) ?? null)}>فتح وردية</Button>
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
                    <p className="num text-xs text-muted">{money(unitPrice(i.product))} × {i.qty} = {money(unitPrice(i.product).times(i.qty).minus(D(i.discount)))}</p>
                  </div>
                  <div className="flex items-center gap-1">
                    <button
                      className="rounded-md border border-line p-1 hover:bg-elevated"
                      onClick={() => setCart((c) => c.map((x, j) => j === idx ? { ...x, qty: Math.max(1, x.qty - 1) } : x))}
                      aria-label="تقليل"
                    ><Minus size={16} /></button>
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
                      aria-label="زيادة"
                    ><Plus size={16} /></button>
                    <button
                      className="rounded-md p-1 text-danger hover:bg-elevated"
                      onClick={() => setCart((c) => c.filter((_, j) => j !== idx))}
                      aria-label="حذف"
                    ><X size={16} /></button>
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
          <Separator />
          <div className="flex gap-2">
            <Button
              variant="outline"
              className="flex-1"
              disabled={!cart.length}
              onClick={() => { persistHeld([...held, { id: String(Date.now()), cart, mode, at: new Date().toISOString() }]); setCart([]); }}
            >
              <Pause size={16} /> تعليق
            </Button>
            <Button
              className="flex-[2] py-3 text-base"
              disabled={!cart.length || shiftMissing || shift.isLoading}
              onClick={() => { setCashInput(total.toFixed(2)); setSplit([]); setPayOpen(true); }}
            >
              إتمام الدفع <Kbd>F2</Kbd>
            </Button>
          </div>
        </Card>
      </div>

      {/* Mobile action bar — checkout always one thumb away */}
      <div className="fixed inset-x-0 bottom-0 z-30 flex items-center justify-between gap-3 border-t border-line bg-background/95 px-4 py-3 pb-[max(0.75rem,env(safe-area-inset-bottom))] backdrop-blur lg:hidden">
        <div className="flex flex-col leading-tight">
          <span className="text-xs text-muted-foreground">الإجمالي</span>
          <span className="num text-lg font-bold">{money(total)} ج.م</span>
        </div>
        <Button
          disabled={!cart.length || shiftMissing || shift.isLoading}
          onClick={() => { setCashInput(total.toFixed(2)); setSplit([]); setPayOpen(true); }}
        >
          إتمام الدفع
        </Button>
      </div>

      {/* Payment modal */}
      <Modal open={payOpen} onClose={() => setPayOpen(false)} title="إتمام الدفع">
        <div className="flex flex-col gap-6">
          <div className="rounded-xl bg-elevated p-4 text-center">
            <p className="text-sm text-muted">المطلوب</p>
            <p className="num text-3xl font-black text-brand">{money(total)} ج.م</p>
          </div>

          <label className="flex items-center gap-2 text-sm font-semibold">
            <input type="checkbox" checked={isCredit} onChange={(e) => setIsCredit(e.target.checked)} />
            بيع آجل (على حساب العميل)
          </label>

          {isCredit && (
            <div className="space-y-2 rounded-xl border border-line p-3">
              <label className="block text-sm font-medium">العميل</label>
              <Select value={customerId} onChange={(e) => setCustomerId(e.target.value)}>
                <option value="">— اختر العميل —</option>
                {customers.data?.map((c) => (
                  <option key={c.id} value={c.id}>{c.name} (مدين: {money(c.balance)})</option>
                ))}
              </Select>
              {customer && (
                <p className="text-xs text-muted">
                  الرصيد الحالي <span className="num font-bold">{money(customer.balance)}</span>
                  {customer.credit_limit ? <> · حد الائتمان <span className="num">{money(customer.credit_limit)}</span></> : null}
                </p>
              )}
              {creditWarning && (
                <p className="flex items-center gap-2 rounded-lg bg-destructive/10 p-2 text-sm font-medium text-destructive">
                  <TriangleAlert className="size-4 shrink-0" aria-hidden />
                  هذه الفاتورة تتجاوز حد الائتمان المسموح
                </p>
              )}
            </div>
          )}

          {!isCredit && (
            <>
              <div>
                <label className="mb-1 block text-sm font-medium">المدفوع نقداً</label>
                <Input className="num text-lg" inputMode="decimal" value={cashInput} onChange={(e) => setCashInput(e.target.value)} />
              </div>
              {!split.length && !cashInput && (
                <div>
                  <label className="mb-1 block text-sm font-medium">أو الدفع بالكامل من محفظة</label>
                  <Select value={walletId} onChange={(e) => setWalletId(e.target.value)}>
                    <option value="">— بدون —</option>
                    {wallets.data?.map((w) => <option key={w.id} value={w.id}>{w.name} ({w.type})</option>)}
                  </Select>
                </div>
              )}
              <div>
                <div className="mb-1 flex items-center justify-between">
                  <label className="text-sm font-medium">دفعات إضافية (تقسيم)</label>
                  <button
                    className="text-xs font-semibold text-brand"
                    onClick={() => setSplit((s) => [...s, { method: "wallet", amount: "", wallet_id: "" }])}
                  >
                    + إضافة دفعة
                  </button>
                </div>
                {split.map((p, i) => (
                  <div key={i} className="mb-2 flex flex-wrap gap-2">
                    <Select
                      className="w-auto"
                      value={p.method}
                      onChange={(e) => setSplit((s) => s.map((x, j) => j === i ? { ...x, method: e.target.value } : x))}
                    >
                      <option value="wallet">محفظة</option>
                      <option value="bank">تحويل بنكي</option>
                      <option value="cheque">شيك</option>
                      <option value="cash">نقدي</option>
                    </Select>
                    {p.method === "wallet" && (
                      <Select
                        className="w-auto"
                        value={p.wallet_id}
                        onChange={(e) => setSplit((s) => s.map((x, j) => j === i ? { ...x, wallet_id: e.target.value } : x))}
                      >
                        <option value="">محفظة؟</option>
                        {wallets.data?.map((w) => <option key={w.id} value={w.id}>{w.name}</option>)}
                      </Select>
                    )}
                    <Input
                      className="num w-24" inputMode="decimal" placeholder="مبلغ"
                      value={p.amount}
                      onChange={(e) => setSplit((s) => s.map((x, j) => j === i ? { ...x, amount: e.target.value } : x))}
                    />
                    <button className="rounded p-1 text-danger" onClick={() => setSplit((s) => s.filter((_, j) => j !== i))} aria-label="حذف دفعة">
                      <X size={16} />
                    </button>
                  </div>
                ))}
              </div>
              <p className="text-xs text-muted">
                {remaining.gt(0) ? <>المتبقي: <span className="num font-bold text-warning">{money(remaining)}</span></>
                : remaining.lt(0) ? <>الباقي للعميل: <span className="num font-bold text-success">{money(remaining.neg())}</span></>
                : <span className="font-bold text-success">مكتمل ✓</span>}
              </p>
            </>
          )}

          {checkout.isError && <ErrorBox message={(checkout.error as Error).message} />}
          <div className="flex gap-2">
            <Button
              className="flex-1"
              disabled={checkout.isPending || (isCredit && !customerId)}
              onClick={() => checkout.mutate()}
            >
              {checkout.isPending ? <Spinner /> : "تأكيد البيع"}
            </Button>
            <Button
              variant="outline"
              className="flex-1"
              disabled={saveQuotation.isPending}
              onClick={() => saveQuotation.mutate()}
              title="عرض سعر — لا يُخصم من المخزون"
            >
              {saveQuotation.isPending ? <Spinner /> : "حفظ كعرض سعر"}
            </Button>
          </div>
          {saveQuotation.isError && <ErrorBox message={(saveQuotation.error as Error).message} />}
        </div>
      </Modal>

      <ConfirmDialog
        open={confirmClear}
        onClose={() => setConfirmClear(false)}
        onConfirm={() => { setCart([]); setConfirmClear(false); }}
        title="تفريغ الفاتورة"
        message="هل تريد تفريغ الفاتورة الحالية؟ لا يمكن التراجع."
        confirmLabel="تفريغ"
      />

      <Modal open={queueOpen} onClose={() => setQueueOpen(false)} title="فواتير في انتظار المزامنة">
        <div className="flex flex-col gap-3">
          {!queue.length ? (
            <p className="p-4 text-center text-sm text-muted">لا توجد فواتير معلقة — كل شيء متزامن ✓</p>
          ) : (
            <>
              <ul className="space-y-2">
                {queue.map((s) => (
                  <li key={s.id} className="flex items-center justify-between rounded-xl border border-line p-3 text-sm">
                    <div>
                      <p className="font-bold">
                        {s.status === "conflict" ? "تعارض — تحتاج مراجعة" : "محفوظة محلياً"}
                      </p>
                      <p className="num text-xs text-muted">{new Date(s.savedAt).toLocaleString("ar-EG")}</p>
                      {s.error && <p className="text-xs text-danger">{s.error}</p>}
                    </div>
                    {s.status === "conflict" && (
                      <Button variant="ghost" className="text-danger" onClick={async () => { await removeSale(s.id); refreshQueue(); }}>
                        تجاهل
                      </Button>
                    )}
                  </li>
                ))}
              </ul>
              <Button className="w-full" onClick={() => tryReplay()}>
                <Play size={16} /> محاولة المزامنة الآن
              </Button>
            </>
          )}
        </div>
      </Modal>

      {/* Resume bills */}
      <Modal open={resumeOpen} onClose={() => setResumeOpen(false)} title="الفواتير المعلقة">
        {!held.length ? (
          <p className="p-4 text-center text-sm text-muted">لا توجد فواتير معلقة</p>
        ) : (
          <ul className="space-y-2">
            {held.map((b) => (
              <li key={b.id} className="flex items-center justify-between rounded-xl border border-line p-3">
                <div>
                  <p className="text-sm font-bold">{b.cart.length} منتج · {b.mode === "retail" ? "تجزئة" : "جملة"}</p>
                  <p className="num text-xs text-muted">{new Date(b.at).toLocaleString("ar-EG")}</p>
                </div>
                <Button
                  variant="outline"
                  onClick={() => {
                    setCart(b.cart); setMode(b.mode);
                    persistHeld(held.filter((x) => x.id !== b.id));
                    setResumeOpen(false);
                  }}
                >
                  <Play size={16} /> استئناف
                </Button>
              </li>
            ))}
          </ul>
        )}
      </Modal>

      {/* Shift-open modal */}
      <Modal open={!!openShiftFor} onClose={() => setOpenShiftFor(null)} title="فتح وردية">
        <div className="flex flex-col gap-6">
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
          <Button onClick={() => saleDone && openPrintDoc(`/print/sale/${saleDone.id}`)}>
            <Printer size={16} /> طباعة الفاتورة
          </Button>
        </div>
      </Modal>
    </div>
  );
}
