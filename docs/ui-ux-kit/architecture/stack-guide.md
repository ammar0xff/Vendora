# Stack Guide

## Recommended stack and why

- **Next.js App Router:** route-level layouts, server components by default, nested loading/error boundaries, and clear data-fetching boundaries.
- **React + TypeScript:** composable UI with compile-time contracts and typed state.
- **Tailwind CSS v4:** CSS-first `@theme` configuration and semantic utility mapping.
- **shadcn/ui:** accessible, copy-pasteable components that the team owns and can adapt rather than treating a hosted black box as the design system.
- **Motion (`motion/react`):** spring physics and declarative state transitions for interactions that benefit from motion.
- **Lucide React:** consistent line icons with predictable sizing and accessible naming.

Pin versions to the project lockfile and verify vendor docs before introducing a new package or API.

## shadcn/ui usage rules

1. Initialize and configure shadcn/ui for the existing project rather than duplicating components.
2. Keep copied source in `components/ui/`; review updates before applying them.
3. Theme via CSS variables and semantic tokens.
4. Prefer primitives for dialog, dropdown, tooltip, select, tabs, and other keyboard-sensitive interactions.
5. Extend via composition and variants, not one-off styling forks.
6. Do not assume a component is accessible just because it came from a library; test the actual composition.
7. Use native HTML where it is simpler and equally accessible.

## File organization

```text
src/
  app/
    layout.tsx
    page.tsx
    accounts/
      risks/
        page.tsx
        loading.tsx
        error.tsx
  components/
    ui/                 # shadcn/ui owned source
    atoms/
    molecules/
    organisms/
    templates/
  lib/
    utils.ts            # cn() and pure utilities
    motions/
      index.ts
  styles/
    globals.css         # @import "tailwindcss"; @theme and semantic CSS vars
```

Adjust `src/` according to the repository's established convention.

## `cn()` utility

Use the project's standard utility, typically `clsx` + `tailwind-merge`:

```ts
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

## Design-token mapping

Use `bg-background`, `text-foreground`, `bg-primary`, `text-primary-foreground`, `border-border`, `ring-ring`, and other semantic utilities. Do not hard-code raw palette colors in components. Keep CSS variables in `styles/globals.css`.

## Server/client boundaries

- Server Components are the default.
- Use Client Components only for local interaction, browser APIs, or client-side animation.
- Keep server-only credentials and data access out of client modules.
- Prefer route `loading.tsx`, `error.tsx`, and explicit permission states where they fit the user journey.
