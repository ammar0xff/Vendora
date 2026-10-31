import { Link } from "react-router-dom";
import { Scale } from "lucide-react";
import { ArrowLeft, BarChart3, Boxes, Check, Receipt, ShoppingCart, Truck, Wallet } from "lucide-react";
import { PLANS } from "./plans";
import { Button } from "@/components/kit/button";
import { Badge } from "@/components/kit/badge";

const FEATURES = [
  { icon: ShoppingCart, title: "نقطة بيع سريعة", desc: "باركود، تجزئة وجملة، بيع آجل، دفع مقسّم — وفاتورة في ثوانٍ حتى بدون إنترنت." },
  { icon: Boxes, title: "مخزون لحظي", desc: "رصيد كل صنف في كل فرع لحظيًا، تنبيهات نواقص، وتقييم المخزون بالتكلفة والبيع." },
  { icon: Receipt, title: "فواتير ومرتجعات", desc: "فواتير رسمية، عروض أسعار، مرتجع كلي وجزئي — كل حركة مسجلة في سجل تدقيق." },
  { icon: Truck, title: "مشتريات وموردون", desc: "أوامر شراء، استلام جزئي، أسعار مشتريات تاريخية، وذمم الموردين." },
  { icon: Wallet, title: "خزائن ومحافظ", desc: "خزينة كل فرع، محافظ إلكترونية، تحويل بين الخزائن، ومراكز مصروفات." },
  { icon: BarChart3, title: "تقارير تفهمها", desc: "مبيعات يومية وشهرية، الأكثر مبيعًا، أداء الكاشيرين، أعمار الديون — بلا محاسب." },
];

const SECTORS = ["أدوات صحية وسباكة", "كهرباء وإضاءة", "سيراميك وبورسلان", "دهانات وأصباغ"];

