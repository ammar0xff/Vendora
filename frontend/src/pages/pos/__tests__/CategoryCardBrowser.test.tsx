/**
 * Test suite for CategoryCardBrowser.tsx
 *
 * Requirements covered: 4.1, 4.2 (scaffold), 4.3–4.5, 5.1–5.5,
 *   6.1, 6.4, 7.1–7.3, 8.2, 9.1–9.2, 10.1–10.2
 *
 * NOTE: Before running these tests, install testing deps from the frontend/ directory:
 *   npm install -D @testing-library/react @testing-library/user-event
 */

import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen } from '@testing-library/react'
// userEvent is imported here for use by subsequent test tasks (4.4 onward)
import userEvent from '@testing-library/user-event'
import CategoryCardBrowser from '../CategoryCardBrowser'

// ---------------------------------------------------------------------------
// Helpers — data factories
// ---------------------------------------------------------------------------

/** Create a minimal Category object */
export function makeCat(id: string, name: string) {
  return { id, name }
}

/** Create a minimal Subcategory object */
export function makeSub(id: string, catId: string, name: string) {
  return { id, category_id: catId, name }
}

/**
 * Create a minimal Product object.
 * Defaults: wholesale_price = retail_price, cost_price = 0, unit = 'piece'.
 */
export function makeProd(
  id: string,
  subId: string,
  name: string,
  retail_price: number,
  stock_status: 'untracked' | 'tracked' = 'untracked',
) {
  return {
    id,
    subcategory_id: subId,
    name,
    retail_price,
    wholesale_price: retail_price,
    cost_price: 0,
    stock_status,
    unit: 'piece',
    company: undefined as string | undefined,
    shelf_number: undefined as string | undefined,
  }
}

// ---------------------------------------------------------------------------
// Fixed test data (used by most tests)
// ---------------------------------------------------------------------------

const CAT_A = makeCat('cat-a', 'فئة أ')
const CAT_B = makeCat('cat-b', 'فئة ب')

const SUB_A1 = makeSub('sub-a1', 'cat-a', 'فرعي أ1')
const SUB_A2 = makeSub('sub-a2', 'cat-a', 'فرعي أ2')
const SUB_A3 = makeSub('sub-a3', 'cat-a', 'فرعي أ3')
const SUB_B1 = makeSub('sub-b1', 'cat-b', 'فرعي ب1')
const SUB_B2 = makeSub('sub-b2', 'cat-b', 'فرعي ب2')

const PROD_1 = makeProd('prod-1', 'sub-a1', 'منتج 1', 100, 'untracked')
const PROD_2 = makeProd('prod-2', 'sub-a1', 'منتج 2', 200, 'untracked')
const PROD_3 = makeProd('prod-3', 'sub-a1', 'منتج 3', 300, 'untracked')

// An empty stock map — no tracked quantities; products default to untracked display
const EMPTY_STOCK_MAP: Record<string, number> = {}

// ---------------------------------------------------------------------------
// Mock @tanstack/react-query
//
// `useQuery` is mocked globally. Individual tests can override the mock by
// calling `mockUseQuery(...)` with a function that returns different data
// based on the queryKey.
// ---------------------------------------------------------------------------

type QueryResult = {
  data: unknown
  isLoading?: boolean
  isError?: boolean
}

/** Current useQuery implementation — tests replace this per-scenario. */
let _useQueryImpl: (opts: { queryKey: unknown[] }) => QueryResult

function mockUseQuery(impl: (opts: { queryKey: unknown[] }) => QueryResult) {
  _useQueryImpl = impl
}

vi.mock('@tanstack/react-query', () => ({
  useQuery: (opts: { queryKey: unknown[] }) => _useQueryImpl(opts),
}))

// ---------------------------------------------------------------------------
// Default useQuery implementation — returns fixed categories, subcategories,
// and an empty products list. Tests that drill into products override this.
// ---------------------------------------------------------------------------

