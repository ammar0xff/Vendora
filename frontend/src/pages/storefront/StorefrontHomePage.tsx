import { useQuery } from '@tanstack/react-query'
import { Link } from 'react-router-dom'
import { Package, Truck, ShieldCheck, Headset } from 'lucide-react'
import { storefrontApi } from '../../api/endpoints'
import { useStorefrontStore } from '../../store/storefront'
import StorefrontNav from './StorefrontNav'
import StorefrontHero from './StorefrontHero'
import StorefrontCategoryShowcase from './StorefrontCategoryShowcase'
import StorefrontProductCard from './StorefrontProductCard'
import StorefrontPromo from './StorefrontPromo'
import StorefrontTestimonials from './StorefrontTestimonials'

export default function StorefrontHomePage() {
  const { cart, wishlist } = useStorefrontStore()

  const { data } = useQuery({ queryKey: ['storefront-home'], queryFn: () => storefrontApi.products({ page: 1, page_size: 8 }) })
  const items = data?.items ?? []
  const totalProducts = data?.total ?? 0

  const { data: categories } = useQuery({ queryKey: ['storefront-categories'], queryFn: storefrontApi.categories })
  const catList = categories ?? []

  return (
    <div className="min-h-screen" style={{ background: 'var(--bg)' }}>
      <StorefrontNav cartCount={cart.reduce((n, i) => n + i.qty, 0)} wishlistCount={wishlist.length} />

      <StorefrontHero products={items} totalProducts={totalProducts} categoryCount={catList.length} />

      {catList.length > 0 && <StorefrontCategoryShowcase categories={catList} />}

      {items.length > 0 && (
        <section className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8 py-14">
          <div className="flex items-end justify-between mb-8">
            <div className="text-right">
              <p className="text-sm font-bold uppercase tracking-wider text-[var(--primary)]">الأكثر مبيعاً</p>
              <h2 className="text-2xl sm:text-3xl font-black tracking-tight mt-2 text-[var(--ink)]">منتجات مميزة</h2>
            </div>
            <Link to="/store/catalog" className="text-sm font-bold text-[var(--primary)]">عرض الكل ←</Link>
          </div>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {items.map((p) => (
              <StorefrontProductCard key={p.id} p={p} />
            ))}
          </div>
        </section>
      )}

      <StorefrontPromo />
      <StorefrontTestimonials />

      <section className="max-w-6xl mx-auto px-4 py-10 grid grid-cols-2 md:grid-cols-4 gap-4 mb-10">
        {[
          { icon: Truck, title: 'توصيل سريع', sub: 'خلال 24 ساعة' },
          { icon: ShieldCheck, title: 'جودة مضمونة', sub: 'ماركات أصلية' },
          { icon: Headset, title: 'دعم فني', sub: 'على مدار اليوم' },
          { icon: Package, title: 'أسعار جملة', sub: 'لأصحاب المحلات' },
        ].map((f) => (
          <div key={f.title} className="bg-white rounded-2xl border p-4 flex items-center gap-3" style={{ borderColor: 'var(--border)' }}>
            <span className="w-10 h-10 rounded-xl bg-[var(--primary-soft)] text-[var(--primary)] flex items-center justify-center flex-shrink-0"><f.icon size={20} /></span>
            <div>
              <p className="text-sm font-bold text-[var(--ink)]">{f.title}</p>
              <p className="text-xs text-[var(--muted)]">{f.sub}</p>
            </div>
          </div>
        ))}
      </section>

      <footer className="text-white" style={{ background: 'var(--primary)' }}>
        <div className="max-w-6xl mx-auto px-4 py-10 grid md:grid-cols-3 gap-8">
          <div className="text-right">
            <div className="flex items-center gap-2 mb-3 justify-start">
              <span className="w-8 h-8 rounded-lg bg-white/15 flex items-center justify-center"><Package size={16} /></span>
              <span className="font-black">متجر ڤندورة</span>
            </div>
            <p className="text-sm text-white/70 leading-relaxed">منصة الجملة والتجزئة المتكاملة — كتالوج موحّد ببيانات سعرية حقيقية من نظامك.</p>
          </div>
          <div className="text-right">
            <p className="font-bold mb-3">روابط سريعة</p>
            <ul className="space-y-2 text-sm text-white/70">
              <li><Link to="/store/catalog" className="hover:text-white">المنتجات</Link></li>
              <li><Link to="/store/cart" className="hover:text-white">عربة التسوق</Link></li>
              <li><Link to="/store/wishlist" className="hover:text-white">المفضلة</Link></li>
              <li><Link to="/store/about" className="hover:text-white">من نحن</Link></li>
            </ul>
          </div>
          <div className="text-right">
            <p className="font-bold mb-3">تواصل معنا</p>
            <ul className="space-y-2 text-sm text-white/70">
              <li>دعم فني: 24/7</li>
              <li>الجملة: خصومات خاصة</li>
              <li>الدفع عند الاستلام</li>
            </ul>
          </div>
        </div>
        <div className="border-t py-4 text-center text-xs text-white/50" style={{ borderColor: 'rgba(255,255,255,0.15)' }}>© 2026 متجر ڤندورة — جميع الحقوق محفوظة</div>
      </footer>
    </div>
  )
}