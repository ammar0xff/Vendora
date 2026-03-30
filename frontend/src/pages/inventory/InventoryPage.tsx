import { useState, useEffect } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { productsApi, categoriesApi, subcategoriesApi, stockApi } from '../../api/endpoints'
import { useAppStore } from '../../store/app'
import { useAuthStore } from '../../store/auth'
import { PageLoader, EmptyState } from '../../components/ui/Loaders'
import ProductForm from '../../components/ui/ProductForm'
import DataTable from '../../components/ui/DataTable'
import Modal from '../../components/ui/Modal'
import api from '../../api/client'
import toast from 'react-hot-toast'
import { Plus, Edit2, Trash2, ChevronDown, ChevronLeft, Package, TrendingUp, Search, Layers, Tag, BarChart2 } from 'lucide-react'
import { clsx } from 'clsx'

function BreakdownModal({ productId, unit }: { productId?: string; unit?: string }) {
  const { data, isLoading } = useQuery({
    queryKey: ['breakdown', productId],
    queryFn: () => api.get(`/stock/balance/breakdown/${productId}`).then(r => r.data),
    enabled: !!productId,
  })
  if (isLoading) return <p className="text-center py-8 text-slate-400">جاري التحميل...</p>
  const total = data?.reduce((s: number, r: any) => s + Number(r.qty), 0) || 0
  return (
    <div className="space-y-2">
      {data?.map((r: any) => (
        <div key={r.warehouse_name} className="flex items-center justify-between p-3 rounded-xl bg-slate-50 border border-slate-100">
          <div className="flex items-center gap-2">
            <span>{r.warehouse_type === 'showroom' ? '🏪' : '🏭'}</span>
            <span className="font-semibold text-slate-700">{r.warehouse_name}</span>
          </div>
          <span className={`font-black ${Number(r.qty) <= 0 ? 'text-red-500' : 'text-green-700'}`}>
            {Number(r.qty).toLocaleString('ar-EG')} {unit}
          </span>
        </div>
      ))}
      <div className="flex justify-between pt-3 border-t border-slate-200 font-black text-slate-800">
        <span>الإجمالي</span>
        <span>{total.toLocaleString('ar-EG')} {unit}</span>
      </div>
    </div>
  )
}

