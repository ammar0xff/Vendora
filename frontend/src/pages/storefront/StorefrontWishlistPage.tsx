import { useQuery } from '@tanstack/react-query'
import { Link } from 'react-router-dom'
import { Heart, ArrowRight, PackageSearch } from 'lucide-react'
import { storefrontApi } from '../../api/endpoints'
import { useStorefrontStore } from '../../store/storefront'
import StorefrontNav from './StorefrontNav'
import StorefrontProductCard from './StorefrontProductCard'

export default function StorefrontWishlistPage() {
  const { wishlist, cart, toggleWishlist } = useStorefrontStore()

  const { data, isLoading } = useQuery({
    queryKey: ['storefront-wishlist', wishlist],
    queryFn: async () => {
      if (wishlist.length === 0) return []
      const pages = await Promise.all(wishlist.map((id) => storefrontApi.product(id)))
      return pages
    },
    enabled: wishlist.length > 0,
  })
  const items = data ?? []

  return (
    <div className="min-h-screen bg-[var(--bg)]">
      <StorefrontNav cartCount={cart.reduce((n, i) => n + i.qty, 0)} wishlistCount={wishlist.length} />

      <section className="max-w-6xl mx-auto px-4 py-10">
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-2xl font-black text-[var(--ink)] flex items-center gap-2"><Heart size={22} className="text-[var(--accent)]" /> المفضلة</h1>
          <button onClick={() => wishlist.forEach((id) => toggleWishlist(id))} className="text-sm font-bold text-[var(--danger)] hover:underline">مسح الكل</button>
        </div>

        {wishlist.length === 0 ? (
          <div className="bg-white rounded-2xl border border-dashed border-[var(--primary-border)] p-16 flex flex-col items-center gap-4 text-center">
            <PackageSearch size={48} className="text-[var(--muted)]" />
            <p className="font-bold text-[var(--ink)]">لا توجد منتجات في المفضلة</p>
            <p className="text-sm text-[var(--muted)]">اضغط على أيقونة القلب في الكتالوج لإضافتها هنا</p>
            <Link to="/catalog" className="btn btn-primary px-6 py-2.5 mt-2">تصفح الكتالوج</Link>
          </div>
        ) : isLoading ? (
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">{[...Array(8)].map((_, i) => <div key={i} className="bg-white rounded-2xl border border-[var(--border)] aspect-[3/4] animate-pulse" />)}</div>
        ) : (
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
            {items.map((p) => (
              <StorefrontProductCard key={p.id} p={p} />
            ))}
          </div>
        )}
      </section>
    </div>
  )
}