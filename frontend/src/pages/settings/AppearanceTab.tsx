import { useState, useRef } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import toast from 'react-hot-toast'
import { Reorder } from 'framer-motion'
import { Save, RotateCcw, Check, ExternalLink, GripVertical, Eye, EyeOff, X, Plus, UploadCloud, Trash2, LayoutTemplate } from 'lucide-react'
import { settingsApi } from '../../api/endpoints'
import { writeThemeDraft } from '../../utils/storefrontDraft'
import { DEFAULT_THEME, FONT_OPTIONS, normalizeHex, resolveTheme, contrastRatio, applyThemeVars, buildCacheCode, cacheTheme } from '../../utils/theme'
import { THEME_PRESETS, type ThemePreset } from '../../utils/themes'
import { TEMPLATES, type Tone } from '../../pages/storefront/templates'
import TemplateThumb from '../../pages/storefront/templates/TemplateThumb'
import { SECTION_META, SECTION_ORDER, parseSections, defaultSectionsFor } from '../../pages/storefront/templates/sections'
import type { SectionConfig, SectionId } from '../../pages/storefront/templates/sections'
import { Button } from '../../components/ui/button'
import { Input } from '../../components/ui/input'
import { Textarea } from '../../components/ui/textarea'
import { Select } from '../../components/ui/select'

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
      storefront_tagline: s.storefront_tagline || '',
      storefront_menu: Array.isArray(s.storefront_menu) ? s.storefront_menu : [],
      storefront_socials: Array.isArray(s.storefront_socials) ? s.storefront_socials : [],
      storefront_posts: Array.isArray(s.storefront_posts) ? s.storefront_posts : [],
      store_email: s.store_email || '',
      store_hours: s.store_hours || '',
      store_map_url: s.store_map_url || '',
      theme_primary: s.theme_primary || DEFAULT_THEME.primary,
      theme_accent: s.theme_accent || DEFAULT_THEME.accent,
      theme_bg: s.theme_bg || DEFAULT_THEME.bg,
      theme_ink: s.theme_ink || '',
      theme_mode: s.theme_mode || 'auto',
      font_heading: s.font_heading || DEFAULT_THEME.fontHeading,
      font_body: s.font_body || DEFAULT_THEME.fontBody,
    }
  })

  const { data: customTheme } = useQuery({
    queryKey: ['storefront-custom-theme'],
    queryFn: settingsApi.getTheme,
    retry: false,
    staleTime: 60_000,
  })

  const fileInputRef = useRef<HTMLInputElement>(null)

  const importThemeMut = useMutation({
    mutationFn: (file: File) => settingsApi.importTheme(file),
    onSuccess: (r) => {
      qc.invalidateQueries({ queryKey: ['settings'] })
      qc.invalidateQueries({ queryKey: ['storefront-custom-theme'] })
      if (r?.html) setThemeForm({ storefront_template: 'custom', customImportName: String(r.name || '') })
      toast.success(`تم استيراد القالب "${r?.name}" وتفعيله — احفظه ليظهر للمتسوقين`)
    },
    onError: (e: any) => toast.error(e?.response?.data?.detail || 'فشل استيراد القالب'),
  })

  const deleteThemeMut = useMutation({
    mutationFn: () => settingsApi.deleteTheme(),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['settings'] })
      qc.invalidateQueries({ queryKey: ['storefront-custom-theme'] })
      const next = { ...form, storefront_template: 'classic', customImportName: '' }
      setForm(next)
      applyDraft(next)
      setPreviewKey((k) => k + 1)
      toast.success('تم حذف القالب المستورد والعودة للقالب الكلاسيكي')
    },
    onError: () => toast.error('فشل حذف القالب المستورد'),
  })

  const onPickZip = (file: File | undefined | null) => {
    if (!file) return
    importThemeMut.mutate(file)
  }

  const applyDraft = (next: Record<string, any>) => {
    writeThemeDraft({
      storefront_template: next.storefront_template,
      storefront_sections: next.storefront_sections,
      storefront_hero_title: next.storefront_hero_title,
      storefront_hero_subtitle: next.storefront_hero_subtitle,
      storefront_tagline: next.storefront_tagline,
      storefront_menu: next.storefront_menu,
      storefront_socials: next.storefront_socials,
      storefront_posts: next.storefront_posts,
      store_email: next.store_email,
      store_hours: next.store_hours,
      store_map_url: next.store_map_url,
      theme_primary: next.theme_primary,
      theme_accent: next.theme_accent,
      theme_bg: next.theme_bg,
      theme_ink: next.theme_ink,
      theme_mode: next.theme_mode,
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
      theme_mode: next.theme_mode,
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
    normalizeHex(form.theme_primary, '') === normalizeHex(p.primary, '') &&
    normalizeHex(form.theme_accent, '') === normalizeHex(p.accent, '') &&
    normalizeHex(form.theme_bg, '') === normalizeHex(p.bg, '') &&
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
        storefront_tagline: form.storefront_tagline || '',
        storefront_menu: form.storefront_menu || [],
        storefront_socials: form.storefront_socials || [],
        storefront_posts: form.storefront_posts || [],
        store_email: form.store_email || '',
        store_hours: form.store_hours || '',
        store_map_url: form.store_map_url || '',
        theme_primary: normalizeHex(form.theme_primary, DEFAULT_THEME.primary),
        theme_accent: normalizeHex(form.theme_accent, DEFAULT_THEME.accent),
        theme_bg: normalizeHex(form.theme_bg, DEFAULT_THEME.bg),
        theme_mode: form.theme_mode || 'auto',
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
      storefront_tagline: '',
      storefront_menu: [],
      storefront_socials: [],
      storefront_posts: [],
      store_email: '',
      store_hours: '',
      store_map_url: '',
      theme_primary: DEFAULT_THEME.primary,
      theme_accent: DEFAULT_THEME.accent,
      theme_bg: DEFAULT_THEME.bg,
      theme_ink: '',
      theme_mode: 'auto',
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
    theme_mode: form.theme_mode,
    font_heading: form.font_heading,
    font_body: form.font_body,
  })
  const primaryAA = contrastRatio(theme.primary, theme.vars['--primary-contrast']) >= 4.5

  return (
    <div className="grid grid-cols-1 xl:grid-cols-5 gap-6">
      {/* Controls */}
      <div className="card xl:col-span-2">
        <div className="flex items-center justify-between mb-5">
          <h3 className="font-bold text-[var(--text)]">ستايل متجرك</h3>
          <Button variant="secondary" size="sm" onClick={resetDefaults} className="flex items-center gap-1.5 text-xs">
            <RotateCcw size={13} /> استعادة الافتراضي
          </Button>
        </div>

        {/* Template picker */}
        <div className="mb-6">
          <label className="block text-xs font-medium text-[var(--text-soft)] mb-2">قالب الواجهة الرئيسية</label>
          <div className="grid grid-cols-3 gap-2">
            {TEMPLATES.map((t) => (
              <Button
                variant="outline"
                key={t.id}
                onClick={() => update('storefront_template', t.id)}
                className={`rounded-xl border-2 p-1.5 text-center transition-colors h-auto ${form.storefront_template === t.id ? 'border-[var(--primary)] ring-2 ring-theme-primary/30' : 'border-[var(--border)] hover:border-[var(--border-strong)]'}`}
                title={t.description}
              >
                <TemplateThumb tone={t.id as Tone} />
                <span className={`block text-xs font-bold mt-1.5 ${form.storefront_template === t.id ? 'text-[var(--primary)]' : 'text-[var(--text-soft)]'}`}>{t.name}</span>
              </Button>
            ))}
            <Button
              variant="outline"
              onClick={() => update('storefront_template', 'custom')}
              className={`rounded-xl border-2 p-1.5 text-center transition-colors h-auto ${form.storefront_template === 'custom' ? 'border-[var(--primary)] ring-2 ring-theme-primary/30' : 'border-[var(--border)] hover:border-[var(--border-strong)]'}`}
              title="قالب مستورد — واجهة كاملة من ملف ZIP (WordPress أو موقع ثابت)"
            >
              <div className="rounded-lg border-b border-black/5 overflow-hidden bg-[linear-gradient(135deg,#1e293b_0%,#334155_55%,#475569_100%)] h-14 flex items-center justify-center">
                <LayoutTemplate size={18} className="text-white/80" />
              </div>
              <span className={`block text-xs font-bold mt-1.5 ${form.storefront_template === 'custom' ? 'text-[var(--primary)]' : 'text-[var(--text-soft)]'}`}>مستورد</span>
            </Button>
          </div>
        </div>

        {form.storefront_template === 'custom' && (
          <div className="mb-5 rounded-2xl border-2 border-dashed p-3 space-y-3" style={{ borderColor: 'var(--border)' }}>
            <div className="flex items-center justify-between gap-2">
              <label className="text-xs font-bold text-[var(--text)]">استيراد قالب من ملف ZIP — WordPress أو موقع ثابت</label>
              {customTheme?.imported && (
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => deleteThemeMut.mutate()}
                  className="text-[11px] text-red-500 hover:text-red-600 p-0 h-auto"
                >
                  <Trash2 size={12} /> حذف القالب المستورد
                </Button>
              )}
            </div>
            {customTheme?.imported && (
              <p className="text-[11px] text-[var(--muted)]">
                القالب الحالي: <span className="font-bold text-[var(--text)]">{customTheme.name}</span> — {Math.round((customTheme.size || 0) / 1024)} ك.ب في {customTheme.assets || 0} ملف
              </p>
            )}
            <div
              onClick={() => fileInputRef.current?.click()}
              className="flex flex-col items-center justify-center gap-1.5 rounded-xl bg-[var(--surface-2)] py-5 cursor-pointer hover:bg-[var(--surface-3)] transition-colors"
            >
              <UploadCloud size={22} className="text-[var(--muted)]" />
              <span className="text-xs font-bold text-[var(--text-soft)]">{importThemeMut.isPending ? 'جاري الاستيراد وتضمين الملفات...' : 'اختر ملف ZIP أو اسحبه هنا'}</span>
              <span className="text-[10px] text-[var(--muted)]">يحوّل الملف إلى صفحة واحدة مضمنة (حتى 30 م.ب، بدون PHP)</span>
            </div>
            <input ref={fileInputRef} type="file" accept=".zip,application/zip" className="hidden" aria-label="استيراد قالب ZIP" onChange={(e) => { onPickZip(e.target.files?.[0]); e.target.value = '' }} />
            <p className="text-[11px] text-[var(--muted)] leading-relaxed">
              أي نصوص في القالب بصيغة <code className="font-mono" dir="ltr">{'{{store_name}}'}</code>، <code className="font-mono" dir="ltr">{'{{products}}'}</code> تُستبدل ببيانات متجرك الحية تلقائياً.
              قوائم المنتجات والفئات والمقالات والقوائم والسوشيال تُربط عبر <code className="font-mono" dir="ltr">data-vendora-repeat</code> و <code className="font-mono" dir="ltr">data-vendora-mount</code>.
            </p>
          </div>
        )}

        {/* Section builder */}
        <div className="mb-6">
          <label className="block text-xs font-medium text-[var(--text-soft)] mb-2">مقاطع الصفحة الرئيسية — اسحب لإعادة الترتيب</label>
          <Reorder.Group axis="y" values={sections} onReorder={(v) => update('storefront_sections', v)} className="space-y-1.5">
            {sections.map((s) => (
              <Reorder.Item
                key={s.id}
                value={s}
                className="flex items-center gap-2 rounded-xl border px-2.5 py-2 bg-[var(--surface)]"
                style={{ borderColor: 'var(--border)' }}
              >
                <GripVertical size={16} className="text-[var(--faint)] cursor-grab shrink-0" />
                <span className="text-sm font-bold flex-1 text-[var(--text)]">{SECTION_META[s.id].name}</span>
                {(s.id === 'categories' || s.id === 'featured') && (
                  <Input
                    className="text-xs w-32 text-right"
                    placeholder="عنوان"
                    value={s.heading || ''}
                    onChange={(e) => updateSection(s, { ...s, heading: e.target.value })}
                  />
                )}
                <Button
                  variant="ghost"
                  size="icon"
                  onClick={() => updateSection(s, { ...s, enabled: s.enabled === false ? undefined : false })}
                  title={s.enabled === false ? 'إظهار' : 'إخفاء'}
                >
                  {s.enabled === false ? <EyeOff size={15} /> : <Eye size={15} />}
                </Button>
                <Button
                  variant="ghost"
                  size="icon"
                  onClick={() => removeSection(s.id)}
                  className="text-red-400 hover:text-red-500 hover:bg-red-50"
                  title="إزالة"
                >
                  <X size={15} />
                </Button>
              </Reorder.Item>
            ))}
          </Reorder.Group>
          {available.length > 0 && (
            <div className="mt-2 flex flex-wrap gap-1.5">
              {available.map((id) => (
                <Button
                  variant="secondary"
                  size="sm"
                  key={id}
                  onClick={() => addSection(id)}
                  className="text-xs"
                >
                  <Plus size={13} /> {SECTION_META[id].name}
                </Button>
              ))}
            </div>
          )}
        </div>

        {/* Hero copy */}
        <div className="grid grid-cols-1 gap-3 mb-6">
          <div>
            <label className="block text-xs font-medium text-[var(--text-soft)] mb-1">سطر الهيرو الرئيسي (يفرغ للتلقائي)</label>
 <Input className="text-sm" value={form.storefront_hero_title} onChange={(e) => update('storefront_hero_title', e.target.value)} placeholder="كل لوازم السباكة ومواد البناء"/>
          </div>
          <div>
            <label className="block text-xs font-medium text-[var(--text-soft)] mb-1">النص التعريفي (يفرغ للتلقائي)</label>
            <Textarea className="text-sm" rows={2} value={form.storefront_hero_subtitle} onChange={(e) => update('storefront_hero_subtitle', e.target.value)} placeholder="أصناف حقيقية بأسعار حقيقية من نظامك — باركود موحّد، بيع جملة وتجزئة، وتوصيل خلال 24 ساعة." />
          </div>
        </div>

        <div className="border-t mb-5" style={{ borderColor: 'var(--border)' }} />

        <h3 className="font-bold text-[var(--text)] mb-5">الهوية البصرية — الألوان والخطوط</h3>

        {/* Mode toggle */}
        <div className="mb-5">
          <label className="block text-xs font-medium text-[var(--text-soft)] mb-2">وضع العرض</label>
          <div className="grid grid-cols-3 gap-2">
            {([
              { id: 'auto', label: 'تلقائي', desc: 'حسب لون الخلفية' },
              { id: 'light', label: 'فاتح', desc: 'إجبار الوضع الفاتح' },
              { id: 'dark', label: 'داكن', desc: 'إجبار الوضع الداكن' },
            ] as { id: string; label: string; desc: string }[]).map((m) => (
              <Button
                key={m.id}
                variant={form.theme_mode === m.id ? 'default' : 'outline'}
                onClick={() => update('theme_mode', m.id)}
                className="rounded-xl h-auto flex-col items-center gap-0.5 py-2.5"
              >
                <span className="text-xs font-bold">{m.label}</span>
                <span className={`text-[10px] ${form.theme_mode === m.id ? 'opacity-90' : 'text-[var(--muted)]'}`}>{m.desc}</span>
              </Button>
            ))}
          </div>
        </div>

        <div className="mb-5">
          <label className="block text-xs font-medium text-[var(--text-soft)] mb-1">ألوان جاهزة — 50 ثيمًا شهيرًا</label>
          <p className="text-[11px] text-[var(--muted)] mb-2">اضغط أي ثيم لتطبيقه فورًا في المعاينة، ويمكنك تعديل كل لون يدويًا من الأسفل.</p>
          <div className="grid grid-cols-3 sm:grid-cols-4 gap-2 max-h-64 overflow-y-auto pl-0.5 pb-1">
            {THEME_PRESETS.map((p) => {
              const active = isPresetActive(p)
              return (
                <Button
                  variant="outline"
                  key={p.id}
                  onClick={() => applyPreset(p)}
                  title={p.nameEn}
                  className={`rounded-xl border-2 p-1.5 text-right transition-colors h-auto ${active ? 'border-[var(--primary)] ring-2 ring-theme-primary/30' : 'border-[var(--border)] hover:border-[var(--border-strong)]'}`}
                >
                  <div className="overflow-hidden rounded-lg border border-black/5">
                    <div className="h-4" style={{ background: p.bg }} />
                    <div className="flex h-4">
                      <div className="flex-1" style={{ background: p.primary }} />
                      <div className="flex-1" style={{ background: p.accent }} />
                    </div>
                  </div>
                  <span className={`block text-[11px] font-bold mt-1.5 truncate ${active ? 'text-[var(--primary)]' : 'text-[var(--text-soft)]'}`}>{p.name}</span>
                  <span className="block text-[10px] text-[var(--muted)] truncate" dir="ltr">{p.nameEn}</span>
                </Button>
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
                className="w-10 h-10 rounded-lg border border-[var(--border)] bg-[var(--surface)] cursor-pointer shrink-0"
              />
              <div className="flex-1">
                <label className="block text-xs font-medium text-[var(--text-soft)] mb-1">{label}</label>
                <Input
                  className="font-mono text-sm"
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
              <label className="block text-xs font-medium text-[var(--text-soft)] mb-1">خط العناوين</label>
              <Select className="text-sm" value={form.font_heading} onChange={(e) => update('font_heading', e.target.value)}>
                {FONT_OPTIONS.map((f) => (
                  <option key={f.id} value={f.id}>{f.label}</option>
                ))}
              </Select>
            </div>
            <div>
              <label className="block text-xs font-medium text-[var(--text-soft)] mb-1">خط النصوص</label>
              <Select className="text-sm" value={form.font_body} onChange={(e) => update('font_body', e.target.value)}>
                {FONT_OPTIONS.map((f) => (
                  <option key={f.id} value={f.id}>{f.label}</option>
                ))}
              </Select>
            </div>
          </div>

          <div className="border-t pt-4 space-y-3" style={{ borderColor: 'var(--border)' }}>
            <h3 className="font-bold text-[var(--text)] text-sm">بيانات المتجر للقالب المستورد</h3>

            <div>
              <label className="block text-xs font-medium text-[var(--text-soft)] mb-1">الوصف القصير / الشعار النصي (tagline)</label>
 <Input className="text-sm" value={form.storefront_tagline} onChange={(e) => update('storefront_tagline', e.target.value)} placeholder="كل لوازم السباكة ومواد البناء — توريد جملة وتجزئة"/>
            </div>

            <div>
              <label className="block text-xs font-medium text-[var(--text-soft)] mb-1">قائمة التنقل</label>
              {((form.storefront_menu || []) as any[]).map((m: any, i: number) => (
                <div key={i} className="flex gap-2 mb-1.5" dir="ltr">
 <Input className="text-xs flex-1" value={m.label || ''} placeholder="اسم الرابط" onChange={(e) => update('storefront_menu', (form.storefront_menu || []).map((x: any, j: number) => (j === i ? { ...x, label: e.target.value } : x)))}/>
 <Input className="text-xs flex-1" value={m.href || ''} placeholder="/catalog" onChange={(e) => update('storefront_menu', (form.storefront_menu || []).map((x: any, j: number) => (j === i ? { ...x, href: e.target.value } : x)))}/>
                  <Button variant="ghost" size="icon-sm" onClick={() => update('storefront_menu', (form.storefront_menu || []).filter((_: any, j: number) => j !== i))} className="text-red-400 hover:text-red-500"><X size={14} /></Button>
                </div>
              ))}
              <Button variant="link" size="sm" onClick={() => update('storefront_menu', [...(form.storefront_menu || []), { label: '', href: '' }])} className="text-[11px] p-0 h-auto inline-flex items-center gap-1"><Plus size={12} /> إضافة رابط</Button>
            </div>

            <div>
              <label className="block text-xs font-medium text-[var(--text-soft)] mb-1">روابط التواصل الاجتماعي</label>
              {((form.storefront_socials || []) as any[]).map((m: any, i: number) => (
                <div key={i} className="flex gap-2 mb-1.5" dir="ltr">
 <Input className="text-xs flex-1" value={m.name || ''} placeholder="فيسبوك" onChange={(e) => update('storefront_socials', (form.storefront_socials || []).map((x: any, j: number) => (j === i ? { ...x, name: e.target.value } : x)))}/>
 <Input className="text-xs flex-1" value={m.href || ''} placeholder="https://facebook.com/..." onChange={(e) => update('storefront_socials', (form.storefront_socials || []).map((x: any, j: number) => (j === i ? { ...x, href: e.target.value } : x)))}/>
                  <Button variant="ghost" size="icon-sm" onClick={() => update('storefront_socials', (form.storefront_socials || []).filter((_: any, j: number) => j !== i))} className="text-red-400 hover:text-red-500"><X size={14} /></Button>
                </div>
              ))}
              <Button variant="link" size="sm" onClick={() => update('storefront_socials', [...(form.storefront_socials || []), { name: '', href: '' }])} className="text-[11px] p-0 h-auto inline-flex items-center gap-1"><Plus size={12} /> إضافة تواصل</Button>
            </div>

            <div>
              <label className="block text-xs font-medium text-[var(--text-soft)] mb-1">مقالات / أخبار</label>
              {((form.storefront_posts || []) as any[]).map((p: any, i: number) => (
                <div key={i} className="space-y-1.5 mb-2 rounded-xl border p-2" style={{ borderColor: 'var(--border)' }}>
                  <div className="flex gap-2" dir="ltr">
 <Input className="text-xs flex-1" value={p.title || ''} placeholder="عنوان المقال" onChange={(e) => update('storefront_posts', (form.storefront_posts || []).map((x: any, j: number) => (j === i ? { ...x, title: e.target.value } : x)))}/>
                    <Button variant="ghost" size="icon-sm" onClick={() => update('storefront_posts', (form.storefront_posts || []).filter((_: any, j: number) => j !== i))} className="text-red-400 hover:text-red-500"><X size={14} /></Button>
                  </div>
                  <Textarea className="text-xs w-full" rows={2} value={p.excerpt || ''} placeholder="ملخص قصير" onChange={(e) => update('storefront_posts', (form.storefront_posts || []).map((x: any, j: number) => (j === i ? { ...x, excerpt: e.target.value } : x)))} />
 <Input className="text-xs w-full" dir="ltr" value={p.image_url || ''} placeholder="https://...-image.jpg" onChange={(e) => update('storefront_posts', (form.storefront_posts || []).map((x: any, j: number) => (j === i ? { ...x, image_url: e.target.value } : x)))}/>
                </div>
              ))}
              <Button variant="link" size="sm" onClick={() => update('storefront_posts', [...(form.storefront_posts || []), { title: '', excerpt: '', image_url: '' }])} className="text-[11px] p-0 h-auto inline-flex items-center gap-1"><Plus size={12} /> إضافة مقال</Button>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-medium text-[var(--text-soft)] mb-1">البريد الإلكتروني</label>
 <Input className="text-sm" dir="ltr" value={form.store_email} onChange={(e) => update('store_email', e.target.value)} placeholder="sales@store.com"/>
              </div>
              <div>
                <label className="block text-xs font-medium text-[var(--text-soft)] mb-1">ساعات العمل</label>
 <Input className="text-sm" value={form.store_hours} onChange={(e) => update('store_hours', e.target.value)} placeholder="السبت - الخميس، 9 ص - 6 م"/>
              </div>
            </div>
            <div>
              <label className="block text-xs font-medium text-[var(--text-soft)] mb-1">رابط الخريطة</label>
 <Input className="text-sm" dir="ltr" value={form.store_map_url} onChange={(e) => update('store_map_url', e.target.value)} placeholder="https://maps.app.goo.gl/..."/>
            </div>
          </div>

          <Button
            onClick={() => saveMut.mutate()}
            disabled={saveMut.isPending}
            className="w-full flex items-center justify-center gap-2"
          >
            <Save size={16} /> {saveMut.isPending ? 'جاري الحفظ...' : 'حفظ الهوية وتطبيقها'}
          </Button>
        </div>
      </div>

      {/* Live preview */}
      <div className="xl:col-span-3 space-y-4">
        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-bold text-[var(--text)]">معاينة الصفحة الرئيسية — بحجم المتجر الحقيقي</h3>
            <a href="/" target="_blank" rel="noreferrer" className="inline-flex items-center gap-1.5 text-xs font-bold text-[var(--primary)]">
              فتح في تبويب جديد <ExternalLink size={13} />
            </a>
          </div>
          <iframe
            key={previewKey}
            src="/"
            title="معاينة المتجر"
            sandbox="allow-scripts allow-same-origin"
            className="w-full h-[540px] rounded-2xl border bg-[var(--surface)]"
            style={{ borderColor: 'var(--border)' }}
          />
          <p className="mt-2 text-[11px] text-[var(--muted)]">تُعرض التغييرات في القالب والألوان والخطوط فوراً هنا دون حفظ.</p>
        </div>

        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-bold text-[var(--text)]">معاينة حية</h3>
            <span className="text-[11px] text-[var(--muted)]">تُعرض التغييرات فوراً على التطبيق كاملاً قبل الحفظ</span>
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
                <Button className="text-xs" style={{ background: theme.primary }}>
                  تسوّق الآن
                </Button>
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