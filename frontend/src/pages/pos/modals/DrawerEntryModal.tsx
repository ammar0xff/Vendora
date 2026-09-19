import Modal from '../../../components/ui/Modal'
import { Button } from '../../../components/ui/button'
import { clsx } from 'clsx'
import { Input } from '../../../components/ui/input'
import { Select } from '../../../components/ui/select'

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
 <Input type="number" className="text-xl font-black" value={drawerEntryAmount}
            onChange={e => setDrawerEntryAmount(e.target.value)} placeholder="0.00" autoFocus />
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">الفئة</label>
          <Select value={drawerEntryCategoryId} onChange={e => setDrawerEntryCategoryId(e.target.value)}>
            <option value="">بدون فئة</option>
            {(finCategories as any[])?.filter((c: any) => c.type === drawerEntryType || (drawerEntryType === 'deposit' && c.type === 'income')).map((c: any) => (
              <option key={c.id} value={c.id}>{c.name}</option>
            ))}
          </Select>
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">وسيلة الدفع</label>
          <div className="flex gap-2">
            <Button type="button" onClick={() => { setDrawerEntryPaymentMethod('cash'); setDrawerEntryWalletId('') }}
              variant={drawerEntryPaymentMethod === 'cash' ? 'default' : 'outline'}
              aria-pressed={drawerEntryPaymentMethod === 'cash'}
              className={clsx('flex-1 py-2.5 rounded-xl text-sm font-bold', drawerEntryPaymentMethod === 'cash' ? 'bg-[var(--primary)] text-white border-[var(--primary)] shadow-sm' : 'border-slate-300 text-slate-600 hover:border-slate-400 hover:bg-transparent')}>
              💵 نقدي
            </Button>
            {(wallets || []).filter((w: any) => w.type !== 'cash').map((w: any) => (
              <Button key={w.id} type="button" variant={drawerEntryPaymentMethod === 'wallet' && drawerEntryWalletId === w.id ? 'default' : 'outline'}
                  aria-pressed={drawerEntryPaymentMethod === 'wallet' && drawerEntryWalletId === w.id}
                  onClick={() => { setDrawerEntryPaymentMethod('wallet'); setDrawerEntryWalletId(w.id) }}
                  className={clsx('flex-1 py-2.5 rounded-xl text-sm font-bold', drawerEntryPaymentMethod === 'wallet' && drawerEntryWalletId === w.id ? 'bg-[var(--primary)] text-white border-[var(--primary)] shadow-sm' : 'border-slate-300 text-slate-600 hover:border-slate-400 hover:bg-transparent')}>
                  {w.type === 'vodafone_cash' ? '📱' : '💳'} {w.name}
                </Button>
            ))}
          </div>
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">البيان</label>
 <Input value={drawerEntryNote} onChange={e => setDrawerEntryNote(e.target.value)}
            placeholder={drawerEntryType === 'expense' ? 'إيجار، كهرباء، مصاريف...' : 'مصدر الدخل...'} />
        </div>
        <div className="flex gap-3 justify-end">
          <Button variant="ghost" onClick={onClose}>إلغاء</Button>
          <Button variant={drawerEntryType === 'expense' ? 'destructive' : 'default'} onClick={() => drawerEntryMut.mutate()} disabled={!drawerEntryAmount || drawerEntryMut.isPending}>
            تسجيل
          </Button>
        </div>
      </div>
    </Modal>
  )
}
