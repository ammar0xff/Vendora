import { useState } from 'react'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import toast from 'react-hot-toast'
import { Reorder } from 'framer-motion'
import { Save, RotateCcw, Check, ExternalLink, GripVertical, Eye, EyeOff, X, Plus } from 'lucide-react'
import { settingsApi } from '../../api/endpoints'
import { writeThemeDraft } from '../../utils/storefrontDraft'
import { DEFAULT_THEME, FONT_OPTIONS, normalizeHex, resolveTheme, contrastRatio, applyThemeVars, buildCacheCode, cacheTheme } from '../../utils/theme'
import { THEME_PRESETS, type ThemePreset } from '../../utils/themes'
import { TEMPLATES, type Tone } from '../../pages/storefront/templates'
import TemplateThumb from '../../pages/storefront/templates/TemplateThumb'
import { SECTION_META, SECTION_ORDER, parseSections, defaultSectionsFor } from '../../pages/storefront/templates/sections'
import type { SectionConfig, SectionId } from '../../pages/storefront/templates/sections'

const COLOR_FIELDS: { key: 'theme_primary' | 'theme_accent' | 'theme_bg' | 'theme_ink'; label: string }[] = [
  { key: 'theme_primary', label: 'اللون الأساسي — شريط التنقل والأزرار' },
  { key: 'theme_accent', label: 'اللون المميز — الأسعار والشارات' },
  { key: 'theme_bg', label: 'لون خلفية المتجر' },
  { key: 'theme_ink', label: 'لون النصوص (يفرغ للتلقائي)' },
]

