import Modal from '../../../components/ui/Modal'
import { Wallet } from 'lucide-react'

interface Props {
  showOpenShift: boolean
  onClose: () => void
  mainWh: any
  lastDrawer: any
  supervisorId: string
  setSupervisorId: (v: string) => void
  allUsers: any[]
  openShiftMut: any
}

export function OpenShiftModal({ showOpenShift, onClose, mainWh, lastDrawer, supervisorId, setSupervisorId, allUsers, openShiftMut }: Props) {
  return (
    <Modal open={showOpenShift} onClose={onClose} title="فتح وردية جديدة">
      <div className="space-y-4">
        <div className="bg-slate-50 rounded-xl p-4 border border-slate-200">
          <p className="text-slate-500 text-xs mb-1">الفرع</p>
          <p className="font-bold text-slate-800">🏪 {mainWh?.name || '—'}</p>
        </div>
        <div className="bg-[var(--primary-soft)] border border-[var(--primary-border)] rounded-xl p-5 text-center">
          <p className="text-slate-500 text-sm mb-1">الرصيد الافتتاحي (فكة اليوم السابق)</p>
          <p className="text-4xl font-black text-[var(--primary)] tabular-nums">
            {Number(lastDrawer?.amount || 0).toLocaleString('ar-EG')} ج.م
          </p>
          <p className="text-xs text-slate-400 mt-1">لا يمكن تعديله — يُحسب تلقائياً</p>
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">المشرف العام (اختياري)</label>
          <select className="input" value={supervisorId} onChange={e => setSupervisorId(e.target.value)}>
            <option value="">بدون مشرف</option>
            {(allUsers as any[])?.map((u: any) => (
              <option key={u.id} value={u.id}>{u.full_name}</option>
            ))}
          </select>
        </div>
        <div className="flex gap-3 justify-end">
          <button onClick={onClose} className="btn btn-ghost">إلغاء</button>
          <button onClick={() => openShiftMut.mutate()} disabled={openShiftMut.isPending || !mainWh?.id}
            className="btn btn-success">
            <Wallet size={15} /> تأكيد فتح الوردية
          </button>
        </div>
      </div>
    </Modal>
  )
}
