import { motion } from 'framer-motion'
import { Link } from 'react-router-dom'
import { ArrowLeft, Star, Package, Tag } from 'lucide-react'
import { fixUploadUrl } from '../../utils/format'
import type { StorefrontProduct } from './types'

export type HeroVariant = 'classic' | 'bold' | 'minimal'

interface StorefrontHeroProps {
  products: StorefrontProduct[]
  totalProducts: number
  categoryCount: number
  variant?: HeroVariant
  title?: string
  subtitle?: string
  badge?: string
}

export default function StorefrontHero({ products, totalProducts, categoryCount, variant = 'classic', title, subtitle, badge }: StorefrontHeroProps) {
  const collage = products.slice(0, 4)
  const t = title || 'كل لوازم السباكة ومواد البناء'
  const s = subtitle || 'أصناف حقيقية بأسعار حقيقية من نظامك — باركود موحّد، بيع جملة وتجزئة، وتوصيل خلال 24 ساعة.'
  const b = badge || 'الجملة والتجزئة — توصيل سريع'

  const Stats = (
    <div className="flex items-center gap-6">
      <div className="flex -space-x-2">
        {['م', 'أ', 'س', 'ن'].map((initial, i) => (
          <div
            key={initial}
            className={`h-9 w-9 rounded-full border-2 flex items-center justify-center text-xs font-bold ${['rgba(251,113,133,.9)', 'rgba(56,189,248,.9)', 'rgba(251,191,36,.9)', 'rgba(52,211,153,.9)'][i]}`}
          >
            {initial}
          </div>
        ))}
      </div>
      <div className="text-right">
        <div className="flex items-center gap-1 justify-end">
          {[...Array(5)].map((_, i) => (
            <Star key={i} className="h-4 w-4 fill-[var(--accent)] text-[var(--accent)]" />
          ))}
          <span className="ms-1 text-sm font-bold">4.8</span>
        </div>
        <p className="text-sm text-white/60">من آلاف العملاء والتجار</p>
      </div>
    </div>
  )

  const Counters = (
    <div className="flex items-center gap-4">
      <div className="flex flex-col text-right">
        <span className="text-2xl font-black tabular-nums">{Number(totalProducts || 0).toLocaleString('ar-EG')}</span>
        <span className="text-xs" style={{ color: 'var(--muted)' }}>صنف متوفر</span>
      </div>
      <div className="h-10 w-px" style={{ background: 'var(--border)' }} />
      <div className="flex flex-col text-right">
        <span className="text-2xl font-black tabular-nums">{Number(categoryCount || 0).toLocaleString('ar-EG')}</span>
        <span className="text-xs" style={{ color: 'var(--muted)' }}>تصنيف</span>
      </div>
      <div className="h-10 w-px" style={{ background: 'var(--border)' }} />
      <div className="flex flex-col text-right">
        <span className="text-2xl font-black"><Tag className="h-5 w-5 inline text-[var(--accent)]" /></span>
        <span className="text-xs" style={{ color: 'var(--muted)' }}>أسعار جملة</span>
      </div>
    </div>
  )

  /* ------------------------------------------------ CLASSIC ------------------------------------------------ */
  if (variant === 'classic') {
    return (
      <section className="relative overflow-hidden text-white" style={{ background: 'linear-gradient(135deg, var(--primary-deep) 0%, var(--primary) 55%, #29507c 100%)' }}>
        <div className="absolute inset-0 opacity-[0.06] pointer-events-none" style={{ backgroundImage: 'radial-gradient(circle at 20% 40%, #fff 1px, transparent 1px)', backgroundSize: '26px 26px' }} />
        <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
          <div className="grid lg:grid-cols-2 gap-10 py-16 lg:py-20 items-center">
            <motion.div initial={{ opacity: 0, y: 24 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.5 }} className="relative z-10">
              <div className="inline-flex items-center gap-2 rounded-full border border-white/20 bg-white/10 px-3.5 py-1.5 text-xs font-bold mb-6">
                <span className="relative flex h-2 w-2">
                  <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[var(--accent)] opacity-75" />
                  <span className="relative inline-flex rounded-full h-2 w-2 bg-[var(--accent)]" />
                </span>
                {b}
              </div>
              {title ? (
                <h1 className="text-4xl sm:text-5xl font-black tracking-tight leading-[1.15] text-right">{t}</h1>
              ) : (
                <h1 className="text-4xl sm:text-5xl font-black tracking-tight leading-[1.15] text-right">
                  كل لوازم السباكة
                  <br />
                  <span className="text-white/70">ومواد البناء</span>
                  <br />
                  <span style={{ backgroundImage: 'linear-gradient(to left, #fff, var(--accent))', WebkitBackgroundClip: 'text', backgroundClip: 'text', color: 'transparent' }}>
                    من مكان واحد
                  </span>
                </h1>
              )}
              <p className="mt-6 text-white/80 text-lg max-w-md leading-relaxed text-right">{s}</p>
              <div className="mt-8 flex flex-wrap gap-3 justify-start">
                <Link to="/catalog" className="inline-flex items-center gap-2 px-6 py-3.5 rounded-xl font-bold transition-colors" style={{ background: 'var(--accent)', color: '#fff' }}>
                  تسوّق الآن <ArrowLeft className="h-4 w-4" />
                </Link>
                <Link to="/catalog" className="inline-flex items-center gap-2 border border-white/25 text-white px-6 py-3.5 rounded-xl font-bold hover:bg-white/10 transition-colors">
                  عروض الجملة
                </Link>
              </div>
              {stats()}
            </motion.div>

            <motion.div initial={{ opacity: 0, scale: 0.96 }} animate={{ opacity: 1, scale: 1 }} transition={{ duration: 0.6, delay: 0.15 }} className="relative hidden lg:block">
              {collageGrid(collage)}
              <div className="absolute -bottom-6 left-1/2 -translate-x-1/2 rounded-2xl shadow-2xl px-6 py-4 flex items-center gap-4" style={{ background: 'var(--surface-2)', color: 'var(--text)' }}>
                {Counters}
              </div>
            </motion.div>
          </div>
        </div>
      </section>
    )
  }

  /* --------------------------------------------------- BOLD -------------------------------------------------- */
  if (variant === 'bold') {
    return (
      <section className="relative overflow-hidden text-white" style={{ background: 'linear-gradient(140deg, #0b1f3a 0%, var(--primary-deep) 45%, var(--primary) 100%)' }}>
        <div className="absolute -top-24 -left-24 w-96 h-96 rounded-full opacity-20 pointer-events-none" style={{ background: 'var(--accent)' }} />
        <div className="absolute inset-0 opacity-[0.05] pointer-events-none" style={{ backgroundImage: 'radial-gradient(circle at 70% 30%, #fff 1px, transparent 1px)', backgroundSize: '30px 30px' }} />
        <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
          <motion.div initial={{ opacity: 0, y: 24 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.5 }} className="relative z-10 text-center py-20 lg:py-24">
            <div className="inline-flex items-center gap-2 rounded-full border border-white/20 bg-white/10 px-4 py-1.5 text-xs font-bold mb-7">
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[var(--accent)] opacity-75" />
                <span className="relative inline-flex rounded-full h-2 w-2 bg-[var(--accent)]" />
              </span>
              {b}
            </div>
            <h1 className="text-4xl sm:text-6xl lg:text-7xl font-black tracking-tight leading-[1.05]">
              {title ? t : (
                <>
                  كل لوازم السباكة
                  <br />
                  <span style={{ backgroundImage: 'linear-gradient(to left, var(--accent), #fff)', WebkitBackgroundClip: 'text', backgroundClip: 'text', color: 'transparent' }}>
                    وم واد البناء
                  </span>
                </>
              )}
            </h1>
            <p className="mt-6 text-white/80 text-lg max-w-2xl mx-auto leading-relaxed">{s}</p>
            <div className="mt-9 flex flex-wrap gap-4 justify-center">
              <Link to="/catalog" className="inline-flex items-center gap-2 px-9 py-4 rounded-2xl font-black text-lg transition-transform hover:scale-[1.03]" style={{ background: 'var(--accent)', color: '#fff' }}>
                تسوّق الآن <ArrowLeft className="h-5 w-5" />
              </Link>
              <Link to="/catalog" className="inline-flex items-center gap-2 border border-white/30 text-white px-9 py-4 rounded-2xl font-bold hover:bg-white/10 transition-colors">
                عروض الجملة
              </Link>
            </div>
          </motion.div>
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="pb-16"
          >
            <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
              {collage.map((p, _i) => (
                <Link key={p.id} to={`/products/${p.id}`} className="block">
                  <div className="rounded-2xl aspect-[4/5] overflow-hidden bg-white/10">
                    {p.image_url ? (
                      <img src={fixUploadUrl(p.image_url)} alt={p.name} loading="lazy" className="h-full w-full object-cover hover:scale-105 transition-transform duration-500" />
                    ) : (
                      <div className="h-full w-full flex items-center justify-center"><Package className="h-12 w-12 text-white/40" /></div>
                    )}
                  </div>
                </Link>
              ))}
            </div>
          </motion.div>
        </div>
      </section>
    )
  }

  /* ------------------------------------------------ MINIMAL ------------------------------------------------ */
  return (
    <section style={{ background: 'var(--bg)' }}>
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="grid lg:grid-cols-2 gap-12 py-16 lg:py-20 items-center">
          <motion.div initial={{ opacity: 0, y: 24 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.5 }}>
            <div className="inline-flex items-center gap-2 rounded-full px-3.5 py-1.5 text-xs font-bold mb-6" style={{ background: 'var(--surface-2)', color: 'var(--primary)' }}>
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[var(--accent)] opacity-75" />
                <span className="relative inline-flex rounded-full h-2 w-2 bg-[var(--accent)]" />
              </span>
              {b}
            </div>
            <h1 className="text-4xl sm:text-5xl font-black tracking-tight leading-[1.15] text-right" style={{ color: 'var(--ink)' }}>
              {title ? t : (
                <>
                  كل لوازم السباكة
                  <br />
                  <span style={{ color: 'var(--primary)' }}>ومواد البناء</span>
                </>
              )}
            </h1>
            <p className="mt-6 text-lg max-w-md leading-relaxed text-right" style={{ color: 'var(--muted)' }}>{s}</p>
            <div className="mt-8 flex flex-wrap gap-3 justify-start">
              <Link to="/catalog" className="inline-flex items-center gap-2 px-6 py-3.5 rounded-xl font-bold transition-colors" style={{ background: 'var(--primary)', color: 'var(--primary-contrast)' }}>
                تسوّق الآن <ArrowLeft className="h-4 w-4" />
              </Link>
              <Link to="/catalog" className="inline-flex items-center gap-2 px-6 py-3.5 rounded-xl font-bold" style={{ border: '1px solid var(--border)', color: 'var(--ink)' }}>
                عروض الجملة
              </Link>
            </div>
            <div className="mt-10">{Counters}</div>
          </motion.div>

          <motion.div initial={{ opacity: 0, scale: 0.97 }} animate={{ opacity: 1, scale: 1 }} transition={{ duration: 0.6, delay: 0.15 }} className="hidden lg:block">
            <div className="grid grid-cols-2 gap-4">
              {collage.slice(0, 2).map((p, i) => (
                <Link key={p.id} to={`/products/${p.id}`} className="block">
                  <div className={`rounded-3xl overflow-hidden bg-white aspect-[4/5] ${i % 2 ? 'mt-12' : ''}`} style={{ border: '1px solid var(--border)', boxShadow: '0 20px 40px -20px rgba(15,23,42,.15)' }}>
                    {p.image_url ? (
                      <img src={fixUploadUrl(p.image_url)} alt={p.name} loading="lazy" className="h-full w-full object-cover" />
                    ) : (
                      <div className="h-full w-full flex items-center justify-center"><Package className="h-12 w-12" style={{ color: 'var(--primary-soft)' }} /></div>
                    )}
                  </div>
                </Link>
              ))}
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  )

  function stats() {
    return <div className="mt-10">{Stats}</div>
  }

  function collageGrid(list: StorefrontProduct[]) {
    return (
      <div className="grid grid-cols-2 gap-4">
        {list.map((p, i) => (
          <Link key={p.id} to={`/products/${p.id}`} className="block">
            <div className={`rounded-2xl aspect-[4/5] overflow-hidden bg-white/10 ${i % 2 ? 'mt-10' : ''}`}>
              {p.image_url ? (
                <img src={fixUploadUrl(p.image_url)} alt={p.name} loading="lazy" className="h-full w-full object-cover" />
              ) : (
                <div className="h-full w-full flex items-center justify-center"><Package className="h-12 w-12 text-white/40" /></div>
              )}
            </div>
          </Link>
        ))}
      </div>
    )
  }
}