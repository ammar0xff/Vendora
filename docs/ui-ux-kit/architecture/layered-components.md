# Layered Component Architecture

## Layers and responsibilities

| Layer | Responsibility | Examples |
|---|---|---|
| Atoms | Small, stable visual/interaction primitives | Button, Badge, Input, IconButton, Skeleton |
| Molecules | A focused control or compact repeated pattern | SearchField, RiskBadge, DateRangePicker, EmptyState |
| Organisms | Complete sections with a coherent job | RiskQueue, FilterToolbar, AccountHeader |
| Templates | Page-region layout and responsive composition | QueuePageTemplate, SettingsTemplate |
| Pages | Route, data/state orchestration, page contract | `app/accounts/risks/page.tsx` |

## Import direction

`atoms → molecules → organisms → templates → pages` describes conceptual dependency direction: a layer may import from layers below it, never above it. Shared types and pure utilities live in `lib/`. No cycles. A component must not import a route page.

## Composition target

Aim for most repeated UI to come from the component catalog. A practical starting target is **70–90% catalog composition** for a mature product, not a rigid ratio. Raw semantic HTML remains appropriate inside components; the goal is reuse and consistency, not wrapping every `<div>`.

## Explicit variant unions

Prefer discriminated unions over unrelated booleans:

```tsx
type NoticeProps =
  | { variant: "success"; title: string; description?: string }
  | { variant: "warning"; title: string; description: string; actionLabel?: string }
  | { variant: "error"; title: string; description: string; onRetry: () => void };

export function Notice(props: NoticeProps) {
  if (props.variant === "error") {
    return (
      <section role="alert" className="rounded-md border border-destructive p-4">
        <h2 className="font-semibold">{props.title}</h2>
        <p className="text-sm text-muted-foreground">{props.description}</p>
        <button type="button" onClick={props.onRetry} className="mt-3">
          Retry
        </button>
      </section>
    );
  }

  return (
    <section className="rounded-md border border-border p-4">
      <h2 className="font-semibold">{props.title}</h2>
      {props.description ? <p className="text-sm text-muted-foreground">{props.description}</p> : null}
      {props.variant === "warning" && props.actionLabel ? (
        <span className="mt-2 inline-block text-sm">{props.actionLabel}</span>
      ) : null}
    </section>
  );
}
```

In production, use the project's shadcn/ui Button and typography primitives rather than leaving raw controls inconsistent.

## Tokens-only styling

- Use Tailwind utilities mapped to `@theme` variables.
- Never add one-off hex colors or arbitrary CSS values inside component files.
- Add a semantic token when a real recurring role is missing.
- Use `cn()` to compose classes and handle variant conflicts.
- Avoid repeated class-string forks; expose explicit variant props.

## Good molecule vs bad raw-div page

**Good:** `SearchField` composes a labeled input, search icon, clear action, and optional result count. It owns keyboard behavior and accessible labels; it does not fetch page data.

**Bad:** a route file with nested anonymous `<div>` elements, hard-coded colors, duplicated button classes, inline event/data logic, and no accessible labels. That makes visual behavior inconsistent and testing difficult.

## Suggested component contract

Every reusable component should document:
- Its user-facing purpose.
- Props and explicit variants.
- Accessibility semantics and keyboard behavior.
- State behavior.
- Token roles used.
- Responsive behavior if it changes by width.
