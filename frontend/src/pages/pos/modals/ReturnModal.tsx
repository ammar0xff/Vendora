import Modal from '../../../components/ui/Modal'
import { Button } from '../../../components/ui/button'
import { RotateCcw, Minus, Plus } from 'lucide-react'
import { Input } from '../../../components/ui/input'

interface Props {
  showReturn: boolean
  onClose: () => void
  returnSearch: string
  setReturnSearch: (v: string) => void
  allSales: any[]
  setShowReturn: (v: boolean) => void
  setReturnSaleDetails: (v: any) => void
  setReturnQtys: (v: any) => void
  returnSaleDetails: any
  returnQtys: Record<string, number>
  returnMut: any
}

export function ReturnModal({ showReturn, onClose, returnSearch, setReturnSearch, allSales, setShowReturn, setReturnSaleDetails, setReturnQtys, returnSaleDetails, returnQtys, returnMut }: Props) {
  return (
    <>
      <Modal open={showReturn} onClose={onClose} title="اختر فاتورة للمرتجع" size="lg">
        <div className="space-y-3">
          <Input type="text" placeholder="ابحث باسم المنتج..." value={returnSearch} onChange={e => setReturnSearch(e.target.value)} autoFocus />
          <div className="space-y-2 max-h-80 overflow-y-auto">
          {!allSales?.length && <div className="empty-state py-10"><p className="empty-title">{returnSearch.trim() ? 'لا توجد فواتير بهذا المنتج' : 'لا توجد فواتير مؤكدة'}</p></div>}
          {allSales?.map((s: any) => (
            <div key={s.id} className="card card-hover p-3 flex items-center justify-between">
              <div>
                <p className="font-semibold text-slate-800">{s.customer_name || 'عميل عادي'}</p>
                <p className="text-xs text-slate-400 font-mono">{s.invoice_number} — {new Date(s.created_at).toLocaleString('ar-EG')} — {s.sale_mode === 'wholesale' ? 'جملة' : 'قطاعي'} — {s.items?.length || 0} صنف</p>
              </div>
              <Button
                variant="secondary"
                size="sm"
                onClick={() => { setShowReturn(false); setReturnSaleDetails(s); const init: Record<string,number> = {}; s.items?.forEach((i: any) => { init[i.product_id] = Number(i.qty) }); setReturnQtys(init) }}
              >
                <RotateCcw size={12} /> مرتجع
              </Button>
            </div>
          ))}
        </div>
        </div>
      </Modal>

      {/* Partial Return Item Selection Modal */}
      <Modal open={!!returnSaleDetails} onClose={() => { setReturnSaleDetails(null); setReturnQtys({}) }} title={returnSaleDetails ? `مرتجع من ${returnSaleDetails.invoice_number}` : ''} size="lg">
        {returnSaleDetails && (
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <p className="text-sm text-slate-500">اختر الكميات المراد إرجاعها</p>
              <p className="text-xs text-slate-400 font-mono">{returnSaleDetails.customer_name || 'عميل عادي'} — {new Date(returnSaleDetails.created_at).toLocaleString('ar-EG')}</p>
            </div>
            <div className="space-y-2 max-h-72 overflow-y-auto">
              {returnSaleDetails.items?.map((item: any) => (
                <div key={item.product_id} className="flex items-center justify-between p-3 rounded-xl bg-slate-50 border border-slate-100">
                  <div className="flex-1">
                    <p className="font-semibold text-sm">{item.product_name || item.product_id.slice(0, 8)}</p>
                    <p className="text-xs text-slate-400">الكمية الأصلية: {item.qty} — {Number(item.unit_price).toLocaleString('ar-EG')} ج.م</p>
                  </div>
                  <div className="flex items-center gap-1.5">
                    <Button variant="ghost" size="icon-sm" onClick={() => setReturnQtys(q => ({ ...q, [item.product_id]: Math.max(0, (q[item.product_id] || 0) - 1) }))}
                      className="bg-slate-200 hover:bg-slate-300 text-slate-600" aria-label="إنقاص"><Minus size={12} /></Button>
                    <input type="number" aria-label={`كمية مرتجعة ${item.product_name}`} min="0" max={item.qty} value={returnQtys[item.product_id] || 0}
                      onChange={e => setReturnQtys(q => ({ ...q, [item.product_id]: Math.min(Number(e.target.value), item.qty) }))}
                      className="w-14 text-center text-sm font-bold border border-slate-200 rounded-lg py-1.5 outline-none focus:border-[var(--accent)] tabular-nums" />
                    <Button variant="ghost" size="icon-sm" onClick={() => setReturnQtys(q => ({ ...q, [item.product_id]: Math.min((q[item.product_id] || 0) + 1, item.qty) }))}
                      className="bg-slate-200 hover:bg-slate-300 text-slate-600" aria-label="زيادة"><Plus size={12} /></Button>
                  </div>
                </div>
              ))}
            </div>
            <div className="bg-amber-50 border border-amber-200 rounded-xl p-3 text-sm text-amber-700">
              إجمالي المرتجع: <span className="font-black tabular-nums">
                {returnSaleDetails.items?.reduce((s: number, i: any) => s + (returnQtys[i.product_id] || 0) * Number(i.unit_price), 0).toLocaleString('ar-EG')} ج.م
              </span>
            </div>
            <div className="flex gap-3 justify-end">
              <Button variant="ghost" onClick={() => { setReturnSaleDetails(null); setReturnQtys({}) }}>إلغاء</Button>
              <Button variant="secondary" onClick={() => returnMut.mutate()}
                disabled={Object.values(returnQtys).every(v => v === 0) || returnMut.isPending}>
                <RotateCcw size={14} /> تأكيد المرتجع
              </Button>
            </div>
          </div>
        )}
      </Modal>
    </>
  )
}
