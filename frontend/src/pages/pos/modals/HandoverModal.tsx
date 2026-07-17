import Modal from '../../../components/ui/Modal'
import { ArrowLeftRight } from 'lucide-react'

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
          <div className="bg-blue-50 border border-blue-200 rounded-xl p-4">
            <p className="text-sm text-blue-700 font-semibold">الرصيد الحالي للتسليم</p>
            <p className="text-2xl font-black text-blue-800 mt-1">{Number(summary.expected_balance).toLocaleString('ar-EG')} ج.م</p>
          </div>
        )}
        <div className="bg-amber-50 border border-amber-200 rounded-xl p-3 text-sm text-amber-700">
          🔐 يجب على الموظف المستلم إدخال بياناته لتأكيد الاستلام
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">اسم المستخدم للموظف المستلم</label>
          <input className="input" value={handoverUsername} onChange={e => setHandoverUsername(e.target.value)} placeholder="username" />
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">كلمة المرور</label>
          <input type="password" className="input" value={handoverPassword} onChange={e => setHandoverPassword(e.target.value)} placeholder="••••••••" />
        </div>
        <div className="flex gap-3 justify-end">
          <button onClick={onClose} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
          <button onClick={() => handoverMut.mutate()} disabled={!handoverUsername || !handoverPassword || handoverMut.isPending}
            className="px-5 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50 flex items-center gap-2"
            style={{ background: '#c8a84b', color: '#1e3a5f' }}>
            <ArrowLeftRight size={15} /> تأكيد التسليم
          </button>
        </div>
      </div>
    </Modal>
  )
}
