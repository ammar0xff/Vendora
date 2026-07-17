import Modal from '../../../components/ui/Modal'
import toast from 'react-hot-toast'

interface Props {
  showSplitModal: boolean
  onClose: () => void
  splitMethod: string
  setSplitMethod: (v: string) => void
  splitAmount: string
  setSplitAmount: (v: string) => void
  splitWalletId: string
  setSplitWalletId: (v: string) => void
  wallets: any[]
  total: () => number
  splitPayments: { method: string; amount: number; walletId?: string }[]
  setSplitPayments: (fn: any) => void
  setShowSplitModal: (v: boolean) => void
}

export function SplitPaymentModal({ showSplitModal, onClose, splitMethod, setSplitMethod, splitAmount, setSplitAmount, splitWalletId, setSplitWalletId, wallets, total, splitPayments, setSplitPayments, setShowSplitModal }: Props) {
  return (
    <Modal open={showSplitModal} onClose={onClose} title="إضافة قسط دفع">
      <div className="space-y-4">
        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">طريقة الدفع</label>
            <select className="input" value={splitMethod} onChange={e => { setSplitMethod(e.target.value); setSplitWalletId('') }}>
              <option value="cash">💵 نقدي</option>
              {(wallets || []).filter((w: any) => w.type !== 'cash').map((w: any) => (
                <option key={w.id} value={w.id}>{w.type === 'vodafone_cash' ? '📱' : '💳'} {w.name}</option>
              ))}
              <option value="credit">📋 آجل</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">المبلغ (ج.م)</label>
            <input type="number" className="input text-lg font-bold" value={splitAmount} onChange={e => setSplitAmount(e.target.value)} autoFocus />
          </div>
        </div>
        <div className="text-xs text-slate-400">
          المتبقي من الفاتورة: {(total() - splitPayments.reduce((s, p) => s + p.amount, 0)).toLocaleString('ar-EG')} ج.م
        </div>
        <div className="flex gap-3 justify-end">
          <button onClick={onClose} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
          <button onClick={() => {
            const amt = Number(splitAmount)
            const maxRemaining = total() - splitPayments.reduce((s, p) => s + p.amount, 0)
            if (!amt || amt <= 0) { toast.error('المبلغ يجب أن يكون أكبر من 0'); return }
            if (amt > maxRemaining + 0.01) { toast.error(`المبلغ يتجاوز المتبقي (${maxRemaining.toLocaleString('ar-EG')})`); return }
            const isWalletMethod = splitMethod !== 'cash' && splitMethod !== 'credit'
            setSplitPayments((p: any) => [...p, { method: isWalletMethod ? 'wallet' : splitMethod, amount: amt, walletId: isWalletMethod ? splitMethod : undefined }])
            setSplitAmount(''); setShowSplitModal(false)
          }} disabled={!splitAmount || Number(splitAmount) <= 0}
            className="px-5 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#1e3a5f' }}>
            إضافة القسط
          </button>
        </div>
      </div>
    </Modal>
  )
}
