import { useState, useEffect } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { usersApi, stockApi } from '../../api/endpoints'
import api from '../../api/client'
import { PageLoader, EmptyState } from '../../components/ui/Loaders'
import Modal from '../../components/ui/Modal'
import DataTable from '../../components/ui/DataTable'
import toast from 'react-hot-toast'
import { Plus, Edit2, Trash2, Shield, Save, KeyRound } from 'lucide-react'

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
]

function UserForm({ user, onSave, onClose }: any) {
  const [form, setForm] = useState(user || { username: '', full_name: '', role: 'cashier', password: '', default_warehouse_id: '' })
  const { data: warehouses } = useQuery({ queryKey: ['warehouses'], queryFn: stockApi.warehouses })
  const set = (k: string, v: any) => setForm((f: any) => ({ ...f, [k]: v }))
  return (
    <form onSubmit={e => { e.preventDefault(); onSave(form) }} className="space-y-4">
      <div><label className="block text-sm font-medium text-slate-600 mb-1">اسم المستخدم *</label><input className="input" value={form.username} onChange={e => set('username', e.target.value)} required disabled={!!user} /></div>
      <div><label className="block text-sm font-medium text-slate-600 mb-1">الاسم الكامل *</label><input className="input" value={form.full_name} onChange={e => set('full_name', e.target.value)} required /></div>
      <div><label className="block text-sm font-medium text-slate-600 mb-1">الصلاحية</label>
        <select className="input" value={form.role} onChange={e => set('role', e.target.value)}>
          <option value="admin">مدير عام</option>
          <option value="manager">مشرف</option>
          <option value="cashier">كاشير</option>
          <option value="storekeeper">أمين مخازن</option>
          <option value="accountant">محاسب</option>
        </select>
      </div>
      {!user && <div><label className="block text-sm font-medium text-slate-600 mb-1">كلمة المرور *</label><input type="password" className="input" value={form.password} onChange={e => set('password', e.target.value)} required /></div>}
      <div><label className="block text-sm font-medium text-slate-600 mb-1">الفرع الافتراضي</label>
        <select className="input" value={form.default_warehouse_id || ''} onChange={e => set('default_warehouse_id', e.target.value)}>
          <option value="">— بدون تحديد (مدير) —</option>
          {warehouses?.map((w: any) => <option key={w.id} value={w.id}>{w.name}</option>)}
        </select>
        <p className="text-xs text-slate-400 mt-1">الموظفون غير المديرين سيُقيَّدون بهذا الفرع تلقائياً</p>
      </div>
      <div className="flex gap-3 justify-end">
        <button type="button" onClick={onClose} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
        <button type="submit" className="px-5 py-2 rounded-xl text-sm font-bold text-white" style={{ background: '#1e3a5f' }}>حفظ</button>
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
  })

  useEffect(() => {
    if (userPerms) {
      setPerms(userPerms.permissions || [])
      setIsManager(!!userPerms.is_manager)
    }
  }, [userPerms])

  const saveMut = useMutation({
    mutationFn: () => api.put(`/permissions/${selectedUser.id}`, { permissions: perms, is_manager: isManager }),
    onSuccess: () => toast.success('تم حفظ الصلاحيات'),
  })

  const selectUser = (u: any) => { setSelectedUser(u); setPerms([]); setIsManager(false) }

  return (
    <div className="flex gap-5 h-[calc(100vh-14rem)]">
      {/* User list */}
      <div className="w-56 flex-shrink-0 space-y-1.5 overflow-y-auto">
        {users?.map(u => (
          <button key={u.id} onClick={() => selectUser(u)}
            className={`w-full text-right p-3 rounded-xl border transition-all ${selectedUser?.id === u.id ? 'border-blue-300 bg-blue-50' : 'bg-white border-slate-100 hover:border-slate-200'}`}>
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-xl flex items-center justify-center text-white text-xs font-bold flex-shrink-0" style={{ background: '#1e3a5f' }}>{u.full_name?.[0]}</div>
              <div className="min-w-0"><p className="font-semibold text-slate-800 text-sm truncate">{u.full_name}</p><p className="text-xs text-slate-400">@{u.username}</p></div>
            </div>
          </button>
        ))}
      </div>

      {/* Permissions */}
      {!selectedUser ? (
        <div className="flex-1 flex items-center justify-center text-slate-400">
          <div className="text-center"><p className="text-4xl mb-3">🔐</p><p>اختر موظفاً لتعديل صلاحياته</p></div>
        </div>
      ) : (
        <div className="flex-1 flex flex-col min-w-0">
          <div className="flex items-center justify-between mb-4">
            <div><h3 className="font-black text-slate-800">{selectedUser.full_name}</h3><p className="text-slate-400 text-sm">@{selectedUser.username}</p></div>
            <div className="flex gap-2">
              <button onClick={() => setPerms(ALL_PAGES.map(p => p.id))} className="px-3 py-1.5 rounded-lg text-xs font-semibold bg-slate-100 text-slate-600 hover:bg-slate-200">تحديد الكل</button>
              <button onClick={() => setPerms([])} className="px-3 py-1.5 rounded-lg text-xs font-semibold bg-slate-100 text-slate-600 hover:bg-slate-200">مسح الكل</button>
              <button onClick={() => saveMut.mutate()} disabled={saveMut.isPending}
                className="px-4 py-1.5 rounded-lg text-xs font-bold text-white flex items-center gap-1.5 disabled:opacity-50" style={{ background: '#16a34a' }}>
                <Save size={12} /> حفظ
              </button>
            </div>
          </div>

          {/* Manager toggle */}
          <div className="flex items-center justify-between p-3 rounded-xl bg-amber-50 border border-amber-200 mb-4">
            <div><p className="font-semibold text-amber-800 text-sm">مدير — يستلم التوريد عند إغلاق الدرج</p></div>
            <button onClick={() => setIsManager(v => !v)}
              className={`w-11 h-6 rounded-full transition-all relative ${isManager ? 'bg-green-500' : 'bg-slate-300'}`}>
              <div className={`w-4 h-4 bg-white rounded-full absolute top-1 transition-all shadow ${isManager ? 'left-6' : 'left-1'}`} />
            </button>
          </div>

          <div className="grid grid-cols-3 gap-2 overflow-y-auto flex-1">
            {ALL_PAGES.map(page => {
              const enabled = perms.includes(page.id)
              return (
                <button key={page.id} onClick={() => setPerms(prev => prev.includes(page.id) ? prev.filter(p => p !== page.id) : [...prev, page.id])}
                  className={`p-3 rounded-xl border-2 text-right transition-all ${enabled ? 'border-blue-300 bg-blue-50' : 'border-slate-200 bg-white hover:border-slate-300'}`}>
                  <div className="flex items-center justify-between mb-1">
                    <span className="text-xl">{page.icon}</span>
                    <div className={`w-4 h-4 rounded border-2 flex items-center justify-center ${enabled ? 'border-blue-500 bg-blue-500' : 'border-slate-300'}`}>
                      {enabled && <svg width="8" height="6" viewBox="0 0 8 6" fill="none"><path d="M1 3L3 5L7 1" stroke="white" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg>}
                    </div>
                  </div>
                  <p className={`text-xs font-bold ${enabled ? 'text-blue-800' : 'text-slate-600'}`}>{page.label}</p>
                </button>
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
  const qc = useQueryClient()

  const { data: users, isLoading } = useQuery({ queryKey: ['users'], queryFn: usersApi.list })

  const createMut = useMutation({ mutationFn: usersApi.create, onSuccess: () => { toast.success('تمت الإضافة'); setShowAdd(false); qc.invalidateQueries({ queryKey: ['users'] }) }, onError: () => toast.error('فشل') })
  const updateMut = useMutation({ mutationFn: ({ id, data }: any) => usersApi.update(id, data), onSuccess: () => { toast.success('تم التحديث'); setEditUser(null); qc.invalidateQueries({ queryKey: ['users'] }) } })
  const resetMut = useMutation({ mutationFn: ({ id, password }: any) => api.post(`/users/${id}/reset-password`, { password }), onSuccess: () => toast.success('تم تغيير كلمة المرور') })
  const deleteMut = useMutation({ mutationFn: usersApi.delete, onSuccess: () => { toast.success('تم التعطيل'); qc.invalidateQueries({ queryKey: ['users'] }) } })

  const roleLabel: Record<string, string> = { admin: 'مدير عام', cashier: 'كاشير', manager: 'مشرف', storekeeper: 'أمين مخازن', accountant: 'محاسب' }
  const roleBadge: Record<string, string> = { admin: 'badge-red', cashier: 'badge-blue', manager: 'badge-yellow', storekeeper: 'badge-green', accountant: 'badge-blue' }

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">المستخدمون والصلاحيات</h1>
        {tab === 'users' && (
          <button onClick={() => setShowAdd(true)} className="px-4 py-2.5 rounded-xl text-sm font-bold text-white flex items-center gap-2" style={{ background: '#1e3a5f' }}>
            <Plus size={15} /> إضافة مستخدم
          </button>
        )}
      </div>

      <div className="flex gap-0 mb-6 border-b border-slate-200">
        {[{ id: 'users', label: '👥 المستخدمون' }, { id: 'permissions', label: '🔐 الصلاحيات' }].map(t => (
          <button key={t.id} onClick={() => setTab(t.id as any)}
            className={`px-5 py-3 text-sm font-semibold border-b-2 transition-all -mb-px whitespace-nowrap ${tab === t.id ? 'border-blue-600 text-blue-700' : 'border-transparent text-slate-500 hover:text-slate-700'}`}>
            {t.label}
          </button>
        ))}
      </div>

      {tab === 'users' && (
        <DataTable
          columns={[
            { key: 'full_name', label: 'المستخدم', sortable: true, render: (u: any) => (
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-xl flex items-center justify-center text-white font-black text-sm flex-shrink-0" style={{ background: '#1e3a5f' }}>{u.full_name?.[0]}</div>
                <div><p className="font-bold text-slate-800">{u.full_name}</p><p className="text-xs text-slate-400">@{u.username}</p></div>
              </div>
            )},
            { key: 'role', label: 'الصلاحية', sortable: true, render: (u: any) => <span className={roleBadge[u.role] || 'badge-gray'}>{roleLabel[u.role] || u.role}</span> },
            { key: 'default_warehouse_name', label: 'الفرع', render: (u: any) => <span className="text-slate-500 text-sm">{u.default_warehouse_name || '—'}</span> },
            { key: 'is_manager', label: 'مدير', render: (u: any) => u.is_manager ? <span className="badge-green">مدير</span> : <span className="text-slate-300 text-sm">—</span> },
            { key: 'actions', label: '', render: (u: any) => (
              <div className="flex gap-1 justify-end">
                <button onClick={() => setEditUser(u)} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400" title="تعديل"><Edit2 size={14} /></button>
                <button onClick={() => { const pw = prompt('كلمة المرور الجديدة (4 أحرف على الأقل):'); if (pw?.trim() && pw.trim().length >= 4) resetMut.mutate({ id: u.id, password: pw.trim() }); else if (pw !== null) alert('كلمة المرور قصيرة جداً — 4 أحرف على الأقل') }} className="p-1.5 rounded-lg hover:bg-amber-50 text-slate-300 hover:text-amber-600" title="إعادة تعيين كلمة المرور"><KeyRound size={14} /></button>
                <button onClick={() => { if (confirm('تعطيل المستخدم؟')) deleteMut.mutate(u.id) }} className="p-1.5 rounded-lg hover:bg-red-50 text-slate-300 hover:text-red-500" title="تعطيل"><Trash2 size={14} /></button>
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
      <Modal open={!!editUser} onClose={() => setEditUser(null)} title="تعديل المستخدم">
        {editUser && <UserForm user={editUser} onSave={(d: any) => updateMut.mutate({ id: editUser.id, data: d })} onClose={() => setEditUser(null)} />}
      </Modal>
    </div>
  )
}
