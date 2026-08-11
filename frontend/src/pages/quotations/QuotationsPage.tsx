import { useState, useMemo } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { salesApi, productsApi, stockApi, customersApi } from '../../api/endpoints'
import api from '../../api/client'
import Modal from '../../components/ui/Modal'
import DataTable from '../../components/ui/DataTable'
import toast from 'react-hot-toast'
import { Plus, Printer, CheckCircle, X, Minus, FileText, Search, AlertTriangle, TrendingUp, Edit2, Trash2 } from 'lucide-react'
import ConfirmDialog from '../../components/ui/ConfirmDialog'
import QuoteDestinationModal from './QuoteDestinationModal'
import { shiftsApi } from '../../api/endpoints'
import { useAuthStore } from '../../store/auth'

// ── Profit helpers ────────────────────────────────────────────────────────────
function profitColor(margin: number) {
  if (margin < 0) return 'text-red-600'
  if (margin < 10) return 'text-amber-600'
  return 'text-green-600'
}

// ── Cart item row with profit display ────────────────────────────────────────
function CartRow({ item, index, onChange, onRemove }: any) {
  const cost = Number(item.product.cost_price) || 0
  const lineTotal = item.qty * item.unit_price
  const discountAmt = item.discount_pct > 0 ? lineTotal * (item.discount_pct / 100) : (item.discount || 0)
  const netLine = lineTotal - discountAmt
  const profit = netLine - cost * item.qty
  const margin = cost > 0 ? ((netLine / item.qty - cost) / cost) * 100 : 0
  const belowCost = netLine / item.qty < cost

  return (
    <tr className={belowCost ? 'bg-red-50' : ''}>
      <td className="px-3 py-2">
        <p className="font-semibold text-slate-800 text-sm">{item.product.name}</p>
        <p className="text-xs text-slate-400">حد أدنى: <span className="font-bold text-slate-600">{cost.toLocaleString('ar-EG')} ج.م</span></p>
        {belowCost && <p className="text-xs text-red-600 font-bold flex items-center gap-1 mt-0.5"><AlertTriangle size={10} /> أقل من التكلفة!</p>}
      </td>
      <td className="px-3 py-2">
        <div className="flex items-center justify-center gap-1">
          <button type="button" onClick={() => onChange(index, 'qty', Math.max(0.001, item.qty - 1))} className="w-6 h-6 rounded bg-slate-100 hover:bg-slate-200 flex items-center justify-center"><Minus size={10} /></button>
          <input type="number" className="w-16 text-center border border-slate-200 rounded-lg px-1 py-1 text-sm font-bold" value={item.qty} min="0.001" step="any" onChange={e => { onChange(index, 'qty', Number(e.target.value)); onChange(index, 'discount_pct', 0); onChange(index, 'discount', 0) }} />
          <button type="button" onClick={() => { onChange(index, 'qty', item.qty + 1); onChange(index, 'discount_pct', 0); onChange(index, 'discount', 0) }} className="w-6 h-6 rounded bg-slate-100 hover:bg-slate-200 flex items-center justify-center"><Plus size={10} /></button>
        </div>
      </td>
      <td className="px-3 py-2">
        <input type="number" className={`w-24 text-center border rounded-lg px-2 py-1 text-sm ${belowCost ? 'border-red-300 bg-red-50' : 'border-slate-200'}`}
          value={item.unit_price} min="0" step="0.01" onChange={e => { onChange(index, 'unit_price', Number(e.target.value)); onChange(index, 'discount_pct', 0); onChange(index, 'discount', 0) }} />
        {cost > 0 && <button type="button" onClick={() => { onChange(index, 'unit_price', cost); onChange(index, 'discount_pct', 0); onChange(index, 'discount', 0) }} className="block text-xs text-blue-500 hover:underline mt-0.5 mx-auto">= التكلفة</button>}
      </td>
      <td className="px-3 py-2 text-center">
        {discountAmt > 0 && <p className="text-xs text-slate-400 line-through">{lineTotal.toLocaleString('ar-EG')}</p>}
        <p className="font-bold text-slate-800">{netLine.toLocaleString('ar-EG')}</p>
        <p className={`text-xs font-semibold ${profitColor(margin)}`}>{profit >= 0 ? '+' : ''}{profit.toLocaleString('ar-EG')} ({margin.toFixed(0)}%)</p>
      </td>
      <td className="px-3 py-2 align-middle">
        <div className="flex flex-col gap-1 items-center">
          <button type="button" onClick={() => onRemove(index)} className="text-slate-300 hover:text-red-500"><X size={14} /></button>
          <div className="flex items-center gap-1">
            <input type="number" min="0" value={item.discount_pct || ''} onChange={e => onChange(index, 'discount_pct', Number(e.target.value))}
              className="w-12 text-center text-xs border border-slate-200 rounded px-1 py-0.5 outline-none focus:border-blue-300" placeholder="%" />
            <span className="text-xs text-slate-400">%</span>
            <span className="text-xs text-slate-300">/</span>
            <input type="number" min="0" value={item.discount || ''} onChange={e => onChange(index, 'discount', Number(e.target.value))}
              className="w-14 text-center text-xs border border-slate-200 rounded px-1 py-0.5 outline-none focus:border-blue-300" placeholder="ج.م" />
          </div>
        </div>
      </td>
    </tr>
  )
}

