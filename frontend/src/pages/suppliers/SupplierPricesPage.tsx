import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { supplierPricesApi, productsApi } from '../../api/endpoints'
import toast from 'react-hot-toast'
import { Trash2, TrendingDown, Calendar } from 'lucide-react'
import { Button } from '../../components/ui/button'
import { Select } from '../../components/ui/select'
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '../../components/ui/table'

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
        <p className="text-[var(--muted)] mt-1">قارن أسعار نفس المنتج من موردين مختلفين</p>
      </div>

      {/* Product Selector */}
      <div className="card p-4">
        <label className="field-label mb-2">اختر منتج</label>
        <Select 
          value={selectedProductId} 
          onChange={e => setSelectedProductId(e.target.value)}
          className="w-full"
        >
          <option value="">-- اختر منتج --</option>
          {products?.map((p: any) => (
            <option key={p.id} value={p.id}>{p.name}</option>
          ))}
        </Select>
      </div>

      {!selectedProductId ? (
        <div className="text-center py-12 text-[var(--muted)]">
          <p>اختر منتج لمشاهدة أسعار الموردين</p>
        </div>
      ) : isLoading ? (
        <div className="text-center py-12">جاري التحميل...</div>
      ) : !priceComparison?.suppliers || priceComparison.suppliers.length === 0 ? (
        <div className="text-center py-12 text-[var(--muted)]">
          <p>لا توجد أسعار مسجلة لهذا المنتج</p>
        </div>
      ) : (
        <>
          {/* Stats Cards */}
          <div className="grid grid-cols-3 gap-4">
            <div className="bg-blue-50 rounded-xl p-4 border border-blue-200">
              <p className="text-sm text-[var(--text-soft)]">أقل سعر</p>
              <p className="text-2xl font-bold text-blue-600">{bestPrice?.toFixed(2)} ج.م</p>
              <p className="text-xs text-[var(--muted)] mt-1">{priceComparison.suppliers[0]?.supplier_name}</p>
            </div>
            <div className="bg-amber-50 rounded-xl p-4 border border-amber-200">
              <p className="text-sm text-[var(--text-soft)]">متوسط السعر</p>
              <p className="text-2xl font-bold text-amber-600">{avgPrice.toFixed(2)} ج.م</p>
              <p className="text-xs text-[var(--muted)] mt-1">{priceComparison.suppliers.length} موردين</p>
            </div>
            <div className="bg-green-50 rounded-xl p-4 border border-green-200">
              <p className="text-sm text-[var(--text-soft)]">المدخرات</p>
              <p className="text-2xl font-bold text-green-600">{savings.toFixed(2)} ج.م</p>
              <p className="text-xs text-[var(--muted)] mt-1">{((savings / avgPrice) * 100).toFixed(0)}% أقل</p>
            </div>
          </div>

          {/* Sort Options */}
          <div className="flex gap-2">
            <Button
              type="button"
              variant="ghost"
              onClick={() => setSortBy('price')}
              className={`chip h-auto hover:bg-transparent ${sortBy === 'price' ? 'chip-active' : ''}`}
            >
              <TrendingDown size={13} className="inline ml-1" /> السعر
            </Button>
            <Button
              type="button"
              variant="ghost"
              onClick={() => setSortBy('supplier')}
              className={`chip h-auto hover:bg-transparent ${sortBy === 'supplier' ? 'chip-active' : ''}`}
            >
              الموردين
            </Button>
            <Button
              type="button"
              variant="ghost"
              onClick={() => setSortBy('date')}
              className={`chip h-auto hover:bg-transparent ${sortBy === 'date' ? 'chip-active' : ''}`}
            >
              <Calendar size={13} className="inline ml-1" /> آخر شراء
            </Button>
          </div>

          {/* Supplier Prices Table */}
          <div className="card p-0 overflow-hidden">
            <div className="table-wrap !rounded-none !border-0 !shadow-none">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>الموردين</TableHead>
                  <TableHead>السعر</TableHead>
                  <TableHead>الحد الأدنى</TableHead>
                  <TableHead>آخر شراء</TableHead>
                  <TableHead>الملاحظات</TableHead>
                  <TableHead className="text-center">الإجراءات</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {sortedSuppliers().map((supplier: any) => (
                  <TableRow key={supplier.id} className="hover:bg-[var(--surface-2)] transition-colors">
                    <TableCell>
                      <div>
                        <p className="font-medium text-[var(--text)]">{supplier.supplier_name}</p>
                        <p className="text-xs text-[var(--muted)]">#{supplier.supplier_id}</p>
                      </div>
                    </TableCell>
                    <TableCell>
                      <span className={`font-bold ${
                        supplier.price === bestPrice ? 'text-green-600' : 'text-[var(--text)]'
                      }`}>
                        {supplier.price} ج.م
                      </span>
                      {supplier.price === bestPrice && <span className="text-xs text-green-600 block">✓ الأقل</span>}
                    </TableCell>
                    <TableCell className="text-center">{supplier.min_qty || '1'}</TableCell>
                    <TableCell className="text-xs text-[var(--muted)]">
                      {supplier.last_purchase_date ? 
                        new Date(supplier.last_purchase_date).toLocaleDateString('ar-EG') : 
                        'لم يتم شراء'}
                    </TableCell>
                    <TableCell className="text-xs text-[var(--muted)]">{supplier.notes || '-'}</TableCell>
                    <TableCell className="text-center">
                      <Button
                        variant="ghost"
                        size="icon-sm"
                        onClick={() => deleteMut.mutate(supplier.id)}
                        disabled={deleteMut.isPending}
                        className="text-red-600 hover:bg-red-50"
                        title="حذف"
                      >
                        <Trash2 size={16} />
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
            </div>
          </div>
        </>
      )}
    </div>
  )
}
