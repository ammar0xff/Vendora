import { Link, useNavigate } from 'react-router-dom'
import { Minus, Plus, Trash2, ShoppingCart, ArrowRight, PackageSearch, Phone, MessageCircle } from 'lucide-react'
import { useStorefrontStore } from '../../store/storefront'
import StorefrontNav from './StorefrontNav'
import { fixUploadUrl } from '../../utils/format'

export default function StorefrontCartPage() {
  const { cart, updateQty, removeFromCart, clearCart, wishlist } = useStorefrontStore()
  const navigate = useNavigate()
  const total = cart.reduce((sum, i) => sum + Number(i.unit_price) * i.qty, 0)

  const orderUrl = () => {
    const lines = cart.map((i) => `• ${i.name} — ${i.qty} × ${Number(i.unit_price).toLocaleString('ar-EG')} ج.م`).join('\n')
    const msg = `طلب من متجر ڤندورة:\n\n${lines}\n\nالإجمالي: ${total.toLocaleString('ar-EG')} ج.م`
    return `https://wa.me/?text=${encodeURIComponent(msg)}`
  }

  return (
    <div className="min-h-screen bg-[var(--bg)]">
      <StorefrontNav cartCount={cart.reduce((n, i) => n + i.qty, 0)} wishlistCount={wishlist.length} />

      <section className="max-w-4xl mx-auto px-4 py-10">
        <h1 className="text-2xl font-black text-[var(--ink)] mb-6">عربة التسوق</h1>

        {cart.length === 0 ? (
          <div className="bg-white rounded-2xl border border-dashed border-[var(--primary-border)] p-16 flex flex-col items-center gap-4 text-center">
            <PackageSearch size={48} className="text-[var(--muted)]" />
            <p className="font-bold text-[var(--ink)]">عربتك فارغة</p>
            <p className="text-sm text-[var(--muted)]">أضف بعض المنتجات من الكتالوج لتبدأ طلبك</p>
            <Link to="/store/catalog" className="btn btn-primary px-6 py-2.5 mt-2">تصفح الكتالوج</Link>
          </div>
        ) : (
          <div className="grid lg:grid-cols-[1fr_320px] gap-6 items-start">
            <div className="space-y-3">
              {cart.map((i) => (
                <div key={i.product_id} className="bg-white rounded-2xl border border-[var(--border)] p-4 flex items-center gap-4">
                  {i.image_url ? (
                    <img src={fixUploadUrl(i.image_url)} alt={i.name} className="w-16 h-16 rounded-xl object-cover bg-[var(--primary-soft)]" />
                  ) : (
                    <div className="w-16 h-16 rounded-xl bg-[var(--primary-soft)] flex items-center justify-center text-[var(--primary)]"><ShoppingCart size={20} /></div>
                  )}
                  <div className="flex-1 min-w-0">
                    <Link to={`/store/products/${i.product_id}`} className="text-sm font-bold text-[var(--ink)] hover:text-[var(--primary)] truncate block">{i.name}</Link>
                    <p className="text-xs text-[var(--muted)] mt-0.5">{Number(i.unit_price).toLocaleString('ar-EG')} ج.م {i.unit ? `/ ${i.unit}` : ''}</p>
                    <div className="flex items-center gap-2 mt-2">
                      <button onClick={() => updateQty(i.product_id, i.qty + 1)} className="w-8 h-8 rounded-lg bg-[var(--primary-soft)] text-[var(--primary)] flex items-center justify-center" aria-label="زيادة"><Plus size={14} /></button>
                      <span className="w-10 text-center text-sm font-black text-[var(--ink)] tabular-nums">{i.qty}</span>
                      <button onClick={() => updateQty(i.product_id, i.qty - 1)} className="w-8 h-8 rounded-lg bg-[var(--primary-soft)] text-[var(--primary)] flex items-center justify-center" aria-label="إنقاص"><Minus size={14} /></button>
                    </div>
                  </div>
                  <div className="text-left">
                    <p className="font-black text-[var(--primary)] tabular-nums">{(Number(i.unit_price) * i.qty).toLocaleString('ar-EG')} <span className="text-[10px] font-normal">ج.م</span></p>
                    <button onClick={() => removeFromCart(i.product_id)} className="mt-2 text-xs font-bold text-[var(--danger)] hover:underline flex items-center gap-1"><Trash2 size={13} /> إزالة</button>
                  </div>
                </div>
              ))}
              <button onClick={clearCart} className="text-sm font-bold text-[var(--danger)] hover:underline flex items-center gap-1"><Trash2 size={14} /> تفريغ العربة</button>
            </div>

            <div className="bg-white rounded-2xl border border-[var(--border)] p-5 sticky top-20">
              <p className="font-black text-[var(--ink)] mb-4">ملخص الطلب</p>
              <div className="flex items-center justify-between text-sm mb-2">
                <span className="text-[var(--muted)]">عدد الأصناف</span>
                <span className="font-bold text-[var(--ink)]">{cart.length}</span>
              </div>
              <div className="flex items-center justify-between text-sm mb-4">
                <span className="text-[var(--muted)]">العدد الإجمالي</span>
                <span className="font-bold text-[var(--ink)] tabular-nums">{cart.reduce((n, i) => n + i.qty, 0)}</span>
              </div>
              <div className="border-t border-[var(--border)] pt-4 flex items-center justify-between mb-5">
                <span className="font-bold text-[var(--ink)]">الإجمالي</span>
                <span className="font-black text-xl text-[var(--primary)] tabular-nums">{total.toLocaleString('ar-EG')} <span className="text-xs">ج.م</span></span>
              </div>
              <a href={orderUrl()} target="_blank" rel="noreferrer" className="btn btn-primary w-full py-3 mb-2">
                <MessageCircle size={16} /> إرسال الطلب
              </a>
              <a href="tel:+" className="btn btn-outline w-full py-3 flex items-center justify-center gap-2">
                <Phone size={16} /> اطلب هاتفياً
              </a>
              <button onClick={() => navigate('/store/catalog')} className="mt-3 w-full text-sm font-bold text-[var(--primary)] flex items-center justify-center gap-1 hover:underline">
                متابعة التسوق <ArrowRight size={14} />
              </button>
            </div>
          </div>
        )}
      </section>
    </div>
  )
}