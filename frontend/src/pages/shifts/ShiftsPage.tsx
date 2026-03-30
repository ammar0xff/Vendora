import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { shiftsApi } from '../../api/endpoints'
import api from '../../api/client'
import { useAppStore } from '../../store/app'
import { PageLoader } from '../../components/ui/Loaders'
import Modal from '../../components/ui/Modal'
import toast from 'react-hot-toast'
import { Wallet, Plus, Lock, ArrowLeftRight, TrendingUp, TrendingDown, DollarSign } from 'lucide-react'
import { clsx } from 'clsx'
import { format } from 'date-fns'

export default function ShiftsPage() {
  const [showOpen, setShowOpen] = useState(false)
  const [showClose, setShowClose] = useState(false)
  const [showExpense, setShowExpense] = useState(false)
  const [initialAmount, setInitialAmount] = useState('')
  const [closingBalance, setClosingBalance] = useState('')
  const [expenseAmount, setExpenseAmount] = useState('')
  const [expenseNote, setExpenseNote] = useState('')
  const qc = useQueryClient()

  const { activeWarehouseId } = useAppStore()
  const { data: shift, isLoading } = useQuery({
    queryKey: ['current-shift', activeWarehouseId], queryFn: () => shiftsApi.current(activeWarehouseId!),
    retry: false, throwOnError: false, enabled: !!activeWarehouseId
  })
  const { data: summary } = useQuery({
    queryKey: ['shift-summary', shift?.id], queryFn: () => shiftsApi.summary(shift!.id), enabled: !!shift?.id
  })
  const { data: transactions } = useQuery({
    queryKey: ['shift-txns', shift?.id], queryFn: () => shiftsApi.transactions(shift!.id), enabled: !!shift?.id
  })
  const { data: history } = useQuery({ queryKey: ['shifts'], queryFn: shiftsApi.list })

  const openMut = useMutation({
    mutationFn: () => shiftsApi.open(Number(initialAmount), activeWarehouseId!),
    onSuccess: () => { toast.success('تم فتح الوردية'); setShowOpen(false); qc.invalidateQueries({ queryKey: ['current-shift'] }); qc.invalidateQueries({ queryKey: ['shifts'] }) },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })
  const [nextDayDrawer, setNextDayDrawer] = useState('')
  const [managerId, setManagerId] = useState('')
  const [managerPassword, setManagerPassword] = useState('')

  const { data: managers } = useQuery({
    queryKey: ['managers'],
    queryFn: () => api.get('/users/managers').then(r => r.data),
    enabled: showClose,
  })

  const closeMut = useMutation({
    mutationFn: () => api.post(`/shifts/${shift!.id}/close-with-manager`, {
      closing_balance: Number(closingBalance),
      next_day_drawer: Number(nextDayDrawer || closingBalance),
      manager_id: managerId,
      manager_password: managerPassword,
    }).then(r => r.data),
    onSuccess: (d) => {
      const variance = Number(d.variance || 0)
      if (variance !== 0) toast.success(`تم الإغلاق — فرق الدرج: ${variance > 0 ? '+' : ''}${variance.toLocaleString('ar-EG')} ج.م`, { duration: 5000 })
      else toast.success('تم إغلاق الوردية بنجاح')
      setShowClose(false); setManagerPassword(''); setManagerId('')
      qc.invalidateQueries({ queryKey: ['current-shift'] }); qc.invalidateQueries({ queryKey: ['shifts'] })
    },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل إغلاق الوردية'),
  })
  const expenseMut = useMutation({
    mutationFn: () => shiftsApi.addTransaction(shift!.id, { type: 'expense', amount: Number(expenseAmount), note: expenseNote }),
    onSuccess: () => { toast.success('تم تسجيل المصروف'); setShowExpense(false); setExpenseAmount(''); setExpenseNote(''); qc.invalidateQueries({ queryKey: ['shift-summary', shift?.id] }); qc.invalidateQueries({ queryKey: ['shift-txns', shift?.id] }) },
  })

  const txTypeLabel: Record<string, string> = { sale: 'مبيعات', return: 'مرتجع', expense: 'مصروف', deposit: 'إيداع', withdrawal: 'سحب' }
  const txColor: Record<string, string> = { sale: 'badge-green', return: 'badge-red', expense: 'badge-yellow', deposit: 'badge-blue', withdrawal: 'badge-gray' }

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">الوردية والدرج النقدي</h1>
        {!shift && <button onClick={() => setShowOpen(true)} className="btn-primary"><Plus size={16} /> فتح وردية</button>}
        {shift && (
          <div className="flex gap-2">
            <button onClick={() => setShowExpense(true)} className="btn-ghost"><TrendingDown size={16} /> تسجيل مصروف</button>
            <button onClick={() => setShowClose(true)} className="btn-danger"><Lock size={16} /> إغلاق الوردية</button>
          </div>
        )}
      </div>

      {isLoading ? <PageLoader /> : (
        <>
          {/* Current shift summary */}
          {shift && summary ? (
            <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
              {[
                { label: 'الرصيد الافتتاحي', value: summary.initial_amount, icon: Wallet, color: '#1e3a5f' },
                { label: 'إجمالي المبيعات', value: summary.sales_total, icon: TrendingUp, color: '#16a34a' },
                { label: 'إجمالي المصروفات', value: summary.expenses_total, icon: TrendingDown, color: '#dc2626' },
                { label: 'الرصيد المتوقع', value: summary.expected_balance, icon: DollarSign, color: '#7c3aed' },
              ].map(({ label, value, icon: Icon, color }) => (
                <div key={label} className="stat-card">
                  <div className="stat-icon" style={{ background: color + '20' }}><Icon size={20} style={{ color }} /></div>
                  <div>
                    <p className="text-slate-500 text-xs mb-1">{label}</p>
                    <p className="text-lg font-black text-slate-800">{Number(value).toLocaleString('ar-EG')} ج.م</p>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="card text-center py-12 mb-6">
              <Wallet size={48} className="mx-auto mb-4 text-slate-300" />
              <p className="text-slate-500 font-medium">لا توجد وردية مفتوحة</p>
              <p className="text-slate-400 text-sm mt-1">افتح وردية جديدة لبدء العمل</p>
            </div>
          )}

          {/* Transactions */}
          {shift && transactions && (
            <div className="card mb-6">
              <h3 className="font-bold text-slate-700 mb-4">حركات الوردية الحالية ({transactions.length})</h3>
              <div className="table-wrap max-h-64 overflow-y-auto">
                <table>
                  <thead><tr><th>الوقت</th><th>النوع</th><th>المبلغ</th><th>ملاحظة</th></tr></thead>
                  <tbody>
                    {transactions.map((t: any) => (
                      <tr key={t.id}>
                        <td className="text-xs text-slate-500">{new Date(t.created_at).toLocaleTimeString('ar-EG')}</td>
                        <td><span className={txColor[t.type] || 'badge-gray'}>{txTypeLabel[t.type] || t.type}</span></td>
                        <td className="font-bold">{Number(t.amount).toLocaleString('ar-EG')} ج.م</td>
                        <td className="text-xs text-slate-500">{t.note || '-'}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* History */}
          <div className="card">
            <h3 className="font-bold text-slate-700 mb-4">سجل الورديات</h3>
            <div className="table-wrap">
              <table>
                <thead><tr><th>تاريخ الفتح</th><th>تاريخ الإغلاق</th><th>الرصيد الافتتاحي</th><th>الرصيد الختامي</th><th>الحالة</th></tr></thead>
                <tbody>
                  {history?.map((s: any) => (
                    <tr key={s.id}>
                      <td className="text-sm">{new Date(s.started_at).toLocaleString('ar-EG')}</td>
                      <td className="text-sm text-slate-500">{s.closed_at ? new Date(s.closed_at).toLocaleString('ar-EG') : '-'}</td>
                      <td className="font-semibold">{Number(s.initial_amount).toLocaleString('ar-EG')} ج.م</td>
                      <td className="font-semibold">{s.closing_balance ? `${Number(s.closing_balance).toLocaleString('ar-EG')} ج.م` : '-'}</td>
                      <td><span className={s.status === 'open' ? 'badge-green' : 'badge-gray'}>{s.status === 'open' ? 'مفتوحة' : 'مغلقة'}</span></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </>
      )}

      <Modal open={showOpen} onClose={() => setShowOpen(false)} title="فتح وردية جديدة">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">الرصيد الافتتاحي (ج.م)</label>
            <input type="number" className="input" value={initialAmount} onChange={e => setInitialAmount(e.target.value)} placeholder="0.00" />
          </div>
          <div className="flex gap-3 justify-end">
            <button onClick={() => setShowOpen(false)} className="btn-ghost">إلغاء</button>
            <button onClick={() => openMut.mutate()} disabled={openMut.isPending} className="btn-primary">فتح الوردية</button>
          </div>
        </div>
      </Modal>

      <Modal open={showClose} onClose={() => setShowClose(false)} title="إغلاق الوردية — يتطلب موافقة مدير">
        <div className="space-y-4">
          {summary && (
            <div className="bg-slate-50 rounded-xl p-4 text-sm space-y-2">
              <div className="flex justify-between"><span className="text-slate-500">الرصيد المتوقع:</span><span className="font-bold">{Number(summary.expected_balance).toLocaleString('ar-EG')} ج.م</span></div>
              <div className="flex justify-between"><span className="text-slate-500">المبيعات:</span><span className="text-green-700 font-semibold">{Number(summary.sales_total).toLocaleString('ar-EG')} ج.م</span></div>
              <div className="flex justify-between"><span className="text-slate-500">المصروفات:</span><span className="text-red-600 font-semibold">{Number(summary.expenses_total).toLocaleString('ar-EG')} ج.م</span></div>
            </div>
          )}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-slate-600 mb-1">الرصيد الفعلي *</label>
              <input type="number" className="input" value={closingBalance} onChange={e => setClosingBalance(e.target.value)} placeholder="0.00" />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-600 mb-1">عهدة اليوم التالي</label>
              <input type="number" className="input" value={nextDayDrawer} onChange={e => setNextDayDrawer(e.target.value)} placeholder={closingBalance || '0.00'} />
            </div>
          </div>
          <div className="border-t border-slate-200 pt-4">
            <p className="text-xs font-bold text-slate-500 mb-3 uppercase tracking-wide">توقيع المدير</p>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-slate-600 mb-1">المدير *</label>
                <select className="input" value={managerId} onChange={e => setManagerId(e.target.value)}>
                  <option value="">اختر مديراً...</option>
                  {managers?.map((m: any) => <option key={m.id} value={m.id}>{m.full_name}</option>)}
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-600 mb-1">كلمة مرور المدير *</label>
                <input type="password" className="input" value={managerPassword} onChange={e => setManagerPassword(e.target.value)} placeholder="••••••" />
              </div>
            </div>
          </div>
          <div className="flex gap-3 justify-end">
            <button onClick={() => setShowClose(false)} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
            <button onClick={() => closeMut.mutate()} disabled={closeMut.isPending || !managerId || !managerPassword || !closingBalance}
              className="px-5 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#dc2626' }}>
              {closeMut.isPending ? 'جاري الإغلاق...' : 'إغلاق الوردية'}
            </button>
          </div>
        </div>
      </Modal>

      <Modal open={showExpense} onClose={() => setShowExpense(false)} title="تسجيل مصروف">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">المبلغ (ج.م)</label>
            <input type="number" className="input" value={expenseAmount} onChange={e => setExpenseAmount(e.target.value)} />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">البيان</label>
            <input className="input" value={expenseNote} onChange={e => setExpenseNote(e.target.value)} placeholder="وصف المصروف..." />
          </div>
          <div className="flex gap-3 justify-end">
            <button onClick={() => setShowExpense(false)} className="btn-ghost">إلغاء</button>
            <button onClick={() => expenseMut.mutate()} disabled={expenseMut.isPending} className="btn-primary">تسجيل</button>
          </div>
        </div>
      </Modal>
    </div>
  )
}
