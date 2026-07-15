import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { shiftsApi } from '../../api/endpoints'
import api from '../../api/client'
import { useAppStore } from '../../store/app'
import { PageLoader } from '../../components/ui/Loaders'
import Modal from '../../components/ui/Modal'
import toast from 'react-hot-toast'
import { Wallet, Plus, Lock, TrendingUp, TrendingDown, DollarSign, Vault, Smartphone, Banknote, Landmark } from 'lucide-react'

export default function ShiftsPage() {
  const [page, setPage] = useState(0)
  const pageSize = 50
  const [showOpen, setShowOpen] = useState(false)
  const [showClose, setShowClose] = useState(false)
  const [showDeposit, setShowDeposit] = useState(false)
  const [showExpense, setShowExpense] = useState(false)
  const [depositSafeId, setDepositSafeId] = useState('')
  const [closeSafeId, setCloseSafeId] = useState('')
  const [depositReceiverId, setDepositReceiverId] = useState('')
  const [depositNotes, setDepositNotes] = useState('')
  const [initialAmount, setInitialAmount] = useState('')
  const [closingBalance, setClosingBalance] = useState('')
  const [nextDayDrawer, setNextDayDrawer] = useState('')
  const [managerId, setManagerId] = useState('')
  const [managerPassword, setManagerPassword] = useState('')
  const [expenseAmount, setExpenseAmount] = useState('')
  const [expenseNote, setExpenseNote] = useState('')
  const [showRevenueDelivery, setShowRevenueDelivery] = useState(false)
  const [revenueAmount, setRevenueAmount] = useState('')
  const [revenueSafeId, setRevenueSafeId] = useState('')
  const [revenueManagerId, setRevenueManagerId] = useState('')
  const [revenueManagerPassword, setRevenueManagerPassword] = useState('')
  const [revenueNotes, setRevenueNotes] = useState('')
  const qc = useQueryClient()

  const { activeWarehouseId } = useAppStore()
  const { data: shift, isLoading } = useQuery({
    queryKey: ['current-shift', activeWarehouseId],
    queryFn: () => shiftsApi.current(activeWarehouseId!),
    retry: false, throwOnError: false, enabled: !!activeWarehouseId,
  })
  const { data: summary } = useQuery({
    queryKey: ['shift-summary', shift?.id],
    queryFn: () => shiftsApi.summary(shift!.id),
    enabled: !!shift?.id,
  })
  const { data: transactions } = useQuery({
    queryKey: ['shift-txns', shift?.id],
    queryFn: () => shiftsApi.transactions(shift!.id),
    enabled: !!shift?.id,
  })
  const { data: history } = useQuery({
    queryKey: ['shifts', page, activeWarehouseId],
    queryFn: () => shiftsApi.list({
      limit: pageSize,
      offset: page * pageSize,
      ...(activeWarehouseId ? { warehouse_id: activeWarehouseId } : {}),
    }),
  })
  const { data: safes } = useQuery({ queryKey: ['safes'], queryFn: () => api.get('/safes').then(r => r.data) })
  const { data: managers } = useQuery({
    queryKey: ['managers'],
    queryFn: () => api.get('/users/managers').then(r => r.data),
    enabled: showClose || showDeposit || showRevenueDelivery,
  })

  const openMut = useMutation({
    mutationFn: () => shiftsApi.open(Number(initialAmount), activeWarehouseId!),
    onSuccess: () => { toast.success('تم فتح الوردية'); setShowOpen(false); qc.invalidateQueries({ queryKey: ['current-shift'] }); qc.invalidateQueries({ queryKey: ['shifts'] }) },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })
  const closeMut = useMutation({
    mutationFn: async () => {
      const res = await api.post(`/shifts/${shift!.id}/close-with-manager`, {
        closing_balance: Number(closingBalance),
        next_day_drawer: Number(nextDayDrawer || closingBalance),
        manager_id: managerId,
        manager_password: managerPassword,
      })
      // Auto-deposit cash to selected safe
      if (closeSafeId) {
        const cashAmt = Number(closingBalance) - Number(nextDayDrawer || 0)
        if (cashAmt > 0) {
          await api.post(`/safes/${closeSafeId}/deposit`, {
            amount: cashAmt,
            shift_id: shift!.id,
            warehouse_id: activeWarehouseId,
            received_by_id: managerId,
            notes: 'تسليم الدرج عند إغلاق الوردية',
          })
        }
      }
      return res.data
    },
    onSuccess: (d) => {
      const closBal = Number(d.closing_balance || 0)
      const variance = Number(d.variance || 0)
      if (variance !== 0) toast.success(`تم الإغلاق — الدرج: ${closBal.toLocaleString('ar-EG')} ج.م / فرق: ${variance > 0 ? '+' : ''}${variance.toLocaleString('ar-EG')} ج.م`, { duration: 5000 })
      else toast.success(`✅ تم الإغلاق — الدرج: ${closBal.toLocaleString('ar-EG')} ج.م`)
      setShowClose(false); setClosingBalance(''); setNextDayDrawer(''); setManagerPassword(''); setManagerId(''); setCloseSafeId('')
      qc.invalidateQueries({ queryKey: ['current-shift'] }); qc.invalidateQueries({ queryKey: ['shifts'] }); qc.invalidateQueries({ queryKey: ['safes'] })
    },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل إغلاق الوردية'),
  })
  const expenseMut = useMutation({
    mutationFn: () => shiftsApi.addTransaction(shift!.id, { type: 'expense', amount: Number(expenseAmount), note: expenseNote }),
    onSuccess: () => {
      toast.success('تم تسجيل المصروف'); setShowExpense(false); setExpenseAmount(''); setExpenseNote('')
      qc.invalidateQueries({ queryKey: ['shift-summary', shift?.id] }); qc.invalidateQueries({ queryKey: ['shift-txns', shift?.id] })
    },
  })
  const depositMut = useMutation({
    mutationFn: () => api.post(`/safes/${depositSafeId}/deposit`, {
      amount: Number(summary?.cash_in_drawer || 0),
      shift_id: shift?.id,
      warehouse_id: activeWarehouseId,
      received_by_id: depositReceiverId || undefined,
      notes: depositNotes,
    }).then(r => r.data),
    onSuccess: () => {
      toast.success('✅ تم توريد الدرج للخزنة')
      setShowDeposit(false); setDepositNotes(''); setDepositReceiverId('')
      qc.invalidateQueries({ queryKey: ['safes'] })
    },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل التوريد'),
  })
  const revenueMut = useMutation({
    mutationFn: () => shiftsApi.revenueDelivery(shift!.id, {
      amount: Number(revenueAmount),
      safe_id: revenueSafeId,
      manager_id: revenueManagerId,
      manager_password: revenueManagerPassword,
      notes: revenueNotes || undefined,
    }),
    onSuccess: (d: any) => {
      toast.success(`✅ تم تسليم ${Number(d.amount).toLocaleString('ar-EG')} ج.م إلى ${d.safe} — مستند: ${d.doc_number}`)
      setShowRevenueDelivery(false); setRevenueAmount(''); setRevenueSafeId(''); setRevenueManagerId('')
      setRevenueManagerPassword(''); setRevenueNotes('')
      qc.invalidateQueries({ queryKey: ['shift-summary', shift?.id] })
      qc.invalidateQueries({ queryKey: ['shift-txns', shift?.id] })
      qc.invalidateQueries({ queryKey: ['safes'] })
    },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل تسليم الإيرادات'),
  })

  const cashInDrawer = Number(summary?.cash_in_drawer || 0)
  const walletTotal = Number(summary?.wallet_total || 0)
  // Sales-only drawer = initial + cash sales - cash returns - cash expenses - withdrawals - revenue_delivery
  // (excludes deposits which are pass-through funds not belonging to this cashier)
  const depositTotal = Number(summary?.deposits_total || 0)
  const salesOnlyDrawer = cashInDrawer - depositTotal

  const txTypeLabel: Record<string, string> = { sale: 'مبيعات', return_: 'مرتجع', expense: 'مصروف', deposit: 'إيداع', withdrawal: 'سحب', revenue_delivery: 'توريد خزنة' }
  const txColor: Record<string, string> = { sale: 'badge-green', return_: 'badge-red', expense: 'badge-yellow', deposit: 'badge-blue', withdrawal: 'badge-gray', revenue_delivery: 'badge-purple' }

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">الوردية والدرج النقدي</h1>
        {!shift && <button onClick={() => setShowOpen(true)} className="btn-primary"><Plus size={16} /> فتح وردية</button>}
        {shift && (
          <div className="flex gap-2 flex-wrap">
            <button onClick={() => setShowExpense(true)} className="btn-ghost"><TrendingDown size={16} /> مصروف</button>
            <button onClick={() => setShowRevenueDelivery(true)}
              className="px-4 py-2 rounded-xl text-sm font-bold text-white flex items-center gap-2"
              style={{ background: '#2563eb' }}>
              <Landmark size={16} /> تسليم إيرادات
            </button>
            <button onClick={() => setShowDeposit(true)}
              className="px-4 py-2 rounded-xl text-sm font-bold text-white flex items-center gap-2"
              style={{ background: '#16a34a' }}>
              <Vault size={16} /> تسليم الدرج
            </button>
            <button onClick={() => setShowClose(true)} className="btn-danger"><Lock size={16} /> إغلاق الوردية</button>
          </div>
        )}
      </div>

      {isLoading ? <PageLoader /> : (
        <>
          {shift && summary ? (
            <>
              {/* KPI cards */}
              <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-5">
                {[
                  { label: 'الرصيد الافتتاحي', value: summary.initial_amount, icon: Wallet, color: '#1e3a5f' },
                  { label: 'إجمالي المبيعات', value: summary.sales_total, icon: TrendingUp, color: '#16a34a' },
                  { label: 'المصروفات', value: summary.expenses_total, icon: TrendingDown, color: '#dc2626' },
                  { label: 'الرصيد الكلي المتوقع', value: summary.expected_balance, icon: DollarSign, color: '#7c3aed' },
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

              {/* Drawer vs Wallets — the key distinction */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-5">
                {/* Cash drawer */}
                <div className="card p-5" style={{ borderRight: '4px solid #16a34a' }}>
                  <div className="flex items-center gap-3 mb-3">
                    <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: '#dcfce7' }}>
                      <Banknote size={20} style={{ color: '#16a34a' }} />
                    </div>
                    <div>
                      <p className="font-bold text-slate-700">محتوى الدرج النقدي</p>
                      <p className="text-xs text-slate-400">يُسلَّم للخزنة آخر اليوم</p>
                    </div>
                  </div>
                  <p className="text-3xl font-black" style={{ color: '#16a34a' }}>{cashInDrawer.toLocaleString('ar-EG')} ج.م</p>
                  <div className="mt-3 space-y-1 text-xs text-slate-500 border-t border-slate-100 pt-2">
                    <div className="flex justify-between">
                      <span>من مبيعات + عهدة:</span>
                      <span className="font-bold text-slate-700">{salesOnlyDrawer.toLocaleString('ar-EG')} ج.م</span>
                    </div>
                    {depositTotal > 0 && (
                      <div className="flex justify-between">
                        <span>إيداعات خارجية (عابرة):</span>
                        <span className="font-bold text-blue-600">{depositTotal.toLocaleString('ar-EG')} ج.م</span>
                      </div>
                    )}
                  </div>
                </div>

                {/* Wallets — already with owners */}
                <div className="card p-5" style={{ borderRight: '4px solid #c8a84b' }}>
                  <div className="flex items-center gap-3 mb-3">
                    <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: '#fef9c3' }}>
                      <Smartphone size={20} style={{ color: '#c8a84b' }} />
                    </div>
                    <div>
                      <p className="font-bold text-slate-700">محافظ إلكترونية (مع الملاك)</p>
                      <p className="text-xs text-slate-400">فودافون كاش / إنستا باي — تعتبر موردة</p>
                    </div>
                  </div>
                  <p className="text-3xl font-black" style={{ color: '#c8a84b' }}>{walletTotal.toLocaleString('ar-EG')} ج.م</p>
                  {summary.payment_breakdown?.filter((p: any) => p.method !== 'cash').map((p: any) => (
                    <p key={p.wallet_name} className="text-xs text-slate-500 mt-1">
                      {p.wallet_type === 'vodafone_cash' ? '📱' : '💳'} {p.wallet_name}: {Number(p.total).toLocaleString('ar-EG')} ج.م ({p.count} فاتورة)
                    </p>
                  ))}
                </div>
              </div>

              {/* Transactions */}
              {transactions?.length > 0 && (
                <div className="card mb-5">
                  <h3 className="font-bold text-slate-700 mb-3">حركات الوردية ({transactions.length})</h3>
                  <div className="table-wrap max-h-56 overflow-y-auto">
                    <table>
                      <thead><tr><th>الوقت</th><th>النوع</th><th>المبلغ</th><th>ملاحظة</th></tr></thead>
                      <tbody>
                        {transactions.map((t: any) => (
                          <tr key={t.id}>
                            <td className="text-xs text-slate-500">{new Date(t.created_at).toLocaleTimeString('ar-EG')}</td>
                            <td><span className={txColor[t.type] || 'badge-gray'}>{txTypeLabel[t.type] || t.type}</span></td>
                            <td className="font-bold">{Number(t.amount).toLocaleString('ar-EG')} ج.م</td>
                            <td className="text-xs text-slate-500">{t.note || '—'}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}
            </>
          ) : (
            <div className="card text-center py-16 mb-6">
              <Wallet size={48} className="mx-auto mb-4 text-slate-300" />
              <p className="text-slate-500 font-medium text-lg">لا توجد وردية مفتوحة</p>
              <p className="text-slate-400 text-sm mt-1">افتح وردية جديدة لبدء العمل</p>
              <button onClick={() => setShowOpen(true)} className="btn-primary mt-4 mx-auto"><Plus size={16} /> فتح وردية</button>
            </div>
          )}

          {/* History */}
          <div className="card">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-bold text-slate-700">سجل الورديات</h3>
              <div className="flex gap-2">
                <button onClick={() => setPage(p => Math.max(0, p - 1))} disabled={page === 0}
                  className="px-3 py-2 rounded-xl text-xs font-bold bg-slate-100 text-slate-600 disabled:opacity-50">
                  السابق
                </button>
                <button onClick={() => setPage(p => p + 1)} disabled={!history?.length || history.length < pageSize}
                  className="px-3 py-2 rounded-xl text-xs font-bold bg-slate-100 text-slate-600 disabled:opacity-50">
                  التالي
                </button>
              </div>
            </div>
            <div className="table-wrap">
              <table>
                <thead><tr><th>تاريخ الفتح</th><th>تاريخ الإغلاق</th><th>الرصيد الافتتاحي</th><th>الرصيد الختامي</th><th>الحالة</th></tr></thead>
                <tbody>
                  {!history?.length && (
                    <tr><td colSpan={5} className="text-center py-10 text-slate-400">لا توجد بيانات</td></tr>
                  )}
                  {history?.map((s: any) => (
                    <tr key={s.id}>
                      <td className="text-sm">{new Date(s.started_at).toLocaleString('ar-EG')}</td>
                      <td className="text-sm text-slate-500">{s.closed_at ? new Date(s.closed_at).toLocaleString('ar-EG') : '—'}</td>
                      <td className="font-semibold">{Number(s.initial_amount).toLocaleString('ar-EG')} ج.م</td>
                      <td className="font-semibold">{s.closing_balance != null ? `${Number(s.closing_balance).toLocaleString('ar-EG')} ج.م` : '—'}</td>
                      <td><span className={s.status === 'open' ? 'badge-green' : 'badge-gray'}>{s.status === 'open' ? 'مفتوحة' : 'مغلقة'}</span></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </>
      )}

      {/* Open shift */}
      <Modal open={showOpen} onClose={() => setShowOpen(false)} title="فتح وردية جديدة">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">عهدة الدرج الافتتاحية (ج.م)</label>
            <input type="number" className="input" value={initialAmount} onChange={e => setInitialAmount(e.target.value)} placeholder="0.00" autoFocus />
          </div>
          <div className="flex gap-3 justify-end">
            <button onClick={() => setShowOpen(false)} className="btn-ghost">إلغاء</button>
            <button onClick={() => openMut.mutate()} disabled={openMut.isPending} className="btn-primary">فتح الوردية</button>
          </div>
        </div>
      </Modal>

      {/* Close shift */}
      <Modal open={showClose} onClose={() => setShowClose(false)} title="إغلاق الوردية — يتطلب موافقة مدير">
        <div className="space-y-4">
          {summary && (
            <div className="bg-slate-50 rounded-xl p-4 text-sm space-y-2">
              <div className="flex justify-between"><span className="text-slate-500">من مبيعات + عهدة:</span><span className="font-black text-green-700">{salesOnlyDrawer.toLocaleString('ar-EG')} ج.م</span></div>
              {depositTotal > 0 && (
                <div className="flex justify-between"><span className="text-slate-500">إيداعات خارجية (عابرة):</span><span className="font-bold text-blue-600">{depositTotal.toLocaleString('ar-EG')} ج.م</span></div>
              )}
              <div className="flex justify-between border-t pt-2"><span className="text-slate-500">إجمالي الدرج المتوقع:</span><span className="font-black text-green-700">{cashInDrawer.toLocaleString('ar-EG')} ج.م</span></div>
              <div className="flex justify-between"><span className="text-slate-500">محافظ إلكترونية (مع الملاك):</span><span className="font-bold text-amber-600">{walletTotal.toLocaleString('ar-EG')} ج.م</span></div>
              <div className="flex justify-between border-t pt-2"><span className="text-slate-500">إجمالي المبيعات:</span><span className="font-bold">{Number(summary.sales_total).toLocaleString('ar-EG')} ج.م</span></div>
            </div>
          )}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-slate-600 mb-1">الرصيد الفعلي في الدرج *</label>
              <input type="number" className="input" value={closingBalance} onChange={e => setClosingBalance(e.target.value)} placeholder="0.00" />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-600 mb-1">عهدة اليوم التالي</label>
              <input type="number" className="input" value={nextDayDrawer} onChange={e => setNextDayDrawer(e.target.value)} placeholder={closingBalance || '0.00'} />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">توريد الدرج إلى خزنة *</label>
            <select className="input" value={closeSafeId} onChange={e => setCloseSafeId(e.target.value)}>
              <option value="">اختر الخزنة...</option>
              {safes?.map((s: any) => <option key={s.id} value={s.id}>{s.name} — {Number(s.balance).toLocaleString('ar-EG')} ج.م</option>)}
            </select>
          </div>
          <div className="border-t border-slate-200 pt-4">
            <p className="text-xs font-bold text-slate-500 mb-3">توقيع المدير</p>
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
            <button onClick={() => setShowClose(false)} className="btn-ghost">إلغاء</button>
            <button onClick={() => closeMut.mutate()} disabled={closeMut.isPending || !managerId || !managerPassword || !closingBalance || Number(closingBalance) <= 0 || !closeSafeId}
              className="px-5 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#dc2626' }}>
              {closeMut.isPending ? 'جاري الإغلاق...' : 'إغلاق الوردية'}
            </button>
          </div>
        </div>
      </Modal>

      {/* Expense */}
      <Modal open={showExpense} onClose={() => setShowExpense(false)} title="تسجيل مصروف">
        <div className="space-y-4">
          <input type="number" className="input" value={expenseAmount} onChange={e => setExpenseAmount(e.target.value)} placeholder="المبلغ (ج.م)" autoFocus />
          <input className="input" value={expenseNote} onChange={e => setExpenseNote(e.target.value)} placeholder="البيان..." />
          <div className="flex gap-3 justify-end">
            <button onClick={() => setShowExpense(false)} className="btn-ghost">إلغاء</button>
            <button onClick={() => expenseMut.mutate()} disabled={expenseMut.isPending} className="btn-primary">تسجيل</button>
          </div>
        </div>
      </Modal>

      {/* Revenue delivery */}
      <Modal open={showRevenueDelivery} onClose={() => { setShowRevenueDelivery(false); setRevenueAmount(''); setRevenueSafeId(''); setRevenueManagerId(''); setRevenueManagerPassword(''); setRevenueNotes('') }} title="تسليم إيرادات إلى الخزنة">
        <div className="space-y-4">
          <div className="rounded-xl p-4 text-center" style={{ background: '#eff6ff', border: '1px solid #bfdbfe' }}>
            <p className="text-xs font-medium mb-1" style={{ color: '#2563eb' }}>الرصيد النقدي المتوقع في الدرج</p>
            <p className="text-3xl font-black" style={{ color: '#2563eb' }}>{cashInDrawer.toLocaleString('ar-EG')} ج.م</p>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">المبلغ المسلَّم *</label>
            <input type="number" className="input" value={revenueAmount} onChange={e => setRevenueAmount(e.target.value)} placeholder="0.00" autoFocus />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">الخزنة المستقبِلة *</label>
            <select className="input" value={revenueSafeId} onChange={e => setRevenueSafeId(e.target.value)}>
              <option value="">اختر الخزنة...</option>
              {safes?.map((s: any) => <option key={s.id} value={s.id}>{s.name} — {Number(s.balance).toLocaleString('ar-EG')} ج.م</option>)}
            </select>
          </div>
          <input className="input" value={revenueNotes} onChange={e => setRevenueNotes(e.target.value)} placeholder="ملاحظات (اختياري)" />
          <div className="border-t border-slate-200 pt-4">
            <p className="text-xs font-bold text-slate-500 mb-3">توقيع المدير</p>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-slate-600 mb-1">المدير *</label>
                <select className="input" value={revenueManagerId} onChange={e => setRevenueManagerId(e.target.value)}>
                  <option value="">اختر مديراً...</option>
                  {managers?.map((m: any) => <option key={m.id} value={m.id}>{m.full_name}</option>)}
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-600 mb-1">كلمة مرور المدير *</label>
                <input type="password" className="input" value={revenueManagerPassword} onChange={e => setRevenueManagerPassword(e.target.value)} placeholder="••••••" />
              </div>
            </div>
          </div>
          <div className="flex gap-3 justify-end">
            <button onClick={() => setShowRevenueDelivery(false)} className="btn-ghost">إلغاء</button>
            <button onClick={() => revenueMut.mutate()} disabled={revenueMut.isPending || !revenueAmount || !revenueSafeId || !revenueManagerId || !revenueManagerPassword}
              className="px-5 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#2563eb' }}>
              {revenueMut.isPending ? 'جاري...' : 'تأكيد التسليم'}
            </button>
          </div>
        </div>
      </Modal>

      {/* Deposit drawer to safe */}
      <Modal open={showDeposit} onClose={() => { setShowDeposit(false); setDepositNotes(''); setDepositReceiverId('') }} title="تسليم الدرج النقدي للخزنة">
        <div className="space-y-4">
          <div className="rounded-xl p-4 text-center" style={{ background: '#f0fdf4', border: '1px solid #bbf7d0' }}>
            <p className="text-xs font-medium mb-1" style={{ color: '#16a34a' }}>محتوى الدرج النقدي</p>
            <p className="text-3xl font-black" style={{ color: '#16a34a' }}>{cashInDrawer.toLocaleString('ar-EG')} ج.م</p>
            {walletTotal > 0 && (
              <p className="text-xs mt-2" style={{ color: '#92400e' }}>
                ⚠️ المحافظ الإلكترونية ({walletTotal.toLocaleString('ar-EG')} ج.م) مع الملاك — لا تُورَّد هنا
              </p>
            )}
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">الخزنة المستقبِلة *</label>
            <select className="input" value={depositSafeId} onChange={e => setDepositSafeId(e.target.value)}>
              <option value="">اختر الخزنة...</option>
              {safes?.map((s: any) => <option key={s.id} value={s.id}>{s.name} — {Number(s.balance).toLocaleString('ar-EG')} ج.م</option>)}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">استلم المبلغ *</label>
            <select className="input" value={depositReceiverId} onChange={e => setDepositReceiverId(e.target.value)}>
              <option value="">اختر المستلم...</option>
              {managers?.map((m: any) => <option key={m.id} value={m.id}>{m.full_name}</option>)}
            </select>
          </div>
          <input className="input" value={depositNotes} onChange={e => setDepositNotes(e.target.value)} placeholder="ملاحظات (اختياري)" />
          <div className="flex gap-3 justify-end">
            <button onClick={() => setShowDeposit(false)} className="btn-ghost">إلغاء</button>
            <button onClick={() => depositMut.mutate()} disabled={!depositSafeId || !depositReceiverId || depositMut.isPending}
              className="px-5 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#16a34a' }}>
              {depositMut.isPending ? 'جاري...' : 'تأكيد التسليم'}
            </button>
          </div>
        </div>
      </Modal>
    </div>
  )
}
