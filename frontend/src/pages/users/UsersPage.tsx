import { useState, useEffect } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { usersApi, stockApi } from '../../api/endpoints'
import api from '../../api/client'
import { Input } from '../../components/ui/input'
import Modal from '../../components/ui/Modal'
import DataTable from '../../components/ui/DataTable'
import toast from 'react-hot-toast'
import { Plus, Edit2, Trash2, Save, KeyRound } from 'lucide-react'
import ConfirmDialog from '../../components/ui/ConfirmDialog'
import { Select } from '../../components/ui/select'
import { Badge } from '../../components/ui/badge'
import { Button } from '../../components/ui/button'

const ALL_PAGES = [
  { id: 'pos',        label: 'نقطة البيع',       icon: '🛒' },
  { id: 'sales',      label: 'الفواتير',          icon: '🧾' },
  { id: 'quotations', label: 'عروض الأسعار',      icon: '📋' },
  { id: 'inventory',  label: 'المخزون',           icon: '📦' },
  { id: 'operations', label: 'العمليات',          icon: '🚚' },
  { id: 'customers',  label: 'العملاء',           icon: '👤' },
  { id: 'reports',    label: 'التقارير',          icon: '📊' },
  { id: 'finance',    label: 'الميزان المالي',    icon: '⚖️' },
  { id: 'archive',    label: 'الأرشيف',           icon: '📁' },
  { id: 'payroll',    label: 'الرواتب',           icon: '💰' },
  { id: 'users',      label: 'المستخدمون',        icon: '👥' },
  { id: 'settings',   label: 'الإعدادات',         icon: '⚙️' },
  { id: 'admin',      label: 'الإدارة الشاملة',   icon: '🏢' },
  { id: 'shifts',     label: 'الورديات',          icon: '🕐' },
]

