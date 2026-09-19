import type { ReactNode } from 'react'
import type { StorefrontCategory, StorefrontProduct } from '../types'
import ClassicHome from './ClassicHome'
import BoldHome from './BoldHome'
import MinimalHome from './MinimalHome'

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
  render: (data: HomeData) => ReactNode
}

export const TEMPLATES: TemplateDef[] = [
  {
    id: 'classic',
    name: 'كلاسيكي',
    description: 'واجهة مزدوجة — نص يسار وصور يمين، درجات أزرق داكن مع لمسة ذهبية',
    render: (d) => <ClassicHome {...d} />,
  },
  {
    id: 'bold',
    name: 'جريء',
    description: 'هيرو مركزي ضخم بخط كبير وصور بعرض الصفحة — أقوى حضور',
    render: (d) => <BoldHome {...d} />,
  },
  {
    id: 'minimal',
    name: 'بسيط',
    description: 'خلفية فاتحة هادئة وتخطيط متنفس بدون فوضى',
    render: (d) => <MinimalHome {...d} />,
  },
]

export function getTemplate(id?: string | null): TemplateDef {
  return TEMPLATES.find((t) => t.id === id) ?? TEMPLATES[0]
}