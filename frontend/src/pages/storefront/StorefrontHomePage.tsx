import { useQuery } from '@tanstack/react-query'
import { Link } from 'react-router-dom'
import { Package, ShoppingCart, Heart, Search, Truck, ShieldCheck, Headset } from 'lucide-react'
import { productsApi } from '../../api/endpoints'
import { useStorefrontStore } from '../../store/storefront'
import { fixUploadUrl } from '../../utils/format'

export default function StorefrontHomePage() {
  const { data } = useQuery({ queryKey: ['storefront-home'], queryFn: () => productsApi.listPage({ page: 1, page_size: 12 }) })
  const items = data?.items ?? []
  const { cart, wishlist, addToCart, toggleWishlist } = useStorefrontStore()

  const featured = items.slice(0, 8)
  const newArrivals = items.slice(4, 12)

  return (
    <div className="min-h-screen bg-[var(--bg)]">
      <header className="sticky top-0 z-40 bg-white/80 backdrop-blur-md border-b border-[var(--line)]">
        <div className="max-w-6xl mx-auto px-4 py-3 flex items-center justify-between gap-4">
          <Link to="/store" className="flex items-center gap-2">
            <span className="w-9 h-9 rounded-xl bg-[var(--primary)] text-white flex items-center justify-center"><Package size={20} /></span>
            <span className="text-lg font-black text-[var(--primary)]">متجر ڤندورة</span>
          </Link>
          <nav className="hidden md:flex items-center gap-1 text-sm font-semibold text-[var(--ink)]">
            <Link to="/store" className="px-3 py-1.5 rounded-lg bg-[var(--primary-soft)] text-[var(--primary)]">الرئيسية</Link>
            <Link to="/store/catalog" className="px-3 py-1.5 rounded-lg hover:bg-[var(--primary-soft)] hover:text-[var(--primary)]">المنتجات</Link>
            <Link to="/store/about" className="px-3 py-1.5 rounded-lg hover:bg-[var(--primary-soft)] hover:text-[var(--primary)]">من نحن</Link>
          </nav>
          <div className="flex items-center gap-2">
            <Link to="/store/wishlist" className="relative w-10 h-10 rounded-xl bg-[var(--primary-soft)] text-[var(--primary)] flex items-center justify-center">
              <Heart size={18} />
              {wishlist.length > 0 && (
                <span className="absolute -top-1 -left-1 min-w-5 h-5 px-1 rounded-full bg-[var(--accent)] text-white text-[10px] font-bold flex items-center justify-center">{wishlist.length}</span>
              )}
            </Link>
            <Link to="/store/cart" className="relative w-10 h-10 rounded-xl bg-[var(--primary)] text-white flex items-center justify-center">
              <ShoppingCart size={18} />
              {cart.length > 0 && (
                <span className="absolute -top-1 -left-1 min-w-5 h-5 px-1 rounded-full bg-[var(--accent)] text-white text-[10px] font-bold flex items-center justify-center">{cart.reduce((n, i) => n + i.qty, 0)}</span>
              )}
            </Link>
          </div>
        </div>
      </header>

      <section className="bg-gradient-to-b from-[var(--primary-soft)] to-transparent">
        <div className="max-w-6xl mx-auto px-4 py-16 grid md:grid-cols-2 gap-10 items-center">
          <div className="text-right">
            <span className="inline-block px-3 py-1 rounded-full bg-white text-[var(--primary)] text-xs font-bold border border-[var(--primary-border)] mb-4">الجملة والتجزئة — توصيل سريع</span>
            <h1 className="text-3xl md:text-4xl font-black text-[var(--ink)] leading-snug mb-4">
              كل منتجاتك من مكان واحد،<br />بأفضل سعر وثقة
            </h1>
            <p className="text-[var(--muted)] mb-6 leading-relaxed">تصفّح الكتالوج الكامل، أضف لعربة التسوق، واطلب بضغطة واحدة — بنفس بيانات الباركود والأسعار من ڤندورة.</p>
            <div className="flex items-center gap-3">
              <Link to="/store/catalog" className="btn btn-primary px-6 py-3">تصفح المنتجات</Link>
              <Link to="/store/catalog" className="btn btn-outline px-6 py-3 flex items-center gap-2"><Search size={16} /> ابحث في الكتالوج</Link>
            </div>
          </div>
          <div className="grid grid-cols-2 gap-6">
            {featured.slice(0, 4).map((p, idx) => (
              <Link key={p.id} to={`/store/products/${p.id}`} className={`${idx % 2 ? 'mt-6' : ''} bg-white rounded-2xl border border-[var(--line)] overflow-hidden hover:border-[var(--primary-border)] hover:shadow-lg transition-all group`}>
                <div className="aspect-square bg-[var(--primary-soft)] flex items-center justify-center overflow-hidden">
                  {p.image_url ? (
                    <img src={fixUploadUrl(p.image_url)} alt={p.name} className="w-full h-full object-cover group-hover:scale-105 transition-transform" />
                  ) : (
                    <Package size={40} className="text-[var(--primary)]" />
                  )}
                </div>
                <div className="p-3">
                  <p className="text-sm font-bold text-[var(--ink)] truncate mb-1">{p.name}</p>
                  <p className="text-sm font-black text-[var(--primary)] tabular-nums">{Number(p.retail_price).toLocaleString('ar-EG')} <span className="text-[10px] font-normal">ج.م</span></p>
                </div>
              </Link>
            ))}
          </div>
        </div>
      </section>

      <section className="max-w-6xl mx-auto px-4 py-12">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-black text-[var(--ink)]">منتجات مميزة</h2>
          <Link to="/store/catalog" className="text-sm font-bold text-[var(--primary)]">عرض الكل ←</Link>
        </div>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          {featured.map((p) => (
            <ProductCard key={p.id} p={p} />
          ))}
        </div>
      </section>

      <section className="max-w-6xl mx-auto px-4 py-8 grid grid-cols-2 md:grid-cols-4 gap-4 mb-10">
        {[
          { icon: Truck, title: 'توصيل سريع', sub: 'خلال 24 ساعة' },
          { icon: ShieldCheck, title: 'جودة مضمونة', sub: 'ماركات أصلية' },
          { icon: Headset, title: 'دعم فني', sub: 'على مدار اليوم' },
          { icon: Package, title: 'أسعار جملة', sub: 'لأصحاب المحلات' },
        ].map((f) => (
          <div key={f.title} className="bg-white rounded-2xl border border-[var(--line)] p-4 flex items-center gap-3">
            <span className="w-10 h-10 rounded-xl bg-[var(--primary-soft)] text-[var(--primary)] flex items-center justify-center flex-shrink-0"><f.icon size={20} /></span>
            <div>
              <p className="text-sm font-bold text-[var(--ink)]">{f.title}</p>
              <p className="text-xs text-[var(--muted)]">{f.sub}</p>
            </div>
          </div>
        ))}
      </section>

      <footer className="bg-[var(--primary)] text-white">
        <div className="max-w-6xl mx-auto px-4 py-10 grid md:grid-cols-3 gap-8">
          <div>
            <div className="flex items-center gap-2 mb-3">
              <span className="w-8 h-8 rounded-lg bg-white/15 flex items-center justify-center"><Package size={16} /></span>
              <span className="font-black">متجر ڤندورة</span>
            </div>
            <p className="text-sm text-white/70 leading-relaxed">منصة الجملة والتجزئة المتكاملة — كتالوج موحّد ببيانات سعرية حقيقية من نظامك.</p>
          </div>
          <div>
            <p className="font-bold mb-3">روابط سريعة</p>
            <ul className="space-y-2 text-sm text-white/70">
              <li><Link to="/store/catalog" className="hover:text-white">المنتجات</Link></li>
              <li><Link to="/store/cart" className="hover:text-white">عربة التسوق</Link></li>
              <li><Link to="/store/wishlist" className="hover:text-white">المفضلة</Link></li>
            </ul>
          </div>
          <div>
            <p className="font-bold mb-3">تواصل معنا</p>
            <ul className="space-y-2 text-sm text-white/70">
              <li>دعم فني: 24/7</li>
              <li>الجملة: خصومات خاصة</li>
              <li>الدفع عند الاستلام</li>
            </ul>
          </div>
        </div>
        <div className="border-t border-white/15 py-4 text-center text-xs text-white/50">© 2026 متجر ڤندورة — جميع الحقوق محفوظة</div>
      </footer>
    </div>
  )
}
