import { X } from "lucide-react";
import type { ReactNode } from "react";

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
    <button
      className={`inline-flex items-center justify-center gap-2 rounded-lg px-4 py-2 text-sm font-semibold transition disabled:cursor-not-allowed disabled:opacity-50 ${styles} ${className}`}
      {...props}
    >
      {children}
    </button>
  );
}

export function Input({
  ref,
  ...props
}: React.InputHTMLAttributes<HTMLInputElement> & { ref?: React.Ref<HTMLInputElement> }) {
  return (
    <input
      ref={ref}
      className="w-full rounded-lg border border-line bg-surface px-3 py-2 text-sm text-ink placeholder:text-muted focus-visible:border-brand"
      {...props}
    />
  );
}

export function Select(props: React.SelectHTMLAttributes<HTMLSelectElement>) {
  return (
    <select
      className="w-full rounded-lg border border-line bg-surface px-3 py-2 text-sm text-ink focus-visible:border-brand"
      {...props}
    />
  );
}

export function Card({ className = "", children }: { className?: string; children: ReactNode }) {
  return <div className={`rounded-xl border border-line bg-surface p-5 ${className}`}>{children}</div>;
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
  if (!open) return null;
  return (
    <div
      className="fixed inset-0 z-50 grid place-items-center bg-black/50 p-4"
      onMouseDown={(e) => e.target === e.currentTarget && onClose()}
    >
      <div
        className={`max-h-[90vh] w-full overflow-auto rounded-2xl border border-line bg-surface p-6 shadow-2xl ${wide ? "max-w-3xl" : "max-w-md"}`}
        role="dialog"
        aria-modal="true"
        aria-label={title}
      >
        <div className="mb-4 flex items-center justify-between">
          <h2 className="text-lg font-bold">{title}</h2>
          <button onClick={onClose} aria-label="إغلاق" className="rounded-lg p-1 hover:bg-elevated">
            <X size={18} />
          </button>
        </div>
        {children}
      </div>
    </div>
  );
}

export function Empty({ text, hint }: { text: string; hint?: string }) {
  return (
    <div className="grid place-items-center gap-1 rounded-xl border border-dashed border-line p-12 text-center">
      <p className="font-semibold text-muted">{text}</p>
      {hint && <p className="text-sm text-muted">{hint}</p>}
    </div>
  );
}

export function ErrorBox({ message, onRetry }: { message: string; onRetry?: () => void }) {
  return (
    <div className="flex items-center justify-between gap-4 rounded-xl border border-danger/30 bg-danger/10 p-4 text-sm text-danger">
      <span>{message}</span>
      {onRetry && (
        <Button variant="outline" onClick={onRetry}>
          إعادة المحاولة
        </Button>
      )}
    </div>
  );
}
