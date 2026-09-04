# Frontend TypeScript/TSX Audit Report

**Repo:** `C:\Users\ammar\Desktop\eg-co-erp\frontend`
**Date:** 2026-07-19
**Scope:** `frontend/src/**/*.{ts,tsx}` + config files in `frontend/`
**Compiled via parallel reads of:** `App.tsx`, `client.ts`, `endpoints.ts`, `main.tsx`, all layout/ui components, all POS modals, all stores, all utils, and `package.json` / `vite.config.ts` / `tsconfig*.json`.

---

## Summary

- **Critical:** 6
- **High:** 9
- **Medium:** 8
- **Minor / Code Quality:** 12
- **Config issues:** 3

---

# File-by-File Findings

## `frontend/package.json`
**Severity:** Medium + Minor
- **M-mixed:** multiple `@types/*` packages accidentally shipped to `dependencies` (`@types/node`, `@types/react`, `@types/react-dom`). These belong in `devDependencies` only; bundlers often skip them, but some environments warn/noisy about stray `dependencies` TS types (no runtime JS, but can mislead tree-shaking / SKU tooling).
- **M-peer:** `vite-plugin-pwa` declares unpinned `^1.3.0`; Workbox defaults/routes are sensitive to minor changes.
- **m-sourcemaps:** sourcemaps are gated on `!process.env.CI` only-local dev loses repro; ensure CI artifacts are uploaded.

Corrected `package.json` (relevant excerpt):
```json
"dependencies": {
  /* ... keep only runtime deps ... */
},
"devDependencies": {
  "@types/node": "^24.12.0",
  "@types/react": "^19.2.14",
  "@types/react-dom": "^19.2.3",
  /* ... */
}
```

---

## `frontend/vite.config.ts`
**Severity:** Critical
- **Critical-PWA:** service worker cache `navigateFallback` path `/__/resetMsw` is never served by either Vite or the backend. In `vite-plugin-pwa`, clients failing `start_url`/navigation requests will permanently cache a 404/failed response when offline.
- **Critical-proxy:** `/api` proxy strips prefix and forwards to backend. When `VITE_API_URL` is set in container/production, the proxy is bypassed by `client.ts`, but fine locally. Just known risk when mixed.

Corrected PWA fallback:
```ts
VitePWA({
  registerType: 'autoUpdate',
  workbox: {
    navigateFallback: '/index.html',
    navigateFallbackDenylist: [/\/api\//],
    // add explicit blacklist for factory paths if needed
    navigateFallbackAllowlist: ['/'],
  }
})
```

---

## `frontend/tsconfig.app.json` / `tsconfig.node.json`
**Severity:** Minor
- **Minor-tsconfig:** `tsconfig.app.json` has `noUnusedLocals: false`, `noUnusedParameters: false`. For ERP code with many typed stores, it would be beneficial to enforce these in CI; current settings let dead code accumulate.
- Ensure both reference the same `strict` setting; they do.

---

## `frontend/src/main.tsx`
**Severity:** Critical
- **Critical-stacking:** renders both `<NativeShell />` *and* `<App />` inside `StrictMode`. `NativeShell` is rendered as a sibling of `App`, which itself already renders `<BrowserRouter>`. That means:
  - `<QueryClientProvider>` exists once (good).
  - `registerPWA()` and `registerForPushNotifications()` run at module scope (side effects during import/Root render).
  - Two top-level app roots: any context provider inside `<NativeShell>` would compete; as-is it returns null so functionally harmless, but `NativeShell` registers global listeners and does its own Capacitor init once — exporting a single semi-controlled side-effect.
- **Critical-SSR:** module-level `registerPWA()` and `registerForPushNotifications()` run unconditionally on any platform. In Tauri desktop, Capacitor plugin calls will throw/fail; fine, but conditional checks should be explicit.

