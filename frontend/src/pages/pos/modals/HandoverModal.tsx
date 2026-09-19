import Modal from '../../../components/ui/Modal'
import { Button } from '../../../components/ui/button'
import { ArrowLeftRight } from 'lucide-react'
import { Input } from '../../../components/ui/input'

interface Props {
  showHandover: boolean
  onClose: () => void
  summary: any
  handoverUsername: string
  setHandoverUsername: (v: string) => void
  handoverPassword: string
  setHandoverPassword: (v: string) => void
  handoverMut: any
}

export function HandoverModal({ showHandover, onClose, summary, handoverUsername, setHandoverUsername, handoverPassword, setHandoverPassword, handoverMut }: Props) {
  return (
    <Modal open={showHandover} onClose={onClose} title="تسليم الدرج لموظف آخر">
      <div className="space-y-4">
        {summary && (
          <div className="bg-[var(--primary-soft)] border border-[var(--primary-border)] rounded-xl p-4">
            <p className="text-sm font-semibold text-[var(--primary)]">الرصيد الحالي للتسليم</p>
            <p className="text-2xl font-black text-[var(--primary-strong)] mt-1 tabular-nums">{Number(summary.expected_balance).toLocaleString('ar-EG')} ج.م</p>
          </div>
        )}
        <div className="bg-amber-50 border border-amber-200 rounded-xl p-3 text-sm text-amber-700">
          🔐 يجب على الموظف المستلم إدخال بياناته لتأكيد الاستلام
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">اسم المستخدم للموظف المستلم</label>
 <Input value={handoverUsername} onChange={e => setHandoverUsername(e.target.value)} placeholder="username"/>
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">كلمة المرور</label>
 <Input type="password" value={handoverPassword} onChange={e => setHandoverPassword(e.target.value)} placeholder="••••••••"/>
        </div>
        <div className="flex gap-3 justify-end">
          <Button variant="ghost" onClick={onClose}>إلغاء</Button>
          <Button variant="secondary" onClick={() => handoverMut.mutate()} disabled={!handoverUsername || !handoverPassword || handoverMut.isPending}>
            <ArrowLeftRight size={15} /> تأكيد التسليم
          </Button>
        </div>
      </div>
    </Modal>
  )
}
