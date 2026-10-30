# Motion Principles

## Principle

Motion is communication, not decoration. Animate only to show a state transition, preserve spatial context, confirm an interaction, or direct attention to a meaningful change. Content must remain understandable with animation disabled.

## Use motion when

- A menu, dialog, or drawer opens/closes and spatial continuity helps.
- A disclosure expands/collapses.
- A new item enters a short list and its arrival matters.
- A save, validation, or selection change needs subtle feedback.
- A drag/reorder interaction communicates direct manipulation.

## Do not animate when

- It delays access to data or actions.
- It adds no information beyond the static state.
- It repeats continuously to attract attention.
- It causes layout shift or distracts from dense operational work.
- The user requests reduced motion or the OS setting indicates it.
- It animates fabricated data or implies a metric is changing live.

## Duration and easing

| Use case | Default | Notes |
|---|---|---|
| Hover/focus feedback | 100–150 ms | Color/border/opacity; never essential to understanding |
| Press feedback | 80–150 ms | Avoid large scale changes |
| Disclosure/collapse | 200 ms | Prefer height/opacity via accessible primitive |
| Reveal | 400 ms `easeOut` | Maximum 600 ms; content remains usable |
| Modal/drawer | 200–300 ms | Backdrop opacity + panel transform |
| Spring interaction | stiffness 300, damping 30 | Use for direct manipulation or spatial feedback |
| List stagger | 40–60 ms between items | Short lists only; avoid blocking long queues |

## Accessibility

- Honor `prefers-reduced-motion` through `useReducedMotion()` and CSS `motion-reduce:` variants.
- Honor `prefers-contrast` by keeping focus, boundaries, and state changes visible in high-contrast contexts.
- Never rely on movement alone to convey meaning.
- Keep focus stable during transitions. Dialogs must trap focus while open and restore it on close.
- Avoid flashing, rapid repeated motion, and motion that interferes with reading.

## Motion constants

```ts
export const motionDefaults = {
  spring: { type: "spring", stiffness: 300, damping: 30 },
  reveal: { duration: 0.4, ease: "easeOut" },
  collapse: { duration: 0.2, ease: "easeInOut" },
  hover: { duration: 0.15, ease: "easeOut" },
  stagger: 0.05,
} as const;
```

Keep these defaults centralized in `lib/motions/`. Do not create per-component timing values unless a documented interaction requires it.
