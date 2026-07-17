import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import api from '../../api/client'
import { expensesApi, stockApi } from '../../api/endpoints'
import { PageLoader, EmptyState } from '../../components/ui/Loaders'
import Modal from '../../components/ui/Modal'
import ConfirmDialog from '../../components/ui/ConfirmDialog'
import toast from 'react-hot-toast'
import ExportButton from '../../components/ui/ExportButton'
import { Plus, Search, Filter, DollarSign, CheckCircle, XCircle, ChevronLeft } from 'lucide-react'

export default function ExpensesPage() {
  const qc = useQueryClient()
  const [search, setSearch] = useState('')
  const [statusFilter, setStatusFilter] = useState('')
  const [showAdd, setShowAdd] = useState(false)
  const [showVendors, setShowVendors] = useState(false)
  const [showDetail, setShowDetail] = useState<any>(null)
  const [confirmDelete, setConfirmDelete] = useState<any>(null)

  const [formVendor, setFormVendor] = useState('')
  const [formCategory, setFormCategory] = useState('')
  const [formWarehouse, setFormWarehouse] = useState('')
  const [formAmount, setFormAmount] = useState('')
  const [formDesc, setFormDesc] = useState('')
  const [formDate, setFormDate] = useState('')
  const [formMethod, setFormMethod] = useState('')
  const [formRecurring, setFormRecurring] = useState(false)
  const [formRecInterval, setFormRecInterval] = useState('')
  const [formNotes, setFormNotes] = useState('')

  const [vendorName, setVendorName] = useState('')
  const [vendorPhone, setVendorPhone] = useState('')

  const { data: expensesData, isLoading } = useQuery({
    queryKey: ['expenses', search, statusFilter],
    queryFn: () => expensesApi.list({ search: search || undefined, status: statusFilter || undefined, page_size: 200 }),
  })
  const { data: vendors } = useQuery({ queryKey: ['expense-vendors'], queryFn: () => expensesApi.vendors.list() })
  const { data: categories } = useQuery({ queryKey: ['financial-categories'], queryFn: () => api.get('/financial-categories').then(r => r.data) })
  const { data: warehouses } = useQuery({ queryKey: ['warehouses'], queryFn: stockApi.warehouses })
  const { data: summary } = useQuery({ queryKey: ['expenses-summary'], queryFn: () => expensesApi.summary() })

  const createMut = useMutation({
    mutationFn: () => expensesApi.create({
      vendor_id: formVendor || null, category_id: formCategory || null, warehouse_id: formWarehouse || null,
      amount: Number(formAmount), description: formDesc, date: formDate || null,
      payment_method: formMethod || null, is_recurring: formRecurring,
      recurring_interval: formRecInterval || null, notes: formNotes || null,
    }),
    onSuccess: () => {
      toast.success('تمت إضافة المصروف')
      setShowAdd(false); resetForm(); qc.invalidateQueries({ queryKey: ['expenses'] })
    },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل إضافة المصروف'),
  })
  const approveMut = useMutation({
    mutationFn: ({ id, approved, notes }: any) => expensesApi.approve(id, { approved, notes }),
    onSuccess: () => { toast.success('تم اعتماد المصروف'); qc.invalidateQueries({ queryKey: ['expenses'] }) },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل الاعتماد'),
  })
  const deleteMut = useMutation({
    mutationFn: (id: string) => expensesApi.delete(id),
    onSuccess: () => { toast.success('تم الحذف'); qc.invalidateQueries({ queryKey: ['expenses'] }) },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل الحذف'),
  })
  const vendorMut = useMutation({
    mutationFn: () => expensesApi.vendors.create({ name: vendorName, phone: vendorPhone || undefined }),
    onSuccess: () => { toast.success('تمت إضافة المورد'); setVendorName(''); setVendorPhone(''); qc.invalidateQueries({ queryKey: ['expense-vendors'] }) },
  })

  function resetForm() {
    setFormVendor(''); setFormCategory(''); setFormWarehouse('')
    setFormAmount(''); setFormDesc(''); setFormDate('')
    setFormMethod(''); setFormRecurring(false); setFormRecInterval(''); setFormNotes('')
  }

  const statusBadge: Record<string, string> = { draft: 'badge-gray', approved: 'badge-green', rejected: 'badge-red' }
  const statusLabel: Record<string, string> = { draft: 'مسودة', approved: 'معتمد', rejected: 'مرفوض' }

  return (
    <div>
      <div className="flex items-center justify-between mb-5">
        <h1 className="page-title">المصروفات</h1>
        <div className="flex items-center gap-3">
          <ExportButton data={expensesData || []} columns={[
            { label: 'التاريخ', accessor: (r: any) => r.date || '' },
            { label: 'الوصف', accessor: (r: any) => r.description },
            { label: 'المبلغ', accessor: (r: any) => Number(r.amount) },
            { label: 'المورد', accessor: (r: any) => r.vendor_name || '' },
            { label: 'الحالة', accessor: (r: any) => statusLabel[r.status] || r.status },
            { label: 'ملاحظات', accessor: (r: any) => r.notes || '' },
          ]} filename="المصروفات" excelEndpoint="/export/expenses" />
          <button onClick={() => setShowAdd(true)} className="px-4 py-2.5 rounded-xl text-sm font-bold text-white flex items-center gap-1.5" style={{ background: '#1e3a5f' }}>
            <Plus size={14} /> إضافة مصروف
          </button>
        </div>
      </div>

      {/* Summary */}
      {summary && (
        <div className="grid grid-cols-4 gap-4 mb-5">
          <div className="stat-card"><p className="text-xs text-slate-500 mb-0.5">إجمالي المصروفات</p><p className="text-lg font-black text-slate-800">{Number(summary.total).toLocaleString('ar-EG')} ج.م</p></div>
          <div className="stat-card"><p className="text-xs text-slate-500 mb-0.5">عدد العمليات</p><p className="text-lg font-black text-slate-800">{summary.count}</p></div>
          <div className="stat-card"><p className="text-xs text-slate-500 mb-0.5">مصروفات متكررة</p><p className="text-lg font-black text-amber-700">{Number(summary.recurring_total).toLocaleString('ar-EG')} ج.م</p></div>
          <div className="stat-card"><p className="text-xs text-slate-500 mb-0.5">عدد المتكرر</p><p className="text-lg font-black text-amber-700">{summary.recurring_count}</p></div>
        </div>
      )}

      {/* Filters */}
      <div className="flex gap-3 mb-4">
        <div className="relative flex-1 max-w-xs">
          <Search size={14} className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input className="input pr-9 text-sm" placeholder="بحث..." value={search} onChange={e => setSearch(e.target.value)} />
        </div>
        <select className="input w-40 text-sm" value={statusFilter} onChange={e => setStatusFilter(e.target.value)}>
          <option value="">كل الحالات</option>
          <option value="draft">مسودة</option>
          <option value="approved">معتمد</option>
          <option value="rejected">مرفوض</option>
        </select>
        <button onClick={() => setShowVendors(true)} className="px-3 py-2 rounded-xl text-sm font-semibold border border-slate-200 hover:bg-slate-50">
          الموردون
        </button>
      </div>

      {/* Table */}
      <div className="card p-0 overflow-hidden">
        {isLoading ? <PageLoader /> : (
          <div className="table-wrap overflow-x-auto">
            <table>
              <thead><tr><th>التاريخ</th><th>البيان</th><th>الفئة</th><th>الفرع</th><th>المورد</th><th>المبلغ</th><th>الحالة</th><th>متكرر</th><th></th></tr></thead>
              <tbody>
                {!expensesData?.data?.length && <tr><td colSpan={9}><EmptyState message="لا توجد مصروفات" icon="💸" /></td></tr>}
                {expensesData?.data?.map((e: any) => (
                  <tr key={e.id} className="cursor-pointer hover:bg-slate-50" onClick={() => setShowDetail(e)}>
                    <td className="text-sm text-slate-600">{e.date}</td>
                    <td className="font-semibold text-slate-800 max-w-[200px] truncate">{e.description}</td>
                    <td className="text-sm text-slate-500">{e.category_name || '-'}</td>
                    <td className="text-sm text-slate-500">{e.warehouse_name || '-'}</td>
                    <td className="text-sm text-slate-500">{e.vendor_name || '-'}</td>
                    <td className="font-bold text-slate-800">{Number(e.amount).toLocaleString('ar-EG')}</td>
                    <td><span className={statusBadge[e.status] || 'badge-gray'}>{statusLabel[e.status] || e.status}</span></td>
                    <td className="text-center">{e.is_recurring ? <span className="text-amber-600 text-sm">🔄 {e.recurring_interval}</span> : '-'}</td>
                    <td>
                      <button onClick={e => e.stopPropagation()} className="text-red-500 hover:text-red-700 text-xs">حذف</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Add Modal */}
      <Modal open={showAdd} onClose={() => setShowAdd(false)} title="إضافة مصروف جديد" size="lg">
        <div className="grid grid-cols-2 gap-4">
          <div className="col-span-2"><label className="block text-sm font-medium text-slate-600 mb-1">البيان *</label><input className="input" value={formDesc} onChange={e => setFormDesc(e.target.value)} /></div>
          <div><label className="block text-sm font-medium text-slate-600 mb-1">المبلغ (ج.م) *</label><input type="number" className="input text-lg font-bold" value={formAmount} onChange={e => setFormAmount(e.target.value)} /></div>
          <div><label className="block text-sm font-medium text-slate-600 mb-1">التاريخ</label><input type="date" className="input" value={formDate} onChange={e => setFormDate(e.target.value)} /></div>
          <div><label className="block text-sm font-medium text-slate-600 mb-1">الفئة</label>
            <select className="input" value={formCategory} onChange={e => setFormCategory(e.target.value)}>
              <option value="">—</option>
              {categories?.map((c: any) => <option key={c.id} value={c.id}>{c.name}</option>)}
            </select>
          </div>
          <div><label className="block text-sm font-medium text-slate-600 mb-1">الفرع</label>
            <select className="input" value={formWarehouse} onChange={e => setFormWarehouse(e.target.value)}>
              <option value="">—</option>
              {warehouses?.map((w: any) => <option key={w.id} value={w.id}>{w.name}</option>)}
            </select>
          </div>
          <div><label className="block text-sm font-medium text-slate-600 mb-1">المورد</label>
            <select className="input" value={formVendor} onChange={e => setFormVendor(e.target.value)}>
              <option value="">—</option>
              {vendors?.map((v: any) => <option key={v.id} value={v.id}>{v.name}</option>)}
            </select>
          </div>
          <div><label className="block text-sm font-medium text-slate-600 mb-1">طريقة الدفع</label>
            <select className="input" value={formMethod} onChange={e => setFormMethod(e.target.value)}>
              <option value="">—</option>
              <option value="cash">نقدي</option>
              <option value="wallet">محفظة</option>
              <option value="bank">بنك</option>
              <option value="cheque">شيك</option>
            </select>
          </div>
          <div className="flex items-end gap-3">
            <label className="flex items-center gap-2 cursor-pointer">
              <input type="checkbox" checked={formRecurring} onChange={e => setFormRecurring(e.target.checked)} className="w-4 h-4" />
              <span className="text-sm text-slate-600">مصروف متكرر</span>
            </label>
            {formRecurring && (
              <select className="input flex-1 text-sm" value={formRecInterval} onChange={e => setFormRecInterval(e.target.value)}>
                <option value="monthly">شهري</option>
                <option value="quarterly">ربع سنوي</option>
                <option value="yearly">سنوي</option>
              </select>
            )}
          </div>
          <div className="col-span-2"><label className="block text-sm font-medium text-slate-600 mb-1">ملاحظات</label><textarea className="input" rows={2} value={formNotes} onChange={e => setFormNotes(e.target.value)} /></div>
        </div>
        <div className="flex gap-3 justify-end mt-6">
          <button onClick={() => setShowAdd(false)} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
          <button onClick={() => createMut.mutate()} disabled={!formAmount || !formDesc} className="px-5 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#1e3a5f' }}>إضافة</button>
        </div>
      </Modal>

      {/* Detail Modal */}
      <Modal open={!!showDetail} onClose={() => setShowDetail(null)} title="تفاصيل المصروف">
        {showDetail && (
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div><p className="text-xs text-slate-400">البيان</p><p className="font-semibold">{showDetail.description}</p></div>
              <div><p className="text-xs text-slate-400">المبلغ</p><p className="font-bold text-lg">{Number(showDetail.amount).toLocaleString('ar-EG')} ج.م</p></div>
              <div><p className="text-xs text-slate-400">التاريخ</p><p>{showDetail.date}</p></div>
              <div><p className="text-xs text-slate-400">الحالة</p><p><span className={statusBadge[showDetail.status]}>{statusLabel[showDetail.status]}</span></p></div>
              <div><p className="text-xs text-slate-400">الفئة</p><p>{showDetail.category_name || '-'}</p></div>
              <div><p className="text-xs text-slate-400">الفرع</p><p>{showDetail.warehouse_name || '-'}</p></div>
              <div><p className="text-xs text-slate-400">المورد</p><p>{showDetail.vendor_name || '-'}</p></div>
              <div><p className="text-xs text-slate-400">طريقة الدفع</p><p>{showDetail.payment_method || '-'}</p></div>
              {showDetail.is_recurring && <div className="col-span-2"><p className="text-xs text-slate-400">مصروف متكرر</p><p>🔄 {showDetail.recurring_interval}</p></div>}
              {showDetail.notes && <div className="col-span-2"><p className="text-xs text-slate-400">ملاحظات</p><p className="text-sm text-slate-600">{showDetail.notes}</p></div>}
              {showDetail.created_by_name && <div className="col-span-2"><p className="text-xs text-slate-400">أضيف بواسطة</p><p className="text-sm">{showDetail.created_by_name}</p></div>}
            </div>
            {showDetail.status === 'draft' && (
              <div className="flex gap-3 pt-4 border-t border-slate-100">
                <button onClick={() => { approveMut.mutate({ id: showDetail.id, approved: true }); setShowDetail(null) }}
                  className="px-5 py-2 rounded-xl text-sm font-bold text-white bg-green-600 hover:bg-green-700 flex items-center gap-2">
                  <CheckCircle size={14} /> اعتماد
                </button>
                <button onClick={() => { approveMut.mutate({ id: showDetail.id, approved: false }); setShowDetail(null) }}
                  className="px-5 py-2 rounded-xl text-sm font-bold text-white bg-red-500 hover:bg-red-600 flex items-center gap-2">
                  <XCircle size={14} /> رفض
                </button>
              </div>
            )}
          </div>
        )}
      </Modal>

      {/* Vendors Modal */}
      <Modal open={showVendors} onClose={() => setShowVendors(false)} title="موردو المصروفات" size="lg">
        <div className="space-y-4">
          <div className="flex gap-3">
            <input className="input flex-1" placeholder="اسم المورد" value={vendorName} onChange={e => setVendorName(e.target.value)} />
            <input className="input w-40" placeholder="رقم الهاتف" value={vendorPhone} onChange={e => setVendorPhone(e.target.value)} />
            <button onClick={() => vendorMut.mutate()} disabled={!vendorName} className="px-4 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#1e3a5f' }}>إضافة</button>
          </div>
          <div className="table-wrap max-h-80 overflow-y-auto">
            <table>
              <thead><tr><th>الاسم</th><th>الهاتف</th><th>عدد المصروفات</th><th>الحالة</th></tr></thead>
              <tbody>
                {!vendors?.length && <tr><td colSpan={4}><EmptyState message="لا يوجد موردون" icon="🏢" /></td></tr>}
                {vendors?.map((v: any) => (
                  <tr key={v.id}>
                    <td className="font-semibold">{v.name}</td>
                    <td className="text-sm text-slate-500">{v.phone || '-'}</td>
                    <td className="text-sm">{v.expense_count || 0}</td>
                    <td>{v.is_active ? <span className="badge-green">نشط</span> : <span className="badge-gray">غير نشط</span>}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </Modal>

      <ConfirmDialog
        open={!!confirmDelete}
        onClose={() => setConfirmDelete(null)}
        onConfirm={() => { deleteMut.mutate(confirmDelete.id); setConfirmDelete(null) }}
        title="حذف المصروف"
        message="هل أنت متأكد من حذف هذا المصروف؟"
      />
    </div>
  )
}
