import { motion } from 'framer-motion'
import { Link } from 'react-router-dom'
import { ArrowLeft } from 'lucide-react'
import type { StorefrontCategory } from './types'

const GRADIENTS = [
  'linear-gradient(135deg, #1e3a5f, #33618f)',
  'linear-gradient(135deg, #123f5d, #2e6b8f)',
  'linear-gradient(135deg, #0f4c5c, #1b7a8a)',
  'linear-gradient(135deg, #2d4f3c, #4d7a5e)',
  'linear-gradient(135deg, #5a4a8a, #7d6bb0)',
  'linear-gradient(135deg, #8a6d3b, #c8a84b)',
]

export default function StorefrontCategoryShowcase({ categories, heading }: { categories: StorefrontCategory[]; heading?: string }) {
  return (
    <section className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8 py-14">
      <div className="flex items-end justify-between mb-8">
        <div className="text-right">
          <p className="text-sm font-bold uppercase tracking-wider text-[var(--primary)]">تصفح حسب التصنيف</p>
          <h2 className="text-2xl sm:text-3xl font-black tracking-tight mt-2 text-[var(--ink)]">{heading || 'كل الأصناف من مكان واحد'}</h2>
        </div>
        <Link
          to="/catalog"
          className="hidden sm:inline-flex items-center gap-1.5 text-sm font-bold text-[var(--primary)] hover:text-[var(--primary-strong)]"
        >
          عرض الكل <ArrowLeft className="h-4 w-4" />
        </Link>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
        {categories.slice(0, 12).map((cat, i) => {
          return (
            <motion.div
              key={cat.id}
              initial={{ opacity: 0, y: 16 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.4, delay: (i % 6) * 0.05 }}
            >
              <Link
                to={`/catalog?category=${cat.id}`}
                className="group block relative overflow-hidden rounded-2xl aspect-[4/5]"
              >
                {cat.image_url ? (
                  <img
                    src={cat.image_url}
                    alt={cat.name}
                    className="absolute inset-0 w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
                    loading="lazy"
                  />
                ) : (
                  <div className="absolute inset-0" style={{ background: GRADIENTS[i % GRADIENTS.length] }} />
                )}
                <div className="absolute inset-0 opacity-[0.08] pointer-events-none" style={{ backgroundImage: 'radial-gradient(circle at 30% 20%, #fff 1px, transparent 1px)', backgroundSize: '18px 18px' }} />
                <div className="absolute inset-0 bg-gradient-to-t from-black/55 via-black/10 to-transparent" />
                <div className="absolute bottom-0 left-0 right-0 p-3">
                  <h3 className="text-white font-bold text-sm leading-snug">{cat.name}</h3>
                  <p className="text-white/80 text-xs mt-0.5 tabular-nums">{cat.product_count.toLocaleString('ar-EG')} صنف</p>
                </div>
              </Link>
            </motion.div>
          )
        })}
      </div>
    </section>
  )
}