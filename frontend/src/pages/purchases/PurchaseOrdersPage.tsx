import { useState, useMemo } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import api from '../../api/client'
import { stockApi, suppliersApi } from '../../api/endpoints'
import DataTable from '../../components/ui/DataTable'
import Modal from '../../components/ui/Modal'
import toast from 'react-hot-toast'
import { ShoppingBag, Plus, Minus, RefreshCw } from 'lucide-react'

const purchasesApi = {
  suggestions: () => api.get('/purchases/suggestions').then(r => r.data),
  create: (d: any) => api.post('/purchases', d).then(r => r.data),
}

export default function PurchaseOrdersPage() {
  const qc = useQueryClient()
  const [selected, setSelected] = useState<Record<string, { qty: number; unit_cost: number }>>({})
  const [supplierId, setSupplierId] = useState('')
  const [warehouseId, setWarehouseId] = useState('')
  const [showConfirm, setShowConfirm] = useState(false)

  const { data: suggestions, isLoading, refetch } = useQuery({ queryKey: ['po-suggestions'], queryFn: purchasesApi.suggestions })
  const { data: suppliers } = useQuery({ queryKey: ['suppliers'], queryFn: suppliersApi.list })
  const { data: warehouses } = useQuery({ queryKey: ['warehouses'], queryFn: stockApi.warehouses })

  const toggle = (row: any) => {
    setSelected(prev => {
      if (prev[row.id]) { const n = { ...prev }; delete n[row.id]; return n }
      return { ...prev, [row.id]: { qty: Number(row.reorder_qty) || Math.max(1, -Number(row.total_stock) + Number(row.reorder_point)), unit_cost: Number(row.cost_price) || 0 } }
    })
  }

  const setQty = (id: string, qty: number) => setSelected(prev => ({ ...prev, [id]: { ...prev[id], qty: Math.max(0.001, qty) } }))
  const setCost = (id: string, cost: number) => setSelected(prev => ({ ...prev, [id]: { ...prev[id], unit_cost: cost } }))

  const selectedCount = Object.keys(selected).length
  const total = Object.entries(selected).reduce((s, [, v]) => s + v.qty * v.unit_cost, 0)

  const createMut = useMutation({
    mutationFn: () => purchasesApi.create({
      supplier_id: supplierId || null,
      warehouse_id: warehouseId,
      items: Object.entries(selected).map(([product_id, v]) => ({ product_id, qty: v.qty, unit_cost: v.unit_cost })),
    }),
    onSuccess: (d) => { toast.success(`تم إنشاء ${d.po_number}`); setSelected({}); setShowConfirm(false); qc.invalidateQueries({ queryKey: ['purchases'] }) },
    onError: () => toast.error('فشل الإنشاء'),
  })

  const columns = [
    {
      key: 'select', label: '', render: (r: any) => (
        <input type="checkbox" checked={!!selected[r.id]} onChange={() => toggle(r)}
          className="w-4 h-4 rounded accent-blue-600 cursor-pointer" />
      )
    },
    { key: 'name', label: 'المنتج', render: (r: any) => <div><p className="font-bold text-slate-800">{r.name}</p><p className="text-xs text-slate-400">{r.barcode}</p></div> },
    {
      key: 'total_stock', label: 'المخزون الحالي', render: (r: any) => (
        <span className={`font-bold ${Number(r.total_stock) <= 0 ? 'text-red-600' : 'text-amber-600'}`}>
          {Number(r.total_stock).toLocaleString('ar-EG')} {r.unit}
        </span>
      )
    },
    { key: 'reorder_point', label: 'حد إعادة الطلب', render: (r: any) => <span className="text-slate-500">{Number(r.reorder_point).toLocaleString('ar-EG')} {r.unit}</span> },
    {
      key: 'qty', label: 'الكمية المقترحة', render: (r: any) => selected[r.id] ? (
        <div className="flex items-center gap-1">
          <button onClick={() => setQty(r.id, selected[r.id].qty - 1)} className="p-1 rounded hover:bg-slate-100"><Minus size={12} /></button>
          <input type="number" className="w-20 text-center border border-slate-200 rounded-lg px-2 py-1 text-sm font-bold"
            value={selected[r.id].qty} onChange={e => setQty(r.id, Number(e.target.value))} min="0.001" step="any" />
          <button onClick={() => setQty(r.id, selected[r.id].qty + 1)} className="p-1 rounded hover:bg-slate-100"><Plus size={12} /></button>
        </div>
      ) : <span className="text-slate-300 text-sm">—</span>
    },
    {
      key: 'unit_cost', label: 'سعر الشراء', render: (r: any) => selected[r.id] ? (
        <input type="number" className="w-24 border border-slate-200 rounded-lg px-2 py-1 text-sm"
          value={selected[r.id].unit_cost} onChange={e => setCost(r.id, Number(e.target.value))} min="0" step="0.01" />
      ) : <span className="text-slate-400 text-sm">{Number(r.cost_price).toLocaleString('ar-EG')} ج.م</span>
    },
  ]

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">🛒 اقتراحات الشراء</h1>
          <p className="text-slate-500 text-sm mt-1">منتجات وصلت لحد إعادة الطلب عبر جميع المخازن</p>
        </div>
        <div className="flex gap-3">
          <button onClick={() => refetch()} className="px-4 py-2.5 rounded-xl text-sm font-semibold bg-white border border-slate-200 text-slate-600 flex items-center gap-2 hover:bg-slate-50">
            <RefreshCw size={14} /> تحديث
          </button>
          {selectedCount > 0 && (
            <button onClick={() => setShowConfirm(true)}
              className="px-4 py-2.5 rounded-xl text-sm font-bold text-white flex items-center gap-2" style={{ background: '#1e3a5f' }}>
              <ShoppingBag size={15} /> إنشاء أمر شراء ({selectedCount})
            </button>
          )}
        </div>
      </div>

      {selectedCount > 0 && (
        <div className="mb-4 p-4 rounded-xl bg-blue-50 border border-blue-200 flex items-center justify-between">
          <p className="text-blue-700 font-semibold text-sm">{selectedCount} منتج محدد — إجمالي متوقع: <span className="font-black">{total.toLocaleString('ar-EG')} ج.م</span></p>
          <button onClick={() => setSelected({})} className="text-xs text-blue-500 hover:underline">إلغاء التحديد</button>
        </div>
      )}

      <DataTable columns={columns} data={suggestions || []} loading={isLoading}
        rowKey={(r: any) => r.id} emptyMessage="لا توجد منتجات تحتاج إعادة طلب 🎉" emptyIcon="✅" />

      {/* Confirm modal */}
      <Modal open={showConfirm} onClose={() => setShowConfirm(false)} title="تأكيد أمر الشراء">
        <div className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-slate-600 mb-1">المورد</label>
              <select className="input" value={supplierId} onChange={e => setSupplierId(e.target.value)}>
                <option value="">— بدون مورد —</option>
                {suppliers?.map((s: any) => <option key={s.id} value={s.id}>{s.name}</option>)}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-600 mb-1">المخزن *</label>
              <select className="input" value={warehouseId} onChange={e => setWarehouseId(e.target.value)} required>
                <option value="">اختر...</option>
                {warehouses?.map((w: any) => <option key={w.id} value={w.id}>{w.name}</option>)}
              </select>
            </div>
          </div>
          <div className="bg-slate-50 rounded-xl p-3 space-y-1.5 max-h-48 overflow-y-auto">
            {Object.entries(selected).map(([pid, v]) => {
              const prod = suggestions?.find((s: any) => s.id === pid)
              return (
                <div key={pid} className="flex justify-between text-sm">
                  <span className="text-slate-700">{prod?.name}</span>
                  <span className="font-bold text-slate-800">{v.qty} × {v.unit_cost} = {(v.qty * v.unit_cost).toLocaleString('ar-EG')} ج.م</span>
                </div>
              )
            })}
            <div className="border-t border-slate-200 pt-2 flex justify-between font-black text-slate-800">
              <span>الإجمالي</span><span>{total.toLocaleString('ar-EG')} ج.م</span>
            </div>
          </div>
          <div className="flex gap-3 justify-end">
            <button onClick={() => setShowConfirm(false)} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
            <button onClick={() => { if (!warehouseId) return toast.error('اختر المخزن أولاً'); createMut.mutate() }} disabled={createMut.isPending}
              className="px-5 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#1e3a5f' }}>
              إنشاء الأمر
            </button>
          </div>
        </div>
      </Modal>
    </div>
  )
}
