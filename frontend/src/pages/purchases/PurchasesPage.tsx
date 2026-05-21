import { useState, useMemo } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import api from '../../api/client'
import { productsApi, stockApi } from '../../api/endpoints'
import { useAppStore } from '../../store/app'
import DataTable from '../../components/ui/DataTable'
import Modal from '../../components/ui/Modal'
import ProductForm from '../../components/ui/ProductForm'
import toast from 'react-hot-toast'
import { Plus, Trash2, Eye, CheckCircle, Package, Printer } from 'lucide-react'
import ExportButton from '../../components/ui/ExportButton'
import { openPrint } from '../../utils/format'

const purchasesApi = {
  list: () => api.get('/purchases').then(r => r.data),
  get: (id: string) => api.get(`/purchases/${id}`).then(r => r.data),
  create: (d: any) => api.post('/purchases', d).then(r => r.data),
  receive: (id: string, d: any) => api.post(`/purchases/${id}/receive`, d).then(r => r.data),
  priceHistory: (pid: string) => api.get(`/purchases/price-history/${pid}`).then(r => r.data),
}

const suppliersApi = { list: () => api.get('/suppliers').then(r => r.data) }

const STATUS_LABEL: Record<string, string> = { draft: 'مسودة', received: 'مستلم', cancelled: 'ملغي' }
const STATUS_CLASS: Record<string, string> = { draft: 'badge-yellow', received: 'badge-green', cancelled: 'badge-red' }

