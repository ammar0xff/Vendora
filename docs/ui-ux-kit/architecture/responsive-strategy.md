# Responsive Strategy

Design at **1440, 768, and 390 CSS px**, then drag between those widths. Breakpoints are constraints, not the design itself. Every region must have an explicit behavior.

## Region behavior vocabulary

- **Stay:** retain position and form.
- **Stack:** move into a vertical sequence.
- **Reorder:** prioritize the decision-critical content.
- **Collapse:** disclose secondary controls behind a button.
- **Scroll:** use deliberate, discoverable horizontal scrolling only when the content is inherently tabular or timeline-like.
- **Drawer/dialog:** move complex filters or secondary workflows into an accessible overlay.
- **Disappear:** remove only nonessential content; provide an alternate path if useful.

## Target behavior

| Region | 1440 | 768 | 390 |
|---|---|---|---|
| Global navigation | Full navigation | Compact nav or menu | Compact nav; primary destination reachable |
| Page title/context | Full title and description | Same meaning, shorter wrapping | Keep task and context; avoid generic oversized hero |
| Primary action | Visible in page header | Visible or in stable action area | Always visible without covering content |
| Filters | Inline toolbar | Wrap or collapse | Dismissible drawer/sheet or compact disclosure |
| Dense table | Full useful columns | Condense lower-priority columns | Convert rows to decision-oriented list/card, or deliberate horizontal scroll |
| Main content | Multi-region if useful | Reflow based on priority | Single primary flow; not merely stacked desktop |
| Supporting metadata | Inline | Wrap or move below | Show only decision-relevant metadata first |
| Dialog/drawer | Sized to task | Fit viewport | Full-width sheet or viewport-fit dialog with safe scrolling |
| Secondary panels | Side-by-side where useful | Reorder/stack | Collapse or remove if nonessential |

## Rules

- Keep the primary action available at all widths and in every applicable state.
- Keep filters logically and visually connected to the results they control. Show active filter count and a clear/reset action when relevant.
- Never truncate essential decision data without an accessible way to inspect it.
- Ensure overlays are dismissible, keyboard operable, and focus managed.
- Horizontal scroll must be deliberate, with visible affordance and no accidental page-level overflow.
- Touch targets should be approximately 44×44 CSS px where feasible.
- Use content-based breakpoints where the layout stops working, not because a device label says so.
- Test long names, translated strings, large text, keyboard focus, empty data, and validation messages.
- Do not hide the only explanation for a status on mobile.
- Do not put critical actions only in hover menus.

## Responsive review sequence

1. At 1440, verify information hierarchy and density.
2. At 768, identify collision points and choose each region's behavior.
3. At 390, redesign the decision flow and control placement.
4. Drag continuously between sizes and test long content.
5. Verify keyboard, touch, focus, overflow, and overlays.
