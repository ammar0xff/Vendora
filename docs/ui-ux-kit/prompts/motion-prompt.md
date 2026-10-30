# Motion Prompt — Motion / Framer Motion

Use Motion (`motion/react`) only when movement clarifies cause, state, hierarchy, or spatial continuity. Motion is not decoration and must never conceal slow loading or make essential content wait.

## Defaults

```ts
export const motionDefaults = {
  spring: { type: "spring", stiffness: 300, damping: 30 },
  reveal: { duration: 0.4, ease: "easeOut" },
  collapse: { duration: 0.2, ease: "easeInOut" },
  hover: { duration: 0.15, ease: "easeOut" },
  stagger: 0.05,
} as const;
```

- Entrance motion: maximum 0.6 seconds.
- Hover/press motion: maximum 0.25 seconds.
- Prefer opacity and transform; avoid animation that causes layout shifts.
- Stagger only short lists where order matters. Never delay access to content.
- Honor `prefers-reduced-motion`; use no movement or a minimal opacity transition.
- Keep animation state aligned with semantic state and keyboard behavior.

## Component patterns

### Entrance

```tsx
import { motion, useReducedMotion } from "motion/react";

export function Reveal({ children }: { children: React.ReactNode }) {
  const reduceMotion = useReducedMotion();

  return (
    <motion.div
      initial={reduceMotion ? false : { opacity: 0, y: 6 }}
      animate={{ opacity: 1, y: 0 }}
      transition={
        reduceMotion
          ? { duration: 0 }
          : { duration: 0.4, ease: "easeOut" }
      }
    >
      {children}
    </motion.div>
  );
}
```

### Staggered list

Use only for a small set of items when sequencing aids comprehension. For long data tables, render immediately or animate only newly inserted rows.

```tsx
import { motion, useReducedMotion } from "motion/react";

const container = {
  hidden: {},
  visible: {
    transition: { staggerChildren: 0.05 },
  },
};

const item = {
  hidden: { opacity: 0, y: 4 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.25, ease: "easeOut" } },
};

export function StaggeredList({ items }: { items: string[] }) {
  const reduceMotion = useReducedMotion();

  return (
    <motion.ul
      variants={container}
      initial={reduceMotion ? false : "hidden"}
      animate="visible"
    >
      {items.map((value) => (
        <motion.li key={value} variants={reduceMotion ? undefined : item}>
          {value}
        </motion.li>
      ))}
    </motion.ul>
  );
}
```

### Hover and press

Prefer Tailwind transition utilities for simple color/border changes. Use Motion only when a transform materially improves feedback. Keep the movement subtle and under 0.25 seconds. Do not scale large cards in ways that move neighboring content.

### Modal / drawer overlay

- Animate backdrop opacity and panel transform.
- Use an accessible dialog primitive for focus trapping, initial focus, escape handling, and focus restoration.
- Reduced motion should remove sliding movement and use immediate visibility or a short opacity change.
- A modal must not become inaccessible because an exit animation is running.

### Reduced-motion behavior

Use `useReducedMotion()` for JavaScript-driven motion and CSS `motion-reduce:` utilities for CSS transitions. Ensure the non-animated state remains understandable and complete.

## Never

- Infinite decorative gradients or floating blobs.
- Animate every element on mount.
- Entrance motion longer than 0.6 seconds or routine hover motion longer than 0.25 seconds.
- Layout-shifting hover that changes surrounding geometry.
- Animate numbers to imply real-time change when no such data exists.
- Hide important content until animation finishes.
- Use motion as the only indication of state.
- Override a user's reduced-motion preference.
