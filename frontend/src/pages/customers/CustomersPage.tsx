import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { customersApi } from '../../api/endpoints'
import { PageLoader, EmptyState } from '../../components/ui/Loaders'
import Modal from '../../components/ui/Modal'
import toast from 'react-hot-toast'
import { Search, Plus, TrendingUp, TrendingDown, DollarSign, Pencil, Trash2, Wallet } from 'lucide-react'
import ExportButton from '../../components/ui/ExportButton'
import { Input } from '../../components/ui/input'
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '../../components/ui/table'
import { Badge } from '../../components/ui/badge'
import { Button } from '../../components/ui/button'

export default function CustomersPage() {
  const [search, setSearch] = useState('')
  const [selected, setSelected] = useState<any>(null)
  const [showAdd, setShowAdd] = useState(false)
  const [showEdit, setShowEdit] = useState(false)
  const [showPayment, setShowPayment] = useState(false)
  const [showBalance, setShowBalance] = useState(false)
  const [balanceAmount, setBalanceAmount] = useState('')
  const [newName, setNewName] = useState('')
  const [newPhone, setNewPhone] = useState('')
  const [newCreditLimit, setNewCreditLimit] = useState('')
  const [newAddress, setNewAddress] = useState('')
  const [payAmount, setPayAmount] = useState('')
  const [payNote, setPayNote] = useState('')
  const qc = useQueryClient()

  const { data: customers, isLoading } = useQuery({
    queryKey: ['customers', search], queryFn: () => customersApi.list(search || undefined),
  })
  const { data: account } = useQuery({
    queryKey: ['customer-account', selected?.id], queryFn: () => customersApi.account(selected.id), enabled: !!selected,
  })
  const { data: ledger } = useQuery({
    queryKey: ['customer-ledger', selected?.id], queryFn: () => customersApi.ledger(selected.id), enabled: !!selected,
  })

  const createMut = useMutation({
    mutationFn: () => customersApi.create({ name: newName, phone: newPhone, credit_limit: newCreditLimit ? Number(newCreditLimit) : null, address: newAddress || undefined }),
    onSuccess: () => { toast.success('تمت الإضافة'); setShowAdd(false); resetForm(); qc.invalidateQueries({ queryKey: ['customers'] }) },
  })
  const editMut = useMutation({
    mutationFn: () => customersApi.update(selected.id, { name: newName, phone: newPhone, credit_limit: newCreditLimit ? Number(newCreditLimit) : null, address: newAddress || undefined }),
    onSuccess: () => { toast.success('تم التعديل'); setShowEdit(false); qc.invalidateQueries({ queryKey: ['customers'] }); qc.invalidateQueries({ queryKey: ['customer-account', selected?.id] }); setSelected({ ...selected, name: newName, phone: newPhone, credit_limit: newCreditLimit ? Number(newCreditLimit) : null }) },
  })
  const deleteMut = useMutation({
    mutationFn: () => customersApi.delete(selected.id),
    onSuccess: () => { toast.success('تم الحذف'); setSelected(null); qc.invalidateQueries({ queryKey: ['customers'] }) },
  })
  const balanceMut = useMutation({
    mutationFn: () => customersApi.setBalance(selected.id, Number(balanceAmount)),
    onSuccess: () => {
      toast.success('تم تعديل المديونية')
      setShowBalance(false)
      qc.invalidateQueries({ queryKey: ['customer-account', selected?.id] })
      qc.invalidateQueries({ queryKey: ['customers'] })
    },
  })

  const paymentMut = useMutation({
    mutationFn: () => customersApi.addPayment(selected.id, Number(payAmount), payNote),
    onSuccess: () => {
      toast.success('تم تسجيل الدفعة')
      setShowPayment(false); setPayAmount(''); setPayNote('')
      qc.invalidateQueries({ queryKey: ['customer-account', selected?.id] })
      qc.invalidateQueries({ queryKey: ['customer-ledger', selected?.id] })
    },
  })

  function resetForm() { setNewName(''); setNewPhone(''); setNewCreditLimit(''); setNewAddress('') }
  function openEdit(c: any) { setNewName(c.name); setNewPhone(c.phone || ''); setNewCreditLimit(c.credit_limit || ''); setNewAddress(c.address || ''); setShowEdit(true) }
  function openDelete(c: any) { if (confirm(`حذف العميل "${c.name}"؟`)) { setSelected(c); deleteMut.mutate() } }

  const typeLabel: Record<string, string> = { invoice: 'فاتورة', return: 'مرتجع', payment: 'دفعة' }
  const typeBadge: Record<string, string> = { invoice: 'blue', return: 'red', payment: 'green' }

  return (
    <div className="flex gap-5 h-[calc(100vh-3rem)]">
      {/* Customer list */}
      <div className="w-72 flex-shrink-0 flex flex-col">
        <div className="page-header mb-4">
          <h1 className="page-title">العملاء</h1>
          <div className="flex items-center gap-3">
            <ExportButton data={customers || []} columns={[
              { label: 'الاسم', accessor: (c: any) => c.name },
              { label: 'الهاتف', accessor: (c: any) => c.phone || '' },
              { label: 'الرصيد', accessor: (c: any) => Number(c.balance_due) },
              { label: 'حد الائتمان', accessor: (c: any) => Number(c.credit_limit || 0) },
            ]} filename="العملاء" excelEndpoint="/export/customers" />
            <Button onClick={() => setShowAdd(true)} className="px-4">
              <Plus size={14} /> إضافة
            </Button>
          </div>
        </div>
        <div className="relative mb-3">
          <Search size={14} className="absolute right-3 top-1/2 -translate-y-1/2 text-[var(--muted)]" />
 <Input className="pr-9 text-sm" placeholder="بحث..." value={search} onChange={e => setSearch(e.target.value)}/>
        </div>
        {isLoading ? <PageLoader /> : (
          <div className="flex-1 overflow-y-auto space-y-2">
            {!customers?.length && <EmptyState message="لا يوجد عملاء" icon="👤" />}
            {customers?.map((c: any) => (
              <Button key={c.id} onClick={() => setSelected(c)} variant="ghost"
                className={`w-full text-right p-3 rounded-xl border transition-all h-auto ${selected?.id === c.id ? 'border-[var(--primary)] bg-[var(--primary-soft)]' : 'bg-[var(--surface)] border-[var(--border-faint)] hover:border-[var(--border)] hover:shadow-sm'}`}>
                <div className="flex items-center justify-between">
                  <div>
                    <p className="font-bold text-[var(--text)] text-sm">{c.name}</p>
                    {c.phone && <p className="text-xs text-[var(--muted)] mt-0.5">{c.phone}</p>}
                  </div>
                  <span className="flex items-center gap-1">
                    {c.credit_limit && (
                      <span className="text-[10px] text-[var(--muted)] ml-1" title="حد الائتمان">{Number(c.credit_limit).toLocaleString('ar-EG')}</span>
                    )}
                    {Number(c.balance_due) > 0 && (
                      <span className="text-xs font-black text-amber-700 bg-amber-50 px-2 py-0.5 rounded-full">
                        {Number(c.balance_due).toLocaleString('ar-EG')} ج.م
                      </span>
                    )}
                  </span>
                </div>
              </Button>
            ))}
          </div>
        )}
      </div>

      {/* Customer detail */}
      <div className="flex-1 flex flex-col min-w-0">
        {!selected ? (
          <div className="flex-1 flex items-center justify-center text-[var(--muted)]">
            <div className="text-center"><p className="text-4xl mb-3">👤</p><p>اختر عميلاً لعرض حسابه</p></div>
          </div>
        ) : (
          <>
            {/* Account summary */}
            <div className="flex items-center justify-between mb-5">
              <div>
                <h2 className="text-xl font-black text-[var(--text)]">{selected.name}</h2>
                {selected.phone && <p className="text-[var(--muted)] text-sm">{selected.phone}</p>}
              </div>
              <div className="flex items-center gap-2">
                <Button variant="secondary" onClick={() => openEdit(selected)} className="px-3">
                  <Pencil size={14} /> تعديل
                </Button>
                <Button variant="destructive" onClick={() => openDelete(selected)} className="px-3">
                  <Trash2 size={14} /> حذف
                </Button>
                <Button onClick={() => { setBalanceAmount(String(account?.balance_due || 0)); setShowBalance(true) }} className="px-3 bg-amber-50 text-amber-700 hover:bg-amber-100">
                  <Wallet size={14} /> تعديل المديونية
                </Button>
                <Button onClick={() => setShowPayment(true)} className="bg-[#16a34a] hover:bg-[#16a34a]/90 px-5">
                  <DollarSign size={15} /> تسجيل دفعة
                </Button>
              </div>
            </div>

            {account && (
              <>
                <div className="grid grid-cols-4 gap-4 mb-2">
                  {[
                    { label: 'إجمالي الفواتير', value: account.total_invoiced, color: 'var(--primary)', icon: TrendingUp },
                    { label: 'المرتجعات', value: account.total_returned, color: '#dc2626', icon: TrendingDown },
                    { label: 'المدفوع', value: account.total_paid, color: '#16a34a', icon: DollarSign },
                    { label: 'المتبقي', value: account.balance_due, color: account.balance_due > 0 ? '#d97706' : '#16a34a', icon: DollarSign },
                  ].map(({ label, value, color, icon: Icon }) => (
                    <div key={label} className="stat-card">
                      <div className="stat-icon" style={{ background: color + '20' }}><Icon size={18} style={{ color }} /></div>
                      <div>
                        <p className="text-[var(--muted)] text-xs mb-0.5">{label}</p>
                        <p className="text-lg font-black" style={{ color }}>{Number(value).toLocaleString('ar-EG')} ج.م</p>
                      </div>
                    </div>
                  ))}
                </div>
                {selected.credit_limit ? (
                  <div className={`mb-5 px-4 py-2 rounded-xl text-sm flex items-center gap-2 ${
                    Number(account.balance_due) > Number(selected.credit_limit)
                      ? 'bg-red-50 border border-red-200 text-red-700'
                      : Number(account.balance_due) > Number(selected.credit_limit) * 0.8
                        ? 'bg-amber-50 border border-amber-200 text-amber-700'
                        : 'bg-green-50 border border-green-200 text-green-700'
                  }`}>
                    <span>حد الائتمان: {Number(selected.credit_limit).toLocaleString('ar-EG')} ج.م</span>
                    <span className="mx-2">|</span>
                    <span>المتبقي من الحد: {Math.max(0, Number(selected.credit_limit) - Number(account.balance_due)).toLocaleString('ar-EG')} ج.م</span>
                  </div>
                ) : (
                  <div className="mb-5 px-4 py-2 rounded-xl text-sm bg-[var(--surface-2)] border border-[var(--border)] text-[var(--muted)]">
                    لا يوجد حد ائتمان محدد لهذا العميل
                  </div>
                )}
              </>
            )}

            {/* Ledger */}
            <div className="card p-0 overflow-hidden flex-1">
              <div className="px-5 py-3 border-b border-[var(--border-faint)]">
                <h3 className="font-bold text-[var(--text)]">سجل الحساب</h3>
              </div>
              <div className="table-wrap overflow-y-auto" style={{ maxHeight: 'calc(100vh - 22rem)' }}>
                <Table>
                  <TableHeader><TableRow><TableHead>التاريخ والوقت</TableHead><TableHead>النوع</TableHead><TableHead>المرجع</TableHead><TableHead>المبلغ</TableHead><TableHead>ملاحظة</TableHead></TableRow></TableHeader>
                  <TableBody>
                    {(!ledger?.filter((e: any) => !e.__pagination)?.length) && <TableRow><TableCell colSpan={5}><EmptyState message="لا توجد حركات" icon="📋" /></TableCell></TableRow>}
                    {ledger?.filter((e: any) => !e.__pagination)?.map((e: any, i: number) => (
                      <TableRow key={i}>
                        <TableCell className="text-sm text-[var(--text-soft)]">{new Date(e.date).toLocaleString('ar-EG')}</TableCell>
                        <TableCell><Badge variant={(typeBadge as any)[e.type] || 'gray'}>{typeLabel[e.type] || e.type}</Badge></TableCell>
                        <TableCell className="font-mono text-xs text-[var(--text-soft)]">{e.ref}</TableCell>
                        <TableCell className={`font-bold ${e.type === 'payment' ? 'text-green-700' : e.type === 'return' ? 'text-red-600' : 'text-[var(--text)]'}`}>
                          {e.type === 'payment' ? '+' : e.type === 'return' ? '-' : ''}{Number(e.amount).toLocaleString('ar-EG')} ج.م
                        </TableCell>
                        <TableCell className="text-xs text-[var(--muted)]">{e.note || (e.items_count ? `${e.items_count} صنف` : '-')}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </div>
            </div>
          </>
        )}
      </div>

      {/* Add modal */}
      <Modal open={showAdd} onClose={() => setShowAdd(false)} title="إضافة عميل جديد">
        <div className="space-y-4">
 <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الاسم *</label><Input value={newName} onChange={e => setNewName(e.target.value)}/></div>
 <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">رقم الهاتف</label><Input value={newPhone} onChange={e => setNewPhone(e.target.value)}/></div>
 <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">العنوان</label><Input value={newAddress} onChange={e => setNewAddress(e.target.value)}/></div>
 <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">حد الائتمان (ج.م) — اختياري</label><Input type="number" value={newCreditLimit} onChange={e => setNewCreditLimit(e.target.value)} placeholder="0 = بدون حد"/></div>
          <div className="flex gap-3 justify-end">
            <Button variant="secondary" onClick={() => { setShowAdd(false); resetForm() }}>إلغاء</Button>
            <Button onClick={() => createMut.mutate()} disabled={!newName} className="px-5">إضافة</Button>
          </div>
        </div>
      </Modal>

      {/* Edit modal */}
      <Modal open={showEdit} onClose={() => setShowEdit(false)} title={`تعديل العميل — ${selected?.name}`}>
        <div className="space-y-4">
 <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الاسم *</label><Input value={newName} onChange={e => setNewName(e.target.value)}/></div>
 <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">رقم الهاتف</label><Input value={newPhone} onChange={e => setNewPhone(e.target.value)}/></div>
 <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">العنوان</label><Input value={newAddress} onChange={e => setNewAddress(e.target.value)}/></div>
 <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">حد الائتمان (ج.م)</label><Input type="number" value={newCreditLimit} onChange={e => setNewCreditLimit(e.target.value)} placeholder="0 = بدون حد"/></div>
          <div className="flex gap-3 justify-end">
            <Button variant="secondary" onClick={() => setShowEdit(false)}>إلغاء</Button>
            <Button onClick={() => editMut.mutate()} disabled={!newName || editMut.isPending} className="px-5">حفظ التعديلات</Button>
          </div>
        </div>
      </Modal>

      {/* Balance modal */}
      <Modal open={showBalance} onClose={() => setShowBalance(false)} title={`تعديل المديونية — ${selected?.name}`}>
        <div className="space-y-4">
          <div className="bg-[var(--primary-soft)] border-[var(--primary-border)] rounded-xl p-3 text-sm">
            المديونية الحالية: <span className="font-black" style={{ color: "#d97706" }}>{Number(account?.balance_due || 0).toLocaleString('ar-EG')} ج.م</span>
          </div>
 <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">المديونية الجديدة (ج.م) *</label><Input type="number" className="text-lg font-bold" value={balanceAmount} onChange={e => setBalanceAmount(e.target.value)} autoFocus/></div>
          <div className="text-xs text-[var(--muted)]">سيتم تحديث رصيد العميل مباشرة بهذه القيمة.</div>
          <div className="flex gap-3 justify-end">
            <Button variant="secondary" onClick={() => setShowBalance(false)}>إلغاء</Button>
            <Button onClick={() => balanceMut.mutate()} disabled={balanceAmount === '' || balanceMut.isPending} className="bg-[#d97706] hover:bg-[#d97706]/90 px-5">حفظ المديونية</Button>
          </div>
        </div>
      </Modal>

      {/* Payment modal */}
      <Modal open={showPayment} onClose={() => setShowPayment(false)} title={`تسجيل دفعة — ${selected?.name}`}>
        <div className="space-y-4">
          {account && (
            <div className="bg-amber-50 border border-amber-200 rounded-xl p-3 text-sm">
              المتبقي: <span className="font-black text-amber-700">{Number(account.balance_due).toLocaleString('ar-EG')} ج.م</span>
            </div>
          )}
 <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">المبلغ (ج.م) *</label><Input type="number" className="text-lg font-bold" value={payAmount} onChange={e => setPayAmount(e.target.value)} autoFocus/></div>
 <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">ملاحظة</label><Input value={payNote} onChange={e => setPayNote(e.target.value)} placeholder="رقم إيصال، تاريخ..."/></div>
          <div className="flex gap-3 justify-end">
            <Button variant="secondary" onClick={() => setShowPayment(false)}>إلغاء</Button>
            <Button onClick={() => { if (Number(payAmount) <= 0) return toast.error('المبلغ يجب أن يكون أكبر من 0'); paymentMut.mutate() }} disabled={!payAmount || Number(payAmount) <= 0 || paymentMut.isPending} className="bg-green-600 hover:bg-green-700 px-5">تسجيل الدفعة</Button>
          </div>
        </div>
      </Modal>
    </div>
  )
}
