# Pre-Ship Preflight Checklist

Every applicable item must pass before shipping. Mark `N/A` only with a reason.

## Structure and hierarchy

- [ ] Page contract is complete and included as a comment at the top of the route TSX.
- [ ] Page purpose and user outcome are obvious from actual content.
- [ ] Primary information is ordered by decision value.
- [ ] Exactly one dominant primary action exists per state.
- [ ] Every region helps the user understand the situation or complete the outcome.
- [ ] Shared components are reused; layers and import direction are respected.
- [ ] No invented metrics, placeholder identities, or generic hero copy.

## Visual / anti-AI defaults

- [ ] No generic gradient identity unless justified by the product.
- [ ] Type scale creates useful hierarchy; body and metadata remain legible.
- [ ] Radius roles differ where component roles differ.
- [ ] Borders and surfaces establish structure; shadows are reserved for elevation.
- [ ] Buttons have distinct primary/secondary/tertiary/destructive priority.
- [ ] Status is not communicated by color alone.
- [ ] All styling uses approved semantic tokens; no inline styles or magic values.
- [ ] Icon style and sizing are consistent and icons have appropriate accessible names.

## States

- [ ] Loading state communicates progress without blocking unnecessary content.
- [ ] Empty first-use state explains what is missing and the next useful action.
- [ ] Filtered-empty state explains how to reset or broaden filters.
- [ ] Error state explains the issue at an appropriate level and offers recovery.
- [ ] Permission-denied state explains the boundary and an available next step.
- [ ] Populated state supports the main outcome.
- [ ] Validation, disabled, stale, and partial-data states are handled where relevant.

## Responsive

- [ ] Reviewed at 1440, 768, and 390 CSS px.
- [ ] Dragged continuously between target widths; no collision or accidental overflow.
- [ ] Primary action remains available at every width.
- [ ] Filters remain connected to the results they control.
- [ ] Essential content is never silently truncated.
- [ ] Horizontal scroll is deliberate and discoverable.
- [ ] Dialogs/drawers fit the viewport, dismiss safely, and manage focus.
- [ ] Touch targets and text wrapping are practical.

## Motion

- [ ] Every animation has a documented communication purpose.
- [ ] Entrance motion is no longer than 0.6s; routine hover no longer than 0.25s.
- [ ] Reduced-motion preference is honored.
- [ ] No infinite decorative animation or layout-shifting hover.
- [ ] Focus and state remain understandable without animation.

## Code and quality

- [ ] TypeScript strictness is respected; no unjustified `any`.
- [ ] No cyclic imports or unnecessary client components.
- [ ] Buttons, links, labels, forms, dialogs, and lists use correct semantics.
- [ ] Keyboard-only interaction and visible focus have been tested.
- [ ] Contrast meets WCAG AA for text and relevant UI components.
- [ ] Loading/error boundaries and data-fetch failure behavior are covered.
- [ ] Tests, lint, typecheck, and build were run where available; results are reported honestly.
- [ ] AI Tell Score is 0, or every remaining item is explicitly justified and approved.
