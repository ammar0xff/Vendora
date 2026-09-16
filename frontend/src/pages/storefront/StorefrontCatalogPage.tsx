import { useState, useEffect } from 'react'
import { useQuery } from '@tanstack/react-query'
import { useSearchParams } from 'react-router-dom'
import { Search, PackageSearch, ChevronLeft, ChevronRight } from 'lucide-react'
import { storefrontApi } from '../../api/endpoints'
import { useStorefrontStore } from '../../store/storefront'
import StorefrontNav from './StorefrontNav'
import StorefrontProductCard from './StorefrontProductCard'

const PAGE_SIZE = 24

export default function StorefrontCatalogPage() {
  const [searchParams, setSearchParams] = useSearchParams()
  const categoryFromUrl = searchParams.get('category') || ''
  const [search, setSearch] = useState('')
  const [debounced, setDebounced] = useState('')
  const [page, setPage] = useState(1)
  useEffect(() => { setPage(1) }, [categoryFromUrl])
  useEffect(() => {
    const t = setTimeout(() => { setDebounced(search); setPage(1) }, 300)
    return () => clearTimeout(t)
  }, [search])

  const params: Record<string, unknown> = { page, page_size: PAGE_SIZE }
  if (debounced) params.search = debounced
  if (categoryFromUrl) params.category_id = categoryFromUrl

  const { data: catList } = useQuery({ queryKey: ['storefront-categories'], queryFn: storefrontApi.categories })
  const activeCat = catList?.find((c: { id: string }) => c.id === categoryFromUrl)
  const categoryName = activeCat?.name

  const { data, isLoading, isFetching } = useQuery({
    queryKey: ['storefront-catalog', debounced, categoryFromUrl, page],
    queryFn: () => storefrontApi.products(params),
  })
  const items = data?.items ?? []
  const pages = Math.max(1, data?.pages ?? 1)
  const { cart, wishlist } = useStorefrontStore()

  return (
    <div className="min-h-screen" style={{ background: 'var(--bg)' }}>
      <StorefrontNav cartCount={cart.reduce((n, i) => n + i.qty, 0)} wishlistCount={wishlist.length} />

      <section className="bg-white border-b" style={{ borderColor: 'var(--border)' }}>
        <div className="max-w-6xl mx-auto px-4 py-6 text-right">
          <div className="flex items-center justify-between gap-4 mb-4">
            {categoryFromUrl && activeCat?.image_url && (
              <div className="flex-1 flex items-center gap-4">
                <img
                  src={activeCat.image_url}
                  alt={categoryName}
                  className="w-14 h-14 rounded-xl object-cover shadow-sm"
                  loading="lazy"
                />
                <div>
                  <h1 className="text-2xl font-black text-[var(--ink)]">{categoryName}</h1>
                  <p className="text-sm text-[var(--muted)] mt-0.5 tabular-nums">
                    {(activeCat.product_count ?? 0).toLocaleString('ar-EG')} صنف متوفر
                  </p>
                </div>
              </div>
            )}
            {!categoryFromUrl && <h1 className="text-2xl font-black text-[var(--ink)]">كتالوج المنتجات</h1>}
            {categoryFromUrl && (
              <button onClick={() => setSearchParams({})} className="text-sm font-bold text-[var(--primary)] hover:underline shrink-0">عرض الكل</button>
            )}
          </div>
          <div className="relative max-w-md">
            <input
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="ابحث بالاسم أو الكود..."
              className="input w-full"
              style={{ paddingLeft: 40 }}
            />
            <Search size={18} className="absolute right-3 top-1/2 -translate-y-1/2 text-[var(--muted)]" />
          </div>
        </div>
      </section>

      <section className="max-w-6xl mx-auto px-4 py-8">
        {isLoading ? (
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">{[...Array(8)].map((_, i) => <div key={i} className="bg-white rounded-2xl border aspect-[3/4] animate-pulse" style={{ borderColor: 'var(--border)' }} />)}</div>
        ) : items.length === 0 ? (
          <div className="bg-white rounded-2xl border border-dashed p-16 flex flex-col items-center gap-4 text-center" style={{ borderColor: 'var(--primary-border)' }}>
            <PackageSearch size={48} className="text-[var(--muted)]" />
            <p className="font-bold text-[var(--ink)]">لا توجد منتجات مطابقة</p>
            <p className="text-sm text-[var(--muted)]">جرّب كلمة بحث أخرى، أو تصفح الكتالوج الكامل</p>
          </div>
        ) : (
          <>
            <div className={`grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 ${isFetching ? 'opacity-60' : ''}`}>
              {items.map((p) => (
                <StorefrontProductCard key={p.id} p={p} />
              ))}
            </div>
            {pages > 1 && (
              <div className="flex items-center justify-center gap-3 mt-8">
                <button
                  onClick={() => setPage((p) => Math.max(1, p - 1))}
                  disabled={page <= 1}
                  className="btn btn-outline px-4 py-2 flex items-center gap-1 disabled:opacity-40"
                >
                  <ChevronRight size={16} /> السابق
                </button>
                <span className="text-sm font-bold text-[var(--ink)] tabular-nums">{page} / {pages}</span>
                <button
                  onClick={() => setPage((p) => Math.min(pages, p + 1))}
                  disabled={page >= pages}
                  className="btn btn-outline px-4 py-2 flex items-center gap-1 disabled:opacity-40"
                >
                  التالي <ChevronLeft size={16} />
                </button>
              </div>
            )}
          </>
        )}
      </section>
    </div>
  )
}