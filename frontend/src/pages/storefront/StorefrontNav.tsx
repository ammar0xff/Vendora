import { Link } from 'react-router-dom'
import { Package, ShoppingCart, Heart, LogIn } from 'lucide-react'
import { useStorefrontStore } from '../../store/storefront'

interface StorefrontNavProps {
  cartCount: number
  wishlistCount: number
}

export default function StorefrontNav({ cartCount, wishlistCount }: StorefrontNavProps) {
  const openCart = useStorefrontStore((s) => s.openCart)
  return (
    <header className="sticky top-0 z-40 bg-white/80 backdrop-blur-md border-b border-[var(--border)]">
      <div className="max-w-6xl mx-auto px-4 py-3 flex items-center justify-between gap-4">
        <Link to="/store" className="flex items-center gap-2">
          <span className="w-9 h-9 rounded-xl bg-[var(--primary)] text-white flex items-center justify-center"><Package size={20} /></span>
          <span className="text-lg font-black text-[var(--primary)]">متجر ڤندورة</span>
        </Link>
        <nav className="hidden md:flex items-center gap-1 text-sm font-semibold text-[var(--ink)]">
          <Link to="/store" className="px-3 py-1.5 rounded-lg hover:bg-[var(--primary-soft)] hover:text-[var(--primary)]">الرئيسية</Link>
          <Link to="/store/catalog" className="px-3 py-1.5 rounded-lg hover:bg-[var(--primary-soft)] hover:text-[var(--primary)]">المنتجات</Link>
          <Link to="/store/about" className="px-3 py-1.5 rounded-lg hover:bg-[var(--primary-soft)] hover:text-[var(--primary)]">من نحن</Link>
        </nav>
        <div className="flex items-center gap-2">
          <Link
            to="/login"
            className="hidden sm:inline-flex items-center gap-1.5 text-sm font-bold text-[var(--muted)] hover:text-[var(--primary)] px-3 py-1.5 rounded-lg hover:bg-[var(--primary-soft)]"
          >
            <LogIn size={16} /> دخول النظام
          </Link>
          <Link to="/store/wishlist" className="relative w-10 h-10 rounded-xl bg-[var(--primary-soft)] text-[var(--primary)] flex items-center justify-center" aria-label="المفضلة">
            <Heart size={18} />
            {wishlistCount > 0 && (
              <span className="absolute -top-1 -left-1 min-w-5 h-5 px-1 rounded-full bg-[var(--accent)] text-white text-[10px] font-bold flex items-center justify-center">{wishlistCount}</span>
            )}
          </Link>
          <button onClick={openCart} className="relative w-10 h-10 rounded-xl bg-[var(--primary)] text-white flex items-center justify-center" aria-label="عربة التسوق">
            <ShoppingCart size={18} />
            {cartCount > 0 && (
              <span className="absolute -top-1 -left-1 min-w-5 h-5 px-1 rounded-full bg-[var(--accent)] text-white text-[10px] font-bold flex items-center justify-center">{cartCount}</span>
            )}
          </button>
        </div>
      </div>
    </header>
  )
}