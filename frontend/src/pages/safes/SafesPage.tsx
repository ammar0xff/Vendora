import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import api from '../../api/client'
import toast from 'react-hot-toast'
import { Plus, Pencil, Vault, Wallet, ArrowDownCircle, ArrowUpCircle, ArrowRightLeft } from 'lucide-react'
import Modal from '../../components/ui/Modal'
import ConfirmDialog from '../../components/ui/ConfirmDialog'
import { PageLoader } from '../../components/ui/Loaders'
import { Button } from '../../components/ui/button'
import { Input } from '../../components/ui/input'
import { Select } from '../../components/ui/select'

const WALLET_LABELS: Record<string, string> = { cash: '💵 نقدي', vodafone_cash: '📱 فودافون كاش', instapay: '💳 إنستا باي' }

export default function SafesPage() {
  const qc = useQueryClient()
  const [action, setAction] = useState<{ type: 'deposit' | 'withdraw' | 'transfer' | 'edit-safe' | 'new-safe' | 'edit-wallet'; target?: any } | null>(null)
  const [amount, setAmount] = useState('')
  const [note, setNote] = useState('')
  const [toSafeId, setToSafeId] = useState('')
  const [form, setForm] = useState<any>({})
  const [confirmResetWallet, setConfirmResetWallet] = useState<any>(null)

  const { data: safes, isLoading: loadingSafes, isError: safesError } = useQuery({
    queryKey: ['safes'], queryFn: () => api.get('/safes').then(r => r.data),
  })
  const { data: wallets, isLoading: loadingWallets } = useQuery({
    queryKey: ['wallets'], queryFn: () => api.get('/wallets').then(r => r.data),
  })

  const close = () => { setAction(null); setAmount(''); setNote(''); setToSafeId(''); setForm({}) }

  const depositMut = useMutation({
    mutationFn: () => api.post(`/safes/${action?.target?.id}/deposit`, { amount: Number(amount), note }),
    onSuccess: () => { toast.success('✅ تم الإيداع'); qc.invalidateQueries({ queryKey: ['safes'] }); close() },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })
  const withdrawMut = useMutation({
    mutationFn: () => api.post(`/safes/${action?.target?.id}/withdraw`, { amount: Number(amount), note }),
    onSuccess: () => { toast.success('✅ تم السحب'); qc.invalidateQueries({ queryKey: ['safes'] }); close() },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })
  const transferMut = useMutation({
    mutationFn: () => api.post(`/safes/transfer`, { from_wallet_id: action?.target?.id, to_safe_id: toSafeId, amount: Number(amount), note }),
    onSuccess: () => { toast.success('✅ تم التحويل'); qc.invalidateQueries({ queryKey: ['safes'] }); qc.invalidateQueries({ queryKey: ['wallets'] }); close() },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })
  const saveSafeMut = useMutation({
    mutationFn: () => action?.target
      ? api.put(`/safes/${action.target.id}`, form)
      : api.post('/safes', form),
    onSuccess: () => { toast.success('✅ تم الحفظ'); qc.invalidateQueries({ queryKey: ['safes'] }); close() },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })
  const saveWalletMut = useMutation({
    mutationFn: () => api.put(`/wallets/${action?.target?.id}`, form),
    onSuccess: () => { toast.success('✅ تم الحفظ'); qc.invalidateQueries({ queryKey: ['wallets'] }); close() },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })

  const totalSafes = safes?.reduce((s: number, x: any) => s + Number(x.balance), 0) || 0
  const totalWallets = wallets?.reduce((s: number, x: any) => s + Number(x.balance), 0) || 0

  if (loadingSafes || loadingWallets) return <PageLoader text="جاري تحميل الخزن المالية..." />

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">🏦 الخزن المالية</h1>
        <Button onClick={() => { setForm({}); setAction({ type: 'new-safe' }) }} className="flex items-center gap-2">
          <Plus size={15} /> خزنة جديدة
        </Button>
      </div>

      {safesError && (
        <div className="mb-4 p-4 rounded-xl bg-red-50 border border-red-200 text-red-700 text-sm font-medium">
          تعذر تحميل الخزن — تحقق من الاتصال
        </div>
      )}

      {/* Totals */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="card p-4 flex items-center gap-3" style={{ borderRight: '4px solid var(--primary)' }}>
          <Vault size={24} style={{ color: 'var(--primary)' }} />
          <div>
            <p className="text-xs text-slate-500">إجمالي الخزن الأساسية</p>
            <p className="text-xl font-black" style={{ color: 'var(--primary)' }}>{totalSafes.toLocaleString('ar-EG')} ج.م</p>
          </div>
        </div>
        <div className="card p-4 flex items-center gap-3" style={{ borderRight: '4px solid var(--accent)' }}>
          <Wallet size={24} style={{ color: 'var(--accent)' }} />
          <div>
            <p className="text-xs text-slate-500">إجمالي المحافظ المؤقتة</p>
            <p className="text-xl font-black" style={{ color: 'var(--accent)' }}>{totalWallets.toLocaleString('ar-EG')} ج.م</p>
          </div>
        </div>
      </div>

      {/* Permanent Safes */}
      <p className="text-sm font-bold text-slate-500 mb-2 flex items-center gap-2"><Vault size={14} /> الخزن الأساسية</p>
      {!safes?.length ? (
        <div className="text-center py-10 text-slate-400 text-sm mb-6">لا توجد خزن أساسية — أضف خزنة جديدة</div>
      ) : (
      <div className="grid grid-cols-1 md:grid-cols-3 gap-3 mb-6">
        {safes?.map((s: any) => (
          <div key={s.id} className="card p-4">
            <div className="flex items-start justify-between mb-2">
              <div>
                <p className="font-bold text-slate-800">{s.name}</p>
                <p className="text-xs text-slate-400">{s.location || '—'}</p>
              </div>
              <Button variant="ghost" size="icon-sm" onClick={() => { setForm({ name: s.name, location: s.location }); setAction({ type: 'edit-safe', target: s }) }}
                className="text-slate-400 hover:text-slate-600"><Pencil size={14} /></Button>
            </div>
            <p className={`text-xl font-black mb-3 ${Number(s.balance) >= 0 ? 'text-green-600' : 'text-red-600'}`}>
              {Number(s.balance).toLocaleString('ar-EG')} ج.م
            </p>
            <div className="flex gap-2">
              <Button onClick={() => setAction({ type: 'deposit', target: s })}
                className="flex-1 text-xs font-bold bg-green-600 hover:bg-green-700 text-white"><ArrowDownCircle size={12} /> إيداع</Button>
              <Button onClick={() => setAction({ type: 'withdraw', target: s })}
                className="flex-1 text-xs font-bold bg-red-600 hover:bg-red-700 text-white"><ArrowUpCircle size={12} /> سحب</Button>
            </div>
          </div>
        ))}
      </div>
      )}

      {/* Temporary Wallets */}
      <p className="text-sm font-bold text-slate-500 mb-2 flex items-center gap-2"><Wallet size={14} /> المحافظ المؤقتة (تجمع إيرادات الورديات)</p>
      {!wallets?.length ? (
        <div className="text-center py-10 text-slate-400 text-sm mb-6">لا توجد محافظ مؤقتة</div>
      ) : (
      <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
        {wallets?.map((w: any) => (
          <div key={w.id} className="card p-4">
            <div className="flex items-start justify-between mb-2">
              <div>
                <p className="font-bold text-slate-800">{w.name}</p>
                <p className="text-xs text-slate-400">{WALLET_LABELS[w.type] || w.type}{w.phone ? ` · ${w.phone}` : ''}</p>
              </div>
              <Button variant="ghost" size="icon-sm" onClick={() => { setForm({ name: w.name, phone: w.phone }); setAction({ type: 'edit-wallet', target: w }) }}
                className="text-slate-400 hover:text-slate-600"><Pencil size={14} /></Button>
            </div>
            <p className="text-xl font-black mb-3" style={{ color: 'var(--accent)' }}>
              {Number(w.balance).toLocaleString('ar-EG')} ج.م
            </p>
            <Button onClick={() => { setToSafeId(safes?.[0]?.id || ''); setAction({ type: 'transfer', target: w }) }}
              className="w-full text-xs font-bold"><ArrowRightLeft size={12} /> تحويل للخزنة</Button>
            <Button variant="destructive" onClick={() => setConfirmResetWallet(w)}
              className="w-full text-xs font-bold">
              ✕ تصفير الرصيد
            </Button>
          </div>
        ))}
      </div>
      )}

      {/* Deposit Modal */}
      <Modal open={action?.type === 'deposit'} onClose={close} title={`إيداع في ${action?.target?.name}`}>
        <div className="space-y-3">
 <Input type="number" placeholder="المبلغ *" value={amount} onChange={e => setAmount(e.target.value)} autoFocus/>
 <Input placeholder="ملاحظة" value={note} onChange={e => setNote(e.target.value)}/>
          <Button onClick={() => depositMut.mutate()} disabled={!amount || depositMut.isPending}
            className="w-full bg-green-600 hover:bg-green-700 text-white">
            {depositMut.isPending ? 'جاري...' : 'تأكيد الإيداع'}
          </Button>
        </div>
      </Modal>

      {/* Withdraw Modal */}
      <Modal open={action?.type === 'withdraw'} onClose={close} title={`سحب من ${action?.target?.name}`}>
        <div className="space-y-3">
 <Input type="number" placeholder="المبلغ *" value={amount} onChange={e => setAmount(e.target.value)} autoFocus/>
 <Input placeholder="ملاحظة" value={note} onChange={e => setNote(e.target.value)}/>
          <Button onClick={() => withdrawMut.mutate()} disabled={!amount || withdrawMut.isPending}
            className="w-full bg-red-600 hover:bg-red-700 text-white">
            {withdrawMut.isPending ? 'جاري...' : 'تأكيد السحب'}
          </Button>
        </div>
      </Modal>

      {/* Transfer Modal */}
      <Modal open={action?.type === 'transfer'} onClose={close} title={`تحويل من ${action?.target?.name} إلى خزنة`}>
        <div className="space-y-3">
          <div>
            <label className="block text-xs font-medium text-slate-500 mb-1">الخزنة المستقبِلة</label>
            <Select value={toSafeId} onChange={e => setToSafeId(e.target.value)}>
              {safes?.map((s: any) => <option key={s.id} value={s.id}>{s.name} — {Number(s.balance).toLocaleString('ar-EG')} ج.م</option>)}
            </Select>
          </div>
 <Input type="number" placeholder="المبلغ *"
            max={action?.target?.balance} value={amount} onChange={e => setAmount(e.target.value)} autoFocus />
          <p className="text-xs text-slate-400">الرصيد المتاح: {Number(action?.target?.balance || 0).toLocaleString('ar-EG')} ج.م</p>
 <Input placeholder="ملاحظة" value={note} onChange={e => setNote(e.target.value)}/>
          <Button onClick={() => transferMut.mutate()} disabled={!amount || !toSafeId || transferMut.isPending}
            className="w-full">
            {transferMut.isPending ? 'جاري...' : 'تأكيد التحويل'}
          </Button>
        </div>
      </Modal>

      {/* Edit/New Safe Modal */}
      <Modal open={action?.type === 'edit-safe' || action?.type === 'new-safe'} onClose={close}
        title={action?.type === 'new-safe' ? 'خزنة جديدة' : `تعديل ${action?.target?.name}`}>
        <div className="space-y-3">
 <Input placeholder="اسم الخزنة *" value={form.name || ''} onChange={e => setForm((f: any) => ({ ...f, name: e.target.value }))} autoFocus/>
 <Input placeholder="الموقع (اختياري)" value={form.location || ''} onChange={e => setForm((f: any) => ({ ...f, location: e.target.value }))}/>
          <Button onClick={() => saveSafeMut.mutate()} disabled={!form.name || saveSafeMut.isPending}
            className="w-full">
            {saveSafeMut.isPending ? 'جاري...' : 'حفظ'}
          </Button>
        </div>
      </Modal>

      {/* Edit Wallet Modal */}
      <Modal open={action?.type === 'edit-wallet'} onClose={close} title={`تعديل ${action?.target?.name}`}>
        <div className="space-y-3">
 <Input placeholder="الاسم *" value={form.name || ''} onChange={e => setForm((f: any) => ({ ...f, name: e.target.value }))} autoFocus/>
 <Input placeholder="رقم الهاتف" value={form.phone || ''} onChange={e => setForm((f: any) => ({ ...f, phone: e.target.value }))}/>
          <Button onClick={() => saveWalletMut.mutate()} disabled={!form.name || saveWalletMut.isPending}
            className="w-full">
            {saveWalletMut.isPending ? 'جاري...' : 'حفظ'}
          </Button>
        </div>
      </Modal>
      <ConfirmDialog open={!!confirmResetWallet} onClose={() => setConfirmResetWallet(null)} onConfirm={() => { api.post(`/wallets/${confirmResetWallet.id}/reset-balance`).then(() => { toast.success('✅ تم التصفير'); qc.invalidateQueries({ queryKey: ['wallets'] }) }).catch((e: any) => toast.error(e.response?.data?.detail || 'فشل')); setConfirmResetWallet(null) }} message={`تصفير رصيد ${confirmResetWallet?.name} (${Number(confirmResetWallet?.balance || 0).toLocaleString('ar-EG')} ج.م)؟`} danger confirmText="تصفير" />
    </div>
  )
}