function defaultUseQuery(opts: { queryKey: unknown[] }): QueryResult {
  const [key] = opts.queryKey as string[]

  if (key === 'categories') {
    return { data: [CAT_A, CAT_B] }
  }
  if (key === 'subcategories') {
    return { data: [SUB_A1, SUB_A2, SUB_A3, SUB_B1, SUB_B2] }
  }
  if (key === 'card-products') {
    return { data: [] }
  }
  if (key === 'card-stock') {
    return { data: EMPTY_STOCK_MAP }
  }
  return { data: undefined }
}

// ---------------------------------------------------------------------------
// Test setup
// ---------------------------------------------------------------------------

beforeEach(() => {
  // Reset to the default mock before each test so tests are isolated
  mockUseQuery(defaultUseQuery)
})

// ---------------------------------------------------------------------------
// Render helper — wraps render() with required props
// ---------------------------------------------------------------------------

interface RenderOptions {
  warehouseId?: string
  mode?: 'retail' | 'wholesale'
  onAddProduct?: ReturnType<typeof vi.fn>
}

function renderBrowser(opts: RenderOptions = {}) {
  const onAddProduct = opts.onAddProduct ?? vi.fn()
  render(
    <CategoryCardBrowser
      warehouseId={opts.warehouseId ?? 'wh1'}
      mode={opts.mode ?? 'retail'}
      onAddProduct={onAddProduct}
    />,
  )
  return { onAddProduct }
}

// ---------------------------------------------------------------------------
// Exported for use by subsequent test tasks (4.2–4.12)
// ---------------------------------------------------------------------------

export {
  mockUseQuery,
  defaultUseQuery,
  renderBrowser,
  userEvent,
  CAT_A,
  CAT_B,
  SUB_A1,
  SUB_A2,
  SUB_A3,
  SUB_B1,
  SUB_B2,
  PROD_1,
  PROD_2,
  PROD_3,
  EMPTY_STOCK_MAP,
}

// ---------------------------------------------------------------------------
// Smoke test — ensures the scaffold itself is valid and the mocks work
// ---------------------------------------------------------------------------

describe('CategoryCardBrowser — scaffold smoke test', () => {
  it('renders without crashing at root level', () => {
    renderBrowser()
    // At root level the categories grid should be in the DOM.
    // Both category names come from CAT_A and CAT_B.
    expect(screen.getByText('فئة أ')).toBeTruthy()
    expect(screen.getByText('فئة ب')).toBeTruthy()
  })
})

// ---------------------------------------------------------------------------
// Property 2: Category Grid Renders All Categories — Validates: Requirements 4.3, 4.4, 4.5
// ---------------------------------------------------------------------------

describe('Level 1 — root category grid', () => {
  it('renders 0 category cards when API returns empty array', () => {
    mockUseQuery((opts) => {
      const [key] = opts.queryKey as string[]
      if (key === 'categories') return { data: [] }
      if (key === 'subcategories') return { data: [] }
      return { data: undefined }
    })

    renderBrowser()

    // With 0 categories, neither CAT_A nor CAT_B names should appear
    expect(screen.queryByText('فئة أ')).toBeNull()
    expect(screen.queryByText('فئة ب')).toBeNull()

    // No buttons with category-card styling should be present (no role=button children)
    // The grid renders buttons only when categories?.map(...) produces items
    const buttons = document.querySelectorAll('button')
    expect(buttons.length).toBe(0)
  })

  it('renders 1 category card when API returns 1 category', () => {
    const singleCat = makeCat('cat-single', 'الفئة الوحيدة')

    mockUseQuery((opts) => {
      const [key] = opts.queryKey as string[]
      if (key === 'categories') return { data: [singleCat] }
      if (key === 'subcategories') return { data: [] }
      return { data: undefined }
    })

    renderBrowser()

    // Exactly 1 category card should appear
    expect(screen.getByText('الفئة الوحيدة')).toBeTruthy()

    const buttons = document.querySelectorAll('button')
    expect(buttons.length).toBe(1)
  })

  it('renders 5 category cards when API returns 5 categories', () => {
    const fiveCategories = [
      makeCat('cat-1', 'فئة 1'),
      makeCat('cat-2', 'فئة 2'),
      makeCat('cat-3', 'فئة 3'),
      makeCat('cat-4', 'فئة 4'),
      makeCat('cat-5', 'فئة 5'),
    ]

    mockUseQuery((opts) => {
      const [key] = opts.queryKey as string[]
      if (key === 'categories') return { data: fiveCategories }
      if (key === 'subcategories') return { data: [] }
      return { data: undefined }
    })

    renderBrowser()

    // All 5 category names should be present
    for (const cat of fiveCategories) {
      expect(screen.getByText(cat.name)).toBeTruthy()
    }

    // Exactly 5 buttons (one per category card)
    const buttons = document.querySelectorAll('button')
    expect(buttons.length).toBe(5)
  })
})

