import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { productsApi, stockApi, categoriesApi, subcategoriesApi } from '../../api/endpoints'
import api from '../../api/client'
import { PageLoader, EmptyState } from '../../components/ui/Loaders'
import Modal from '../../components/ui/Modal'
import toast from 'react-hot-toast'
import { Truck, PackagePlus, ChevronDown, ChevronLeft, Plus, Minus, X, Search } from 'lucide-react'
import { clsx } from 'clsx'
import PurchasesPage from '../purchases/PurchasesPage'

type OpType = 'dispatch' | 'goods_receipt'

interface CartItem { product_id: string; name: string; unit: string; qty: number; unit_cost: number }

function ProductPicker({ onAdd }: { onAdd: (p: any) => void }) {
  const [search, setSearch] = useState('')
  const { data: products } = useQuery({
    queryKey: ['products', search],
    queryFn: () => productsApi.list(search ? { search } : {}),
    enabled: search.length > 1,
  })
  return (
    <div className="relative">
      <div className="relative">
        <Search size={14} className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400" />
        <input className="input pr-9 text-sm" placeholder="ابحث عن صنف..." value={search} onChange={e => setSearch(e.target.value)} />
      </div>
      {products && search.length > 1 && (
        <div className="absolute z-20 w-full bg-white border border-slate-200 rounded-xl shadow-xl mt-1 max-h-48 overflow-y-auto">
          {products.map((p: any) => (
            <button key={p.id} onClick={() => { onAdd(p); setSearch('') }}
              className="w-full text-right px-4 py-2.5 hover:bg-slate-50 flex justify-between text-sm border-b border-slate-50 last:border-0">
              <span className="font-medium truncate">{p.name}</span>
              <span className="text-slate-400 text-xs mr-2 flex-shrink-0">{p.unit}</span>
            </button>
          ))}
        </div>
      )}
    </div>
  )
}

function ItemsTable({ items, setItems, showCost }: { items: CartItem[]; setItems: any; showCost?: boolean }) {
  const update = (id: string, field: string, val: any) =>
    setItems((prev: CartItem[]) => prev.map(i => i.product_id === id ? { ...i, [field]: val } : i))
  return (
    <div className="border border-slate-200 rounded-xl overflow-hidden">
      <table className="w-full text-sm">
        <thead className="bg-slate-50">
          <tr>
            <th className="text-right px-3 py-2">الصنف</th>
            <th className="text-center px-3 py-2 w-28">الكمية</th>
            {showCost && <th className="text-center px-3 py-2 w-28">سعر التكلفة</th>}
            <th className="w-8"></th>
          </tr>
        </thead>
        <tbody>
          {items.map(item => (
            <tr key={item.product_id} className="border-t border-slate-100">
              <td className="px-3 py-2 font-medium">{item.name} <span className="text-slate-400 text-xs">({item.unit})</span></td>
              <td className="px-3 py-2">
                <div className="flex items-center justify-center gap-1">
                  <button onClick={() => update(item.product_id, 'qty', Math.max(1, item.qty - 1))} className="w-6 h-6 rounded bg-slate-100 hover:bg-slate-200 flex items-center justify-center"><Minus size={10} /></button>
                  <input type="number" className="w-14 text-center border border-slate-200 rounded px-1 py-0.5 text-sm" value={item.qty}
                    onChange={e => update(item.product_id, 'qty', Number(e.target.value))} />
                  <button onClick={() => update(item.product_id, 'qty', item.qty + 1)} className="w-6 h-6 rounded bg-slate-100 hover:bg-slate-200 flex items-center justify-center"><Plus size={10} /></button>
                </div>
              </td>
              {showCost && (
                <td className="px-3 py-2">
                  <input type="number" step="0.01" className="w-full text-center border border-slate-200 rounded px-2 py-0.5 text-sm" value={item.unit_cost}
                    onChange={e => update(item.product_id, 'unit_cost', Number(e.target.value))} />
                </td>
              )}
              <td className="px-3 py-2">
                <button onClick={() => setItems((p: CartItem[]) => p.filter(i => i.product_id !== item.product_id))} className="text-slate-300 hover:text-red-500"><X size={14} /></button>
              </td>
            </tr>
          ))}
          {!items.length && <tr><td colSpan={4} className="text-center py-6 text-slate-400 text-sm">أضف أصناف من البحث أعلاه</td></tr>}
        </tbody>
      </table>
    </div>
  )
}

