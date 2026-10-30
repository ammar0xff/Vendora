# Anti-AI Tells Checklist

Score each distinct tell once. This is a diagnostic, not a substitute for product judgment. Lower is better; the shipping target is **0 tells**.

## Visual

- [ ] Generic indigo→violet gradient acts as the brand without product justification.
- [ ] One font size/weight dominates every text role.
- [ ] Same radius is applied to controls, cards, menus, and dialogs.
- [ ] Soft shadow is used on every panel despite no elevation difference.
- [ ] Decorative icons, emoji cards, or gradients replace meaningful visual hierarchy.
- [ ] Every action uses the same filled-primary treatment.
- [ ] Status is communicated by color alone.

## Structure

- [ ] Page starts with a generic hero instead of the task.
- [ ] Four equal KPI cards exist despite unequal decision importance.
- [ ] Regions repeat information or do not support the outcome.
- [ ] Generic three-column feature-card pattern appears without a content reason.
- [ ] A monolithic page mixes data logic, state, and all presentation.
- [ ] No hierarchy distinguishes the next action from secondary information.

## Content

- [ ] Generic headline (“Build the future of work”, “The platform for X”).
- [ ] Lorem ipsum, John Doe, “Get Started,” or invented metrics are present.
- [ ] Content lacks concrete nouns, units, dates, owners, or meaningful status.
- [ ] Empty labels such as “Insights” or “Overview” do not explain the information.
- [ ] Placeholder content could belong to any product.

## States

- [ ] Loading state is absent or only a spinner blocks the whole page.
- [ ] Empty state does not explain why it is empty or what to do next.
- [ ] Error state has no recovery path.
- [ ] Permission-denied state is missing or misleading.
- [ ] Filtered-empty and first-use-empty states are treated as identical.
- [ ] Disabled controls have no explanation when one is needed.

## Responsive

- [ ] Desktop layout is merely stacked on mobile.
- [ ] Primary action disappears or becomes hard to reach at 390 px.
- [ ] Essential values are truncated with no alternative.
- [ ] Filters become detached from the results they affect.
- [ ] Horizontal overflow is accidental or has no scroll affordance.
- [ ] Dialogs/drawers cannot be dismissed or do not manage focus.

## Score bands

Use `checks/ai-tell-score.md` for weights.

| Score | Diagnosis | Required response |
|---:|---|---|
| 0–5 | Clean | Review product correctness and ship gates |
| 6–12 | Generic | Rewrite the affected structure/content and rescore |
| 13+ | AI-default | Rebuild from the page contract; do not polish the existing composition |

**Target: 0 tells.** A low score does not excuse accessibility, correctness, performance, or missing-state failures.
