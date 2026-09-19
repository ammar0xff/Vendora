import { useState } from 'react'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import toast from 'react-hot-toast'
import { Save, RotateCcw, Check } from 'lucide-react'
import { settingsApi } from '../../api/endpoints'
import { writeThemeDraft } from '../../ThemeManager'
import { DEFAULT_THEME, FONT_OPTIONS, normalizeHex, resolveTheme, contrastRatio, applyThemeVars, buildCacheCode, cacheTheme } from '../../utils/theme'

const COLOR_FIELDS: { key: 'theme_primary' | 'theme_accent' | 'theme_bg' | 'theme_ink'; label: string }[] = [
  { key: 'theme_primary', label: 'اللون الأساسي — شريط التنقل والأزرار' },
  { key: 'theme_accent', label: 'اللون المميز — الأسعار والشارات' },
  { key: 'theme_bg', label: 'لون خلفية المتجر' },
  { key: 'theme_ink', label: 'لون النصوص (يفرغ للتلقائي)' },
]

export default function AppearanceTab({ settings }: { settings: any }) {
  const qc = useQueryClient()
  const [form, setForm] = useState<Record<string, any>>(() => {
    const s = settings || {}
    return {
      theme_primary: s.theme_primary || DEFAULT_THEME.primary,
      theme_accent: s.theme_accent || DEFAULT_THEME.accent,
      theme_bg: s.theme_bg || DEFAULT_THEME.bg,
      theme_ink: s.theme_ink || '',
      font_heading: s.font_heading || DEFAULT_THEME.fontHeading,
      font_body: s.font_body || DEFAULT_THEME.fontBody,
    }
  })

  const applyDraft = (next: Record<string, any>) => {
    writeThemeDraft({
      theme_primary: next.theme_primary,
      theme_accent: next.theme_accent,
      theme_bg: next.theme_bg,
      theme_ink: next.theme_ink,
      font_heading: next.font_heading,
      font_body: next.font_body,
    })
  }

  /** Apply immediately on edit (the iframe/preview picks the draft up via storage). */
  const pushTheme = (next: Record<string, any>) => {
    const t = resolveTheme({
      theme_primary: next.theme_primary,
      theme_accent: next.theme_accent,
      theme_bg: next.theme_bg,
      theme_ink: next.theme_ink,
      font_heading: next.font_heading,
      font_body: next.font_body,
    })
    applyThemeVars(t.vars)
    cacheTheme(buildCacheCode(t.vars))
  }

  const update = (key: string, value: any) => {
    const next = { ...form, [key]: value }
    setForm(next)
    applyDraft(next)
    pushTheme(next)
  }

  const saveMut = useMutation({
    mutationFn: () => {
      const payload: Record<string, string> = {
        theme_primary: normalizeHex(form.theme_primary, DEFAULT_THEME.primary),
        theme_accent: normalizeHex(form.theme_accent, DEFAULT_THEME.accent),
        theme_bg: normalizeHex(form.theme_bg, DEFAULT_THEME.bg),
        font_heading: form.font_heading,
        font_body: form.font_body,
      }
      if (form.theme_ink) payload.theme_ink = normalizeHex(form.theme_ink, '')
      return settingsApi.update(payload)
    },
    onSuccess: () => {
      writeThemeDraft(null)
      qc.invalidateQueries({ queryKey: ['settings'] })
      toast.success('تم حفظ الهوية وتطبيقها على التطبيق كاملاً')
    },
    onError: () => toast.error('فشل الحفظ'),
  })

  const resetDefaults = () => {
    const next = {
      ...form,
      theme_primary: DEFAULT_THEME.primary,
      theme_accent: DEFAULT_THEME.accent,
      theme_bg: DEFAULT_THEME.bg,
      theme_ink: '',
      font_heading: DEFAULT_THEME.fontHeading,
      font_body: DEFAULT_THEME.fontBody,
    }
    setForm(next)
    applyDraft(next)
    pushTheme(next)
    toast('تمت استعادة الألوان الافتراضية — اضغط "حفظ الهوية" للتطبيق', { icon: '🎨' })
  }

  const theme = resolveTheme({
    theme_primary: form.theme_primary,
    theme_accent: form.theme_accent,
    theme_bg: form.theme_bg,
    theme_ink: form.theme_ink,
    font_heading: form.font_heading,
    font_body: form.font_body,
  })
  const primaryAA = contrastRatio(theme.primary, theme.vars['--primary-contrast']) >= 4.5

  return (
    <div className="grid grid-cols-1 xl:grid-cols-5 gap-6">
      {/* Controls */}
      <div className="card xl:col-span-2">
        <div className="flex items-center justify-between mb-5">
          <h3 className="font-bold text-slate-700">الهوية البصرية — الألوان والخطوط</h3>
          <button onClick={resetDefaults} className="flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-lg bg-slate-100 text-slate-500 hover:bg-slate-200">
            <RotateCcw size={13} /> استعادة الافتراضي
          </button>
        </div>

        <div className="space-y-4">
          {COLOR_FIELDS.map(({ key, label }) => (
            <div key={key} className="flex items-center gap-3">
              <input
                type="color"
                value={normalizeHex(form[key] || '', key === 'theme_ink' ? '#0f172a' : '')}
                onChange={(e) => update(key, e.target.value)}
                className="w-10 h-10 rounded-lg border border-slate-200 bg-white cursor-pointer shrink-0"
              />
              <div className="flex-1">
                <label className="block text-xs font-medium text-slate-600 mb-1">{label}</label>
                <input
                  className="input font-mono text-sm"
                  dir="ltr"
                  value={form[key] || ''}
                  onChange={(e) => update(key, e.target.value)}
                  placeholder={key === 'theme_ink' ? 'تلقائي' : '#rrggbb'}
                />
              </div>
            </div>
          ))}

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-medium text-slate-600 mb-1">خط العناوين</label>
              <select className="input text-sm" value={form.font_heading} onChange={(e) => update('font_heading', e.target.value)}>
                {FONT_OPTIONS.map((f) => (
                  <option key={f.id} value={f.id}>{f.label}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-xs font-medium text-slate-600 mb-1">خط النصوص</label>
              <select className="input text-sm" value={form.font_body} onChange={(e) => update('font_body', e.target.value)}>
                {FONT_OPTIONS.map((f) => (
                  <option key={f.id} value={f.id}>{f.label}</option>
                ))}
              </select>
            </div>
          </div>

          <button
            onClick={() => saveMut.mutate()}
            disabled={saveMut.isPending}
            className="w-full flex items-center justify-center gap-2 px-5 py-2.5 rounded-xl text-sm font-bold text-white"
            style={{ background: 'var(--primary)' }}
          >
            <Save size={16} /> {saveMut.isPending ? 'جاري الحفظ...' : 'حفظ الهوية وتطبيقها'}
          </button>
        </div>
      </div>

      {/* Live preview */}
      <div className="xl:col-span-3 space-y-4">
        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-bold text-slate-700">معاينة حية</h3>
            <span className="text-[11px] text-slate-400">تُعرض التغييرات فوراً على التطبيق كاملاً قبل الحفظ</span>
          </div>

          <div
            className="rounded-2xl overflow-hidden border"
            style={{ background: theme.vars['--bg'], borderColor: theme.vars['--border'], fontFamily: theme.body }}
          >
            {/* mini navbar */}
            <div className="flex items-center justify-between px-5 py-3" style={{ background: theme.primary }}>
              <div className="flex items-center gap-2">
                <span className="w-7 h-7 rounded-lg flex items-center justify-center text-xs font-black" style={{ background: 'rgba(255,255,255,0.18)', color: '#ffffff' }}>V</span>
                <span className="text-sm font-bold text-white">{settings?.store_name || 'متجرك'}</span>
              </div>
              <div className="flex items-center gap-3 text-xs" style={{ color: theme.vars['--primary-contrast'] }}>
                <span className="opacity-90">الرئيسية</span>
                <span className="opacity-90">المتجر</span>
                <span className="px-2.5 py-1 rounded-lg font-bold" style={{ background: '#ffffff', color: theme.primary }}>دخول</span>
              </div>
            </div>

            {/* hero-ish strip */}
            <div className="px-5 py-5">
              <p className="text-xl font-black mb-1" style={{ color: theme.vars['--text'], fontFamily: theme.heading }}>
                صياغة جديدة لمتجرك
              </p>
              <p className="text-xs mb-4" style={{ color: theme.vars['--muted'] }}>الألوان والخطوط تُطبق على الواجهة ولوحة التحكم معاً.</p>
              <div className="flex flex-wrap items-center gap-2 mb-4">
                <button className="px-4 py-2 rounded-xl text-xs font-bold text-white" style={{ background: theme.primary }}>
                  تسوّق الآن
                </button>
                <span className="px-3 py-2 rounded-xl text-xs font-black" style={{ background: theme.vars['--accent-soft'], color: theme.vars['--accent-strong'], border: `1px solid ${theme.vars['--accent-border']}` }}>
                  250 ج.م
                </span>
              </div>
              <div
                className="rounded-xl border p-4 text-sm font-semibold"
                style={{ background: theme.vars['--surface'], borderColor: theme.vars['--border'], color: theme.vars['--text'] }}
              >
                بطاقة منتج — خامة عالية الجودة
              </div>
            </div>
          </div>
        </div>

        {/* swatches */}
        <div className="card">
          <div className="flex flex-wrap gap-3 items-end">
            {[
              { name: 'أساسي', color: theme.primary, fg: theme.vars['--primary-contrast'] },
              { name: 'أساسي غامق', color: theme.vars['--primary-strong'], fg: '#ffffff' },
              { name: 'أساسي فاتح', color: theme.vars['--primary-soft'], fg: theme.primary },
              { name: 'مميز', color: theme.accent, fg: theme.vars['--accent-contrast'] },
              { name: 'مميز فاتح', color: theme.vars['--accent-soft'], fg: theme.vars['--accent-strong'] },
              { name: 'خلفية', color: theme.bg, fg: theme.vars['--text'] },
              { name: 'سطح', color: theme.vars['--surface'], fg: theme.vars['--text'] },
            ].map((sw) => (
              <div key={sw.name} className="flex flex-col items-center gap-1.5">
                <div
                  className="w-16 h-14 rounded-xl flex items-end p-1.5 text-[10px] font-bold border"
                  style={{ background: sw.color, color: sw.fg, borderColor: theme.vars['--border'] }}
                >
                  {sw.name}
                </div>
                {sw.color}
              </div>
            ))}
            <div className="flex flex-col items-center gap-1.5">
              <div className="w-16 h-14 rounded-xl flex items-center justify-center border" style={{ borderColor: theme.accent, background: 'transparent' }}>
                <span className="flex items-center gap-1 text-[10px] font-black" style={{ color: primaryAA ? '#16a34a' : '#dc2626' }}>
                  <Check size={11} /> {primaryAA ? 'AA' : 'ضعيف'}
                </span>
              </div>
              تباين النص
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}