export default function OperationsPage() {
  const [tab, setTab] = useState<'ops' | 'purchases'>('ops')
  const [activeOp, setActiveOp] = useState<OpType | null>(null)
  const [items, setItems] = useState<CartItem[]>([])
  const [fromWh, setFromWh] = useState('')
  const [toWh, setToWh] = useState('')
  const [supplier, setSupplier] = useState('')
  const [notes, setNotes] = useState('')
  const qc = useQueryClient()

  const { data: warehouses } = useQuery({ queryKey: ['warehouses'], queryFn: stockApi.warehouses })
  const { data: operations, isLoading } = useQuery({ queryKey: ['operations'], queryFn: () => api.get('/operations/').then(r => r.data) })

  const addItem = (p: any) => {
    if (items.find(i => i.product_id === p.id)) return
    setItems(prev => [...prev, { product_id: p.id, name: p.name, unit: p.unit, qty: 1, unit_cost: Number(p.cost_price) || 0 }])
  }

  const reset = () => { setItems([]); setFromWh(''); setToWh(''); setSupplier(''); setNotes('') }

  const submitMut = useMutation({
    mutationFn: async () => {
      const payload = items.map(i => ({ product_id: i.product_id, qty: i.qty, unit_cost: i.unit_cost }))
      if (activeOp === 'dispatch')
        return api.post('/operations/dispatch', { from_warehouse_id: fromWh, to_warehouse_id: toWh, items: payload, notes }).then(r => r.data)
      if (activeOp === 'goods_receipt')
        return api.post('/operations/goods-receipt', { warehouse_id: toWh, supplier_name: supplier, items: payload, notes }).then(r => r.data)
    },
    onSuccess: (data: any) => {
      toast.success(`✅ تم إنشاء المستند ${data.doc_number}`)
      setActiveOp(null); reset()
      qc.invalidateQueries({ queryKey: ['operations'] })
      qc.invalidateQueries({ queryKey: ['archive'] })
    },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })

  const opConfig = {
    dispatch:      { label: 'إذن صرف', icon: Truck,         color: '#1e3a5f', desc: 'نقل بضاعة من مخزن إلى معرض' },
    goods_receipt: { label: 'استلام مشتريات', icon: PackagePlus, color: '#16a34a', desc: 'استلام بضاعة جديدة من تاجر' },
  }

  const docTypeLabel: Record<string, string> = {
    dispatch_order: 'إذن صرف', goods_receipt: 'استلام مشتريات', stock_request: 'استلام مشتريات'
  }
  const docTypeBadge: Record<string, string> = {
    dispatch_order: 'badge-blue', goods_receipt: 'badge-green', stock_request: 'badge-green'
  }

  const showrooms = warehouses?.filter((w: any) => w.warehouse_type === 'showroom') || []
  const stores    = warehouses?.filter((w: any) => w.warehouse_type === 'warehouse') || []

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">المشتريات والعمليات</h1>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex gap-0 mb-6 border-b border-slate-200 overflow-x-auto" style={{ WebkitOverflowScrolling: 'touch' }}>
        {[
          { id: 'purchases', label: '📦 فواتير المشتريات' },
          { id: 'ops',       label: '🚚 العمليات والنقل' },
        ].map(t => (
          <button key={t.id} onClick={() => setTab(t.id as any)}
            className={`px-5 py-3 text-sm font-semibold border-b-2 transition-all -mb-px whitespace-nowrap flex-shrink-0 ${tab === t.id ? 'border-blue-600 text-blue-700' : 'border-transparent text-slate-500 hover:text-slate-700'}`}>
            {t.label}
          </button>
        ))}
      </div>

      {tab === 'purchases' && <PurchasesPage />}

      {tab === 'ops' && (
        <div>

      {/* Operation type cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8">
        {(Object.entries(opConfig) as any[]).map(([key, cfg]) => (
          <button key={key} onClick={() => { setActiveOp(key as OpType); reset() }}
            className="card text-right hover:shadow-md transition-all active:scale-95 border-2 hover:border-blue-200">
            <div className="w-12 h-12 rounded-xl flex items-center justify-center mb-3" style={{ background: cfg.color + '20' }}>
              <cfg.icon size={22} style={{ color: cfg.color }} />
            </div>
            <p className="font-bold text-slate-800 text-base">{cfg.label}</p>
            <p className="text-slate-500 text-sm mt-1">{cfg.desc}</p>
          </button>
        ))}
      </div>

      {/* Operations history */}
      <div className="card p-0 overflow-hidden">
        <div className="px-6 py-4 border-b border-slate-100">
          <h3 className="font-bold text-slate-700">سجل العمليات</h3>
        </div>
        {isLoading ? <PageLoader /> : (
          <div className="table-wrap">
            <table>
              <thead><tr><th>رقم المستند</th><th>النوع</th><th>التفاصيل</th><th>التاريخ</th></tr></thead>
              <tbody>
                {!operations?.length && <tr><td colSpan={4}><EmptyState message="لا توجد عمليات بعد" icon="📋" /></td></tr>}
                {operations?.map((op: any) => (
                  <tr key={op.id}>
                    <td>
                      <p className="font-semibold text-slate-800">{op.metadata?.supplier || op.metadata?.from || op.metadata?.to || '—'}</p>
                      <p className="text-xs text-slate-400 font-mono mt-0.5">{op.doc_number}</p>
                    </td>
                    <td><span className={docTypeBadge[op.doc_type] || 'badge-gray'}>{docTypeLabel[op.doc_type] || op.doc_type}</span></td>
                    <td className="text-sm text-slate-600">
                      {op.metadata?.from && <span>من: {op.metadata.from} </span>}
                      {op.metadata?.to && <span>إلى: {op.metadata.to} </span>}
                      {op.metadata?.supplier && <span>المورد: {op.metadata.supplier} </span>}
                      {op.metadata?.items?.length && <span>({op.metadata.items.length} صنف)</span>}
                    </td>
                    <td className="text-sm text-slate-500">{new Date(op.created_at).toLocaleString('ar-EG')}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Operation Modal */}
      {activeOp && (
        <Modal open={true} onClose={() => setActiveOp(null)} title={opConfig[activeOp].label} size="lg">
          <div className="space-y-4">
            {/* Warehouse selectors */}
            <div className="grid grid-cols-2 gap-4">
              {activeOp !== 'goods_receipt' && (
                <div>
                  <label className="block text-sm font-medium text-slate-600 mb-1">
                    {activeOp === 'dispatch' ? 'من المخزن' : 'المخزن المطلوب منه'}
                  </label>
                  <select className="input" value={fromWh} onChange={e => setFromWh(e.target.value)}>
                    <option value="">اختر...</option>
                    <optgroup label="المخازن">
                      {stores.map((w: any) => <option key={w.id} value={w.id}>{w.name}</option>)}
                    </optgroup>
                    <optgroup label="المعارض">
                      {showrooms.map((w: any) => <option key={w.id} value={w.id}>{w.name}</option>)}
                    </optgroup>
                  </select>
                </div>
              )}
              <div>
                <label className="block text-sm font-medium text-slate-600 mb-1">
                  {activeOp === 'dispatch' ? 'إلى المعرض' : 'المخزن المستلِم'}
                </label>
                <select className="input" value={toWh} onChange={e => setToWh(e.target.value)}>
                  <option value="">اختر...</option>
                  <optgroup label="المعارض">
                    {showrooms.map((w: any) => <option key={w.id} value={w.id}>{w.name}</option>)}
                  </optgroup>
                  <optgroup label="المخازن">
                    {stores.map((w: any) => <option key={w.id} value={w.id}>{w.name}</option>)}
                  </optgroup>
                </select>
              </div>
            </div>

            {activeOp === 'goods_receipt' && (
              <div>
                <label className="block text-sm font-medium text-slate-600 mb-1">اسم المورد / التاجر</label>
                <input className="input" value={supplier} onChange={e => setSupplier(e.target.value)} placeholder="اسم التاجر..." />
              </div>
            )}

            <div>
              <label className="block text-sm font-medium text-slate-600 mb-2">إضافة أصناف</label>
              <ProductPicker onAdd={addItem} />
            </div>

            <ItemsTable items={items} setItems={setItems} showCost={activeOp === 'goods_receipt'} />

            <div>
              <label className="block text-sm font-medium text-slate-600 mb-1">ملاحظات</label>
              <textarea className="input h-16 resize-none" value={notes} onChange={e => setNotes(e.target.value)} />
            </div>

            <div className="flex gap-3 justify-end pt-2">
              <button onClick={() => setActiveOp(null)} className="px-5 py-2.5 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600 hover:bg-slate-200">إلغاء</button>
              <button
                onClick={() => submitMut.mutate()}
                disabled={!items.length || submitMut.isPending || (!fromWh && activeOp !== 'goods_receipt') || !toWh}
                className="px-5 py-2.5 rounded-xl text-sm font-bold text-white disabled:opacity-50 flex items-center gap-2"
                style={{ background: opConfig[activeOp].color }}
              >
                {submitMut.isPending ? 'جاري...' : `إنشاء ${opConfig[activeOp].label}`}
              </button>
            </div>
          </div>
        </Modal>
      )}
      </div>
      )}
    </div>
  )
}
