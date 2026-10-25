import { AnimatePresence, motion } from "motion/react";
import { CheckCircle2, Info, X, XCircle } from "lucide-react";
import {
  createContext, useCallback, useContext, useEffect, useState,
  type ReactNode,
} from "react";
import { spring } from "@/components/motion";

export function Spinner({ className = "" }: { className?: string }) {
  return (
    <span
      className={`inline-block h-4 w-4 animate-spin rounded-full border-2 border-current border-t-transparent ${className}`}
      aria-label="جارٍ التحميل"
    />
  );
}

export function Button({
  variant = "default",
  className = "",
  children,
  ...props
}: React.ButtonHTMLAttributes<HTMLButtonElement> & { variant?: "default" | "ghost" | "danger" | "outline" }) {
  const styles = {
    default: "bg-brand text-brand-ink hover:opacity-90",
    ghost: "hover:bg-elevated text-ink",
    danger: "bg-danger text-white hover:opacity-90",
    outline: "border border-line hover:bg-elevated",
  }[variant];
  return (
    <motion.button
      whileTap={{ scale: 0.97 }}
      transition={{ duration: 0.08 }}
      className={`inline-flex items-center justify-center gap-2 rounded-lg px-4 py-2 text-sm font-semibold transition disabled:cursor-not-allowed disabled:opacity-50 ${styles} ${className}`}
      {...(props as React.ComponentProps<typeof motion.button>)}
    >
      {children}
    </motion.button>
  );
}

export function Input({ ref, ...props }: React.InputHTMLAttributes<HTMLInputElement> & { ref?: React.Ref<HTMLInputElement> }) {
  return (
    <input
      ref={ref}
      className="w-full rounded-lg border border-line bg-surface px-3 py-2 text-sm text-ink transition placeholder:text-muted focus-visible:border-brand focus-visible:ring-2 focus-visible:ring-brand/25"
      {...props}
    />
  );
}

export function Select(props: React.SelectHTMLAttributes<HTMLSelectElement>) {
  return (
    <select
      className="w-full rounded-lg border border-line bg-surface px-3 py-2 text-sm text-ink transition focus-visible:border-brand focus-visible:ring-2 focus-visible:ring-brand/25"
      {...props}
    />
  );
}

export function Card({ className = "", children, hover = false }: { className?: string; children: ReactNode; hover?: boolean }) {
  return (
    <div
      className={`rounded-xl border border-line bg-surface shadow-[0_1px_2px_rgba(0,0,0,0.04)] transition-shadow ${
        hover ? "hover:border-brand/40 hover:shadow-[0_8px_24px_rgba(0,0,0,0.08)]" : ""
      } ${className}`}
    >
      {children}
    </div>
  );
}

export function Badge({ tone = "muted", children }: { tone?: "muted" | "success" | "warning" | "danger" | "brand"; children: ReactNode }) {
  const tones = {
    muted: "bg-elevated text-muted",
    success: "bg-success/15 text-success",
    warning: "bg-warning/15 text-warning",
    danger: "bg-danger/15 text-danger",
    brand: "bg-brand/15 text-brand",
  }[tone];
  return <span className={`inline-block rounded-full px-2.5 py-0.5 text-xs font-semibold ${tones}`}>{children}</span>;
}

export function Modal({
  open,
  onClose,
  title,
  children,
  wide = false,
}: {
  open: boolean;
  onClose: () => void;
  title: string;
  children: ReactNode;
  wide?: boolean;
}) {
  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [open, onClose]);

  return (
    <AnimatePresence>
      {open && (
        <motion.div
          className="fixed inset-0 z-50 grid place-items-center bg-black/50 p-4 backdrop-blur-[2px]"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.15 }}
          onMouseDown={(e) => e.target === e.currentTarget && onClose()}
        >
          <motion.div
            className={`max-h-[90vh] w-full overflow-auto rounded-2xl border border-line bg-surface p-6 shadow-2xl ${wide ? "max-w-3xl" : "max-w-md"}`}
            role="dialog"
            aria-modal="true"
            aria-label={title}
            initial={{ opacity: 0, scale: 0.96, y: 10 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.97, y: 6 }}
            transition={spring}
          >
            <div className="mb-4 flex items-center justify-between">
              <h2 className="text-lg font-bold">{title}</h2>
              <button onClick={onClose} aria-label="إغلاق" className="rounded-lg p-1 text-muted transition hover:bg-elevated hover:text-ink">
                <X size={18} />
              </button>
            </div>
            {children}
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}

