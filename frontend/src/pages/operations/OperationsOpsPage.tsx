import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { productsApi, stockApi } from '../../api/endpoints'
import api from '../../api/client'
import { PageLoader, EmptyState } from '../../components/ui/Loaders'
import Modal from '../../components/ui/Modal'
import toast from 'react-hot-toast'
import { Truck, PackagePlus, Plus, Minus, X, Search } from 'lucide-react'
import { Button } from '../../components/ui/button'
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '../../components/ui/table'
import { Input } from '../../components/ui/input'
import { Textarea } from '../../components/ui/textarea'
import { Select } from '../../components/ui/select'
import { Badge } from '../../components/ui/badge'

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
        <Search size={14} className="absolute right-3 top-1/2 -translate-y-1/2 text-[var(--muted)]" />
 <Input className="pr-9 text-sm" placeholder="ابحث عن صنف..." value={search} onChange={e => setSearch(e.target.value)}/>
      </div>
      {products && search.length > 1 && (
        <div className="absolute z-20 w-full bg-[var(--surface)] border border-[var(--border)] rounded-xl shadow-xl mt-1 max-h-48 overflow-y-auto">
          {products.map((p: any) => (
            <Button key={p.id} variant="ghost" onClick={() => { onAdd(p); setSearch('') }}
              className="w-full text-right px-4 py-2.5 hover:bg-[var(--surface-2)] justify-between text-sm border-b border-slate-50 last:border-0 h-auto">
              <span className="font-medium truncate">{p.name}</span>
              <span className="text-[var(--muted)] text-xs mr-2 flex-shrink-0">{p.unit}</span>
            </Button>
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
    <div className="border border-[var(--border)] rounded-xl overflow-hidden">
      <Table className="w-full text-sm">
        <TableHeader className="bg-[var(--surface-2)]">
          <TableRow>
            <TableHead className="text-right px-3 py-2">الصنف</TableHead>
            <TableHead className="text-center px-3 py-2 w-28">الكمية</TableHead>
            {showCost && <TableHead className="text-center px-3 py-2 w-28">سعر التكلفة</TableHead>}
            <TableHead className="w-8"></TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {items.map(item => (
            <TableRow key={item.product_id} className="border-t border-[var(--border-faint)]">
              <TableCell className="px-3 py-2 font-medium">{item.name} <span className="text-[var(--muted)] text-xs">({item.unit})</span></TableCell>
              <TableCell className="px-3 py-2">
                <div className="flex items-center justify-center gap-1">
                  <Button variant="ghost" size="icon-sm" onClick={() => update(item.product_id, 'qty', Math.max(1, item.qty - 1))} className="w-6 h-6 rounded bg-[var(--surface-3)] hover:bg-[var(--surface-3)]"><Minus size={10} /></Button>
                  <input type="number" aria-label={`كمية ${item.name}`} className="w-14 text-center border border-[var(--border)] rounded px-1 py-0.5 text-sm" value={item.qty}
                    onChange={e => update(item.product_id, 'qty', Number(e.target.value))} />
                  <Button variant="ghost" size="icon-sm" onClick={() => update(item.product_id, 'qty', item.qty + 1)} className="w-6 h-6 rounded bg-[var(--surface-3)] hover:bg-[var(--surface-3)]"><Plus size={10} /></Button>
                </div>
              </TableCell>
              {showCost && (
                <TableCell className="px-3 py-2">
                  <input type="number" aria-label={`تكلفة ${item.name}`} step="0.01" className="w-full text-center border border-[var(--border)] rounded px-2 py-0.5 text-sm" value={item.unit_cost}
                    onChange={e => update(item.product_id, 'unit_cost', Number(e.target.value))} />
                </TableCell>
              )}
              <TableCell className="px-3 py-2">
                <Button variant="ghost" size="icon-sm" onClick={() => setItems((p: CartItem[]) => p.filter(i => i.product_id !== item.product_id))} className="text-[var(--faint)] hover:text-red-500"><X size={14} /></Button>
              </TableCell>
            </TableRow>
          ))}
          {!items.length && <TableRow><TableCell colSpan={4} className="text-center py-6 text-[var(--muted)] text-sm">أضف أصناف من البحث أعلاه</TableCell></TableRow>}
        </TableBody>
      </Table>
    </div>
  )
}

export default function OperationsOpsPage() {
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
    dispatch:      { label: 'إذن صرف', icon: Truck,         iconBg: 'bg-[var(--primary-soft)]', iconColor: 'text-[var(--primary)]', desc: 'نقل بضاعة من مخزن إلى معرض' },
    goods_receipt: { label: 'استلام مشتريات', icon: PackagePlus, iconBg: 'bg-green-50', iconColor: 'text-green-600', desc: 'استلام بضاعة جديدة من تاجر' },
  }

  const docTypeLabel: Record<string, string> = {
    dispatch_order: 'إذن صرف', goods_receipt: 'استلام مشتريات', stock_request: 'استلام مشتريات'
  }
  const docTypeBadge: Record<string, string> = {
    dispatch_order: 'blue', goods_receipt: 'green', stock_request: 'green'
  }

  const showrooms = warehouses?.filter((w: any) => w.warehouse_type === 'showroom') || []
  const stores    = warehouses?.filter((w: any) => w.warehouse_type === 'warehouse') || []

  return (
    <div>
      {/* Operation type cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8">
        {(Object.entries(opConfig) as any[]).map(([key, cfg]) => (
          <Button key={key} variant="ghost" onClick={() => { setActiveOp(key as OpType); reset() }}
            className="card text-right hover:shadow-md transition-all active:scale-95 border-2 hover:border-[var(--primary-border)] w-full h-auto flex-col items-start bg-[var(--surface)] rounded-[var(--r-lg)] border-[var(--border)] p-4">
            <div className={`w-12 h-12 rounded-xl flex items-center justify-center mb-3 ${cfg.iconBg}`}>
              <cfg.icon size={22} className={cfg.iconColor + ' size-[22px]'} />
            </div>
            <p className="font-bold text-[var(--text)] text-base">{cfg.label}</p>
            <p className="text-[var(--muted)] text-sm mt-1">{cfg.desc}</p>
          </Button>
        ))}
      </div>

      {/* Operations history */}
      <div className="card p-0 overflow-hidden">
        <div className="px-6 py-4 border-b border-[var(--border-faint)]">
          <h3 className="font-bold text-[var(--text)]">سجل العمليات</h3>
        </div>
        {isLoading ? <PageLoader /> : (
          <div className="table-wrap">
            <Table>
              <TableHeader><TableRow><TableHead>رقم المستند</TableHead><TableHead>النوع</TableHead><TableHead>التفاصيل</TableHead><TableHead>التاريخ</TableHead></TableRow></TableHeader>
              <TableBody>
                {!operations?.length && <TableRow><TableCell colSpan={4}><EmptyState message="لا توجد عمليات بعد" icon="📋" /></TableCell></TableRow>}
                {operations?.map((op: any) => (
                  <TableRow key={op.id}>
                    <TableCell>
                      <p className="font-semibold text-[var(--text)]">{op.metadata?.supplier || op.metadata?.from || op.metadata?.to || '—'}</p>
                      <p className="text-xs text-[var(--muted)] font-mono mt-0.5">{op.doc_number}</p>
                    </TableCell>
                    <TableCell><Badge variant={(docTypeBadge as any)[op.doc_type] || 'gray'}>{docTypeLabel[op.doc_type] || op.doc_type}</Badge></TableCell>
                    <TableCell className="text-sm text-[var(--text-soft)]">
                      {op.metadata?.from && <span>من: {op.metadata.from} </span>}
                      {op.metadata?.to && <span>إلى: {op.metadata.to} </span>}
                      {op.metadata?.supplier && <span>المورد: {op.metadata.supplier} </span>}
                      {op.metadata?.items?.length && <span>({op.metadata.items.length} صنف)</span>}
                    </TableCell>
                    <TableCell className="text-sm text-[var(--muted)]">{new Date(op.created_at).toLocaleString('ar-EG')}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
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
                  <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">
                    {activeOp === 'dispatch' ? 'من المخزن' : 'المخزن المطلوب منه'}
                  </label>
                  <Select value={fromWh} onChange={e => setFromWh(e.target.value)}>
                    <option value="">اختر...</option>
                    <optgroup label="المخازن">
                      {stores.map((w: any) => <option key={w.id} value={w.id}>{w.name}</option>)}
                    </optgroup>
                    <optgroup label="المعارض">
                      {showrooms.map((w: any) => <option key={w.id} value={w.id}>{w.name}</option>)}
                    </optgroup>
                  </Select>
                </div>
              )}
              <div>
                <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">
                  {activeOp === 'dispatch' ? 'إلى المعرض' : 'المخزن المستلِم'}
                </label>
                <Select value={toWh} onChange={e => setToWh(e.target.value)}>
                  <option value="">اختر...</option>
                  <optgroup label="المعارض">
                    {showrooms.map((w: any) => <option key={w.id} value={w.id}>{w.name}</option>)}
                  </optgroup>
                  <optgroup label="المخازن">
                    {stores.map((w: any) => <option key={w.id} value={w.id}>{w.name}</option>)}
                  </optgroup>
                </Select>
              </div>
            </div>

            {activeOp === 'goods_receipt' && (
              <div>
                <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">اسم المورد / التاجر</label>
 <Input value={supplier} onChange={e => setSupplier(e.target.value)} placeholder="اسم التاجر..."/>
              </div>
            )}

            <div>
              <label className="block text-sm font-medium text-[var(--text-soft)] mb-2">إضافة أصناف</label>
              <ProductPicker onAdd={addItem} />
            </div>

            <ItemsTable items={items} setItems={setItems} showCost={activeOp === 'goods_receipt'} />

            <div>
              <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">ملاحظات</label>
              <Textarea className="h-16 resize-none" value={notes} onChange={e => setNotes(e.target.value)} />
            </div>

            <div className="flex gap-3 justify-end pt-2">
              <Button variant="ghost" onClick={() => setActiveOp(null)}>إلغاء</Button>
              <Button
                onClick={() => {
                  if (!toWh) return toast.error('اختر المخزن المستلم أولاً')
                  if (!fromWh && activeOp !== 'goods_receipt') return toast.error('اختر المخزن المصدر أولاً')
                  submitMut.mutate()
                }}
                disabled={!items.length || !toWh || (!fromWh && activeOp !== 'goods_receipt') || submitMut.isPending}
              >
                {submitMut.isPending ? 'جاري...' : `إنشاء ${opConfig[activeOp].label}`}
              </Button>
            </div>
          </div>
        </Modal>
      )}
    </div>
  )
}