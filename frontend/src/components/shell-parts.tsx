import { useEffect, useMemo, useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { ArrowLeft, Receipt, Search, ShoppingCart } from "lucide-react";
import { useAuth } from "@/stores/auth";
import { NAV_ITEMS } from "@/lib/nav";
import { Dialog, DialogContent, DialogTitle } from "@/components/kit/dialog";

/* ── Ctrl+K global hotkey ─────────────────────────────────────── */
export function useHotkeySearch(open: () => void) {
  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === "k") {
        e.preventDefault();
        open();
      }
    }
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [open]);
}

/* ── Trial banner — routes to pricing (the SaaS conversion loop) ── */
export function TrialBanner() {
  const { tenant } = useAuth();
  if (!tenant || tenant.plan !== "trial" || !tenant.trial_ends_at) return null;
  const days = Math.max(0, Math.ceil((new Date(tenant.trial_ends_at).getTime() - Date.now()) / 86_400_000));
  return (
    <div className="no-print flex flex-wrap items-center justify-center gap-x-3 gap-y-1 border-b border-primary/20 bg-primary/10 px-4 py-2 text-sm">
      <span>
        <strong className="font-bold">تجربة مجانية</strong> — باقي{" "}
        <span className="num font-bold">{days}</span> يوم على «{tenant.name}»
      </span>
      <Link to="/pricing" className="inline-flex items-center gap-1 font-bold text-primary hover:underline">
        فعّل خطتك الآن
        <ArrowLeft className="size-4" aria-hidden />
      </Link>
    </div>
  );
}

/* ── Ctrl+K command palette — navigate + one-tap actions ──────── */
export function CommandPalette({ open, onOpenChange }: { open: boolean; onOpenChange: (o: boolean) => void }) {
  const { can } = useAuth();
  const nav = useNavigate();
  const [q, setQ] = useState("");

  const actions = useMemo(() => {
    const items: { label: string; hint: string; run: () => void; icon: React.ReactNode }[] = [
      { label: "فاتورة جديدة", hint: "نقطة البيع", icon: <ShoppingCart className="size-4" />, run: () => nav("/pos") },
      { label: "كل الفواتير", hint: "المبيعات", icon: <Receipt className="size-4" />, run: () => nav("/sales") },
    ];
    for (const n of NAV_ITEMS) {
      if (n.perm && !can(n.perm)) continue;
      items.push({
        label: n.label, hint: n.to === "/" ? "الرئيسية" : n.to.replace("/", ""),
        icon: <n.icon className="size-4" />,
        run: () => nav(n.to === "/" ? "/" : n.to),
      });
    }
    return items;
  }, [can, nav]);

  const filtered = useMemo(() => {
    const query = q.trim();
    if (!query) return actions.slice(0, 9);
    return actions.filter((a) => a.label.includes(query) || a.hint.includes(query)).slice(0, 9);
  }, [actions, q]);

  useEffect(() => {
    if (open) setQ("");
  }, [open]);

  function pick(a: { run: () => void }) {
    onOpenChange(false);
    a.run();
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="top-[15%] translate-y-0 gap-0 p-0 sm:max-w-lg" showCloseButton={false}>
        <DialogTitle className="sr-only">بحث وانتقال سريع</DialogTitle>
        <div className="flex items-center gap-2 border-b px-4">
          <Search className="size-4 shrink-0 text-muted-foreground" aria-hidden />
          <input
            autoFocus
            value={q}
            onChange={(e) => setQ(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter" && filtered[0]) pick(filtered[0]);
            }}
            placeholder="ابحث عن شاشة أو نفّذ إجراء…"
            aria-label="بحث"
            className="h-12 w-full bg-transparent text-sm outline-none placeholder:text-muted-foreground"
          />
        </div>
        <ul className="max-h-80 overflow-y-auto p-2" role="listbox">
          {filtered.length === 0 && (
            <li className="px-3 py-6 text-center text-sm text-muted-foreground">لا نتائج لـ «{q}»</li>
          )}
          {filtered.map((a) => (
            <li key={a.label + a.hint}>
              <button
                onClick={() => pick(a)}
                className="flex w-full items-center gap-3 rounded-md px-3 py-2.5 text-sm transition hover:bg-accent"
              >
                <span className="text-muted-foreground">{a.icon}</span>
                <span className="flex-1 text-start">{a.label}</span>
                <span className="text-xs text-muted-foreground">{a.hint}</span>
              </button>
            </li>
          ))}
        </ul>
      </DialogContent>
    </Dialog>
  );
}