function UserForm({ user, onSave, onClose }: any) {
  const [form, setForm] = useState(user || { username: '', full_name: '', role: 'cashier', password: '', default_warehouse_id: '' })
  const [warehouseIds, setWarehouseIds] = useState<string[]>([])
  const { data: warehouses } = useQuery({ queryKey: ['warehouses'], queryFn: stockApi.warehouses })
  const { data: userWarehouses } = useQuery({
    queryKey: ['user-warehouses', user?.id],
    queryFn: () => api.get(`/users/${user.id}/warehouses`).then(r => r.data),
    enabled: !!user?.id,
  })
  useEffect(() => { if (userWarehouses) setWarehouseIds(userWarehouses) }, [userWarehouses])

  const set = (k: string, v: any) => setForm((f: any) => ({ ...f, [k]: v }))
  const handleSave = (e: any) => {
    e.preventDefault()
    if (user?.id) {
      api.put(`/users/${user.id}/warehouses`, { warehouse_ids: warehouseIds.filter(Boolean) }).catch(() => {})
    }
    onSave(form)
  }
  return (
    <form onSubmit={handleSave} className="space-y-4">
 <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">اسم المستخدم *</label><Input value={form.username} onChange={e => set('username', e.target.value)} required disabled={!!user}/></div>
 <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الاسم الكامل *</label><Input value={form.full_name} onChange={e => set('full_name', e.target.value)} required/></div>
      <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">المسمى الوظيفي</label>
        <Select value={form.role} onChange={e => set('role', e.target.value)}>
          <option value="admin">مدير عام</option>
          <option value="manager">مشرف</option>
          <option value="cashier">كاشير</option>
          <option value="storekeeper">أمين مخازن</option>
          <option value="accountant">محاسب</option>
        </Select>
      </div>
 {!user && <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">كلمة المرور *</label><Input type="password" value={form.password} onChange={e => set('password', e.target.value)} required/></div>}
      <div><label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الفرع الافتراضي</label>
        <Select value={form.default_warehouse_id || ''} onChange={e => set('default_warehouse_id', e.target.value)}>
          <option value="">— بدون تحديد (مدير) —</option>
          {warehouses?.map((w: any) => <option key={w.id} value={w.id}>{w.name}</option>)}
        </Select>
        <p className="text-xs text-[var(--muted)] mt-1">الموظفون غير المديرين سيُقيَّدون بهذا الفرع تلقائياً</p>
      </div>
      {user && (
        <div>
          <label className="block text-sm font-medium text-[var(--text-soft)] mb-2">الفروع المسموح الدخول إليها</label>
          <div className="grid grid-cols-2 gap-2">
            {warehouses?.map((w: any) => (
              <label key={w.id} className="flex items-center gap-2 p-2 rounded-lg border border-[var(--border)] cursor-pointer hover:bg-[var(--surface-2)]">
                <input type="checkbox" aria-label={`صلاحية ${w.name}`} checked={warehouseIds.includes(w.id)}
                  onChange={e => setWarehouseIds(prev => e.target.checked ? [...prev, w.id] : prev.filter(id => id !== w.id))} />
                <span className="text-sm">{w.name}</span>
              </label>
            ))}
          </div>
        </div>
      )}
      <div className="flex gap-3 justify-end">
        <Button type="button" variant="secondary" onClick={onClose}>إلغاء</Button>
        <Button type="submit" className="px-5">حفظ</Button>
      </div>
    </form>
  )
}

function PermissionsPanel({ users }: { users: any[] | undefined }) {
  const [selectedUser, setSelectedUser] = useState<any>(null)
  const [perms, setPerms] = useState<string[]>([])
  const [isManager, setIsManager] = useState(false)
  const qc = useQueryClient()

  const { data: userPerms } = useQuery({
    queryKey: ['user-perms', selectedUser?.id],
    queryFn: () => api.get(`/permissions/${selectedUser.id}`).then(r => r.data),
    enabled: !!selectedUser,
    staleTime: Infinity,
  })

  useEffect(() => {
    if (!selectedUser || !userPerms) return
    setPerms(userPerms.permissions || [])
    setIsManager(!!userPerms.is_manager)
  }, [selectedUser, userPerms])

  const saveMut = useMutation({
    mutationFn: () => api.put(`/permissions/${selectedUser.id}`, { permissions: perms, is_manager: isManager }),
    onSuccess: () => { toast.success('تم حفظ الصلاحيات'); qc.invalidateQueries({ queryKey: ['user-perms'] }) },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل حفظ الصلاحيات'),
  })

  const selectUser = (u: any) => { setSelectedUser(u); setPerms([]); setIsManager(false) }

  return (
    <div className="flex gap-5 h-[calc(100vh-14rem)]">
      {/* User list */}
      <div className="w-56 flex-shrink-0 space-y-1.5 overflow-y-auto">
        {users?.map(u => (
          <Button key={u.id} onClick={() => selectUser(u)} variant="ghost"
            className={`w-full text-right p-3 rounded-xl border transition-all h-auto ${selectedUser?.id === u.id ? 'border-[var(--primary)] bg-[var(--primary-soft)]' : 'bg-[var(--surface)] border-[var(--border-faint)] hover:border-[var(--border)]'}`}>
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-xl flex items-center justify-center text-white text-xs font-bold flex-shrink-0" style={{ background: 'var(--primary)' }}>{u.full_name?.[0]}</div>
              <div className="min-w-0"><p className="font-semibold text-[var(--text)] text-sm truncate">{u.full_name}</p><p className="text-xs text-[var(--muted)]">@{u.username}</p></div>
            </div>
          </Button>
        ))}
      </div>

      {/* Permissions */}
      {!selectedUser ? (
        <div className="flex-1 flex items-center justify-center text-[var(--muted)]">
          <div className="text-center"><p className="text-4xl mb-3">🔐</p><p>اختر موظفاً لتعديل صلاحياته</p></div>
        </div>
      ) : (
        <div className="flex-1 flex flex-col min-w-0">
          <div className="flex items-center justify-between mb-4">
            <div><h3 className="font-black text-[var(--text)]">{selectedUser.full_name}</h3><p className="text-[var(--muted)] text-sm">@{selectedUser.username}</p></div>
            <div className="flex gap-2">
              <Button variant="secondary" size="sm" onClick={() => setPerms(ALL_PAGES.map(p => p.id))} className="text-xs">تحديد الكل</Button>
              <Button variant="secondary" size="sm" onClick={() => setPerms([])} className="text-xs">مسح الكل</Button>
              <Button size="sm" onClick={() => saveMut.mutate()} disabled={saveMut.isPending} className="bg-[#16a34a] hover:bg-[#16a34a]/90">
                <Save size={12} /> حفظ
              </Button>
            </div>
          </div>

          {/* Manager toggle */}
          <div className="flex items-center justify-between p-3 rounded-xl bg-amber-50 border border-amber-200 mb-4">
            <div><p className="font-semibold text-amber-800 text-sm">مدير — يستلم التوريد عند إغلاق الدرج</p></div>
            <Button onClick={() => setIsManager(v => !v)} variant="ghost" aria-pressed={isManager}
              className={`w-11 h-6 p-0 rounded-full transition-all relative ${isManager ? 'bg-green-500' : 'bg-slate-300'}`}>
              <div className={`w-4 h-4 bg-[var(--surface)] rounded-full absolute top-1 transition-all shadow ${isManager ? 'left-6' : 'left-1'}`} />
            </Button>
          </div>

          <div className="grid grid-cols-3 gap-2 overflow-y-auto flex-1">
            {ALL_PAGES.map(page => {
              const enabled = perms.includes(page.id)
              return (
                <Button key={page.id} onClick={() => setPerms(prev => prev.includes(page.id) ? prev.filter(p => p !== page.id) : [...prev, page.id])} variant="ghost"
                  className={`w-full p-3 h-auto rounded-xl border-2 text-right transition-all ${enabled ? 'border-[var(--primary)] bg-[var(--primary-soft)]' : 'border-[var(--border)] bg-[var(--surface)] hover:border-[var(--border-strong)]'}`}>
                  <div className="flex items-center justify-between mb-1">
                    <span className="text-xl">{page.icon}</span>
                    <div className={`w-4 h-4 rounded border-2 flex items-center justify-center ${enabled ? 'border-blue-500 bg-blue-500' : 'border-[var(--border-strong)]'}`}>
                      {enabled && <svg width="8" height="6" viewBox="0 0 8 6" fill="none"><path d="M1 3L3 5L7 1" stroke="white" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg>}
                    </div>
                  </div>
                  <p className={`text-xs font-bold ${enabled ? 'text-blue-800' : 'text-[var(--text-soft)]'}`}>{page.label}</p>
                </Button>
              )
            })}
          </div>
        </div>
      )}
    </div>
  )
}

export default function UsersPage() {
  const [tab, setTab] = useState<'users' | 'permissions'>('users')
  const [showAdd, setShowAdd] = useState(false)
  const [editUser, setEditUser] = useState<any>(null)
  const [resetPwUser, setResetPwUser] = useState<any>(null)
  const [newPassword, setNewPassword] = useState('')
  const [confirmDel, setConfirmDel] = useState<any>(null)
  const qc = useQueryClient()

  const { data: users, isLoading } = useQuery({ queryKey: ['users'], queryFn: usersApi.list })

  const createMut = useMutation({ mutationFn: usersApi.create, onSuccess: () => { toast.success('تمت الإضافة'); setShowAdd(false); qc.invalidateQueries({ queryKey: ['users'] }) }, onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل إضافة المستخدم') })
  const updateMut = useMutation({ mutationFn: ({ id, data }: any) => usersApi.update(id, data), onSuccess: () => { toast.success('تم التحديث'); setEditUser(null); qc.invalidateQueries({ queryKey: ['users'] }) } })
  const resetMut = useMutation({ mutationFn: ({ id, password }: any) => api.post(`/users/${id}/reset-password`, { password }), onSuccess: () => toast.success('تم تغيير كلمة المرور'), onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل تغيير كلمة المرور') })
  const deleteMut = useMutation({ mutationFn: usersApi.delete, onSuccess: () => { toast.success('تم التعطيل'); qc.invalidateQueries({ queryKey: ['users'] }) } })

  const roleLabel: Record<string, string> = { admin: 'مدير عام', cashier: 'كاشير', manager: 'مشرف', storekeeper: 'أمين مخازن', accountant: 'محاسب' }
  const roleBadge: Record<string, string> = { admin: 'bg-red-50 text-red-600 border-red-100', cashier: 'bg-blue-50 text-blue-700 border-blue-100', manager: 'bg-amber-50 text-amber-700 border-amber-100', storekeeper: 'bg-emerald-50 text-emerald-700 border-emerald-100', accountant: 'bg-blue-50 text-blue-700 border-blue-100' }

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">المستخدمون والصلاحيات</h1>
        {tab === 'users' && (
          <Button onClick={() => setShowAdd(true)} className="px-4">
            <Plus size={15} /> إضافة مستخدم
          </Button>
        )}
      </div>

      <div className="flex gap-0 mb-6 border-b border-[var(--border)]">
        {[{ id: 'users', label: '👥 المستخدمون' }, { id: 'permissions', label: '🔐 الصلاحيات' }].map(t => (
          <Button key={t.id} onClick={() => setTab(t.id as any)} variant="ghost"
            className={`px-5 py-3 text-sm font-semibold border-b-2 transition-all -mb-px whitespace-nowrap h-auto rounded-none ${tab === t.id ? 'border-[var(--primary)] text-[var(--primary)]' : 'border-transparent text-[var(--muted)] hover:text-[var(--text)]'}`}>
            {t.label}
          </Button>
        ))}
      </div>

      {tab === 'users' && (
        <DataTable
          columns={[
            { key: 'full_name', label: 'المستخدم', sortable: true, render: (u: any) => (
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-xl flex items-center justify-center text-white font-black text-sm flex-shrink-0" style={{ background: 'var(--primary)' }}>{u.full_name?.[0]}</div>
                <div><p className="font-bold text-[var(--text)]">{u.full_name}</p><p className="text-xs text-[var(--muted)]">@{u.username}</p></div>
              </div>
            )},
            { key: 'role', label: 'المسمى الوظيفي', sortable: true, render: (u: any) => <Badge className={roleBadge[u.role] || 'bg-[var(--surface-3)] text-[var(--text-soft)] border-[var(--border)]'}>{roleLabel[u.role] || u.role}</Badge> },
            { key: 'default_warehouse_name', label: 'الفرع', render: (u: any) => <span className="text-[var(--muted)] text-sm">{u.default_warehouse_name || '—'}</span> },
            { key: 'is_manager', label: 'مدير', render: (u: any) => u.is_manager ? <Badge className="bg-emerald-50 text-emerald-700 border-emerald-100">مدير</Badge> : <span className="text-[var(--faint)] text-sm">—</span> },
            { key: 'actions', label: '', render: (u: any) => (
              <div className="flex gap-1 justify-end">
                <Button variant="ghost" size="icon-sm" onClick={() => setEditUser(u)} className="text-[var(--muted)] hover:bg-[var(--surface-3)]" title="تعديل"><Edit2 size={14} /></Button>
                <Button variant="ghost" size="icon-sm" onClick={() => { setResetPwUser(u); setNewPassword('') }} className="text-[var(--faint)] hover:text-amber-600 hover:bg-amber-50" title="إعادة تعيين كلمة المرور"><KeyRound size={14} /></Button>
                <Button variant="ghost" size="icon-sm" onClick={() => setConfirmDel({ id: u.id })} className="text-[var(--faint)] hover:text-red-500 hover:bg-red-50" title="تعطيل"><Trash2 size={14} /></Button>
              </div>
            )},
          ]}
          data={users || []}
          loading={isLoading}
          rowKey={(u: any) => u.id}
          emptyMessage="لا يوجد مستخدمون" emptyIcon="👥"
        />
      )}

      {tab === 'permissions' && <PermissionsPanel users={users} />}

      <Modal open={showAdd} onClose={() => setShowAdd(false)} title="إضافة مستخدم جديد">
        <UserForm onSave={(d: any) => createMut.mutate(d)} onClose={() => setShowAdd(false)} />
      </Modal>

      <Modal open={!!resetPwUser} onClose={() => setResetPwUser(null)} title={`إعادة تعيين كلمة المرور — ${resetPwUser?.full_name || ''}`} size="sm">
        <div className="p-4 space-y-4">
          <Input type="password" value={newPassword} onChange={e => setNewPassword(e.target.value)}
            placeholder="كلمة المرور الجديدة (8 أحرف على الأقل)"
            className="py-3 text-right"
            autoFocus dir="auto" />
          <div className="flex gap-3">
            <Button onClick={() => { setResetPwUser(null); setNewPassword('') }} variant="secondary" className="flex-1">
              إلغاء
            </Button>
            <Button onClick={() => {
              if (newPassword.trim().length < 8) { toast.error('كلمة المرور قصيرة جداً — 8 أحرف على الأقل'); return }
              resetMut.mutate({ id: resetPwUser.id, password: newPassword.trim() })
              setResetPwUser(null)
              setNewPassword('')
            }} disabled={newPassword.trim().length < 8} className="flex-1 px-5">
              حفظ
            </Button>
          </div>
        </div>
      </Modal>
      <Modal open={!!editUser} onClose={() => setEditUser(null)} title="تعديل المستخدم">
        {editUser && <UserForm user={editUser} onSave={(d: any) => updateMut.mutate({ id: editUser.id, data: d })} onClose={() => setEditUser(null)} />}
      </Modal>
      <ConfirmDialog open={!!confirmDel} onClose={() => setConfirmDel(null)}
        onConfirm={() => deleteMut.mutate(confirmDel.id)}
        message="تعطيل المستخدم؟" danger confirmText="تعطيل" />
    </div>
  )
}
