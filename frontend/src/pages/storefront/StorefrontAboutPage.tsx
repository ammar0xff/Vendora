import { Link } from 'react-router-dom'
import { Package, Truck, ShieldCheck, Headset, Building2, Sparkles } from 'lucide-react'
import { useStorefrontStore } from '../../store/storefront'
import StorefrontNav from './StorefrontNav'

export default function StorefrontAboutPage() {
  const { cart, wishlist } = useStorefrontStore()

  return (
    <div className="min-h-screen bg-[var(--bg)]">
      <StorefrontNav cartCount={cart.reduce((n, i) => n + i.qty, 0)} wishlistCount={wishlist.length} />

      <section className="bg-gradient-to-b from-[var(--primary-soft)] to-transparent">
        <div className="max-w-3xl mx-auto px-4 py-16 text-center">
          <span className="w-16 h-16 mx-auto mb-4 inline-flex items-center justify-center rounded-2xl bg-[var(--primary)] text-white"><Package size={32} /></span>
          <h1 className="text-3xl font-black text-[var(--ink)] mb-3">من نحن</h1>
          <p className="text-[var(--muted)] leading-relaxed">
            متجر ڤندورة هو الواجهة العامة لنظام ڤندورة لإدارة نقاط البيع والمخزون والحسابات. كل منتج هنا
            ببياناته الحقيقية — الباركود، الأسعار، الوحدات، والمقاسات — مباشرة من مخزوننا الفعلي. ما تراه هنا
            هو ما لدينا فعلاً، بالأرقام الحقيقية.
          </p>
        </div>
      </section>

      <section className="max-w-4xl mx-auto px-4 py-10">
        <div className="grid md:grid-cols-2 gap-4 mb-10">
          {[
            { icon: Building2, title: 'تجار ومحلات', sub: 'أسعار جملة خاصة لكبار العملاء — تواصل معنا لفتح حساب جملة واحصل على شريحة سعرية مخصّصة' },
            { icon: Truck, title: 'توصيل', sub: 'نوصّل طلباتك خلال 24 ساعة داخل المحافظة، والتغليف مجاني' },
            { icon: ShieldCheck, title: 'جودة أصلية', sub: 'منتجات من مصنّعين موثوقين — كل ماركة بضمان حقيقي' },
            { icon: Headset, title: 'دعم فني', sub: 'فريقنا متاح على مدار اليوم للاستفسارات وتتبع الطلبات' },
          ].map((f) => (
            <div key={f.title} className="bg-white rounded-2xl border border-[var(--border)] p-5 flex gap-4 items-start">
              <span className="w-11 h-11 rounded-xl bg-[var(--primary-soft)] text-[var(--primary)] flex items-center justify-center flex-shrink-0"><f.icon size={20} /></span>
              <div>
                <p className="font-black text-[var(--ink)] mb-1">{f.title}</p>
                <p className="text-sm text-[var(--muted)] leading-relaxed">{f.sub}</p>
              </div>
            </div>
          ))}
        </div>

        <div className="bg-white rounded-2xl border border-[var(--border)] p-8 text-center">
          <Sparkles size={28} className="mx-auto text-[var(--accent)] mb-3" />
          <h2 className="text-xl font-black text-[var(--ink)] mb-2">جاهز لطلبك؟</h2>
          <p className="text-sm text-[var(--muted)] mb-5">تصفّح الكتالوج، أضف لعربة التسوق، وأرسل طلبك — سنتولى الباقي.</p>
          <div className="flex items-center justify-center gap-3 flex-wrap">
            <Link to="/catalog" className="btn btn-primary px-6 py-3">تصفح المنتجات</Link>
            <Link to="/login" className="btn btn-outline px-6 py-3">دخول نظام ڤندورة</Link>
          </div>
        </div>
      </section>

      <footer className="bg-[var(--primary)] text-white mt-10">
        <div className="max-w-6xl mx-auto px-4 py-8 text-center text-sm text-white/70">© 2026 متجر ڤندورة — جميع الحقوق محفوظة</div>
      </footer>
    </div>
  )
}