// ---------------------------------------------------------------------------
// Property 3: Subcategory Drill-Down Shows Correct Children — Validates: Requirements 5.1, 5.2
// ---------------------------------------------------------------------------

describe('Level 2 — subcategory drill-down', () => {
  it('shows only subcategories of clicked category (category A → 3 subs)', async () => {
    // defaultUseQuery already returns CAT_A (3 subs) and CAT_B (2 subs)
    renderBrowser()

    // Click category A's button
    await userEvent.click(screen.getByText('فئة أ'))

    // Exactly 3 subcategory cards should be rendered
    expect(screen.getByText('فرعي أ1')).toBeTruthy()
    expect(screen.getByText('فرعي أ2')).toBeTruthy()
    expect(screen.getByText('فرعي أ3')).toBeTruthy()

    // None of category B's subcategories should appear
    expect(screen.queryByText('فرعي ب1')).toBeNull()
    expect(screen.queryByText('فرعي ب2')).toBeNull()

    // Confirm exactly 3 subcategory name elements are visible (count via role)
    const subcatButtons = screen.getAllByRole('button', { name: /فرعي أ/ })
    expect(subcatButtons).toHaveLength(3)
  })

  it('shows breadcrumb with category name and back button after drill-down', async () => {
    renderBrowser()

    // Click category A's button
    await userEvent.click(screen.getByText('فئة أ'))

    // BreadcrumbNav should show category A's name as a span
    // In CategoryCardBrowser.tsx the selected cat name renders as:
    //   <span className="text-xs font-bold text-slate-800">{selectedCat?.name}</span>
    const breadcrumbSpan = screen.getByText('فئة أ', {
      selector: 'span.text-xs.font-bold.text-slate-800',
    })
    expect(breadcrumbSpan).toBeTruthy()

    // BackButton labeled "رجوع" must be present
    const backButton = screen.getByRole('button', { name: /رجوع/ })
    expect(backButton).toBeTruthy()
  })
})

// ---------------------------------------------------------------------------
// Property 11: Back Navigation Clears Correct State Level — Validates: Requirements 7.2, 7.3
// ---------------------------------------------------------------------------

describe('Back navigation Level 2 → Level 1', () => {
  it('clicking back from subcategory view returns to root category grid', async () => {
    const user = userEvent.setup()
    renderBrowser()

    // Verify we start at root — both category cards visible
    expect(screen.getByText('فئة أ')).toBeTruthy()
    expect(screen.getByText('فئة ب')).toBeTruthy()

    // No back button at root level
    expect(screen.queryByText('رجوع')).toBeNull()

    // Click category A to drill into Level 2 (subcategory view)
    await user.click(screen.getByText('فئة أ'))

    // Now at Level 2 — subcategories of CAT_A should be visible
    expect(screen.getByText('فرعي أ1')).toBeTruthy()
    expect(screen.getByText('فرعي أ2')).toBeTruthy()
    expect(screen.getByText('فرعي أ3')).toBeTruthy()

    // Back button should be present at Level 2
    const backButton = screen.getByText('رجوع')
    expect(backButton).toBeTruthy()

    // Click the back button to return to Level 1
    await user.click(backButton)

    // Should be back at root — category grid visible again
    expect(screen.getByText('فئة أ')).toBeTruthy()
    expect(screen.getByText('فئة ب')).toBeTruthy()

    // Subcategory cards should no longer be visible
    expect(screen.queryByText('فرعي أ1')).toBeNull()
    expect(screen.queryByText('فرعي أ2')).toBeNull()
    expect(screen.queryByText('فرعي أ3')).toBeNull()

    // Back button should be gone (back at root, selectedCatId cleared)
    expect(screen.queryByText('رجوع')).toBeNull()
  })

  it('back button is not visible at root level', async () => {
    renderBrowser()

    // At root level, back button must not be rendered (Requirement 7.3)
    expect(screen.queryByText('رجوع')).toBeNull()

    // Both top-level category cards are shown
    expect(screen.getByText('فئة أ')).toBeTruthy()
    expect(screen.getByText('فئة ب')).toBeTruthy()
  })
})

