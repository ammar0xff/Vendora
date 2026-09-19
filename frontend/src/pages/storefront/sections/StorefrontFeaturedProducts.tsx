import { Link } from 'react-router-dom'
import StorefrontProductCard from '../StorefrontProductCard'
import type { StorefrontProduct } from '../types'

export default function StorefrontFeaturedProducts({ items, heading }: { items: StorefrontProduct[]; heading?: string }) {
  return (
    <section className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8 py-14" style={{ background: 'var(--bg)' }}>
      <div className="flex items-end justify-between mb-8">
        <div className="text-right">
          <p className="text-sm font-bold uppercase tracking-wider text-[var(--primary)]">الأكثر مبيعاً</p>
          <h2 className="text-2xl sm:text-3xl font-black tracking-tight mt-2 text-[var(--ink)]">{heading || 'منتجات مميزة'}</h2>
        </div>
        <Link to="/catalog" className="text-sm font-bold text-[var(--primary)]">عرض الكل ←</Link>
      </div>
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {items.map((p) => (
          <StorefrontProductCard key={p.id} p={p} />
        ))}
      </div>
    </section>
  )
}