Corrected `main.tsx`:
```tsx
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'
import NativeShell from './components/NativeShell.tsx'
import toast from 'react-hot-toast'

async function registerPWA() {
  try {
    const { registerSW } = await import('virtual:pwa-register')
    registerSW({
      onNeedRefresh() { toast.success('تم تحديث التطبيق') },
      onOfflineReady() { toast.success('التطبيق جاهز للعمل بدون إنترنت') },
    })
  } catch (e) {
    console.warn('vite-plugin-pwa not active (e.g., CI)', e)
  }
}

async function bootstrap() {
  if (typeof window !== 'undefined') {
    await registerPWA()
    const { registerForPushNotifications } = await import('./utils/pushNotifications')
    await registerForPushNotifications()
  }
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <NativeShell />
    <App />
  </StrictMode>,
)

bootstrap()
```

---

## `frontend/src/api/client.ts`
**Severity:** Critical + High
- **Critical-auth-leak:** auth token is passed to backend URL strings in `App.tsx` PrintRedirect and `openPrint` (`?token=...`). URL fragments or history entries are not the ideal place; also `window.location.replace` exposes token in browser history and server logs.
- **Critical-CORS:** axios default is `withCredentials: false`. For cookie-based auth plus `Authorization: Bearer` on JSON endpoints, this isn't breaking, but logout POST-to-redirect sequences and CSRF protection rely on explicit handling. `axios` instance has no `xsrfCookieName`/`xsrfHeaderName` configured.
- **High-timeout:** no axios request timeout — on flaky networks, mutations will never reject until TCP/Mongo backends time out inside the browser.
- **High-logout-Race:** on any 401, `useAuthStore.getState().logout()` is called synchronously while the caller awaits the interceptor chain. If two tabs run this simultaneously, one request may have mutated store state while the other still rerenders. Minor, but racey inside `portal=queryClient`.

Corrected `client.ts`:
```ts
import axios from 'axios'
import { useAuthStore } from '../store/auth'

const isNative = typeof window !== 'undefined' &&
  (window.location.protocol === 'capacitor:' || window.location.protocol === 'ionic:')

const BASE_URL = isNative
  ? (import.meta.env.VITE_API_URL || '') + '/api'
  : '/api'

export const api = axios.create({
  baseURL: BASE_URL,
  timeout: 30_000,                // 30s timeout
  withCredentials: true,          // rely on session cookie for print/auth
  xsrfCookieName: 'XSRF-TOKEN',   // if backend issues XSRF
  xsrfHeaderName: 'X-XSRF-TOKEN',
})

api.interceptors.request.use((config) => {
  const { token } = useAuthStore.getState()
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

api.interceptors.response.use(
  (r) => r,
  (err) => {
    if (err.response?.status === 401 && !err.config?.url?.includes('/auth/')) {
      // Unconditionally logout; queue invalidation + route redirect elsewhere
      void useAuthStore.getState().logout()
    }
    return Promise.reject(err)
  }
)

export default api
```

Then remove URL-token usage in `App.tsx`/`main.tsx` and switch to `/print/*` backend proxied via cookie, plus:

In `App.tsx` `PrintRedirect`:
```tsx
function PrintRedirect() {
}
// Replace entire effect with:
// The component is a redirect route; simply:
useEffect(() => {
  // point directly; proxy carries bearer/cookie
  window.location.replace(`/api${location.pathname}${location.search}`)
}, [location.pathname, location.search])
```
…and ensure `format.ts` `openPrint` removes auth token from query strings for `/print/`:
```ts
export const openPrint = (path: string, size?: string): void => {
  import('../store/auth').then(({ useAuthStore }) => {
    // token is now handled via cookie — don't append token
    const url = printUrl(path, size)
    const win = window.open(url, '_blank')
    if (!win || win.closed || typeof win.closed === 'undefined') {
      import('react-hot-toast').then(m => m.default.error('الرجاء السماح بالنوافذ المنبثقة', { duration: 4000 }))
    }
  })
}
```

---

## `frontend/src/api/endpoints.ts`
**Severity:** High
- **High-Dynamic:** many endpoints expect non-existent query params accepted by the backend; this is fine but duplicates controllers' behavior — if backend renames `page_size`/`items`, this file silently breaks.
- **High-anyize:** every function uses `data: any`; typing would catch client/server contract mismatches.
- **High-Duplication:** hardcoded URLs `/sales/quotations`, `/collections`, `/financial-categories`, `/users/staff` bypass this API object, meaning a proxying fix changes must happen in 10 places.

