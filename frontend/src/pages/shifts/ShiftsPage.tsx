import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '../../components/ui/table'
import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { shiftsApi } from '../../api/endpoints'
import api from '../../api/client'
import { useAppStore } from '../../store/app'
import { PageLoader } from '../../components/ui/Loaders'
import Modal from '../../components/ui/Modal'
import toast from 'react-hot-toast'
import { Wallet, Plus, Lock, TrendingUp, TrendingDown, DollarSign, Vault, Smartphone, Banknote, Landmark } from 'lucide-react'
import { Button } from '../../components/ui/button'
import { Input } from '../../components/ui/input'
import { Select } from '../../components/ui/select'
import { Badge } from '../../components/ui/badge'

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
  const txColor: Record<string, string> = { sale: 'green', return_: 'red', expense: 'yellow', deposit: 'blue', withdrawal: 'gray', revenue_delivery: 'purple' }

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">الوردية والدرج النقدي</h1>
        {!shift && <Button onClick={() => setShowOpen(true)}><Plus size={16} /> فتح وردية</Button>}
        {shift && (
          <div className="flex gap-2 flex-wrap">
            <Button onClick={() => setShowExpense(true)} variant="ghost"><TrendingDown size={16} /> مصروف</Button>
            <Button onClick={() => setShowRevenueDelivery(true)}>
              <Landmark size={16} /> تسليم إيرادات
            </Button>
            <Button onClick={() => setShowDeposit(true)}>
              <Vault size={16} /> تسليم الدرج
            </Button>
            <Button onClick={() => setShowClose(true)} variant="destructive"><Lock size={16} /> إغلاق الوردية</Button>
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
                  { label: 'الرصيد الافتتاحي', value: summary.initial_amount, icon: Wallet, color: 'var(--primary)' },
                  { label: 'إجمالي المبيعات', value: summary.sales_total, icon: TrendingUp, color: '#16a34a' },
                  { label: 'المصروفات', value: summary.expenses_total, icon: TrendingDown, color: '#dc2626' },
                  { label: 'الرصيد الكلي المتوقع', value: summary.expected_balance, icon: DollarSign, color: '#7c3aed' },
                ].map(({ label, value, icon: Icon, color }) => (
                  <div key={label} className="stat-card">
                    <div className="stat-icon" style={{ background: color + '20' }}><Icon size={20} style={{ color }} /></div>
                    <div>
                      <p className="text-[var(--muted)] text-xs mb-1">{label}</p>
                      <p className="text-lg font-black text-[var(--text)]">{Number(value).toLocaleString('ar-EG')} ج.م</p>
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
                      <Banknote size={20} className="text-green-600" />
                    </div>
                    <div>
                      <p className="font-bold text-[var(--text)]">محتوى الدرج النقدي</p>
                      <p className="text-xs text-[var(--muted)]">يُسلَّم للخزنة آخر اليوم</p>
                    </div>
                  </div>
                  <p className="text-3xl font-black text-green-600">{cashInDrawer.toLocaleString('ar-EG')} ج.م</p>
                  <div className="mt-3 space-y-1 text-xs text-[var(--muted)] border-t border-[var(--border-faint)] pt-2">
                    <div className="flex justify-between">
                      <span>من مبيعات + عهدة:</span>
                      <span className="font-bold text-[var(--text)]">{salesOnlyDrawer.toLocaleString('ar-EG')} ج.م</span>
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
                <div className="card p-5" style={{ borderRight: '4px solid var(--accent)' }}>
                  <div className="flex items-center gap-3 mb-3">
                    <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: '#fef9c3' }}>
                      <Smartphone size={20} style={{ color: 'var(--accent)' }} />
                    </div>
                    <div>
                      <p className="font-bold text-[var(--text)]">محافظ إلكترونية (مع الملاك)</p>
                      <p className="text-xs text-[var(--muted)]">فودافون كاش / إنستا باي — تعتبر موردة</p>
                    </div>
                  </div>
                  <p className="text-3xl font-black" style={{ color: 'var(--accent)' }}>{walletTotal.toLocaleString('ar-EG')} ج.م</p>
                  {summary.payment_breakdown?.filter((p: any) => p.method !== 'cash').map((p: any) => (
                    <p key={p.wallet_name} className="text-xs text-[var(--muted)] mt-1">
                      {p.wallet_type === 'vodafone_cash' ? '📱' : '💳'} {p.wallet_name}: {Number(p.total).toLocaleString('ar-EG')} ج.م ({p.count} فاتورة)
                    </p>
                  ))}
                </div>
              </div>

              {/* Transactions */}
              {transactions?.length > 0 && (
                <div className="card mb-5">
                  <h3 className="font-bold text-[var(--text)] mb-3">حركات الوردية ({transactions.length})</h3>
                  <div className="table-wrap max-h-56 overflow-y-auto">
                    <Table>
                      <TableHeader><TableRow><TableHead>الوقت</TableHead><TableHead>النوع</TableHead><TableHead>المبلغ</TableHead><TableHead>ملاحظة</TableHead></TableRow></TableHeader>
                      <TableBody>
                        {transactions.map((t: any) => (
                          <TableRow key={t.id}>
                            <TableCell className="text-xs text-[var(--muted)]">{new Date(t.created_at).toLocaleTimeString('ar-EG')}</TableCell>
                            <TableCell><Badge variant={(txColor as any)[t.type] || 'gray'}>{txTypeLabel[t.type] || t.type}</Badge></TableCell>
                            <TableCell className="font-bold">{Number(t.amount).toLocaleString('ar-EG')} ج.م</TableCell>
                            <TableCell className="text-xs text-[var(--muted)]">{t.note || '—'}</TableCell>
                          </TableRow>
                        ))}
                      </TableBody>
                    </Table>
                  </div>
                </div>
              )}
            </>
          ) : (
            <div className="card text-center py-16 mb-6">
              <Wallet size={48} className="mx-auto mb-4 text-[var(--faint)]" />
              <p className="text-[var(--muted)] font-medium text-lg">لا توجد وردية مفتوحة</p>
              <p className="text-[var(--muted)] text-sm mt-1">افتح وردية جديدة لبدء العمل</p>
              <Button onClick={() => setShowOpen(true)} className="mt-4 mx-auto"><Plus size={16} /> فتح وردية</Button>
            </div>
          )}

          {/* History */}
          <div className="card">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-bold text-[var(--text)]">سجل الورديات</h3>
              <div className="flex gap-2">
                <Button onClick={() => setPage(p => Math.max(0, p - 1))} disabled={page === 0}
                  size="sm">
                  السابق
                </Button>
                <Button onClick={() => setPage(p => p + 1)} disabled={!history?.length || history.length < pageSize}
                  size="sm">
                  التالي
                </Button>
              </div>
            </div>
            <div className="table-wrap">
              <Table>
                <TableHeader><TableRow><TableHead>تاريخ الفتح</TableHead><TableHead>تاريخ الإغلاق</TableHead><TableHead>الرصيد الافتتاحي</TableHead><TableHead>الرصيد الختامي</TableHead><TableHead>الحالة</TableHead></TableRow></TableHeader>
                <TableBody>
                  {!history?.length && (
                    <TableRow><TableCell colSpan={5} className="text-center py-10 text-[var(--muted)]">لا توجد بيانات</TableCell></TableRow>
                  )}
                  {history?.map((s: any) => (
                    <TableRow key={s.id}>
                      <TableCell className="text-sm">{new Date(s.started_at).toLocaleString('ar-EG')}</TableCell>
                      <TableCell className="text-sm text-[var(--muted)]">{s.closed_at ? new Date(s.closed_at).toLocaleString('ar-EG') : '—'}</TableCell>
                      <TableCell className="font-semibold">{Number(s.initial_amount).toLocaleString('ar-EG')} ج.م</TableCell>
                      <TableCell className="font-semibold">{s.closing_balance != null ? `${Number(s.closing_balance).toLocaleString('ar-EG')} ج.م` : '—'}</TableCell>
                      <TableCell><Badge variant={s.status === 'open' ? 'green' : 'gray'}>{s.status === 'open' ? 'مفتوحة' : 'مغلقة'}</Badge></TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          </div>
        </>
      )}

      {/* Open shift */}
      <Modal open={showOpen} onClose={() => setShowOpen(false)} title="فتح وردية جديدة">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">عهدة الدرج الافتتاحية (ج.م)</label>
 <Input type="number" value={initialAmount} onChange={e => setInitialAmount(e.target.value)} placeholder="0.00" autoFocus/>
          </div>
          <div className="flex gap-3 justify-end">
            <Button onClick={() => setShowOpen(false)} variant="ghost">إلغاء</Button>
            <Button onClick={() => openMut.mutate()} disabled={openMut.isPending}>فتح الوردية</Button>
          </div>
        </div>
      </Modal>

      {/* Close shift */}
      <Modal open={showClose} onClose={() => setShowClose(false)} title="إغلاق الوردية — يتطلب موافقة مدير">
        <div className="space-y-4">
          {summary && (
            <div className="bg-[var(--surface-2)] rounded-xl p-4 text-sm space-y-2">
              <div className="flex justify-between"><span className="text-[var(--muted)]">من مبيعات + عهدة:</span><span className="font-black text-green-700">{salesOnlyDrawer.toLocaleString('ar-EG')} ج.م</span></div>
              {depositTotal > 0 && (
                <div className="flex justify-between"><span className="text-[var(--muted)]">إيداعات خارجية (عابرة):</span><span className="font-bold text-blue-600">{depositTotal.toLocaleString('ar-EG')} ج.م</span></div>
              )}
              <div className="flex justify-between border-t pt-2"><span className="text-[var(--muted)]">إجمالي الدرج المتوقع:</span><span className="font-black text-green-700">{cashInDrawer.toLocaleString('ar-EG')} ج.م</span></div>
              <div className="flex justify-between"><span className="text-[var(--muted)]">محافظ إلكترونية (مع الملاك):</span><span className="font-bold text-amber-600">{walletTotal.toLocaleString('ar-EG')} ج.م</span></div>
              <div className="flex justify-between border-t pt-2"><span className="text-[var(--muted)]">إجمالي المبيعات:</span><span className="font-bold">{Number(summary.sales_total).toLocaleString('ar-EG')} ج.م</span></div>
            </div>
          )}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الرصيد الفعلي في الدرج *</label>
 <Input type="number" value={closingBalance} onChange={e => setClosingBalance(e.target.value)} placeholder="0.00"/>
            </div>
            <div>
              <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">عهدة اليوم التالي</label>
 <Input type="number" value={nextDayDrawer} onChange={e => setNextDayDrawer(e.target.value)} placeholder={closingBalance || '0.00'}/>
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">توريد الدرج إلى خزنة *</label>
            <Select value={closeSafeId} onChange={e => setCloseSafeId(e.target.value)}>
              <option value="">اختر الخزنة...</option>
              {safes?.map((s: any) => <option key={s.id} value={s.id}>{s.name} — {Number(s.balance).toLocaleString('ar-EG')} ج.م</option>)}
            </Select>
          </div>
          <div className="border-t border-[var(--border)] pt-4">
            <p className="text-xs font-bold text-[var(--muted)] mb-3">توقيع المدير</p>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">المدير *</label>
                <Select value={managerId} onChange={e => setManagerId(e.target.value)}>
                  <option value="">اختر مديراً...</option>
                  {managers?.map((m: any) => <option key={m.id} value={m.id}>{m.full_name}</option>)}
                </Select>
              </div>
              <div>
                <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">كلمة مرور المدير *</label>
 <Input type="password" value={managerPassword} onChange={e => setManagerPassword(e.target.value)} placeholder="••••••"/>
              </div>
            </div>
          </div>
          <div className="flex gap-3 justify-end">
            <Button onClick={() => setShowClose(false)} variant="ghost">إلغاء</Button>
            <Button onClick={() => closeMut.mutate()} disabled={closeMut.isPending || !managerId || !managerPassword || !closingBalance || Number(closingBalance) <= 0 || !closeSafeId}
              variant="destructive">
              {closeMut.isPending ? 'جاري الإغلاق...' : 'إغلاق الوردية'}
            </Button>
          </div>
        </div>
      </Modal>

      {/* Expense */}
      <Modal open={showExpense} onClose={() => setShowExpense(false)} title="تسجيل مصروف">
        <div className="space-y-4">
 <Input type="number" value={expenseAmount} onChange={e => setExpenseAmount(e.target.value)} placeholder="المبلغ (ج.م)" autoFocus/>
 <Input value={expenseNote} onChange={e => setExpenseNote(e.target.value)} placeholder="البيان..."/>
          <div className="flex gap-3 justify-end">
            <Button onClick={() => setShowExpense(false)} variant="ghost">إلغاء</Button>
            <Button onClick={() => expenseMut.mutate()} disabled={expenseMut.isPending}>تسجيل</Button>
          </div>
        </div>
      </Modal>

      {/* Revenue delivery */}
      <Modal open={showRevenueDelivery} onClose={() => { setShowRevenueDelivery(false); setRevenueAmount(''); setRevenueSafeId(''); setRevenueManagerId(''); setRevenueManagerPassword(''); setRevenueNotes('') }} title="تسليم إيرادات إلى الخزنة">
        <div className="space-y-4">
          <div className="rounded-xl p-4 text-center" style={{ background: '#eff6ff', border: '1px solid #bfdbfe' }}>
            <p className="text-xs font-medium mb-1 text-blue-600">الرصيد النقدي المتوقع في الدرج</p>
            <p className="text-3xl font-black text-blue-600">{cashInDrawer.toLocaleString('ar-EG')} ج.م</p>
          </div>
          <div>
            <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">المبلغ المسلَّم *</label>
 <Input type="number" value={revenueAmount} onChange={e => setRevenueAmount(e.target.value)} placeholder="0.00" autoFocus/>
          </div>
          <div>
            <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الخزنة المستقبِلة *</label>
            <Select value={revenueSafeId} onChange={e => setRevenueSafeId(e.target.value)}>
              <option value="">اختر الخزنة...</option>
              {safes?.map((s: any) => <option key={s.id} value={s.id}>{s.name} — {Number(s.balance).toLocaleString('ar-EG')} ج.م</option>)}
            </Select>
          </div>
 <Input value={revenueNotes} onChange={e => setRevenueNotes(e.target.value)} placeholder="ملاحظات (اختياري)"/>
          <div className="border-t border-[var(--border)] pt-4">
            <p className="text-xs font-bold text-[var(--muted)] mb-3">توقيع المدير</p>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">المدير *</label>
                <Select value={revenueManagerId} onChange={e => setRevenueManagerId(e.target.value)}>
                  <option value="">اختر مديراً...</option>
                  {managers?.map((m: any) => <option key={m.id} value={m.id}>{m.full_name}</option>)}
                </Select>
              </div>
              <div>
                <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">كلمة مرور المدير *</label>
 <Input type="password" value={revenueManagerPassword} onChange={e => setRevenueManagerPassword(e.target.value)} placeholder="••••••"/>
              </div>
            </div>
          </div>
          <div className="flex gap-3 justify-end">
            <Button onClick={() => setShowRevenueDelivery(false)} variant="ghost">إلغاء</Button>
            <Button onClick={() => revenueMut.mutate()} disabled={revenueMut.isPending || !revenueAmount || !revenueSafeId || !revenueManagerId || !revenueManagerPassword}>
              {revenueMut.isPending ? 'جاري...' : 'تأكيد التسليم'}
            </Button>
          </div>
        </div>
      </Modal>

      {/* Deposit drawer to safe */}
      <Modal open={showDeposit} onClose={() => { setShowDeposit(false); setDepositNotes(''); setDepositReceiverId('') }} title="تسليم الدرج النقدي للخزنة">
        <div className="space-y-4">
          <div className="rounded-xl p-4 text-center" style={{ background: '#f0fdf4', border: '1px solid #bbf7d0' }}>
            <p className="text-xs font-medium mb-1 text-green-600">محتوى الدرج النقدي</p>
            <p className="text-3xl font-black text-green-600">{cashInDrawer.toLocaleString('ar-EG')} ج.م</p>
            {walletTotal > 0 && (
              <p className="text-xs mt-2 text-amber-800">
                ⚠️ المحافظ الإلكترونية ({walletTotal.toLocaleString('ar-EG')} ج.م) مع الملاك — لا تُورَّد هنا
              </p>
            )}
          </div>
          <div>
            <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الخزنة المستقبِلة *</label>
            <Select value={depositSafeId} onChange={e => setDepositSafeId(e.target.value)}>
              <option value="">اختر الخزنة...</option>
              {safes?.map((s: any) => <option key={s.id} value={s.id}>{s.name} — {Number(s.balance).toLocaleString('ar-EG')} ج.م</option>)}
            </Select>
          </div>
          <div>
            <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">استلم المبلغ *</label>
            <Select value={depositReceiverId} onChange={e => setDepositReceiverId(e.target.value)}>
              <option value="">اختر المستلم...</option>
              {managers?.map((m: any) => <option key={m.id} value={m.id}>{m.full_name}</option>)}
            </Select>
          </div>
 <Input value={depositNotes} onChange={e => setDepositNotes(e.target.value)} placeholder="ملاحظات (اختياري)"/>
          <div className="flex gap-3 justify-end">
            <Button onClick={() => setShowDeposit(false)} variant="ghost">إلغاء</Button>
            <Button onClick={() => depositMut.mutate()} disabled={!depositSafeId || !depositReceiverId || depositMut.isPending}>
              {depositMut.isPending ? 'جاري...' : 'تأكيد التسليم'}
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  )
}