// ── New PO form ──────────────────────────────────────────────────────────────
function NewPOForm({ onClose }: { onClose: () => void }) {
  const qc = useQueryClient()
  const { activeWarehouseId } = useAppStore()
  const [supplierId, setSupplierId] = useState('')
  const [warehouseId, setWarehouseId] = useState(activeWarehouseId || '')
  const [notes, setNotes] = useState('')
  const [amountPaid, setAmountPaid] = useState('')
  const [receivedByName, setReceivedByName] = useState('')
  const [items, setItems] = useState<any[]>([{ product_id: '', product_name: '', qty: 1, unit_cost: 0 }])
  const [productSearch, setProductSearch] = useState<Record<number, string>>({})
  const [newProductIdx, setNewProductIdx] = useState<number | null>(null)
  const [newProduct, setNewProduct] = useState({ name: '', unit: 'عدد', cost_price: 0, retail_price: 0 })
  const [dropdownPos, setDropdownPos] = useState<{top:number;left:number;width:number;idx:number}|null>(null)

  const { data: suppliers } = useQuery({ queryKey: ['suppliers'], queryFn: suppliersApi.list })
  const { data: warehouses } = useQuery({ queryKey: ['warehouses'], queryFn: stockApi.warehouses })
  const { data: products } = useQuery({ queryKey: ['products-all'], queryFn: () => productsApi.list({}) })

  const createMut = useMutation({
    mutationFn: purchasesApi.create,
    onSuccess: () => { toast.success('تم إنشاء أمر الشراء'); qc.invalidateQueries({ queryKey: ['purchases'] }); onClose() },
    onError: () => toast.error('فشل الإنشاء'),
  })

  const setItem = (i: number, k: string, v: any) => setItems(prev => prev.map((it, idx) => idx === i ? { ...it, [k]: v } : it))

  const selectProduct = (i: number, product: any) => {
    setDropdownPos(null)
    setItem(i, 'product_id', product.id)
    setItem(i, 'product_name', product.name)
    setItem(i, 'unit_cost', product.cost_price || 0)
    setProductSearch(prev => ({ ...prev, [i]: product.name }))
  }

  const filteredProducts = (search: string) =>
    (products || []).filter((p: any) => p.name.includes(search) || (p.barcode || '').includes(search)).slice(0, 8)

  const total = items.reduce((s, it) => s + (Number(it.qty) * Number(it.unit_cost)), 0)

  const submit = (e: React.FormEvent) => {
    e.preventDefault()
    // Check if any row has text typed but no product selected
    const unselected = items.filter((it, i) => productSearch[i] && !it.product_id)
    if (unselected.length) return toast.error('يوجد صنف غير محدد — اختر من القائمة أو أضف منتجاً جديداً')
    const validItems = items.filter(it => it.product_id && it.qty > 0)
    if (!validItems.length) return toast.error('أضف منتجاً واحداً على الأقل')
    if (!warehouseId) return toast.error('اختر المخزن')
    createMut.mutate({ supplier_id: supplierId || null, warehouse_id: warehouseId, notes,
                       amount_paid: Number(amountPaid) || 0, received_by_name: receivedByName,
                       items: validItems })
  }

  return (
    <form onSubmit={submit} className="space-y-5">
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

      {/* Items */}
      <div>
        <div className="flex items-center justify-between mb-2">
          <label className="text-sm font-medium text-slate-600">الأصناف</label>
          <button type="button" onClick={() => setItems(p => [...p, { product_id: '', product_name: '', qty: 1, unit_cost: 0 }])}
            className="text-xs text-blue-600 hover:underline flex items-center gap-1"><Plus size={12} /> إضافة صنف</button>
        </div>
        <div className="space-y-2 max-h-72 overflow-y-auto overflow-x-visible">
          {/* Column headers */}
          <div className="grid grid-cols-12 gap-2 px-0.5">
            <div className="col-span-5 text-xs font-bold text-slate-400">الصنف</div>
            <div className="col-span-2 text-xs font-bold text-slate-400 text-center">الكمية</div>
            <div className="col-span-3 text-xs font-bold text-slate-400 text-center">سعر الشراء</div>
            <div className="col-span-1 text-xs font-bold text-slate-400 text-left">الإجمالي</div>
          </div>
          {items.map((item, i) => (
            <div key={i} className="grid grid-cols-12 gap-2 items-start">
              {/* Product search */}
              <div className="col-span-5" style={{ position: 'relative' }}>
                <input className={"input text-sm " + (productSearch[i] && !item.product_id ? 'border-red-400 bg-red-50' : '')} placeholder="ابحث عن منتج..."
                  value={productSearch[i] ?? item.product_name}
                  onChange={e => { setProductSearch(p => ({ ...p, [i]: e.target.value })); setItem(i, 'product_id', '') }}
                  onFocus={e => {
                    const rect = e.currentTarget.getBoundingClientRect()
                    setDropdownPos({ top: rect.bottom + window.scrollY + 4, left: rect.left, width: rect.width, idx: i })
                  }}
                  onBlur={() => setTimeout(() => setDropdownPos(null), 200)}
                />
                {dropdownPos?.idx === i && productSearch[i] && !item.product_id && (
                  <div style={{ position: 'fixed', top: dropdownPos.top, left: dropdownPos.left, width: dropdownPos.width, zIndex: 99999 }}
                    className="bg-white border border-slate-200 rounded-xl shadow-xl max-h-52 overflow-y-auto">
                    {filteredProducts(productSearch[i]).map((p: any) => (
                      <button key={p.id} type="button" onClick={() => selectProduct(i, p)}
                        className="w-full text-right px-3 py-2.5 hover:bg-blue-50 text-sm border-b border-slate-100 last:border-0 flex items-center justify-between">
                        <div>
                          <span className="font-semibold text-slate-800">{p.name}</span>
                          {p.barcode && <span className="text-slate-400 text-xs mr-2 font-mono">{p.barcode}</span>}
                        </div>
                        <span className="text-slate-500 text-xs flex-shrink-0 mr-2">{p.cost_price} ج.م</span>
                      </button>
                    ))}
                    {/* Always show add-new at bottom */}
                    <button key="add-new" type="button"
                      onClick={() => { setNewProductIdx(i); setNewProduct({ name: productSearch[i], unit: 'عدد', cost_price: Number(item.unit_cost) || 0, retail_price: 0 }) }}
                      className="w-full text-right px-3 py-2.5 hover:bg-green-50 text-sm border-t border-slate-100 flex items-center gap-2"
                      style={{ color: '#16a34a', fontWeight: 700 }}>
                      <Plus size={13} />
                      {filteredProducts(productSearch[i]).length
                        ? `إضافة "${productSearch[i]}" كمنتج جديد`
                        : `لا نتائج — إضافة "${productSearch[i]}" كمنتج جديد`}
                    </button>
                  </div>
                )}
              </div>
              <div className="col-span-2">
                <input type="number" className="input text-sm" placeholder="الكمية" min="0.001" step="any"
                  value={item.qty} onChange={e => setItem(i, 'qty', e.target.value)} />
              </div>
              <div className="col-span-3">
                <input type="number" className="input text-sm" placeholder="سعر الشراء" min="0" step="0.01"
                  value={item.unit_cost} onChange={e => setItem(i, 'unit_cost', e.target.value)} />
              </div>
              <div className="col-span-1 flex items-center justify-center pt-2">
                <span className="text-xs text-slate-500">{(Number(item.qty) * Number(item.unit_cost)).toLocaleString('ar-EG')}</span>
              </div>
              <div className="col-span-1 flex items-center justify-center pt-1">
                <button type="button" onClick={() => setItems(p => p.filter((_, idx) => idx !== i))}
                  className="p-1 rounded hover:bg-red-50 text-slate-300 hover:text-red-500"><Trash2 size={13} /></button>
              </div>
            </div>
          ))}
        </div>
        <div className="flex justify-end mt-3 pt-3 border-t border-slate-100">
          <span className="font-bold text-slate-700">الإجمالي: <span style={{ color: '#1e3a5f' }}>{total.toLocaleString('ar-EG')} ج.م</span></span>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">المبلغ المدفوع</label>
          <input type="number" className="input" value={amountPaid} onChange={e => setAmountPaid(e.target.value)} min="0" step="0.01" placeholder="0.00" />
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">استلم البضاعة</label>
          <input className="input" value={receivedByName} onChange={e => setReceivedByName(e.target.value)} placeholder="اسم المستلم" />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-slate-600 mb-1">ملاحظات</label>
        <textarea className="input" rows={2} value={notes} onChange={e => setNotes(e.target.value)} />
      </div>

      <div className="flex gap-3 justify-end">
        <button type="button" onClick={onClose} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
        <button type="submit" disabled={createMut.isPending} className="px-5 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#1e3a5f' }}>
          إنشاء أمر الشراء
        </button>
      </div>

      {/* Full product form modal */}
      <Modal open={newProductIdx !== null} onClose={() => setNewProductIdx(null)} title="إضافة منتج جديد" size="lg">
        <ProductForm
          product={{ name: newProduct.name, cost_price: newProduct.cost_price, retail_price: newProduct.cost_price }}
          onClose={() => setNewProductIdx(null)}
          onSave={async (data: any) => {
            const p = await productsApi.create(data)
            selectProduct(newProductIdx!, p)
            setItem(newProductIdx!, 'unit_cost', p.cost_price)
            qc.invalidateQueries({ queryKey: ['products-all'] })
            setNewProductIdx(null)
            toast.success('تم إضافة المنتج')
          }}
        />
      </Modal>
    </form>
  )
}

