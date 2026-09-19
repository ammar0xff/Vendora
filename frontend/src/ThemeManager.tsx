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
if (cachedCode) applyThemeVars(decodeCacheCode(cachedCode))

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
      return
    }
    const theme = resolveTheme(merged)
    applyThemeVars(theme.vars)
    cacheTheme(buildCacheCode(theme.vars))
  }, [data])

  return null
}