import { fixUploadUrl } from '../utils/format'
import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { useAuthStore } from '../store/auth'
import { authApi, settingsApi } from '../api/endpoints'
import toast from 'react-hot-toast'
import { Lock, User } from 'lucide-react'

export default function LoginPage() {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const { login } = useAuthStore()
  const navigate = useNavigate()

  const { data: settings } = useQuery({ queryKey: ['settings'], queryFn: settingsApi.get, retry: false, staleTime: 60_000 })
  const companyName = settings?.store_name || 'نظام إدارة الأعمال'
  const logoUrl = settings?.logo_url || ''

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    try {
      const data = await authApi.login(username, password)
      // Store token first so subsequent requests are authenticated
      login(data.access_token, { id: data.user_id, username: data.username, full_name: data.full_name || data.username, role: data.role })
      // Then fetch full profile
      try {
        const me = await authApi.me()
        login(data.access_token, { ...me, permissions: me.permissions || [] })
      } catch { /* use basic profile from login response */ }
      // Redirect based on role
      const roleHome: Record<string, string> = {
        cashier: '/pos', storekeeper: '/inventory', accountant: '/accounting'
      }
      navigate(roleHome[data.role] || '/')
    } catch {
      toast.error('اسم المستخدم أو كلمة المرور غير صحيحة')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex" style={{ background: 'linear-gradient(135deg, #1e3a5f 0%, #152d4a 60%, #0f1f33 100%)' }}>
      {/* Left panel */}
      <div className="hidden lg:flex flex-1 items-center justify-center p-12">
        <div className="text-center text-white max-w-md">
          {/* Logo */}
          <div className="mb-8">
            {logoUrl ? (
              <img src={fixUploadUrl(logoUrl)} alt="logo" className="w-32 h-32 object-contain mx-auto rounded-2xl" />
            ) : (
              <div className="w-28 h-28 rounded-3xl flex items-center justify-center mx-auto shadow-2xl text-5xl font-black text-white"
                style={{ background: 'var(--accent)' }}>
                {companyName[0]}
              </div>
            )}
          </div>
          <h1 className="text-4xl font-black mb-3 leading-tight">{companyName}</h1>
          <p className="text-white/60 text-lg leading-relaxed">منصة متكاملة لإدارة المبيعات والمخزون والموظفين</p>
          <div className="mt-10 grid grid-cols-3 gap-4">
            {[['🛒','نقطة البيع'],['📦','المخزون'],['📊','التقارير']].map(([icon, label]) => (
              <div key={label} className="bg-white/10 rounded-2xl p-4 backdrop-blur-sm">
                <div className="text-2xl mb-1">{icon}</div>
                <p className="text-white/80 text-xs font-medium">{label}</p>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Login form */}
      <div className="w-full lg:w-[440px] flex items-center justify-center p-8 bg-white/5 backdrop-blur-sm">
        <div className="w-full max-w-sm">
          {/* Mobile logo */}
          <div className="lg:hidden text-center mb-8">
            {logoUrl ? (
              <img src={fixUploadUrl(logoUrl)} alt="logo" className="w-20 h-20 object-contain mx-auto rounded-2xl mb-3" />
            ) : (
              <div className="w-16 h-16 rounded-2xl flex items-center justify-center mx-auto mb-3 text-3xl font-black text-white"
                style={{ background: 'var(--accent)' }}>
                {companyName[0]}
              </div>
            )}
            <p className="text-white font-bold">{companyName}</p>
          </div>

          <div className="mb-8">
            <h2 className="text-3xl font-black text-white mb-1">مرحباً بك</h2>
            <p className="text-white/50">سجّل دخولك للمتابعة</p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-5">
            <div>
              <label className="block text-white/70 text-sm font-medium mb-2">اسم المستخدم</label>
              <div className="relative">
                <User size={16} className="absolute right-3 top-1/2 -translate-y-1/2 text-white/40" />
                <input value={username} onChange={e => setUsername(e.target.value)}
                  className="w-full bg-white/10 border border-white/20 rounded-xl px-4 py-3 pr-10 text-white placeholder-white/30 outline-none focus:border-yellow-400 focus:ring-2 focus:ring-yellow-400/20 transition-all"
                  placeholder="أدخل اسم المستخدم" required autoFocus />
              </div>
            </div>
            <div>
              <label className="block text-white/70 text-sm font-medium mb-2">كلمة المرور</label>
              <div className="relative">
                <Lock size={16} className="absolute right-3 top-1/2 -translate-y-1/2 text-white/40" />
                <input type="password" value={password} onChange={e => setPassword(e.target.value)}
                  className="w-full bg-white/10 border border-white/20 rounded-xl px-4 py-3 pr-10 text-white placeholder-white/30 outline-none focus:border-yellow-400 focus:ring-2 focus:ring-yellow-400/20 transition-all"
                  placeholder="أدخل كلمة المرور" required />
              </div>
            </div>
            <button type="submit" disabled={loading}
              className="w-full py-3.5 rounded-xl font-bold text-base transition-all active:scale-95 disabled:opacity-60 mt-2"
              style={{ background: 'var(--accent)', color: 'var(--primary)' }}>
              {loading ? 'جاري تسجيل الدخول...' : 'تسجيل الدخول'}
            </button>
          </form>
        </div>
      </div>
    </div>
  )
}