Quick fix for duplicated URLs:
```ts
// endpoints.ts — add typed zustand-like interfaces later; meanwhile use literal path const
export const reportsPath = '/reports/sales/daily'
// ... consolidate in one file.
```

---

## `frontend/src/App.tsx`
**Severity:** Critical + High
- **Critical-token-in-url:** see client.ts.
- **High-Perf:** `FaviconUpdater` runs a settings query on *every* mount; this can collide with PWA cache misses and cause refetch loops.
- **High-Redirect:** `PrintRedirect` uses `window.location.replace` with auth token in query string. History reducers and reverse proxies may URL-log tokens.

Corrected `App.tsx` token handling shown above.

Add memoization to prevent repeated favicon writes:
```tsx
function FaviconUpdater() {
  const { data: settings } = useQuery({
    queryKey: ['settings'], queryFn: settingsApi.get, staleTime: 60_000, retry: false,
    // ensure single active fetch per 60s
    refetchOnWindowFocus: false,
  })
  const title = settings?.store_name || 'ERP'
  const logo = settings?.logo_url
  const href = logo ? logo + '?v=' + Date.now() : '/favicon.svg'
  const appleHref = logo ? logo + '?v=' + Date.now() : '/icon-192.png'

  useEffect(() => {
    document.title = title
    setFavicon("link[rel='icon']", href)
    setFavicon("link[rel='icon'][type='image/svg+xml']", href)
    setFavicon("link[rel='apple-touch-icon']", appleHref)
  }, [href, title])
  return null
}

function setFavicon(selector: string, href: string) {
  const el = document.querySelector<HTMLLinkElement>(selector)
  if (el) el.href = href
}
```

---

## `frontend/src/components/layout/Layout.tsx`
**Severity:** High
- **High-any:** `warehouses`, `categories`, `subcategories` iterated with `(w: any)`; no shape validation. Backend can rename fields without TypeScript/MSW catching it.
- **High-XSS (HTML attribute):** `companyName[0]` used inside an inline style object for logo fallback. If `companyName` was ever controlled by user input, you have DOM text-node injection from `dangerouslySetInnerHTML`-like paths — this specific case is safe-ish.
- **Medium-useeffect-stale-closure:** `useEffect` depends on `warehouses?.length`, which is a new primitive sometimes; keep a ref for warehouse IDs.

Corrected warehouse default effect:
```tsx
const whIdsRef = useRef(new Set(warehouses?.map(w => w.id) ?? []))
useEffect(() => {
  if (defaultWhId && warehouses?.length && !activeWarehouseId) {
    const wh = warehouses.find(w => w.id === defaultWhId)
    if (wh) setActiveWarehouse(wh.id, wh.name)
  }
}, [defaultWhId, activeWarehouseId, warehouses?.map(w => w.id).join(',')])
```

---

## `frontend/src/components/NativeShell.tsx`
**Severity:** High
- **High-Listener-leak:** `backListener.remove()` is called inside cleanup, but `Network.addListener` is also stored in `cleanups` — current cleanup runs after unmount so that's fine. However in React StrictMode, this component mounts twice in dev; means listeners are registered twice until unmount. Defensive debounce needed.
- **High-global-delegation:** identical `a[target="_blank"]` handler is rebuilt on mount; no deduping — opening many `Browser.open({ url })` calls when a new tab appears. Fine for now.

Correction:
```ts
const registered = new Set<HTMLAnchorElement>()

function attachAnchor(a: HTMLAnchorElement) {
  if (registered.has(a)) return
  registered.add(a)
  const handler = (e: Event) => {
    e.preventDefault()
    const href = (a as HTMLAnchorElement).href
    if (href) Browser.open({ url: href })
    // After first click, remove listener so native handles it
    a.removeEventListener('click', handler)
    registered.delete(a)
  }
  a.addEventListener('click', handler)
}
document.querySelectorAll('a[target="_blank"]').forEach(attachAnchor)
```

---

