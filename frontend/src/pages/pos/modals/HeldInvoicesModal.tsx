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
            className="btn btn-primary"
            disabled={items.length === 0}
            onClick={() => { holdCurrent({ label: holdLabel, warehouse_id: mainWh?.id, shift_id: shift?.id }); setHoldLabel('') }}
          >
            تعليق الحالية
          </button>
        </div>

        {suspended.length === 0 ? (
          <div className="empty-state py-10">
            <p className="empty-title">لا توجد فواتير معلقة</p>
            <p className="empty-sub">علّق فاتورة ليتم استئنافها لاحقاً</p>
          </div>
        ) : (
          <div className="space-y-2 max-h-96 overflow-y-auto">
            {suspended.map((b: any) => {
              const sameWarehouse = !b.warehouse_id || b.warehouse_id === mainWh?.id
              const sameShift = !b.shift_id || b.shift_id === shift?.id
              const canResume = sameWarehouse && sameShift
              return (
                <div key={b.id} className="card card-hover p-3 flex items-center justify-between gap-3">
                  <div className="min-w-0">
                    <p className="font-bold text-slate-800 truncate">{b.label}</p>
                    <p className="text-xs text-slate-500">{new Date(b.created_at).toLocaleString('ar-EG')} · {b.items.length} بند</p>
                    {!canResume && (
                      <p className="text-xs text-amber-700 mt-1">لا يمكن الاستئناف: مختلف مخزن/وردية</p>
                    )}
                  </div>
                  <div className="flex items-center gap-2 flex-shrink-0">
                    <button
                      className="btn btn-success btn-sm"
                      disabled={!canResume || items.length > 0}
                      title={items.length > 0 ? 'امسح السلة الحالية أولاً' : ''}
                      onClick={() => { resume(b.id); setShowHeld(false) }}
                    >
                      استئناف
                    </button>
                    <button
                      className="btn btn-primary-soft btn-sm"
                      disabled={convertToQuotationMut.isPending}
                      onClick={() => convertToQuotationMut.mutate(b)}
                    >
                      {convertToQuotationMut.isPending ? 'جاري...' : 'عرض سعر'}
                    </button>
                    <button
                      className="btn btn-danger-soft btn-sm"
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
