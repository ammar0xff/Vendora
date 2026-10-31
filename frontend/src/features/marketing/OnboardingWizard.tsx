/**
 * PAGE CONTRACT
 * Page: تهيئة مساحة العمل (/onboarding)
 * User: تاجر سجّل للتو — بنبني له مساحة عمل على مقاس نشاطه
 * Outcome: مساحة عمل منظّمة ببيانات تجريبية على قطاعته + جلسة جاهزة
 * Primary information: النشاط → اسم الشركة وحجمها → الهوية والاختيارات → إنشاء
 * Primary action (per state): step → «التالي»؛ last → «أنشئ نظامي»؛ busy → جارٍ التجهيز؛ error → إعادة المحاولة
 * Secondary action: رجوع للخطوة السابقة · اختصار: دخول بحساب موجود
 * Required states: step-1..3, submitting, conflict (409), error
 * Responsive: عمود واحد، البطاقة مركزية، شريط تقدم أعلى البطاقة
 */
import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { Check, Scale } from "lucide-react";
import { api, ApiError } from "@/lib/api";
import { applyBrandHue, useAuth, type TenantInfo } from "@/stores/auth";
import { Button, ErrorBox, Input } from "@/components/ui";
import { FEATURE_OPTIONS, PALETTE_OPTIONS, SCALE_OPTIONS, SECTOR_OPTIONS } from "./plans";
import { cn } from "@/lib/utils";

interface OwnerDraft { full_name: string; username: string; password: string }

const STEPS = ["النشاط", "شركتك", "الهوية"];

export default function OnboardingWizard() {
  const nav = useNavigate();
  const draft: OwnerDraft | null = (() => {
    try { return JSON.parse(sessionStorage.getItem("mizan.owner") ?? "null"); } catch { return null; }
  })();

  const [step, setStep] = useState(0);
  const [sector, setSector] = useState("plumbing");
  const [company, setCompany] = useState("");
  const [scale, setScale] = useState("medium");
  const [palette, setPalette] = useState("water");
  const [features, setFeatures] = useState<string[]>(["credit", "quotations"]);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  if (!draft) {
    return (
      <Centered>
        <Emptyish />
      </Centered>
    );
  }

  function toggleFeature(v: string) {
    setFeatures((f) => (f.includes(v) ? f.filter((x) => x !== v) : [...f, v]));
  }

  function previewHue() {
    const h = PALETTE_OPTIONS.find((p) => p.value === palette)?.hue ?? 250;
    applyBrandHue(h); // live preview while choosing
  }

  async function create() {
    setBusy(true);
    setError(null);
    try {
      const r = await api.post<{ access_token: string; user: never; tenant: TenantInfo }>("/platform/signup", {
        company_name: company,
        sector,
        scale,
        palette,
        features,
        owner_username: draft!.username,
        owner_password: draft!.password,
        owner_full_name: draft!.full_name,
      });
      applyBrandHue(r.tenant.palette?.hue);
      useAuth.getState().setToken(r.access_token);
      useAuth.getState().setUser(r.user);
      useAuth.getState().setTenant(r.tenant);
      sessionStorage.removeItem("mizan.owner");
      nav("/app", { replace: true });
    } catch (err) {
      if (err instanceof ApiError && err.status === 409) {
        setError("اسم المستخدم محجوز — ارجع للخطوة السابقة واختر اسمًا آخر.");
        setStep(0);
      } else {
        setError(err instanceof ApiError ? err.message : "تعذر تجهيز مساحة العمل — حاول تاني");
      }
    } finally {
      setBusy(false);
    }
  }


  return (
    <div className="grid min-h-svh place-items-center bg-background p-4">
      <div className="w-full max-w-lg">
        <Link to="/" className="mb-6 flex items-center justify-center gap-2">
          <span className="grid size-10 place-items-center rounded-lg bg-primary text-primary-foreground"><Scale /></span>
          <span className="text-xl font-bold">ميزان</span>
        </Link>

        <div className="rounded-2xl border bg-card p-8 shadow-sm">
          {/* progress */}
          <div className="mb-8 flex items-center gap-2" aria-label={`خطوة ${step + 1} من 3`}>
            {STEPS.map((label, i) => (
              <div key={label} className="flex flex-1 flex-col gap-1.5">
                <div className={cn("h-1 rounded-full", i <= step ? "bg-primary" : "bg-muted")} />
                <span className={cn("text-xs", i === step ? "font-semibold text-foreground" : "text-muted-foreground")}>{label}</span>
              </div>
            ))}
          </div>

          {step === 0 && (
            <fieldset>
              <legend className="text-lg font-bold">إيه نشاط معرضك؟</legend>
              <p className="mt-1 text-sm text-muted-foreground">بنجهز أصناف وبيانات تجريبية على نفس مجالك.</p>
              <div className="mt-5 grid gap-2 sm:grid-cols-2">
                {SECTOR_OPTIONS.map((o) => (
                  <Choice key={o.value} selected={sector === o.value} onClick={() => setSector(o.value)} title={o.label} />
                ))}
              </div>
            </fieldset>
          )}

          {step === 1 && (
            <fieldset>
              <legend className="text-lg font-bold">اسم شركتك وحجمها؟</legend>
              <p className="mt-1 text-sm text-muted-foreground">هذا الاسم يظهر لفريقك داخل النظام.</p>
              <div className="mt-5">
                <Input value={company} onChange={(e) => setCompany(e.target.value)} placeholder="مثال: معرض النيل للكهرباء" autoFocus />
              </div>
              <div className="mt-4 grid gap-2 sm:grid-cols-3">
                {SCALE_OPTIONS.map((o) => (
                  <Choice key={o.value} selected={scale === o.value} onClick={() => setScale(o.value)} title={o.label} desc={o.desc} />
                ))}
              </div>
            </fieldset>
          )}

          {step === 2 && (
            <fieldset>
              <legend className="text-lg font-bold">اختار هوية نظامك</legend>
              <p className="mt-1 text-sm text-muted-foreground">اللون بيتطبق فورًا على معاينة النظام — وتقدر تغيّره بعدين.</p>
              <div className="mt-5 grid gap-2 sm:grid-cols-2">
                {PALETTE_OPTIONS.map((o) => (
                  <Choice
                    key={o.value}
                    selected={palette === o.value}
                    onClick={() => { setPalette(o.value); setTimeout(previewHue, 0); }}
                    title={o.label}
                    desc={o.desc}
                    swatch={`oklch(0.5 0.16 ${o.hue})`}
                  />
                ))}
              </div>
              <p className="mt-6 mb-2 text-sm font-semibold">ميزات اختيارية</p>
              <div className="grid gap-2">
                {FEATURE_OPTIONS.map((o) => (
                  <Choice
                    key={o.value}
                    selected={features.includes(o.value)}
                    onClick={() => toggleFeature(o.value)}
                    title={o.label}
                    desc={o.desc}
                    check
                  />
                ))}
              </div>
            </fieldset>
          )}

          {error && <div className="mt-5"><ErrorBox message={error} /></div>}

          <div className="mt-8 flex items-center justify-between gap-3">
            <Button variant="ghost" onClick={() => (step === 0 ? nav("/signup") : setStep((s) => s - 1))}>
              رجوع
            </Button>
            {step < 2 ? (
              <Button onClick={() => setStep((s) => s + 1)} disabled={step === 1 && !company.trim()}>
                التالي
              </Button>
            ) : (
              <Button onClick={create} disabled={busy}>
                {busy ? "جارٍ تجهيز نظامك…" : "أنشئ نظامي"}
              </Button>
            )}
          </div>
        </div>
        <p className="mt-4 text-center text-xs text-muted-foreground">
          هتدخل على نظام جاهز ببيانات تجريبية واقعية — تمسحها وتبدأ ببياناتك متى ما تحب.
        </p>
      </div>
    </div>
  );
}