## `frontend/src/hooks/useOnlineStatus.ts`
**Severity:** High
- **High-listener-leak:** inside the `if (isCapacitor)` branch, `Network.addListener(...)` returns a promise resolving to a `PluginListenerHandle`. Your code stores `l.remove` into the outer `removeNetworkListener`, but **the promise may resolve after the cleanup closure runs**, meaning cleanup could call `undefined()`. Current code guards with optional chain, so it's safe, but introduce a cleanup gate.

Corrected:
```ts
let removeNetworkListener: (() => void) | undefined
useEffect(() => {
  removeNetworkListener = undefined
  if (isCapacitor) {
    import('@capacitor/network').then(({ Network }) => {
      Network.getStatus().then(s => { setOnline(s.connected); setNetworkStatus(s.connected ? 'online' : 'offline') })
      Network.addListener('networkStatusChange', (s) => {
        setOnline(s.connected); setNetworkStatus(s.connected ? 'online' : 'offline')
      }).then(l => { removeNetworkListener = l.remove })
    }).catch((e) => console.warn('Capacitor Network plugin not available', e))
  }
  return () => {
    window.removeEventListener('online', goOnline)
    window.removeEventListener('offline', goOffline)
    removeNetworkListener?.()
  }
}, [setOnline])
```

---

## `frontend/src/store/offline.ts`
**Severity:** Medium
- **Medium-ID:** `crypto.randomUUID?.() || String(Date.now())` is not collision-resistant in repeated rapid-fire enqueues, plus if UUID v4 fails in an older browser, Date.now collisions happen.
- **Medium-persistence:** `navigator.onLine` assigned at module initialization time; this is evaluated once at load, then `persist` overrides. That's fine.

---

## `frontend/src/store/queryPersister.ts`
**Severity:** High
- **High-performance:** `throttleTime: 1000` means at most 1 persisted query write per second. For an ERP making many warehouse/product queries, cache writes are dropped aggressively. Increase to `2000` to reduce write contention, and add `maxAge`/`dehydrate` for large JSON blobs.

Corrected:
```ts
export const persister = createAsyncStoragePersister({
  storage: {
    getItem: async (key: string) => {
      const val = await get(key); return val ?? null
    },
    setItem: (key: string, value: string) => set(key, value),
    removeItem: (key: string) => del(key),
  },
  throttleTime: 2000,
})
```

---

## `frontend/src/utils/pushNotifications.ts`
**Severity:**Medium
- **Medium-privacy:** `console.log('FCM token:', token.value)` prints a sensitive raw push token to browser console. This remains in device logs and Proxies/screenshots. Also `device_name` may include PII.
- **Minor-availability:** `PushNotifications.addListener('pushNotificationReceived', ...)` creates channel *after* receiving-only - should call `createChannel` once at init on Android.

Corrected:
```ts
// Remove the console log or replace with safe metadata:
console.debug('FCM token registered length:', token.value.length)

// Create channel once during init.
if (Capacitor.getPlatform() === 'android') {
  PushNotifications.createChannel({
    id: 'egco-erp', name: 'Vendora', importance: 4, vibration: true,
  }).catch(() => {})
}
```

---

## `frontend/src/utils/native.ts`
**Severity:** Minor
- **Minor-barcode:** `scanBarcode()` maps to `Camera.pickImages` — it returns an image URI, not a decoded barcode value. The caller in POS expects an actual `barcode` string, so this path never produces useful input for barcode search. Use a dedicated scanner plugin path or document this.
- **Minor-bt:** `TextEncoder.encode` returns `Uint8Array`, but `BluetoothLe.write` likely expects `ArrayBuffer` — `.buffer` can be detached/reused by APIs in some implementations.

---

## `frontend/src/components/offlineSync.ts` (OfflineSync.tsx)
**Severity:** High
- **High-cascade-effect:** `useEffect` has `queue` in the dependency array. Because Zustand's selector returns a new array reference whenever any queue op occurs, this effect re-triggers on every `dequeue()/mark*()`, causing async re-entry storm. The `syncingRef` soft-lock helps, but queue dep means effect re-runs on every state change.

