import { useState, useEffect } from 'react'
import Modal from '../../components/ui/Modal'
import { Landmark, Clock } from 'lucide-react'

interface Props {
  quote: any
  show: boolean
  onClose: () => void
  currentShift: any
  safes: any[]
  loadingSafes: boolean
  onConfirm: (destination: string, safeId?: string) => void
  isPending: boolean
}

export default function QuoteDestinationModal({ quote, show, onClose, currentShift, safes, loadingSafes, onConfirm, isPending }: Props) {
  const [destination, setDestination] = useState<string>('drawer')
  const [safeId, setSafeId] = useState<string>('')

  useEffect(() => {
    if (show) {
      setDestination(currentShift ? 'drawer' : 'safe')
      setSafeId('')
    }
  }, [show, currentShift])

  const hasShift = !!currentShift
  const amount = Number(quote?.net_total || quote?.total || 0)

  return (
    <Modal open={show} onClose={onClose} title="وجهة المقبوضات" size="md"
      footer={
        <div className="flex gap-3 pt-4">
          <button onClick={onClose} className="flex-1 py-2.5 rounded-xl text-sm font-bold text-slate-600 bg-slate-100 hover:bg-slate-200 transition-colors">
            إلغاء
          </button>
          <button
            onClick={() => onConfirm(destination, safeId)}
            disabled={isPending || (destination === 'safe' && (!safeId || loadingSafes))}
            className="flex-1 py-2.5 rounded-xl text-sm font-bold text-white bg-blue-600 hover:bg-blue-700 transition-colors disabled:opacity-50"
          >
            {isPending ? '...جارٍ التأكيد' : 'تأكيد التحويل'}
          </button>
        </div>
      }>
      <div className="space-y-4">
        <div className="rounded-xl p-4 text-center" style={{ background: '#f0fdf4', border: '1px solid #bbf7d0' }}>
          <p className="text-xs font-medium mb-1 text-slate-500">مبلغ عرض السعر</p>
          <p className="text-3xl font-black" style={{ color: '#16a34a' }}>{amount.toLocaleString('ar-EG')} ج.م</p>
        </div>
        <p className="text-sm text-slate-600">في أي مكان توضع المقبوضات؟</p>

        <button
          onClick={() => setDestination('drawer')}
          disabled={!hasShift}
          className={`w-full flex items-center gap-3 p-4 rounded-xl border-2 text-right transition-colors ${destination === 'drawer' ? 'border-blue-500 bg-blue-50' : 'border-slate-200 hover:border-slate-300'} ${!hasShift ? 'opacity-50 cursor-not-allowed' : ''}`}
        >
          <div className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0" style={{ background: '#dbeafe', color: '#2563eb' }}>
            <Clock size={20} />
          </div>
          <div className="flex-1">
            <p className="font-bold text-slate-800">الدرج (ورديتي المفتوحة)</p>
            <p className="text-xs text-slate-500">{hasShift ? `عدد النقود في الدرج — ${currentShift.id.slice(0, 8)}` : 'لا توجد وردية مفتوحة لك في هذا الفرع'}</p>
          </div>
        </button>

        <button
          onClick={() => setDestination('safe')}
          className={`w-full flex items-center gap-3 p-4 rounded-xl border-2 text-right transition-colors ${destination === 'safe' ? 'border-blue-500 bg-blue-50' : 'border-slate-200 hover:border-slate-300'}`}
        >
          <div className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0" style={{ background: '#dcfce7', color: '#16a34a' }}>
            <Landmark size={20} />
          </div>
          <div>
            <p className="font-bold text-slate-800">الخزنة</p>
            <p className="text-xs text-slate-500">إيداع في أحد الخزنات المالية</p>
          </div>
        </button>

        {destination === 'safe' && (
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">اختر الخزنة *</label>
            <select className="input" value={safeId} onChange={e => setSafeId(e.target.value)} disabled={loadingSafes}>
              <option value="">{loadingSafes ? '...جارٍ التحميل' : 'اختر الخزنة...'}</option>
              {(safes as any[])?.map((s: any) => <option key={s.id} value={s.id}>{s.name} — {Number(s.balance).toLocaleString('ar-EG')} ج.م</option>)}
            </select>
          </div>
        )}
      </div>
    </Modal>
  )
}