import { fixUploadUrl } from '../utils/format'
import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { useAuthStore } from '../store/auth'
import { authApi, settingsApi } from '../api/endpoints'
import toast from 'react-hot-toast'
import { Lock, User, Store, Boxes, BarChart3 } from 'lucide-react'

const FEATURES = [
  { icon: Store, label: 'نقطة البيع', desc: 'مبيعات سريعة وسلسة' },
  { icon: Boxes, label: 'المخزون', desc: 'تتبع كامل للأصناف' },
  { icon: BarChart3, label: 'التقارير', desc: 'تحليلات دقيقة' },
]

export default function LoginPage() {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const { login } = useAuthStore()
  const navigate = useNavigate()

  const { data: settings } = useQuery({ queryKey: ['settings'], queryFn: settingsApi.get, retry: false, staleTime: 60_000 })
  const companyName = settings?.store_name || 'Vendora'
  const logoUrl = settings?.logo_url || ''

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    try {
      const data = await authApi.login(username, password)
      login(data.access_token, { id: data.user_id, username: data.username, full_name: data.full_name || data.username, role: data.role })
      try {
        const me = await authApi.me()
        login(data.access_token, { ...me, permissions: me.permissions || [] })
      } catch (e) { console.warn('Failed to fetch detailed profile', e) }
      navigate('/')
    } catch {
      toast.error('اسم المستخدم أو كلمة المرور غير صحيحة')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex bg-[#f4f6fa]">
      {/* Brand panel */}
      <div className="hidden lg:flex flex-1 flex-col justify-between items-center p-12 relative overflow-hidden bg-[var(--primary)]">
        <div className="absolute inset-0 opacity-[0.08]" style={{
          backgroundImage: 'radial-gradient(circle at 20% 20%, #fff 1px, transparent 1px), radial-gradient(circle at 80% 70%, #fff 1px, transparent 1px)',
          backgroundSize: '48px 48px'
        }} />
        <div className="relative z-10 flex flex-col items-center text-center max-w-md">
          <div className="mb-8">
            {logoUrl ? (
              <img src={fixUploadUrl(logoUrl)} alt="logo" className="w-28 h-28 object-contain mx-auto rounded-2xl drop-shadow-2xl" />
            ) : (
              <div className="w-28 h-28 rounded-3xl flex items-center justify-center mx-auto shadow-2xl overflow-hidden bg-[#2b1b03]">
                <img src="/favicon.svg" alt="logo" className="w-full h-full object-cover" />
              </div>
            )}
          </div>
          <h1 className="text-4xl font-black mb-4 leading-tight text-white">{companyName}</h1>
          <p className="text-white/60 text-base leading-relaxed">منصة متكاملة لإدارة المبيعات والمخزون والموظفين</p>
          <div className="mt-12 grid grid-cols-3 gap-3 w-full">
            {FEATURES.map(({ icon: Icon, label, desc }) => (
              <div key={label} className="bg-white/10 rounded-2xl p-4 backdrop-blur-sm border border-white/10">
                <Icon size={22} className="mb-2 text-[var(--accent)]" />
                <p className="text-white/90 text-sm font-bold mb-0.5">{label}</p>
                <p className="text-white/50 text-[11px]">{desc}</p>
              </div>
            ))}
          </div>
        </div>
        <p className="relative z-10 text-white/30 text-xs">Vendora v1.0 · إدارة شاملة</p>
      </div>

      {/* Login form */}
      <div className="w-full lg:max-w-[480px] flex items-center justify-center p-6 sm:p-10 bg-white">
        <div className="w-full max-w-sm">
          <div className="flex items-center justify-center w-14 h-14 rounded-2xl bg-[var(--primary-soft)] mb-6 lg:hidden">
            {logoUrl ? (
              <img src={fixUploadUrl(logoUrl)} alt="logo" className="w-9 h-9 object-contain rounded-xl" />
            ) : (
              <div className="w-9 h-9 rounded-xl overflow-hidden bg-[#2b1b03]">
                <img src="/favicon.svg" alt="logo" className="w-full h-full object-cover" />
              </div>
            )}
          </div>

          <div className="mb-8">
            <h2 className="text-2xl font-black text-[var(--text)] mb-1.5">مرحباً بك</h2>
            <p className="text-[var(--muted)] text-sm">سجّل دخولك للمتابعة</p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-5">
            <div>
              <label className="field-label">اسم المستخدم</label>
              <div className="relative">
                <User size={16} className="absolute right-3 top-1/2 -translate-y-1/2 text-[var(--muted)]" />
                <input value={username} onChange={e => setUsername(e.target.value)}
                  className="input pr-10"
                  placeholder="أدخل اسم المستخدم" required autoFocus />
              </div>
            </div>
            <div>
              <label className="field-label">كلمة المرور</label>
              <div className="relative">
                <Lock size={16} className="absolute right-3 top-1/2 -translate-y-1/2 text-[var(--muted)]" />
                <input type="password" value={password} onChange={e => setPassword(e.target.value)}
                  className="input pr-10"
                  placeholder="أدخل كلمة المرور" required />
              </div>
            </div>
            <button type="submit" disabled={loading}
              className="btn-primary w-full btn-lg mt-2">
              {loading ? 'جاري تسجيل الدخول...' : 'تسجيل الدخول'}
            </button>
          </form>
          <p className="text-center text-[11px] text-[var(--muted)] mt-8">© {new Date().getFullYear()} {companyName} — جميع الحقوق محفوظة</p>
        </div>
      </div>
    </div>
  )
}