function Centered({ children }: { children: React.ReactNode }) {
  return <div className="min-h-svh bg-background">{children}</div>;
}

function Emptyish() {
  return (
    <div className="mx-auto max-w-sm rounded-2xl border bg-card p-8 text-center">
      <span className="mx-auto mb-4 grid size-12 place-items-center rounded-xl bg-primary/10 text-primary"><Scale /></span>
      <h1 className="font-bold">ابدأ من صفحة الحساب</h1>
      <p className="mt-2 text-sm text-muted-foreground">المعالج بيقرأ بيانات حسابك من الخطوة الأولى.</p>
      <Link to="/signup" className="mt-5 inline-block">
        <Button>إنشاء حساب</Button>
      </Link>
    </div>
  );
}

function Choice({ selected, onClick, title, desc, swatch, check }: {
  selected: boolean; onClick: () => void; title: string; desc?: string; swatch?: string; check?: boolean;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-pressed={selected}
      className={cn(
        "flex items-start gap-3 rounded-xl border p-3 text-start transition",
        selected ? "border-primary bg-primary/5 ring-2 ring-primary/20" : "hover:border-foreground/25",
      )}
    >
      {swatch ? (
        <span className="mt-0.5 size-5 shrink-0 rounded-full border" style={{ background: swatch }} aria-hidden />
      ) : (
        <span className={cn(
          "mt-0.5 grid size-5 shrink-0 place-items-center rounded-md border",
          selected && check ? "border-primary bg-primary text-primary-foreground" : "",
          selected && !check ? "border-primary bg-primary text-primary-foreground" : "",
        )} aria-hidden>
          {selected && <Check className="size-3.5" />}
        </span>
      )}
      <span className="min-w-0">
        <span className="block text-sm font-semibold">{title}</span>
        {desc && <span className="mt-0.5 block text-xs text-muted-foreground">{desc}</span>}
      </span>
    </button>
  );
}
