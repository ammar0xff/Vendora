import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { productsApi, stockApi } from '../../api/endpoints'
import { useAppStore } from '../../store/app'
import api from '../../api/client'
import DataTable from '../../components/ui/DataTable'
import Modal from '../../components/ui/Modal'
import toast from 'react-hot-toast'
import { Plus, Search, TrendingUp, TrendingDown } from 'lucide-react'

const MOVEMENT_TYPES = [
  { value: 'adjustment_in',  label: 'تسوية إضافة +',  color: 'text-green-700' },
  { value: 'adjustment_out', label: 'تسوية خصم −',    color: 'text-red-600' },
  { value: 'opening_stock',  label: 'رصيد افتتاحي',   color: 'text-blue-600' },
  { value: 'damage',         label: 'تلف / هالك',      color: 'text-amber-600' },
  { value: 'transfer_in',    label: 'تحويل وارد',      color: 'text-purple-600' },
  { value: 'transfer_out',   label: 'تحويل صادر',      color: 'text-purple-600' },
]

function AdjustmentForm({ onClose }: { onClose: () => void }) {
  const qc = useQueryClient()
  const { activeWarehouseId } = useAppStore()
  const [search, setSearch] = useState('')
  const [selectedProduct, setSelectedProduct] = useState<any>(null)
  const [warehouseId, setWarehouseId] = useState(activeWarehouseId || '')
  const [movementType, setMovementType] = useState('adjustment_in')
  const [qty, setQty] = useState('')
  const [note, setNote] = useState('')

  const { data: warehouses } = useQuery({ queryKey: ['warehouses'], queryFn: stockApi.warehouses })
  const { data: products } = useQuery({
    queryKey: ['products', search],
    queryFn: () => productsApi.list({ search }),
    enabled: search.length > 1,
  })

  const mut = useMutation({
    mutationFn: () => api.post('/stock/movements', {
      product_id: selectedProduct.id,
      warehouse_id: warehouseId,
      movement_type: movementType,
      qty: Number(qty),
      note,
    }),
    onSuccess: () => {
      toast.success('تم تسجيل الحركة')
      qc.invalidateQueries({ queryKey: ['stock-movements'] })
      qc.invalidateQueries({ queryKey: ['balances'] })
      onClose()
    },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })

  return (
    <form onSubmit={e => { e.preventDefault(); mut.mutate() }} className="space-y-4">
      {/* Product search */}
      <div>
        <label className="block text-sm font-medium text-slate-600 mb-1">المنتج *</label>
        {selectedProduct ? (
          <div className="flex items-center justify-between p-3 bg-blue-50 border border-blue-200 rounded-xl">
            <span className="font-semibold text-blue-800">{selectedProduct.name}</span>
            <button type="button" onClick={() => { setSelectedProduct(null); setSearch('') }} className="text-xs text-blue-500 hover:underline">تغيير</button>
          </div>
        ) : (
          <div className="relative">
            <Search size={14} className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input className="input pr-9" placeholder="ابحث عن منتج..." value={search} onChange={e => setSearch(e.target.value)} />
            {products && search.length > 1 && (
              <div className="absolute z-10 top-full right-0 left-0 bg-white border border-slate-200 rounded-xl shadow-lg mt-1 max-h-44 overflow-y-auto">
                {products.map((p: any) => (
                  <button key={p.id} type="button" onClick={() => { setSelectedProduct(p); setSearch('') }}
                    className="w-full text-right px-3 py-2.5 hover:bg-slate-50 text-sm border-b border-slate-50 last:border-0">
                    <span className="font-medium">{p.name}</span>
                    <span className="text-slate-400 text-xs mr-2">{p.unit}</span>
                  </button>
                ))}
              </div>
            )}
          </div>
        )}
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">المخزن *</label>
          <select className="input" value={warehouseId} onChange={e => setWarehouseId(e.target.value)} required>
            <option value="">اختر...</option>
            {warehouses?.map((w: any) => <option key={w.id} value={w.id}>{w.name}</option>)}
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">نوع الحركة *</label>
          <select className="input" value={movementType} onChange={e => setMovementType(e.target.value)}>
            {MOVEMENT_TYPES.map(t => <option key={t.value} value={t.value}>{t.label}</option>)}
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">الكمية *</label>
          <input type="number" className="input" value={qty} onChange={e => setQty(e.target.value)} min="0.001" step="any" required />
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">ملاحظة {['adjustment_out', 'damage'].includes(movementType) ? '*' : ''}</label>
          <input className="input" value={note} onChange={e => setNote(e.target.value)} placeholder={['adjustment_out', 'damage'].includes(movementType) ? 'سبب التسوية مطلوب...' : 'اختياري'} />
        </div>
      </div>

      <div className="flex gap-3 justify-end">
        <button type="button" onClick={onClose} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
        <button type="submit" disabled={!selectedProduct || !warehouseId || !qty || mut.isPending || (['adjustment_out', 'damage'].includes(movementType) && !note.trim())}
          className="px-5 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#1e3a5f' }}>
          تسجيل الحركة
        </button>
      </div>
    </form>
  )
}