export default function LandingPage() {
  return (
    <div className="min-h-svh bg-background text-foreground">
      {/* Nav */}
      <header className="sticky top-0 z-30 border-b bg-background/85 backdrop-blur">
        <div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-4">
          <div className="flex items-center gap-2">
            <span className="grid size-9 place-items-center rounded-lg bg-primary text-primary-foreground">
              <Scale />
            </span>
            <span className="text-lg font-bold">ميزان</span>
          </div>
          <nav className="flex items-center gap-2">
            <Link to="/pricing" className="rounded-md px-3 py-2 text-sm font-medium text-muted-foreground transition hover:text-foreground">
              الأسعار
            </Link>
            <Link to="/login" className="rounded-md px-3 py-2 text-sm font-medium text-muted-foreground transition hover:text-foreground">
              تسجيل الدخول
            </Link>
            <Button nativeButton={false} render={<Link to="/signup" />}>
              ابدأ مجانًا
            </Button>
          </nav>
        </div>
      </header>

      {/* Hero */}
      <section className="mx-auto max-w-6xl px-4 pb-16 pt-20 text-center">
        <Badge variant="secondary" className="mb-5">أول نظام إدارة مصري لنُهُد المواد والبناء</Badge>
        <h1 className="mx-auto max-w-3xl text-balance text-4xl font-bold tracking-tight sm:text-6xl">
          نظامك كامل للبيع والمخزون والفروع — من أول يوم
        </h1>
        <p className="mx-auto mt-5 max-w-2xl text-pretty text-lg text-muted-foreground">
          ميزان يشغّل نقطة البيع والمخزون والفواتير والمشتريات والخزائن لمعرضك أو ورشتك.
          سجّل، أجب على ٣ أسئلة، وهتلاقي نظامك شغّال ببيانات تجريبية على قطاعتك — مجانًا ١٤ يوم.
        </p>
        <div className="mt-8 flex flex-wrap items-center justify-center gap-3">
          <Button size="lg" nativeButton={false} render={<Link to="/signup" />}>
            جرّب ميزان مجانًا
            <ArrowLeft data-icon="inline-end" />
          </Button>
          <Button size="lg" variant="outline" nativeButton={false} render={<Link to="/pricing" />}>
            شاهد الخطط
          </Button>
        </div>
        <div className="mt-6 flex flex-wrap items-center justify-center gap-2 text-sm text-muted-foreground">
          {["بدون بطاقة", "عربي بالكامل", "يعمل بلا إنترنت في الكاشير"].map((t) => (
            <span key={t} className="inline-flex items-center gap-1.5">
              <Check className="size-4 text-success" aria-hidden /> {t}
            </span>
          ))}
        </div>
      </section>

      {/* Sectors */}
      <section className="border-y bg-card py-8">
        <div className="mx-auto flex max-w-6xl flex-wrap items-center justify-center gap-x-8 gap-y-3 px-4 text-sm font-medium text-muted-foreground">
          <span className="text-xs font-semibold tracking-wide text-primary">مصمم لنشاطات:</span>
          {SECTORS.map((s) => <span key={s}>{s}</span>)}
          <span>وأي معرض بيع بالقطعة</span>
        </div>
      </section>

      {/* Features */}
      <section className="mx-auto max-w-6xl px-4 py-20">
        <h2 className="text-center text-3xl font-bold tracking-tight">كل اللي معرضك محتاجه في مكان واحد</h2>
        <p className="mt-3 text-center text-muted-foreground">من الكاشير للرواتب — نظام واحد بصلاحيات لكل موظف</p>
        <div className="mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {FEATURES.map((f) => (
            <div key={f.title} className="rounded-xl border bg-card p-6">
              <span className="mb-4 grid size-11 place-items-center rounded-lg bg-primary/10 text-primary">
                <f.icon className="size-5" aria-hidden />
              </span>
              <h3 className="font-semibold">{f.title}</h3>
              <p className="mt-2 text-sm leading-7 text-muted-foreground">{f.desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* Pricing teaser */}
      <section className="border-t bg-card py-20">
        <div className="mx-auto max-w-6xl px-4">
          <h2 className="text-center text-3xl font-bold tracking-tight">خطط واضحة، بلا مفاجآت</h2>
          <div className="mt-12 grid gap-6 md:grid-cols-3">
            {PLANS.map((p) => (
              <div key={p.id} className={`rounded-xl border bg-background p-6 ${p.popular ? "border-primary shadow-md" : ""}`}>
                {p.popular && <Badge className="mb-3">الأكثر اختيارًا</Badge>}
                <h3 className="text-lg font-bold">{p.name}</h3>
                <p className="mt-1 text-sm text-muted-foreground">{p.tagline}</p>
                <p className="mt-4">
                  {p.price_egp
                    ? <><span className="num text-4xl font-bold">{p.price_egp}</span> <span className="text-sm text-muted-foreground">ج.م / شهريًا</span></>
                    : <span className="text-2xl font-bold">حسب الاحتياج</span>}
                </p>
                <Button variant={p.popular ? "default" : "outline"} className="mt-6 w-full" nativeButton={false} render={<Link to="/signup" />}>
                  ابدأ الآن
                </Button>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Final CTA */}
      <section className="mx-auto max-w-6xl px-4 py-24 text-center">
        <h2 className="text-3xl font-bold tracking-tight">جاهز تعرف ميزان يومك؟</h2>
        <p className="mx-auto mt-3 max-w-xl text-muted-foreground">
          دقايق وتلاقي نظامك شغّال بأصناف قطاعتك — والقرار بعد ما تشوف بعينك.
        </p>
        <Button size="lg" className="mt-8" nativeButton={false} render={<Link to="/signup" />}>
          ابدأ تجربتك المجانية
        </Button>
      </section>

      <footer className="border-t py-8 text-center text-sm text-muted-foreground">
        ميزان — نظام إدارة التجار بالجملة والتجزئة · صُنع في مصر
      </footer>
    </div>
  );
}