// Property 5: Empty-Subcategory Category Jumps to Products — Validates: Requirements 5.4, 5.5
describe('Empty subcategory category — jumps directly to products', () => {
  it('clicking a category with no subcategories shows product grid directly', async () => {
    const CAT_EMPTY = makeCat('cat-empty', 'فئة بلا أقسام')
    const PROD_E1 = makeProd('prod-e1', '__all__', 'منتج إي 1', 50)
    const PROD_E2 = makeProd('prod-e2', '__all__', 'منتج إي 2', 75)

    mockUseQuery((opts) => {
      const [key] = opts.queryKey as string[]

      if (key === 'categories') return { data: [CAT_EMPTY] }
      // No subcategories for this category
      if (key === 'subcategories') return { data: [] }
      // Products query is keyed ['card-products', selectedSubId]
      if (key === 'card-products') return { data: [PROD_E1, PROD_E2] }
      if (key === 'card-stock') return { data: EMPTY_STOCK_MAP }
      return { data: undefined }
    })

    renderBrowser()

    // Level 1: category card should be visible
    expect(screen.getByText('فئة بلا أقسام')).toBeTruthy()

    // Click the category — it has 0 subcategories so handleCatClick sets selectedSubId = '__all__'
    await userEvent.click(screen.getByText('فئة بلا أقسام'))

    // Level 3 should be shown directly — product cards must appear (no subcategory grid)
    expect(screen.getByText('منتج إي 1')).toBeTruthy()
    expect(screen.getByText('منتج إي 2')).toBeTruthy()

    // Subcategory grid must NOT be shown (no subcategory names rendered as buttons)
    expect(screen.queryByRole('button', { name: /فرعي/ })).toBeNull()

    // Breadcrumb shows category name
    // In Level 3 breadcrumb: <span className="text-xs font-bold text-slate-600">{selectedCat?.name}</span>
    const catBreadcrumb = screen.getByText('فئة بلا أقسام', {
      selector: 'span.text-xs.font-bold.text-slate-600',
    })
    expect(catBreadcrumb).toBeTruthy()

    // Breadcrumb subcategory slot shows "الكل" because selectedSub is undefined
    expect(screen.getByText('الكل')).toBeTruthy()

    // Back button is present
    expect(screen.getByRole('button', { name: /رجوع/ })).toBeTruthy()
  })
})

