# Design Tokens — Tailwind CSS v4

Tokens are semantic contracts, not a bag of decoration. Start with existing brand/product constraints; map them into roles. The values below are a neutral starting scaffold, not a mandate to recolor an established product.

## `styles/globals.css`

```css
@import "tailwindcss";

:root {
  color-scheme: light;
  --background: oklch(0.985 0.003 250);
  --foreground: oklch(0.22 0.015 255);
  --primary: oklch(0.42 0.09 245);
  --primary-foreground: oklch(0.99 0.002 250);
  --secondary: oklch(0.94 0.012 250);
  --muted: oklch(0.955 0.006 250);
  --muted-foreground: oklch(0.48 0.018 255);
  --accent: oklch(0.92 0.025 200);
  --accent-foreground: oklch(0.24 0.025 230);
  --destructive: oklch(0.55 0.19 27);
  --border: oklch(0.88 0.01 255);
  --input: oklch(0.86 0.012 255);
  --ring: oklch(0.57 0.12 245);
  --success: oklch(0.55 0.13 155);
  --warning: oklch(0.72 0.14 75);
  --info: oklch(0.61 0.12 230);

  --radius-sm: 0.25rem;
  --radius-md: 0.5rem;
  --radius-lg: 0.875rem;
  --radius-full: 9999px;

  --shadow-sm: 0 1px 2px oklch(0.2 0.01 255 / 0.06);
  --shadow-md: 0 8px 24px oklch(0.2 0.01 255 / 0.10);
  --shadow-lg: 0 20px 48px oklch(0.2 0.01 255 / 0.16);

  --ease-spring: linear(0, 0.009 1%, 0.035 3%, 0.1 7%, 0.25 15%, 0.5 30%, 0.75 45%, 0.9 60%, 0.97 75%, 1);
  --duration-fast: 150ms;
  --duration-normal: 250ms;
  --duration-slow: 400ms;
}

.dark {
  color-scheme: dark;
  --background: oklch(0.18 0.012 255);
  --foreground: oklch(0.94 0.008 255);
  --primary: oklch(0.73 0.10 245);
  --primary-foreground: oklch(0.2 0.02 255);
  --secondary: oklch(0.27 0.012 255);
  --muted: oklch(0.24 0.012 255);
  --muted-foreground: oklch(0.72 0.012 255);
  --accent: oklch(0.3 0.03 220);
  --accent-foreground: oklch(0.94 0.008 255);
  --destructive: oklch(0.68 0.17 27);
  --border: oklch(0.34 0.012 255);
  --input: oklch(0.38 0.012 255);
  --ring: oklch(0.72 0.10 245);
  --success: oklch(0.72 0.13 155);
  --warning: oklch(0.82 0.13 75);
  --info: oklch(0.74 0.11 230);
}

@theme inline {
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --color-primary: var(--primary);
  --color-primary-foreground: var(--primary-foreground);
  --color-secondary: var(--secondary);
  --color-muted: var(--muted);
  --color-muted-foreground: var(--muted-foreground);
  --color-accent: var(--accent);
  --color-accent-foreground: var(--accent-foreground);
  --color-destructive: var(--destructive);
  --color-border: var(--border);
  --color-input: var(--input);
  --color-ring: var(--ring);
  --color-success: var(--success);
  --color-warning: var(--warning);
  --color-info: var(--info);

  --radius-sm: var(--radius-sm);
  --radius-md: var(--radius-md);
  --radius-lg: var(--radius-lg);
  --radius-full: var(--radius-full);

  --shadow-sm: var(--shadow-sm);
  --shadow-md: var(--shadow-md);
  --shadow-lg: var(--shadow-lg);

  --ease-spring: var(--ease-spring);
  --duration-fast: var(--duration-fast);
  --duration-normal: var(--duration-normal);
  --duration-slow: var(--duration-slow);

  --text-xs: 0.75rem;
  --text-sm: 0.875rem;
  --text-base: 1rem;
  --text-lg: 1.125rem;
  --text-xl: 1.25rem;
  --text-2xl: 1.5rem;
  --text-3xl: 1.875rem;
  --text-4xl: 2.25rem;

  --tracking-tight: -0.035em;
  --tracking-tighter: -0.05em;
}
```

## Token conventions

### Color roles

- `background` / `foreground`: default page surface and text.
- `primary` / `primary-foreground`: the one dominant action and its readable content.
- `secondary`: lower-priority controls or surfaces.
- `muted` / `muted-foreground`: supporting content with verified contrast.
- `accent` / `accent-foreground`: meaningful emphasis, selected states, or highlighted regions.
- `destructive`: irreversible or dangerous actions and errors requiring attention.
- `border` / `input`: structural boundaries and form-control outlines.
- `ring`: visible keyboard focus.
- `success`, `warning`, `info`: status semantics; always pair color with text/icon/shape.

### Spacing scale

Use Tailwind's standard spacing scale (`0`, `1`, `2`, `3`, `4`, `5`, `6`, `8`, `10`, `12`, `16`, `20`, `24`) consistently. Define a new semantic spacing token only when a repeated product pattern requires it. Avoid arbitrary values like `mt-[37px]`.

### Role-based radii

- `rounded-sm`: compact chips, subtle control corners.
- `rounded-md`: inputs and standard buttons.
- `rounded-lg`: grouped panels and cards when the product warrants them.
- `rounded-full`: pills, avatars, circular icon buttons.
- Dialogs and sheets may use a larger role if it is explicitly tokenized; do not default every surface to it.

### Type scale

Use `text-xs` through `text-4xl` with intentional roles. Larger headings use tighter tracking (`tracking-tight` / `tracking-tighter`); body copy should remain comfortable to read. Do not use `text-4xl` as a universal page title. Check line-height and wrapping at all target widths.

### Elevation

Prefer borders and surface contrast first. Use `shadow-sm` for subtle separation, `shadow-md` for menus/popovers, and `shadow-lg` for a modal or floating surface only when elevation is real. Do not shadow every card.

### Motion tokens

Use `duration-fast`, `duration-normal`, `duration-slow`, and `ease-spring` for CSS transitions. Motion's spring physics are configured in Motion props; keep them consistent with `prompts/motion-prompt.md`.
