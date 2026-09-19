import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { categoriesApi, subcategoriesApi, productsApi } from '../../api/endpoints'
import BarcodeManager from './BarcodeManager'
import toast from 'react-hot-toast'
import type { Category, Subcategory } from '../../types'
import { Button } from './button'
import { Input } from './input'
import { Select } from './select'

interface ProductFormProps {
  product?: any | null
  onSave: (values: Record<string, any>) => void
  onClose: () => void
}

const INITIAL = {
  name: '', code: '', unit: 'عدد', retail_price: 0, wholesale_price: 0,
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
        <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">اسم المنتج *</label>
 <Input value={form.name} onChange={e => set('name', e.target.value)} required autoFocus/>
      </div>

      <div className="grid grid-cols-2 gap-3">
        <div>
          <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الكود (اختياري — للتمييز والبحث)</label>
 <Input className="font-mono" dir="ltr" value={form.code || ''} onChange={e => set('code', e.target.value)} placeholder="مثال: P-100"/>
        </div>
        <div>
          <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الشركة</label>
 <Input value={form.company || ''} onChange={e => set('company', e.target.value)}/>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-3">
        <div>
          <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">التصنيف الرئيسي *</label>
          <Select value={effectiveCategoryId} onChange={e => { setCategoryId(e.target.value); set('subcategory_id', '') }} required>
            <option value="">اختر التصنيف...</option>
            {categories?.map(c => <option key={c.id} value={c.id}>{c.code ? `[${c.code}] ${c.name}` : c.name}</option>)}
          </Select>
        </div>
        <div>
          <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">التصنيف الفرعي *</label>
          <Select value={form.subcategory_id} onChange={e => set('subcategory_id', e.target.value)} required disabled={!effectiveCategoryId}>
            <option value="">{effectiveCategoryId ? 'اختر...' : 'اختر التصنيف الرئيسي أولاً'}</option>
            {filteredSubs.map(s => <option key={s.id} value={s.id}>{s.code ? `[${s.code}] ${s.name}` : s.name}</option>)}
          </Select>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-3">
        <div>
          <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الوحدة</label>
          <Select value={form.unit} onChange={e => set('unit', e.target.value)}>
            {['عدد', 'كيلو', 'متر', 'ماسورة', 'طقم', 'علبة', 'كرتونة'].map(u => <option key={u}>{u}</option>)}
          </Select>
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الرف</label>
 <Input value={form.shelf_number || ''} onChange={e => set('shelf_number', e.target.value)} placeholder="مثال: 5/1"/>
      </div>

      <div className="grid grid-cols-3 gap-3">
        <div>
          <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">سعر التكلفة</label>
 <Input type="number" step="0.01" min="0" value={form.cost_price} onChange={e => set('cost_price', e.target.value)}/>
        </div>
        <div>
          <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">سعر القطاعي</label>
 <Input type="number" step="0.01" min="0" value={form.retail_price} onChange={e => set('retail_price', e.target.value)}/>
        </div>
        <div>
          <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">سعر الجملة</label>
 <Input type="number" step="0.01" min="0" value={form.wholesale_price} onChange={e => set('wholesale_price', e.target.value)}/>
        </div>
      </div>

      {!isEditing && (
        <div>
          <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الباركود (اختياري)</label>
 <Input className="font-mono" dir="ltr" value={form.barcode || ''} onChange={e => set('barcode', e.target.value)} placeholder="اختاري"/>
        </div>
      )}

      {isEditing && (
        <div className="border-t pt-4">
          <BarcodeManager productId={product.id} barcodes={product.barcodes || []} />
        </div>
      )}

      {isEditing && (
        <div className="border-t pt-4">
          <label className="block text-sm font-medium text-[var(--text-soft)] mb-2">صورة المنتج</label>
          <div className="flex items-center gap-4">
            {(uploadedImageUrl || product?.image_url) ? (
              <img src={uploadedImageUrl || product.image_url} alt={product.name}
                className="w-20 h-20 rounded-xl object-contain border border-[var(--border)] bg-[var(--surface)]" />
            ) : (
              <div className="w-20 h-20 rounded-xl bg-[var(--surface-3)] border border-[var(--border)] flex items-center justify-center text-[var(--faint)] text-2xl font-black">
                {product?.name?.[0] || '?'}
              </div>
            )}
            <label className="cursor-pointer">
              <Button variant="ghost" type="button">
                {product?.image_url ? 'تغيير الصورة' : 'إضافة صورة'}
              </Button>
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

      <div className="flex items-center justify-between p-3 bg-[var(--surface-2)] rounded-xl border border-[var(--border)]">
        <div>
          <p className="text-sm font-medium text-[var(--text)]">تتبع المخزون</p>
          <p className="text-xs text-[var(--muted)]">{form.stock_status === 'untracked' ? 'غير محدد — يُباع بدون خصم من الجرد' : 'محدد — يُخصم من الجرد عند البيع'}</p>
        </div>
        <Button type="button" variant="outline" size="sm"
          onClick={() => set('stock_status', form.stock_status === 'untracked' ? 'tracked' : 'untracked')}
          className={form.stock_status === 'untracked' ? 'text-warning border-warning bg-warning-soft' : 'text-success border-success bg-success-soft'}>
          {form.stock_status === 'untracked' ? '⚠️ غير محدد' : '✅ محدد'}
        </Button>
      </div>

      <div className="flex gap-3 justify-end pt-2">
        <Button type="button" variant="ghost" onClick={onClose}>إلغاء</Button>
        <Button type="submit">حفظ</Button>
      </div>
    </form>
  )
}