// Property 6: Product Cards Scoped to Subcategory — Validates: Requirements 6.1
// Property 8: onAddProduct Invoked with Correct Product — Validates: Requirements 6.4, 8.2
describe('Level 3 — product cards and onAddProduct', () => {
  const CAT_L3 = makeCat('cat-l3', 'فئة المستوى 3')
  const SUB_L3 = makeSub('sub-l3', 'cat-l3', 'فرعي المستوى 3')
  const PROD_L3_1 = makeProd('prod-l3-1', 'sub-l3', 'منتج ل3 أول', 10, 'untracked')
  const PROD_L3_2 = makeProd('prod-l3-2', 'sub-l3', 'منتج ل3 ثاني', 20, 'untracked')
  const PROD_L3_3 = makeProd('prod-l3-3', 'sub-l3', 'منتج ل3 ثالث', 30, 'untracked')

  function setupL3Query() {
    mockUseQuery((opts) => {
      const [key] = opts.queryKey as string[]
      if (key === 'categories') return { data: [CAT_L3] }
      if (key === 'subcategories') return { data: [SUB_L3] }
      if (key === 'card-products') return { data: [PROD_L3_1, PROD_L3_2, PROD_L3_3] }
      if (key === 'card-stock') return { data: EMPTY_STOCK_MAP }
      return { data: undefined }
    })
  }

  it('drilling into subcategory shows exactly 3 product cards', async () => {
    setupL3Query()
    renderBrowser()

    // Level 1 → click category
    await userEvent.click(screen.getByText('فئة المستوى 3'))

    // Level 2 → click subcategory
    await userEvent.click(screen.getByText('فرعي المستوى 3'))

    // Level 3 → all 3 product cards must be visible
    expect(screen.getByText('منتج ل3 أول')).toBeTruthy()
    expect(screen.getByText('منتج ل3 ثاني')).toBeTruthy()
    expect(screen.getByText('منتج ل3 ثالث')).toBeTruthy()

    // Exactly 3 product-level buttons (back button + 3 products = 4 total buttons;
    // use text content to count only product cards)
    const productButtons = screen
      .getAllByRole('button')
      .filter((btn) => btn.textContent?.includes('منتج ل3'))
    expect(productButtons).toHaveLength(3)

    // Untracked products must NOT show a stock badge (qty is null)
    expect(screen.queryByText('0')).toBeNull()
  })

  it('clicking a product card calls onAddProduct with the correct product object', async () => {
    setupL3Query()
    const onAddProduct = vi.fn()
    renderBrowser({ onAddProduct })

    // Drill: Level 1 → Level 2 → Level 3
    await userEvent.click(screen.getByText('فئة المستوى 3'))
    await userEvent.click(screen.getByText('فرعي المستوى 3'))

    // Click the first product card
    const firstProductBtn = screen
      .getAllByRole('button')
      .find((btn) => btn.textContent?.includes('منتج ل3 أول'))!
    await userEvent.click(firstProductBtn)

    // onAddProduct must have been called exactly once with the exact product object
    expect(onAddProduct).toHaveBeenCalledTimes(1)
    expect(onAddProduct).toHaveBeenCalledWith(PROD_L3_1)
  })
})

// Property 11: Back Navigation Clears Correct State Level — Validates: Requirements 7.1
describe('Back navigation Level 3 → Level 2', () => {
  it('pressing back from product level returns to subcategory grid', async () => {
    const user = userEvent.setup()

    // Override 'card-products' to return real products so Level 3 is reached
    mockUseQuery((opts) => {
      const [key] = opts.queryKey as string[]
      if (key === 'categories') return { data: [CAT_A, CAT_B] }
      if (key === 'subcategories') return { data: [SUB_A1, SUB_A2, SUB_A3, SUB_B1, SUB_B2] }
      if (key === 'card-products') return { data: [PROD_1, PROD_2, PROD_3] }
      if (key === 'card-stock') return { data: EMPTY_STOCK_MAP }
      return { data: undefined }
    })

    renderBrowser()

    // ── Level 1 ─────────────────────────────────────────────────────────────
    // Root category grid is visible; no back button yet
    expect(screen.getByText('فئة أ')).toBeTruthy()
    expect(screen.queryByText('رجوع')).toBeNull()

    // ── Level 1 → Level 2 ───────────────────────────────────────────────────
    // Click category A → subcategory grid appears
    await user.click(screen.getByText('فئة أ'))

    expect(screen.getByText('فرعي أ1')).toBeTruthy()
    expect(screen.getByText('فرعي أ2')).toBeTruthy()
    expect(screen.getByText('فرعي أ3')).toBeTruthy()

    // ── Level 2 → Level 3 ───────────────────────────────────────────────────
    // Click subcategory A1 → product grid appears
    await user.click(screen.getByText('فرعي أ1'))

    // Products are visible at Level 3
    expect(screen.getByText('منتج 1')).toBeTruthy()
    expect(screen.getByText('منتج 2')).toBeTruthy()
    expect(screen.getByText('منتج 3')).toBeTruthy()

    // Subcategory buttons are gone
    expect(screen.queryByText('فرعي أ1')).toBeNull()
    expect(screen.queryByText('فرعي أ2')).toBeNull()
    expect(screen.queryByText('فرعي أ3')).toBeNull()

    // Level 3 breadcrumb shows category name in the first breadcrumb slot
    // <span className="text-xs font-bold text-slate-600">{selectedCat?.name}</span>
    const catBreadcrumb = screen.getByText('فئة أ', {
      selector: 'span.text-xs.font-bold.text-slate-600',
    })
    expect(catBreadcrumb).toBeTruthy()

    // Back button is present at Level 3
    expect(screen.getByRole('button', { name: /رجوع/ })).toBeTruthy()

    // ── Level 3 → Level 2 (the key assertion) ───────────────────────────────
    await user.click(screen.getByRole('button', { name: /رجوع/ }))

    // Products must be gone — we are back at Level 2
    expect(screen.queryByText('منتج 1')).toBeNull()
    expect(screen.queryByText('منتج 2')).toBeNull()
    expect(screen.queryByText('منتج 3')).toBeNull()

    // Subcategory grid is visible again (Level 2, not root)
    expect(screen.getByText('فرعي أ1')).toBeTruthy()
    expect(screen.getByText('فرعي أ2')).toBeTruthy()
    expect(screen.getByText('فرعي أ3')).toBeTruthy()

    // Root categories must NOT be in a category-card button at this level
    // (CAT_A appears only in the breadcrumb span, not as a category grid button)
    expect(screen.queryByRole('button', { name: 'فئة أ' })).toBeNull()
    expect(screen.queryByRole('button', { name: 'فئة ب' })).toBeNull()

    // Level 2 breadcrumb still shows category name
    // <span className="text-xs font-bold text-slate-800">{selectedCat?.name}</span>
    const breadcrumbAtLevel2 = screen.getByText('فئة أ', {
      selector: 'span.text-xs.font-bold.text-slate-800',
    })
    expect(breadcrumbAtLevel2).toBeTruthy()

    // Back button is still present (can go back to Level 1)
    expect(screen.getByRole('button', { name: /رجوع/ })).toBeTruthy()
  })
})

