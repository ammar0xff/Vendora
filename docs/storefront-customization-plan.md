# Storefront Templates + Visual Identity — Implementation Plan

> Owners pick a landing-page template and customize brand colors/fonts/logo once in Settings;
> the whole app (storefront + admin) rebrands instantly; later a drag-and-drop section builder.

## Decisions (confirmed with owner)
- Template scope: **everything**, shipped in phases.
- Identity scope: **colors + fonts + logo/name** (+ a few hero copy fields).
- Applies: **whole app** (storefront + admin).
- Settings preview: **full-page live preview** (same-origin iframe reading a localStorage draft).

## Backend (minimal, no schema change)
- `store_settings` key/value store already: `GET /settings` is **public**; `PUT /settings` upserts arbitrary keys (`settings` perm required).
- Change `pwa_manifest` in `backend/app/api/routers/settings.py`: `theme_color`/`background_color` read `theme_color` setting instead of hardcoded `#2b1b03`. Also we may read `primary_color`.
- Settings keys (defaults = today's values):
  | key | default |
  |---|---|
  | `storefront_template` | `'classic'` |
  | `theme_primary` | `#1e3a5f` |
  | `theme_accent` | `#c8a84b` |
  | `theme_bg` | `#f3f5fa` |
  | `theme_ink` | `#0f172a` | — dark readable text color (also derived by luminance)
  | `font_heading` | `'Cairo'` |
  | `font_body` | `'Cairo'` |
  | `storefront_hero_title` | current hero title |
  | `storefront_hero_subtitle` | current hero subtitle |

## Phase 0 — Theme engine (whole-app)
1. **`frontend/src/utils/theme.ts`** — new, zero deps:
   - `hexToRgb`, `mix(hex, other, t)`, `shade(hex, t)` (mix toward black/white),
   - `luminance(hex)` + `bestText(bg)` → `#0f172a` or `#ffffff`,
   - `resolveTheme(settings)` → flat map of CSS vars:
     - primary → `--primary`, `--primary-strong` (−12% dark), `--primary-deep` (−18%), `--primary-soft` (12% light), `--primary-border` (22% light), `--primary-contrast` (bestText),
     - accent → `--accent`, `--accent-strong` (−10%), `--accent-soft` (+12%), `--accent-border` (+22%), `--accent-contrast`,
     - `--gold/--gold-strong/--gold-soft/--gold-border` mirror accent (legacy aliases used in code),
     - bg → `--bg`, `--surface`, `--surface-2`, `--surface-3`, `--border`, `--border-strong`, `--text`, `--text-soft`, `--muted` (neutral ramp derived from bg + ink),
     - fonts → `--font-heading`, `--font-body`.
2. **`frontend/src/components/ThemeManager.tsx`** — mounted once at App root:
   - `const { data } = useQuery(['settings'], settingsApi.get)` (reuses existing persisted query, public).
   - Computes `resolveTheme(data)` and writes to `document.documentElement.style` via `setProperty`.
   - Clears properties when settings absent (back to CSS defaults).
   - localStorage cache of last known theme applied synchronously before paint to avoid flash.
3. **`frontend/src/index.css`**:
   - base layer: `html { font-family: var(--font-body, 'Cairo', ...) }`,
   - add `h1..h6 { font-family: var(--font-heading, ...) }`,
   - declare `--font-heading`/`--font-body` in `:root` (default Cairo).
   - (Tailwind `@theme inline` values stay as build-time fallbacks; app uses `var(--...)` which runtime overrides win.)
4. **`frontend/index.html`** — add Google Fonts links for apt body/heading choices (joined families):
   Cairo, Tajawal, Almarai, Amiri, Noto Kufi Arabic, IBM Plex Sans Arabic.
5. **Settings UI — new «الواجهة والمظهر» tab** (`SettingsPage.tsx`):
   - Color pickers (primary/accent/bg/ink) with hex inputs + `type=color`,
   - font dropdowns (heading/body) with live sample,
   - reset-to-defaults button,
   - live swatch strip (contrast-checked badge),
   - Save → `PUT /settings` (existing mechanism).

## Phase 1 — Templates + full-page live preview
1. Refactor `StorefrontHomePage` into composable sections:
   - `Nav`, `Hero` (variant-driven), `CategoryShowcase`, `FeaturedProducts`, `Promo`, `Testimonials`, `FeatureStrip`, `Footer` → extracted components in `storefront/sections/`.
2. **`frontend/src/pages/storefront/templates/`** registry (`index.ts`):
   `{ id, name, description, thumbnail, component }`.
   - `classic` — current composition (nav cargo light, hero + categories + featured + promo + testimonials + features + footer).
   - `bold` — full-bleed hero, large typography, strong accent band, dark footer band.
   - `minimal` — airy, shallow bg, bordered cards, slim hero.
3. `StorefrontHomePage` reads `storefront_template` from settings and renders the template component (fallback `classic`).
4. **Live preview**: Settings writes a draft JSON to `localStorage['storefront_preview']`; a same-origin `<iframe src="/?preview=1">` renders `/`; the storefront config hook merges `localStorage` draft over saved settings so changes draw live; «حفظ وتطبيق» writes `PUT /settings` and clears draft.
   - Because preview URL = `/` on the same deployment, iframe needs no backend.
5. Hero copy from `storefront_hero_title`/`_subtitle` (falls back to current copy).

## Phase 2 — Drag-and-drop section builder
1. Section registry `storefront/sections/index.ts`: `{ id, title, icon, component, defaults, fields[] }` where fields drive simple forms (text/color/image/bool/list).
2. Config stored in setting `storefront_sections` (JSON array `[{id, order, props}]`); when present, `/` renders those sections in order (template = a default section order when absent).
3. Builder UI in the Settings tab:
   - list active sections w/ up/down/remove,
   - «إضافة قسم» palette,
   - per-section props form,
   - same live iframe preview.
4. Optional: floating «تخصيص» button on `/` visible only to admins (checks `useAuthStore`) → deep-links to settings tab.

## Verification
- `cd frontend && npx tsc --noEmit`
- `npm run build` (vite) — catches missing import / JSX name bugs
- Playwright: storefront `/`, `/catalog`, admin `/settings` render; change color → save → reload reflects; template switch; preview iframe updates live.
- Backend: run local uvicorn (be-venv) for manifest spot-check + E2E `/health`.

## Commit order
1. `docs` + TASKS update (docs only)
2. Phase 0 backend manifest color (backend)
3. Phase 0 frontend (theme utils, ThemeManager, css/fonts, settings tab)
4. Phase 1 (sections refactor + templates + preview)
5. Phase 2 (builder)