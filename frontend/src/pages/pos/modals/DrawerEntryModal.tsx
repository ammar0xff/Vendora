import Modal from '../../../components/ui/Modal'

interface Props {
  showDrawerEntry: boolean
  onClose: () => void
  drawerEntryType: 'expense' | 'deposit'
  drawerEntryAmount: string
  setDrawerEntryAmount: (v: string) => void
  drawerEntryCategoryId: string
  setDrawerEntryCategoryId: (v: string) => void
  drawerEntryPaymentMethod: string
  setDrawerEntryPaymentMethod: (v: string) => void
  drawerEntryWalletId: string
  setDrawerEntryWalletId: (v: string) => void
  drawerEntryNote: string
  setDrawerEntryNote: (v: string) => void
  finCategories: any[]
  wallets: any[]
  drawerEntryMut: any
}

export function DrawerEntryModal({ showDrawerEntry, onClose, drawerEntryType, drawerEntryAmount, setDrawerEntryAmount, drawerEntryCategoryId, setDrawerEntryCategoryId, drawerEntryPaymentMethod, setDrawerEntryPaymentMethod, drawerEntryWalletId, setDrawerEntryWalletId, drawerEntryNote, setDrawerEntryNote, finCategories, wallets, drawerEntryMut }: Props) {
  return (
    <Modal open={showDrawerEntry} onClose={onClose}
      title={drawerEntryType === 'expense' ? 'تسجيل خوارج' : 'تسجيل دواخل مالية'}>
      <div className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">المبلغ (ج.م) *</label>
          <input type="number" className="input text-xl font-black" value={drawerEntryAmount}
            onChange={e => setDrawerEntryAmount(e.target.value)} placeholder="0.00" autoFocus />
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">الفئة</label>
          <select className="input" value={drawerEntryCategoryId} onChange={e => setDrawerEntryCategoryId(e.target.value)}>
            <option value="">بدون فئة</option>
            {(finCategories as any[])?.filter((c: any) => c.type === drawerEntryType || (drawerEntryType === 'deposit' && c.type === 'income')).map((c: any) => (
              <option key={c.id} value={c.id}>{c.name}</option>
            ))}
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">وسيلة الدفع</label>
          <div className="flex gap-2">
            <button type="button" onClick={() => { setDrawerEntryPaymentMethod('cash'); setDrawerEntryWalletId('') }}
              className={`flex-1 py-2 rounded-lg text-sm font-bold border transition-all ${drawerEntryPaymentMethod === 'cash' ? 'bg-slate-800 text-white border-slate-800' : 'border-slate-300 text-slate-600'}`}>
              💵 نقدي
            </button>
            {(wallets || []).filter((w: any) => w.type !== 'cash').map((w: any) => (
              <button key={w.id} type="button"
                onClick={() => { setDrawerEntryPaymentMethod('wallet'); setDrawerEntryWalletId(w.id) }}
                className={`flex-1 py-2 rounded-lg text-sm font-bold border transition-all ${drawerEntryPaymentMethod === 'wallet' && drawerEntryWalletId === w.id ? 'bg-slate-800 text-white border-slate-800' : 'border-slate-300 text-slate-600'}`}>
                {w.type === 'vodafone_cash' ? '📱' : '💳'} {w.name}
              </button>
            ))}
          </div>
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">البيان</label>
          <input className="input" value={drawerEntryNote} onChange={e => setDrawerEntryNote(e.target.value)}
            placeholder={drawerEntryType === 'expense' ? 'إيجار، كهرباء، مصاريف...' : 'مصدر الدخل...'} />
        </div>
        <div className="flex gap-3 justify-end">
          <button onClick={onClose} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
          <button onClick={() => drawerEntryMut.mutate()} disabled={!drawerEntryAmount || drawerEntryMut.isPending}
            className="px-5 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50"
            style={{ background: drawerEntryType === 'expense' ? '#dc2626' : '#16a34a' }}>
            تسجيل
          </button>
        </div>
      </div>
    </Modal>
  )
}