export default function InventoryPage() {
  const [search, setSearch] = useState('')
  const [selectedCatId, setSelectedCatId] = useState<string | null>(null)
  const [selectedSubId, setSelectedSubId] = useState<string | null>(null)
  const [breakdownProduct, setBreakdownProduct] = useState<any>(null)
  const { activeWarehouseId } = useAppStore()
  const { user } = useAuthStore()
  const isAdmin = (user as any)?.role === 'admin'
  const isCompanyView = !activeWarehouseId
  const [expandedCats, setExpandedCats] = useState<Set<string>>(new Set())
  const [showAdd, setShowAdd] = useState(false)
  const [editProduct, setEditProduct] = useState<any>(null)
  const [viewMovements, setViewMovements] = useState<any>(null)
  const qc = useQueryClient()

  const { data: categories } = useQuery({ queryKey: ['categories'], queryFn: categoriesApi.list })
  const { data: subcategories } = useQuery({ queryKey: ['subcategories'], queryFn: () => subcategoriesApi.list() })
  const { data: products, isLoading } = useQuery({
    queryKey: ['products', search, selectedCatId, selectedSubId],
    queryFn: () => productsApi.list({
      ...(search ? { search } : {}),
      ...(selectedSubId ? { subcategory_id: selectedSubId } : selectedCatId ? { category_id: selectedCatId } : {}),
    }),
  })

  // Fetch stock balances for visible products
  const productIds = products?.map((p: any) => p.id) || []
  const { data: balances } = useQuery({
    queryKey: ['balances', activeWarehouseId, productIds.length, productIds[0]],
    queryFn: () => isCompanyView
      ? api.post('/stock/balance/total', productIds).then(r => r.data)
      : api.post(`/stock/balance/bulk?warehouse_id=${activeWarehouseId}`, productIds).then(r => r.data),
    enabled: productIds.length > 0,
    staleTime: 30_000,
  })
  const { data: movements } = useQuery({
    queryKey: ['movements', viewMovements?.id],
    queryFn: () => productsApi.movements(viewMovements.id),
    enabled: !!viewMovements,
  })

  const createMut = useMutation({ mutationFn: productsApi.create, onSuccess: () => { toast.success('تم إضافة المنتج'); setShowAdd(false); qc.invalidateQueries({ queryKey: ['products'] }) } })
  const updateMut = useMutation({ mutationFn: ({ id, data }: any) => productsApi.update(id, data), onSuccess: () => { toast.success('تم التحديث'); setEditProduct(null); qc.invalidateQueries({ queryKey: ['products'] }) } })
  const deleteMut = useMutation({ mutationFn: productsApi.delete, onSuccess: () => { toast.success('تم الحذف'); qc.invalidateQueries({ queryKey: ['products'] }) } })

  const toggleCat = (id: string) => {
    setExpandedCats(prev => { const s = new Set(prev); s.has(id) ? s.delete(id) : s.add(id); return s })
  }

  const getSubsForCat = (catId: string) => subcategories?.filter((s: any) => s.category_id === catId) || []

  const mvTypeLabel: Record<string, string> = {
    opening_stock: 'رصيد افتتاحي', purchase: 'شراء', sale: 'بيع',
    return_in: 'مرتجع', adjustment_in: 'تسوية +', adjustment_out: 'تسوية -',
    damage: 'تلف', transfer_in: 'تحويل وارد', transfer_out: 'تحويل صادر',
  }

  const activeCrumb = selectedSubId
    ? subcategories?.find((s: any) => s.id === selectedSubId)?.name
    : selectedCatId
    ? categories?.find((c: any) => c.id === selectedCatId)?.name
    : null

  return (
    <div className="flex gap-5 h-[calc(100vh-3rem)]">

      {/* ── Tree Sidebar ─────────────────────────────────────────── */}
      <aside className="w-52 flex-shrink-0 flex flex-col bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
        <div className="px-4 py-3 border-b border-slate-100 flex-shrink-0">
          <p className="text-xs font-bold text-slate-400 uppercase tracking-wide">التصنيفات</p>
        </div>
        <div className="flex-1 overflow-y-auto py-2">
          {/* All */}
          <button
            onClick={() => { setSelectedCatId(null); setSelectedSubId(null) }}
            className={clsx('w-full text-right px-4 py-2 text-sm font-semibold transition-colors flex items-center gap-2',
              !selectedCatId && !selectedSubId ? 'text-white rounded-lg mx-2 w-[calc(100%-1rem)]' : 'text-slate-600 hover:bg-slate-50')}
            style={!selectedCatId && !selectedSubId ? { background: '#1e3a5f' } : {}}
          >
            <Package size={14} /> الكل
          </button>

          {categories?.map((cat: any) => {
            const subs = getSubsForCat(cat.id)
            const isExpanded = expandedCats.has(cat.id)
            const isCatActive = selectedCatId === cat.id && !selectedSubId

            return (
              <div key={cat.id}>
                {/* Category row */}
                <div className="flex items-center group">
                  <button
                    onClick={() => { setSelectedCatId(cat.id); setSelectedSubId(null); if (!isExpanded) toggleCat(cat.id) }}
                    title={cat.name}
                    className={clsx('flex-1 text-right px-3 py-2 text-sm font-semibold transition-colors flex items-center gap-2',
                      isCatActive ? 'text-white rounded-lg mx-2 w-[calc(100%-1rem)]' : 'text-slate-700 hover:bg-slate-50')}
                    style={isCatActive ? { background: '#1e3a5f' } : {}}
                  >
                    <Tag size={12} className="flex-shrink-0 opacity-60" />
                    <span className="truncate leading-tight">{cat.name}</span>
                  </button>
                  {subs.length > 0 && (
                    <button onClick={() => toggleCat(cat.id)} className="pr-3 text-slate-400 hover:text-slate-600 flex-shrink-0">
                      {isExpanded ? <ChevronDown size={13} /> : <ChevronLeft size={13} />}
                    </button>
                  )}
                </div>

                {/* Subcategories */}
                {isExpanded && subs.map((sub: any) => {
                  const isSubActive = selectedSubId === sub.id
                  return (
                    <button
                      key={sub.id}
                      onClick={() => { setSelectedCatId(cat.id); setSelectedSubId(sub.id) }}
                      title={sub.name}
                      className={clsx('w-full text-right pl-3 pr-7 py-1.5 text-xs font-medium transition-colors flex items-center gap-2',
                        isSubActive ? 'text-white rounded-lg mx-2 w-[calc(100%-1rem)]' : 'text-slate-500 hover:bg-slate-50 hover:text-slate-700')}
                      style={isSubActive ? { background: '#2d5a8e' } : {}}
                    >
                      <Layers size={10} className="flex-shrink-0 opacity-50" />
                      <span className="truncate leading-tight">{sub.name}</span>
                    </button>
                  )
                })}
              </div>
            )
          })}
        </div>
      </aside>

      {/* ── Main Content ─────────────────────────────────────────── */}
      <div className="flex-1 flex flex-col min-w-0">
        {/* Header */}
        <div className="flex items-center justify-between mb-4 flex-shrink-0">
          <div>
            <h1 className="page-title">المخزون</h1>
            {activeCrumb && (
              <p className="text-sm text-slate-500 mt-0.5 flex items-center gap-1">
                <span className="text-slate-400">الكل</span>
                <ChevronLeft size={12} className="text-slate-300" />
                <span className="font-medium text-slate-600">{activeCrumb}</span>
              </p>
            )}
          </div>
          <button onClick={() => setShowAdd(true)} className="px-4 py-2.5 rounded-xl font-bold text-sm text-white flex items-center gap-2 flex-shrink-0" style={{ background: '#1e3a5f' }}>
            <Plus size={15} /> إضافة منتج
          </button>
        </div>

        {/* Search */}
        <div className="relative mb-4 flex-shrink-0">
          <Search size={16} className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input className="input pr-10" placeholder="بحث عن منتج..." value={search} onChange={e => { setSearch(e.target.value); setSelectedCatId(null); setSelectedSubId(null) }} />
        </div>

        {/* Products table */}
        <div className="flex-1 overflow-y-auto">
          <DataTable
            columns={[
              { key: 'name', label: 'المنتج', sortable: true, render: (p: any) => (
                <div>
                  <p className="font-bold text-slate-800">{p.name}</p>
                  {p.company && <p className="text-xs text-slate-400">{p.company}</p>}
                </div>
              )},
              { key: 'qty', label: 'المخزون', sortable: true, render: (p: any) => {
                // If balances loaded but product not in response → 0 stock
                const qty = balances ? (balances[p.id] ?? 0) : null
                if (qty === null) return <span className="text-slate-300 text-xs">جاري...</span>
                const low = qty <= 5
                return <span className={`font-black text-sm ${low ? 'text-red-600' : 'text-green-700'}`}>{qty} {p.unit}</span>
              }},
              { key: 'retail_price', label: 'سعر القطاعي', sortable: true, render: (p: any) => <span className="font-bold" style={{ color: '#c8a84b' }}>{Number(p.retail_price).toLocaleString('ar-EG')} ج.م</span> },
              { key: 'wholesale_price', label: 'سعر الجملة', sortable: true, render: (p: any) => <span className="text-slate-600">{Number(p.wholesale_price).toLocaleString('ar-EG')} ج.م</span> },
              { key: 'cost_price', label: 'التكلفة', sortable: true, render: (p: any) => <span className="text-slate-500 text-sm">{Number(p.cost_price).toLocaleString('ar-EG')} ج.م</span> },
              { key: 'actions', label: '', render: (p: any) => (
                <div className="flex gap-1 justify-end">
                  {isAdmin && isCompanyView && (
                    <button onClick={() => setBreakdownProduct(p)} className="p-1.5 rounded-lg hover:bg-purple-50 text-slate-300 hover:text-purple-500" title="توزيع المخازن"><BarChart2 size={14} /></button>
                  )}
                  <button onClick={() => setViewMovements(p)} className="p-1.5 rounded-lg hover:bg-blue-50 text-slate-300 hover:text-blue-500" title="الحركات"><TrendingUp size={14} /></button>
                  <button onClick={() => setEditProduct(p)} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-300 hover:text-slate-600" title="تعديل"><Edit2 size={14} /></button>
                  <button onClick={() => { if (confirm('حذف؟')) deleteMut.mutate(p.id) }} className="p-1.5 rounded-lg hover:bg-red-50 text-slate-300 hover:text-red-500" title="حذف"><Trash2 size={14} /></button>
                </div>
              )},
            ]}
            data={products || []}
            loading={isLoading}
            rowKey={(p: any) => p.id}
            emptyMessage="لا توجد منتجات" emptyIcon="📦"
          />
        </div>
      </div>

      {/* Modals */}
      <Modal open={showAdd} onClose={() => setShowAdd(false)} title="إضافة منتج جديد" size="lg">
        <ProductForm onSave={(d: any) => createMut.mutate(d)} onClose={() => setShowAdd(false)} />
      </Modal>
      <Modal open={!!editProduct} onClose={() => setEditProduct(null)} title="تعديل المنتج" size="lg">
        {editProduct && <ProductForm product={editProduct} onSave={(d: any) => updateMut.mutate({ id: editProduct.id, data: d })} onClose={() => setEditProduct(null)} />}
      </Modal>
      <Modal open={!!viewMovements} onClose={() => setViewMovements(null)} title={`حركات: ${viewMovements?.name}`} size="xl">
        <div className="table-wrap max-h-96 overflow-y-auto">
          <table>
            <thead><tr><th>التاريخ</th><th>النوع</th><th>الكمية</th><th>ملاحظة</th></tr></thead>
            <tbody>
              {movements?.map((m: any) => (
                <tr key={m.id}>
                  <td className="text-xs text-slate-500">{new Date(m.created_at).toLocaleString('ar-EG')}</td>
                  <td><span className={clsx('badge', ['transfer_in','return_in','purchase','opening_stock','adjustment_in'].includes(m.movement_type) ? 'badge-green' : 'badge-red')}>{mvTypeLabel[m.movement_type] || m.movement_type}</span></td>
                  <td className="font-bold">{m.qty}</td>
                  <td className="text-xs text-slate-500">{m.note || '-'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Modal>

      {/* Breakdown per warehouse modal */}
      <Modal open={!!breakdownProduct} onClose={() => setBreakdownProduct(null)} title={`توزيع المخازن — ${breakdownProduct?.name}`}>
        <BreakdownModal productId={breakdownProduct?.id} unit={breakdownProduct?.unit} />
      </Modal>
    </div>
  )
}
