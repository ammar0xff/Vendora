import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import api from '../../api/client'
import { productsApi } from '../../api/endpoints'
import toast from 'react-hot-toast'
import { Trash2, Package } from 'lucide-react'
import Modal from '../ui/Modal'
import { Button } from './button'
import { Input } from './input'

interface Props {
  open: boolean
  onClose: () => void
  initial?: any
}

export default function CollectionModal({ open, onClose, initial }: Props) {
  const qc = useQueryClient()
  const [name, setName] = useState(initial?.name || '')
  const [desc, setDesc] = useState(initial?.description || '')
  const [retail, setRetail] = useState(initial?.retail_price || '')
  const [wholesale, setWholesale] = useState(initial?.wholesale_price || '')
  const [items, setItems] = useState<{ product_id: string; qty: number; product_name?: string; unit?: string }[]>(
    initial?.items || []
  )
  const [search, setSearch] = useState('')

  const { data: products } = useQuery({
    queryKey: ['products-search', search],
    queryFn: () => productsApi.list({ search }),
    enabled: search.length > 1,
  })

  const saveMut = useMutation({
    mutationFn: () => {
      const payload = { name, description: desc, retail_price: Number(retail), wholesale_price: Number(wholesale), items }
      return initial ? api.put(`/collections/${initial.id}`, payload) : api.post('/collections', payload)
    },
    onSuccess: () => {
      toast.success('✅ تم الحفظ')
      qc.invalidateQueries({ queryKey: ['collections'] })
      onClose()
    },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })

  const addProduct = (p: any) => {
    if (items.find(i => i.product_id === p.id)) return
    setItems(prev => [...prev, { product_id: p.id, qty: 1, product_name: p.name, unit: p.unit }])
    setSearch('')
  }

  return (
    <Modal open={open} onClose={onClose} title={initial ? `تعديل ${initial.name}` : 'كوليكشن / باكيج جديد'}>
      <div className="space-y-3">
 <Input placeholder="اسم الكوليكشن *" value={name} onChange={e => setName(e.target.value)} autoFocus/>
 <Input placeholder="وصف (اختياري)" value={desc} onChange={e => setDesc(e.target.value)}/>
        <div className="grid grid-cols-2 gap-3">
          <div>
            <label className="block text-xs text-[var(--muted)] mb-1">سعر قطاعي</label>
 <Input type="number" placeholder="0.00" value={retail} onChange={e => setRetail(e.target.value)}/>
          </div>
          <div>
            <label className="block text-xs text-[var(--muted)] mb-1">سعر جملة</label>
 <Input type="number" placeholder="0.00" value={wholesale} onChange={e => setWholesale(e.target.value)}/>
          </div>
        </div>

        {/* Items */}
        <div>
          <label className="block text-xs font-bold text-[var(--text-soft)] mb-2">المنتجات</label>
          <div className="relative mb-2">
 <Input className="text-sm" placeholder="ابحث عن منتج..." value={search} onChange={e => setSearch(e.target.value)}/>
            {products?.length > 0 && search.length > 1 && (
              <div className="absolute top-full right-0 left-0 mt-1 bg-[var(--surface)] border border-[var(--border)] rounded-xl shadow-xl z-50 max-h-40 overflow-y-auto">
                {products.map((p: any) => (
                  <Button key={p.id} variant="ghost" type="button" onMouseDown={() => addProduct(p)}
                    className="w-full justify-between">
                    <span>{p.name}</span>
                    <span className="text-[var(--muted)] text-xs">{p.unit}</span>
                  </Button>
                ))}
              </div>
            )}
          </div>

          <div className="space-y-1 max-h-48 overflow-y-auto">
            {items.map((item, i) => (
              <div key={item.product_id} className="flex items-center gap-2 bg-[var(--surface-2)] rounded-lg px-3 py-1.5">
                <span className="flex-1 text-sm font-medium text-[var(--text)]">{item.product_name}</span>
                <span className="text-xs text-[var(--muted)]">{item.unit}</span>
 <Input type="number" className="w-16 text-center text-sm py-1" min="0.001" step="any"
                  value={item.qty}
                  onChange={e => setItems(prev => prev.map((it, idx) => idx === i ? { ...it, qty: Number(e.target.value) } : it))} />
                <Button variant="ghost" size="icon" type="button" onClick={() => setItems(prev => prev.filter((_, idx) => idx !== i))}
                  className="text-red-400 hover:text-red-600"><Trash2 size={14} /></Button>
              </div>
            ))}
            {!items.length && <p className="text-xs text-[var(--muted)] text-center py-3">أضف منتجات للكوليكشن</p>}
          </div>
        </div>

        <Button onClick={() => saveMut.mutate()} disabled={!name || !items.length || saveMut.isPending}
          className="w-full">
          <Package size={16} /> {saveMut.isPending ? 'جاري...' : 'حفظ الكوليكشن'}
        </Button>
      </div>
    </Modal>
  )
}
