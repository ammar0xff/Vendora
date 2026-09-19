import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import api from '../../api/client'
import { expensesApi, stockApi } from '../../api/endpoints'
import { PageLoader, EmptyState } from '../../components/ui/Loaders'
import Modal from '../../components/ui/Modal'
import ConfirmDialog from '../../components/ui/ConfirmDialog'
import toast from 'react-hot-toast'
import ExportButton from '../../components/ui/ExportButton'
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '../../components/ui/table'
import { Plus, Search, CheckCircle, XCircle } from 'lucide-react'
import { Button } from '../../components/ui/button'
import { Input } from '../../components/ui/input'
import { Textarea } from '../../components/ui/textarea'
import { Select } from '../../components/ui/select'
import { Badge } from '../../components/ui/badge'

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

  const statusBadge: Record<string, string> = { draft: 'bg-[var(--surface-3)] text-[var(--text-soft)] border-[var(--border)]', approved: 'bg-emerald-50 text-emerald-700 border-emerald-100', rejected: 'bg-red-50 text-red-600 border-red-100' }
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
          <Button onClick={() => setShowAdd(true)} className="flex items-center gap-1.5">
            <Plus size={14} /> إضافة مصروف
          </Button>
        </div>
      </div>

      {/* Summary */}
      {summary && (
        <div className="grid grid-cols-4 gap-4 mb-5">
          <div className="stat-card"><p className="text-xs text-[var(--muted)] mb-0.5">إجمالي المصروفات</p><p className="text-lg font-black text-[var(--text)]">{Number(summary.total).toLocaleString('ar-EG')} ج.م</p></div>
          <div className="stat-card"><p className="text-xs text-[var(--muted)] mb-0.5">عدد العمليات</p><p className="text-lg font-black text-[var(--text)]">{summary.count}</p></div>
          <div className="stat-card"><p className="text-xs text-[var(--muted)] mb-0.5">مصروفات متكررة</p><p className="text-lg font-black text-amber-700">{Number(summary.recurring_total).toLocaleString('ar-EG')} ج.م</p></div>
          <div className="stat-card"><p className="text-xs text-[var(--muted)] mb-0.5">عدد المتكرر</p><p className="text-lg font-black text-amber-700">{summary.recurring_count}</p></div>
        </div>
      )}

      {/* Filters */}
      <div className="flex gap-3 mb-4">
        <div className="relative flex-1 max-w-xs">
          <Search size={14} className="absolute right-3 top-1/2 -translate-y-1/2 text-[var(--muted)]" />
 <Input className="pr-9 text-sm" placeholder="بحث..." value={search} onChange={e => setSearch(e.target.value)}/>
        </div>
        <Select className="w-40 text-sm" value={statusFilter} onChange={e => setStatusFilter(e.target.value)}>
          <option value="">كل الحالات</option>
          <option value="draft">مسودة</option>
          <option value="approved">معتمد</option>
          <option value="rejected">مرفوض</option>
        </Select>
        <Button variant="outline" size="sm" onClick={() => setShowVendors(true)}>
          الموردون
        </Button>
      </div>

      {/* Table */}
      <div className="card p-0 overflow-hidden">
        {isLoading ? <PageLoader /> : (
          <div className="table-wrap overflow-x-auto">
            <Table>
              <TableHeader><TableRow><TableHead>التاريخ</TableHead><TableHead>البيان</TableHead><TableHead>الفئة</TableHead><TableHead>الفرع</TableHead><TableHead>المورد</TableHead><TableHead>المبلغ</TableHead><TableHead>الحالة</TableHead><TableHead>متكرر</TableHead><TableHead></TableHead></TableRow></TableHeader>
              <TableBody>
                {!expensesData?.data?.length && <TableRow><TableCell colSpan={9}><EmptyState message="لا توجد مصروفات" icon="💸" /></TableCell></TableRow>}
                {expensesData?.data?.map((e: any) => (
                  <TableRow key={e.id} className="cursor-pointer hover:bg-[var(--surface-2)]" onClick={() => setShowDetail(e)}>
                    <TableCell className="text-sm text-[var(--text-soft)]">{e.date}</TableCell>
                    <TableCell className="font-semibold text-[var(--text)] max-w-[200px] truncate">{e.description}</TableCell>
                    <TableCell className="text-sm text-[var(--muted)]">{e.category_name || '-'}</TableCell>
                    <TableCell className="text-sm text-[var(--muted)]">{e.warehouse_name || '-'}</TableCell>
                    <TableCell className="text-sm text-[var(--muted)]">{e.vendor_name || '-'}</TableCell>
                    <TableCell className="font-bold text-[var(--text)]">{Number(e.amount).toLocaleString('ar-EG')}</TableCell>
                    <TableCell><Badge className={statusBadge[e.status] || 'bg-[var(--surface-3)] text-[var(--text-soft)] border-[var(--border)]'}>{statusLabel[e.status] || e.status}</Badge></TableCell>
                    <TableCell className="text-center">{e.is_recurring ? <span className="text-amber-600 text-sm">🔄 {e.recurring_interval}</span> : '-'}</TableCell>
                    <TableCell>
                      <Button variant="ghost" size="sm" onClick={ev => { ev.stopPropagation(); setConfirmDelete(e) }} className="text-red-500 hover:text-red-700 text-xs h-auto p-0">حذف</Button>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        )}
      </div>

      {/* Add Modal */}
      <Modal open={showAdd} onClose={() => setShowAdd(false)} title="إضافة مصروف جديد" size="lg">
        <div className="grid grid-cols-2 gap-4">
 <div className="col-span-2"><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">البيان *</label><Input value={formDesc} onChange={e => setFormDesc(e.target.value)}/></div>
 <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">المبلغ (ج.م) *</label><Input type="number" className="text-lg font-bold" value={formAmount} onChange={e => setFormAmount(e.target.value)}/></div>
 <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">التاريخ</label><Input type="date" value={formDate} onChange={e => setFormDate(e.target.value)}/></div>
          <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الفئة</label>
            <Select value={formCategory} onChange={e => setFormCategory(e.target.value)}>
              <option value="">—</option>
              {categories?.map((c: any) => <option key={c.id} value={c.id}>{c.name}</option>)}
            </Select>
          </div>
          <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الفرع</label>
            <Select value={formWarehouse} onChange={e => setFormWarehouse(e.target.value)}>
              <option value="">—</option>
              {warehouses?.map((w: any) => <option key={w.id} value={w.id}>{w.name}</option>)}
            </Select>
          </div>
          <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">المورد</label>
            <Select value={formVendor} onChange={e => setFormVendor(e.target.value)}>
              <option value="">—</option>
              {vendors?.map((v: any) => <option key={v.id} value={v.id}>{v.name}</option>)}
            </Select>
          </div>
          <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">طريقة الدفع</label>
            <Select value={formMethod} onChange={e => setFormMethod(e.target.value)}>
              <option value="">—</option>
              <option value="cash">نقدي</option>
              <option value="wallet">محفظة</option>
              <option value="bank">بنك</option>
              <option value="cheque">شيك</option>
            </Select>
          </div>
          <div className="flex items-end gap-3">
            <label className="flex items-center gap-2 cursor-pointer">
              <input type="checkbox" aria-label="مصروف متكرر" checked={formRecurring} onChange={e => setFormRecurring(e.target.checked)} className="w-4 h-4" />
              <span className="text-sm text-[var(--text-soft)]">مصروف متكرر</span>
            </label>
            {formRecurring && (
              <Select className="flex-1 text-sm" value={formRecInterval} onChange={e => setFormRecInterval(e.target.value)}>
                <option value="monthly">شهري</option>
                <option value="quarterly">ربع سنوي</option>
                <option value="yearly">سنوي</option>
              </Select>
            )}
          </div>
          <div className="col-span-2"><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">ملاحظات</label><Textarea rows={2} value={formNotes} onChange={e => setFormNotes(e.target.value)} /></div>
        </div>
        <div className="flex gap-3 justify-end mt-6">
          <Button variant="secondary" size="sm" onClick={() => setShowAdd(false)}>إلغاء</Button>
          <Button size="sm" onClick={() => createMut.mutate()} disabled={!formAmount || !formDesc}>إضافة</Button>
        </div>
      </Modal>

      {/* Detail Modal */}
      <Modal open={!!showDetail} onClose={() => setShowDetail(null)} title="تفاصيل المصروف">
        {showDetail && (
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div><p className="text-xs text-[var(--muted)]">البيان</p><p className="font-semibold">{showDetail.description}</p></div>
              <div><p className="text-xs text-[var(--muted)]">المبلغ</p><p className="font-bold text-lg">{Number(showDetail.amount).toLocaleString('ar-EG')} ج.م</p></div>
              <div><p className="text-xs text-[var(--muted)]">التاريخ</p><p>{showDetail.date}</p></div>
              <div><p className="text-xs text-[var(--muted)]">الحالة</p><p><Badge className={statusBadge[showDetail.status]}>{statusLabel[showDetail.status]}</Badge></p></div>
              <div><p className="text-xs text-[var(--muted)]">الفئة</p><p>{showDetail.category_name || '-'}</p></div>
              <div><p className="text-xs text-[var(--muted)]">الفرع</p><p>{showDetail.warehouse_name || '-'}</p></div>
              <div><p className="text-xs text-[var(--muted)]">المورد</p><p>{showDetail.vendor_name || '-'}</p></div>
              <div><p className="text-xs text-[var(--muted)]">طريقة الدفع</p><p>{showDetail.payment_method || '-'}</p></div>
              {showDetail.is_recurring && <div className="col-span-2"><p className="text-xs text-[var(--muted)]">مصروف متكرر</p><p>🔄 {showDetail.recurring_interval}</p></div>}
              {showDetail.notes && <div className="col-span-2"><p className="text-xs text-[var(--muted)]">ملاحظات</p><p className="text-sm text-[var(--text-soft)]">{showDetail.notes}</p></div>}
              {showDetail.created_by_name && <div className="col-span-2"><p className="text-xs text-[var(--muted)]">أضيف بواسطة</p><p className="text-sm">{showDetail.created_by_name}</p></div>}
            </div>
            {showDetail.status === 'draft' && (
              <div className="flex gap-3 pt-4 border-t border-[var(--border-faint)]">
                <Button onClick={() => { approveMut.mutate({ id: showDetail.id, approved: true }); setShowDetail(null) }}
                  className="bg-green-600 hover:bg-green-700 flex items-center gap-2">
                  <CheckCircle size={14} /> اعتماد
                </Button>
                <Button variant="destructive" onClick={() => { approveMut.mutate({ id: showDetail.id, approved: false }); setShowDetail(null) }}
                  className="flex items-center gap-2">
                  <XCircle size={14} /> رفض
                </Button>
              </div>
            )}
          </div>
        )}
      </Modal>

      {/* Vendors Modal */}
      <Modal open={showVendors} onClose={() => setShowVendors(false)} title="موردو المصروفات" size="lg">
        <div className="space-y-4">
          <div className="flex gap-3">
 <Input className="flex-1" placeholder="اسم المورد" value={vendorName} onChange={e => setVendorName(e.target.value)}/>
 <Input className="w-40" placeholder="رقم الهاتف" value={vendorPhone} onChange={e => setVendorPhone(e.target.value)}/>
            <Button onClick={() => vendorMut.mutate()} disabled={!vendorName}>إضافة</Button>
          </div>
          <div className="table-wrap max-h-80 overflow-y-auto">
            <Table>
              <TableHeader><TableRow><TableHead>الاسم</TableHead><TableHead>الهاتف</TableHead><TableHead>عدد المصروفات</TableHead><TableHead>الحالة</TableHead></TableRow></TableHeader>
              <TableBody>
                {!vendors?.length && <TableRow><TableCell colSpan={4}><EmptyState message="لا يوجد موردون" icon="🏢" /></TableCell></TableRow>}
                {vendors?.map((v: any) => (
                  <TableRow key={v.id}>
                    <TableCell className="font-semibold">{v.name}</TableCell>
                    <TableCell className="text-sm text-[var(--muted)]">{v.phone || '-'}</TableCell>
                    <TableCell className="text-sm">{v.expense_count || 0}</TableCell>
                    <TableCell>{v.is_active ? <Badge className="bg-emerald-50 text-emerald-700 border-emerald-100">نشط</Badge> : <Badge className="bg-[var(--surface-3)] text-[var(--text-soft)] border-[var(--border)]">غير نشط</Badge>}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
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
