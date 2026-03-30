import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { customersApi } from '../../api/endpoints'
import { PageLoader, EmptyState } from '../../components/ui/Loaders'
import Modal from '../../components/ui/Modal'
import toast from 'react-hot-toast'
import { Search, Plus, ChevronLeft, TrendingUp, TrendingDown, DollarSign } from 'lucide-react'

export default function CustomersPage() {
  const [search, setSearch] = useState('')
  const [selected, setSelected] = useState<any>(null)
  const [showAdd, setShowAdd] = useState(false)
  const [showPayment, setShowPayment] = useState(false)
  const [newName, setNewName] = useState('')
  const [newPhone, setNewPhone] = useState('')
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
    mutationFn: () => customersApi.create({ name: newName, phone: newPhone }),
    onSuccess: () => { toast.success('تمت الإضافة'); setShowAdd(false); setNewName(''); setNewPhone(''); qc.invalidateQueries({ queryKey: ['customers'] }) },
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

  const typeLabel: Record<string, string> = { invoice: 'فاتورة', return: 'مرتجع', payment: 'دفعة' }
  const typeBadge: Record<string, string> = { invoice: 'badge-blue', return: 'badge-red', payment: 'badge-green' }

  return (
    <div className="flex gap-5 h-[calc(100vh-3rem)]">
      {/* Customer list */}
      <div className="w-72 flex-shrink-0 flex flex-col">
        <div className="page-header mb-4">
          <h1 className="page-title">العملاء</h1>
          <button onClick={() => setShowAdd(true)} className="px-4 py-2 rounded-xl text-sm font-bold text-white flex items-center gap-1.5" style={{ background: '#1e3a5f' }}>
            <Plus size={14} /> إضافة
          </button>
        </div>
        <div className="relative mb-3">
          <Search size={14} className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input className="input pr-9 text-sm" placeholder="بحث..." value={search} onChange={e => setSearch(e.target.value)} />
        </div>
        {isLoading ? <PageLoader /> : (
          <div className="flex-1 overflow-y-auto space-y-2">
            {!customers?.length && <EmptyState message="لا يوجد عملاء" icon="👤" />}
            {customers?.map((c: any) => (
              <button key={c.id} onClick={() => setSelected(c)}
                className={`w-full text-right p-3 rounded-xl border transition-all ${selected?.id === c.id ? 'border-blue-300 bg-blue-50' : 'bg-white border-slate-100 hover:border-slate-200 hover:shadow-sm'}`}>
                <div className="flex items-center justify-between">
                  <div>
                    <p className="font-bold text-slate-800 text-sm">{c.name}</p>
                    {c.phone && <p className="text-xs text-slate-400 mt-0.5">{c.phone}</p>}
                  </div>
                  {Number(c.balance_due) > 0 && (
                    <span className="text-xs font-black text-amber-700 bg-amber-50 px-2 py-0.5 rounded-full">
                      {Number(c.balance_due).toLocaleString('ar-EG')} ج.م
                    </span>
                  )}
                </div>
              </button>
            ))}
          </div>
        )}
      </div>

      {/* Customer detail */}
      <div className="flex-1 flex flex-col min-w-0">
        {!selected ? (
          <div className="flex-1 flex items-center justify-center text-slate-400">
            <div className="text-center"><p className="text-4xl mb-3">👤</p><p>اختر عميلاً لعرض حسابه</p></div>
          </div>
        ) : (
          <>
            {/* Account summary */}
            <div className="flex items-center justify-between mb-5">
              <div>
                <h2 className="text-xl font-black text-slate-800">{selected.name}</h2>
                {selected.phone && <p className="text-slate-500 text-sm">{selected.phone}</p>}
              </div>
              <button onClick={() => setShowPayment(true)} className="px-5 py-2.5 rounded-xl text-sm font-bold text-white flex items-center gap-2" style={{ background: '#16a34a' }}>
                <DollarSign size={15} /> تسجيل دفعة
              </button>
            </div>

            {account && (
              <div className="grid grid-cols-4 gap-4 mb-5">
                {[
                  { label: 'إجمالي الفواتير', value: account.total_invoiced, color: '#1e3a5f', icon: TrendingUp },
                  { label: 'المرتجعات', value: account.total_returned, color: '#dc2626', icon: TrendingDown },
                  { label: 'المدفوع', value: account.total_paid, color: '#16a34a', icon: DollarSign },
                  { label: 'المتبقي', value: account.balance_due, color: account.balance_due > 0 ? '#d97706' : '#16a34a', icon: DollarSign },
                ].map(({ label, value, color, icon: Icon }) => (
                  <div key={label} className="stat-card">
                    <div className="stat-icon" style={{ background: color + '20' }}><Icon size={18} style={{ color }} /></div>
                    <div>
                      <p className="text-slate-500 text-xs mb-0.5">{label}</p>
                      <p className="text-lg font-black" style={{ color }}>{Number(value).toLocaleString('ar-EG')} ج.م</p>
                    </div>
                  </div>
                ))}
              </div>
            )}

            {/* Ledger */}
            <div className="card p-0 overflow-hidden flex-1">
              <div className="px-5 py-3 border-b border-slate-100">
                <h3 className="font-bold text-slate-700">سجل الحساب</h3>
              </div>
              <div className="table-wrap overflow-y-auto" style={{ maxHeight: 'calc(100vh - 22rem)' }}>
                <table>
                  <thead><tr><th>التاريخ والوقت</th><th>النوع</th><th>المرجع</th><th>المبلغ</th><th>ملاحظة</th></tr></thead>
                  <tbody>
                    {!ledger?.length && <tr><td colSpan={5}><EmptyState message="لا توجد حركات" icon="📋" /></td></tr>}
                    {ledger?.map((e: any, i: number) => (
                      <tr key={i}>
                        <td className="text-sm text-slate-600">{new Date(e.date).toLocaleString('ar-EG')}</td>
                        <td><span className={typeBadge[e.type] || 'badge-gray'}>{typeLabel[e.type] || e.type}</span></td>
                        <td className="font-mono text-xs text-slate-600">{e.ref}</td>
                        <td className={`font-bold ${e.type === 'payment' ? 'text-green-700' : e.type === 'return' ? 'text-red-600' : 'text-slate-800'}`}>
                          {e.type === 'payment' ? '+' : e.type === 'return' ? '-' : ''}{Number(e.amount).toLocaleString('ar-EG')} ج.م
                        </td>
                        <td className="text-xs text-slate-400">{e.note || (e.items_count ? `${e.items_count} صنف` : '-')}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </>
        )}
      </div>

      <Modal open={showAdd} onClose={() => setShowAdd(false)} title="إضافة عميل جديد">
        <div className="space-y-4">
          <div><label className="block text-sm font-medium text-slate-600 mb-1">الاسم *</label><input className="input" value={newName} onChange={e => setNewName(e.target.value)} /></div>
          <div><label className="block text-sm font-medium text-slate-600 mb-1">رقم الهاتف</label><input className="input" value={newPhone} onChange={e => setNewPhone(e.target.value)} /></div>
          <div className="flex gap-3 justify-end">
            <button onClick={() => setShowAdd(false)} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
            <button onClick={() => createMut.mutate()} disabled={!newName} className="px-5 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#1e3a5f' }}>إضافة</button>
          </div>
        </div>
      </Modal>

      <Modal open={showPayment} onClose={() => setShowPayment(false)} title={`تسجيل دفعة — ${selected?.name}`}>
        <div className="space-y-4">
          {account && (
            <div className="bg-amber-50 border border-amber-200 rounded-xl p-3 text-sm">
              المتبقي: <span className="font-black text-amber-700">{Number(account.balance_due).toLocaleString('ar-EG')} ج.م</span>
            </div>
          )}
          <div><label className="block text-sm font-medium text-slate-600 mb-1">المبلغ (ج.م) *</label><input type="number" className="input text-lg font-bold" value={payAmount} onChange={e => setPayAmount(e.target.value)} autoFocus /></div>
          <div><label className="block text-sm font-medium text-slate-600 mb-1">ملاحظة</label><input className="input" value={payNote} onChange={e => setPayNote(e.target.value)} placeholder="رقم إيصال، تاريخ..." /></div>
          <div className="flex gap-3 justify-end">
            <button onClick={() => setShowPayment(false)} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
            <button onClick={() => paymentMut.mutate()} disabled={!payAmount || paymentMut.isPending} className="px-5 py-2 rounded-xl text-sm font-bold text-white bg-green-600 hover:bg-green-700 disabled:opacity-50">تسجيل الدفعة</button>
          </div>
        </div>
      </Modal>
    </div>
  )
}
