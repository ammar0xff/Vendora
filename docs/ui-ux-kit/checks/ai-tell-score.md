# AI Tell Score Detector (0–100)

Lower is better. Score distinct observable tells, not subjective dislike. **Target = 0 tells.** This score is a heuristic and must be paired with accessibility, correctness, and product review.

## Scoring rules

- Critical visual tells: **+2 each**
- Structure, content, state, and responsive tells: **+1 each**
- Cap the total at 100.
- Count each listed tell once. Do not double-count the same root cause in multiple phrasings.

## Critical visual tells (+2)

- [ ] Generic indigo→violet gradient used as the default brand identity.
- [ ] One radius and one shadow used indiscriminately across the interface.
- [ ] All buttons styled as equally primary.
- [ ] Type has no meaningful scale/hierarchy.
- [ ] Status conveyed by color alone.

## Structure tells (+1)

- [ ] Generic hero or dashboard structure replaces the page's task.
- [ ] Four equal KPI cards despite unequal importance.
- [ ] Three emoji feature cards without product-specific reason.
- [ ] Redundant or ornamental regions do not support the outcome.
- [ ] Monolithic route with no reusable component structure.

## Content tells (+1)

- [ ] Generic headline or generic CTA.
- [ ] Lorem ipsum, John Doe, or unmarked fake content.
- [ ] Invented metrics or percentages.
- [ ] Labels do not identify concrete domain information.
- [ ] Sample content is not distinguished from real data.

## State tells (+1)

- [ ] Missing loading, empty, error, or permission-denied state.
- [ ] Empty/error state has no useful next action.
- [ ] Filtered-empty state is not distinguished when applicable.
- [ ] Disabled action has no explanation when needed.

## Responsive tells (+1)

- [ ] Mobile is only a stacked desktop layout.
- [ ] Primary action is missing or hard to reach at 390 px.
- [ ] Essential data is truncated.
- [ ] Filters become detached from results.
- [ ] Accidental horizontal overflow or inaccessible overlay.

## Bands and required response

| Score | Band | Required response |
|---:|---|---|
| 0–5 | Ship candidate | Complete all preflight checks; target is still 0 |
| 6–12 | Structural rewrite | Repair affected hierarchy/content/states, then rescore |
| 13+ | Rebuild | Return to the page contract and reconstruct the page |

A score of 0 is not a guarantee of quality. It means these specific generic tells were not detected. Verify the user outcome, domain correctness, accessibility, performance, and responsive behavior independently.
