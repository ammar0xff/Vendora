# Implementation Plan: cashier-product-view

## Overview

Two focused changes: update the icon-only toggle buttons in `POSPage.tsx` (desktop + mobile) to show text labels, and write tests covering the toggle behavior and `CategoryCardBrowser` drill-down logic. No backend changes and no changes to `CategoryCardBrowser.tsx` itself.

## Tasks

- [x] 1. Update desktop toggle button in POSPage.tsx
  - [x] 1.1 Replace icon-only desktop toggle button with labeled button
    - In `frontend/src/pages/pos/POSPage.tsx`, find the desktop `<button>` at line ~937 that renders `{viewMode === 'table' ? <LayoutGrid size={16} /> : <List size={16} />}` with only `title` text
    - Change the button content so it renders `<LayoutGrid size={14} /> عرض الفئات` when `viewMode === 'table'` and `<List size={14} /> عرض الجدول` when `viewMode === 'cards'`
    - Keep the existing `onClick`, `className`, and `flex items-center gap-1.5` — just remove the `title` attribute and add the text label alongside the icon
    - _Requirements: 2.1, 2.2, 2.5_

  - [ ]* 1.2 Write unit tests for the desktop toggle button label
    - Create `frontend/src/pages/pos/__tests__/POSPageToggle.test.tsx`
    - Use `vitest` + `@testing-library/react` — no `@testing-library/react` is installed yet; add it as a dev dependency note (test file only, no install step needed in this task)
    - Mock `@tanstack/react-query`, `../../store/pos`, `../../store/auth`, `../../store/app`, `../../store/localShift`, `../../hooks/useOnlineStatus`, and all api imports so the component renders without a real backend
    - Assert: when `viewMode` is `'table'` the button contains the text `عرض الفئات`
    - Assert: when `viewMode` is `'cards'` the button contains the text `عرض الجدول`
    - _Requirements: 2.1, 2.2_

- [x] 2. Update mobile toggle button in POSPage.tsx
  - [x] 2.1 Replace icon-only mobile toggle button with labeled button
    - In `frontend/src/pages/pos/POSPage.tsx`, find the second (mobile) `<button>` at line ~1368 inside the `{mobileTab === 'products' && ...}` block
    - Apply the identical label change: show `<LayoutGrid size={14} /> عرض الفئات` when `viewMode === 'table'` and `<List size={14} /> عرض الجدول` when `viewMode === 'cards'`
    - Remove the `title` attribute from this button too
    - _Requirements: 2.1, 2.2, 2.5_

  - [ ]* 2.2 Write unit tests for the mobile toggle button label
    - In the same test file `frontend/src/pages/pos/__tests__/POSPageToggle.test.tsx`, add a `describe('mobile toggle')` block
    - Use `@testing-library/react` `getByRole` / `getByText` to locate the mobile button (simulate a viewport width <1024px if needed, or look for both toggle buttons in the rendered tree)
    - Assert same text labels as desktop: `عرض الفئات` when `viewMode === 'table'`, `عرض الجدول` when `viewMode === 'cards'`
    - _Requirements: 2.1, 2.2, 2.5_

  - [ ]* 2.3 Write property test for toggle involution (Property 1)
    - In `frontend/src/pages/pos/__tests__/POSPageToggle.test.tsx`, add a property test using `vitest` + a simple generator (no additional library required — use an array `['table', 'cards']` and verify `toggle(toggle(v)) === v`)
    - Implement as: for each value in `['table', 'cards']`, calling the toggle handler twice should return `viewMode` to its original value
    - Annotate: `// Property 1: Toggle Is an Involution — Validates: Requirements 2.3, 2.6`
    - _Requirements: 2.3, 2.6_

