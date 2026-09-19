import { BrowserRouter } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { persistQueryClient } from '@tanstack/react-query-persist-client'
import { Toaster } from 'react-hot-toast'
import { persister } from './store/queryPersister'
import StorefrontCartSidebar from './pages/storefront/StorefrontCartSidebar'
import AppRoutes from './router/AppRoutes'

const qc = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 30_000,
      retry: 1,
      gcTime: 1000 * 60 * 60 * 24,
    },
  },
})

persistQueryClient({
  queryClient: qc,
  persister,
  maxAge: 1000 * 60 * 60 * 24,
})

import { useEffect } from 'react'
import { useQuery } from '@tanstack/react-query'
import { settingsApi } from './api/endpoints'
import { normalizeHex } from './utils/theme'
import ThemeManager from './ThemeManager'
import { checkForDesktopUpdates } from './utils/desktopUpdate'

function FaviconUpdater() {
  const { data: settings } = useQuery({ queryKey: ['settings'], queryFn: settingsApi.get, staleTime: 60_000, retry: false })
  useEffect(() => {
    const logo = settings?.logo_url
    const name = settings?.store_name || 'Vendora'
    document.title = name
    const theme = settings?.theme_primary ? normalizeHex(settings.theme_primary, '#1e3a5f') : ''
    if (theme) {
      document.querySelector<HTMLMetaElement>("meta[name='theme-color']")?.setAttribute('content', theme)
    }
    const href = logo ? logo + '?v=' + Date.now() : '/favicon.svg'
    const appleHref = logo ? logo + '?v=' + Date.now() : '/icon-192.png'
    const favicon = document.querySelector<HTMLLinkElement>("link[rel='icon']")
    if (favicon) favicon.href = href
    const svgFavicon = document.querySelector<HTMLLinkElement>("link[rel='icon'][type='image/svg+xml']")
    if (svgFavicon) svgFavicon.href = href
    const apple = document.querySelector<HTMLLinkElement>("link[rel='apple-touch-icon']")
    if (apple) apple.href = appleHref
  }, [settings?.logo_url, settings?.store_name])
  return null
}

export default function App() {
  useEffect(() => { checkForDesktopUpdates() }, [])
  return (
    <QueryClientProvider client={qc}>
      <ThemeManager />
      <FaviconUpdater />
      <BrowserRouter>
        <StorefrontCartSidebar />
        <AppRoutes />
      </BrowserRouter>
      <Toaster position="top-center" toastOptions={{
        style: { fontFamily: 'var(--font-body, Cairo, sans-serif)', direction: 'rtl', borderRadius: '12px' },
        success: { style: { background: '#f0fdf4', border: '1px solid #bbf7d0', color: '#166534' } },
        error: { style: { background: '#fef2f2', border: '1px solid #fecaca', color: '#991b1b' } },
      }} />
    </QueryClientProvider>
  )
}