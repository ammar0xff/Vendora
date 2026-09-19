import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '../../components/ui/table'

function AuditLogTable() {
  const { data: logs, isLoading } = useQuery({
    queryKey: ['hr-audit-log'],
    queryFn: () => api.get('/hr/audit-log').then(r => r.data),
  })
  const actionLabels: Record<string, string> = { create: 'إضافة', update: 'تعديل', delete: 'حذف' }
  const entityLabels: Record<string, string> = { attendance: 'حضور', advance: 'سلفة/مكافأة', employee: 'موظف', payroll: 'راتب' }
  return (
    <div className="card p-0 overflow-hidden">
      <div className="table-wrap max-h-[60vh] overflow-y-auto">
        <Table>
          <TableHeader><TableRow><TableHead>التاريخ والوقت</TableHead><TableHead>المسؤول</TableHead><TableHead>النوع</TableHead><TableHead>الكيان</TableHead><TableHead>السبب / التفاصيل</TableHead></TableRow></TableHeader>
          <TableBody>
            {isLoading && <TableRow><TableCell colSpan={5} className="text-center py-8 text-[var(--muted)]">جاري التحميل...</TableCell></TableRow>}
            {!isLoading && !logs?.length && <TableRow><TableCell colSpan={5}><EmptyState message="لا توجد سجلات تعديلات" icon="📑" /></TableCell></TableRow>}
            {logs?.map((l: any) => (
              <TableRow key={l.id}>
                <TableCell className="text-xs text-[var(--muted)]">{l.created_at ? new Date(l.created_at).toLocaleString("ar-EG") : "-"}</TableCell>
                <TableCell className="font-semibold text-sm">{l.performed_by_name || "-"}</TableCell>
                <TableCell><Badge variant={l.action_type === "create" ? "green" : l.action_type === "delete" ? "red" : "yellow"}>{actionLabels[l.action_type] || l.action_type}</Badge></TableCell>
                <TableCell className="text-sm">{entityLabels[l.entity_type] || l.entity_type}</TableCell>
                <TableCell className="text-xs text-[var(--muted)]">{l.reason || JSON.stringify(l.details || {})}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}




function AttendanceTable({ month, employees: _employees }: { month: string; employees: any[] | undefined }) {
  const { data: attendance } = useQuery({
    queryKey: ['hr-attendance', month],
    queryFn: () => hrApi.attendance({ month }),
    enabled: !!month,
  })
  const qc = useQueryClient()
  const [editRec, setEditRec] = useState<any>(null)
  const [editCheckIn, setEditCheckIn] = useState('')
  const [editCheckOut, setEditCheckOut] = useState('')
  const [editStatus, setEditStatus] = useState('')
  const [editReason, setEditReason] = useState('')
  const saveMut = useMutation({
    mutationFn: (d: any) => hrApi.addAttendance(d),
    onSuccess: () => { toast.success('تم الحفظ'); setEditRec(null); qc.invalidateQueries({ queryKey: ['hr-attendance'] }) },
  })

  const statusColors: Record<string, string> = { present: 'green', absent: 'red', leave: 'blue', mission: 'blue', excuse: 'yellow' }
  const statusLabels: Record<string, string> = { present: 'حضور', absent: 'غياب', leave: 'إجازة', mission: 'مأمورية', excuse: 'عذر' }

  return (
    <div className="card p-0 overflow-hidden">
      <div className="table-wrap max-h-[60vh] overflow-y-auto">
        <Table>
          <TableHeader><TableRow><TableHead>الموظف</TableHead><TableHead>التاريخ</TableHead><TableHead>دخول</TableHead><TableHead>خروج</TableHead><TableHead>الحالة</TableHead><TableHead>ملاحظة</TableHead><TableHead></TableHead></TableRow></TableHeader>
          <TableBody>
            {!attendance?.length && <TableRow><TableCell colSpan={7}><EmptyState message="لا توجد سجلات حضور" icon="📅" /></TableCell></TableRow>}
            {attendance?.map((a: any) => (
              <TableRow key={a.id} className={a.edited ? 'bg-yellow-50' : ''}>
                <TableCell className="font-semibold">{a.emp_name}</TableCell>
                <TableCell className="text-sm">{a.work_date}</TableCell>
                <TableCell className="text-xs text-[var(--text-soft)] font-mono">{a.check_in ? new Date(a.check_in).toLocaleTimeString('ar-EG') : '-'}</TableCell>
                <TableCell className="text-xs text-[var(--text-soft)] font-mono">{a.check_out ? new Date(a.check_out).toLocaleTimeString('ar-EG') : '-'}</TableCell>
                <TableCell><Badge variant={(statusColors as any)[a.status] || 'gray'}>{statusLabels[a.status] || a.status}</Badge></TableCell>
                <TableCell className="text-xs text-[var(--muted)]">{a.edit_reason || ''}</TableCell>
                <TableCell>                <Button variant="ghost" size="sm" onClick={() => { setEditRec(a); setEditCheckIn(a.check_in?.slice(0,16) || ''); setEditCheckOut(a.check_out?.slice(0,16) || ''); setEditStatus(a.status); setEditReason(a.edit_reason || '') }} className="px-0 h-auto text-xs text-[var(--accent)] hover:underline">تعديل</Button></TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
      {editRec && (
        <Modal open={true} onClose={() => setEditRec(null)} title="تعديل سجل الحضور">
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">وقت الدخول</label>
 <Input type="datetime-local" value={editCheckIn} onChange={e => setEditCheckIn(e.target.value)}/></div>
              <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">وقت الخروج</label>
 <Input type="datetime-local" value={editCheckOut} onChange={e => setEditCheckOut(e.target.value)}/></div>
            </div>
            <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الحالة</label>
              <Select value={editStatus} onChange={e => setEditStatus(e.target.value)}>
                {['present','absent','leave','mission','excuse'].map(s => <option key={s} value={s}>{statusLabels[s]}</option>)}
              </Select></div>
            <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">سبب التعديل</label>
 <Input value={editReason} onChange={e => setEditReason(e.target.value)}/></div>
            <div className="flex gap-3 justify-end">
              <Button variant="secondary" onClick={() => setEditRec(null)}>إلغاء</Button>
              <Button onClick={() => saveMut.mutate({
                employee_id: editRec.employee_id,
                work_date: editRec.work_date,
                check_in: editCheckIn || null,
                check_out: editCheckOut || null,
                status: editStatus,
                edit_reason: editReason,
                edited: true,
              })} className="px-5">حفظ</Button>
            </div>
          </div>
        </Modal>
      )}
    </div>
  )
}

import { useState, useRef } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import api from '../../api/client'
import { PageLoader, EmptyState } from '../../components/ui/Loaders'
import DataTable from '../../components/ui/DataTable'
import Modal from '../../components/ui/Modal'
import ConfirmDialog from '../../components/ui/ConfirmDialog'
import toast from 'react-hot-toast'
import { Plus, Edit2, Trash2, Calculator } from 'lucide-react'
import { format, startOfMonth } from 'date-fns'
import { Input } from '../../components/ui/input'
import { Select } from '../../components/ui/select'
import { Badge } from '../../components/ui/badge'
import { Button } from '../../components/ui/button'

const hrApi = {
  employees: () => api.get('/hr/employees').then(r => r.data),
  createEmployee: (d: any) => api.post('/hr/employees', d).then(r => r.data),
  updateEmployee: (id: string, d: any) => api.put(`/hr/employees/${id}`, d).then(r => r.data),
  deleteEmployee: (id: string) => api.delete(`/hr/employees/${id}`),
  shifts: () => api.get('/hr/shifts').then(r => r.data),
  attendance: (params?: any) => api.get('/hr/attendance', { params }).then(r => r.data),
  addAttendance: (d: any) => api.post('/hr/attendance', d).then(r => r.data),
  payroll: (month?: string) => api.get('/hr/payroll', { params: month ? { month } : {} }).then(r => r.data),
  calculatePayroll: (month: string) => api.post('/hr/payroll/calculate', { month }).then(r => r.data),
  payrollPeriod: (month: string) => api.get('/hr/payroll/period', { params: { month } }).then(r => r.data),
  submitPayrollPeriod: (month: string) => api.post('/hr/payroll/period/submit', null, { params: { month } }).then(r => r.data),
  approvePayrollPeriod: (month: string) => api.post('/hr/payroll/period/approve', null, { params: { month } }).then(r => r.data),
  payPayrollPeriod: (month: string) => api.post('/hr/payroll/period/pay', null, { params: { month } }).then(r => r.data),
  reopenPayrollPeriod: (month: string) => api.post('/hr/payroll/period/reopen', null, { params: { month } }).then(r => r.data),
  updatePayroll: (id: string, d: any) => api.put(`/hr/payroll/${id}`, d).then(r => r.data),
  breakdown: (id: string) => api.get(`/hr/payroll/${id}/breakdown`).then(r => r.data),
  advances: (employee_id?: string) => api.get('/hr/advances', { params: employee_id ? { employee_id } : {} }).then(r => r.data),
  addAdvance: (d: any) => api.post('/hr/advances', d).then(r => r.data),
  settings: () => api.get('/hr/settings').then(r => r.data),
  updateSettings: (d: any) => api.put('/hr/settings', d).then(r => r.data),
}

function EmployeeForm({ emp, shifts, onSave, onClose }: any) {
  const [form, setForm] = useState(emp || { name: '', position: '', monthly_salary: 0, shift_schedule: '', hire_date: '', emp_code: '', ignore_lateness: false, max_lateness_before_overtime_cancellation: 30 })
  const set = (k: string, v: any) => setForm((f: any) => ({ ...f, [k]: v }))
  return (
    <form onSubmit={e => { e.preventDefault(); onSave(form) }} className="space-y-4">
      <div className="grid grid-cols-2 gap-4">
 <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الاسم *</label><Input value={form.name} onChange={e => set('name', e.target.value)} required/></div>
 <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الكود</label><Input value={form.emp_code || ''} onChange={e => set('emp_code', e.target.value)}/></div>
 <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">المسمى الوظيفي</label><Input value={form.position || ''} onChange={e => set('position', e.target.value)}/></div>
 <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الراتب الشهري</label><Input type="number" value={form.monthly_salary} onChange={e => set('monthly_salary', e.target.value)}/></div>
        <div>
          <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الوردية</label>
          <Select value={form.shift_schedule || ''} onChange={e => set('shift_schedule', e.target.value)}>
            <option value="">اختر وردية...</option>
            {shifts?.map((s: any) => <option key={s.id} value={s.name}>{s.name} ({s.start_time}-{s.end_time})</option>)}
          </Select>
        </div>
 <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">تاريخ التعيين</label><Input type="date" value={form.hire_date || ''} onChange={e => set('hire_date', e.target.value)}/></div>
 <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">حد التأخير قبل إلغاء الإضافي (دقيقة)</label><Input type="number" value={form.max_lateness_before_overtime_cancellation} onChange={e => set('max_lateness_before_overtime_cancellation', e.target.value)}/></div>
        <div className="flex items-center gap-3 pt-6">
          <input type="checkbox" id="ignore_late" checked={form.ignore_lateness} onChange={e => set('ignore_lateness', e.target.checked)} className="w-4 h-4" />
          <label htmlFor="ignore_late" className="text-sm font-medium text-[var(--text-soft)]">تجاهل التأخير</label>
        </div>
      </div>
      <div className="flex gap-3 justify-end">
        <Button type="button" variant="secondary" onClick={onClose}>إلغاء</Button>
        <Button type="submit" className="px-5">حفظ</Button>
      </div>
    </form>
  )
}

const STATUS_LABELS: Record<string, string> = { present: 'حضور', absent: 'غياب', leave: 'إجازة', mission: 'مأمورية', excuse: 'عذر', weekend: 'عطلة', 'pre-hire': 'قبل التعيين' }
const STATUS_COLORS: Record<string, string> = { present: 'green', absent: 'red', leave: 'blue', mission: 'blue', excuse: 'yellow', weekend: 'gray', 'pre-hire': 'gray' }

function CsvImportSection() {
  const qc = useQueryClient()
  const fileRef = useRef<HTMLInputElement>(null)
  const [file, setFile] = useState<File | null>(null)
  const [preview, setPreview] = useState<any[]>([])
  const [importing, setImporting] = useState(false)
  const [result, setResult] = useState<any>(null)

  const handleFile = (e: React.ChangeEvent<HTMLInputElement>) => {
    const f = e.target.files?.[0]
    if (!f) return
    if (!f.name.endsWith('.csv')) { toast.error('يرجى اختيار ملف CSV'); return }
    setFile(f)
    setResult(null)
    const reader = new FileReader()
    reader.onload = () => {
      const text = reader.result as string
      const lines = text.split('\n').filter(l => l.trim())
      const headers = lines[0]?.split(',').map(h => h.trim()) || []
      const rows = lines.slice(1, 4).map(l => {
        const vals = l.split(',').map(v => v.trim())
        const obj: any = {}
        headers.forEach((h, i) => obj[h] = vals[i] || '')
        return obj
      })
      setPreview(rows)
    }
    reader.readAsText(f)
  }

  const doImport = async () => {
    if (!file) return
    setImporting(true)
    setResult(null)
    try {
      const fd = new FormData()
      fd.append('file', file)
      const r = await api.post('/hr/attendance/import-csv', fd, { headers: { 'Content-Type': 'multipart/form-data' } })
      setResult(r.data)
      toast.success(`تم الاستيراد: ${r.data.added} جديد، ${r.data.updated} محدّث، ${r.data.skipped} تم تخطيه`)
      qc.invalidateQueries({ queryKey: ['hr-attendance'] })
    } catch (e: any) {
      toast.error(e.response?.data?.detail || 'فشل الاستيراد')
    } finally {
      setImporting(false)
    }
  }

  return (
    <div className="card mb-5">
      <h3 className="font-bold text-[var(--text)] mb-3">📥 استيراد حضور من CSV</h3>
      <p className="text-xs text-[var(--muted)] mb-3" dir="rtl">
        يدعم ملفات Jibble (Member / Date / Start time / End time) — يتطابق مع اسم الموظف تلقائياً
      </p>
      <div className="flex items-center gap-3 flex-wrap">
        <input ref={fileRef} type="file" aria-label="رفع ملف الحضور" accept=".csv" onChange={handleFile} className="text-sm" />
        <Button onClick={doImport} disabled={!file || importing} className="px-4">
          {importing ? 'جاري الاستيراد...' : 'استيراد'}
        </Button>
      </div>
      {preview.length > 0 && (
        <div className="mt-3">
          <p className="text-xs text-[var(--muted)] mb-2">معاينة أول {preview.length} صف:</p>
          <div className="overflow-x-auto">
            <Table className="text-xs w-full">
              <TableHeader><TableRow>{Object.keys(preview[0]).map(h => <TableHead key={h} className="px-2 py-1 text-right">{h}</TableHead>)}</TableRow></TableHeader>
              <TableBody>{preview.map((row, i) => (
                <TableRow key={i}>{Object.values(row).map((v: any, j) => <TableCell key={j} className="px-2 py-1">{v}</TableCell>)}</TableRow>
              ))}</TableBody>
            </Table>
          </div>
        </div>
      )}
      {result && (
        <div className="mt-3 flex gap-3 text-sm">
          <Badge variant="green">+{result.added} جديد</Badge>
          <Badge variant="blue">~{result.updated} محدّث</Badge>
          <Badge variant="gray">{result.skipped} متخطى</Badge>
          {result.errors?.length > 0 && (
            <details className="text-xs text-red-600">
              <summary>{result.errors.length} خطأ</summary>
              <ul className="mt-1">{result.errors.map((e: string, i: number) => <li key={i}>• {e}</li>)}</ul>
            </details>
          )}
        </div>
      )}
    </div>
  )
}

function DeviceSyncCard({ settings, onSettingsChange, onSave }: any) {
  const qc = useQueryClient()
  const [syncing, setSyncing] = useState(false)
  const { data: syncLog } = useQuery({ queryKey: ['hr-sync-log'], queryFn: () => api.get('/hr/sync-log').then(r => r.data) })

  const doSync = async () => {
    setSyncing(true)
    try {
      const r = await api.post('/hr/sync-device')
      toast.success(`✅ تمت المزامنة — ${r.data.added} جديد، ${r.data.updated} محدّث`)
      qc.invalidateQueries({ queryKey: ['hr-sync-log'] })
      qc.invalidateQueries({ queryKey: ['hr-attendance'] })
    } catch (e: any) {
      toast.error(e.response?.data?.detail || 'فشل الاتصال بالجهاز')
    } finally {
      setSyncing(false)
    }
  }

  return (
    <div className="card">
      <h3 className="font-bold text-[var(--text)] mb-4">🔌 جهاز البصمة (ZK)</h3>
      <div className="grid grid-cols-2 gap-3 mb-4">
        <div>
          <label className="block text-xs font-medium text-[var(--muted)] mb-1">IP الجهاز</label>
 <Input className="text-sm" value={settings.device_host || '192.168.1.201'}
            onChange={e => onSettingsChange('device_host', e.target.value)} />
        </div>
        <div>
          <label className="block text-xs font-medium text-[var(--muted)] mb-1">المنفذ</label>
 <Input className="text-sm" value={settings.device_port || '4370'}
            onChange={e => onSettingsChange('device_port', e.target.value)} />
        </div>
      </div>
      <div className="flex gap-2 mb-4">
        <Button variant="secondary" size="sm" onClick={onSave} className="text-xs">حفظ الإعدادات</Button>
        <Button onClick={doSync} disabled={syncing} className="flex-1">
          {syncing ? '⏳ جاري المزامنة...' : '🔄 مزامنة الحضور الآن'}
        </Button>
      </div>
      {/* Sync log */}
      {syncLog?.length > 0 && (
        <div className="space-y-1 max-h-40 overflow-y-auto">
          <p className="text-xs font-bold text-[var(--muted)] mb-1">آخر عمليات المزامنة</p>
          {syncLog.slice(0, 10).map((l: any) => (
            <div key={l.id} className={`flex items-center justify-between text-xs px-3 py-1.5 rounded-lg ${l.status === 'success' ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-600'}`}>
              <span>{new Date(l.synced_at).toLocaleString('ar-EG')}</span>
              {l.status === 'success'
                ? <span>{l.fetched} بصمة — {l.added} جديد، {l.updated} محدّث</span>
                : <span>{l.message}</span>}
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

export default function PayrollPage() {
  const [tab, setTab] = useState<'employees' | 'payroll' | 'attendance' | 'advances' | 'shifts' | 'audit' | 'settings' | 'reports'>('employees')
  const [selectedMonth, setSelectedMonth] = useState(format(startOfMonth(new Date()), 'yyyy-MM'))
  const [showAddEmp, setShowAddEmp] = useState(false)
  const [editEmp, setEditEmp] = useState<any>(null)
  const [showAddAdvance, setShowAddAdvance] = useState(false)
  const [advEmpId, setAdvEmpId] = useState('')
  const [advAmount, setAdvAmount] = useState('')
  const [advNote, setAdvNote] = useState('')
  const [advType, setAdvType] = useState('سلفة')
  const [breakdown, setBreakdown] = useState<any>(null)
  const [empSearch, setEmpSearch] = useState('')
  const [, setShowAddShift] = useState(false)
  const [confirmDelEmp, setConfirmDelEmp] = useState<any>(null)
  const qc = useQueryClient()

  const { data: employees, isLoading: loadingEmps } = useQuery({ queryKey: ['hr-employees'], queryFn: hrApi.employees })
  const { data: shifts } = useQuery({ queryKey: ['hr-shifts'], queryFn: hrApi.shifts })
  const { data: payrollData, isLoading: loadingPayroll } = useQuery({ queryKey: ['hr-payroll', selectedMonth], queryFn: () => hrApi.payroll(selectedMonth) })
  const { data: payrollPeriod } = useQuery({ queryKey: ['hr-payroll-period', selectedMonth], queryFn: () => hrApi.payrollPeriod(selectedMonth) })
  const { data: advances } = useQuery({ queryKey: ['hr-advances'], queryFn: () => hrApi.advances() })
  const { data: hrSettings } = useQuery({ queryKey: ['hr-settings'], queryFn: hrApi.settings })
  const [settingsForm, setSettingsForm] = useState<any>(null)

  const createEmpMut = useMutation({ mutationFn: hrApi.createEmployee, onSuccess: () => { toast.success('تمت الإضافة'); setShowAddEmp(false); qc.invalidateQueries({ queryKey: ['hr-employees'] }) } })
  const updateEmpMut = useMutation({ mutationFn: ({ id, d }: any) => hrApi.updateEmployee(id, d), onSuccess: () => { toast.success('تم التحديث'); setEditEmp(null); qc.invalidateQueries({ queryKey: ['hr-employees'] }) } })
  const deleteEmpMut = useMutation({ mutationFn: hrApi.deleteEmployee, onSuccess: () => { toast.success('تم الحذف'); qc.invalidateQueries({ queryKey: ['hr-employees'] }) } })
  const calcMut = useMutation({
    mutationFn: () => hrApi.calculatePayroll(selectedMonth),
    onSuccess: (d) => { toast.success(`✅ ${d.employees} موظف — إجمالي: ${Number(d.total).toLocaleString('ar-EG')} ج.م`); qc.invalidateQueries({ queryKey: ['hr-payroll'] }) },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })

  const submitPeriodMut = useMutation({
    mutationFn: () => hrApi.submitPayrollPeriod(selectedMonth),
    onSuccess: () => { toast.success('تم إرسال الشهر للمراجعة'); qc.invalidateQueries({ queryKey: ['hr-payroll-period'] }) },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })
  const approvePeriodMut = useMutation({
    mutationFn: () => hrApi.approvePayrollPeriod(selectedMonth),
    onSuccess: (d: any) => { toast.success(`تم الاعتماد — إجمالي ${Number(d.total || 0).toLocaleString('ar-EG')} ج.م`); qc.invalidateQueries({ queryKey: ['hr-payroll-period'] }); qc.invalidateQueries({ queryKey: ['hr-payroll'] }) },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })
  const payPeriodMut = useMutation({
    mutationFn: () => hrApi.payPayrollPeriod(selectedMonth),
    onSuccess: () => { toast.success('تم تعليم الشهر كـ مدفوع'); qc.invalidateQueries({ queryKey: ['hr-payroll-period'] }); qc.invalidateQueries({ queryKey: ['hr-payroll'] }) },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })
  const reopenPeriodMut = useMutation({
    mutationFn: () => hrApi.reopenPayrollPeriod(selectedMonth),
    onSuccess: () => { toast.success('تم إعادة فتح الشهر'); qc.invalidateQueries({ queryKey: ['hr-payroll-period'] }); qc.invalidateQueries({ queryKey: ['hr-payroll'] }) },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })
  const addAdvanceMut = useMutation({
    mutationFn: () => hrApi.addAdvance({ employee_id: advEmpId, amount: Number(advAmount), note: advNote, record_type: advType }),
    onSuccess: () => { toast.success('تم التسجيل'); setShowAddAdvance(false); setAdvAmount(''); setAdvNote(''); setAdvType('سلفة'); qc.invalidateQueries({ queryKey: ['hr-advances'] }) },
  })
  const saveSettingsMut = useMutation({
    mutationFn: () => hrApi.updateSettings(settingsForm || hrSettings),
    onSuccess: () => { toast.success('تم حفظ الإعدادات'); qc.invalidateQueries({ queryKey: ['hr-settings'] }) },
  })

  const token = JSON.parse(localStorage.getItem('auth') || '{}')?.state?.token || ''
  const reportUrl = (path: string) => `/api${path}${path.includes('?') ? '&' : '?'}token=${token}`
  const totalNet = payrollData?.reduce((s: number, p: any) => s + Number(p.net_salary), 0) || 0
  const sf = settingsForm || hrSettings || {}

  const tabs = [
    { id: 'employees', label: '👥 الموظفون' },
    { id: 'attendance', label: '📅 الحضور' },
    { id: 'payroll', label: '💰 الرواتب' },
    { id: 'reports', label: '📊 التقارير' },
    { id: 'advances', label: '💸 السلف' },
    { id: 'shifts', label: '⏰ المناوبات' },
    { id: 'audit', label: '📑 السجل' },
    { id: 'settings', label: '⚙️ الإعدادات' },
  ]

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">إدارة الرواتب والموظفين</h1>
      </div>

      <div className="flex gap-0 mb-6 border-b border-[var(--border)] overflow-x-auto pb-px" style={{ WebkitOverflowScrolling: 'touch' }}>
        {tabs.map(t => (
          <Button key={t.id} onClick={() => setTab(t.id as any)} variant="ghost"
            className={`px-4 py-3 text-sm font-semibold border-b-2 transition-all -mb-px whitespace-nowrap flex-shrink-0 h-auto rounded-none ${tab === t.id ? 'border-[var(--primary)] text-[var(--primary)]' : 'border-transparent text-[var(--muted)] hover:text-[var(--text)]'}`}>
            {t.label}
          </Button>
        ))}
      </div>

      {/* ── Payroll Tab ── */}
      {tab === 'payroll' && (
        <div>
          <div className="flex items-center gap-3 mb-5 flex-wrap">
 <Input type="month" className="w-48" value={selectedMonth} onChange={e => setSelectedMonth(e.target.value)}/>
            <div className="flex items-center gap-2">
              <Badge variant={
                payrollPeriod?.status === 'paid' ? 'green' :
                payrollPeriod?.status === 'approved' ? 'blue' :
                payrollPeriod?.status === 'review' ? 'yellow' : 'gray'
              }>
                {payrollPeriod?.status === 'paid' ? 'مدفوع' :
                 payrollPeriod?.status === 'approved' ? 'معتمد' :
                 payrollPeriod?.status === 'review' ? 'مراجعة' : 'مسودة'}
              </Badge>
              {payrollPeriod?.status === 'draft' && (
                <Button variant="outline" size="sm" onClick={() => submitPeriodMut.mutate()} disabled={submitPeriodMut.isPending}>
                  إرسال للمراجعة
                </Button>
              )}
              {payrollPeriod?.status === 'review' && (
                <Button size="sm" onClick={() => approvePeriodMut.mutate()} disabled={approvePeriodMut.isPending} className="bg-[#2563eb] hover:bg-[#2563eb]/90">
                  اعتماد
                </Button>
              )}
              {payrollPeriod?.status === 'approved' && (
                <Button size="sm" onClick={() => payPeriodMut.mutate()} disabled={payPeriodMut.isPending} className="bg-[#16a34a] hover:bg-[#16a34a]/90">
                  تعليم كـ مدفوع
                </Button>
              )}
              {(payrollPeriod?.status === 'review' || payrollPeriod?.status === 'approved') && (
                <Button variant="destructive" size="sm" onClick={() => reopenPeriodMut.mutate()} disabled={reopenPeriodMut.isPending} className="border-red-200">
                  إعادة فتح
                </Button>
              )}
            </div>
            <Button onClick={() => calcMut.mutate()} disabled={calcMut.isPending || payrollPeriod?.status !== 'draft'} className="bg-[#16a34a] hover:bg-[#16a34a]/90 px-5">
              <Calculator size={15} /> حساب الرواتب
            </Button>
            <Button variant="outline" size="sm" onClick={() => window.open(reportUrl(`/hr/payroll/report/monthly?month=${selectedMonth}`), '_blank')}>
              📄 تقرير الرواتب
            </Button>
            <Button variant="outline" size="sm" onClick={() => window.open(reportUrl(`/hr/attendance/report?month=${selectedMonth}`), '_blank')}>
              📊 تقرير الحضور
            </Button>
            {totalNet > 0 && (
              <div className="mr-auto bg-[var(--primary-soft)] border-[var(--primary-border)] rounded-xl px-4 py-2 text-sm">
                إجمالي الرواتب: <span className="font-black text-blue-800">{totalNet.toLocaleString('ar-EG')} ج.م</span>
              </div>
            )}
          </div>

          {loadingPayroll ? <PageLoader /> : (
            <div className="card p-0 overflow-hidden">
              <div className="table-wrap" style={{ overflowX: 'auto' }}>
                <Table style={{ minWidth: '900px' }}>
                  <TableHeader>
                    <TableRow>
                      <TableHead>الموظف</TableHead><TableHead>الراتب الأساسي</TableHead><TableHead>أيام الحضور</TableHead><TableHead>تأخير</TableHead><TableHead>خصم التأخير</TableHead>
                      <TableHead>إضافي</TableHead><TableHead>أجر إضافي</TableHead><TableHead>سلف</TableHead><TableHead>صافي الراتب</TableHead><TableHead>الحالة</TableHead><TableHead>الإجراءات</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {!payrollData?.length && <TableRow><TableCell colSpan={11}><EmptyState message="اضغط حساب الرواتب" icon="💰" /></TableCell></TableRow>}
                    {payrollData?.map((p: any) => (
                      <TableRow key={p.id}>
                        <TableCell>
                          <p className="font-semibold">{p.emp_name}</p>
                          <p className="text-xs text-[var(--muted)]">{p.position}</p>
                        </TableCell>
                        <TableCell>{Number(p.base_salary).toLocaleString('ar-EG')}</TableCell>
                        <TableCell>
                          <span className="font-bold text-green-700">{p.working_days}</span>
                          {p.absent_days > 0 && <span className="text-xs text-red-500 mr-1">({p.absent_days} غياب)</span>}
                        </TableCell>
                        <TableCell className={p.lateness_minutes > 0 ? 'text-amber-600 font-semibold' : ''}>
                          {p.lateness_minutes > 0 ? `${p.lateness_minutes} د` : '-'}
                        </TableCell>
                        <TableCell className="text-red-600 font-semibold">
                          {Number(p.lateness_deduction) > 0 ? `${Number(p.lateness_deduction).toLocaleString('ar-EG')} ج.م` : '-'}
                        </TableCell>
                        <TableCell className="text-[var(--accent)]">{p.overtime_hours > 0 ? `${p.overtime_hours}h` : '-'}</TableCell>
                        <TableCell className="text-green-600">{Number(p.overtime_pay) > 0 ? `${Number(p.overtime_pay).toLocaleString('ar-EG')}` : '-'}</TableCell>
                        <TableCell className="text-amber-600">{Number(p.advances) > 0 ? `${Number(p.advances).toLocaleString('ar-EG')}` : '-'}</TableCell>
                        <TableCell className="font-black text-lg" style={{ color: 'var(--primary)' }}>{Number(p.net_salary).toLocaleString('ar-EG')} ج.م</TableCell>
                        <TableCell>
                          <Badge variant={p.status === 'paid' ? 'green' : p.status === 'approved' ? 'blue' : 'gray'}>
                            {p.status === 'paid' ? 'مدفوع' : p.status === 'approved' ? 'معتمد' : 'مسودة'}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <div className="flex gap-1 flex-nowrap">
                            <Button variant="ghost" size="sm"
                              onClick={async () => { const d = await hrApi.breakdown(p.id); setBreakdown(d) }}
                              className="px-2 py-1 text-xs font-semibold bg-[var(--primary-soft)] text-[var(--primary)] hover:bg-[var(--primary-border)] whitespace-nowrap h-auto">
                              تفاصيل
                            </Button>
                            <Button variant="ghost" size="sm"
                              onClick={() => window.open(reportUrl(`/hr/payroll/report/employee/${p.employee_id}?month=${selectedMonth}&report_type=detailed`), '_blank')}
                              className="px-2 py-1 text-xs font-semibold bg-green-50 text-green-700 hover:bg-green-100 whitespace-nowrap h-auto">
                              تقرير
                            </Button>
                            <Button variant="ghost" size="sm"
                              onClick={() => window.open(reportUrl(`/hr/payroll/report/employee/${p.employee_id}?month=${selectedMonth}&report_type=ticket`), '_blank')}
                              className="px-2 py-1 text-xs font-semibold bg-amber-50 text-amber-700 hover:bg-amber-100 whitespace-nowrap h-auto">
                              قسيمة
                            </Button>
                          </div>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </div>
            </div>
          )}
        </div>
      )}


      {/* ── Attendance Tab ── */}
      {tab === 'attendance' && (
        <div>
          <div className="flex items-center gap-4 mb-5 flex-wrap">
 <Input type="month" className="w-48" value={selectedMonth} onChange={e => setSelectedMonth(e.target.value)}/>
            <Button onClick={() => window.open(reportUrl(`/hr/attendance/report?month=${selectedMonth}`), '_blank')} className="bg-[#0891b2] hover:bg-[#0891b2]/90 px-5">
              📊 تصدير تقرير الحضور
            </Button>
          </div>

          {/* CSV Import */}
          <CsvImportSection />

          <AttendanceTable month={selectedMonth} employees={employees} />
        </div>
      )}

      {/* ── Shifts Tab ── */}
      {tab === 'shifts' && (
        <div>
          <div className="flex justify-end mb-4">
            <Button onClick={() => setShowAddShift(true)} className="px-4">
              <Plus size={15} /> إضافة مناوبة
            </Button>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {shifts?.map((s: any) => (
              <div key={s.id} className="card">
                <p className="font-bold text-[var(--text)] text-lg">{s.name}</p>
                <p className="text-[var(--muted)] text-sm mt-1">🕐 {s.start_time} — {s.end_time}</p>
                {s.description && <p className="text-xs text-[var(--muted)] mt-1">{s.description}</p>}
              </div>
            ))}
          </div>
        </div>
      )}


      {/* ── Reports Tab (📊 التقارير) — matches Qt init_reports_tab exactly ── */}
      {tab === 'reports' && (
        <div>
          <div className="flex items-center gap-4 mb-6 flex-wrap">
            <label className="text-sm font-medium text-[var(--text-soft)]">📅 الشهر:</label>
 <Input type="month" className="w-48" value={selectedMonth} onChange={e => setSelectedMonth(e.target.value)}/>
          </div>
          <div className="card max-w-2xl">
            <h3 className="font-bold text-[var(--text)] mb-6 text-lg">📄 التقارير المتاحة</h3>
            <div className="space-y-4">
              <div className="flex items-center justify-between p-4 rounded-xl bg-[var(--surface-2)] border border-[var(--border)]">
                <div>
                  <p className="font-bold text-[var(--text)]">📄 تقرير الرواتب الشهري</p>
                  <p className="text-sm text-[var(--muted)] mt-0.5">عرض ملخص رواتب جميع الموظفين للشهر المحدد</p>
                </div>
                <Button onClick={() => window.open(reportUrl(`/hr/payroll/report/monthly?month=${selectedMonth}`), "_blank")} className="px-5">
                  عرض التقرير
                </Button>
              </div>
              <div className="flex items-center justify-between p-4 rounded-xl bg-[var(--surface-2)] border border-[var(--border)]">
                <div>
                  <p className="font-bold text-[var(--text)]">📋 تقرير الموظف الفردي</p>
                  <p className="text-sm text-[var(--muted)] mt-0.5">عرض تفاصيل الراتب والحضور لموظف محدد</p>
                </div>
                <div className="flex gap-2 items-center">
                  <Select className="w-48 text-sm" id="report-emp-select">
                    <option value="">اختر موظف...</option>
                    {employees?.map((e: any) => <option key={e.id} value={e.id}>{e.name}</option>)}
                  </Select>
                  <Button onClick={() => {
                    const sel = (document.getElementById("report-emp-select") as HTMLSelectElement)?.value
                    if (sel) window.open(reportUrl(`/hr/payroll/report/employee/${sel}?month=${selectedMonth}&report_type=detailed`), "_blank")
                  }} className="px-4">تقرير مفصل</Button>
                  <Button onClick={() => {
                    const sel = (document.getElementById("report-emp-select") as HTMLSelectElement)?.value
                    if (sel) window.open(reportUrl(`/hr/payroll/report/employee/${sel}?month=${selectedMonth}&report_type=ticket`), "_blank")
                  }} className="px-4" style={{ background: "var(--accent)", color: "var(--primary)" }}>قسيمة راتب</Button>
                </div>
              </div>
              <div className="flex items-center justify-between p-4 rounded-xl bg-[var(--surface-2)] border border-[var(--border)]">
                <div>
                  <p className="font-bold text-[var(--text)]">📊 تقرير الحضور</p>
                  <p className="text-sm text-[var(--muted)] mt-0.5">عرض سجل الحضور والغياب لجميع الموظفين</p>
                </div>
                <Button onClick={() => window.open(reportUrl(`/hr/attendance/report?month=${selectedMonth}`), "_blank")} className="bg-[#0891b2] hover:bg-[#0891b2]/90 px-5">
                  عرض التقرير
                </Button>
              </div>
            </div>
            <div className="mt-6 p-4 rounded-xl bg-blue-50 border border-blue-200 text-sm text-[var(--primary)]">
              ✓ يتم إنشاء التقارير بصيغة HTML جاهزة للطباعة والمشاركة
            </div>
          </div>
        </div>
      )}

      {/* ── Employees Tab ── */}
      {tab === 'employees' && (
        <div>
          <div className="flex items-center justify-between mb-4 gap-3">
 <Input className="max-w-xs" placeholder="بحث بالاسم أو الوظيفة..."
              onChange={e => setEmpSearch(e.target.value)} />
            <Button onClick={() => setShowAddEmp(true)} className="px-4 flex-shrink-0">
              <Plus size={15} /> إضافة موظف
            </Button>
          </div>
          <DataTable
            columns={[
              { key: 'name', label: 'الموظف', sortable: true, render: (e: any) => (
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-xl flex items-center justify-center text-white font-black text-sm flex-shrink-0" style={{ background: 'var(--primary)' }}>{e.name[0]}</div>
                  <div><p className="font-bold text-[var(--text)]">{e.name}</p><p className="text-xs text-[var(--muted)]">{e.shift_schedule || ''}</p></div>
                </div>
              )},
              { key: 'position', label: 'الوظيفة', sortable: true, render: (e: any) => <span className="text-[var(--text-soft)]">{e.position}</span> },
              { key: 'monthly_salary', label: 'الراتب', sortable: true, render: (e: any) => <span className="font-black" style={{ color: 'var(--primary)' }}>{Number(e.monthly_salary).toLocaleString('ar-EG')} ج.م</span> },
              { key: 'status', label: 'الحالة', render: (e: any) => <Badge variant={e.is_active !== false ? 'green' : 'red'}>{e.is_active !== false ? 'نشط' : 'غير نشط'}</Badge> },
              { key: 'actions', label: '', render: (e: any) => (
                <div className="flex gap-1 justify-end">
                  <Button variant="ghost" size="icon-sm" onClick={() => setEditEmp(e)} className="text-[var(--muted)] hover:bg-[var(--surface-3)]"><Edit2 size={14} /></Button>
                  <Button variant="ghost" size="icon-sm" onClick={() => setConfirmDelEmp(e.id)} className="text-[var(--faint)] hover:text-red-500 hover:bg-red-50"><Trash2 size={14} /></Button>
                </div>
              )},
            ]}
            data={(employees || []).filter((e: any) => !empSearch || e.name.includes(empSearch) || (e.position || '').includes(empSearch))}
            loading={loadingEmps}
            rowKey={(e: any) => e.id}
            emptyMessage="لا يوجد موظفون" emptyIcon="👥"
          />
        </div>
      )}

      {/* ── Advances Tab ── */}
      {tab === 'advances' && (
        <div>
          <div className="flex justify-end mb-4">
            <Button onClick={() => setShowAddAdvance(true)} className="px-4">
              <Plus size={15} /> تسجيل سلفة
            </Button>
          </div>
          <div className="card p-0 overflow-hidden">
            <div className="table-wrap">
              <Table>
                <TableHeader><TableRow><TableHead>الموظف</TableHead><TableHead>المبلغ</TableHead><TableHead>التاريخ</TableHead><TableHead>ملاحظة</TableHead></TableRow></TableHeader>
                <TableBody>
                  {!advances?.length && <TableRow><TableCell colSpan={4}><EmptyState message="لا توجد سلف" icon="💸" /></TableCell></TableRow>}
                  {advances?.map((a: any) => (
                    <TableRow key={a.id}>
                      <TableCell className="font-semibold">{a.emp_name}</TableCell>
                      <TableCell>
                        <span className={`font-bold ${a.record_type === 'خصم' ? 'text-red-600' : a.record_type === 'مكافأة' ? 'text-green-600' : 'text-amber-700'}`}>
                          {a.record_type === 'خصم' ? '−' : a.record_type === 'مكافأة' ? '+' : ''}{Number(a.amount).toLocaleString('ar-EG')} ج.م
                        </span>
                        <span className="text-xs text-[var(--muted)] mr-1">({a.record_type || 'سلفة'})</span>
                      </TableCell>
                      <TableCell className="text-sm text-[var(--muted)]">{new Date(a.date).toLocaleDateString('ar-EG')}</TableCell>
                      <TableCell className="text-sm text-[var(--muted)]">{a.note || '-'}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          </div>
        </div>
      )}


      {/* ── Audit Log Tab ── */}
      {tab === 'audit' && (
        <div>
          <AuditLogTable />
        </div>
      )}

      {/* ── Settings Tab ── */}
      {tab === 'settings' && (
        <div className="space-y-5 max-w-lg">
          <div className="card">
          <h3 className="font-bold text-[var(--text)] mb-5">إعدادات حساب الرواتب</h3>
          <div className="space-y-4">
            {[
              { key: 'grace_period_minutes', label: 'فترة السماح (دقيقة)' },
              { key: 'late_penalty_multiplier', label: 'مضاعف خصم التأخير' },
              { key: 'missing_checkout_penalty_hours', label: 'خصم غياب البصمة (ساعة)' },
              { key: 'days_in_month', label: 'أيام الشهر المحتسبة' },
            ].map(({ key, label }) => (
              <div key={key}>
                <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">{label}</label>
 <Input type="number" step="0.1" value={sf[key] || ''}
                  onChange={e => setSettingsForm({ ...sf, [key]: e.target.value })} />
              </div>
            ))}
            <div className="flex items-center gap-3">
              <input type="checkbox" id="mcp" checked={sf.apply_missing_checkout_penalty === 'True' || sf.apply_missing_checkout_penalty === true}
                onChange={e => setSettingsForm({ ...sf, apply_missing_checkout_penalty: e.target.checked ? 'True' : 'False' })} className="w-4 h-4" />
              <label htmlFor="mcp" className="text-sm font-medium text-[var(--text-soft)]">تطبيق خصم عدم تسجيل الخروج</label>
            </div>
            <div className="flex items-center gap-3">
              <input type="checkbox" id="ot" checked={sf.overtime_enabled === 'True' || sf.overtime_enabled === true}
                onChange={e => setSettingsForm({ ...sf, overtime_enabled: e.target.checked ? 'True' : 'False' })} className="w-4 h-4" />
              <label htmlFor="ot" className="text-sm font-medium text-[var(--text-soft)]">تفعيل الإضافي</label>
            </div>
            <div className="flex items-center gap-3">
              <input type="checkbox" id="wp" checked={sf.weekend_paid === 'True' || sf.weekend_paid === true}
                onChange={e => setSettingsForm({ ...sf, weekend_paid: e.target.checked ? 'True' : 'False' })} className="w-4 h-4" />
              <label htmlFor="wp" className="text-sm font-medium text-[var(--text-soft)]">الجمعة مدفوعة</label>
            </div>
            <Button onClick={() => saveSettingsMut.mutate()} className="w-full px-5">
              حفظ الإعدادات
            </Button>
          </div>
          </div>

          {/* ZK Device Sync */}
          <DeviceSyncCard settings={sf} onSettingsChange={(k: string, v: string) => setSettingsForm({ ...sf, [k]: v })} onSave={() => saveSettingsMut.mutate()} />
        </div>
      )}

      {/* Modals */}
      <Modal open={showAddEmp} onClose={() => setShowAddEmp(false)} title="إضافة موظف جديد" size="lg">
        <EmployeeForm shifts={shifts} onSave={(d: any) => createEmpMut.mutate(d)} onClose={() => setShowAddEmp(false)} />
      </Modal>
      <Modal open={!!editEmp} onClose={() => setEditEmp(null)} title="تعديل بيانات الموظف" size="lg">
        {editEmp && <EmployeeForm emp={editEmp} shifts={shifts} onSave={(d: any) => updateEmpMut.mutate({ id: editEmp.id, d })} onClose={() => setEditEmp(null)} />}
      </Modal>
      <Modal open={showAddAdvance} onClose={() => setShowAddAdvance(false)} title="تسجيل سلفة">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الموظف</label>
            <Select value={advEmpId} onChange={e => setAdvEmpId(e.target.value)}>
              <option value="">اختر موظف...</option>
              {employees?.map((e: any) => <option key={e.id} value={e.id}>{e.name}</option>)}
            </Select>
          </div>
          <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">النوع</label><Select value={advType} onChange={e => setAdvType(e.target.value)}><option value="سلفة">سلفة</option><option value="مكافأة">مكافأة</option><option value="خصم">خصم</option></Select></div>
 <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">المبلغ</label><Input type="number" value={advAmount} onChange={e => setAdvAmount(e.target.value)}/></div>
 <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">ملاحظة</label><Input value={advNote} onChange={e => setAdvNote(e.target.value)}/></div>
          <div className="flex gap-3 justify-end">
            <Button variant="secondary" onClick={() => setShowAddAdvance(false)}>إلغاء</Button>
            <Button onClick={() => addAdvanceMut.mutate()} disabled={!advEmpId || !advAmount} className="px-5">تسجيل</Button>
          </div>
        </div>
      </Modal>

      <ConfirmDialog open={!!confirmDelEmp} onClose={() => setConfirmDelEmp(null)}
        onConfirm={() => deleteEmpMut.mutate(confirmDelEmp)}
        message="حذف الموظف؟" danger confirmText="حذف" />
      {/* Daily Breakdown Modal */}
      <Modal open={!!breakdown} onClose={() => setBreakdown(null)} title={`تفاصيل الحضور — ${breakdown?.employee}`} size="xl">
        {breakdown && (
          <div className="table-wrap max-h-[70vh] overflow-y-auto">
            <Table>
              <TableHeader><TableRow><TableHead>التاريخ</TableHead><TableHead>الحالة</TableHead><TableHead>دخول</TableHead><TableHead>خروج</TableHead><TableHead>ساعات</TableHead><TableHead>تأخير</TableHead><TableHead>مبكر</TableHead><TableHead>إضافي</TableHead><TableHead>ملاحظة</TableHead></TableRow></TableHeader>
              <TableBody>
                {breakdown.breakdown?.map((d: any, i: number) => (
                  <TableRow key={i} className={d.status === 'absent' ? 'bg-red-50' : d.status === 'weekend' ? 'bg-[var(--surface-2)]' : d.status === 'pre-hire' ? 'bg-[var(--surface-2)] opacity-50' : ''}>
                    <TableCell className="text-sm font-medium">{new Date(d.date).toLocaleDateString('ar-EG', { weekday: 'short', day: 'numeric', month: 'numeric' })}</TableCell>
                    <TableCell><Badge variant={(STATUS_COLORS as any)[d.status] || 'gray'}>{STATUS_LABELS[d.status] || d.status}</Badge></TableCell>
                    <TableCell className="text-xs text-[var(--text-soft)] font-mono">{d.check_in ? d.check_in.slice(11, 16) : '—'}</TableCell>
                    <TableCell className="text-xs text-[var(--text-soft)] font-mono">{d.check_out ? d.check_out.slice(11, 16) : '—'}</TableCell>
                    <TableCell className="font-semibold text-center">{d.work_hours > 0 ? d.work_hours.toFixed(1) : '—'}</TableCell>
                    <TableCell className={`text-center ${d.late_minutes > 0 ? 'text-amber-600 font-semibold' : 'text-[var(--faint)]'}`}>{d.late_minutes > 0 ? `${d.late_minutes}د` : '—'}</TableCell>
                    <TableCell className={`text-center ${d.early_minutes > 0 ? 'text-orange-500 font-semibold' : 'text-[var(--faint)]'}`}>{d.early_minutes > 0 ? `${d.early_minutes}د` : '—'}</TableCell>
                    <TableCell className={`text-center ${d.overtime_hours > 0 ? 'text-[var(--accent)] font-semibold' : 'text-[var(--faint)]'}`}>{d.overtime_hours > 0 ? `${d.overtime_hours.toFixed(1)}h` : '—'}</TableCell>
                    <TableCell className="text-xs text-[var(--muted)] max-w-xs truncate">{d.note || ''}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        )}
      </Modal>
    </div>
  )
}