// Property 10: Stock Filter Excludes Zero-Qty Tracked Products — Validates: Requirements 10.1, 10.2
describe('Stock filter — zero-qty tracked products hidden', () => {
  const CAT_STOCK = makeCat('cat-stock', 'فئة المخزون')
  const SUB_STOCK = makeSub('sub-stock', 'cat-stock', 'فرعي المخزون')

  const prod_tracked_zero = makeProd('prod-tracked-zero', 'sub-stock', 'منتج متتبع صفر', 50, 'tracked')
  const prod_tracked_three = makeProd('prod-tracked-three', 'sub-stock', 'منتج متتبع ثلاثة', 60, 'tracked')
  const prod_untracked = makeProd('prod-untracked', 'sub-stock', 'منتج غير متتبع', 70, 'untracked')

  it('hides tracked zero-qty product, shows tracked 3-qty and untracked zero-qty', async () => {
    mockUseQuery((opts) => {
      const [key] = opts.queryKey as string[]

      if (key === 'categories') return { data: [CAT_STOCK] }
      if (key === 'subcategories') return { data: [SUB_STOCK] }
      if (key === 'card-products') {
        return { data: [prod_tracked_zero, prod_tracked_three, prod_untracked] }
      }
      if (key === 'card-stock') {
        return {
          data: {
            [prod_tracked_zero.id]: 0,
            [prod_tracked_three.id]: 3,
          },
        }
      }
      return { data: undefined }
    })

    renderBrowser()

    // Level 1 → click category
    await userEvent.click(screen.getByText('فئة المخزون'))

    // Level 2 → click subcategory
    await userEvent.click(screen.getByText('فرعي المخزون'))

    // Level 3: only 2 product cards should be rendered (tracked-zero is filtered out)
    expect(screen.queryByText('منتج متتبع صفر')).toBeNull()
    expect(screen.getByText('منتج متتبع ثلاثة')).toBeTruthy()
    expect(screen.getByText('منتج غير متتبع')).toBeTruthy()

    // Exactly 2 product buttons (back button excluded by filtering on product name text)
    const productButtons = screen
      .getAllByRole('button')
      .filter(
        (btn) =>
          btn.textContent?.includes('منتج متتبع ثلاثة') ||
          btn.textContent?.includes('منتج غير متتبع') ||
          btn.textContent?.includes('منتج متتبع صفر'),
      )
    expect(productButtons).toHaveLength(2)
  })
})