// ── Receive PO modal ─────────────────────────────────────────────────────────
function ReceivePOModal({ poId, onClose }: { poId: string; onClose: () => void }) {
  const qc = useQueryClient()
  const { data: po, isLoading } = useQuery({ queryKey: ['po', poId], queryFn: () => purchasesApi.get(poId) })
  const [overrides, setOverrides] = useState<Record<string, { qty_received: number; unit_cost: number }>>({})

  const getVal = (pid: string, key: 'qty_received' | 'unit_cost', fallback: number) =>
    overrides[pid]?.[key] ?? fallback

  const setVal = (pid: string, key: 'qty_received' | 'unit_cost', val: number) =>
    setOverrides(prev => ({ ...prev, [pid]: { ...prev[pid], [key]: val } }))

  const receiveMut = useMutation({
    mutationFn: () => purchasesApi.receive(poId, {
      items: po.items.map((it: any) => ({
        product_id: it.product_id,
        qty_received: getVal(it.product_id, 'qty_received', it.qty_ordered),
        unit_cost: getVal(it.product_id, 'unit_cost', it.unit_cost),
      }))
    }),
    onSuccess: () => { toast.success('تم الاستلام وتحديث أسعار التكلفة'); qc.invalidateQueries({ queryKey: ['purchases'] }); onClose() },
    onError: () => toast.error('فشل الاستلام'),
  })

  if (isLoading) return <p className="text-center py-8 text-slate-400">جاري التحميل...</p>

  const total = po?.items?.reduce((s: number, it: any) =>
    s + getVal(it.product_id, 'qty_received', it.qty_ordered) * getVal(it.product_id, 'unit_cost', it.unit_cost), 0) || 0

  return (
    <div className="space-y-4">
      <div className="bg-blue-50 rounded-xl p-3 text-sm text-blue-700 font-medium">
        ⚠️ عند الاستلام سيتم تحديث سعر التكلفة لكل منتج تلقائياً وحفظ السجل التاريخي
      </div>
      <div className="space-y-2 max-h-72 overflow-y-auto">
        <div className="grid grid-cols-12 gap-2 text-xs font-bold text-slate-500 px-1 mb-1">
          <div className="col-span-5">المنتج</div>
          <div className="col-span-2">الكمية المستلمة</div>
          <div className="col-span-3">سعر الشراء الفعلي</div>
          <div className="col-span-2 text-left">الإجمالي</div>
        </div>
        {po?.items?.map((it: any) => (
          <div key={it.product_id} className="grid grid-cols-12 gap-2 items-center bg-slate-50 rounded-xl p-2">
            <div className="col-span-5">
              <p className="font-semibold text-slate-800 text-sm">{it.product_name}</p>
              {it.current_cost !== it.unit_cost && (
                <p className="text-xs text-amber-600">تكلفة حالية: {it.current_cost} ج.م</p>
              )}
            </div>
            <div className="col-span-2">
              <input type="number" className="input text-sm py-1.5" min="0" step="any"
                value={getVal(it.product_id, 'qty_received', it.qty_ordered)}
                onChange={e => setVal(it.product_id, 'qty_received', Number(e.target.value))} />
            </div>
            <div className="col-span-3">
              <input type="number" className="input text-sm py-1.5" min="0" step="0.01"
                value={getVal(it.product_id, 'unit_cost', it.unit_cost)}
                onChange={e => setVal(it.product_id, 'unit_cost', Number(e.target.value))} />
            </div>
            <div className="col-span-2 text-left text-sm font-bold text-slate-700">
              {(getVal(it.product_id, 'qty_received', it.qty_ordered) * getVal(it.product_id, 'unit_cost', it.unit_cost)).toLocaleString('ar-EG')}
            </div>
          </div>
        ))}
      </div>
      <div className="flex items-center justify-between pt-3 border-t border-slate-100">
        <div className="space-y-1">
          <div className="flex gap-4 text-sm">
            <span className="text-slate-500">الإجمالي: <span className="font-black" style={{ color: '#1e3a5f' }}>{total.toLocaleString('ar-EG')} ج.م</span></span>
            {po?.amount_paid > 0 && <span className="text-green-600">مدفوع: <span className="font-black">{Number(po.amount_paid).toLocaleString('ar-EG')} ج.م</span></span>}
            {po?.amount_paid > 0 && total - Number(po.amount_paid) > 0 && (
              <span className="text-amber-600">متبقي: <span className="font-black">{(total - Number(po.amount_paid)).toLocaleString('ar-EG')} ج.م</span></span>
            )}
          </div>
          {po?.received_by_name && <p className="text-xs text-slate-400">المستلم: {po.received_by_name}</p>}
        </div>
        <div className="flex gap-3">
          <button onClick={onClose} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
          <button onClick={() => receiveMut.mutate()} disabled={receiveMut.isPending}
            className="px-5 py-2 rounded-xl text-sm font-bold text-white flex items-center gap-2 disabled:opacity-50" style={{ background: '#16a34a' }}>
            <CheckCircle size={15} /> تأكيد الاستلام
          </button>
        </div>
      </div>
    </div>
  )
}