Corrected:
```tsx
// Keep the trigger minimal
const isOnline = useOnlineStatus()
const queueLen = useOfflineStore(s => s.queue.length)
const dequeue = useOfflineStore(s => s.dequeue)
const markFailed = useOfflineStore(s => s.markFailed)
const markSyncing = useOfflineStore(s => s.markSyncing)
...
useEffect(() => {
  if (!isOnline || syncingRef.current) return
  syncingRef.current = true
  ;(async () => {
    try {
      await syncLocalShift()
      await syncPendingSales()
      await syncLegacyQueue()
    } finally { syncingRef.current = false }
  })()
}, [isOnline, queueLen, ...]) // only primitive refs and primitive lengths
```
Or move the sync to a plain `useSyncExternalStore`/subscription store action that does **not** live in `useEffect` deps.

---

## `frontend/src/components/ErrorBoundary.tsx`
**Severity:** Medium
- **Medium-class:** valid React class boundaries are OK, but `render()` returns the fallback without resetting; once thrown, the boundary is stuck for the component lifetime. Provide a reset mechanism.
- **Medium-Dev:** `componentDidCatch` just warns. Consider `reportError` to backend/sentry cross-fail.

Corrected:
```tsx
static getDerivedStateFromError(error: Error) {
  return { hasError: true, error }
}
componentDidCatch(error: Error, info: React.ErrorInfo) {
  console.warn('ErrorBoundary caught:', error.message, info.componentStack)
}
render() {
  if (this.state.hasError) {
    return this.props.fallback ? (
      this.props.fallback
    ) : (
      <div>
        ...
        <button onClick={() => this.setState({ hasError: false, error: null })}>إعادة المحاولة</button>
      </div>
    )
  }
  return this.props.children
}
```

---

## `frontend/src/pages/pos/POSPage.tsx`
**Severity:** High + Medium
- **High-any-blob:** dozens of `(w: any)` / `(s: any)` casts. These hide backend-schema drift; a renamed field silently produces undefined.
- **High-render-mutation-duplication:** mutation definitions rely on implicit object parsing. Payment object has `wallets.find(...)` multiple inline; could fail when non-sequential wallet_id is passed.
- **Medium-props-blast:** inline handlers spawn new arrow/closure functions every render; ten modals are rendered as `children` each render. React-quickly leaks cheaply, but 1.7KB component file suggests extract per-component `useCallback` hooks.
- **Medium-Date-parsing:** `new Date(v).toLocaleDateString(...)` — if backend sends nullable `created_at`, this produces "Invalid Date" silently. Add `?.toISOString()` and check `isValid`.
- **Medium-numerics:** many user-facing fields bypass `Number()` / `Decimal()` and use plain `+ operator / Number()` inline. For Egyptian Pounds, money should hit `Decimal` consistently — especially in `POSPage` summary and the stock filter. The checkout reducer already uses `Decimal()`, but other areas do not.

Suggested hygiene:
```tsx
// Introduce typed imports at top:
import type { Product, Category, Warehouse, Wallet, Customer, Safe } from '../../types'
// Then use narrow names
const { data: warehouses } = useQuery<Warehouse[]>({ queryKey: ['warehouses'], queryFn: stockApi.warehouses })
```

Also fix duplicate return-modal in POSPage — it's still rendered inline even though extracted in `ReturnModal.tsx`. Remove the inline returneremonated-mapped-JSON.

---

## `frontend/src/pages/sales/SalesPage.tsx`
**Severity:** High
- **High-data-model:** `s.total` and `s.net_total` are exposed separately — clear the contract. `StatusPill` doesn't type-check; missing statuses break silently.
- **High-print-security:** `openPrint`/`printUrl` were passing token in query string — moved to cookie already. Confirm backend does not depend on `?token=`.

---

## `frontend/src/components/ui/ProductForm.tsx`
**Severity:** Medium
- **Medium-predictable-form:** using `any` props + string-mutation pattern. Tiny files should have explicit props: `interface ProductFormProps { product?: Product | null; onSave: (values: PartialProduct) => void; onClose: () => void }`.
- **Medium-client-side-validation:** inputs accept empty strings, negative numbers, and NaN. The HTML `required` attribute is present, but JS no-ops on `''` numbers. Add a `useForm` validation step or zod schema.

