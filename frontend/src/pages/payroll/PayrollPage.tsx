
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
        <table>
          <thead><tr><th>التاريخ والوقت</th><th>المسؤول</th><th>النوع</th><th>الكيان</th><th>السبب / التفاصيل</th></tr></thead>
          <tbody>
            {isLoading && <tr><td colSpan={5} className="text-center py-8 text-slate-400">جاري التحميل...</td></tr>}
            {!isLoading && !logs?.length && <tr><td colSpan={5}><EmptyState message="لا توجد سجلات تعديلات" icon="📑" /></td></tr>}
            {logs?.map((l: any) => (
              <tr key={l.id}>
                <td className="text-xs text-slate-500">{l.created_at ? new Date(l.created_at).toLocaleString("ar-EG") : "-"}</td>
                <td className="font-semibold text-sm">{l.performed_by_name || "-"}</td>
                <td><span className={l.action_type === "create" ? "badge-green" : l.action_type === "delete" ? "badge-red" : "badge-yellow"}>{actionLabels[l.action_type] || l.action_type}</span></td>
                <td className="text-sm">{entityLabels[l.entity_type] || l.entity_type}</td>
                <td className="text-xs text-slate-500">{l.reason || JSON.stringify(l.details || {})}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}




function AttendanceTable({ month, employees }: { month: string; employees: any[] | undefined }) {
  const { data: attendance } = useQuery({
    queryKey: ['hr-attendance', month],
    queryFn: () => hrApi.attendance({ month }),
    enabled: !!month,
  })
  const qc = useQueryClient()
  const [editRec, setEditRec] = useState<any>(null)
  const saveMut = useMutation({
    mutationFn: (d: any) => hrApi.addAttendance(d),
    onSuccess: () => { toast.success('تم الحفظ'); setEditRec(null); qc.invalidateQueries({ queryKey: ['hr-attendance'] }) },
  })

  const statusColors: Record<string, string> = { present: 'badge-green', absent: 'badge-red', leave: 'badge-blue', mission: 'badge-blue', excuse: 'badge-yellow' }
  const statusLabels: Record<string, string> = { present: 'حضور', absent: 'غياب', leave: 'إجازة', mission: 'مأمورية', excuse: 'عذر' }

  return (
    <div className="card p-0 overflow-hidden">
      <div className="table-wrap max-h-[60vh] overflow-y-auto">
        <table>
          <thead><tr><th>الموظف</th><th>التاريخ</th><th>دخول</th><th>خروج</th><th>الحالة</th><th>ملاحظة</th><th></th></tr></thead>
          <tbody>
            {!attendance?.length && <tr><td colSpan={7}><EmptyState message="لا توجد سجلات حضور" icon="📅" /></td></tr>}
            {attendance?.map((a: any) => (
              <tr key={a.id} className={a.edited ? 'bg-yellow-50' : ''}>
                <td className="font-semibold">{a.emp_name}</td>
                <td className="text-sm">{a.work_date}</td>
                <td className="text-xs text-slate-600 font-mono">{a.check_in ? new Date(a.check_in).toLocaleTimeString('ar-EG') : '-'}</td>
                <td className="text-xs text-slate-600 font-mono">{a.check_out ? new Date(a.check_out).toLocaleTimeString('ar-EG') : '-'}</td>
                <td><span className={statusColors[a.status] || 'badge-gray'}>{statusLabels[a.status] || a.status}</span></td>
                <td className="text-xs text-slate-400">{a.edit_reason || ''}</td>
                <td><button onClick={() => setEditRec(a)} className="text-xs text-blue-600 hover:underline">تعديل</button></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      {editRec && (
        <Modal open={true} onClose={() => setEditRec(null)} title="تعديل سجل الحضور">
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div><label className="block text-sm font-medium text-slate-600 mb-1">وقت الدخول</label>
                <input type="datetime-local" className="input" defaultValue={editRec.check_in?.slice(0,16)} id="ci" /></div>
              <div><label className="block text-sm font-medium text-slate-600 mb-1">وقت الخروج</label>
                <input type="datetime-local" className="input" defaultValue={editRec.check_out?.slice(0,16)} id="co" /></div>
            </div>
            <div><label className="block text-sm font-medium text-slate-600 mb-1">الحالة</label>
              <select className="input" defaultValue={editRec.status} id="st">
                {['present','absent','leave','mission','excuse'].map(s => <option key={s} value={s}>{statusLabels[s]}</option>)}
              </select></div>
            <div><label className="block text-sm font-medium text-slate-600 mb-1">سبب التعديل</label>
              <input className="input" defaultValue={editRec.edit_reason || ''} id="er" /></div>
            <div className="flex gap-3 justify-end">
              <button onClick={() => setEditRec(null)} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
              <button onClick={() => saveMut.mutate({
                employee_id: editRec.employee_id,
                work_date: editRec.work_date,
                check_in: (document.getElementById('ci') as HTMLInputElement)?.value || null,
                check_out: (document.getElementById('co') as HTMLInputElement)?.value || null,
                status: (document.getElementById('st') as HTMLSelectElement)?.value,
                edit_reason: (document.getElementById('er') as HTMLInputElement)?.value,
                edited: true,
              })} className="px-5 py-2 rounded-xl text-sm font-bold text-white" style={{ background: '#1e3a5f' }}>حفظ</button>
            </div>
          </div>
        </Modal>
      )}
    </div>
  )
}

import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import api from '../../api/client'
import { PageLoader, EmptyState } from '../../components/ui/Loaders'
import DataTable from '../../components/ui/DataTable'
import Modal from '../../components/ui/Modal'
import toast from 'react-hot-toast'
import { Plus, Edit2, Trash2, Calculator, ChevronDown, ChevronLeft, Clock, TrendingUp, AlertCircle } from 'lucide-react'
import { format, startOfMonth } from 'date-fns'
import { clsx } from 'clsx'

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
        <div><label className="block text-sm font-medium text-slate-600 mb-1">الاسم *</label><input className="input" value={form.name} onChange={e => set('name', e.target.value)} required /></div>
        <div><label className="block text-sm font-medium text-slate-600 mb-1">الكود</label><input className="input" value={form.emp_code || ''} onChange={e => set('emp_code', e.target.value)} /></div>
        <div><label className="block text-sm font-medium text-slate-600 mb-1">المسمى الوظيفي</label><input className="input" value={form.position || ''} onChange={e => set('position', e.target.value)} /></div>
        <div><label className="block text-sm font-medium text-slate-600 mb-1">الراتب الشهري</label><input type="number" className="input" value={form.monthly_salary} onChange={e => set('monthly_salary', e.target.value)} /></div>
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">الوردية</label>
          <select className="input" value={form.shift_schedule || ''} onChange={e => set('shift_schedule', e.target.value)}>
            <option value="">اختر وردية...</option>
            {shifts?.map((s: any) => <option key={s.id} value={s.name}>{s.name} ({s.start_time}-{s.end_time})</option>)}
          </select>
        </div>
        <div><label className="block text-sm font-medium text-slate-600 mb-1">تاريخ التعيين</label><input type="date" className="input" value={form.hire_date || ''} onChange={e => set('hire_date', e.target.value)} /></div>
        <div><label className="block text-sm font-medium text-slate-600 mb-1">حد التأخير قبل إلغاء الإضافي (دقيقة)</label><input type="number" className="input" value={form.max_lateness_before_overtime_cancellation} onChange={e => set('max_lateness_before_overtime_cancellation', e.target.value)} /></div>
        <div className="flex items-center gap-3 pt-6">
          <input type="checkbox" id="ignore_late" checked={form.ignore_lateness} onChange={e => set('ignore_lateness', e.target.checked)} className="w-4 h-4" />
          <label htmlFor="ignore_late" className="text-sm font-medium text-slate-600">تجاهل التأخير</label>
        </div>
      </div>
      <div className="flex gap-3 justify-end">
        <button type="button" onClick={onClose} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
        <button type="submit" className="px-5 py-2 rounded-xl text-sm font-bold text-white" style={{ background: '#1e3a5f' }}>حفظ</button>
      </div>
    </form>
  )
}

const STATUS_LABELS: Record<string, string> = { present: 'حضور', absent: 'غياب', leave: 'إجازة', mission: 'مأمورية', excuse: 'عذر', weekend: 'عطلة', 'pre-hire': 'قبل التعيين' }
const STATUS_COLORS: Record<string, string> = { present: 'badge-green', absent: 'badge-red', leave: 'badge-blue', mission: 'badge-blue', excuse: 'badge-yellow', weekend: 'badge-gray', 'pre-hire': 'badge-gray' }

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
  const [showAddShift, setShowAddShift] = useState(false)
  const [editPayroll, setEditPayroll] = useState<any>(null)
  const qc = useQueryClient()

  const { data: employees, isLoading: loadingEmps } = useQuery({ queryKey: ['hr-employees'], queryFn: hrApi.employees })
  const { data: shifts } = useQuery({ queryKey: ['hr-shifts'], queryFn: hrApi.shifts })
  const { data: payrollData, isLoading: loadingPayroll } = useQuery({ queryKey: ['hr-payroll', selectedMonth], queryFn: () => hrApi.payroll(selectedMonth) })
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

      <div className="flex gap-0 mb-6 border-b border-slate-200 overflow-x-auto">
        {tabs.map(t => (
          <button key={t.id} onClick={() => setTab(t.id as any)}
            className={`px-4 py-3 text-sm font-semibold border-b-2 transition-all -mb-px whitespace-nowrap flex-shrink-0 ${tab === t.id ? 'border-blue-600 text-blue-700' : 'border-transparent text-slate-500 hover:text-slate-700'}`}>
            {t.label}
          </button>
        ))}
      </div>

      {/* ── Payroll Tab ── */}
      {tab === 'payroll' && (
        <div>
          <div className="flex items-center gap-3 mb-5 flex-wrap">
            <input type="month" className="input w-48" value={selectedMonth} onChange={e => setSelectedMonth(e.target.value)} />
            <button onClick={() => calcMut.mutate()} disabled={calcMut.isPending}
              className="px-5 py-2.5 rounded-xl text-sm font-bold text-white flex items-center gap-2 disabled:opacity-50"
              style={{ background: '#16a34a' }}>
              <Calculator size={15} /> حساب الرواتب
            </button>
            <button onClick={() => window.open(reportUrl(`/hr/payroll/report/monthly?month=${selectedMonth}`), '_blank')}
              className="px-3 py-2 rounded-xl text-xs font-bold border border-slate-200 text-slate-600 hover:bg-slate-50">
              📄 تقرير الرواتب
            </button>
            <button onClick={() => window.open(reportUrl(`/hr/attendance/report?month=${selectedMonth}`), '_blank')}
              className="px-3 py-2 rounded-xl text-xs font-bold border border-slate-200 text-slate-600 hover:bg-slate-50">
              📊 تقرير الحضور
            </button>
            {totalNet > 0 && (
              <div className="mr-auto bg-blue-50 border border-blue-200 rounded-xl px-4 py-2 text-sm">
                إجمالي الرواتب: <span className="font-black text-blue-800">{totalNet.toLocaleString('ar-EG')} ج.م</span>
              </div>
            )}
          </div>

          {loadingPayroll ? <PageLoader /> : (
            <div className="card p-0 overflow-hidden">
              <div className="table-wrap">
                <table>
                  <thead>
                    <tr>
                      <th>الموظف</th><th>الراتب الأساسي</th><th>أيام الحضور</th><th>تأخير</th><th>خصم التأخير</th>
                      <th>إضافي</th><th>أجر إضافي</th><th>سلف</th><th>صافي الراتب</th><th>الحالة</th><th>الإجراءات</th>
                    </tr>
                  </thead>
                  <tbody>
                    {!payrollData?.length && <tr><td colSpan={11}><EmptyState message="اضغط حساب الرواتب" icon="💰" /></td></tr>}
                    {payrollData?.map((p: any) => (
                      <tr key={p.id}>
                        <td>
                          <p className="font-semibold">{p.emp_name}</p>
                          <p className="text-xs text-slate-400">{p.position}</p>
                        </td>
                        <td>{Number(p.base_salary).toLocaleString('ar-EG')}</td>
                        <td>
                          <span className="font-bold text-green-700">{p.working_days}</span>
                          {p.absent_days > 0 && <span className="text-xs text-red-500 mr-1">({p.absent_days} غياب)</span>}
                        </td>
                        <td className={p.lateness_minutes > 0 ? 'text-amber-600 font-semibold' : ''}>
                          {p.lateness_minutes > 0 ? `${p.lateness_minutes} د` : '-'}
                        </td>
                        <td className="text-red-600 font-semibold">
                          {Number(p.lateness_deduction) > 0 ? `${Number(p.lateness_deduction).toLocaleString('ar-EG')} ج.م` : '-'}
                        </td>
                        <td className="text-blue-600">{p.overtime_hours > 0 ? `${p.overtime_hours}h` : '-'}</td>
                        <td className="text-green-600">{Number(p.overtime_pay) > 0 ? `${Number(p.overtime_pay).toLocaleString('ar-EG')}` : '-'}</td>
                        <td className="text-amber-600">{Number(p.advances) > 0 ? `${Number(p.advances).toLocaleString('ar-EG')}` : '-'}</td>
                        <td className="font-black text-lg" style={{ color: '#1e3a5f' }}>{Number(p.net_salary).toLocaleString('ar-EG')} ج.م</td>
                        <td>
                          <span className={p.status === 'paid' ? 'badge-green' : p.status === 'approved' ? 'badge-blue' : 'badge-gray'}>
                            {p.status === 'paid' ? 'مدفوع' : p.status === 'approved' ? 'معتمد' : 'مسودة'}
                          </span>
                        </td>
                        <td>
                          <div className="flex gap-1 flex-nowrap">
                            <button
                              onClick={async () => { const d = await hrApi.breakdown(p.id); setBreakdown(d) }}
                              className="px-2 py-1 rounded-lg text-xs font-semibold bg-blue-50 text-blue-700 hover:bg-blue-100 whitespace-nowrap">
                              تفاصيل
                            </button>
                            <button
                              onClick={() => window.open(reportUrl(`/hr/payroll/report/employee/${p.employee_id}?month=${selectedMonth}&report_type=detailed`), '_blank')}
                              className="px-2 py-1 rounded-lg text-xs font-semibold bg-green-50 text-green-700 hover:bg-green-100 whitespace-nowrap">
                              تقرير
                            </button>
                            <button
                              onClick={() => window.open(reportUrl(`/hr/payroll/report/employee/${p.employee_id}?month=${selectedMonth}&report_type=ticket`), '_blank')}
                              className="px-2 py-1 rounded-lg text-xs font-semibold bg-amber-50 text-amber-700 hover:bg-amber-100 whitespace-nowrap">
                              قسيمة
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </div>
      )}


      {/* ── Attendance Tab ── */}
      {tab === 'attendance' && (
        <div>
          <div className="flex items-center gap-4 mb-5 flex-wrap">
            <input type="month" className="input w-48" value={selectedMonth} onChange={e => setSelectedMonth(e.target.value)} />
            <button onClick={() => window.open(reportUrl(`/hr/attendance/report?month=${selectedMonth}`), '_blank')}
              className="px-5 py-2.5 rounded-xl text-sm font-bold text-white flex items-center gap-2"
              style={{ background: '#0891b2' }}>
              📊 تصدير تقرير الحضور
            </button>
          </div>
          <AttendanceTable month={selectedMonth} employees={employees} />
        </div>
      )}

      {/* ── Shifts Tab ── */}
      {tab === 'shifts' && (
        <div>
          <div className="flex justify-end mb-4">
            <button onClick={() => setShowAddShift(true)} className="px-4 py-2.5 rounded-xl text-sm font-bold text-white flex items-center gap-2" style={{ background: '#1e3a5f' }}>
              <Plus size={15} /> إضافة مناوبة
            </button>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {shifts?.map((s: any) => (
              <div key={s.id} className="card">
                <p className="font-bold text-slate-800 text-lg">{s.name}</p>
                <p className="text-slate-500 text-sm mt-1">🕐 {s.start_time} — {s.end_time}</p>
                {s.description && <p className="text-xs text-slate-400 mt-1">{s.description}</p>}
              </div>
            ))}
          </div>
        </div>
      )}


      {/* ── Reports Tab (📊 التقارير) — matches Qt init_reports_tab exactly ── */}
      {tab === 'reports' && (
        <div>
          <div className="flex items-center gap-4 mb-6 flex-wrap">
            <label className="text-sm font-medium text-slate-600">📅 الشهر:</label>
            <input type="month" className="input w-48" value={selectedMonth} onChange={e => setSelectedMonth(e.target.value)} />
          </div>
          <div className="card max-w-2xl">
            <h3 className="font-bold text-slate-700 mb-6 text-lg">📄 التقارير المتاحة</h3>
            <div className="space-y-4">
              <div className="flex items-center justify-between p-4 rounded-xl bg-slate-50 border border-slate-200">
                <div>
                  <p className="font-bold text-slate-800">📄 تقرير الرواتب الشهري</p>
                  <p className="text-sm text-slate-500 mt-0.5">عرض ملخص رواتب جميع الموظفين للشهر المحدد</p>
                </div>
                <button onClick={() => window.open(reportUrl(`/hr/payroll/report/monthly?month=${selectedMonth}`), "_blank")}
                  className="px-5 py-2.5 rounded-xl text-sm font-bold text-white flex items-center gap-2"
                  style={{ background: "#1e3a5f" }}>
                  عرض التقرير
                </button>
              </div>
              <div className="flex items-center justify-between p-4 rounded-xl bg-slate-50 border border-slate-200">
                <div>
                  <p className="font-bold text-slate-800">📋 تقرير الموظف الفردي</p>
                  <p className="text-sm text-slate-500 mt-0.5">عرض تفاصيل الراتب والحضور لموظف محدد</p>
                </div>
                <div className="flex gap-2 items-center">
                  <select className="input w-48 text-sm" id="report-emp-select">
                    <option value="">اختر موظف...</option>
                    {employees?.map((e: any) => <option key={e.id} value={e.id}>{e.name}</option>)}
                  </select>
                  <button onClick={() => {
                    const sel = (document.getElementById("report-emp-select") as HTMLSelectElement)?.value
                    if (sel) window.open(reportUrl(`/hr/payroll/report/employee/${sel}?month=${selectedMonth}&report_type=detailed`), "_blank")
                  }} className="px-4 py-2.5 rounded-xl text-sm font-bold text-white" style={{ background: "#1e3a5f" }}>تقرير مفصل</button>
                  <button onClick={() => {
                    const sel = (document.getElementById("report-emp-select") as HTMLSelectElement)?.value
                    if (sel) window.open(reportUrl(`/hr/payroll/report/employee/${sel}?month=${selectedMonth}&report_type=ticket`), "_blank")
                  }} className="px-4 py-2.5 rounded-xl text-sm font-bold text-white" style={{ background: "#c8a84b", color: "#1e3a5f" }}>قسيمة راتب</button>
                </div>
              </div>
              <div className="flex items-center justify-between p-4 rounded-xl bg-slate-50 border border-slate-200">
                <div>
                  <p className="font-bold text-slate-800">📊 تقرير الحضور</p>
                  <p className="text-sm text-slate-500 mt-0.5">عرض سجل الحضور والغياب لجميع الموظفين</p>
                </div>
                <button onClick={() => window.open(reportUrl(`/hr/attendance/report?month=${selectedMonth}`), "_blank")}
                  className="px-5 py-2.5 rounded-xl text-sm font-bold text-white flex items-center gap-2"
                  style={{ background: "#0891b2" }}>
                  عرض التقرير
                </button>
              </div>
            </div>
            <div className="mt-6 p-4 rounded-xl bg-blue-50 border border-blue-200 text-sm text-blue-700">
              ✓ يتم إنشاء التقارير بصيغة HTML جاهزة للطباعة والمشاركة
            </div>
          </div>
        </div>
      )}

      {/* ── Employees Tab ── */}
      {tab === 'employees' && (
        <div>
          <div className="flex items-center justify-between mb-4 gap-3">
            <input className="input max-w-xs" placeholder="بحث بالاسم أو الوظيفة..."
              onChange={e => setEmpSearch(e.target.value)} />
            <button onClick={() => setShowAddEmp(true)} className="px-4 py-2.5 rounded-xl text-sm font-bold text-white flex items-center gap-2 flex-shrink-0" style={{ background: '#1e3a5f' }}>
              <Plus size={15} /> إضافة موظف
            </button>
          </div>
          <DataTable
            columns={[
              { key: 'name', label: 'الموظف', sortable: true, render: (e: any) => (
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-xl flex items-center justify-center text-white font-black text-sm flex-shrink-0" style={{ background: '#1e3a5f' }}>{e.name[0]}</div>
                  <div><p className="font-bold text-slate-800">{e.name}</p><p className="text-xs text-slate-400">{e.shift_schedule || ''}</p></div>
                </div>
              )},
              { key: 'position', label: 'الوظيفة', sortable: true, render: (e: any) => <span className="text-slate-600">{e.position}</span> },
              { key: 'monthly_salary', label: 'الراتب', sortable: true, render: (e: any) => <span className="font-black" style={{ color: '#1e3a5f' }}>{Number(e.monthly_salary).toLocaleString('ar-EG')} ج.م</span> },
              { key: 'status', label: 'الحالة', render: (e: any) => <span className={e.is_active !== false ? 'badge-green' : 'badge-red'}>{e.is_active !== false ? 'نشط' : 'غير نشط'}</span> },
              { key: 'actions', label: '', render: (e: any) => (
                <div className="flex gap-1 justify-end">
                  <button onClick={() => setEditEmp(e)} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400"><Edit2 size={14} /></button>
                  <button onClick={() => { if (confirm('حذف الموظف؟')) deleteEmpMut.mutate(e.id) }} className="p-1.5 rounded-lg hover:bg-red-50 text-slate-300 hover:text-red-500"><Trash2 size={14} /></button>
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
            <button onClick={() => setShowAddAdvance(true)} className="px-4 py-2.5 rounded-xl text-sm font-bold text-white flex items-center gap-2" style={{ background: '#1e3a5f' }}>
              <Plus size={15} /> تسجيل سلفة
            </button>
          </div>
          <div className="card p-0 overflow-hidden">
            <div className="table-wrap">
              <table>
                <thead><tr><th>الموظف</th><th>المبلغ</th><th>التاريخ</th><th>ملاحظة</th></tr></thead>
                <tbody>
                  {!advances?.length && <tr><td colSpan={4}><EmptyState message="لا توجد سلف" icon="💸" /></td></tr>}
                  {advances?.map((a: any) => (
                    <tr key={a.id}>
                      <td className="font-semibold">{a.emp_name}</td>
                      <td className="font-bold text-amber-700">{Number(a.amount).toLocaleString('ar-EG')} ج.م</td>
                      <td className="text-sm text-slate-500">{new Date(a.date).toLocaleDateString('ar-EG')}</td>
                      <td className="text-sm text-slate-400">{a.note || '-'}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
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
        <div className="card max-w-lg">
          <h3 className="font-bold text-slate-700 mb-5">إعدادات حساب الرواتب</h3>
          <div className="space-y-4">
            {[
              { key: 'grace_period_minutes', label: 'فترة السماح (دقيقة)' },
              { key: 'late_penalty_multiplier', label: 'مضاعف خصم التأخير' },
              { key: 'missing_checkout_penalty_hours', label: 'خصم غياب البصمة (ساعة)' },
              { key: 'days_in_month', label: 'أيام الشهر المحتسبة' },
            ].map(({ key, label }) => (
              <div key={key}>
                <label className="block text-sm font-medium text-slate-600 mb-1">{label}</label>
                <input type="number" step="0.1" className="input" value={sf[key] || ''}
                  onChange={e => setSettingsForm({ ...sf, [key]: e.target.value })} />
              </div>
            ))}
            <div className="flex items-center gap-3">
              <input type="checkbox" id="mcp" checked={sf.apply_missing_checkout_penalty === 'True' || sf.apply_missing_checkout_penalty === true}
                onChange={e => setSettingsForm({ ...sf, apply_missing_checkout_penalty: e.target.checked ? 'True' : 'False' })} className="w-4 h-4" />
              <label htmlFor="mcp" className="text-sm font-medium text-slate-600">تطبيق خصم عدم تسجيل الخروج</label>
            </div>
            <div className="flex items-center gap-3">
              <input type="checkbox" id="ot" checked={sf.overtime_enabled === 'True' || sf.overtime_enabled === true}
                onChange={e => setSettingsForm({ ...sf, overtime_enabled: e.target.checked ? 'True' : 'False' })} className="w-4 h-4" />
              <label htmlFor="ot" className="text-sm font-medium text-slate-600">تفعيل الإضافي</label>
            </div>
            <div className="flex items-center gap-3">
              <input type="checkbox" id="wp" checked={sf.weekend_paid === 'True' || sf.weekend_paid === true}
                onChange={e => setSettingsForm({ ...sf, weekend_paid: e.target.checked ? 'True' : 'False' })} className="w-4 h-4" />
              <label htmlFor="wp" className="text-sm font-medium text-slate-600">الجمعة مدفوعة</label>
            </div>
            <button onClick={() => saveSettingsMut.mutate()} className="px-5 py-2.5 rounded-xl text-sm font-bold text-white w-full" style={{ background: '#1e3a5f' }}>
              حفظ الإعدادات
            </button>
          </div>
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
            <label className="block text-sm font-medium text-slate-600 mb-1">الموظف</label>
            <select className="input" value={advEmpId} onChange={e => setAdvEmpId(e.target.value)}>
              <option value="">اختر موظف...</option>
              {employees?.map((e: any) => <option key={e.id} value={e.id}>{e.name}</option>)}
            </select>
          </div>
          <div><label className="block text-sm font-medium text-slate-600 mb-1">النوع</label><select className="input" value={advType} onChange={e => setAdvType(e.target.value)}><option value="سلفة">سلفة</option><option value="مكافأة">مكافأة</option><option value="خصم">خصم</option></select></div>
          <div><label className="block text-sm font-medium text-slate-600 mb-1">المبلغ</label><input type="number" className="input" value={advAmount} onChange={e => setAdvAmount(e.target.value)} /></div>
          <div><label className="block text-sm font-medium text-slate-600 mb-1">ملاحظة</label><input className="input" value={advNote} onChange={e => setAdvNote(e.target.value)} /></div>
          <div className="flex gap-3 justify-end">
            <button onClick={() => setShowAddAdvance(false)} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
            <button onClick={() => addAdvanceMut.mutate()} disabled={!advEmpId || !advAmount} className="px-5 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#1e3a5f' }}>تسجيل</button>
          </div>
        </div>
      </Modal>

      {/* Daily Breakdown Modal */}
      <Modal open={!!breakdown} onClose={() => setBreakdown(null)} title={`تفاصيل: ${breakdown?.employee}`} size="xl">
        {breakdown && (
          <div className="table-wrap max-h-[70vh] overflow-y-auto">
            <table>
              <thead><tr><th>التاريخ</th><th>الحالة</th><th>دخول</th><th>خروج</th><th>ساعات</th><th>تأخير</th><th>إضافي</th><th>ملاحظة</th></tr></thead>
              <tbody>
                {breakdown.breakdown?.map((d: any, i: number) => (
                  <tr key={i} className={d.status === 'absent' ? 'bg-red-50' : d.status === 'weekend' ? 'bg-slate-50' : ''}>
                    <td className="text-sm font-medium">{d.date}</td>
                    <td><span className={STATUS_COLORS[d.status] || 'badge-gray'}>{STATUS_LABELS[d.status] || d.status}</span></td>
                    <td className="text-xs text-slate-600">{d.check_in ? d.check_in.slice(11, 16) : '-'}</td>
                    <td className="text-xs text-slate-600">{d.check_out ? d.check_out.slice(11, 16) : '-'}</td>
                    <td className="font-semibold">{d.work_hours > 0 ? d.work_hours.toFixed(1) : '-'}</td>
                    <td className={d.late_minutes > 0 ? 'text-amber-600 font-semibold' : ''}>{d.late_minutes > 0 ? `${d.late_minutes}د` : '-'}</td>
                    <td className={d.overtime_hours > 0 ? 'text-blue-600 font-semibold' : ''}>{d.overtime_hours > 0 ? `${d.overtime_hours.toFixed(1)}h` : '-'}</td>
                    <td className="text-xs text-slate-400 max-w-xs truncate">{d.note || ''}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Modal>
    </div>
  )
}
