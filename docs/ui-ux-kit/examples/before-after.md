# Before / After: Account Manager Customer-Risk List

Both versions represent the same page: an account manager needs to find the account most likely to require intervention and act on it.

## Before (AI-default)

```tsx
export default function Dashboard() {
  return (
    <main className="min-h-screen bg-white p-8 text-slate-900">
      <section className="rounded-2xl bg-gradient-to-r from-indigo-600 to-violet-600 p-10 text-white shadow-lg">
        <h1 className="text-4xl font-bold">Build the future of customer success</h1>
        <p className="mt-3">The platform for better relationships.</p>
        <button className="mt-6 rounded-xl bg-white px-5 py-3 text-indigo-700">Get Started</button>
      </section>
      <section className="mt-8 grid grid-cols-4 gap-4">
        {["Accounts", "Growth", "Engagement", "Success"].map((title) => (
          <div key={title} className="rounded-2xl border p-5 shadow-sm">
            <div className="text-sm text-slate-500">{title}</div>
            <div className="mt-2 text-3xl font-bold">+24%</div>
          </div>
        ))}
      </section>
      <section className="mt-8 grid grid-cols-3 gap-4">
        <div className="rounded-2xl border p-6">🚀 Grow faster</div>
        <div className="rounded-2xl border p-6">💡 Get insights</div>
        <div className="rounded-2xl border p-6">🔒 Stay secure</div>
      </section>
    </main>
  );
}
```

### Why it fails

- The page describes a generic product instead of the account manager's immediate task.
- It invents the same `+24%` metric four times.
- The only action is generic and does not lead to an at-risk account.
- No account name, risk reason, owner, renewal date, or last activity is shown.
- No loading, empty, error, or permission state exists.
- The layout spends the most visual space on a gradient hero that does not help triage.
- Every panel has the same radius/shadow treatment.
- The mobile layout is not designed around account decisions.

**Illustrative AI Tell Score: ~14** (actual score depends on the exact checklist and whether overlapping tells are counted once).

## After (professional, product-specific)

