import Modal from '../../../components/ui/Modal'
import { Button } from '../../../components/ui/button'
import { Lock } from 'lucide-react'
import { clsx } from 'clsx'
import { Select } from '../../../components/ui/select'
import { Input } from '../../../components/ui/input'

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
          <div className="card bg-slate-50/70 p-4 space-y-2 text-sm">
            <div className="flex justify-between"><span className="text-slate-500">المبيعات</span><span className="font-bold text-green-600 tabular-nums">{Number(summary.sales_total).toLocaleString('ar-EG')} ج.م</span></div>
            <div className="flex justify-between"><span className="text-slate-500">المرتجعات</span><span className="font-bold text-amber-600 tabular-nums">{Number(summary.returns_total).toLocaleString('ar-EG')} ج.م</span></div>
            <div className="flex justify-between"><span className="text-slate-500">المصروفات</span><span className="font-bold text-red-600 tabular-nums">{Number(summary.expenses_total).toLocaleString('ar-EG')} ج.م</span></div>
            <div className="flex justify-between border-t border-slate-200 pt-2"><span className="font-semibold">الرصيد المتوقع</span><span className="font-black text-base text-[var(--primary)] tabular-nums">{Number(summary.expected_balance).toLocaleString('ar-EG')} ج.م</span></div>
          </div>
        )}
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">الرصيد الفعلي في الدرج</label>
          <Input type="number" className="text-lg font-bold" value={closingBalance} onChange={e => setClosingBalance(e.target.value)} placeholder="0.00" />
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">الفكة للغد (يبقى في الدرج)</label>
          <Input type="number" value={nextDayDrawer} onChange={e => setNextDayDrawer(e.target.value)} placeholder="0.00" />
        </div>
        {closingBalance && nextDayDrawer && (
          <div className="bg-blue-50 border border-blue-200 rounded-xl p-3 text-sm space-y-1">
            <div className="flex justify-between font-semibold text-blue-800">
              <span>المبلغ المورَّد (التوريد)</span>
              <span className="tabular-nums">{(Number(closingBalance) - Number(nextDayDrawer)).toLocaleString('ar-EG')} ج.م</span>
            </div>
            {summary && (
              <div className={clsx('flex justify-between text-xs tabular-nums', Number(closingBalance) >= Number(summary.expected_balance) ? 'text-green-600' : 'text-red-600')}>
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
            <Select className="text-sm" value={closeSafeId} onChange={e => setCloseSafeId(e.target.value)}>
              <option value="">اختر الخزنة...</option>
              {(safes as any[])?.map((s: any) => (
                <option key={s.id} value={s.id}>{s.name} — {Number(s.balance).toLocaleString('ar-EG')} ج.م</option>
              ))}
            </Select>
          </div>
          <div>
            <label className="block text-xs font-medium text-amber-700 mb-1">المدير المستلم</label>
            <Select className="text-sm" value={managerIdForClose} onChange={e => setManagerIdForClose(e.target.value)}>
              <option value="">اختر المدير...</option>
              {(allUsers as any[])?.filter((u: any) => u.is_manager).map((u: any) => (
                <option key={u.id} value={u.id}>{u.full_name}</option>
              ))}
            </Select>
          </div>
          <div>
            <label className="block text-xs font-medium text-amber-700 mb-1">كلمة مرور المدير</label>
            <Input type="password" className="text-sm" value={managerPasswordForClose}
              onChange={e => setManagerPasswordForClose(e.target.value)} placeholder="••••••••" />
          </div>
        </div>
        <div className="flex gap-3 justify-end">
          <Button variant="ghost" onClick={onClose}>إلغاء</Button>
          <Button variant="destructive" onClick={() => closeMut.mutate()} disabled={!closingBalance || Number(closingBalance) <= 0 || !managerIdForClose || !managerPasswordForClose || !closeSafeId || closeMut.isPending}>
            <Lock size={15} /> إغلاق الوردية
          </Button>
        </div>
      </div>
    </Modal>
  )
}