const TYPE_LABELS: Record<string, { label: string; cls: string }> = {
  adjustment_in:  { label: 'تسوية +',       cls: 'badge-green' },
  adjustment_out: { label: 'تسوية −',       cls: 'badge-red' },
  opening_stock:  { label: 'رصيد افتتاحي', cls: 'badge-blue' },
  damage:         { label: 'تلف',           cls: 'badge-yellow' },
  transfer_in:    { label: 'تحويل وارد',   cls: 'badge-blue' },
  transfer_out:   { label: 'تحويل صادر',   cls: 'badge-gray' },
  purchase:       { label: 'شراء',          cls: 'badge-green' },
  sale:           { label: 'بيع',           cls: 'badge-red' },
  return_in:      { label: 'مرتجع',         cls: 'badge-yellow' },
}

export default function StockAdjustmentsPage() {
  const [showAdd, setShowAdd] = useState(false)
  const [search, setSearch] = useState('')
  const [typeFilter, setTypeFilter] = useState('')
  const { activeWarehouseId } = useAppStore()

  const { data: movements, isLoading } = useQuery({
    queryKey: ['stock-movements', activeWarehouseId],
    queryFn: () => api.get('/stock/movements', { params: { warehouse_id: activeWarehouseId || undefined, limit: 200 } }).then(r => r.data),
  })

  const filtered = (movements || []).filter((m: any) => {
    if (typeFilter && m.movement_type !== typeFilter) return false
    if (search && !(m.product_name || '').includes(search) && !(m.note || '').includes(search)) return false
    return true
  })

  const columns = [
    { key: 'created_at', label: 'التاريخ', sortable: true, render: (r: any) => <span className="text-slate-500 text-sm">{new Date(r.created_at).toLocaleString('ar-EG')}</span> },
    { key: 'product_name', label: 'المنتج', sortable: true, render: (r: any) => <span className="font-semibold text-slate-800">{r.product_name || r.product_id}</span> },
    { key: 'warehouse_name', label: 'المخزن', render: (r: any) => <span className="text-slate-500 text-sm">{r.warehouse_name}</span> },
    {
      key: 'movement_type', label: 'النوع', render: (r: any) => {
        const t = TYPE_LABELS[r.movement_type] || { label: r.movement_type, cls: 'badge-gray' }
        return <span className={t.cls}>{t.label}</span>
      }
    },
    {
      key: 'qty', label: 'الكمية', sortable: true, render: (r: any) => {
        const isIn = ['adjustment_in', 'opening_stock', 'purchase', 'return_in', 'transfer_in'].includes(r.movement_type)
        return (
          <span className={`font-bold flex items-center gap-1 ${isIn ? 'text-green-700' : 'text-red-600'}`}>
            {isIn ? <TrendingUp size={13} /> : <TrendingDown size={13} />}
            {Number(r.qty).toLocaleString('ar-EG')}
          </span>
        )
      }
    },
    { key: 'note', label: 'ملاحظة', render: (r: any) => <span className="text-slate-400 text-sm">{r.note || '—'}</span> },
  ]

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">📋 حركات المخزون</h1>
        <button onClick={() => setShowAdd(true)} className="px-4 py-2.5 rounded-xl text-sm font-bold text-white flex items-center gap-2" style={{ background: '#1e3a5f' }}>
          <Plus size={15} /> تسوية جديدة
        </button>
      </div>

      <div className="flex gap-3 mb-4 flex-wrap">
        <input className="input max-w-xs" placeholder="بحث بالمنتج أو الملاحظة..." value={search} onChange={e => setSearch(e.target.value)} />
        <select className="input w-44" value={typeFilter} onChange={e => setTypeFilter(e.target.value)}>
          <option value="">كل الأنواع</option>
          {MOVEMENT_TYPES.map(t => <option key={t.value} value={t.value}>{t.label}</option>)}
        </select>
      </div>

      <DataTable columns={columns} data={filtered} loading={isLoading}
        rowKey={(r: any) => r.id} emptyMessage="لا توجد حركات" emptyIcon="📋" />

      <Modal open={showAdd} onClose={() => setShowAdd(false)} title="تسجيل حركة مخزون">
        <AdjustmentForm onClose={() => setShowAdd(false)} />
      </Modal>
    </div>
  )
}
