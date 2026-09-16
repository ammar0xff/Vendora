import { useState } from 'react'
import { useParams, Link } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { Package, ShoppingCart, Heart, ArrowRight, Minus, Plus, Truck, ShieldCheck, Headset, Ruler, Building2 } from 'lucide-react'
import { storefrontApi } from '../../api/endpoints'
import { useStorefrontStore } from '../../store/storefront'
import StorefrontNav from './StorefrontNav'
import StorefrontProductCard from './StorefrontProductCard'
import { fixUploadUrl } from '../../utils/format'

export default function StorefrontProductDetailPage() {
  const { id = '' } = useParams()
  const [qty, setQty] = useState(1)
  const [activeImage, setActiveImage] = useState(0)
  const { cart, wishlist, addToCart, toggleWishlist } = useStorefrontStore()

  const { data: p, isLoading } = useQuery({
    queryKey: ['storefront-product', id],
    queryFn: () => storefrontApi.product(id),
    enabled: !!id,
  })

  const { data: relatedData } = useQuery({
    queryKey: ['storefront-related', p?.category_id],
    queryFn: () => storefrontApi.products({ category_id: p!.category_id!, page_size: 4 }),
    enabled: !!p?.category_id,
  })
  const related = (relatedData?.items ?? []).filter((r: { id: string }) => r.id !== p?.id).slice(0, 4)

  const inCart = cart.find((i) => i.product_id === id)

  if (isLoading) {
    return (
      <div className="min-h-screen bg-[var(--bg)]">
        <StorefrontNav cartCount={0} wishlistCount={0} />
        <div className="max-w-6xl mx-auto px-4 py-10 grid md:grid-cols-2 gap-8">
          <div className="aspect-square bg-white rounded-3xl border border-[var(--border)] animate-pulse" />
          <div className="space-y-4"><div className="h-8 bg-white rounded-xl animate-pulse w-2/3" /><div className="h-4 bg-white rounded-xl animate-pulse w-full" /><div className="h-4 bg-white rounded-xl animate-pulse w-1/2" /></div>
        </div>
      </div>
    )
  }

  if (!p) {
    return (
      <div className="min-h-screen bg-[var(--bg)]">
        <StorefrontNav cartCount={cart.reduce((n, i) => n + i.qty, 0)} wishlistCount={wishlist.length} />
        <div className="max-w-6xl mx-auto px-4 py-24 flex flex-col items-center gap-4 text-center">
          <Package size={48} className="text-[var(--muted)]" />
          <p className="font-bold text-[var(--ink)]">المنتج غير متوفر</p>
          <Link to="/catalog" className="btn btn-primary px-6 py-2.5">العودة للكتالوج</Link>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-[var(--bg)]">
      <StorefrontNav cartCount={cart.reduce((n, i) => n + i.qty, 0)} wishlistCount={wishlist.length} />

      <section className="max-w-6xl mx-auto px-4 py-6">
        <nav className="text-xs text-[var(--muted)] mb-5 flex items-center gap-1 flex-wrap">
          <Link to="/" className="hover:text-[var(--primary)]">الرئيسية</Link>
          <span>←</span>
          <Link to="/catalog" className="hover:text-[var(--primary)]">المنتجات</Link>
          {p.category_name && <><span>←</span><span className="text-[var(--ink)]">{p.category_name}</span></>}
        </nav>

        <div className="grid md:grid-cols-2 gap-8 items-start">
          <div className="bg-white rounded-3xl border border-[var(--border)] overflow-hidden">
            <div className="aspect-square bg-[var(--primary-soft)] flex items-center justify-center overflow-hidden">
              {(() => {
                const gallery = p.images?.length ? p.images : p.image_url ? [p.image_url] : []
                const src = gallery[activeImage] || gallery[0]
                return src ? (
                  <img src={fixUploadUrl(src)} alt={p.name} className="w-full h-full object-cover" />
                ) : (
                  <Package size={80} className="text-[var(--primary)]" />
                )
              })()}
            </div>
            {p.images && p.images.length > 1 && (
              <div className="flex gap-2 p-3 overflow-x-auto">
                {p.images.map((img, i) => (
                  <button
                    key={i}
                    onClick={() => setActiveImage(i)}
                    className={`w-16 h-16 rounded-xl shrink-0 border-2 overflow-hidden transition ${i === activeImage ? 'border-[var(--primary)]' : 'border-transparent hover:border-[var(--border-strong)]'}`}
                  >
                    <img src={fixUploadUrl(img)} alt="" className="w-full h-full object-cover" />
                  </button>
                ))}
              </div>
            )}
          </div>

          <div className="text-right">
            <p className="text-xs font-bold text-[var(--muted)] mb-1">{p.code || (p.category_name ?? 'منتج')}</p>
            <h1 className="text-2xl md:text-3xl font-black text-[var(--ink)] mb-3">{p.name}</h1>

            <div className="flex items-baseline gap-3 mb-5">
              <span className="text-3xl font-black text-[var(--primary)] tabular-nums">{Number(p.retail_price).toLocaleString('ar-EG')} <span className="text-sm font-normal">ج.م</span></span>
              {Number(p.wholesale_price) > 0 && Number(p.wholesale_price) !== Number(p.retail_price) && (
                <span className="text-lg font-bold text-[var(--muted)] tabular-nums line-through">{Number(p.wholesale_price).toLocaleString('ar-EG')}</span>
              )}
            </div>

            <div className="grid grid-cols-2 gap-3 mb-6">
              {p.unit && (
                <div className="flex items-center gap-3 bg-white rounded-xl border border-[var(--border)] p-3">
                  <span className="w-9 h-9 rounded-lg bg-[var(--primary-soft)] text-[var(--primary)] flex items-center justify-center"><Package size={16} /></span>
                  <div><p className="text-[10px] text-[var(--muted)]">الوحدة</p><p className="text-sm font-bold text-[var(--ink)]">{p.unit}</p></div>
                </div>
              )}
              {p.company && (
                <div className="flex items-center gap-3 bg-white rounded-xl border border-[var(--border)] p-3">
                  <span className="w-9 h-9 rounded-lg bg-[var(--primary-soft)] text-[var(--primary)] flex items-center justify-center"><Building2 size={16} /></span>
                  <div><p className="text-[10px] text-[var(--muted)]">الشركة</p><p className="text-sm font-bold text-[var(--ink)]">{p.company}</p></div>
                </div>
              )}
              {p.size && (
                <div className="flex items-center gap-3 bg-white rounded-xl border border-[var(--border)] p-3">
                  <span className="w-9 h-9 rounded-lg bg-[var(--primary-soft)] text-[var(--primary)] flex items-center justify-center"><Ruler size={16} /></span>
                  <div><p className="text-[10px] text-[var(--muted)]">المقاس</p><p className="text-sm font-bold text-[var(--ink)]">{p.size}</p></div>
                </div>
              )}
            </div>

            <div className="flex items-center gap-3 mb-6">
              <div className="flex items-center gap-2 bg-white rounded-xl border border-[var(--border)] p-2">
                <button onClick={() => setQty((q) => Math.max(1, q - 1))} className="w-9 h-9 rounded-lg bg-[var(--primary-soft)] text-[var(--primary)] flex items-center justify-center" aria-label="إنقاص"><Minus size={15} /></button>
                <span className="w-10 text-center font-black text-[var(--ink)] tabular-nums">{qty}</span>
                <button onClick={() => setQty((q) => q + 1)} className="w-9 h-9 rounded-lg bg-[var(--primary-soft)] text-[var(--primary)] flex items-center justify-center" aria-label="زيادة"><Plus size={15} /></button>
              </div>
              <button
                onClick={() => addToCart({ product_id: p.id, name: p.name, unit_price: Number(p.retail_price), qty, image_url: p.image_url, unit: p.unit })}
                className="btn btn-primary flex-1 py-3 flex items-center justify-center gap-2"
              >
                <ShoppingCart size={18} />{inCart ? 'أُضيف إلى العربة ✓' : 'أضف للعربة'}
              </button>
              <button
                onClick={() => toggleWishlist(p.id)}
                className={`w-12 h-12 rounded-xl flex items-center justify-center border ${wishlist.includes(p.id) ? 'bg-[var(--accent)] text-white border-transparent' : 'bg-white text-slate-700 border-[var(--border)] hover:text-[var(--accent)]'}`}
                aria-label="المفضلة"
              >
                <Heart size={18} fill={wishlist.includes(p.id) ? 'currentColor' : 'none'} />
              </button>
            </div>

            <div className="grid grid-cols-3 gap-3">
              {[
                { icon: Truck, title: 'توصيل سريع', sub: 'خلال 24 ساعة' },
                { icon: ShieldCheck, title: 'جودة مضمونة', sub: 'ماركات أصلية' },
                { icon: Headset, title: 'دعم فني', sub: 'على مدار اليوم' },
              ].map((f) => (
                <div key={f.title} className="bg-white rounded-xl border border-[var(--border)] p-3 text-center">
                  <f.icon size={18} className="mx-auto text-[var(--primary)] mb-1" />
                  <p className="text-xs font-bold text-[var(--ink)]">{f.title}</p>
                  <p className="text-[10px] text-[var(--muted)]">{f.sub}</p>
                </div>
              ))}
            </div>
          </div>
        </div>

        {p.description && (
          <div className="mt-8 bg-white rounded-3xl border border-[var(--border)] p-6 md:p-8 text-right">
            <h2 className="text-lg font-black text-[var(--ink)] mb-3">وصف المنتج</h2>
            <p className="text-sm leading-7 text-slate-600 whitespace-pre-line">{p.description}</p>
          </div>
        )}

        {related.length > 0 && (
          <section className="mt-14">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-black text-[var(--ink)]">منتجات مشابهة</h2>
              <Link to="/catalog" className="text-sm font-bold text-[var(--primary)] flex items-center gap-1">عرض الكل <ArrowRight size={14} /></Link>
            </div>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              {related.map((r: { id: string }) => (
                <StorefrontProductCard key={r.id} p={r} />
              ))}
            </div>
          </section>
        )}
      </section>
    </div>
  )
}