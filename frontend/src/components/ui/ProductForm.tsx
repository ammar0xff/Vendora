import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { categoriesApi, subcategoriesApi, productsApi } from '../../api/endpoints'
import BarcodeManager from './BarcodeManager'
import toast from 'react-hot-toast'
import type { Category, Subcategory } from '../../types'

interface ProductFormProps {
  product?: any | null
  onSave: (values: Record<string, any>) => void
  onClose: () => void
}

const INITIAL = {
  name: '', unit: 'عدد', retail_price: 0, wholesale_price: 0,
  cost_price: 0, barcode: '', subcategory_id: '', company: '',
  shelf_number: '', stock_status: 'untracked',
}

function validate(form: Record<string, any>): string | null {
  if (!form.name?.trim()) return 'اسم المنتج مطلوب'
  if (!form.subcategory_id) return 'التصنيف الفرعي مطلوب'
  if (Number(form.retail_price) < 0) return 'سعر القطاعي لا يمكن أن يكون سالباً'
  if (Number(form.wholesale_price) < 0) return 'سعر الجملة لا يمكن أن يكون سالباً'
  if (Number(form.cost_price) < 0) return 'سعر التكلفة لا يمكن أن يكون سالباً'
  return null
}

export default function ProductForm({ product, onSave, onClose }: ProductFormProps) {
  const [form, setForm] = useState(product || INITIAL)
  const [categoryId, setCategoryId] = useState('')
  const [errors, setErrors] = useState<string | null>(null)
  const set = (k: string, v: any) => setForm((f: any) => ({ ...f, [k]: v }))

  const { data: categories } = useQuery<Category[]>({ queryKey: ['categories'], queryFn: categoriesApi.list })
  const { data: subcategories } = useQuery<Subcategory[]>({ queryKey: ['subcategories'], queryFn: () => subcategoriesApi.list() })

  const effectiveCategoryId = categoryId || (
    subcategories?.find(s => s.id === form.subcategory_id)?.category_id || ''
  )
  const filteredSubs = subcategories?.filter(s => s.category_id === effectiveCategoryId) || []
  const isEditing = !!product?.id
  const [uploadedImageUrl, setUploadedImageUrl] = useState<string | null>(null)

  const handleSubmit = () => {
    const err = validate(form)
    if (err) { setErrors(err); return }
    setErrors(null)
    onSave(form)
  }

  return (
    <form onSubmit={e => { e.preventDefault(); handleSubmit() }} className="space-y-4">

      {errors && (
        <div className="bg-red-50 border border-red-200 rounded-xl p-3 text-sm text-red-700 font-semibold">{errors}</div>
      )}

      <div>
        <label className="block text-sm font-medium text-slate-600 mb-1">اسم المنتج *</label>
        <input className="input" value={form.name} onChange={e => set('name', e.target.value)} required autoFocus />
      </div>

      <div className="grid grid-cols-2 gap-3">
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">التصنيف الرئيسي *</label>
          <select className="input" value={effectiveCategoryId} onChange={e => { setCategoryId(e.target.value); set('subcategory_id', '') }} required>
            <option value="">اختر التصنيف...</option>
            {categories?.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">التصنيف الفرعي *</label>
          <select className="input" value={form.subcategory_id} onChange={e => set('subcategory_id', e.target.value)} required disabled={!effectiveCategoryId}>
            <option value="">{effectiveCategoryId ? 'اختر...' : 'اختر التصنيف الرئيسي أولاً'}</option>
            {filteredSubs.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
          </select>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-3">
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">الوحدة</label>
          <select className="input" value={form.unit} onChange={e => set('unit', e.target.value)}>
            {['عدد', 'كيلو', 'متر', 'ماسورة', 'طقم', 'علبة', 'كرتونة'].map(u => <option key={u}>{u}</option>)}
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">الشركة</label>
          <input className="input" value={form.company || ''} onChange={e => set('company', e.target.value)} />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-slate-600 mb-1">الرف</label>
        <input className="input" value={form.shelf_number || ''} onChange={e => set('shelf_number', e.target.value)} placeholder="مثال: 5/1" />
      </div>

      <div className="grid grid-cols-3 gap-3">
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">سعر التكلفة</label>
          <input type="number" step="0.01" min="0" className="input" value={form.cost_price} onChange={e => set('cost_price', e.target.value)} />
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">سعر القطاعي</label>
          <input type="number" step="0.01" min="0" className="input" value={form.retail_price} onChange={e => set('retail_price', e.target.value)} />
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">سعر الجملة</label>
          <input type="number" step="0.01" min="0" className="input" value={form.wholesale_price} onChange={e => set('wholesale_price', e.target.value)} />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-slate-600 mb-1">الباركود</label>
        <input className="input" value={form.barcode || ''} onChange={e => set('barcode', e.target.value)} placeholder="اختياري" />
      </div>

      {isEditing && product?.barcodes && (
        <div className="border-t pt-4">
          <BarcodeManager productId={product.id} barcodes={product.barcodes} />
        </div>
      )}

      {isEditing && (
        <div className="border-t pt-4">
          <label className="block text-sm font-medium text-slate-600 mb-2">صورة المنتج</label>
          <div className="flex items-center gap-4">
            {(uploadedImageUrl || product?.image_url) ? (
              <img src={uploadedImageUrl || product.image_url} alt={product.name}
                className="w-20 h-20 rounded-xl object-contain border border-slate-200 bg-white" />
            ) : (
              <div className="w-20 h-20 rounded-xl bg-slate-100 border border-slate-200 flex items-center justify-center text-slate-300 text-2xl font-black">
                {product?.name?.[0] || '?'}
              </div>
            )}
            <label className="cursor-pointer px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600 hover:bg-slate-200 transition-colors">
              {product?.image_url ? 'تغيير الصورة' : 'إضافة صورة'}
              <input type="file" accept="image/*" className="hidden"
                onChange={async e => {
                  const file = e.target.files?.[0]
                  if (!file) return
                  try {
                    const r = await productsApi.uploadImage(product.id, file)
                    setUploadedImageUrl(r.image_url)
                    toast.success('تم رفع الصورة')
                  } catch { toast.error('فشل رفع الصورة') }
                }} />
            </label>
          </div>
        </div>
      )}

      <div className="flex items-center justify-between p-3 bg-slate-50 rounded-xl border border-slate-200">
        <div>
          <p className="text-sm font-medium text-slate-700">تتبع المخزون</p>
          <p className="text-xs text-slate-400">{form.stock_status === 'untracked' ? 'غير محدد — يُباع بدون خصم من الجرد' : 'محدد — يُخصم من الجرد عند البيع'}</p>
        </div>
        <button type="button"
          onClick={() => set('stock_status', form.stock_status === 'untracked' ? 'tracked' : 'untracked')}
          className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${form.stock_status === 'untracked' ? 'bg-amber-100 text-amber-700' : 'bg-green-100 text-green-700'}`}>
          {form.stock_status === 'untracked' ? '⚠️ غير محدد' : '✅ محدد'}
        </button>
      </div>

      <div className="flex gap-3 justify-end pt-2">
        <button type="button" onClick={onClose} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
        <button type="submit" className="px-5 py-2 rounded-xl text-sm font-bold text-white" style={{ background: '#1e3a5f' }}>حفظ</button>
      </div>
    </form>
  )
}
