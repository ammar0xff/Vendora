import { Truck, ShieldCheck, Headset, Package } from 'lucide-react'
import type { HeroVariant } from '../StorefrontHero'

const FEATURES = [
  { icon: Truck, title: 'توصيل سريع', sub: 'خلال 24 ساعة' },
  { icon: ShieldCheck, title: 'جودة مضمونة', sub: 'ماركات أصلية' },
  { icon: Headset, title: 'دعم فني', sub: 'على مدار اليوم' },
  { icon: Package, title: 'أسعار جملة', sub: 'لأصحاب المحلات' },
]

export default function StorefrontFeatureStrip({ variant = 'classic' }: { variant?: HeroVariant }) {
  const minimal = variant === 'minimal'
  return (
    <section
      className="max-w-6xl mx-auto px-4 py-10 grid grid-cols-2 md:grid-cols-4 gap-4 mb-10"
      style={{ background: 'var(--bg)' }}
    >
      {FEATURES.map((f) => (
        <div
          key={f.title}
          className={minimal ? 'inline-flex items-center gap-3' : 'bg-white rounded-2xl border p-4 flex items-center gap-3'}
          style={minimal ? { background: 'transparent' } : { borderColor: 'var(--border)' }}
        >
          <span className={`${minimal ? '' : 'w-10 h-10'} rounded-xl bg-[var(--primary-soft)] text-[var(--primary)] flex items-center justify-center flex-shrink-0`}>
            <f.icon size={minimal ? 18 : 20} />
          </span>
          <div>
            <p className="text-sm font-bold text-[var(--ink)]">{f.title}</p>
            <p className="text-xs text-[var(--muted)]">{f.sub}</p>
          </div>
        </div>
      ))}
    </section>
  )
}