/** Accessible confirmation dialog — replaces window.confirm. */
export function ConfirmDialog({
  open,
  onConfirm,
  onClose,
  title,
  message,
  confirmLabel = "تأكيد",
  danger = true,
}: {
  open: boolean;
  onConfirm: () => void;
  onClose: () => void;
  title: string;
  message: string;
  confirmLabel?: string;
  danger?: boolean;
}) {
  return (
    <Modal open={open} onClose={onClose} title={title}>
      <div className="space-y-4">
        <p className="text-sm text-muted">{message}</p>
        <div className="flex gap-2">
          <Button variant={danger ? "danger" : "default"} className="flex-1" onClick={onConfirm}>
            {confirmLabel}
          </Button>
          <Button variant="ghost" className="flex-1" onClick={onClose}>
            إلغاء
          </Button>
        </div>
      </div>
    </Modal>
  );
}

export function Empty({ text, hint, icon = "🗂️" }: { text: string; hint?: string; icon?: string }) {
  return (
    <div className="grid place-items-center gap-2 rounded-xl border border-dashed border-line p-12 text-center">
      <span className="text-3xl opacity-40">{icon}</span>
      <p className="font-semibold text-muted">{text}</p>
      {hint && <p className="text-sm text-muted">{hint}</p>}
    </div>
  );
}

export function ErrorBox({ message, onRetry }: { message: string; onRetry?: () => void }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: -4 }}
      animate={{ opacity: 1, y: 0 }}
      className="flex items-center justify-between gap-4 rounded-xl border border-danger/30 bg-danger/10 p-4 text-sm text-danger"
      role="alert"
    >
      <span className="flex items-center gap-2"><XCircle size={16} className="shrink-0" /> {message}</span>
      {onRetry && (
        <Button variant="outline" onClick={onRetry}>
          إعادة المحاولة
        </Button>
      )}
    </motion.div>
  );
}

/* ── Toasts ─────────────────────────────────────────────── */

type ToastKind = "success" | "error" | "info";
interface Toast { id: number; kind: ToastKind; message: string }

const ToastCtx = createContext<{ toast: (kind: ToastKind, message: string) => void }>({ toast: () => {} });
export const useToast = () => useContext(ToastCtx);

export function ToastProvider({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<Toast[]>([]);
  const toast = useCallback((kind: ToastKind, message: string) => {
    const id = Date.now() + Math.random();
    setToasts((t) => [...t, { id, kind, message }]);
    setTimeout(() => setToasts((t) => t.filter((x) => x.id !== id)), kind === "error" ? 6000 : 3500);
  }, []);

  return (
    <ToastCtx.Provider value={{ toast }}>
      {children}
      <div className="pointer-events-none fixed inset-x-0 top-4 z-[60] flex flex-col items-center gap-2 px-4" aria-live="polite">
        <AnimatePresence>
          {toasts.map((t) => (
            <motion.div
              key={t.id}
              initial={{ opacity: 0, y: -16, scale: 0.97 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              exit={{ opacity: 0, y: -10, scale: 0.98 }}
              transition={spring}
              className={`pointer-events-auto flex max-w-md items-center gap-2.5 rounded-xl border px-4 py-3 text-sm font-semibold shadow-lg backdrop-blur ${
                t.kind === "success"
                  ? "border-success/30 bg-success/10 text-success"
                  : t.kind === "error"
                    ? "border-danger/30 bg-danger/10 text-danger"
                    : "border-line bg-surface text-ink"
              }`}
            >
              {t.kind === "success" ? <CheckCircle2 size={17} /> : t.kind === "error" ? <XCircle size={17} /> : <Info size={17} />}
              {t.message}
            </motion.div>
          ))}
        </AnimatePresence>
      </div>
    </ToastCtx.Provider>
  );
}
