import { Link } from 'react-router-dom'
import { Package, ShoppingCart, Heart } from 'lucide-react'
import { useStorefrontStore } from '../../store/storefront'
import { fixUploadUrl } from '../../utils/format'
import type { StorefrontProduct } from '../storefront/types'

export default function StorefrontProductCard({ p }: { p: StorefrontProduct }) {
  const { wishlist, addToCart, toggleWishlist } = useStorefrontStore()
  return (
    <div className="bg-white rounded-2xl border border-[var(--border)] overflow-hidden hover:border-[var(--primary-border)] hover:shadow-lg transition-all group relative">
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
          <p className="text-xs text-[var(--muted)] mb-0.5">{p.code || p.company}</p>
          <p className="text-sm font-bold text-[var(--ink)] truncate mb-2">{p.name}</p>
          <div className="flex items-center justify-between">
            <p className="text-sm font-black text-[var(--primary)] tabular-nums">{Number(p.retail_price).toLocaleString('ar-EG')} <span className="text-[10px] font-normal">ج.م</span></p>
            <button
              onClick={(e) => { e.preventDefault(); e.stopPropagation(); addToCart({ product_id: p.id, name: p.name, unit_price: Number(p.retail_price), qty: 1, image_url: p.image_url, unit: p.unit }) }}
              className="w-9 h-9 rounded-xl bg-[var(--primary)] text-white flex items-center justify-center hover:bg-[var(--primary-strong)]"
              aria-label="أضف للعربة"
            >
              <ShoppingCart size={16} />
            </button>
          </div>
        </div>
      </Link>
    </div>
  )
}