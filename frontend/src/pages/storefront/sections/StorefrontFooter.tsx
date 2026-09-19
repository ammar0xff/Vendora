import { Link } from 'react-router-dom'
import { Package } from 'lucide-react'
import { useQuery } from '@tanstack/react-query'
import { settingsApi } from '../../../api/endpoints'
import { fixUploadUrl } from '../../../utils/format'
import type { HeroVariant } from '../StorefrontHero'

export default function StorefrontFooter({ variant = 'classic' }: { variant?: HeroVariant }) {
  const { data } = useQuery({ queryKey: ['settings'], queryFn: settingsApi.get, staleTime: 60_000, retry: false })
  const sf = (data || {}) as Record<string, unknown>
  const name = (sf.store_name as string) || 'متجر ڤندورة'
  const logo = sf.logo_url as string | undefined
  const minimal = variant === 'minimal'

  if (minimal) {
    return (
      <footer className="border-t" style={{ background: 'var(--surface-2)', borderColor: 'var(--border)' }}>
        <div className="max-w-6xl mx-auto px-4 py-10 grid md:grid-cols-3 gap-8 text-center md:text-right">
          <div className="text-right">
            <div className="flex items-center gap-2 mb-3 justify-start">
              <span className="w-8 h-8 rounded-lg bg-[var(--primary-soft)] text-[var(--primary)] flex items-center justify-center">
                {logo ? <img src={fixUploadUrl(logo)} alt={name} className="w-6 h-6 object-contain" /> : <Package size={16} />}
              </span>
              <span className="font-black text-[var(--ink)]">{name}</span>
            </div>
            <p className="text-sm text-[var(--muted)] leading-relaxed">منصة الجملة والتجزئة المتكاملة — كتالوج موحّد ببيانات سعرية حقيقية من نظامك.</p>
          </div>
          <div className="text-right">
            <p className="font-bold mb-3 text-[var(--ink)]">روابط سريعة</p>
            <ul className="space-y-2 text-sm text-[var(--muted)]">
              <li><Link to="/catalog" className="hover:text-[var(--primary)]">المنتجات</Link></li>
              <li><Link to="/cart" className="hover:text-[var(--primary)]">عربة التسوق</Link></li>
              <li><Link to="/wishlist" className="hover:text-[var(--primary)]">المفضلة</Link></li>
              <li><Link to="/about" className="hover:text-[var(--primary)]">من نحن</Link></li>
            </ul>
          </div>
          <div className="text-right">
            <p className="font-bold mb-3 text-[var(--ink)]">تواصل معنا</p>
            <ul className="space-y-2 text-sm text-[var(--muted)]">
              <li>دعم فني: 24/7</li>
              <li>الجملة: خصومات خاصة</li>
              <li>الدفع عند الاستلام</li>
            </ul>
          </div>
        </div>
        <div className="border-t py-4 text-center text-xs text-[var(--muted)]" style={{ borderColor: 'var(--border)' }}>
          © 2026 {name} — جميع الحقوق محفوظة
        </div>
      </footer>
    )
  }

  return (
    <footer className="text-white" style={{ background: 'var(--primary)' }}>
      <div className="max-w-6xl mx-auto px-4 py-10 grid md:grid-cols-3 gap-8">
        <div className="text-right">
          <div className="flex items-center gap-2 mb-3 justify-start">
            <span className="w-8 h-8 rounded-lg bg-white/15 flex items-center justify-center">
              {logo ? <img src={fixUploadUrl(logo)} alt={name} className="w-6 h-6 object-contain" /> : <Package size={16} />}
            </span>
            <span className="font-black">{name}</span>
          </div>
          <p className="text-sm text-white/70 leading-relaxed">منصة الجملة والتجزئة المتكاملة — كتالوج موحّد ببيانات سعرية حقيقية من نظامك.</p>
        </div>
        <div className="text-right">
          <p className="font-bold mb-3">روابط سريعة</p>
          <ul className="space-y-2 text-sm text-white/70">
            <li><Link to="/catalog" className="hover:text-white">المنتجات</Link></li>
            <li><Link to="/cart" className="hover:text-white">عربة التسوق</Link></li>
            <li><Link to="/wishlist" className="hover:text-white">المفضلة</Link></li>
            <li><Link to="/about" className="hover:text-white">من نحن</Link></li>
          </ul>
        </div>
        <div className="text-right">
          <p className="font-bold mb-3">تواصل معنا</p>
          <ul className="space-y-2 text-sm text-white/70">
            <li>دعم فني: 24/7</li>
            <li>الجملة: خصومات خاصة</li>
            <li>الدفع عند الاستلام</li>
          </ul>
        </div>
      </div>
      <div className="border-t py-4 text-center text-xs text-white/50" style={{ borderColor: 'rgba(255,255,255,0.15)' }}>© 2026 {name} — جميع الحقوق محفوظة</div>
    </footer>
  )
}