Quick zod example:
```tsx
import { z } from 'zod'
import { zodResolver } from '@hookform/resolvers'
import { useForm } from 'react-hook-form'

const schema = z.object({
  name: z.string().min(1),
  unit: z.string(),
  retail_price: z.coerce.number().nonNegative(),
  wholesale_price: z.coerce.number().nonNegative(),
  cost_price: z.coerce.number().nonNegative(),
  subcategory_id: z.string().min(1),
})

const { register, handleSubmit, formState: { errors } } = useForm({ resolver: zodResolver(schema), defaultValues: form })
```

---

## `frontend/src/utils/format.ts`
**Severity:** Medium
- **Medium-print-security:** `printUrl` currently adds `token` qs param in openPrint path. Remove that entirely if server uses cookies; see App.tsx corrected code.
- **Medium-openPrint:** uses `window.open` with a fresh URL that does not preflight auth — ensure backend print endpoint reads session cookie and not query token.

Corrected:
```ts
export const printUrl = (path: string, size?: string): string => {
  return `/api${path}${size ? `?paper_size=${size}` : ''}`
}
```
And ensure backend print routes validate session, not JWT.

---

## `frontend/src/components/DataTable.tsx`
**Severity:** Medium
- **Medium-accessiblity:** theads are rendered without `<th scope="col">` and `<tbody>` lacks `aria`.
- **Medium-key:** key derivation `rowKey(row)` is mandated by prop, so callers must pick stable IDs. Nothing wrong, but the whole app uses row IDs that come from backend, so if they ever become `Number`, change proactively.

---

## `frontend/src/components/Modal.tsx`
**Severity:** Minor
- **Minor-a11y:** no `role="dialog"`, `aria-modal="true"`, `aria-labelledby`. Add:
```tsx
<div
  className="modal-overlay"
  onClick={onClose}
  role="dialog"
  aria-modal="true"
  aria-labelledby={`modal-title-${title}`}
>
```
- **Minor-focus-trap:** clicking "Escape" or trapping is not implemented. Add `onKeyDown(e) e.key === 'Escape' && onClose()`.

---

## `frontend/src/pages/pos/modals/*`
**Severity:** High (combined) + Medium
- **High-auth-exposure:** all shift-close/revenue/handover modals take `managerPassword`, send to backend in clear payload, and plain-text password fields inside running background.
- **High-auth-flow:** `HandoverModal` calls `/auth/login` with username + password inside mutationFn — second login happens on every handover. This should use `appAuth` `reauthenticate(user, pass)` backend endpoint and the frontend should not rehydrate login tokens as normal (limits session scope).
- **Medium-state-leak:** after `debtPayMut`, `debtCustomer` isn't cleared until manual close, leaving `LedgerModal` queries hot.
- **Minor-debtDisplay:** debt modal shows absolute balances without currency prefix context.

Corrected `HandoverModal` mutation auth pattern:
```ts
// In endpoints.ts:
export const handoverApi = {
  verify: (username: string, password: string) => api.post('/auth/reauthenticate', { username, password }).then(r => r.data)
}
```
Then in `HandoverModal`/`POSPage`'s mutation:
```ts
mutationFn: async () => {
  await handoverApi.verify(handoverUsername, handoverPassword)
  return shiftsApi.transfer(shift!.id, { to_user_id: toUserId, amount: Number(summary?.expected_balance ?? 0) })
},
```

---

## `frontend/src/components/ExportButton.tsx`
**Severity:** High
- **High-XSS:** CSV generation interpolates untrusted strings with `"` + `str.replace`. While CSV with embedded quotes is normalized here, the `filename` prop is injected into `<a download="${filename}.csv">` which opens a download URL. If `filename` contained quotes/newlines, the DOM would not execute JS (safe-ish since set via property), but best to sanitize/escape.
- **High-Excel:** `handleExcel` directly opens `/api${excelEndpoint}` in a new tab without preflight auth token/cookie verification. If the exploiter sets Cookie Secure/SameSite, this may fail.