- [x] 3. Checkpoint — Ensure toggle button tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 4. Write tests for CategoryCardBrowser drill-down behavior
  - [x] 4.1 Set up test file and mocks for CategoryCardBrowser
    - Create `frontend/src/pages/pos/__tests__/CategoryCardBrowser.test.tsx`
    - Mock `@tanstack/react-query`'s `useQuery` to return controlled data: a fixed list of categories, subcategories, products, and an empty stockMap
    - Define helpers: `makeCat(id, name)`, `makeSub(id, catId, name)`, `makeProd(id, subId, name, retail_price, stock_status)`
    - _Requirements: 4.1, 4.2_

  - [x] 4.2 Test Level 1 — root category grid renders all categories (Property 2)
    - Render `<CategoryCardBrowser warehouseId="wh1" mode="retail" onAddProduct={vi.fn()} />`
    - Mock `useQuery` to return N categories (test with N=0, N=1, N=5)
    - Assert the number of rendered category buttons equals N
    - Annotate: `// Property 2: Category Grid Renders All Categories — Validates: Requirements 4.3, 4.4, 4.5`
    - _Requirements: 4.3, 4.4, 4.5_

  - [ ]* 4.3 Write property test for category grid count (Property 2)
    - Within the same test file, add a parameterized/looped test that runs for category list sizes [0, 1, 3, 10]
    - For each size N, assert exactly N folder cards are rendered at root level
    - Annotate: `// Property 2: Category Grid Renders All Categories — Validates: Requirements 4.3`
    - _Requirements: 4.3_

  - [x] 4.4 Test Level 2 — clicking category with subcategories shows correct children (Property 3)
    - Set up mock data: 2 categories, category A has 3 subcategories, category B has 2 subcategories
    - Click category A's button; assert exactly 3 subcategory cards are rendered (none from category B)
    - Assert BreadcrumbNav shows category A's name and BackButton labeled "رجوع" is present
    - Annotate: `// Property 3: Subcategory Drill-Down Shows Correct Children — Validates: Requirements 5.1, 5.2`
    - _Requirements: 5.1, 5.2_

  - [ ]* 4.5 Write property test for subcategory scoping (Property 3)
    - Parameterize over multiple categories with distinct subcategory sets
    - For each category click, assert that NO subcategory card belongs to a different category
    - Annotate: `// Property 3: Subcategory Drill-Down Shows Correct Children — Validates: Requirements 5.1`
    - _Requirements: 5.1_

  - [x] 4.6 Test Level 2 → Level 1 back navigation (Property 11)
    - After clicking into a category (Level 2), click the BackButton
    - Assert `selectedCatId` is cleared (top-level category grid is shown again — all categories visible, no breadcrumb)
    - Annotate: `// Property 11: Back Navigation Clears Correct State Level — Validates: Requirements 7.2`
    - _Requirements: 7.2, 7.3_

  - [x] 4.7 Test empty-subcategory category jumps to products (Property 5)
    - Set up mock: one category with zero subcategories; mock `useQuery` for products to return 2 products
    - Click the category card; assert the product grid (Level 3) is shown directly (no subcategory grid, breadcrumb shows category name)
    - Annotate: `// Property 5: Empty-Subcategory Category Jumps to Products — Validates: Requirements 5.4, 5.5`
    - _Requirements: 5.4, 5.5_

  - [x] 4.8 Test Level 3 — clicking subcategory shows products; clicking product calls onAddProduct (Properties 6, 8)
    - Set up mock data: one category, one subcategory, 3 products with `stock_status: 'untracked'`
    - Drill into subcategory; assert 3 product cards render
    - Click the first product card; assert `onAddProduct` spy was called with that product object
    - Annotate: `// Property 6: Product Cards Scoped to Subcategory — Validates: Requirements 6.1` and `// Property 8: onAddProduct Invoked with Correct Product — Validates: Requirements 6.4, 8.2`
    - _Requirements: 6.1, 6.4, 8.2_

  - [ ]* 4.9 Write property test for onAddProduct callback (Property 8)
    - For each of several distinct product objects, click each product card and assert the callback received the exact product
    - Annotate: `// Property 8: onAddProduct Invoked with Correct Product — Validates: Requirements 6.4, 8.2`
    - _Requirements: 6.4, 8.2_

  - [x] 4.10 Test Level 3 → Level 2 back navigation (Property 11)
    - Drill to product level; click BackButton; assert subcategory grid is shown (not root, not product level) — breadcrumb still shows category name
    - Annotate: `// Property 11: Back Navigation Clears Correct State Level — Validates: Requirements 7.1`
    - _Requirements: 7.1_

  - [x] 4.11 Test stock filter — zero-qty tracked products are hidden (Property 10)
    - Set up 3 products: one `tracked` qty=0 (should be hidden), one `tracked` qty=3 (shown), one `untracked` qty=0 (shown)
    - Mock `useQuery` for stockMap to return `{ [prod1.id]: 0, [prod2.id]: 3 }`
    - Assert only 2 product cards render, not 3
    - Annotate: `// Property 10: Stock Filter Excludes Zero-Qty Tracked Products — Validates: Requirements 10.1, 10.2`
    - _Requirements: 10.1, 10.2_

  - [x] 4.12 Test price display respects mode prop (Property 9)
    - Render with `mode="retail"`: assert product card shows `retail_price`
    - Re-render with `mode="wholesale"`: assert product card shows `wholesale_price`
    - Re-render with `mode="wholesale"` and a product where `wholesale_price=0`: assert fallback to `retail_price`
    - Annotate: `// Property 9: Price Respects Sale Mode — Validates: Requirements 9.1, 9.2`
    - _Requirements: 9.1, 9.2_

- [x] 5. Final checkpoint — Ensure all tests pass
  - Ensure all tests pass (`npm test` or `npx vitest run` from `frontend/`), ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- The only production code change is in `POSPage.tsx` (two buttons, ~4 lines total). Everything else is tests.
- `@testing-library/react` and `@testing-library/user-event` are not yet installed; you will need to run `npm install -D @testing-library/react @testing-library/user-event` in `frontend/` before executing the test tasks.
- Test command: `npx vitest run` (single-pass, no watch) from `frontend/`
- `CategoryCardBrowser.tsx` does NOT need to be modified — it already implements the correct behavior
- Property tests in this plan are simple enumeration-based rather than requiring fast-check, since the state space is small and finite

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "2.1"] },
    { "id": 1, "tasks": ["1.2", "2.2", "2.3", "4.1"] },
    { "id": 2, "tasks": ["4.2", "4.4", "4.6", "4.7", "4.8", "4.10", "4.11", "4.12"] },
    { "id": 3, "tasks": ["4.3", "4.5", "4.9"] }
  ]
}
```
