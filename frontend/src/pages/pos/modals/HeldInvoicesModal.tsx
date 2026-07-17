import Modal from '../../../components/ui/Modal'

interface Props {
  showHeld: boolean
  onClose: () => void
  holdLabel: string
  setHoldLabel: (v: string) => void
  suspended: any[]
  items: any[]
  mainWh: any
  shift: any
  holdCurrent: (opts: any) => void
  resume: (id: string) => void
  deleteHeld: (id: string) => void
  convertToQuotationMut: any
  setShowHeld: (v: boolean) => void
}

export function HeldInvoicesModal({ showHeld, onClose, holdLabel, setHoldLabel, suspended, items, mainWh, shift, holdCurrent, resume, deleteHeld, convertToQuotationMut, setShowHeld }: Props) {
  return (
    <Modal open={showHeld} onClose={onClose} title="الفواتير المعلقة" size="lg">
      <div className="space-y-3">
        <div className="flex gap-2">
          <input
            className="input flex-1"
            placeholder="اسم الفاتورة (اختياري)"
            value={holdLabel}
            onChange={e => setHoldLabel(e.target.value)}
          />
          <button
            className="px-4 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50"
            style={{ background: '#1e3a5f' }}
            disabled={items.length === 0}
            onClick={() => { holdCurrent({ label: holdLabel, warehouse_id: mainWh?.id, shift_id: shift?.id }); setHoldLabel('') }}
          >
            تعليق الحالية
          </button>
        </div>

        {suspended.length === 0 ? (
          <div className="text-center py-10 text-slate-400">لا توجد فواتير معلقة</div>
        ) : (
          <div className="space-y-2 max-h-96 overflow-y-auto">
            {suspended.map((b: any) => {
              const sameWarehouse = !b.warehouse_id || b.warehouse_id === mainWh?.id
              const sameShift = !b.shift_id || b.shift_id === shift?.id
              const canResume = sameWarehouse && sameShift
              return (
                <div key={b.id} className="p-3 rounded-xl border border-slate-200 bg-white flex items-center justify-between gap-3">
                  <div className="min-w-0">
                    <p className="font-bold text-slate-800 truncate">{b.label}</p>
                    <p className="text-xs text-slate-500">{new Date(b.created_at).toLocaleString('ar-EG')} · {b.items.length} بند</p>
                    {!canResume && (
                      <p className="text-xs text-amber-700 mt-1">لا يمكن الاستئناف: مختلف مخزن/وردية</p>
                    )}
                  </div>
                  <div className="flex items-center gap-2 flex-shrink-0">
                    <button
                      className="px-3 py-2 rounded-xl text-xs font-bold text-white disabled:opacity-50"
                      style={{ background: '#16a34a' }}
                      disabled={!canResume || items.length > 0}
                      title={items.length > 0 ? 'امسح السلة الحالية أولاً' : ''}
                      onClick={() => { resume(b.id); setShowHeld(false) }}
                    >
                      استئناف
                    </button>
                    <button
                      className="px-3 py-2 rounded-xl text-xs font-bold disabled:opacity-50"
                      style={{ background: '#7c3aed20', color: '#7c3aed' }}
                      disabled={convertToQuotationMut.isPending}
                      onClick={() => convertToQuotationMut.mutate(b)}
                    >
                      {convertToQuotationMut.isPending ? 'جاري...' : 'عرض سعر'}
                    </button>
                    <button
                      className="px-3 py-2 rounded-xl text-xs font-bold bg-red-50 text-red-600 border border-red-200"
                      onClick={() => deleteHeld(b.id)}
                    >
                      حذف
                    </button>
                  </div>
                </div>
              )
            })}
          </div>
        )}
      </div>
    </Modal>
  )
}
