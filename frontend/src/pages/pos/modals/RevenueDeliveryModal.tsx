import Modal from '../../../components/ui/Modal'
import { Landmark } from 'lucide-react'

interface Props {
  showRevenueDelivery: boolean
  onClose: () => void
  summary: any
  revenueAmount: string
  setRevenueAmount: (v: string) => void
  revenueSafeId: string
  setRevenueSafeId: (v: string) => void
  revenueNotes: string
  setRevenueNotes: (v: string) => void
  revenueManagerId: string
  setRevenueManagerId: (v: string) => void
  revenueManagerPassword: string
  setRevenueManagerPassword: (v: string) => void
  allUsers: any[]
  safes: any[]
  revenueMut: any
}

export function RevenueDeliveryModal({ showRevenueDelivery, onClose, summary, revenueAmount, setRevenueAmount, revenueSafeId, setRevenueSafeId, revenueNotes, setRevenueNotes, revenueManagerId, setRevenueManagerId, revenueManagerPassword, setRevenueManagerPassword, allUsers, safes, revenueMut }: Props) {
  return (
    <Modal open={showRevenueDelivery} onClose={onClose} title="توريد إيرادات إلى الخزنة">
      <div className="space-y-4">
        <div className="rounded-xl p-4 text-center" style={{ background: '#eff6ff', border: '1px solid #bfdbfe' }}>
          <p className="text-xs font-medium mb-1" style={{ color: '#2563eb' }}>الرصيد النقدي المتوقع في الدرج</p>
          <p className="text-3xl font-black" style={{ color: '#2563eb' }}>{Number(summary?.cash_in_drawer ?? 0).toLocaleString('ar-EG')} ج.م</p>
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">المبلغ المسلَّم *</label>
          <input type="number" className="input" value={revenueAmount} onChange={e => setRevenueAmount(e.target.value)} placeholder="0.00" autoFocus />
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">الخزنة المستقبِلة *</label>
          <select className="input" value={revenueSafeId} onChange={e => setRevenueSafeId(e.target.value)}>
            <option value="">اختر الخزنة...</option>
            {(safes as any[])?.map((s: any) => <option key={s.id} value={s.id}>{s.name} — {Number(s.balance).toLocaleString('ar-EG')} ج.م</option>)}
          </select>
        </div>
        <input className="input" value={revenueNotes} onChange={e => setRevenueNotes(e.target.value)} placeholder="ملاحظات (اختياري)" />
        <div className="border-t border-slate-200 pt-4">
          <p className="text-xs font-bold text-slate-500 mb-3">توقيع المدير</p>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-slate-600 mb-1">المدير *</label>
              <select className="input" value={revenueManagerId} onChange={e => setRevenueManagerId(e.target.value)}>
                <option value="">اختر مديراً...</option>
                {(allUsers as any[])?.filter((u: any) => u.is_manager).map((u: any) => <option key={u.id} value={u.id}>{u.full_name}</option>)}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-600 mb-1">كلمة مرور المدير *</label>
              <input type="password" className="input" value={revenueManagerPassword} onChange={e => setRevenueManagerPassword(e.target.value)} placeholder="••••••" />
            </div>
          </div>
        </div>
        <div className="flex gap-3 justify-end">
          <button onClick={onClose} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
          <button onClick={() => revenueMut.mutate()} disabled={revenueMut.isPending || !revenueAmount || !revenueSafeId || !revenueManagerId || !revenueManagerPassword}
            className="px-5 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50 flex items-center gap-2"
            style={{ background: '#2563eb' }}>
            <Landmark size={15} /> تأكيد التوريد
          </button>
        </div>
      </div>
    </Modal>
  )
}
