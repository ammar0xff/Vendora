import { useQuery } from '@tanstack/react-query'
import { storefrontApi } from '../../api/endpoints'
import { useMergedSettings } from '../../utils/storefrontDraft'
import { getTemplate } from './templates'
import type { HomeData } from './templates'

export default function StorefrontHomePage() {
  const merged = useMergedSettings()
  const template = merged.storefront_template as string | undefined

  const { data } = useQuery({ queryKey: ['storefront-home'], queryFn: () => storefrontApi.products({ page: 1, page_size: 8 }) })
  const items = data?.items ?? []
  const totalProducts = data?.total ?? 0

  const { data: categories } = useQuery({ queryKey: ['storefront-categories'], queryFn: storefrontApi.categories })
  const catList = categories ?? []

  const def = getTemplate(template)

  const homeData: HomeData = {
    items,
    totalProducts,
    catList,
    heroTitle: merged.storefront_hero_title as string | undefined,
    heroSubtitle: merged.storefront_hero_subtitle as string | undefined,
  }

  return (
    <div className="min-h-screen" style={{ background: 'var(--bg)' }}>
      {def.render(homeData)}
    </div>
  )
}