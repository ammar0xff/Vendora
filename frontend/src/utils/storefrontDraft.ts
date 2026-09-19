import { useQuery } from '@tanstack/react-query'
import { settingsApi } from '../api/endpoints'

export const DRAFT_KEY = 'vendora-theme-draft'

export type StorefrontDraft = Record<string, unknown>

export function readThemeDraft(): StorefrontDraft | null {
  try {
    const raw = localStorage.getItem(DRAFT_KEY)
    return raw ? JSON.parse(raw) : null
  } catch {
    return null
  }
}

export function writeThemeDraft(draft: StorefrontDraft | null): void {
  try {
    if (draft) localStorage.setItem(DRAFT_KEY, JSON.stringify({ ...readThemeDraft(), ...draft }))
    else localStorage.removeItem(DRAFT_KEY)
  } catch {
    /* ignore */
  }
}

/** Saved settings merged over the unsaved draft — used by the storefront itself and admin previews. */
export function mergeSettings(saved: Record<string, unknown> | null | undefined) {
  const draft = readThemeDraft()
  if (!saved) return saved
  return { ...saved, ...(draft || {}) }
}

/** Settings = server rows + current unsaved draft (template, hero copy, theme). */
export function useMergedSettings() {
  const { data } = useQuery({ queryKey: ['settings'], queryFn: settingsApi.get, staleTime: 60_000, retry: false })
  return mergeSettings(data || {})
}