// Property 9: Price Respects Sale Mode — Validates: Requirements 9.1, 9.2
describe('Price display — respects mode prop', () => {
  const CAT_PRICE = makeCat('cat-price', 'فئة الأسعار')
  const SUB_PRICE = makeSub('sub-price', 'cat-price', 'فرعي الأسعار')

  // Product with distinct retail and wholesale prices
  const PROD_PRICE = {
    id: 'prod-price-1',
    subcategory_id: 'sub-price',
    name: 'منتج الأسعار',
    retail_price: 100,
    wholesale_price: 75,
    cost_price: 0,
    stock_status: 'untracked' as const,
    unit: 'piece',
    company: undefined as string | undefined,
    shelf_number: undefined as string | undefined,
  }

  // Product with wholesale_price = 0 (fallback to retail)
  const PROD_ZERO_WHOLESALE = {
    id: 'prod-price-2',
    subcategory_id: 'sub-price',
    name: 'منتج بدون جملة',
    retail_price: 200,
    wholesale_price: 0,
    cost_price: 0,
    stock_status: 'untracked' as const,
    unit: 'piece',
    company: undefined as string | undefined,
    shelf_number: undefined as string | undefined,
  }

  function setupPriceQuery(product: typeof PROD_PRICE | typeof PROD_ZERO_WHOLESALE) {
    mockUseQuery((opts) => {
      const [key] = opts.queryKey as string[]
      if (key === 'categories') return { data: [CAT_PRICE] }
      if (key === 'subcategories') return { data: [SUB_PRICE] }
      if (key === 'card-products') return { data: [product] }
      if (key === 'card-stock') return { data: EMPTY_STOCK_MAP }
      return { data: undefined }
    })
  }

  it('shows retail_price when mode is retail', async () => {
    setupPriceQuery(PROD_PRICE)
    renderBrowser({ mode: 'retail' })

    // Drill: category → subcategory → products
    await userEvent.click(screen.getByText('فئة الأسعار'))
    await userEvent.click(screen.getByText('فرعي الأسعار'))

    // retail_price = 100 → rendered as ar-EG locale string + ج.م
    const expectedPrice = (100).toLocaleString('ar-EG')
    expect(screen.getByText((content) => content.includes(expectedPrice) && content.includes('ج.م'))).toBeTruthy()

    // wholesale_price = 75 should NOT appear
    const unexpectedPrice = (75).toLocaleString('ar-EG')
    const priceEl = screen.queryByText((content) => content.includes(unexpectedPrice) && content.includes('ج.م'))
    expect(priceEl).toBeNull()
  })

  it('shows wholesale_price when mode is wholesale', async () => {
    setupPriceQuery(PROD_PRICE)
    renderBrowser({ mode: 'wholesale' })

    // Drill: category → subcategory → products
    await userEvent.click(screen.getByText('فئة الأسعار'))
    await userEvent.click(screen.getByText('فرعي الأسعار'))

    // wholesale_price = 75 → rendered as ar-EG locale string + ج.م
    const expectedPrice = (75).toLocaleString('ar-EG')
    expect(screen.getByText((content) => content.includes(expectedPrice) && content.includes('ج.م'))).toBeTruthy()

    // retail_price = 100 should NOT appear as a price (it would only show if fallback kicked in)
    const unexpectedPrice = (100).toLocaleString('ar-EG')
    const priceEl = screen.queryByText((content) => content.includes(unexpectedPrice) && content.includes('ج.م'))
    expect(priceEl).toBeNull()
  })

  it('falls back to retail_price when wholesale_price is 0 and mode is wholesale', async () => {
    setupPriceQuery(PROD_ZERO_WHOLESALE)
    renderBrowser({ mode: 'wholesale' })

    // Drill: category → subcategory → products
    await userEvent.click(screen.getByText('فئة الأسعار'))
    await userEvent.click(screen.getByText('فرعي الأسعار'))

    // wholesale_price = 0 → falsy → falls back to retail_price = 200
    const expectedPrice = (200).toLocaleString('ar-EG')
    expect(screen.getByText((content) => content.includes(expectedPrice) && content.includes('ج.م'))).toBeTruthy()
  })
})
