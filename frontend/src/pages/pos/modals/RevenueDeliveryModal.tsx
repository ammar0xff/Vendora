import Modal from '../../../components/ui/Modal'
import { Button } from '../../../components/ui/button'
import { Landmark } from 'lucide-react'
import { Input } from '../../../components/ui/input'
import { Select } from '../../../components/ui/select'

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
        <div className="rounded-xl p-5 text-center bg-[var(--primary-soft)] border border-[var(--primary-border)]">
          <p className="text-xs font-medium mb-1 text-[var(--primary)]">الرصيد النقدي المتوقع في الدرج</p>
          <p className="text-3xl font-black text-[var(--primary)] tabular-nums">{Number(summary?.cash_in_drawer ?? 0).toLocaleString('ar-EG')} ج.م</p>
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">المبلغ المسلَّم *</label>
 <Input type="number" value={revenueAmount} onChange={e => setRevenueAmount(e.target.value)} placeholder="0.00" autoFocus/>
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">الخزنة المستقبِلة *</label>
          <Select value={revenueSafeId} onChange={e => setRevenueSafeId(e.target.value)}>
            <option value="">اختر الخزنة...</option>
            {(safes as any[])?.map((s: any) => <option key={s.id} value={s.id}>{s.name} — {Number(s.balance).toLocaleString('ar-EG')} ج.م</option>)}
          </Select>
        </div>
 <Input value={revenueNotes} onChange={e => setRevenueNotes(e.target.value)} placeholder="ملاحظات (اختياري)"/>
        <div className="border-t border-slate-200 pt-4">
          <p className="text-xs font-bold text-slate-500 mb-3">توقيع المدير</p>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-slate-600 mb-1">المدير *</label>
              <Select value={revenueManagerId} onChange={e => setRevenueManagerId(e.target.value)}>
                <option value="">اختر مديراً...</option>
                {(allUsers as any[])?.filter((u: any) => u.is_manager).map((u: any) => <option key={u.id} value={u.id}>{u.full_name}</option>)}
              </Select>
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-600 mb-1">كلمة مرور المدير *</label>
 <Input type="password" value={revenueManagerPassword} onChange={e => setRevenueManagerPassword(e.target.value)} placeholder="••••••"/>
            </div>
          </div>
        </div>
        <div className="flex gap-3 justify-end">
          <Button variant="ghost" onClick={onClose}>إلغاء</Button>
          <Button onClick={() => revenueMut.mutate()} disabled={revenueMut.isPending || !revenueAmount || !revenueSafeId || !revenueManagerId || !revenueManagerPassword}>
            <Landmark size={15} /> تأكيد التوريد
          </Button>
        </div>
      </div>
    </Modal>
  )
}
