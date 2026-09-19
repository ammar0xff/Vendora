import { useState, useEffect } from 'react'
import Modal from '../../components/ui/Modal'
import { Button } from '../../components/ui/button'
import { Landmark, Clock } from 'lucide-react'
import { Select } from '../../components/ui/select'

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
          <Button variant="secondary" className="flex-1" onClick={onClose}>
            إلغاء
          </Button>
          <Button
            variant="default"
            className="flex-1"
            onClick={() => onConfirm(destination, safeId)}
            disabled={isPending || (destination === 'safe' && (!safeId || loadingSafes))}
          >
            {isPending ? '...جارٍ التأكيد' : 'تأكيد التحويل'}
          </Button>
        </div>
      }>
      <div className="space-y-4">
        <div className="rounded-xl p-4 text-center" style={{ background: '#f0fdf4', border: '1px solid #bbf7d0' }}>
          <p className="text-xs font-medium mb-1 text-slate-500">مبلغ عرض السعر</p>
          <p className="text-3xl font-black" style={{ color: '#16a34a' }}>{amount.toLocaleString('ar-EG')} ج.م</p>
        </div>
        <p className="text-sm text-slate-600">في أي مكان توضع المقبوضات؟</p>

        <Button
          type="button"
          onClick={() => setDestination('drawer')}
          disabled={!hasShift}
          variant={destination === 'drawer' ? 'default' : 'outline'}
          className={`w-full flex items-center justify-start gap-3 p-4 rounded-xl border-2 text-right transition-colors h-auto ${destination === 'drawer' ? 'border-[var(--primary)] bg-[var(--primary-soft)] text-slate-800' : 'border-slate-200 hover:border-slate-300'} ${!hasShift ? 'opacity-50 cursor-not-allowed' : ''}`}
        >
          <div className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0" style={{ background: '#dbeafe', color: '#2563eb' }}>
            <Clock size={20} />
          </div>
          <div className="flex-1">
            <p className="font-bold text-slate-800">الدرج (ورديتي المفتوحة)</p>
            <p className="text-xs text-slate-500">{hasShift ? `عدد النقود في الدرج — ${currentShift.id.slice(0, 8)}` : 'لا توجد وردية مفتوحة لك في هذا الفرع'}</p>
          </div>
        </Button>

        <Button
          type="button"
          onClick={() => setDestination('safe')}
          variant={destination === 'safe' ? 'default' : 'outline'}
          className={`w-full flex items-center justify-start gap-3 p-4 rounded-xl border-2 text-right transition-colors h-auto ${destination === 'safe' ? 'border-[var(--primary)] bg-[var(--primary-soft)] text-slate-800' : 'border-slate-200 hover:border-slate-300'}`}
        >
          <div className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0" style={{ background: '#dcfce7', color: '#16a34a' }}>
            <Landmark size={20} />
          </div>
          <div>
            <p className="font-bold text-slate-800">الخزنة</p>
            <p className="text-xs text-slate-500">إيداع في أحد الخزنات المالية</p>
          </div>
        </Button>

        {destination === 'safe' && (
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">اختر الخزنة *</label>
            <Select value={safeId} onChange={e => setSafeId(e.target.value)} disabled={loadingSafes}>
              <option value="">{loadingSafes ? '...جارٍ التحميل' : 'اختر الخزنة...'}</option>
              {(safes as any[])?.map((s: any) => <option key={s.id} value={s.id}>{s.name} — {Number(s.balance).toLocaleString('ar-EG')} ج.م</option>)}
            </Select>
          </div>
        )}
      </div>
    </Modal>
  )
}