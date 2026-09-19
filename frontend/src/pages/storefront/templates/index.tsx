import type { StorefrontCategory, StorefrontProduct } from '../types'

export type Tone = 'classic' | 'bold' | 'minimal'

export interface HomeData {
  items: StorefrontProduct[]
  totalProducts: number
  catList: StorefrontCategory[]
  heroTitle?: string
  heroSubtitle?: string
}

export interface TemplateDef {
  id: Tone
  name: string
  description: string
  tone: Tone
}

export const TEMPLATES: TemplateDef[] = [
  { id: 'classic', name: 'كلاسيكي', description: 'واجهة مزدوجة — نص يسار وصور يمين، درجات أزرق داكن مع لمسة ذهبية', tone: 'classic' },
  { id: 'bold', name: 'جريء', description: 'هيرو مركزي ضخم بخط كبير وصور بعرض الصفحة — أقوى حضور', tone: 'bold' },
  { id: 'minimal', name: 'بسيط', description: 'خلفية فاتحة هادئة وتخطيط متنفس بدون فوضى', tone: 'minimal' },
]

export function getTemplate(id?: string | null): TemplateDef {
  return TEMPLATES.find((t) => t.id === id) ?? TEMPLATES[0]
}

export function getTone(id?: string | null): Tone {
  return getTemplate(id).tone
}