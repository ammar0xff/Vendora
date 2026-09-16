import { useState, useEffect } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Link } from 'react-router-dom'
import { Package, ShoppingCart, Heart, Search, PackageSearch } from 'lucide-react'
import { productsApi } from '../../api/endpoints'
import { useStorefrontStore } from '../../store/storefront'
import { fixUploadUrl } from '../../utils/format'

export default function StorefrontCatalogPage() {
  const [search, setSearch] = useState('')
  const [debounced, setDebounced] = useState('')
  useEffect(() => { const t = setTimeout(() => setDebounced(search), 300); return () => clearTimeout(t) }, [search])

  const { data, isLoading } = useQuery({
    queryKey: ['storefront-catalog', debounced],
    queryFn: () => productsApi.listPage({ page: 1, page_size: 60, ...(debounced ? { search: debounced } : {}) }),
  })
  const items = data?.items ?? []
  const { cart, wishlist, addToCart, toggleWishlist } = useStorefrontStore()

  return (
    <div className="min-h-screen bg-[var(--bg)]">
      <StorefrontNav cartCount={cart.reduce((n, i) => n + i.qty, 0)} wishlistCount={wishlist.length} />

      <section className="bg-white border-b border-[var(--line)]">
        <div className="max-w-6xl mx-auto px-4 py-6 text-right">
          <h1 className="text-2xl font-black text-[var(--ink)] mb-4">كتالوج المنتجات</h1>
          <div className="relative max-w-md">
            <input
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="ابحث بالاسم أو الكود..."
              className="input w-full pr-10"
            />
            <Search size={18} className="absolute right-3 top-1/2 -translate-y-1/2 text-[var(--muted)]" />
          </div>
        </div>
      </section>

      <section className="max-w-6xl mx-auto px-4 py-8">
        {isLoading ? (
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">{[...Array(8)].map((_, i) => <div key={i} className="bg-white rounded-2xl border border-[var(--line)] aspect-[3/4] animate-pulse" />)}</div>
        ) : items.length === 0 ? (
          <div className="bg-white rounded-2xl border border-dashed border-[var(--primary-border)] p-16 flex flex-col items-center gap-4 text-center">
            <PackageSearch size={48} className="text-[var(--muted)]" />
            <p className="font-bold text-[var(--ink)]">لا توجد منتجات مطابقة</p>
            <p className="text-sm text-[var(--muted)]">جرّب كلمة بحث أخرى، أو تصفح الكتالوج الكامل</p>
          </div>
        ) : (
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
            {items.map((p) => (
              <div key={p.id} className="bg-white rounded-2xl border border-[var(--line)] overflow-hidden hover:border-[var(--primary-border)] hover:shadow-lg transition-all group relative">
                <button
                  onClick={() => toggleWishlist(p.id)}
                  className={`absolute top-3 left-3 z-10 w-9 h-9 rounded-xl flex items-center justify-center transition-colors ${wishlist.includes(p.id) ? 'bg-[var(--accent)] text-white' : 'bg-white/90 text-[var(--muted)] hover:text-[var(--accent)]'}`}
                  aria-label="أضف للمفضلة"
                >
                  <Heart size={16} fill={wishlist.includes(p.id) ? 'currentColor' : 'none'} />
                </button>
                <Link to={`/store/products/${p.id}`} className="block">
                  <div className="aspect-square bg-[var(--primary-soft)] flex items-center justify-center overflow-hidden">
                    {p.image_url ? (
                      <img src={fixUploadUrl(p.image_url)} alt={p.name} loading="lazy" className="w-full h-full object-cover group-hover:scale-105 transition-transform" />
                    ) : (
                      <Package size={40} className="text-[var(--primary)]" />
                    )}
                  </div>
                  <div className="p-3">
                    <p className="text-xs text-[var(--muted)] mb-0.5">{p.code}</p>
                    <p className="text-sm font-bold text-[var(--ink)] truncate mb-2">{p.name}</p>
                    <div className="flex items-center justify-between">
                      <p className="text-sm font-black text-[var(--primary)] tabular-nums">{Number(p.retail_price).toLocaleString('ar-EG')} <span className="text-[10px] font-normal">ج.م</span></p>
                      <button
                        onClick={(e) => { e.preventDefault(); addToCart({ product_id: p.id, name: p.name, unit_price: Number(p.retail_price), qty: 1, image_url: p.image_url, unit: p.unit }) }}
                        className="w-9 h-9 rounded-xl bg-[var(--primary)] text-white flex items-center justify-center hover:bg-[var(--primary-strong)]"
                        aria-label="أضف للعربة"
                      >
                        <ShoppingCart size={16} />
                      </button>
                    </div>
                  </div>
                </Link>
              </div>
            ))}
          </div>
        )}
      </section>
    </div>
  )
}
