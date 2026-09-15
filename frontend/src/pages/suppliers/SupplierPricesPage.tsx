import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { supplierPricesApi, productsApi } from '../../api/endpoints'
import toast from 'react-hot-toast'
import { Trash2, TrendingDown, Calendar } from 'lucide-react'

export default function SupplierPricesPage() {
  const [selectedProductId, setSelectedProductId] = useState('')
  const [sortBy, setSortBy] = useState<'price' | 'supplier' | 'date'>('price')
  const queryClient = useQueryClient()

  const { data: products } = useQuery({
    queryKey: ['products'],
    queryFn: () => productsApi.list(),
  })

  const { data: priceComparison, isLoading } = useQuery({
    queryKey: ['supplierPrices', selectedProductId],
    queryFn: () => supplierPricesApi.getProductPrices(selectedProductId),
    enabled: !!selectedProductId,
  })

  const deleteMut = useMutation({
    mutationFn: (id: string) => supplierPricesApi.delete(id),
    onSuccess: () => {
      toast.success('تم حذف السعر')
      queryClient.invalidateQueries({ queryKey: ['supplierPrices', selectedProductId] })
    },
  })

  const sortedSuppliers = () => {
    if (!priceComparison?.suppliers) return []
    const sorted = [...priceComparison.suppliers]
    if (sortBy === 'price') {
      sorted.sort((a, b) => Number(a.price) - Number(b.price))
    } else if (sortBy === 'supplier') {
      sorted.sort((a, b) => a.supplier_name.localeCompare(b.supplier_name))
    } else if (sortBy === 'date') {
      sorted.sort((a, b) => {
        const dateA = new Date(a.last_purchase_date || 0).getTime()
        const dateB = new Date(b.last_purchase_date || 0).getTime()
        return dateB - dateA
      })
    }
    return sorted
  }

  const bestPrice = priceComparison?.suppliers?.[0]?.price
  const avgPrice = priceComparison?.suppliers ? 
    priceComparison.suppliers.reduce((sum, s) => sum + Number(s.price), 0) / priceComparison.suppliers.length : 0
  const savings = bestPrice && avgPrice ? avgPrice - bestPrice : 0

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="page-title">مقارنة أسعار الموردين</h1>
        <p className="text-slate-500 mt-1">قارن أسعار نفس المنتج من موردين مختلفين</p>
      </div>

      {/* Product Selector */}
      <div className="card p-4">
        <label className="field-label mb-2">اختر منتج</label>
        <select 
          value={selectedProductId} 
          onChange={e => setSelectedProductId(e.target.value)}
          className="input w-full"
        >
          <option value="">-- اختر منتج --</option>
          {products?.map((p: any) => (
            <option key={p.id} value={p.id}>{p.name}</option>
          ))}
        </select>
      </div>

      {!selectedProductId ? (
        <div className="text-center py-12 text-slate-400">
          <p>اختر منتج لمشاهدة أسعار الموردين</p>
        </div>
      ) : isLoading ? (
        <div className="text-center py-12">جاري التحميل...</div>
      ) : !priceComparison?.suppliers || priceComparison.suppliers.length === 0 ? (
        <div className="text-center py-12 text-slate-400">
          <p>لا توجد أسعار مسجلة لهذا المنتج</p>
        </div>
      ) : (
        <>
          {/* Stats Cards */}
          <div className="grid grid-cols-3 gap-4">
            <div className="bg-blue-50 rounded-xl p-4 border border-blue-200">
              <p className="text-sm text-slate-600">أقل سعر</p>
              <p className="text-2xl font-bold text-blue-600">{bestPrice?.toFixed(2)} ج.م</p>
              <p className="text-xs text-slate-500 mt-1">{priceComparison.suppliers[0]?.supplier_name}</p>
            </div>
            <div className="bg-amber-50 rounded-xl p-4 border border-amber-200">
              <p className="text-sm text-slate-600">متوسط السعر</p>
              <p className="text-2xl font-bold text-amber-600">{avgPrice.toFixed(2)} ج.م</p>
              <p className="text-xs text-slate-500 mt-1">{priceComparison.suppliers.length} موردين</p>
            </div>
            <div className="bg-green-50 rounded-xl p-4 border border-green-200">
              <p className="text-sm text-slate-600">المدخرات</p>
              <p className="text-2xl font-bold text-green-600">{savings.toFixed(2)} ج.م</p>
              <p className="text-xs text-slate-500 mt-1">{((savings / avgPrice) * 100).toFixed(0)}% أقل</p>
            </div>
          </div>

          {/* Sort Options */}
          <div className="flex gap-2">
            <button
              onClick={() => setSortBy('price')}
              className={`chip ${sortBy === 'price' ? 'chip-active' : ''}`}
            >
              <TrendingDown size={13} className="inline ml-1" /> السعر
            </button>
            <button
              onClick={() => setSortBy('supplier')}
              className={`chip ${sortBy === 'supplier' ? 'chip-active' : ''}`}
            >
              الموردين
            </button>
            <button
              onClick={() => setSortBy('date')}
              className={`chip ${sortBy === 'date' ? 'chip-active' : ''}`}
            >
              <Calendar size={13} className="inline ml-1" /> آخر شراء
            </button>
          </div>

          {/* Supplier Prices Table */}
          <div className="card p-0 overflow-hidden">
            <div className="table-wrap !rounded-none !border-0 !shadow-none">
            <table>
              <thead>
                <tr>
                  <th>الموردين</th>
                  <th>السعر</th>
                  <th>الحد الأدنى</th>
                  <th>آخر شراء</th>
                  <th>الملاحظات</th>
                  <th className="text-center">الإجراءات</th>
                </tr>
              </thead>
              <tbody>
                {sortedSuppliers().map((supplier: any) => (
                  <tr key={supplier.id} className="hover:bg-slate-50 transition-colors">
                    <td>
                      <div>
                        <p className="font-medium text-slate-800">{supplier.supplier_name}</p>
                        <p className="text-xs text-slate-500">#{supplier.supplier_id}</p>
                      </div>
                    </td>
                    <td>
                      <span className={`font-bold ${
                        supplier.price === bestPrice ? 'text-green-600' : 'text-slate-800'
                      }`}>
                        {supplier.price} ج.م
                      </span>
                      {supplier.price === bestPrice && <span className="text-xs text-green-600 block">✓ الأقل</span>}
                    </td>
                    <td className="text-center">{supplier.min_qty || '1'}</td>
                    <td className="text-xs text-slate-500">
                      {supplier.last_purchase_date ? 
                        new Date(supplier.last_purchase_date).toLocaleDateString('ar-EG') : 
                        'لم يتم شراء'}
                    </td>
                    <td className="text-xs text-slate-500">{supplier.notes || '-'}</td>
                    <td className="text-center">
                      <button
                        onClick={() => deleteMut.mutate(supplier.id)}
                        disabled={deleteMut.isPending}
                        className="p-1.5 rounded btn-icon text-red-600 hover:bg-red-50 transition-colors"
                        title="حذف"
                      >
                        <Trash2 size={16} />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            </div>
          </div>
        </>
      )}
    </div>
  )
}