export default function AppearanceTab({ settings }: { settings: any }) {
  const qc = useQueryClient()
  const [previewKey, setPreviewKey] = useState(0)
  const [form, setForm] = useState<Record<string, any>>(() => {
    const s = settings || {}
    return {
      storefront_template: s.storefront_template || 'classic',
      storefront_sections: parseSections(s.storefront_sections) ?? defaultSectionsFor(s.storefront_template || 'classic'),
      storefront_hero_title: s.storefront_hero_title || '',
      storefront_hero_subtitle: s.storefront_hero_subtitle || '',
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
      storefront_template: next.storefront_template,
      storefront_sections: next.storefront_sections,
      storefront_hero_title: next.storefront_hero_title,
      storefront_hero_subtitle: next.storefront_hero_subtitle,
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

  const setThemeForm = (patch: Record<string, any>) => {
    const next = { ...form, ...patch }
    setForm(next)
    applyDraft(next)
    pushTheme(next)
    setPreviewKey((k) => k + 1)
  }

  const update = (key: string, value: any) => setThemeForm({ [key]: value })

  const applyPreset = (p: ThemePreset) =>
    setThemeForm({
      theme_primary: p.primary,
      theme_accent: p.accent,
      theme_bg: p.bg,
      theme_ink: '',
    })

  const isPresetActive = (p: ThemePreset) =>
    normalizeHex(form.theme_primary, '') === p.primary &&
    normalizeHex(form.theme_accent, '') === p.accent &&
    normalizeHex(form.theme_bg, '') === p.bg &&
    !form.theme_ink

  const sections = (form.storefront_sections as SectionConfig[]) || []
  const updateSection = (cfg: SectionConfig, next: SectionConfig) => update('storefront_sections', sections.map((x) => (x.id === cfg.id ? next : x)))
  const addSection = (id: SectionId) => update('storefront_sections', [...sections, { id }])
  const removeSection = (id: SectionId) => update('storefront_sections', sections.filter((x) => x.id !== id))
  const available = SECTION_ORDER.filter((id) => !sections.some((x) => x.id === id))

  const saveMut = useMutation({
    mutationFn: () => {
      const payload: Record<string, unknown> = {
        storefront_template: form.storefront_template || 'classic',
        storefront_sections: form.storefront_sections,
        storefront_hero_title: form.storefront_hero_title || '',
        storefront_hero_subtitle: form.storefront_hero_subtitle || '',
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
      storefront_template: 'classic',
      storefront_sections: defaultSectionsFor('classic'),
      storefront_hero_title: '',
      storefront_hero_subtitle: '',
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
    setPreviewKey((k) => k + 1)
    toast('تمت استعادة الافتراضي — اضغط "حفظ الهوية" للتطبيق', { icon: '🎨' })
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
          <h3 className="font-bold text-slate-700">ستايل متجرك</h3>
          <button onClick={resetDefaults} className="flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-lg bg-slate-100 text-slate-500 hover:bg-slate-200">
            <RotateCcw size={13} /> استعادة الافتراضي
          </button>
        </div>

        {/* Template picker */}
        <div className="mb-6">
          <label className="block text-xs font-medium text-slate-600 mb-2">قالب الواجهة الرئيسية</label>
          <div className="grid grid-cols-3 gap-2">
            {TEMPLATES.map((t) => (
              <button
                key={t.id}
                onClick={() => update('storefront_template', t.id)}
                className={`rounded-xl border-2 p-1.5 text-center transition-colors ${form.storefront_template === t.id ? 'border-[var(--primary)] ring-2 ring-theme-primary/30' : 'border-slate-200 hover:border-slate-300'}`}
                title={t.description}
              >
                <TemplateThumb tone={t.id as Tone} />
                <span className={`block text-xs font-bold mt-1.5 ${form.storefront_template === t.id ? 'text-[var(--primary)]' : 'text-slate-600'}`}>{t.name}</span>
              </button>
            ))}
          </div>
        </div>

        {/* Section builder */}
        <div className="mb-6">
          <label className="block text-xs font-medium text-slate-600 mb-2">مقاطع الصفحة الرئيسية — اسحب لإعادة الترتيب</label>
          <Reorder.Group axis="y" values={sections} onReorder={(v) => update('storefront_sections', v)} className="space-y-1.5">
            {sections.map((s) => (
              <Reorder.Item
                key={s.id}
                value={s}
                className="flex items-center gap-2 rounded-xl border px-2.5 py-2 bg-white"
                style={{ borderColor: 'var(--border)' }}
              >
                <GripVertical size={16} className="text-slate-300 cursor-grab shrink-0" />
                <span className="text-sm font-bold flex-1 text-slate-700">{SECTION_META[s.id].name}</span>
                {(s.id === 'categories' || s.id === 'featured') && (
                  <input
                    className="input text-xs w-32 text-right"
                    placeholder="عنوان"
                    value={s.heading || ''}
                    onChange={(e) => updateSection(s, { ...s, heading: e.target.value })}
                  />
                )}
                <button
                  onClick={() => updateSection(s, { ...s, enabled: s.enabled === false ? undefined : false })}
                  className="w-8 h-8 rounded-lg flex items-center justify-center hover:bg-slate-100 text-slate-500"
                  title={s.enabled === false ? 'إظهار' : 'إخفاء'}
                >
                  {s.enabled === false ? <EyeOff size={15} /> : <Eye size={15} />}
                </button>
                <button
                  onClick={() => removeSection(s.id)}
                  className="w-8 h-8 rounded-lg flex items-center justify-center hover:bg-red-50 text-red-400"
                  title="إزالة"
                >
                  <X size={15} />
                </button>
              </Reorder.Item>
            ))}
          </Reorder.Group>
          {available.length > 0 && (
            <div className="mt-2 flex flex-wrap gap-1.5">
              {available.map((id) => (
                <button
                  key={id}
                  onClick={() => addSection(id)}
                  className="inline-flex items-center gap-1 text-xs font-semibold px-2.5 py-1.5 rounded-lg bg-slate-100 text-slate-600 hover:bg-slate-200"
                >
                  <Plus size={13} /> {SECTION_META[id].name}
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Hero copy */}
        <div className="grid grid-cols-1 gap-3 mb-6">
          <div>
            <label className="block text-xs font-medium text-slate-600 mb-1">سطر الهيرو الرئيسي (يفرغ للتلقائي)</label>
            <input className="input text-sm" value={form.storefront_hero_title} onChange={(e) => update('storefront_hero_title', e.target.value)} placeholder="كل لوازم السباكة ومواد البناء" />
          </div>
          <div>
            <label className="block text-xs font-medium text-slate-600 mb-1">النص التعريفي (يفرغ للتلقائي)</label>
            <textarea className="input text-sm" rows={2} value={form.storefront_hero_subtitle} onChange={(e) => update('storefront_hero_subtitle', e.target.value)} placeholder="أصناف حقيقية بأسعار حقيقية من نظامك — باركود موحّد، بيع جملة وتجزئة، وتوصيل خلال 24 ساعة." />
          </div>
        </div>

        <div className="border-t mb-5" style={{ borderColor: 'var(--border)' }} />

        <h3 className="font-bold text-slate-700 mb-5">الهوية البصرية — الألوان والخطوط</h3>

        <div className="mb-5">
          <label className="block text-xs font-medium text-slate-600 mb-1">ألوان جاهزة — 50 ثيمًا شهيرًا</label>
          <p className="text-[11px] text-slate-400 mb-2">اضغط أي ثيم لتطبيقه فورًا في المعاينة، ويمكنك تعديل كل لون يدويًا من الأسفل.</p>
          <div className="grid grid-cols-3 sm:grid-cols-4 gap-2 max-h-64 overflow-y-auto pl-0.5 pb-1">
            {THEME_PRESETS.map((p) => {
              const active = isPresetActive(p)
              return (
                <button
                  key={p.id}
                  onClick={() => applyPreset(p)}
                  title={p.nameEn}
                  className={`rounded-xl border-2 p-1.5 text-right transition-colors ${active ? 'border-[var(--primary)] ring-2 ring-theme-primary/30' : 'border-slate-200 hover:border-slate-300'}`}
                >
                  <div className="overflow-hidden rounded-lg border border-black/5">
                    <div className="h-4" style={{ background: p.bg }} />
                    <div className="flex h-4">
                      <div className="flex-1" style={{ background: p.primary }} />
                      <div className="flex-1" style={{ background: p.accent }} />
                    </div>
                  </div>
                  <span className={`block text-[11px] font-bold mt-1.5 truncate ${active ? 'text-[var(--primary)]' : 'text-slate-600'}`}>{p.name}</span>
                  <span className="block text-[10px] text-slate-400 truncate" dir="ltr">{p.nameEn}</span>
                </button>
              )
            })}
          </div>
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
            <h3 className="font-bold text-slate-700">معاينة الصفحة الرئيسية — بحجم المتجر الحقيقي</h3>
            <a href="/" target="_blank" rel="noreferrer" className="inline-flex items-center gap-1.5 text-xs font-bold text-[var(--primary)]">
              فتح في تبويب جديد <ExternalLink size={13} />
            </a>
          </div>
          <iframe
            key={previewKey}
            src="/"
            title="معاينة المتجر"
            sandbox="allow-scripts allow-same-origin"
            className="w-full h-[540px] rounded-2xl border bg-white"
            style={{ borderColor: 'var(--border)' }}
          />
          <p className="mt-2 text-[11px] text-slate-400">تُعرض التغييرات في القالب والألوان والخطوط فوراً هنا دون حفظ.</p>
        </div>

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