/* Visual identity engine: turns store settings into CSS custom properties.
   Zero dependencies. Values default to the current Vendora navy/gold palette. */

export type ThemeSettings = Record<string, unknown>

export const DEFAULT_THEME = {
  primary: '#1e3a5f',
  accent: '#c8a84b',
  bg: '#f3f5fa',
  ink: '',
  fontHeading: 'Cairo',
  fontBody: 'Cairo',
}

export const FONT_OPTIONS = [
  { id: 'Cairo', label: 'كايرو (Cairo)' },
  { id: 'Tajawal', label: 'تجوّل (Tajawal)' },
  { id: 'Almarai', label: 'المراعي (Almarai)' },
  { id: 'Noto Kufi Arabic', label: 'Noto Kufi Arabic' },
  { id: 'Amiri', label: 'أميري (Amiri)' },
  { id: 'IBM Plex Sans Arabic', label: 'IBM Plex Sans Arabic' },
] as const

export function normalizeHex(value: unknown, fallback: string): string {
  if (typeof value !== 'string') return fallback
  const m = value.trim().match(/^#?([0-9a-f]{3}|[0-9a-f]{6})$/i)
  if (!m) return fallback
  let hex = m[1]
  if (hex.length === 3) hex = hex.split('').map((c) => c + c).join('')
  return '#' + hex.toLowerCase()
}

export function hexToRgb(hex: string): [number, number, number] {
  const h = hex.replace('#', '')
  const n = parseInt(h, 16)
  return [(n >> 16) & 255, (n >> 8) & 255, n & 255]
}

export function rgbToHex(r: number, g: number, b: number): string {
  const to = (x: number) => Math.max(0, Math.min(255, Math.round(x))).toString(16).padStart(2, '0')
  return `#${to(r)}${to(g)}${to(b)}`
}

/** Blend hexA (t=0) toward hexB (t=1). */
export function mix(hexA: string, hexB: string, t: number): string {
  const [r1, g1, b1] = hexToRgb(hexA)
  const [r2, g2, b2] = hexToRgb(hexB)
  return rgbToHex(r1 + (r2 - r1) * t, g1 + (g2 - g1) * t, b1 + (b2 - b1) * t)
}

/** t<0 toward black, t>0 toward white. */
export function shade(hex: string, t: number): string {
  return t <= 0 ? mix(hex, '#000000', -t) : mix(hex, '#ffffff', t)
}

/** WCAG relative luminance (0..1). */
export function luminance(hex: string): number {
  const [r, g, b] = hexToRgb(hex).map((c) => {
    const s = c / 255
    return s <= 0.03928 ? s / 12.92 : Math.pow((s + 0.055) / 1.055, 2.4)
  })
  return 0.2126 * r + 0.7152 * g + 0.0722 * b
}

export function contrastRatio(a: string, b: string): number {
  const [hi, lo] = [luminance(a), luminance(b)].sort((x, y) => y - x)
  return (hi + 0.05) / (lo + 0.05)
}

/** Best readable text color on a given background. */
export function bestText(bgHex: string, dark = '#0f172a', light = '#ffffff'): string {
  return contrastRatio(bgHex, dark) >= contrastRatio(bgHex, light) ? dark : light
}

export function isDark(bgHex: string): boolean {
  return luminance(bgHex) < 0.32
}

export interface ResolvedTheme {
  vars: Record<string, string>
  primary: string
  accent: string
  bg: string
  ink: string
  heading: string
  body: string
}

/** Map store settings → full set of CSS custom properties the app already uses. */
export function resolveTheme(s?: ThemeSettings | null): ResolvedTheme {
  const primary = normalizeHex(s?.theme_primary, DEFAULT_THEME.primary)
  const accent = normalizeHex(s?.theme_accent, DEFAULT_THEME.accent)
  const rawBg = normalizeHex(s?.theme_bg, DEFAULT_THEME.bg)
  const mode = String(s?.theme_mode ?? '').toLowerCase()
  const autoDark = isDark(rawBg)
  const dark = mode === 'dark' ? true : mode === 'light' ? false : autoDark
  // When the mode is forced, synthesize a matching base so surfaces stay coherent
  // (e.g. forced dark with a light theme_bg still produces dark backgrounds).
  const bg =
    mode === 'dark' ? (autoDark ? rawBg : mix(rawBg, '#0f172a', 0.86))
    : mode === 'light' ? (autoDark ? mix(rawBg, '#ffffff', 0.9) : rawBg)
    : rawBg
  const ink = normalizeHex(s?.theme_ink, dark ? '#f8fafc' : '#0f172a')
  const heading = fontId(s?.font_heading)
  const body = fontId(s?.font_body)

  const text = dark ? mix(bg, '#ffffff', 0.86) : '#0f172a'
  const textSoft = dark ? mix(bg, '#ffffff', 0.58) : '#475569'
  const muted = dark ? mix(bg, '#ffffff', 0.4) : '#8a94a6'
  const faint = dark ? mix(bg, '#ffffff', 0.24) : '#b4bccb'
  const surface = dark ? mix(bg, '#ffffff', 0.07) : '#ffffff'
  const surface2 = dark ? mix(bg, '#ffffff', 0.045) : '#f8fafc'
  const surface3 = dark ? mix(bg, '#ffffff', 0.025) : '#f1f4f9'
  const border = dark ? mix(bg, '#ffffff', 0.16) : '#e6eaf2'
  const borderStrong = dark ? mix(bg, '#ffffff', 0.24) : '#d3dae4'
  const borderFaint = dark ? mix(bg, '#ffffff', 0.1) : '#eef1f6'

  const vars: Record<string, string> = {
    '--primary': primary,
    '--primary-strong': shade(primary, -0.13),
    '--primary-deep': shade(primary, -0.24),
    '--primary-soft': mix(primary, '#ffffff', dark ? 0.06 : 0.9),
    '--primary-border': mix(primary, dark ? '#000000' : '#ffffff', dark ? 0.45 : 0.74),
    '--primary-contrast': bestText(primary),
    '--accent': accent,
    '--accent-strong': shade(accent, -0.11),
    '--accent-soft': mix(accent, '#ffffff', dark ? 0.06 : 0.86),
    '--accent-border': mix(accent, dark ? '#000000' : '#ffffff', dark ? 0.42 : 0.72),
    '--accent-contrast': bestText(accent),
    '--gold': accent,
    '--gold-strong': shade(accent, -0.11),
    '--gold-soft': mix(accent, '#ffffff', dark ? 0.06 : 0.86),
    '--gold-border': mix(accent, dark ? '#000000' : '#ffffff', dark ? 0.42 : 0.72),
    '--bg': bg,
    '--surface': surface,
    '--surface-2': surface2,
    '--surface-3': surface3,
    '--border': border,
    '--border-strong': borderStrong,
    '--border-faint': borderFaint,
    '--text': text,
    '--text-soft': textSoft,
    '--ink': text,
    '--muted': muted,
    '--faint': faint,
    '--font-heading': heading,
    '--font-body': body,
    '--sidebar': surface,
    '--sidebar-foreground': text,
    '--sidebar-primary': primary,
    '--sidebar-primary-foreground': bestText(primary),
    '--sidebar-accent': surface3,
    '--sidebar-accent-foreground': text,
    '--sidebar-border': border,
    '--sidebar-ring': primary,
  }
  return { vars, primary, accent, bg, ink, heading, body }
}

export function fontId(value: unknown): string {
  const v = String(value ?? '').trim()
  const found = FONT_OPTIONS.find((f) => f.id.toLowerCase() === v.toLowerCase())
  return found ? found.id : DEFAULT_THEME.fontBody
}

/** Apply a resolved theme to <html>; pass null to clear (back to CSS defaults). */
const STYLE_KEYS = new Set([
  '--primary', '--primary-strong', '--primary-deep', '--primary-soft', '--primary-border', '--primary-contrast',
  '--accent', '--accent-strong', '--accent-soft', '--accent-border', '--accent-contrast',
  '--gold', '--gold-strong', '--gold-soft', '--gold-border',
  '--bg', '--surface', '--surface-2', '--surface-3',
  '--border', '--border-strong', '--border-faint',
  '--text', '--text-soft', '--ink', '--muted', '--faint',
  '--font-heading', '--font-body',
  '--sidebar', '--sidebar-foreground', '--sidebar-primary', '--sidebar-primary-foreground',
  '--sidebar-accent', '--sidebar-accent-foreground', '--sidebar-border', '--sidebar-ring',
])

export function applyThemeVars(vars: Record<string, string> | null): void {
  const el = document.documentElement
  if (!vars) {
    STYLE_KEYS.forEach((k) => el.style.removeProperty(k))
    return
  }
  for (const [k, v] of Object.entries(vars)) el.style.setProperty(k, v)
}

const CACHE_KEY = 'vendora-theme-cache'
export function cacheTheme(code: string): void {
  try { localStorage.setItem(CACHE_KEY, code) } catch { /* ignore */ }
}
export function readCachedThemeCode(): string {
  try { return localStorage.getItem(CACHE_KEY) || '' } catch { return '' }
}
export function clearCachedThemeCode(): void {
  try { localStorage.removeItem(CACHE_KEY) } catch { /* ignore */ }
}
export function buildCacheCode(vars: Record<string, string>): string {
  return Object.entries(vars).map(([k, v]) => `${k}=${v}`).join(';')
}
export function decodeCacheCode(code: string): Record<string, string> {
  const out: Record<string, string> = {}
  for (const pair of code.split(';')) {
    const i = pair.indexOf('=')
    if (i > 0) out[pair.slice(0, i)] = pair.slice(i + 1)
  }
  return out
}