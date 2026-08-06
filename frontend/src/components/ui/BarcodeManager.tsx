import { useState } from 'react'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { productsApi } from '../../api/endpoints'
import toast from 'react-hot-toast'
import { Trash2, Star, Plus } from 'lucide-react'

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
        <label className="block text-sm font-medium text-slate-600">الأرمز الشريطية</label>
        <button
          type="button"
          onClick={() => setIsAdding(!isAdding)}
          className="text-xs px-2 py-1 rounded bg-blue-100 text-blue-600 font-medium flex items-center gap-1"
        >
          <Plus size={14} /> جديد
        </button>
      </div>

      {isAdding && (
        <div className="flex gap-2">
          <input
            type="text"
            value={newBarcode}
            onChange={e => setNewBarcode(e.target.value)}
            onKeyDown={handleKey}
            placeholder="أدخل الرمز الشريطي..."
            className="input flex-1"
            autoFocus
          />
          <button type="button" onClick={handleAdd} disabled={addMut.isPending} className="px-3 py-2 bg-blue-600 text-white rounded text-sm font-medium">
            {addMut.isPending ? '...' : 'إضافة'}
          </button>
          <button type="button" onClick={() => { setIsAdding(false); setNewBarcode('') }} className="px-3 py-2 bg-slate-200 text-slate-600 rounded text-sm font-medium">
            إلغاء
          </button>
        </div>
      )}

      {barcodes.length === 0 ? (
        <p className="text-sm text-slate-400">لا توجد أرمز شريطية</p>
      ) : (
        <div className="space-y-2">
          {barcodes.map((bc: any) => (
            <div key={bc.id} className="flex items-center justify-between p-2 bg-slate-50 rounded border border-slate-200">
              <div className="flex items-center gap-2 flex-1">
                {bc.is_primary && <Star size={14} className="text-amber-500 fill-amber-500" />}
                <code className="text-sm font-mono">{bc.barcode}</code>
              </div>
              <div className="flex gap-1">
                {!bc.is_primary && (
                  <button
                    type="button"
                    onClick={() => setPrimaryMut.mutate(bc.id)}
                    disabled={setPrimaryMut.isPending}
                    className="p-1 hover:bg-slate-200 rounded text-slate-600"
                    title="اجعله الرمز الأساسي"
                  >
                    <Star size={14} />
                  </button>
                )}
                <button
                  type="button"
                  onClick={() => deleteMut.mutate(bc.id)}
                  disabled={deleteMut.isPending}
                  className="p-1 hover:bg-red-100 rounded text-red-600"
                  title="حذف"
                >
                  <Trash2 size={14} />
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