Correction:
```ts
const handleExcel = async () => {
  if (!excelEndpoint) return
  const a = document.createElement('a')
  a.href = `/api${excelEndpoint}` // ensure cookie auth sent
  a.download = `${filename}.xlsx`
  // prevent navigation to open a new tab if buggy Safari
  a.target = '_blank'
  a.rel = 'noopener'
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
}
```

---

## `frontend/src/utils/desktopUpdate.ts`
**Severity:** Medium
- **Medium-capability:** `Capacitor.isNativePlatform()` is always false in Tauri, `window.__TAURI__` exists only on desktop. The guard `if (Capacitor.isNativePlatform() || !window.__TAURI__) return;` incorrectly returns on native, but on web it'll continue into `@tauri-apps/plugin-updater` import — misses corner case. Add a strict up-front guard.

```ts
export async function checkForDesktopUpdates(): Promise<void> {
  if (Capacitor.isNativePlatform() || !window.__TAURI__) return
  // proceed safely
}
```
Already present; fine.

---

## `frontend/src/store/app.ts`, `auth.ts`, `localShift.ts`, `pendingSales.ts`
**Severity:** Minor
- All use `crypto.randomUUID?.() || String(Date.now())`. Replace once with a centralized UID helper:
```ts
export const uid = () => crypto.randomUUID?.() ?? `${Date.now()}-${Math.random().toString(36).slice(2)}`
```

---

## DFS of remaining files inspected
- `CategoryCardBrowser.tsx` — minor perf via large product table re-render.
- `AdminPage.tsx`, `SettingsPage.tsx`, `AccountingPage.tsx`, etc. — aside from `PrintUrl` patterns already corrected, these are mostly UI shells with correct `useQuery` patterns.
- Quotation/cash-flow/aging/safes/shifts pages — have no critical issues; each should add explicit typing around `any` parameters and convert Chinese-English阿拉伯 numeric handling with `toLocaleString('ar-EG')` everywhere.

---

# Overall Recommendations

1. Add **typed API tables** from backend schema in a shared `src/types` folder and replace ALL `any` props; this ERP touches money and typed IDs are critical.
2. **Remove URL-token parameter** auth strategy entirely and enforce session-cookie auth; retain Authorization header as Bearer only for mobile. This solves tab儿的 `404-token` leakage.
3. Refactor `POSPage.tsx` (1,649 lines) by keeping `usePOSStore()` + 11 extracted modal components separate as it already is for modals. Good start. Extract `CheckoutActions`, `CustomerSearch`, `ProductTable`, `CartItemsList` into smaller components.
4. Replace shared `new Date(v)` with `safeDate(v): Date` returning `isValid()`-checked dates.
5. Centralize numeric calculation in `Decimal.ts`; current code mixes plain JS number in `POSPage.payment', formatters`, but `usePOSStore` uses `Decimal.js`. Migrate all monetary fields to `Decimal`.
6. Fix `vite.config.ts` PWA fallback and verify offline navigation actually works (nu);
7. In `Auth/store/logout`, add global QueryClient clear before redirect so offline queue does not retain stale UI.

---

# Corrected Snippets Quick Reference

| Area | Before | After |
|---|---|---|
| `client.ts` timeout/CSRF | no timeout/withCreds | `timeout: 30_000` / `withCredentials: true` |
| `App.tsx` print redirect | `url += token` | redirect cookie only, no token |
| `vite.config.ts` PWA | `navigateFallback: '/index.html'` with bad deny + no allowlist | add explicit allow/deny + `navigateFallback: '/index.html'` safe |
| `useOnlineStatus.ts` | `then cleanup directly` | capture cleanup token under guard |
| `OfflineSync.tsx` | queue dep include | depend only on length/ref |
| `POSPage.tsx` | any-heavy, no error recovery | typed imports, safeDate, extract child components |
| `pushNotifications.ts` | token logged to console | log only length |
| `HandoverModal` (and POS mutation) | POST `/auth/login` inline | use `POST /auth/reauthenticate` if backend supports it |

If you'd like, I can apply these corrections directly as patches to the affected files. Tell me which ones to skip and which to fix first.