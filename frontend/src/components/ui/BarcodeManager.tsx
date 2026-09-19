import { useState } from 'react'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { productsApi } from '../../api/endpoints'
import toast from 'react-hot-toast'
import { Trash2, Star, Plus } from 'lucide-react'
import { Button } from './button'
import { Input } from './input'

export default function BarcodeManager({ productId, barcodes = [] }: any) {
  const [newBarcode, setNewBarcode] = useState('')
  const [isAdding, setIsAdding] = useState(false)
  const queryClient = useQueryClient()

  const addMut = useMutation({
    mutationFn: (data: any) => productsApi.addBarcode(productId, data),
    onSuccess: () => {
      toast.success('تم إضافة الرمز الشريطي')
      setNewBarcode('')
      setIsAdding(false)
      queryClient.invalidateQueries({ queryKey: ['product', productId] })
    },
    onError: (err: any) => toast.error(err.response?.data?.detail || 'خطأ'),
  })

  const setPrimaryMut = useMutation({
    mutationFn: (barcodeId: string) =>
      productsApi.updateBarcode(barcodeId, { barcode: barcodes.find((b: any) => b.id === barcodeId)?.barcode, is_primary: true }),
    onSuccess: () => {
      toast.success('تم تعيين الرمز الأساسي')
      queryClient.invalidateQueries({ queryKey: ['product', productId] })
    },
  })

  const deleteMut = useMutation({
    mutationFn: (barcodeId: string) => productsApi.deleteBarcode(barcodeId),
    onSuccess: () => {
      toast.success('تم حذف الرمز الشريطي')
      queryClient.invalidateQueries({ queryKey: ['product', productId] })
    },
  })

  const handleAdd = () => {
    if (!newBarcode.trim()) {
      toast.error('أدخل رمز شريطي')
      return
    }
    addMut.mutate({ barcode: newBarcode, is_primary: barcodes.length === 0 })
  }

  const handleKey = (e: any) => {
    e.stopPropagation()
    if (e.key === 'Enter') {
      e.preventDefault()
      handleAdd()
    }
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between">
        <label className="block text-sm font-medium text-[var(--text-soft)]">الأرمز الشريطية</label>
        <Button
          type="button"
          variant="secondary"
          size="sm"
          onClick={() => setIsAdding(!isAdding)}
        >
          <Plus size={14} /> جديد
        </Button>
      </div>

      {isAdding && (
        <div className="flex gap-2">
          <Input
            type="text"
            value={newBarcode}
            onChange={e => setNewBarcode(e.target.value)}
            onKeyDown={handleKey}
            placeholder="أدخل الرمز الشريطي..."
            className="flex-1"
            autoFocus
          />
          <Button type="button" size="sm" onClick={handleAdd} disabled={addMut.isPending}>
            {addMut.isPending ? '...' : 'إضافة'}
          </Button>
          <Button type="button" variant="ghost" size="sm" onClick={() => { setIsAdding(false); setNewBarcode('') }}>
            إلغاء
          </Button>
        </div>
      )}

      {barcodes.length === 0 ? (
        <p className="text-sm text-[var(--muted)]">لا توجد أرمز شريطية</p>
      ) : (
        <div className="space-y-2">
          {barcodes.map((bc: any) => (
            <div key={bc.id} className="flex items-center justify-between p-2 bg-[var(--surface-2)] rounded border border-[var(--border)]">
              <div className="flex items-center gap-2 flex-1">
                {bc.is_primary && <Star size={14} className="text-amber-500 fill-amber-500" />}
                <code className="text-sm font-mono">{bc.barcode}</code>
              </div>
              <div className="flex gap-1">
                {!bc.is_primary && (
                  <Button
                    type="button"
                    variant="ghost"
                    size="icon"
                    className="size-7"
                    onClick={() => setPrimaryMut.mutate(bc.id)}
                    disabled={setPrimaryMut.isPending}
                    title="اجعله الرمز الأساسي"
                  >
                    <Star size={14} />
                  </Button>
                )}
                <Button
                  type="button"
                  variant="ghost"
                  size="icon"
                  className="size-7 text-destructive hover:text-destructive"
                  onClick={() => deleteMut.mutate(bc.id)}
                  disabled={deleteMut.isPending}
                  title="حذف"
                >
                  <Trash2 size={14} />
                </Button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
