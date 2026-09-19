import type { Tone } from './index'

export type SectionId = 'hero' | 'categories' | 'featured' | 'promo' | 'testimonials' | 'features'

export interface SectionConfig {
  id: SectionId
  enabled?: boolean
  heading?: string
}

export const SECTION_META: Record<SectionId, { name: string; description: string }> = {
  hero: { name: 'الهيرو (الواجهة)', description: 'المقدمة الرئيسية — العنوان والصور' },
  categories: { name: 'التصنيفات', description: 'شبكة التصنيفات' },
  featured: { name: 'منتجات مميزة', description: 'أعلى المنتجات مبيعاً' },
  promo: { name: 'بانر عروض الجملة', description: 'دعوة لفتح حساب جملة' },
  testimonials: { name: 'آراء العملاء', description: 'شهادات التجار' },
  features: { name: 'مميزات المتجر', description: 'توصيل / جودة / دعم / أسعار جملة' },
}

export const SECTION_ORDER: SectionId[] = ['hero', 'categories', 'featured', 'promo', 'testimonials', 'features']

export const DEFAULT_SECTIONS: Record<Tone, SectionConfig[]> = {
  classic: [
    { id: 'hero' },
    { id: 'categories' },
    { id: 'featured' },
    { id: 'promo' },
    { id: 'testimonials' },
    { id: 'features' },
  ],
  bold: [
    { id: 'hero' },
    { id: 'categories' },
    { id: 'featured' },
    { id: 'promo' },
    { id: 'testimonials' },
    { id: 'features' },
  ],
  minimal: [
    { id: 'hero' },
    { id: 'categories' },
    { id: 'featured' },
    { id: 'features' },
  ],
}

export function defaultSectionsFor(tone: Tone): SectionConfig[] {
  return DEFAULT_SECTIONS[tone].map((s) => ({ ...s }))
}

/** Accepts the parsed array (backend GET) or a raw JSON string (defensive). */
export function parseSections(raw: unknown): SectionConfig[] | null {
  let arr: unknown = raw
  if (typeof raw === 'string') {
    try {
      arr = JSON.parse(raw)
    } catch {
      return null
    }
  }
  if (!Array.isArray(arr)) return null
  const out: SectionConfig[] = []
  for (const item of arr) {
    if (!item || typeof item !== 'object') continue
    const entry = item as Record<string, unknown>
    const id = entry.id as SectionId
    if (!SECTION_META[id]) continue
    const cfg: SectionConfig = { id }
    if (typeof entry.enabled === 'boolean') cfg.enabled = entry.enabled
    if (typeof entry.heading === 'string') cfg.heading = entry.heading
    out.push(cfg)
  }
  return out.length ? out : null
}