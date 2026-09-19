import { Link } from 'react-router-dom'
import { Button } from '../../components/ui/button'
import { Package, ShoppingCart, Heart, LogIn } from 'lucide-react'
import { useQuery } from '@tanstack/react-query'
import { useStorefrontStore } from '../../store/storefront'
import { settingsApi } from '../../api/endpoints'
import { fixUploadUrl } from '../../utils/format'

interface StorefrontNavProps {
  cartCount?: number
  wishlistCount?: number
}

export default function StorefrontNav({ cartCount, wishlistCount }: StorefrontNavProps) {
  const openCart = useStorefrontStore((s) => s.openCart)
  const cart = useStorefrontStore((s) => s.cart)
  const wishlist = useStorefrontStore((s) => s.wishlist)
  const qty = cartCount ?? cart.reduce((n, i) => n + i.qty, 0)
  const wc = wishlistCount ?? wishlist.length

  const { data } = useQuery({ queryKey: ['settings'], queryFn: settingsApi.get, staleTime: 60_000, retry: false })
  const sf = (data || {}) as Record<string, unknown>
  const name = (sf.store_name as string) || 'متجر ڤندورة'
  const logo = sf.logo_url as string | undefined

  return (
    <header className="sticky top-0 z-40 bg-white/80 backdrop-blur-md border-b border-[var(--border)]">
      <div className="max-w-6xl mx-auto px-4 py-3 flex items-center justify-between gap-4">
        <Link to="/" className="flex items-center gap-2">
          <span className="w-9 h-9 rounded-xl bg-[var(--primary)] text-white flex items-center justify-center">
            {logo ? <img src={fixUploadUrl(logo)} alt={name} className="w-9 h-9 rounded-xl object-contain p-1" /> : <Package size={20} />}
          </span>
          <span className="text-lg font-black text-[var(--primary)]">{name}</span>
        </Link>
        <nav className="hidden md:flex items-center gap-1 text-sm font-semibold text-[var(--ink)]">
          <Link to="/" className="px-3 py-1.5 rounded-lg hover:bg-[var(--primary-soft)] hover:text-[var(--primary)]">الرئيسية</Link>
          <Link to="/catalog" className="px-3 py-1.5 rounded-lg hover:bg-[var(--primary-soft)] hover:text-[var(--primary)]">المنتجات</Link>
          <Link to="/about" className="px-3 py-1.5 rounded-lg hover:bg-[var(--primary-soft)] hover:text-[var(--primary)]">من نحن</Link>
        </nav>
        <div className="flex items-center gap-2">
          <Link
            to="/login"
            className="hidden sm:inline-flex items-center gap-1.5 text-sm font-bold text-[var(--muted)] hover:text-[var(--primary)] px-3 py-1.5 rounded-lg hover:bg-[var(--primary-soft)]"
          >
            <LogIn size={16} /> دخول النظام
          </Link>
          <Link to="/wishlist" className="relative w-10 h-10 rounded-xl bg-[var(--primary-soft)] text-[var(--primary)] flex items-center justify-center" aria-label="المفضلة">
            <Heart size={18} />
            {wc > 0 && (
              <span className="absolute -top-1 -left-1 min-w-5 h-5 px-1 rounded-full bg-[var(--accent)] text-white text-[10px] font-bold flex items-center justify-center">{wc}</span>
            )}
          </Link>
          <Button type="button" variant="ghost" size="icon" onClick={openCart} className="relative w-10 h-10 rounded-xl bg-[var(--primary)] text-white" aria-label="عربة التسوق">
            <ShoppingCart size={18} />
            {qty > 0 && (
              <span className="absolute -top-1 -left-1 min-w-5 h-5 px-1 rounded-full bg-[var(--accent)] text-white text-[10px] font-bold flex items-center justify-center">{qty}</span>
            )}
          </Button>
        </div>
      </div>
    </header>
  )
}