```tsx
/**
 * PAGE CONTRACT
 * Page: Customer risk queue
 * User: Account manager reviewing retention risk
 * Outcome: Identify the most urgent account and open its record
 * Primary information: Severity, account, reason, owner, renewal, last activity
 * Primary action: Open highest-priority account (populated); state-specific recovery action otherwise
 * Secondary action: Search and filter the queue
 * Required states: loading, empty, error, permission-denied, populated
 * Responsive: full table at 1440; condensed rows at 768; decision-first cards at 390
 */
import { AlertTriangle, ArrowRight, Search } from "lucide-react";

type RiskLevel = "High" | "Medium" | "Low";

type AccountRisk = {
  id: string;
  name: string;
  level: RiskLevel;
  reason: string;
  owner: string;
  renewalDate: string;
  lastActivity: string;
};

const sampleAccounts: AccountRisk[] = [
  {
    id: "northstar",
    name: "Northstar Logistics",
    level: "High",
    reason: "No admin login in 21 days",
    owner: "Maya Chen",
    renewalDate: "18 Nov 2026",
    lastActivity: "08 Oct 2026",
  },
  {
    id: "cedar",
    name: "Cedar & Finch",
    level: "Medium",
    reason: "Two unresolved support cases",
    owner: "Omar Hassan",
    renewalDate: "02 Dec 2026",
    lastActivity: "24 Oct 2026",
  },
];

function RiskLabel({ level }: { level: RiskLevel }) {
  const classes: Record<RiskLevel, string> = {
    High: "border-destructive/40 bg-destructive/10 text-destructive",
    Medium: "border-warning/50 bg-warning/10 text-foreground",
    Low: "border-success/40 bg-success/10 text-foreground",
  };

  return (
    <span className={`inline-flex items-center gap-2 rounded-sm border px-2 py-1 text-xs font-medium ${classes[level]}`}>
      {level === "High" ? <AlertTriangle aria-hidden="true" className="size-3.5" /> : null}
      {level} risk
    </span>
  );
}

export function CustomerRiskQueue({
  accounts = sampleAccounts,
  onOpenAccount,
}: {
  accounts?: AccountRisk[];
  onOpenAccount: (id: string) => void;
}) {
  if (accounts.length === 0) {
    return (
      <section className="rounded-lg border border-border bg-background p-6">
        <h2 className="text-lg font-semibold tracking-tight">No accounts need attention</h2>
        <p className="mt-2 text-sm text-muted-foreground">
          The current queue has no matching risk records. Clear filters or review all accounts.
        </p>
      </section>
    );
  }

  return (
    <section aria-labelledby="risk-queue-title" className="space-y-4">
      <header className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <h1 id="risk-queue-title" className="text-2xl font-semibold tracking-tight">
            Accounts requiring attention
          </h1>
          <p className="mt-1 text-sm text-muted-foreground">
            Review the reason for each risk before choosing the next action.
          </p>
        </div>
        <button
          type="button"
          className="inline-flex min-h-11 items-center gap-2 rounded-md border border-border px-3 text-sm font-medium hover:bg-muted focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
        >
          <Search aria-hidden="true" className="size-4" />
          Search accounts
        </button>
      </header>

      <ul className="divide-y divide-border rounded-lg border border-border">
        {accounts.map((account, index) => (
          <li key={account.id} className="p-4 md:p-5">
            <div className="grid gap-3 md:grid-cols-[minmax(0,1.7fr)_minmax(0,1.4fr)_minmax(8rem,0.8fr)_auto] md:items-center">
              <div className="min-w-0">
                <div className="flex flex-wrap items-center gap-2">
                  <RiskLabel level={account.level} />
                  {index === 0 ? <span className="text-xs font-medium text-muted-foreground">Highest priority</span> : null}
                </div>
                <h2 className="mt-2 font-semibold">{account.name}</h2>
                <p className="mt-1 text-sm text-muted-foreground">{account.reason}</p>
              </div>

              <dl className="grid grid-cols-2 gap-3 text-sm md:grid-cols-1">
                <div>
                  <dt className="text-muted-foreground">Owner</dt>
                  <dd className="mt-0.5 font-medium">{account.owner}</dd>
                </div>
                <div>
                  <dt className="text-muted-foreground">Last activity</dt>
                  <dd className="mt-0.5 font-medium">{account.lastActivity}</dd>
                </div>
              </dl>

              <div className="text-sm">
                <div className="text-muted-foreground">Renewal</div>
                <div className="mt-0.5 font-medium">{account.renewalDate}</div>
              </div>

              <button
                type="button"
                onClick={() => onOpenAccount(account.id)}
                className="inline-flex min-h-11 items-center justify-center gap-2 self-start rounded-md bg-primary px-4 text-sm font-medium text-primary-foreground hover:opacity-90 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 md:self-center"
              >
                Open account
                <ArrowRight aria-hidden="true" className="size-4" />
              </button>
            </div>
          </li>
        ))}
      </ul>
    </section>
  );
}
```

**Implementation note:** the example demonstrates content and hierarchy, not a complete route integration. Production code should use the project's shadcn/ui Button, actual data fetching, route navigation, and separate loading/error/permission components. The sample records are illustrative and must not be mistaken for real customer data.

## Tells removed

- Generic gradient hero and generic marketing headline.
- Fake repeated growth metrics.
- Emoji feature cards.
- Uniform card-heavy layout.
- Equal emphasis for all actions.
- Missing domain-specific decision information.
- Lack of empty state and responsive intent.
- Color-only risk communication.

**After score: 0 on the listed AI-default tells**, assuming the final responsive implementation and all required states are completed and verified. This is not a claim that the sample snippet alone passes every production gate.

## The difference is decisions, not colors

The professional version does not become credible because it uses a different hue. It becomes credible because the content is ranked around a real task, risk has a concrete reason, the next action is explicit, the information density matches account triage, and the empty state explains what to do. A product-specific page contract drives these choices before visual polish begins.