// ── Main page ────────────────────────────────────────────────────────────────
export default function PurchasesPage() {
  const [showNew, setShowNew] = useState(false)
  const [receivePO, setReceivePO] = useState<string | null>(null)
  const [search, setSearch] = useState('')
  const [printingId, setPrintingId] = useState<string | null>(null)
  const qc = useQueryClient()

  const { data: purchases, isLoading } = useQuery({ queryKey: ['purchases'], queryFn: purchasesApi.list })

  const filtered = useMemo(() =>
    (purchases || []).filter((p: any) =>
      p.po_number.includes(search) || (p.supplier_name || '').includes(search) || (p.warehouse_name || '').includes(search)
    ), [purchases, search])

  const columns = [
    { key: 'po_number', label: 'رقم الأمر', render: (r: any) => <span className="font-mono font-bold text-slate-800">{r.po_number}</span> },
    { key: 'supplier_name', label: 'المورد', render: (r: any) => <span className="text-slate-600">{r.supplier_name || '—'}</span> },
    { key: 'warehouse_name', label: 'المخزن', render: (r: any) => <span className="text-slate-600">{r.warehouse_name}</span> },
    { key: 'status', label: 'الحالة', render: (r: any) => <span className={STATUS_CLASS[r.status]}>{STATUS_LABEL[r.status]}</span> },
    { key: 'amount_paid', label: 'مدفوع / متبقي', render: (r: any) => r.amount_paid > 0 ? (
      <div className="text-xs">
        <span className="text-green-600 font-bold">{Number(r.amount_paid).toLocaleString('ar-EG')} ج.م</span>
        {r.total_cost > r.amount_paid && <span className="text-amber-600 mr-1">/ {(r.total_cost - r.amount_paid).toLocaleString('ar-EG')} متبقي</span>}
      </div>
    ) : <span className="text-slate-300">—</span> },
    { key: 'created_at', label: 'التاريخ', render: (r: any) => <span className="text-slate-400 text-sm">{new Date(r.created_at).toLocaleDateString('ar-EG')}</span> },
    {
      key: 'actions', label: '', render: (r: any) => (
        <div className="flex gap-1 justify-end items-center">
          {/* Invoice image upload */}
          <label className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-300 hover:text-slate-600 cursor-pointer" title="رفع صورة الفاتورة">
            📎
            <input type="file" accept="image/*" className="hidden" onChange={async e => {
              const file = e.target.files?.[0]; if (!file) return
              if (!file.type.startsWith('image/')) { toast.error('يرجى اختيار صورة'); return }
              if (file.size > 5 * 1024 * 1024) { toast.error('الحجم يجب أن يكون أقل من 5 ميجابايت'); return }
              const fd = new FormData(); fd.append('file', file)
              await api.post(`/purchases/${r.id}/upload-invoice`, fd, { headers: { 'Content-Type': 'multipart/form-data' } })
              toast.success('تم رفع صورة الفاتورة'); qc.invalidateQueries({ queryKey: ['purchases'] })
              e.target.value = ''
            }} />
          </label>
          {r.invoice_image_url && (
            <a href={r.invoice_image_url?.startsWith("/uploads") ? "/api" + r.invoice_image_url : r.invoice_image_url} target="_blank" rel="noreferrer" className="p-1.5 rounded-lg hover:bg-blue-50 text-blue-400" title="عرض الفاتورة" onClick={e => { e.preventDefault(); window.open(r.invoice_image_url, '_blank') }}>🖼️</a>
          )}
          <button onClick={() => { setPrintingId(r.id); openPrint(`/print/purchase/${r.id}`); setTimeout(() => setPrintingId(null), 2000) }}
            disabled={printingId === r.id}
            className="p-1.5 rounded-lg hover:bg-blue-50 text-slate-300 hover:text-blue-600 disabled:opacity-40" title="طباعة">
            <Printer size={14} />
          </button>
          {r.status === 'draft' && (
            <button onClick={() => setReceivePO(r.id)}
              className="px-3 py-1.5 rounded-lg text-xs font-bold text-white flex items-center gap-1" style={{ background: '#16a34a' }}>
              <Package size={12} /> استلام
            </button>
          )}
        </div>
      )
    },
  ]

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">📦 فواتير المشتريات</h1>
        <div className="flex items-center gap-3">
          <ExportButton data={filtered || []} columns={[
            { label: 'رقم الأمر', accessor: (r: any) => r.po_number },
            { label: 'المورد', accessor: (r: any) => r.supplier_name || '—' },
            { label: 'الإجمالي', accessor: (r: any) => Number(r.total_cost) },
            { label: 'الحالة', accessor: (r: any) => r.status },
            { label: 'التاريخ', accessor: (r: any) => new Date(r.created_at).toLocaleDateString('en-CA') },
          ]} filename="المشتريات" excelEndpoint="/export/purchases" />
          <button onClick={() => setShowNew(true)} className="px-4 py-2.5 rounded-xl text-sm font-bold text-white flex items-center gap-2" style={{ background: '#1e3a5f' }}>
            <Plus size={15} /> فاتورة مشتريات جديدة
          </button>
        </div>
      </div>

      <div className="mb-4">
        <input className="input max-w-xs" placeholder="بحث برقم الأمر أو المورد..." value={search} onChange={e => setSearch(e.target.value)} />
      </div>

      <DataTable columns={columns} data={filtered} loading={isLoading}
        rowKey={(r: any) => r.id} emptyMessage="لا توجد أوامر شراء" emptyIcon="📦" />

      <Modal open={showNew} onClose={() => setShowNew(false)} title="فاتورة مشتريات جديدة" size="xl">
        <NewPOForm onClose={() => setShowNew(false)} />
      </Modal>
      <Modal open={!!receivePO} onClose={() => setReceivePO(null)} title="استلام البضاعة" size="xl">
        {receivePO && <ReceivePOModal poId={receivePO} onClose={() => setReceivePO(null)} />}
      </Modal>
    </div>
  )
}
