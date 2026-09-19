import { useEffect } from 'react'
import { useQuery } from '@tanstack/react-query'
import { settingsApi } from './api/endpoints'
import {
  resolveTheme, applyThemeVars, buildCacheCode, cacheTheme,
  readCachedThemeCode, decodeCacheCode, type ThemeSettings,
} from './utils/theme'

const DRAFT_KEY = 'vendora-theme-draft'

export function readThemeDraft(): Partial<ThemeSettings> | null {
  try {
    const raw = localStorage.getItem(DRAFT_KEY)
    return raw ? JSON.parse(raw) : null
  } catch {
    return null
  }
}

export function writeThemeDraft(draft: Partial<ThemeSettings> | null): void {
  try {
    if (draft) localStorage.setItem(DRAFT_KEY, JSON.stringify(draft))
    else localStorage.removeItem(DRAFT_KEY)
  } catch {
    /* ignore */
  }
}

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