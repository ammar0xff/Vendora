import { useState, useRef } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { ShoppingCart, Plus, Minus, CheckCircle, Search, Package, X } from 'lucide-react'
import { productsApi, stockApi, purchasesApi, suppliersApi, categoriesApi, subcategoriesApi } from '../../api/endpoints'
import { usePurchaseCartStore } from '../../store/purchaseCart'
import { useAppStore } from '../../store/app'
import toast from 'react-hot-toast'
import { clsx } from 'clsx'
import CategoryCardBrowser from '../pos/CategoryCardBrowser'
import { Button } from '../../components/ui/button'
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '../../components/ui/table'
import { Input } from '../../components/ui/input'

export default function PurchaseBillPage() {
  const { activeWarehouseId, setActiveWarehouse } = useAppStore()
  const { items, addItem, updateQty, updateCost, removeItem, clear, totalCost } = usePurchaseCartStore()
  const qc = useQueryClient()

  const [supplierId, setSupplierId] = useState('')
  const [search, setSearch] = useState('')
  const [debouncedSearch, setDebouncedSearch] = useState('')
  const [viewMode, setViewMode] = useState<'cards' | 'table'>('cards')
  const [mobileTab, setMobileTab] = useState<'products' | 'cart'>('products')
  const searchTimer = useRef<any>(null)

  const handleSearch = (v: string) => {
    setSearch(v)
    clearTimeout(searchTimer.current)
    searchTimer.current = setTimeout(() => setDebouncedSearch(v), 350)
  }

  const { data: warehousesRaw } = useQuery({ queryKey: ['warehouses'], queryFn: stockApi.warehouses })
  const { data: suppliersRaw } = useQuery({ queryKey: ['suppliers'], queryFn: suppliersApi.list })
  const warehouses = Array.isArray(warehousesRaw) ? warehousesRaw : []
  const suppliers = Array.isArray(suppliersRaw) ? suppliersRaw : []

  const targetWhId = activeWarehouseId || ''

  const { data: productsRaw } = useQuery({
    queryKey: ['purchase-products', debouncedSearch],
    queryFn: () => productsApi.list({ page_size: 5000, ...(debouncedSearch ? { search: debouncedSearch } : {}) }),
    staleTime: 30_000,
  })
  const products = Array.isArray(productsRaw) ? productsRaw : (productsRaw?.items ?? [])

  const { data: stockMap } = useQuery({
    queryKey: ['purchase-stock', targetWhId, products.map((p: any) => p.id).join(',')],
    queryFn: () => stockApi.balanceBulk(targetWhId!, products!.map((p: any) => p.id)),
    enabled: !!targetWhId && !!products?.length,
    staleTime: 10_000,
  })

  const { data: categoriesRaw } = useQuery({ queryKey: ['categories'], queryFn: categoriesApi.list })
  const { data: subcategoriesRaw } = useQuery({ queryKey: ['subcategories'], queryFn: subcategoriesApi.list })
  const categories = Array.isArray(categoriesRaw) ? categoriesRaw : []
  const subcategories = Array.isArray(subcategoriesRaw) ? subcategoriesRaw : []

  const handleAddProduct = (p: any) => {
    if (!targetWhId) { toast.error('اختر المخزن أولاً'); return }
    const currentStock = p.stock_status === 'untracked' ? 0 : (stockMap?.[p.id] ?? 0)
    addItem({
      product_id: p.id,
      name: p.name,
      unit_cost: Number(p.cost_price) || 0,
      unit: p.unit,
      current_stock: Number(currentStock),
    })
    toast.success(`تمت إضافة ${p.name}`, { duration: 800 })
  }

  const submitMut = useMutation({
    mutationFn: async () => {
      if (!targetWhId) throw new Error('اختر المخزن')
      if (!items.length) throw new Error('السلة فارغة')
      const itemsData = items.map(i => {
        const diff = Math.max(1, i.new_qty - i.current_stock)
        return { product_id: i.product_id, unit_cost: i.unit_cost, qty: diff }
      })
      const po = await purchasesApi.create({
        warehouse_id: targetWhId,
        supplier_id: supplierId || null,
        notes: 'فاتورة مشتريات',
        items: itemsData,
      })
      await purchasesApi.receive(po.id, {
        items: itemsData.map((i: any) => ({
          product_id: i.product_id,
          qty_received: i.qty,
          unit_cost: i.unit_cost,
        })),
      })
      return po
    },
    onSuccess: (po: any) => {
      toast.success(`✅ تم تأكيد فاتورة المشتريات ${po.po_number}`)
      clear()
      qc.invalidateQueries({ queryKey: ['purchase-stock'] })
    },
    onError: (e: any) => toast.error(e.response?.data?.detail || e.message || 'فشل في تأكيد الفاتورة'),
  })

  const filteredProducts = (products || []).filter((p: any) => {
    const q = p.stock_status === 'untracked' ? null : (stockMap?.[p.id] ?? null)
    return q === null || q > 0
  })

  const [, setSelectedCatId] = useState<string | null>(null)
  const [selectedSubId, setSelectedSubId] = useState<string | null>(null)

  const getSubsForCat = (catId: string) => subcategories.filter((s: any) => s.category_id === catId)
  const handleCatClick = (catId: string) => {
    const subs = getSubsForCat(catId)
    setSelectedCatId(catId)
    if (subs.length === 0) setSelectedSubId('__all__')
    else setSelectedSubId(null)
  }

  const { data: catProductsRaw } = useQuery({
    queryKey: ['purchase-cat-products', selectedSubId],
    queryFn: () => productsApi.list({ page_size: 5000, subcategory_id: selectedSubId! }),
    enabled: !!selectedSubId,
  })
  const catProducts = Array.isArray(catProductsRaw) ? catProductsRaw : (catProductsRaw?.items ?? [])

  const handleWhChange = (whId: string) => {
    const wh = warehouses?.find((w: any) => w.id === whId)
    setActiveWarehouse(whId, wh?.name || '')
  }

  const productListView = (showProducts: any[]) => (
    <div className="flex-1 overflow-y-auto">
      {viewMode === 'cards' ? (
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-3 xl:grid-cols-4 gap-2.5">
          {showProducts.map((p: any) => {
            const qty = p.stock_status === 'untracked' ? null : (stockMap?.[p.id] ?? null)
            return (
              <Button key={p.id} onClick={() => handleAddProduct(p)} variant="ghost"
                className="bg-[var(--surface)] rounded-xl border border-[var(--border)] p-3 text-right hover:border-[var(--primary-border)] hover:shadow-md transition-all active:scale-95 flex flex-col h-auto w-full">
                <div className="flex items-start justify-between mb-1.5">
                  <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-blue-100 to-blue-200 flex items-center justify-center">
                    <Package size={14} className="text-blue-600" />
                  </div>
                  {qty != null && (
                    <span className={clsx('text-xs font-bold px-1.5 py-0.5 rounded-md',
                      qty <= 0 ? 'bg-red-100 text-red-600' : qty <= 5 ? 'bg-amber-100 text-amber-700' : 'bg-green-100 text-green-700'
                    )}>{qty}</span>
                  )}
                </div>
                <p className="text-xs font-bold text-[var(--text)] leading-tight line-clamp-2 mb-0.5">{p.name}</p>
                {p.company && <p className="text-[10px] text-[var(--muted)] mb-1.5">{p.company}</p>}
                <div className="mt-auto">
                  <p className="text-[10px] text-[var(--muted)]">التكلفة: {Number(p.cost_price || 0).toLocaleString('ar-EG')} ج.م</p>
                </div>
              </Button>
            )
          })}
        </div>
      ) : (
        <Table className="w-full text-right text-xs">
          <TableHeader className="sticky top-0 bg-[var(--surface-3)] z-10">
            <TableRow className="text-[var(--muted)] font-semibold">
              <TableHead className="py-2 px-2">المنتج</TableHead>
              <TableHead className="py-2 px-2">المخزون</TableHead>
              <TableHead className="py-2 px-2">سعر التكلفة</TableHead>
              <TableHead className="py-2 px-2"></TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {showProducts.map((p: any) => {
              const qty = p.stock_status === 'untracked' ? null : (stockMap?.[p.id] ?? null)
              return (
                <TableRow key={p.id} onClick={() => handleAddProduct(p)}
                  className="border-t border-[var(--border-faint)] hover:bg-blue-50 cursor-pointer transition-colors">
                  <TableCell className="py-2 px-2 font-semibold text-[var(--text)]">{p.name}</TableCell>
                  <TableCell className="py-2 px-2">
                    {qty !== null ? (
                      <span className={clsx('font-bold px-1 rounded', qty <= 0 ? 'text-red-500' : qty <= 5 ? 'text-amber-600' : 'text-green-600')}>{qty}</span>
                    ) : <span className="text-[var(--faint)]">—</span>}
                  </TableCell>
                  <TableCell className="py-2 px-2 font-black text-[var(--accent)]">{Number(p.cost_price || 0).toLocaleString('ar-EG')}</TableCell>
                  <TableCell className="py-2 px-2 text-blue-500 font-bold text-sm">+</TableCell>
                </TableRow>
              )
            })}
          </TableBody>
        </Table>
      )}
    </div>
  )

  const cartPanel = (
    <div className="w-full lg:w-96 flex flex-col bg-[var(--surface)] rounded-xl border border-[var(--border)] min-h-0 flex-shrink-0">
      <div className="px-4 py-3 flex-shrink-0" style={{ background: 'var(--primary)' }}>
        <div className="flex items-center justify-between mb-2">
          <span className="text-white font-bold text-sm">فاتورة مشتريات</span>
          {items.length > 0 && <Button onClick={clear} variant="ghost" size="sm" className="text-white/50 text-xs px-1 h-auto">✕ مسح</Button>}
        </div>
        <div className="space-y-2">
          <select value={supplierId} onChange={e => setSupplierId(e.target.value)}
            className="w-full bg-white/10 border border-white/20 rounded-lg px-3 py-2 text-white text-sm outline-none focus:border-yellow-400">
            <option value="" className="text-[var(--text)]">اختر المورد (اختياري)</option>
            {suppliers?.map((s: any) => (
              <option key={s.id} value={s.id} className="text-[var(--text)]">{s.name}</option>
            ))}
          </select>
          <select value={targetWhId} onChange={e => handleWhChange(e.target.value)}
            className="w-full bg-white/10 border border-white/20 rounded-lg px-3 py-2 text-white text-sm outline-none focus:border-yellow-400">
            <option value="" className="text-[var(--text)]">اختر المخزن</option>
            {warehouses?.filter((w: any) => ['warehouse', 'showroom'].includes(w.warehouse_type)).map((w: any) => (
              <option key={w.id} value={w.id} className="text-[var(--text)]">{w.warehouse_type === 'showroom' ? '🏪' : '🏭'} {w.name}</option>
            ))}
          </select>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-3 space-y-2">
        {!items.length && (
          <div className="text-center py-16 text-[var(--faint)]">
            <ShoppingCart size={40} className="mx-auto mb-3 opacity-30" />
            <p className="text-sm">السلة فارغة</p>
            <p className="text-xs text-[var(--muted)] mt-1">اختر منتجات من القائمة</p>
          </div>
        )}
        {items.map((item) => {
          const addQty = Math.max(0, item.new_qty - item.current_stock)
          const lineTotal = addQty * item.unit_cost
          return (
            <div key={item.product_id} className="bg-[var(--surface)] rounded-xl border border-[var(--border-faint)] p-3">
              <div className="flex items-start justify-between gap-2">
                <div className="flex-1 min-w-0">
                  <p className="font-bold text-[var(--text)] text-sm leading-tight truncate">{item.name}</p>
                  <p className="text-xs text-[var(--muted)]">{item.unit} · المخزون: {item.current_stock}</p>
                </div>
                <Button variant="ghost" size="icon-sm" onClick={() => removeItem(item.product_id)} className="text-[var(--faint)] hover:text-red-500 flex-shrink-0" aria-label="إزالة">
                  <X size={14} />
                </Button>
              </div>
              <div className="flex items-center justify-between mt-2 gap-1">
                <div className="flex items-center gap-1">
                  <Button variant="ghost" size="icon-sm" onClick={() => updateQty(item.product_id, item.new_qty - 1)} className="w-7 h-7 rounded-lg bg-[var(--surface-3)] flex items-center justify-center text-[var(--text-soft)] active:scale-90" aria-label="إنقاص"><Minus size={12} /></Button>
                  <input type="number" aria-label={`كمية ${item.name}`} min="1" value={item.new_qty}
                    onChange={e => updateQty(item.product_id, Math.max(1, Number(e.target.value)))}
                    className="w-14 text-center text-sm font-bold border border-[var(--border)] rounded-lg py-1 outline-none focus:border-[var(--accent)]" />
                  <Button variant="ghost" size="icon-sm" onClick={() => updateQty(item.product_id, item.new_qty + 1)} className="w-7 h-7 rounded-lg bg-[var(--surface-3)] flex items-center justify-center text-[var(--text-soft)] active:scale-90" aria-label="زيادة"><Plus size={12} /></Button>
                </div>
                <div className="flex items-center gap-1">
                  <span className="text-[10px] text-[var(--muted)]">تكلفة</span>
                  <input type="number" aria-label={`تكلفة ${item.name}`} min="0" step="0.01" value={item.unit_cost}
                    onChange={e => updateCost(item.product_id, Number(e.target.value))}
                    className="w-16 text-center text-sm font-bold border border-[var(--border)] rounded-lg py-1 outline-none focus:border-[var(--accent)]" />
                </div>
              </div>
              <div className="flex justify-between mt-1.5 text-xs">
                <span className="text-green-600">الإضافة: +{addQty}</span>
                <span className="font-bold text-[var(--text-soft)]">{lineTotal.toLocaleString('ar-EG')} ج.م</span>
              </div>
            </div>
          )
        })}
      </div>

      <div className="p-3 border-t border-[var(--border-faint)] flex-shrink-0 space-y-2">
        <div className="flex justify-between items-center">
          <span className="text-[var(--muted)] text-sm">إجمالي الفاتورة</span>
          <span className="text-2xl font-black text-[var(--primary)]">{totalCost().toLocaleString('ar-EG')} ج.م</span>
        </div>
        <Button onClick={() => submitMut.mutate()}
          disabled={!items.length || !targetWhId || submitMut.isPending}
          className={clsx('w-full font-black', items.length && targetWhId ? 'bg-green-600 hover:bg-green-700 text-white' : 'text-[var(--muted)]')}
          variant={items.length && targetWhId ? 'default' : 'ghost'}
          size="lg">
          <CheckCircle size={20} />
          {submitMut.isPending ? 'جاري...' : !targetWhId ? '⚠️ اختر المخزن' : 'تأكيد فاتورة المشتريات'}
        </Button>
      </div>
    </div>
  )

  return (
    <div className="flex flex-col h-[calc(100vh-120px)] lg:h-[calc(100vh-100px)]">
      {/* Desktop top bar */}
      <div className="hidden lg:flex items-center gap-3 mb-3 flex-shrink-0 flex-wrap">
        <div className="relative flex-1 max-w-md">
          <Search size={15} className="absolute right-3 top-1/2 -translate-y-1/2 text-[var(--muted)]" />
          <Input value={search} onChange={e => handleSearch(e.target.value)}
            className="pr-10 pl-4 py-2.5 rounded-xl"
            placeholder="ابحث عن منتج..." />
        </div>
        <Button variant="secondary" size="sm" onClick={() => setViewMode(v => v === 'cards' ? 'table' : 'cards')} className="px-3 text-xs">
          {viewMode === 'cards' ? 'جدول' : 'بطاقات'}
        </Button>
        {!targetWhId && (
          <span className="text-xs font-bold text-amber-600 bg-amber-50 px-3 py-2 rounded-xl">⚠️ اختر المخزن من القائمة الجانبية</span>
        )}
      </div>

      {/* Desktop layout */}
      <div className="hidden lg:flex flex-1 gap-3 min-h-0">
        <div className="flex-1 flex flex-col min-h-0 min-w-0">
          {search || selectedSubId ? (
            productListView(selectedSubId ? (catProducts || []) : filteredProducts)
          ) : viewMode === 'cards' ? (
            <div className="flex-1 flex flex-col min-h-0">
              <CategoryCardBrowser warehouseId={targetWhId} mode="retail" onAddProduct={handleAddProduct} />
            </div>
          ) : (
            <div className="flex-1 overflow-y-auto">
              <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-3">
                {categories?.map((cat: any) => (
                  <Button key={cat.id} onClick={() => handleCatClick(cat.id)} variant="ghost"
                    className="w-full bg-[var(--surface)] rounded-xl border border-[var(--border)] p-4 text-center hover:border-[var(--primary-border)] hover:shadow-md transition-all h-auto">
                    <p className="text-xs font-bold text-[var(--text)]">{cat.name}</p>
                  </Button>
                ))}
              </div>
            </div>
          )}
        </div>
        {cartPanel}
      </div>

      {/* Mobile layout */}
      <div className="flex lg:hidden flex-1 flex-col min-h-0">
        <div className="flex items-center gap-2 mb-2 flex-shrink-0">
          <div className="relative flex-1">
            <Search size={14} className="absolute right-3 top-1/2 -translate-y-1/2 text-[var(--muted)]" />
            <Input value={search} onChange={e => handleSearch(e.target.value)}
              className="pr-9 pl-3 py-2 rounded-xl"
              placeholder="ابحث..." />
          </div>
          <select value={targetWhId} onChange={e => handleWhChange(e.target.value)}
            className="px-2 py-2 rounded-xl border border-[var(--border)] bg-[var(--surface)] text-xs outline-none max-w-28">
            <option value="">المخزن</option>
            {warehouses?.map((w: any) => (
              <option key={w.id} value={w.id}>{w.name}</option>
            ))}
          </select>
        </div>

        {mobileTab === 'products' && (
          <div className="flex-1 flex flex-col min-h-0">
            {search || selectedSubId ? (
              productListView(selectedSubId ? (catProducts || []) : filteredProducts)
            ) : (
              <div className="flex-1 flex flex-col min-h-0">
                <CategoryCardBrowser warehouseId={targetWhId} mode="retail" onAddProduct={handleAddProduct} />
              </div>
            )}
          </div>
        )}

        {mobileTab === 'cart' && cartPanel}

        {/* Mobile tab bar */}
        <div className="flex-shrink-0 border-t border-[var(--border)] bg-[var(--surface)] flex">
          <Button onClick={() => setMobileTab('products')} variant="ghost"
            className={clsx('flex-1 py-3 flex flex-col items-center gap-0.5 text-xs font-bold transition-colors h-auto rounded-none',
              mobileTab === 'products' ? 'text-[var(--primary)]' : 'text-[var(--muted)]')}>
            <Package size={20} className="size-5" />
            <span>منتجات</span>
          </Button>
          <Button onClick={() => setMobileTab('cart')} variant="ghost"
            className={clsx('flex-1 py-3 flex flex-col items-center gap-0.5 text-xs font-bold transition-colors relative h-auto rounded-none',
              mobileTab === 'cart' ? 'text-[var(--primary)]' : 'text-[var(--muted)]')}>
            <ShoppingCart size={20} className="size-5" />
            <span>السلة</span>
            {items.length > 0 && (
              <span className="absolute top-2 right-1/2 translate-x-4 -translate-y-0.5 w-5 h-5 rounded-full bg-red-500 text-white text-xs flex items-center justify-center font-black">{items.length}</span>
            )}
          </Button>
        </div>
      </div>
    </div>
  )
}
