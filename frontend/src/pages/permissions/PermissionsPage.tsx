import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { usersApi } from '../../api/endpoints'
import api from '../../api/client'
import { PageLoader } from '../../components/ui/Loaders'
import toast from 'react-hot-toast'
import { Shield, Save } from 'lucide-react'

const ALL_PAGES = [
  { id: 'pos',        label: 'نقطة البيع',       icon: '🛒', desc: 'البيع والدرج' },
  { id: 'sales',      label: 'المبيعات',          icon: '🧾', desc: 'سجل الفواتير' },
  { id: 'quotations', label: 'عروض الأسعار',      icon: '📋', desc: 'إنشاء وتأكيد العروض' },
  { id: 'inventory',  label: 'المخزون',           icon: '📦', desc: 'إدارة المنتجات' },
  { id: 'operations', label: 'العمليات',          icon: '🚚', desc: 'صرف واستلام' },
  { id: 'customers',  label: 'العملاء',           icon: '👤', desc: 'حسابات العملاء' },
  { id: 'reports',    label: 'التقارير',          icon: '📊', desc: 'التقارير والإحصائيات' },
  { id: 'archive',    label: 'الأرشيف',           icon: '📁', desc: 'المستندات المحفوظة' },
  { id: 'payroll',    label: 'الرواتب',           icon: '💰', desc: 'إدارة الموظفين والرواتب' },
  { id: 'users',      label: 'المستخدمون',        icon: '👥', desc: 'إدارة الحسابات' },
  { id: 'settings',   label: 'الإعدادات',         icon: '⚙️', desc: 'إعدادات النظام' },
  { id: 'admin',      label: 'الإدارة الشاملة',   icon: '🏢', desc: 'تقارير كل الفروع' },
]

export default function PermissionsPage() {
  const [selectedUser, setSelectedUser] = useState<any>(null)
  const [perms, setPerms] = useState<string[]>([])
  const [isManager, setIsManager] = useState(false)
  const qc = useQueryClient()

  const { data: users, isLoading } = useQuery({ queryKey: ['users'], queryFn: usersApi.list })

  const { data: userPerms } = useQuery({
    queryKey: ['user-perms', selectedUser?.id],
    queryFn: () => api.get(`/permissions/${selectedUser.id}`).then(r => r.data),
    enabled: !!selectedUser,
    onSuccess: (d: any) => { setPerms(d.permissions || []); setIsManager(d.is_manager || false) },
  } as any)

  const saveMut = useMutation({
    mutationFn: () => api.put(`/permissions/${selectedUser.id}`, { permissions: perms, is_manager: isManager }),
    onSuccess: () => { toast.success('تم حفظ الصلاحيات'); qc.invalidateQueries({ queryKey: ['user-perms'] }) },
  })

  const toggle = (page: string) => {
    setPerms(prev => prev.includes(page) ? prev.filter(p => p !== page) : [...prev, page])
  }

  const selectAll = () => setPerms(ALL_PAGES.map(p => p.id))
  const clearAll = () => setPerms([])

  return (
    <div className="flex gap-5 h-[calc(100vh-3rem)]">
      {/* User list */}
      <div className="w-64 flex-shrink-0 flex flex-col">
        <div className="page-header mb-4">
          <h1 className="page-title flex items-center gap-2"><Shield size={22} /> الصلاحيات</h1>
        </div>
        {isLoading ? null : (
          <div className="space-y-2 flex-1 overflow-y-auto">
            {users?.map((u: any) => (
              <button key={u.id} onClick={() => setSelectedUser(u)}
                className={`w-full text-right p-3 rounded-xl border transition-all ${selectedUser?.id === u.id ? 'border-blue-300 bg-blue-50' : 'bg-white border-slate-100 hover:border-slate-200'}`}>
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-xl flex items-center justify-center text-white font-bold text-sm" style={{ background: '#1e3a5f' }}>
                    {u.full_name?.[0]}
                  </div>
                  <div>
                    <p className="font-semibold text-slate-800 text-sm">{u.full_name}</p>
                    <p className="text-xs text-slate-400">@{u.username}</p>
                  </div>
                </div>
              </button>
            ))}
          </div>
        )}
      </div>

      {/* Permissions panel */}
      <div className="flex-1 flex flex-col min-w-0">
        {!selectedUser ? (
          <div className="flex-1 flex items-center justify-center text-slate-400">
            <div className="text-center"><p className="text-4xl mb-3">🔐</p><p>اختر موظفاً لتعديل صلاحياته</p></div>
          </div>
        ) : (
          <>
            <div className="flex items-center justify-between mb-5">
              <div>
                <h2 className="text-xl font-black text-slate-800">{selectedUser.full_name}</h2>
                <p className="text-slate-500 text-sm">@{selectedUser.username}</p>
              </div>
              <div className="flex gap-2">
                <button onClick={selectAll} className="px-3 py-1.5 rounded-lg text-xs font-semibold bg-slate-100 text-slate-600 hover:bg-slate-200">تحديد الكل</button>
                <button onClick={clearAll} className="px-3 py-1.5 rounded-lg text-xs font-semibold bg-slate-100 text-slate-600 hover:bg-slate-200">مسح الكل</button>
                <button onClick={() => saveMut.mutate()} disabled={saveMut.isPending}
                  className="px-5 py-2 rounded-xl text-sm font-bold text-white flex items-center gap-2 disabled:opacity-50"
                  style={{ background: '#16a34a' }}>
                  <Save size={14} /> حفظ الصلاحيات
                </button>
              </div>
            </div>

            {/* Manager toggle */}
            <div className="card mb-4 p-4 flex items-center justify-between">
              <div>
                <p className="font-bold text-slate-800">مدير / يملك صلاحية استلام التوريد</p>
                <p className="text-slate-500 text-xs mt-0.5">يمكنه استلام توريد الدرج عند إغلاق الوردية</p>
              </div>
              <button onClick={() => setIsManager(v => !v)}
                className={`w-12 h-6 rounded-full transition-all relative ${isManager ? 'bg-green-500' : 'bg-slate-300'}`}>
                <div className={`w-5 h-5 bg-white rounded-full absolute top-0.5 transition-all shadow ${isManager ? 'left-6' : 'left-0.5'}`} />
              </button>
            </div>

            {/* Pages grid */}
            <div className="grid grid-cols-2 lg:grid-cols-3 gap-3 flex-1 overflow-y-auto">
              {ALL_PAGES.map(page => {
                const enabled = perms.includes(page.id)
                return (
                  <button key={page.id} onClick={() => toggle(page.id)}
                    className={`p-4 rounded-2xl border-2 text-right transition-all ${enabled ? 'border-blue-300 bg-blue-50' : 'border-slate-200 bg-white hover:border-slate-300'}`}>
                    <div className="flex items-start justify-between mb-2">
                      <span className="text-2xl">{page.icon}</span>
                      <div className={`w-5 h-5 rounded-md border-2 flex items-center justify-center transition-all ${enabled ? 'border-blue-500 bg-blue-500' : 'border-slate-300'}`}>
                        {enabled && <svg width="10" height="8" viewBox="0 0 10 8" fill="none"><path d="M1 4L3.5 6.5L9 1" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>}
                      </div>
                    </div>
                    <p className={`font-bold text-sm ${enabled ? 'text-blue-800' : 'text-slate-700'}`}>{page.label}</p>
                    <p className="text-xs text-slate-400 mt-0.5">{page.desc}</p>
                  </button>
                )
              })}
            </div>
          </>
        )}
      </div>
    </div>
  )
}
