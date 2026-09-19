import { useEffect, useMemo, useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { settingsApi, storefrontApi } from '../../../../api/endpoints'
import { useMergedSettings, buildCustomThemeDoc, type CustomThemeData } from '../../../../utils/storefrontDraft'

/**
 * Renders the imported WordPress-style template as a fully self-contained
 * srcdoc iframe, hydrated with live store data (products, categories, posts,
 * menu, socials, store info). Any {{token}} or data-vendora-* placeholder
 * in the template resolves against that data.
 */
export default function CustomTemplatePage() {
  const merged = useMergedSettings()

  const { data: theme } = useQuery({
    queryKey: ['storefront-custom-theme'],
    queryFn: settingsApi.getTheme,
    staleTime: 30_000,
    retry: false,
  })

  const { data: productsData } = useQuery({
    queryKey: ['storefront-home'],
    queryFn: () => storefrontApi.products({ page: 1, page_size: 8 }),
    retry: false,
    enabled: !!theme?.imported,
  })

  const { data: categories } = useQuery({
    queryKey: ['storefront-categories'],
    queryFn: storefrontApi.categories,
    retry: false,
    enabled: !!theme?.imported,
  })

  const data = useMemo<CustomThemeData | null>(() => {
    if (!theme?.imported) return null
    const menu = (merged.storefront_menu || []).map((m: any, i: number) => ({
      label: typeof m === 'string' ? m : m.label || `رابط ${i + 1}`,
      href: typeof m === 'string' ? m : m.href || '',
    }))
    const socials = (merged.storefront_socials || []).map((m: any) => ({
      name: m.name || m.platform || '',
      href: m.url || m.href || '',
    }))
    const posts = (merged.storefront_posts || []).map((p: any) => ({
      title: p.title || '',
      excerpt: p.excerpt || '',
      image_url: p.image_url || '',
      href: p.href || '',
    }))
    return {
      settings: merged || {},
      products: productsData?.items ?? [],
      categories: categories ?? [],
      posts,
      menu,
      socials,
    }
  }, [theme, merged, productsData, categories])

  const srcDoc = useMemo(() => (theme?.html && data ? buildCustomThemeDoc(theme.html, data) : ''), [theme, data])
  const [height, setHeight] = useState(800)

  useEffect(() => {
    const onMsg = (e: MessageEvent) => {
      const msg = e.data
      if (msg?.type === 'vendora:height') setHeight(Math.max(400, msg.height || 800))
      if (msg?.type === 'vendora:nav') window.location.href = msg.href
    }
    window.addEventListener('message', onMsg)
    return () => window.removeEventListener('message', onMsg)
  }, [])

  if (!theme?.imported || !srcDoc) {
    return (
      <div className="min-h-[70vh] flex items-center justify-center text-slate-400 text-sm">
        لم يتم العثور على قالب مستورد — عد إلى الإعدادات لاستيراد قالب.
      </div>
    )
  }

  return (
    <div className="w-full" style={{ background: 'var(--bg)' }}>
      <iframe
        title="قالب المستورد"
        srcDoc={srcDoc}
        sandbox="allow-scripts allow-same-origin allow-forms"
        className="w-full border-0 block"
        style={{ height, display: 'block' }}
      />
    </div>
  )
}