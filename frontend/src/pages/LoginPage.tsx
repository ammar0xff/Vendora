import { fixUploadUrl } from '../utils/format'
import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { useAuthStore } from '../store/auth'
import { authApi, settingsApi } from '../api/endpoints'
import toast from 'react-hot-toast'
import { Lock, User, Store, Boxes, BarChart3, Eye, EyeOff, TrendingUp, PackageCheck, ShieldCheck } from 'lucide-react'

const FEATURES = [
  { icon: Store, label: 'نقطة البيع', desc: 'مبيعات سريعة وسلسة' },
  { icon: Boxes, label: 'المخزون', desc: 'تتبع كامل للأصناف' },
  { icon: BarChart3, label: 'التقارير', desc: 'تحليلات دقيقة' },
]

const STATS = [
  { icon: TrendingUp, value: '+٩٥٪', label: 'دقة المبيعات' },
  { icon: PackageCheck, value: '٢٤/٧', label: 'تتبع المخزون' },
  { icon: ShieldCheck, value: 'مشفّر', label: 'حماية كاملة' },
]

export default function LoginPage() {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
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
    <div className="min-h-screen flex bg-[var(--bg)]">
      {/* ── Brand panel (right in RTL) ── */}
      <div className="hidden lg:flex lg:w-[45%] xl:w-[42%] relative overflow-hidden bg-[var(--primary)]">
        {/* Decor layers */}
        <div className="absolute inset-0 opacity-[0.07]" style={{
          backgroundImage: 'radial-gradient(circle at 20% 20%, #fff 1px, transparent 1px), radial-gradient(circle at 80% 70%, #fff 1px, transparent 1px)',
          backgroundSize: '44px 44px'
        }} />
        <div className="absolute -top-24 -left-24 w-96 h-96 rounded-full bg-[var(--accent)]/20 blur-3xl" />
        <div className="absolute bottom-0 right-0 w-80 h-80 rounded-full bg-[var(--primary-strong)]/60 blur-3xl" />
        <div className="absolute top-1/3 right-14 w-px h-[340px] bg-gradient-to-b from-transparent via-white/20 to-transparent" />

        <div className="relative z-10 w-full flex flex-col justify-between px-14 py-12">
          <div className="flex items-center gap-3">
            {logoUrl ? (
              <img src={fixUploadUrl(logoUrl)} alt="logo" className="w-12 h-12 object-contain rounded-2xl bg-white/10 p-1.5 border border-white/15" />
            ) : (
              <div className="w-12 h-12 rounded-2xl overflow-hidden bg-[#2b1b03] border border-white/15">
                <img src="/favicon.svg" alt="logo" className="w-full h-full object-cover" />
              </div>
            )}
            <div>
              <p className="text-white font-black text-[15px] leading-tight">{companyName}</p>
              <p className="text-white/50 text-[11px] mt-0.5">منصة الإدارة الشاملة</p>
            </div>
          </div>

          <div className="max-w-md">
            <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/10 border border-white/15 text-[11px] font-bold text-[var(--accent)] mb-6">
              <span className="dot dot-yellow" />
              نظام متكامل لإدارة الأعمال
            </div>
            <h1 className="text-[34px] xl:text-[40px] font-black leading-[1.25] text-white mb-4">
              كل عملياتك التجارية
              <br />
              <span className="text-[var(--accent)]">في منصة واحدة</span>
            </h1>
            <p className="text-white/60 text-[15px] leading-relaxed">
              مبيعات، مخزون، موردون، موظفون، وحسابات — بنظام سريع وآمن يعمل على المتصفح والهاتف والكمبيوتر.
            </p>

            <div className="mt-10 grid grid-cols-3 gap-3">
              {FEATURES.map(({ icon: Icon, label, desc }) => (
                <div key={label} className="bg-white/[0.07] rounded-2xl p-4 border border-white/10 backdrop-blur-sm transition-colors hover:bg-white/[0.12] hover:border-white/20">
                  <div className="w-9 h-9 rounded-xl bg-[var(--accent)]/20 flex items-center justify-center mb-3">
                    <Icon size={18} className="text-[var(--accent)]" />
                  </div>
                  <p className="text-white/90 text-[13px] font-bold mb-0.5">{label}</p>
                  <p className="text-white/45 text-[11px]">{desc}</p>
                </div>
              ))}
            </div>
          </div>

          <div className="flex items-center gap-6">
            {STATS.map(({ icon: Icon, value, label }) => (
              <div key={label} className="flex items-center gap-2.5">
                <Icon size={16} className="text-[var(--accent)]" />
                <div className="leading-tight">
                  <p className="text-white font-black text-[13px] tabular-nums">{value}</p>
                  <p className="text-white/45 text-[10.5px]">{label}</p>
                </div>
              </div>
            ))}
            <div className="flex-1" />
            <p className="text-white/25 text-[11px]">Vendora v1.0</p>
          </div>
        </div>
      </div>

      {/* ── Login form ── */}
      <div className="flex-1 flex items-center justify-center p-6 sm:p-10">
        <div className="w-full max-w-sm">
          {/* Mobile brand */}
          <div className="flex flex-col items-center text-center mb-8 lg:hidden">
            <div className="w-16 h-16 rounded-2xl bg-[var(--primary-soft)] mb-3 flex items-center justify-center overflow-hidden">
              {logoUrl ? (
                <img src={fixUploadUrl(logoUrl)} alt="logo" className="w-10 h-10 object-contain rounded-xl" />
              ) : (
                <div className="w-10 h-10 rounded-xl overflow-hidden bg-[#2b1b03]">
                  <img src="/favicon.svg" alt="logo" className="w-full h-full object-cover" />
                </div>
              )}
            </div>
            <h1 className="text-xl font-black text-[var(--text)]">{companyName}</h1>
          </div>

          <div className="mb-8">
            <h2 className="text-2xl font-black text-[var(--text)] mb-1.5">مرحباً بك 👋</h2>
            <p className="text-[var(--muted)] text-sm">سجّل دخولك للوصول إلى لوحة التحكم</p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-5">
            <div>
              <label htmlFor="login-username" className="field-label">اسم المستخدم</label>
              <div className="relative">
                <User size={16} className="absolute right-3.5 top-1/2 -translate-y-1/2 text-[var(--muted)] pointer-events-none" />
                <input id="login-username" value={username} onChange={e => setUsername(e.target.value)}
                  className="input pr-10"
                  placeholder="أدخل اسم المستخدم" required autoFocus autoComplete="username" />
              </div>
            </div>
            <div>
              <label htmlFor="login-password" className="field-label">كلمة المرور</label>
              <div className="relative">
                <Lock size={16} className="absolute right-3.5 top-1/2 -translate-y-1/2 text-[var(--muted)] pointer-events-none" />
                <input id="login-password" type={showPassword ? 'text' : 'password'} value={password}
                  onChange={e => setPassword(e.target.value)}
                  className="input pr-10 pl-10"
                  placeholder="أدخل كلمة المرور" required autoComplete="current-password" />
                <button type="button" onClick={() => setShowPassword(s => !s)}
                  className="absolute left-2.5 top-1/2 -translate-y-1/2 p-1.5 rounded-lg text-[var(--muted)] hover:text-[var(--text)] transition-colors"
                  aria-label={showPassword ? 'إخفاء كلمة المرور' : 'إظهار كلمة المرور'}>
                  {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                </button>
              </div>
            </div>
            <button type="submit" disabled={loading}
              className="btn-primary w-full btn-lg mt-2">
              {loading ? 'جاري تسجيل الدخول...' : 'تسجيل الدخول'}
            </button>
          </form>

          <div className="mt-6 flex items-center gap-2.5 p-3.5 rounded-[var(--r-lg)] bg-[var(--gold-soft)] border border-[var(--gold-border)]">
            <ShieldCheck size={16} className="text-[var(--accent-strong)] flex-shrink-0" />
            <p className="text-[11px] text-[var(--text-soft)] leading-relaxed">
              بياناتك آمنة ومشفّرة. نسخة المبيعات التجريبية: <span className="font-black">ammar / changeme</span>
            </p>
          </div>

          <p className="text-center text-[11px] text-[var(--muted)] mt-8">© {new Date().getFullYear()} {companyName} — جميع الحقوق محفوظة</p>
        </div>
      </div>
    </div>
  )
}