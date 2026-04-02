import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import api from '../../api/client'
import toast from 'react-hot-toast'
import { Plus, Vault, ArrowDownCircle, ArrowUpCircle } from 'lucide-react'
import Modal from '../../components/ui/Modal'

export default function SafesPage() {
  const qc = useQueryClient()
  const [selectedSafe, setSelectedSafe] = useState<any>(null)
  const [showDeposit, setShowDeposit] = useState(false)
  const [showWithdraw, setShowWithdraw] = useState(false)
  const [showCreate, setShowCreate] = useState(false)
  const [amount, setAmount] = useState('')
  const [note, setNote] = useState('')
  const [newName, setNewName] = useState('')
  const [newLocation, setNewLocation] = useState('')

  const { data: safes } = useQuery({ queryKey: ['safes'], queryFn: () => api.get('/safes').then(r => r.data) })
  const { data: history } = useQuery({
    queryKey: ['safe-history', selectedSafe?.id],
    queryFn: () => api.get(`/safes/${selectedSafe.id}/history`).then(r => r.data),
    enabled: !!selectedSafe,
  })

  const depositMut = useMutation({
    mutationFn: () => api.post(`/safes/${selectedSafe.id}/deposit`, { amount: Number(amount), note }),
    onSuccess: () => { toast.success('✅ تم الإيداع'); qc.invalidateQueries({ queryKey: ['safes'] }); qc.invalidateQueries({ queryKey: ['safe-history', selectedSafe?.id] }); setShowDeposit(false); setAmount(''); setNote('') },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })

  const withdrawMut = useMutation({
    mutationFn: () => api.post(`/safes/${selectedSafe.id}/withdraw`, { amount: Number(amount), note }),
    onSuccess: () => { toast.success('✅ تم السحب'); qc.invalidateQueries({ queryKey: ['safes'] }); qc.invalidateQueries({ queryKey: ['safe-history', selectedSafe?.id] }); setShowWithdraw(false); setAmount(''); setNote('') },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })

  const createMut = useMutation({
    mutationFn: () => api.post('/safes', { name: newName, location: newLocation }),
    onSuccess: () => { toast.success('✅ تم إنشاء الخزنة'); qc.invalidateQueries({ queryKey: ['safes'] }); setShowCreate(false); setNewName(''); setNewLocation('') },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })

  const totalBalance = safes?.reduce((s: number, x: any) => s + Number(x.balance), 0) || 0

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">🏦 الخزن المالية</h1>
        <button onClick={() => setShowCreate(true)} className="btn-primary flex items-center gap-2">
          <Plus size={15} /> خزنة جديدة
        </button>
      </div>

      {/* Total */}
      <div className="card p-4 mb-5 flex items-center gap-4" style={{ borderRight: '4px solid #c8a84b' }}>
        <Vault size={28} style={{ color: '#c8a84b' }} />
        <div>
          <p className="text-xs text-slate-500">إجمالي الخزن</p>
          <p className="text-2xl font-black" style={{ color: '#1e3a5f' }}>{totalBalance.toLocaleString('ar-EG')} ج.م</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        {safes?.map((s: any) => (
          <div key={s.id}
            onClick={() => setSelectedSafe(s)}
            className={`card p-4 cursor-pointer border-2 transition-all ${selectedSafe?.id === s.id ? 'border-[#1e3a5f]' : 'border-transparent hover:border-slate-200'}`}>
            <p className="font-bold text-slate-800">{s.name}</p>
            <p className="text-xs text-slate-400 mb-3">{s.location}</p>
            <p className="text-xl font-black" style={{ color: Number(s.balance) >= 0 ? '#16a34a' : '#dc2626' }}>
              {Number(s.balance).toLocaleString('ar-EG')} ج.م
            </p>
            {selectedSafe?.id === s.id && (
              <div className="flex gap-2 mt-3">
                <button onClick={e => { e.stopPropagation(); setShowDeposit(true) }}
                  className="flex-1 py-1.5 rounded-lg text-xs font-bold text-white flex items-center justify-center gap-1"
                  style={{ background: '#16a34a' }}>
                  <ArrowDownCircle size={13} /> إيداع
                </button>
                <button onClick={e => { e.stopPropagation(); setShowWithdraw(true) }}
                  className="flex-1 py-1.5 rounded-lg text-xs font-bold text-white flex items-center justify-center gap-1"
                  style={{ background: '#dc2626' }}>
                  <ArrowUpCircle size={13} /> سحب
                </button>
              </div>
            )}
          </div>
        ))}
      </div>

      {/* History */}
      {selectedSafe && (
        <div className="card p-0 overflow-hidden">
          <div className="px-4 py-3 border-b border-slate-100">
            <p className="font-bold text-slate-700">حركات {selectedSafe.name}</p>
          </div>
          <div className="table-wrap" style={{ maxHeight: '400px' }}>
            <table>
              <thead>
                <tr>
                  <th>التاريخ</th>
                  <th>النوع</th>
                  <th>المبلغ</th>
                  <th>الرصيد بعد</th>
                  <th>ملاحظة</th>
                </tr>
              </thead>
              <tbody>
                {!history?.length && <tr><td colSpan={5} className="text-center py-8 text-slate-400">لا توجد حركات</td></tr>}
                {history?.map((h: any) => (
                  <tr key={h.id}>
                    <td className="text-xs text-slate-500">{new Date(h.created_at).toLocaleString('ar-EG')}</td>
                    <td>
                      <span className={`text-xs px-2 py-0.5 rounded-full font-bold ${h.tx_type === 'deposit' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
                        {h.tx_type === 'deposit' ? '↓ إيداع' : '↑ سحب'}
                      </span>
                    </td>
                    <td className={`font-bold ${h.tx_type === 'deposit' ? 'text-green-600' : 'text-red-600'}`}>
                      {h.tx_type === 'deposit' ? '+' : '-'}{Number(h.amount).toLocaleString('ar-EG')} ج.م
                    </td>
                    <td className="font-bold text-slate-700">{Number(h.balance_after).toLocaleString('ar-EG')} ج.م</td>
                    <td className="text-xs text-slate-500">{h.note || '—'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Deposit Modal */}
      <Modal open={showDeposit} onClose={() => { setShowDeposit(false); setAmount(''); setNote('') }} title={`إيداع في ${selectedSafe?.name}`}>
        <div className="space-y-3">
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">المبلغ *</label>
            <input type="number" className="input" placeholder="0.00" value={amount} onChange={e => setAmount(e.target.value)} autoFocus />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">ملاحظة</label>
            <input className="input" placeholder="سبب الإيداع..." value={note} onChange={e => setNote(e.target.value)} />
          </div>
          <button onClick={() => depositMut.mutate()} disabled={!amount || depositMut.isPending}
            className="w-full py-2.5 rounded-xl font-bold text-white disabled:opacity-50"
            style={{ background: '#16a34a' }}>
            {depositMut.isPending ? 'جاري...' : 'تأكيد الإيداع'}
          </button>
        </div>
      </Modal>

      {/* Withdraw Modal */}
      <Modal open={showWithdraw} onClose={() => { setShowWithdraw(false); setAmount(''); setNote('') }} title={`سحب من ${selectedSafe?.name}`}>
        <div className="space-y-3">
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">المبلغ *</label>
            <input type="number" className="input" placeholder="0.00" value={amount} onChange={e => setAmount(e.target.value)} autoFocus />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">ملاحظة</label>
            <input className="input" placeholder="سبب السحب..." value={note} onChange={e => setNote(e.target.value)} />
          </div>
          <button onClick={() => withdrawMut.mutate()} disabled={!amount || withdrawMut.isPending}
            className="w-full py-2.5 rounded-xl font-bold text-white disabled:opacity-50"
            style={{ background: '#dc2626' }}>
            {withdrawMut.isPending ? 'جاري...' : 'تأكيد السحب'}
          </button>
        </div>
      </Modal>

      {/* Create Modal */}
      <Modal open={showCreate} onClose={() => setShowCreate(false)} title="خزنة جديدة">
        <div className="space-y-3">
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">اسم الخزنة *</label>
            <input className="input" placeholder="مثال: خزنة المعرض الجديد" value={newName} onChange={e => setNewName(e.target.value)} autoFocus />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">الموقع</label>
            <input className="input" placeholder="مثال: الدور الأول" value={newLocation} onChange={e => setNewLocation(e.target.value)} />
          </div>
          <button onClick={() => createMut.mutate()} disabled={!newName || createMut.isPending}
            className="w-full py-2.5 rounded-xl font-bold text-white disabled:opacity-50"
            style={{ background: '#1e3a5f' }}>
            {createMut.isPending ? 'جاري...' : 'إنشاء الخزنة'}
          </button>
        </div>
      </Modal>
    </div>
  )
}
