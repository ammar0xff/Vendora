# Page Contract

Complete this contract before generating or materially redesigning a page. Use real domain nouns and observable outcomes. If a field is unknown, mark it `Unknown — confirm` rather than inventing it.

## Fill-in template

- **Page:** [route/name]
- **User:** [specific role and context]
- **Outcome:** [observable thing the user needs to complete]
- **Primary information:** [information needed to decide or act, in priority order]
- **Primary action (exactly one per state):** [state → action; name one dominant action for each state]
- **Secondary action:** [optional lower-priority action(s)]
- **Real content:** [concrete entities, fields, statuses, dates, units, and realistic examples]
- **What can go wrong:** [failure modes, missing data, permissions, stale data, network issues, validation]
- **Required states:**
  - [ ] Loading
  - [ ] Empty
  - [ ] Error
  - [ ] Permission denied
  - [ ] Populated
- **Constraints:** [business rules, privacy, latency, device, localization, existing components, APIs]
- **Responsive targets:**
  - **1440:** [regions and information density]
  - **768:** [what changes and why]
  - **390:** [priority information, controls, and actions]
- **Assumptions to validate:** [explicit list]
- **Success criteria:** [observable and testable]

**Region rule:** A region belongs only if it helps the user understand the situation or complete the outcome. If its purpose cannot be stated in one sentence tied to the outcome, remove it.

## Worked example: Account manager customer-risk queue

- **Page:** `/accounts/risks`
- **User:** Account manager starting a daily retention review
- **Outcome:** Identify the most urgent at-risk account and take the next appropriate action
- **Primary information:** Risk severity, customer/account name, risk reason, account owner, last meaningful activity, renewal date, recommended next step
- **Primary action (exactly one per state):**
  - Loading: none while data is unavailable; expose a stable skeleton and status announcement
  - Empty: `Review all accounts`
  - Error: `Retry loading risk queue`
  - Permission denied: `Request access`
  - Populated: `Open highest-priority account`
- **Secondary action:** Search accounts; filter by risk severity and owner; sort by renewal date
- **Real content:** `Northstar Logistics`, `High risk`, `No admin login in 21 days`, `Maya Chen`, `Renewal: 18 Nov 2026`, `Last activity: 08 Oct 2026`. Treat these as sample records for a prototype, not real customer facts.
- **What can go wrong:** API timeout; partial activity history; stale risk score; no accounts meet current filters; user can view but not edit; permission expires
- **Required states:** loading, empty (including no filter matches), error with retry, permission denied with access path, populated queue
- **Constraints:** Do not expose sensitive notes in a list preview; risk severity must include text, not color alone; filters must work with the queue; avoid fabricated risk percentages
- **Responsive targets:**
  - **1440:** Dense table with columns for account, risk/reason, owner, renewal, last activity, and one row action
  - **768:** Condensed list rows; keep account, severity, reason, and renewal visible; move filters into a disclosure/drawer if needed
  - **390:** One account per compact card/row; severity and reason first; show renewal and next action without truncating essential content; filters open in a dismissible sheet
- **Assumptions to validate:** Risk score source and refresh cadence; whether users can reassign owners; exact permission-request route
- **Success criteria:** User can identify the highest-priority account without opening multiple records, can understand why it is at risk, and can reach its detail page by keyboard or touch

## Contract review questions

1. Can the user's outcome be stated as a verb plus an object?
2. Is primary information ranked by decision value?
3. Is there exactly one dominant action in each applicable state?
4. Are examples concrete and clearly marked as sample data if not real?
5. Does every region earn its space?
6. Are failure and permission states actionable?
7. Does the mobile layout preserve decision-making—not merely stack desktop columns?
