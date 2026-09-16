import { AnimatePresence, motion } from 'framer-motion'
import { Link } from 'react-router-dom'
import { X, Minus, Plus, Trash2, ShoppingCart, ArrowLeft, PackageSearch } from 'lucide-react'
import { useStorefrontStore } from '../../store/storefront'
import { fixUploadUrl } from '../../utils/format'

export default function StorefrontCartSidebar() {
  const { isCartOpen, closeCart, cart, updateQty, removeFromCart } = useStorefrontStore()
  const total = cart.reduce((sum, i) => sum + Number(i.unit_price) * i.qty, 0)

  return (
    <AnimatePresence>
      {isCartOpen && (
        <>
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={closeCart}
            className={`fixed inset-0 z-50 ${'bg-black/45 backdrop-blur-sm'}`}
          />
          <motion.aside
            initial={false}
            animate={{ x: 0 }}
            exit={{ x: '-100%' }}
            transition={{ type: 'tween', duration: 0.25 }}
            className="fixed top-0 right-0 h-full w-full max-w-md z-50 bg-white shadow-2xl flex flex-col"
            dir="rtl"
          >
            <div className="flex items-center justify-between px-5 py-4 border-b" style={{ borderColor: 'var(--border)' }}>
              <h3 className="font-black text-[var(--ink)] flex items-center gap-2">
                <ShoppingCart size={18} className="text-[var(--primary)]" /> عربة التسوق
                <span className="text-xs font-bold text-[var(--muted)] tabular-nums">({cart.reduce((n, i) => n + i.qty, 0)})</span>
              </h3>
              <button onClick={closeCart} className="w-9 h-9 rounded-xl hover:bg-[var(--surface-2)] flex items-center justify-center text-[var(--muted)]" aria-label="إغلاق">
                <X size={20} />
              </button>
            </div>

            {cart.length === 0 ? (
              <div className="flex-1 flex flex-col items-center justify-center gap-4 px-6 text-center">
                <PackageSearch size={48} className="text-[var(--muted)]" />
                <p className="font-bold text-[var(--ink)]">عربتك فارغة</p>
                <p className="text-sm text-[var(--muted)]">أضف بعض المنتجات من الكتالوج</p>
                <button onClick={closeCart} className="btn btn-primary px-6 py-2.5 mt-2">تصفح الكتالوج</button>
              </div>
            ) : (
              <>
                <div className="flex-1 overflow-y-auto px-5 py-4 space-y-3">
                  {cart.map((i) => (
                    <div key={i.product_id} className="flex items-center gap-3">
                      {i.image_url ? (
                        <img src={fixUploadUrl(i.image_url)} alt={i.name} className="w-14 h-14 rounded-xl object-cover bg-[var(--primary-soft)]" />
                      ) : (
                        <div className="w-14 h-14 rounded-xl bg-[var(--primary-soft)] flex items-center justify-center text-[var(--primary)] flex-shrink-0"><ShoppingCart size={18} /></div>
                      )}
                      <div className="flex-1 min-w-0">
                        <Link to={`/products/${i.product_id}`} onClick={closeCart} className="text-sm font-bold text-[var(--ink)] hover:text-[var(--primary)] truncate block">{i.name}</Link>
                        <p className="text-xs text-[var(--muted)] mt-0.5 tabular-nums">{Number(i.unit_price).toLocaleString('ar-EG')} ج.م {i.unit ? `/ ${i.unit}` : ''}</p>
                        <div className="flex items-center gap-2 mt-1.5">
                          <button onClick={() => updateQty(i.product_id, i.qty + 1)} className="w-7 h-7 rounded-lg bg-[var(--primary-soft)] text-[var(--primary)] flex items-center justify-center" aria-label="زيادة"><Plus size={13} /></button>
                          <span className="w-8 text-center text-sm font-black text-[var(--ink)] tabular-nums">{i.qty}</span>
                          <button onClick={() => updateQty(i.product_id, i.qty - 1)} className="w-7 h-7 rounded-lg bg-[var(--primary-soft)] text-[var(--primary)] flex items-center justify-center" aria-label="إنقاص"><Minus size={13} /></button>
                          <button onClick={() => removeFromCart(i.product_id)} className="ms-auto w-7 h-7 rounded-lg hover:bg-red-50 text-[var(--danger)] flex items-center justify-center" aria-label="إزالة"><Trash2 size={14} /></button>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>

                <div className="border-t px-5 py-4 space-y-3" style={{ borderColor: 'var(--border)' }}>
                  <div className="flex items-center justify-between">
                    <span className="text-sm font-bold text-[var(--ink)]">الإجمالي</span>
                    <span className="font-black text-lg text-[var(--primary)] tabular-nums">{total.toLocaleString('ar-EG')} <span className="text-xs">ج.م</span></span>
                  </div>
                  <Link to="/cart" onClick={closeCart} className="btn btn-primary w-full py-3 flex items-center justify-center gap-2">
                    إتمام الطلب <ArrowLeft size={16} />
                  </Link>
                </div>
              </>
            )}
          </motion.aside>
        </>
      )}
    </AnimatePresence>
  )
}