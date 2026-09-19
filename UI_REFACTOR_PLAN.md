# Vendora UI Refactor — Full Overhaul Plan

> **Date:** 2026-09-19
> **Status:** In Progress
> **Scan Results:** 732 issues across 37 files (121 errors, 342 warnings, 269 info)
> **Current Stack:** React 19 + Tailwind CSS + Lucide React + Framer Motion + React Hook Form
> **Target Stack:** + shadcn/ui (Radix UI primitives) + Inter font + CSS variables

---

## Phase 0: Foundation (shadcn/ui setup + design tokens)

**Goal:** Install shadcn/ui, create design tokens, set up component library structure.

### Tasks:
- [ ] `npx shadcn@latest init` — configure with existing Tailwind
- [ ] Create `frontend/src/lib/utils.ts` (cn helper already exists, verify)
- [ ] Install core shadcn components: Button, Input, Label, Dialog, Select, Tabs, Table, Card, Badge, Toast, Tooltip, Sheet, Separator, ScrollArea
- [ ] Set up CSS variables in `index.css` (light/dark theme tokens)
- [ ] Update `tailwind.config.js` — Inter font, shadcn color tokens, remove hardcoded colors
- [ ] Create `frontend/src/components/ui/` directory structure (shadcn components go here)
- [ ] Update `index.html` — add Inter + JetBrains Mono font imports
- [ ] Verify `npx tsc --noEmit` passes

### Files:
- `frontend/src/index.css` — add CSS variables, Inter font import
- `frontend/tailwind.config.js` — extend with shadcn tokens
- `frontend/src/components/ui/` — new shadcn components
- `frontend/src/lib/utils.ts` — verify cn() helper

---

## Phase 1: Core Component Replacement

**Goal:** Replace hand-rolled UI primitives with shadcn equivalents.

### 1a: Button replacement
- [ ] Audit all `<button>` elements — find custom button styles
- [ ] Replace with `<Button>` from shadcn (variants: default, destructive, outline, ghost, link)
- [ ] Remove inline button styles (`style={{ background: 'var(--primary)' }}`)
- [ ] Files: `CategoriesPage.tsx`, `SettingsLayout.tsx`, `AccountingLayout.tsx`, `OperationsLayout.tsx`, all modals

### 1b: Input/Label/Form replacement
- [ ] Replace `<input className="input">` with `<Input>` + `<Label>` from shadcn
- [ ] Add `aria-label` or `<Label>` to ALL 95 unlabeled inputs
- [ ] Replace `<select>` with `<Select>` from shadcn
- [ ] Files: `GeneralSettingsPage.tsx`, `AppearancePage.tsx`, `CategoriesPage.tsx`, `ProductForm.tsx`, all forms

### 1c: Modal/Dialog replacement
- [ ] Replace hand-rolled `<Modal>` with `<Dialog>` from shadcn
- [ ] Add proper ARIA attributes (`role="dialog"`, `aria-modal="true"`)
- [ ] Fix ConfirmDialog to use `<AlertDialog>` from shadcn
- [ ] Files: `Layout.tsx` (ConfirmDialog), all pages with modals

### 1d: Table replacement
- [ ] Replace hand-rolled tables with `<Table>` from shadcn
- [ ] Add proper `<thead>`, `<tbody>`, `<th scope>` semantics
- [ ] Files: `DataTable` component (already exists), `SalesPage`, `InventoryPage`

### 1e: Tabs replacement
- [ ] Replace `SectionTabs` custom component with shadcn `<Tabs>`
- [ ] Files: `SectionTabs.tsx`, `SettingsLayout.tsx`, `AccountingLayout.tsx`, `OperationsLayout.tsx`

---

## Phase 2: Layout Overhaul

**Goal:** Fix sidebar navigation, page structure, responsive design.

### 2a: Sidebar redesign
- [ ] Replace hand-rolled sidebar with shadcn `<Sidebar>` or custom with proper semantics
- [ ] Fix width: `w-[220px]` (per design system)
- [ ] Fix item padding: `px-2.5 py-[5px]`
- [ ] Fix icon sizes: `w-[14px] h-[14px]`
- [ ] Add proper `<nav>` element with `aria-label`
- [ ] Fix active state: `opacity-90` (active) vs `opacity-40` (inactive)
- [ ] Files: `Layout.tsx`

### 2b: Page header standardization
- [ ] Standardize page headers across all pages
- [ ] Use consistent heading hierarchy (h1 for page title, h2 for sections)
- [ ] Fix typography: `text-[13px] font-semibold` for page titles
- [ ] Files: All page components

### 2c: Quick tiles / Dashboard cards
- [ ] Replace hand-rolled dashboard cards with shadcn `<Card>`
- [ ] Fix KPI layout: hero KPI full-width, secondary 3-col grid
- [ ] Files: `DashboardPage.tsx`

