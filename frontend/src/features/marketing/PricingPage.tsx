import { Link } from "react-router-dom";
import { Check, Scale } from "lucide-react";
import { api, ApiError } from "@/lib/api";
import { useToast } from "@/components/ui";
import { useAuth } from "@/stores/auth";
import { PLANS, TRIAL_DAYS } from "./plans";
import { Button } from "@/components/kit/button";
import { Badge } from "@/components/kit/badge";
import { Input } from "@/components/ui";
import { useState } from "react";

export default function PricingPage() {
  const { user, tenant } = useAuth();
  const { toast } = useToast();
  const [phone, setPhone] = useState("");
  const [busyPlan, setBusyPlan] = useState<string | null>(null);

  async function requestPlan(planId: string) {
    if (!user) {
      window.location.href = "/signup";
      return;
    }
    setBusyPlan(planId);
    try {
      const r = await api.post<{ message: string }>("/platform/subscribe-request", {
        plan: planId, contact_phone: phone || undefined,
      });
      toast("success", r.message);
    } catch (err) {
      toast("error", err instanceof ApiError ? err.message : "تعذر إرسال الطلب");
    } finally {
      setBusyPlan(null);
    }
  }

  return (
    <div className="min-h-svh bg-background text-foreground">
      <header className="border-b">
        <div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-4">
          <Link to="/" className="flex items-center gap-2">
            <span className="grid size-9 place-items-center rounded-lg bg-primary text-primary-foreground"><Scale /></span>
            <span className="text-lg font-bold">ميزان</span>
          </Link>
          {user
            ? <Button variant="outline" nativeButton={false} render={<a href="/app" />}>الرجوع للنظام</Button>
            : <Button nativeButton={false} render={<Link to="/signup" />}>ابدأ مجانًا</Button>}
        </div>
      </header>

      <main className="mx-auto max-w-6xl px-4 py-16">
        <div className="text-center">
          <h1 className="text-4xl font-bold tracking-tight">خطط ميزان</h1>
          <p className="mx-auto mt-3 max-w-xl text-muted-foreground">
            كل خططة تبدأ بـ {TRIAL_DAYS} يوم مجاني بكل الميزات — بلا بطاقة، والقرار بعد ما تشوف نظامك شغّال.
          </p>
          {tenant?.plan === "trial" && (
            <div className="mx-auto mt-6 max-w-xl rounded-xl border border-warning/40 bg-warning/10 p-4 text-sm">
              أنت الآن على التجربة المجانية. فعّل خطتك ليكمل بعد انتهاء المدة —
              والبيانات كلها هتفضل زي ما هي.
            </div>
          )}
        </div>

        {!user && (
          <div className="mx-auto mt-6 flex max-w-sm items-center gap-2">
            <Input placeholder="رقم الموبايل (اختياري) للتواصل السريع" value={phone} onChange={(e) => setPhone(e.target.value)} />
          </div>
        )}

        <div className="mt-12 grid gap-6 md:grid-cols-3">
          {PLANS.map((p) => (
            <div key={p.id} className={`relative rounded-2xl border bg-card p-7 ${p.popular ? "border-primary shadow-lg" : ""}`}>
              {p.popular && <Badge className="absolute -top-3 right-6">الأكثر اختيارًا</Badge>}
              <h3 className="text-xl font-bold">{p.name}</h3>
              <p className="mt-1 text-sm text-muted-foreground">{p.tagline}</p>
              <p className="mt-5">
                {p.price_egp
                  ? <><span className="num text-5xl font-bold tracking-tight">{p.price_egp}</span> <span className="text-sm text-muted-foreground">ج.م / شهريًا</span></>
                  : <span className="text-3xl font-bold">حسب الاحتياج</span>}
              </p>
              <ul className="mt-6 flex flex-col gap-2.5 text-sm">
                {p.features.map((f) => (
                  <li key={f} className="flex items-center gap-2">
                    <Check className="size-4 shrink-0 text-success" aria-hidden />
                    {f}
                  </li>
                ))}
              </ul>
              <Button
                variant={p.popular ? "default" : "outline"}
                className="mt-7 w-full"
                disabled={busyPlan === p.id}
                onClick={() => requestPlan(p.id)}
              >
                {user ? (p.price_egp ? "اشترك في الخطة" : "اطلب عرض سعر") : "ابدأ تجربة مجانية"}
              </Button>
            </div>
          ))}
        </div>

        <p className="mt-10 text-center text-sm text-muted-foreground">
          الدفع حاليًا بتحويل أو محفظة إلكترونية — اضغط «اشترك» وهنكلمك نفعّلها في دقايق.
        </p>
      </main>
    </div>
  );
}
