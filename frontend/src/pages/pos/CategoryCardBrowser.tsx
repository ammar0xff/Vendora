import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { ChevronRight, Package, Layers, Grid3X3, Box, ShoppingCart } from 'lucide-react'
import { productsApi, categoriesApi, subcategoriesApi } from '../../api/endpoints'
import { stockApi } from '../../api/endpoints'

const CAT_COLORS = [
  'from-blue-500 to-blue-600', 'from-emerald-500 to-emerald-600', 'from-amber-500 to-amber-600',
  'from-rose-500 to-rose-600', 'from-violet-500 to-violet-600', 'from-cyan-500 to-cyan-600',
  'from-orange-500 to-orange-600', 'from-teal-500 to-teal-600', 'from-pink-500 to-pink-600',
  'from-indigo-500 to-indigo-600', 'from-lime-500 to-lime-600', 'from-red-500 to-red-600',
]

function catColor(i: number) { return CAT_COLORS[i % CAT_COLORS.length] }

export default function CategoryCardBrowser({
  warehouseId, mode, onAddProduct,
}: {
  warehouseId?: string
  mode: 'retail' | 'wholesale'
  onAddProduct: (p: any) => void
}) {
  const [selectedCatId, setSelectedCatId] = useState<string | null>(null)
  const [selectedSubId, setSelectedSubId] = useState<string | null>(null)

  const { data: categories } = useQuery({ queryKey: ['categories'], queryFn: categoriesApi.list })
  const { data: subcategories } = useQuery({ queryKey: ['subcategories'], queryFn: subcategoriesApi.list })

  const { data: productsRaw, isLoading: loadingProducts } = useQuery({
    queryKey: ['card-products', selectedSubId],
    queryFn: () => productsApi.list({ subcategory_id: selectedSubId! }),
    enabled: !!selectedSubId,
  })
  const products = Array.isArray(productsRaw) ? productsRaw : (productsRaw?.items ?? [])

  const { data: stockMap } = useQuery({
    queryKey: ['card-stock', warehouseId, products.map((p: any) => p.id).join(',') ?? ''],
    queryFn: () => stockApi.balanceBulk(warehouseId!, products.map((p: any) => p.id)),
    enabled: !!warehouseId && !!products.length,
  })

  const getSubsForCat = (catId: string) => (subcategories as any[])?.filter((s: any) => s.category_id === catId) || []
  const selectedCat = (categories as any[])?.find((c: any) => c.id === selectedCatId)
  const selectedSub = (subcategories as any[])?.find((s: any) => s.id === selectedSubId)
  const subsOfSelected = selectedCatId ? getSubsForCat(selectedCatId) : []

  const handleBack = () => {
    if (selectedSubId) { setSelectedSubId(null); return }
    if (selectedCatId) { setSelectedCatId(null); return }
  }

  const handleCatClick = (catId: string) => {
    const subs = getSubsForCat(catId)
    setSelectedCatId(catId)
    if (subs.length === 0) setSelectedSubId('__all__')
    else setSelectedSubId(null)
  }

  if (selectedSubId) {
    const subProducts = loadingProducts ? [] : (products || []).filter((p: any) => {
      const q = p.stock_status === 'untracked' ? null : (stockMap?.[p.id] ?? null)
      return q === null || q > 0
    })

    return (
      <div className="flex flex-col h-full">
        <div className="flex items-center gap-2 mb-3 flex-shrink-0">
          <button onClick={handleBack}
            className="flex items-center gap-1 px-2.5 py-1.5 rounded-lg text-xs font-bold bg-slate-100 text-slate-600 hover:bg-slate-200 transition-colors">
            <ChevronRight size={14} /> رجوع
          </button>
          <div className="text-xs text-slate-400">/</div>
          <span className="text-xs font-bold text-slate-600">{selectedCat?.name}</span>
          <div className="text-xs text-slate-400">/</div>
          <span className="text-xs font-bold text-slate-800">{selectedSub?.name || 'الكل'}</span>
        </div>

        {loadingProducts ? (
          <div className="flex-1 flex items-center justify-center">
            <div className="text-sm text-slate-400 animate-pulse">جاري تحميل المنتجات...</div>
          </div>
        ) : subProducts.length === 0 ? (
          <div className="flex-1 flex items-center justify-center text-slate-400 text-sm">لا توجد منتجات</div>
        ) : (
          <div className="flex-1 overflow-y-auto">
            <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-3 xl:grid-cols-4 gap-2.5">
              {subProducts.map((p: any) => {
                const price = mode === 'wholesale' ? Number(p.wholesale_price) || Number(p.retail_price) : Number(p.retail_price)
                const qty = p.stock_status === 'untracked' ? null : (stockMap?.[p.id] ?? null)
                return (
                  <button key={p.id} onClick={() => onAddProduct(p)}
                    className="bg-white rounded-xl border border-slate-200 p-3 text-right hover:border-blue-300 hover:shadow-md transition-all active:scale-95 flex flex-col">
                    <div className="flex items-start justify-between mb-1.5">
                      <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-blue-100 to-blue-200 flex items-center justify-center flex-shrink-0">
                        <Package size={14} className="text-blue-600" />
                      </div>
                      {qty != null && (
                        <span className={`text-xs font-bold px-1.5 py-0.5 rounded-md ${
                          qty <= 0 ? 'bg-red-100 text-red-600' :
                          qty <= 5 ? 'bg-amber-100 text-amber-700' :
                          'bg-green-100 text-green-700'
                        }`}>{qty}</span>
                      )}
                    </div>
                    <p className="text-xs font-bold text-slate-800 leading-tight line-clamp-2 mb-0.5">{p.name}</p>
                    {p.company && <p className="text-[10px] text-slate-400 mb-1.5">{p.company}</p>}
                    {p.shelf_number && <p className="text-[10px] font-bold text-indigo-500 mb-1.5">الرف: {p.shelf_number}</p>}
                    <div className="mt-auto">
                      <p className="text-sm font-black leading-none" style={{ color: '#c8a84b' }}>
                        {price.toLocaleString('ar-EG')} <span className="text-[10px] font-normal">ج.م</span>
                      </p>
                    </div>
                  </button>
                )
              })}
            </div>
          </div>
        )}
      </div>
    )
  }

  if (selectedCatId) {
    return (
      <div className="flex flex-col h-full">
        <div className="flex items-center gap-2 mb-3 flex-shrink-0">
          <button onClick={handleBack}
            className="flex items-center gap-1 px-2.5 py-1.5 rounded-lg text-xs font-bold bg-slate-100 text-slate-600 hover:bg-slate-200 transition-colors">
            <ChevronRight size={14} /> رجوع
          </button>
          <div className="text-xs text-slate-400">/</div>
          <span className="text-xs font-bold text-slate-800">{selectedCat?.name}</span>
        </div>

        <div className="flex-1 overflow-y-auto">
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-3">
            {subsOfSelected.map((sub: any, i: number) => (
              <button key={sub.id} onClick={() => setSelectedSubId(sub.id)}
                className="bg-white rounded-xl border border-slate-200 p-4 text-center hover:border-blue-300 hover:shadow-md transition-all active:scale-95">
                <div className={`w-12 h-12 mx-auto rounded-xl bg-gradient-to-br ${catColor(i)} flex items-center justify-center mb-2`}>
                  <Layers size={18} className="text-white" />
                </div>
                <p className="text-xs font-bold text-slate-700 leading-tight line-clamp-2">{sub.name}</p>
              </button>
            ))}
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="flex flex-col h-full">
      <div className="flex-1 overflow-y-auto">
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-3">
          {(categories as any[])?.map((cat: any, i: number) => {
            const subs = getSubsForCat(cat.id)
            return (
              <button key={cat.id} onClick={() => handleCatClick(cat.id)}
                className="bg-white rounded-xl border border-slate-200 p-4 text-right hover:border-blue-300 hover:shadow-md transition-all active:scale-95">
                <div className={`w-12 h-12 rounded-xl bg-gradient-to-br ${catColor(i)} flex items-center justify-center mb-2`}>
                  <Grid3X3 size={18} className="text-white" />
                </div>
                <p className="text-xs font-bold text-slate-700 leading-tight line-clamp-2 mb-0.5">{cat.name}</p>
                <p className="text-[10px] text-slate-400">{subs.length || 0} قسم</p>
              </button>
            )
          })}
        </div>
      </div>
    </div>
  )
}