### 2d: Responsive breakpoints
- [ ] Fix all hardcoded pixel values (`w-[347px]`, `h-[52px]`, etc.)
- [ ] Use responsive Tailwind classes instead
- [ ] Files: `POSPage.tsx` (7 absolute positioning instances), all pages

---

## Phase 3: Visual Polish

**Goal:** Typography, colors, spacing, shadows — make it look professional.

### 3a: Typography system
- [ ] Add Inter font with OpenType features (`cv02`, `cv03`, `cv11`)
- [ ] Set up font hierarchy:
  - Hero KPI: `text-[2.75rem] font-semibold tracking-[-0.04em]`
  - Secondary KPI: `text-[20px] font-semibold tracking-[-0.02em]`
  - Table headers: `text-[9.5px] font-medium uppercase tracking-[0.08em]`
  - Table cells: `text-[11.5px]`
  - Nav items: `text-[12.5px] font-medium`
  - Section headings: `text-[12px] font-medium text-zinc-400`
- [ ] Add `tabular-nums` to all number displays
- [ ] Files: `index.css`, all page components

### 3b: Color system
- [ ] Set up CSS variables for light/dark themes
- [ ] Replace magic hex colors with semantic tokens:
  - `--color-primary`: `#2563eb` (existing blue)
  - `--color-success`: `#22c55e`
  - `--color-warning`: `#f59e0b`
  - `--color-error`: `#ef4444`
- [ ] Remove 28 hardcoded hex colors found in scan
- [ ] Files: `index.css`, all components using inline colors

### 3c: Spacing system
- [ ] Lock vertical rhythm to `mt-5` (20px) between sections
- [ ] Fix card grid gap: `gap-3` (12px)
- [ ] Fix table row padding: `py-[9px]`
- [ ] Files: All page components

### 3d: Shadow/elevation system
- [ ] Define 3 elevation tiers:
  - Tier 1 (hero): `shadow-sm border border-zinc-200`
  - Tier 2 (secondary): `shadow-xs border border-zinc-100`
  - Tier 3 (inline): no shadow
- [ ] Files: All card components

---

## Phase 4: Accessibility Fixes

**Goal:** WCAG compliance — ARIA labels, keyboard navigation, focus management.

### 4a: Form accessibility
- [ ] Add `<Label>` to ALL 95 unlabeled inputs (already covered in 1b)
- [ ] Add `aria-describedby` for error messages
- [ ] Add `required` attribute where needed
- [ ] Files: All form components

### 4b: Interactive element accessibility
- [ ] Add `role="button"` + `tabIndex={0}` + `onKeyDown` to all clickable divs
- [ ] Add `aria-label` to icon-only buttons
- [ ] Remove `outline-none` (keep focus-visible instead)
- [ ] Files: 13+ files with ARIA violations

### 4c: Modal accessibility
- [ ] Add `role="dialog"` + `aria-modal="true"` + `aria-labelledby` to all modals
- [ ] Implement focus trap in modals
- [ ] Add Escape key handler to close modals
- [ ] Files: All modal components

### 4d: Navigation accessibility
- [ ] Add `aria-label="القائمة الرئيسية"` to sidebar nav
- [ ] Add `aria-current="page"` to active nav links
- [ ] Add skip-to-content link
- [ ] Files: `Layout.tsx`

---

## Phase 5: Dark Mode (Optional — if user wants)

**Goal:** Full dark mode support using CSS variables.

### Tasks:
- [ ] Set up dark mode CSS variables (already in Phase 0)
- [ ] Add `dark:` variants to all components
- [ ] Add theme toggle in settings
- [ ] Persist theme preference in localStorage
- [ ] Files: All components

---

## Execution Order

1. **Phase 0** → Foundation (install, tokens, verify)
2. **Phase 1a-1e** → Core components (button, input, modal, table, tabs)
3. **Phase 2a-2d** → Layout (sidebar, headers, responsive)
4. **Phase 3a-3d** → Visual polish (typography, colors, spacing)
5. **Phase 4a-4d** → Accessibility (ARIA, keyboard, focus)
6. **Phase 5** → Dark mode (optional)

## Verification Checkpoints

After each phase:
- `npx tsc --noEmit` — must pass
- `npm run build` — must pass
- `npm run lint` — 0 errors
- `npx vitest run` — all tests pass
- Manual smoke test on dev server

## Risk Mitigation

- **Never touch `docker-compose.yml`**
- **Never commit unless asked**
- **Don't mutate prod `store_name`**
- **Keep existing functionality working** — this is a visual refactor, not a feature change
- **Smallest possible commits per phase** — easy to revert if something breaks
