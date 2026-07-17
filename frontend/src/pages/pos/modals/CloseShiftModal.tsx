import Modal from '../../../components/ui/Modal'
import { Lock } from 'lucide-react'
import { clsx } from 'clsx'

interface Props {
  showClose: boolean
  onClose: () => void
  summary: any
  closingBalance: string
  setClosingBalance: (v: string) => void
  nextDayDrawer: string
  setNextDayDrawer: (v: string) => void
  closeSafeId: string
  setCloseSafeId: (v: string) => void
  managerIdForClose: string
  setManagerIdForClose: (v: string) => void
  managerPasswordForClose: string
  setManagerPasswordForClose: (v: string) => void
  allUsers: any[]
  safes: any[]
  closeMut: any
}

export function CloseShiftModal({ showClose, onClose, summary, closingBalance, setClosingBalance, nextDayDrawer, setNextDayDrawer, closeSafeId, setCloseSafeId, managerIdForClose, setManagerIdForClose, managerPasswordForClose, setManagerPasswordForClose, allUsers, safes, closeMut }: Props) {
  return (
    <Modal open={showClose} onClose={onClose} title="إغلاق الوردية">
      <div className="space-y-4">
        {summary && (
          <div className="bg-slate-50 rounded-xl p-4 space-y-2 text-sm">
            <div className="flex justify-between"><span className="text-slate-500">المبيعات</span><span className="font-bold text-green-700">{Number(summary.sales_total).toLocaleString('ar-EG')} ج.م</span></div>
            <div className="flex justify-between"><span className="text-slate-500">المرتجعات</span><span className="font-bold text-amber-600">{Number(summary.returns_total).toLocaleString('ar-EG')} ج.م</span></div>
            <div className="flex justify-between"><span className="text-slate-500">المصروفات</span><span className="font-bold text-red-600">{Number(summary.expenses_total).toLocaleString('ar-EG')} ج.م</span></div>
            <div className="flex justify-between border-t border-slate-200 pt-2"><span className="font-semibold">الرصيد المتوقع</span><span className="font-black text-base">{Number(summary.expected_balance).toLocaleString('ar-EG')} ج.م</span></div>
          </div>
        )}
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">الرصيد الفعلي في الدرج</label>
          <input type="number" className="input text-lg font-bold" value={closingBalance} onChange={e => setClosingBalance(e.target.value)} placeholder="0.00" />
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">الفكة للغد (يبقى في الدرج)</label>
          <input type="number" className="input" value={nextDayDrawer} onChange={e => setNextDayDrawer(e.target.value)} placeholder="0.00" />
        </div>
        {closingBalance && nextDayDrawer && (
          <div className="bg-blue-50 border border-blue-200 rounded-xl p-3 text-sm space-y-1">
            <div className="flex justify-between font-semibold text-blue-800">
              <span>المبلغ المورَّد (التوريد)</span>
              <span>{(Number(closingBalance) - Number(nextDayDrawer)).toLocaleString('ar-EG')} ج.م</span>
            </div>
            {summary && (
              <div className={clsx('flex justify-between text-xs', Number(closingBalance) >= Number(summary.expected_balance) ? 'text-green-600' : 'text-red-600')}>
                <span>الفرق عن المتوقع</span>
                <span>{(Number(closingBalance) - Number(summary.expected_balance)).toLocaleString('ar-EG')} ج.م</span>
              </div>
            )}
          </div>
        )}
        {/* Manager verification */}
        <div className="bg-amber-50 border border-amber-200 rounded-xl p-4 space-y-3">
          <p className="text-sm font-bold text-amber-800 flex items-center gap-2">🔐 يجب على المدير تأكيد استلام التوريد</p>
          <div>
            <label className="block text-xs font-medium text-amber-700 mb-1">توريد الدرج إلى خزنة *</label>
            <select className="input text-sm" value={closeSafeId} onChange={e => setCloseSafeId(e.target.value)}>
              <option value="">اختر الخزنة...</option>
              {(safes as any[])?.map((s: any) => (
                <option key={s.id} value={s.id}>{s.name} — {Number(s.balance).toLocaleString('ar-EG')} ج.م</option>
              ))}
            </select>
          </div>
          <div>
            <label className="block text-xs font-medium text-amber-700 mb-1">المدير المستلم</label>
            <select className="input text-sm" value={managerIdForClose} onChange={e => setManagerIdForClose(e.target.value)}>
              <option value="">اختر المدير...</option>
              {(allUsers as any[])?.filter((u: any) => u.is_manager).map((u: any) => (
                <option key={u.id} value={u.id}>{u.full_name}</option>
              ))}
            </select>
          </div>
          <div>
            <label className="block text-xs font-medium text-amber-700 mb-1">كلمة مرور المدير</label>
            <input type="password" className="input text-sm" value={managerPasswordForClose}
              onChange={e => setManagerPasswordForClose(e.target.value)} placeholder="••••••••" />
          </div>
        </div>
        <div className="flex gap-3 justify-end">
          <button onClick={onClose} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
          <button onClick={() => closeMut.mutate()} disabled={!closingBalance || Number(closingBalance) <= 0 || !managerIdForClose || !managerPasswordForClose || !closeSafeId || closeMut.isPending}
            className="px-5 py-2 rounded-xl text-sm font-bold text-white bg-red-600 hover:bg-red-700 disabled:opacity-50 flex items-center gap-2">
            <Lock size={15} /> إغلاق الوردية
          </button>
        </div>
      </div>
    </Modal>
  )
}
