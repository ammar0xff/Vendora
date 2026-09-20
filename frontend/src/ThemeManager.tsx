import { useEffect } from 'react'
import { useQuery } from '@tanstack/react-query'
import { settingsApi } from './api/endpoints'
import { readThemeDraft } from './utils/storefrontDraft'
import type { ThemeSettings } from './utils/theme'
import {
  resolveTheme, applyThemeVars, buildCacheCode, cacheTheme,
  readCachedThemeCode, decodeCacheCode,
} from './utils/theme'

/* Apply the last-known theme before first paint to avoid a flash. */
const cachedCode = readCachedThemeCode()
if (cachedCode) {
  applyThemeVars(decodeCacheCode(cachedCode))
  const cached = decodeCacheCode(cachedCode)
  if (cached['--bg']) {
    const isDark = cached['--bg'] === cached['--bg'].replace(/^#/, '') // simple check: if bg is dark-ish
    // Better: check if text is light (dark mode)
    const text = cached['--text'] || ''
    if (text && text.startsWith('#') && parseInt(text.slice(1, 3), 16) > 200) {
      document.documentElement.classList.add('dark')
    }
  }
}

export default function ThemeManager() {
  const { data } = useQuery({
    queryKey: ['settings'],
    queryFn: settingsApi.get,
    staleTime: 60_000,
    retry: false,
  })

  useEffect(() => {
    const draft = readThemeDraft()
    const merged = (draft ? { ...(data || {}), ...draft } : data) as ThemeSettings | null | undefined
    if (!merged || Object.keys(merged).length === 0) {
      const code = readCachedThemeCode()
      if (code) applyThemeVars(decodeCacheCode(code))
      else applyThemeVars(null)
      document.documentElement.classList.remove('dark')
      return
    }
    const theme = resolveTheme(merged)
    applyThemeVars(theme.vars)
    cacheTheme(buildCacheCode(theme.vars))
    if (theme.dark) document.documentElement.classList.add('dark')
    else document.documentElement.classList.remove('dark')
  }, [data])

  return null
}