function QuotationModal({ initial, onClose, onCreated }: { initial?: any; onClose: () => void; onCreated: (data: any) => void }) {
  const isEdit = !!initial
  const [search, setSearch] = useState('')
  const [customerName, setCustomerName] = useState(initial?.customer_name || '')
  const [selectedCustomer, setSelectedCustomer] = useState(initial?.customer_id || '')
  const [notes, setNotes] = useState(initial?.notes || '')
  const [confirmBelowCost, setConfirmBelowCost] = useState(false)
  const [invoiceDiscount, setInvoiceDiscount] = useState<number>(Number(initial?.discount_amount || 0))
  const [invoiceDiscountPct, setInvoiceDiscountPct] = useState<number>(0)
  const [cart, setCart] = useState<any[]>(
    initial?.items?.map((it: any) => ({ product: { id: it.product_id, name: it.product_name, cost_price: it.unit_cost }, qty: it.qty, unit_price: it.unit_price, discount: Number(it.discount || 0), discount_pct: 0 })) || []
  )
  // Extra financial lines (fees, discounts, shipping, etc.)
  const [extraLines, setExtraLines] = useState<{label: string; amount: number; type: 'add'|'deduct'}[]>([])

  const { data: warehouses } = useQuery({ queryKey: ['warehouses'], queryFn: stockApi.warehouses })
  const mainWh = warehouses?.[0]?.id
  const { data: customers } = useQuery({ queryKey: ['customers'], queryFn: () => customersApi.list() })
  const { data: products } = useQuery({
    queryKey: ['products', search],
    queryFn: () => productsApi.list({ search }),
    enabled: search.length > 1,
  })

  const changeItem = (i: number, key: string, val: any) =>
    setCart(prev => prev.map((it, idx) => idx === i ? { ...it, [key]: val } : it))

  const addToCart = (p: any) => {
    const existing = cart.findIndex(i => i.product.id === p.id)
    if (existing >= 0) { changeItem(existing, 'qty', cart[existing].qty + 1) }
    else setCart(prev => [...prev, { product: p, qty: 1, unit_price: Number(p.wholesale_price) || Number(p.retail_price) || 0, discount: 0, discount_pct: 0 }])
    setSearch('')
  }

  const totalRevenue = cart.reduce((s, i) => {
    const line = i.qty * i.unit_price
    const disc = i.discount_pct > 0 ? line * (i.discount_pct / 100) : (i.discount || 0)
    return s + line - disc
  }, 0)
  const totalCost = cart.reduce((s, i) => s + i.qty * (Number(i.product.cost_price) || 0), 0)
  const extraTotal = extraLines.reduce((s, l) => s + (l.type === 'add' ? l.amount : -l.amount), 0)
  const grandTotal = totalRevenue + extraTotal - invoiceDiscount
  const totalProfit = grandTotal - totalCost
  const totalMargin = totalCost > 0 ? (totalProfit / totalCost) * 100 : 0
  const hasBelowCost = cart.some(i => {
    const line = i.qty * i.unit_price
    const disc = i.discount_pct > 0 ? line * (i.discount_pct / 100) : (i.discount || 0)
    const netUnit = (line - disc) / i.qty
    return netUnit < (Number(i.product.cost_price) || 0)
  })

  const mut = useMutation({
    mutationFn: async () => {
      let customerId = selectedCustomer || null
      if (!customerId && customerName.trim()) {
        const c = await customersApi.create({ name: customerName.trim() })
        customerId = c.id
      }
      const extraNotesLines = extraLines.filter(l => l.label || l.amount > 0)
        .map(l => `${l.type === 'add' ? '+' : '-'} ${l.label}: ${l.amount.toLocaleString('ar-EG')} ج.م`).join('\n')
      const fullNotes = [notes, extraNotesLines].filter(Boolean).join('\n')
      const payload = {
        warehouse_id: mainWh,
        sale_mode: 'wholesale',
        customer_id: customerId,
        discount_amount: invoiceDiscount,
        notes: fullNotes,
        items: cart.map(i => {
          const line = i.qty * i.unit_price
          const discount = i.discount_pct > 0 ? line * (i.discount_pct / 100) : (i.discount || 0)
          return { product_id: i.product.id, qty: i.qty, unit_price: i.unit_price, unit_cost: Number(i.product.cost_price) || 0, discount }
        }),
      }
      const sale = isEdit
        ? await api.put(`/sales/${initial.id}`, payload).then(r => r.data)
        : await api.post('/sales/quotations', payload).then(r => r.data)
      return { id: sale.id }
    },
    onSuccess: onCreated,
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })

  const handleSubmit = () => {
    if (!cart.length) return toast.error('أضف منتجاً واحداً على الأقل')
    if (hasBelowCost) { setConfirmBelowCost(true); return }
    mut.mutate()
  }

  return (
    <div className="space-y-5">
      {/* Customer */}
      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">العميل</label>
          <select className="input" value={selectedCustomer} onChange={e => setSelectedCustomer(e.target.value)}>
            <option value="">اختر عميل...</option>
            {customers?.map((c: any) => <option key={c.id} value={c.id}>{c.name}</option>)}
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">أو اسم عميل جديد</label>
          <input className="input" value={customerName} onChange={e => setCustomerName(e.target.value)}
            placeholder="اسم الشركة / العميل" disabled={!!selectedCustomer} />
        </div>
      </div>

      {/* Product search */}
      <div>
        <label className="block text-sm font-medium text-slate-600 mb-1">إضافة منتجات</label>
        <div className="relative">
          <Search size={16} className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input className="input pr-9" placeholder="ابحث عن منتج..." value={search} onChange={e => setSearch(e.target.value)} />
        </div>
        {products && search.length > 1 && (
          <div className="border border-slate-200 rounded-xl mt-1 max-h-44 overflow-y-auto shadow-lg bg-white z-10 relative">
            {products.map((p: any) => (
              <button key={p.id} type="button" onClick={() => addToCart(p)}
                className="w-full text-right px-4 py-2.5 hover:bg-slate-50 flex items-center justify-between text-sm border-b border-slate-50 last:border-0">
                <span className="font-medium">{p.name}</span>
                <div className="text-left">
                  <span className="text-slate-700 font-bold">{Number(p.wholesale_price || p.retail_price).toLocaleString('ar-EG')} ج.م</span>
                  <span className="text-slate-400 text-xs mr-2">تكلفة: {Number(p.cost_price).toLocaleString('ar-EG')}</span>
                </div>
              </button>
            ))}
          </div>
        )}
      </div>

      {/* Cart table */}
      {cart.length > 0 && (
        <div className="border border-slate-200 rounded-xl overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-slate-50">
              <tr>
                <th className="text-right px-3 py-2 text-xs font-bold text-slate-500">المنتج</th>
                <th className="text-center px-3 py-2 text-xs font-bold text-slate-500">الكمية</th>
                <th className="text-center px-3 py-2 text-xs font-bold text-slate-500">السعر</th>
                <th className="text-center px-3 py-2 text-xs font-bold text-slate-500">الإجمالي / الربح</th>
                <th className="text-center px-3 py-2 text-xs font-bold text-slate-500">خصم</th>
              </tr>
            </thead>
            <tbody>
              {cart.map((item, i) => (
                <CartRow key={i} item={item} index={i} onChange={changeItem} onRemove={(idx: number) => setCart(p => p.filter((_, j) => j !== idx))} />
              ))}
            </tbody>
          </table>

          {/* Summary bar */}
          <div className="bg-slate-50 px-4 py-3 border-t border-slate-200">
            <div className="grid grid-cols-4 gap-4 mb-3">
              <div className="text-center">
                <p className="text-xs text-slate-500">إجمالي الأصناف</p>
                <p className="font-black text-slate-800">{totalRevenue.toLocaleString('ar-EG')} ج.م</p>
              </div>
              <div className="text-center">
                <p className="text-xs text-slate-500">بنود إضافية</p>
                <p className={`font-black ${extraTotal >= 0 ? 'text-green-700' : 'text-red-600'}`}>{extraTotal >= 0 ? '+' : ''}{extraTotal.toLocaleString('ar-EG')} ج.م</p>
              </div>
              <div className="text-center">
                <p className="text-xs text-slate-500">الإجمالي الكلي</p>
                <p className="font-black" style={{ color: '#1e3a5f' }}>{grandTotal.toLocaleString('ar-EG')} ج.م</p>
              </div>
              <div className="text-center">
                <p className="text-xs text-slate-500">صافي الربح</p>
                <p className={`font-black ${profitColor(totalMargin)}`}>
                  {totalProfit.toLocaleString('ar-EG')} ج.م
                  <span className="text-xs mr-1">({totalMargin.toFixed(0)}%)</span>
                </p>
              </div>
            </div>
            {/* Invoice-level discount */}
            <div className="flex items-center gap-3 pt-2 border-t border-slate-200 flex-wrap">
              <label className="text-sm font-bold text-slate-600 whitespace-nowrap">خصم على الإجمالي:</label>
              <div className="flex items-center gap-2">
                {/* Amount input */}
                <input
                  type="number" min="0" max={totalRevenue + extraTotal} step="0.01"
                  className="w-28 text-center border border-orange-300 rounded-lg px-2 py-1.5 text-sm font-bold focus:outline-none focus:border-orange-500 bg-orange-50"
                  value={invoiceDiscount || ''}
                  onChange={e => {
                    const amt = Math.max(0, Number(e.target.value))
                    setInvoiceDiscount(amt)
                    const base = totalRevenue + extraTotal
                    setInvoiceDiscountPct(base > 0 ? Math.round((amt / base) * 10000) / 100 : 0)
                  }}
                  placeholder="0.00"
                />
                <span className="text-sm text-slate-400">ج.م</span>
                <span className="text-slate-300">أو</span>
                {/* Percentage input */}
                <input
                  type="number" min="0" max="100" step="0.1"
                  className="w-20 text-center border border-orange-300 rounded-lg px-2 py-1.5 text-sm font-bold focus:outline-none focus:border-orange-500 bg-orange-50"
                  value={invoiceDiscountPct || ''}
                  onChange={e => {
                    const pct = Math.min(100, Math.max(0, Number(e.target.value)))
                    setInvoiceDiscountPct(pct)
                    const base = totalRevenue + extraTotal
                    setInvoiceDiscount(Math.round(base * pct / 100 * 100) / 100)
                  }}
                  placeholder="0"
                />
                <span className="text-sm text-slate-400">%</span>
              </div>
              <div className="mr-auto flex items-center gap-2">
                <span className="text-sm text-slate-500">الصافي بعد الخصم:</span>
                <span className="text-lg font-black" style={{ color: '#1e3a5f' }}>{grandTotal.toLocaleString('ar-EG')} ج.م</span>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Extra financial lines */}
      <div>
        <div className="flex items-center justify-between mb-2">
          <label className="text-sm font-medium text-slate-600">بنود مالية إضافية</label>
          <button type="button" onClick={() => setExtraLines(p => [...p, { label: '', amount: 0, type: 'add' }])}
            className="text-xs text-blue-600 hover:underline flex items-center gap-1"><Plus size={12} /> إضافة بند</button>
        </div>
        {extraLines.map((line, i) => (
          <div key={i} className="flex gap-2 mb-2 items-center">
            <select className="input text-sm w-24 flex-shrink-0" value={line.type} onChange={e => setExtraLines(p => p.map((l, j) => j === i ? { ...l, type: e.target.value as any } : l))}>
              <option value="add">إضافة +</option>
              <option value="deduct">خصم −</option>
            </select>
            <input className="input text-sm flex-1" placeholder="البيان (رسوم شحن، ضريبة...)" value={line.label} onChange={e => setExtraLines(p => p.map((l, j) => j === i ? { ...l, label: e.target.value } : l))} />
            <input type="number" className="input text-sm w-28" placeholder="المبلغ" value={line.amount} min="0" step="0.01" onChange={e => setExtraLines(p => p.map((l, j) => j === i ? { ...l, amount: Number(e.target.value) } : l))} />
            <button type="button" onClick={() => setExtraLines(p => p.filter((_, j) => j !== i))} className="text-slate-300 hover:text-red-500"><X size={14} /></button>
          </div>
        ))}
      </div>

      {hasBelowCost && (
        <div className="flex items-center gap-2 p-3 bg-red-50 border border-red-200 rounded-xl text-red-700 text-sm font-medium">
          <AlertTriangle size={16} /> تحذير: بعض الأصناف بسعر أقل من التكلفة
        </div>
      )}

      <div>
        <label className="block text-sm font-medium text-slate-600 mb-1">ملاحظات</label>
        <textarea className="input h-16 resize-none" value={notes} onChange={e => setNotes(e.target.value)} placeholder="شروط الدفع، مدة الصلاحية..." />
      </div>

      <div className="flex gap-3 justify-end">
        <button type="button" onClick={onClose} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
        <button type="button" onClick={handleSubmit} disabled={!cart.length || mut.isPending}
          className="px-5 py-2.5 rounded-xl font-bold text-sm text-white flex items-center gap-2 disabled:opacity-50"
          style={{ background: '#c8a84b', color: '#1e3a5f' }}>
          <FileText size={16} /> {isEdit ? 'حفظ التعديلات' : 'إنشاء وطباعة'}
        </button>
      </div>
      <ConfirmDialog open={confirmBelowCost} onClose={() => setConfirmBelowCost(false)} onConfirm={() => { setConfirmBelowCost(false); mut.mutate() }} message="⚠️ بعض الأصناف أقل من سعر التكلفة. هل تريد المتابعة؟" confirmText="متابعة" />
    </div>
  )
}

// ── Main page ─────────────────────────────────────────────────────────────────
export default function QuotationsPage() {
  const [showCreate, setShowCreate] = useState(false)
  const [editItem, setEditItem] = useState<any>(null)
  const [search, setSearch] = useState('')
  const [confirmQuote, setConfirmQuote] = useState<any>(null)
  const [destQuote, setDestQuote] = useState<any>(null)
  const [confirmDelete, setConfirmDelete] = useState<any>(null)
  const qc = useQueryClient()

  const { data: quotations, isLoading } = useQuery({
    queryKey: ['quotations'],
    queryFn: () => salesApi.list({ status: 'quotation', limit: 100 }),
  })

  const destWarehouseId = destQuote?.warehouse_id

  const { data: currentShift } = useQuery({
    queryKey: ['current-shift', destWarehouseId],
    queryFn: () => shiftsApi.current(destWarehouseId!),
    enabled: !!destWarehouseId,
    retry: false,
    throwOnError: false,
  })

  const { data: safes, isLoading: loadingSafes } = useQuery({
    queryKey: ['safes'],
    queryFn: () => api.get('/safes').then(r => r.data),
    enabled: !!destQuote,
  })

  const confirmMut = useMutation({
    mutationFn: (payload: { id: string; destination?: string; safe_id?: string }) =>
      api.post(`/sales/${payload.id}/confirm-quotation`, { destination: payload.destination || 'drawer', safe_id: payload.safe_id }).then(r => r.data),
    onSuccess: (data) => {
      toast.success(`✅ تم تحويل عرض السعر إلى فاتورة ${data.invoice_number}`)
      qc.invalidateQueries({ queryKey: ['quotations'] })
      qc.invalidateQueries({ queryKey: ['sales'] })
      qc.invalidateQueries({ queryKey: ['safes'] })
      qc.invalidateQueries({ queryKey: ['shifts'] })
    },
    onError: (e: any) => {
      const detail = e.response?.data?.detail || 'فشل'
      toast.error(detail.includes('Insufficient') ? '⚠️ كمية غير كافية في المخزن' : detail, { duration: 4000 })
    },
  })

  const deleteMut = useMutation({
    mutationFn: (id: string) => api.delete(`/sales/${id}`),
    onSuccess: () => {
      toast.success('✅ تم حذف عرض السعر')
      qc.invalidateQueries({ queryKey: ['quotations'] })
    },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل الحذف'),
  })

  const precheckAndConfirm = async (id: string) => {
    try {
      const detail = await api.get(`/sales/${id}`).then(r => r.data)
      const warehouseId = detail.warehouse_id
      if (!warehouseId) {
        toast.error('لا يوجد مخزن محدد لهذا العرض')
        return
      }
      const items = detail.items || []
      const productIds = Array.from(new Set(items.map((it: any) => it.product_id)))
      if (productIds.length === 0) {
        toast.error('لا توجد أصناف في العرض')
        return
      }
      const balances = await stockApi.balanceBulk(warehouseId, productIds)
      const trackedMap = (balances as any).__tracked__ || {}
      const insufficient = items.find((it: any) => {
        const bal = Number(balances?.[it.product_id] ?? 0)
        return trackedMap[it.product_id] !== false && bal < Number(it.qty)
      })
      if (insufficient) {
        toast.error(`⚠️ كمية غير كافية: ${insufficient.product_name || insufficient.name || 'صنف'} — متاح ${Number(balances?.[insufficient.product_id] ?? 0)}`)
        return
      }
      setDestQuote(detail)
    } catch (e: any) {
      toast.error(e.response?.data?.detail || 'فشل فحص المخزون')
    }
  }

  const handlePrint = (id: string) => {
    const token = useAuthStore.getState().token
    const url = `/api/print/sale/${id}?token=${encodeURIComponent(token || '')}`
    const win = window.open(url, '_blank')
    if (!win) window.location.href = url
  }

  const handleEdit = async (q: any) => {
    try {
      const detail = await api.get(`/sales/${q.id}`).then(r => r.data)
      setEditItem(detail)
    } catch { toast.error('فشل في تحميل بيانات عرض السعر') }
  }

  const filtered = useMemo(() =>
    (quotations || []).filter((q: any) => !search || q.invoice_number.includes(search) || (q.customer_name || '').includes(search)),
    [quotations, search])


  const columns = [
    {
      key: 'invoice', label: 'رقم العرض', render: (r: any) => (
        <div>
          <p className="font-bold text-slate-800">{r.invoice_number}</p>
          <p className="text-xs text-slate-400">{new Date(r.created_at).toLocaleDateString('ar-EG')}</p>
        </div>
      )
    },
    { key: 'customer', label: 'العميل', render: (r: any) => <span className="text-slate-600">{r.customer_name || 'عميل عادي'}</span> },
    {
      key: 'total', label: 'الإجمالي', render: (r: any) => (
        <span className="font-bold text-slate-800">{Number(r.net_total || r.total || 0).toLocaleString('ar-EG')} ج.م</span>
      )
    },
    { key: 'status', label: 'الحالة', render: () => <span className="badge-yellow">عرض سعر</span> },
    {
      key: 'actions', label: '', render: (r: any) => (
        <div className="flex gap-1.5 justify-end">
          <button onClick={() => handlePrint(r.id)} className="p-1.5 rounded-lg hover:bg-blue-50 text-slate-400 hover:text-blue-600" title="طباعة"><Printer size={14} /></button>
          <button onClick={() => handleEdit(r)} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400" title="تعديل"><Edit2 size={14} /></button>
          <button onClick={() => setConfirmDelete(r.id)}
            className="p-1.5 rounded-lg hover:bg-red-50 text-slate-400 hover:text-red-600" title="حذف">
            <Trash2 size={14} />
          </button>
          <button onClick={() => setConfirmQuote(r.id)}
            className="px-3 py-1.5 rounded-lg text-xs font-bold text-white flex items-center gap-1" style={{ background: '#16a34a' }}>
            <CheckCircle size={12} /> تأكيد
          </button>
        </div>
      )
    },
  ]

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">📋 عروض الأسعار</h1>
          <p className="text-slate-500 text-sm mt-1">إنشاء عروض أسعار مع تتبع الربحية</p>
        </div>
        <button onClick={() => setShowCreate(true)} className="px-5 py-2.5 rounded-xl font-bold text-sm text-white flex items-center gap-2" style={{ background: '#1e3a5f' }}>
          <Plus size={16} /> عرض سعر جديد
        </button>
      </div>

      <div className="mb-4">
        <input className="input max-w-xs" placeholder="بحث برقم العرض أو العميل..." value={search} onChange={e => setSearch(e.target.value)} />
      </div>

      <DataTable columns={columns} data={filtered} loading={isLoading}
        rowKey={(r: any) => r.id} emptyMessage="لا توجد عروض أسعار" emptyIcon="📋" />

      <Modal open={showCreate} onClose={() => setShowCreate(false)} title="إنشاء عرض سعر جديد" size="xl">
        <QuotationModal onClose={() => setShowCreate(false)} onCreated={(data) => {
          setShowCreate(false)
          qc.invalidateQueries({ queryKey: ['quotations'] })
          if (data?.id) {
            const token = useAuthStore.getState().token
            const url = `/api/print/sale/${data.id}?token=${encodeURIComponent(token || '')}`
            const win = window.open(url, '_blank')
            if (!win) window.location.href = url
          }
        }} />
      </Modal>

      <Modal open={!!editItem} onClose={() => setEditItem(null)} title="تعديل عرض السعر" size="xl">
        {editItem && <QuotationModal initial={editItem} onClose={() => setEditItem(null)} onCreated={(data) => {
          setEditItem(null)
          qc.invalidateQueries({ queryKey: ['quotations'] })
          if (data?.id) {
            const token = useAuthStore.getState().token
            const url = `/api/print/sale/${data.id}?token=${encodeURIComponent(token || '')}`
            const win = window.open(url, '_blank')
            if (!win) window.location.href = url
          }
        }} />}
      </Modal>
      <ConfirmDialog
        open={!!confirmQuote}
        onClose={() => setConfirmQuote(null)}
        onConfirm={() => { if (confirmQuote) precheckAndConfirm(confirmQuote); setConfirmQuote(null) }}
        message="تحويل إلى فاتورة مؤكدة؟ سيتم خصم الكميات."
        confirmText="تحويل"
      />
      <QuoteDestinationModal
        quote={destQuote}
        show={!!destQuote}
        onClose={() => setDestQuote(null)}
        currentShift={currentShift}
        safes={safes}
        loadingSafes={loadingSafes}
        isPending={confirmMut.isPending}
        onConfirm={(destination, safeId) => {
          if (destQuote?.id) confirmMut.mutate({ id: destQuote.id, destination, safe_id: destination === 'safe' ? safeId : undefined })
          setDestQuote(null)
        }}
      />
      <ConfirmDialog
        open={!!confirmDelete}
        onClose={() => setConfirmDelete(null)}
        onConfirm={() => { if (confirmDelete) { deleteMut.mutate(confirmDelete); setConfirmDelete(null) } }}
        message="حذف عرض السعر؟"
        confirmText="حذف"
        variant="danger"
      />
    </div>
  )
}
