import { useQuery } from '@tanstack/react-query'
import { storefrontApi } from '../../api/endpoints'
import { useMergedSettings } from '../../utils/storefrontDraft'
import { getTone } from './templates'
import type { HomeData } from './templates'
import { defaultSectionsFor, parseSections } from './templates/sections'
import StorefrontSections from './templates/StorefrontSections'
import StorefrontNav from './StorefrontNav'
import Footer from './sections/StorefrontFooter'

export default function StorefrontHomePage() {
  const merged = useMergedSettings()
  const tone = getTone(merged.storefront_template as string | undefined)
  const sections = parseSections(merged.storefront_sections) ?? defaultSectionsFor(tone)

  const { data } = useQuery({ queryKey: ['storefront-home'], queryFn: () => storefrontApi.products({ page: 1, page_size: 8 }) })
  const items = data?.items ?? []
  const totalProducts = data?.total ?? 0

  const { data: categories } = useQuery({ queryKey: ['storefront-categories'], queryFn: storefrontApi.categories })
  const catList = categories ?? []

  const homeData: HomeData = {
    items,
    totalProducts,
    catList,
    heroTitle: merged.storefront_hero_title as string | undefined,
    heroSubtitle: merged.storefront_hero_subtitle as string | undefined,
  }

  return (
    <div className="min-h-screen" style={{ background: 'var(--bg)' }}>
      <StorefrontNav />
      <StorefrontSections data={homeData} tone={tone} sections={sections} />
      <Footer variant={tone} />
    </div>
  )
}