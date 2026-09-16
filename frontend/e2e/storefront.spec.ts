import { test, expect } from '@playwright/test'
import { setupSettingsMock } from './helpers'

const PRODUCTS = [
  { id: 'p1', name: 'ماسورة ½ بوصة', code: 'A-1', unit: 'متر', retail_price: 25, wholesale_price: 18, company: 'المصرية', size: null, image_url: null, subcategory_id: 's1', category_id: 'c1', category_name: 'مواسير' },
  { id: 'p2', name: 'محبس ¾ بوصة', code: 'A-2', unit: 'قطعة', retail_price: 45, wholesale_price: 32, company: 'مصر تولز', size: '3/4', image_url: null, subcategory_id: 's2', category_id: 'c1', category_name: 'مواسير' },
]

const CATEGORIES = [
  { id: 'c1', name: 'مواسير', code: 'P', product_count: 2 },
]

async function setupStoreMock(page: import('@playwright/test').Page) {
  await setupSettingsMock(page)
  await page.route('**/api/store/products*', async (route, request) => {
    if (request.method() !== 'GET') return route.continue()
    const url = new URL(request.url())
    const search = url.searchParams.get('search') || ''
    const cat = url.searchParams.get('category_id') || ''
    const filtered = PRODUCTS.filter((p) =>
      (!search || p.name.includes(search) || (p.code || '').includes(search)) &&
      (!cat || p.category_id === cat)
    )
    await route.fulfill({ status: 200, contentType: 'application/json', body: JSON.stringify({ items: filtered, total: filtered.length, page: 1, size: 24, pages: 1 }) })
  })
  await page.route('**/api/store/products/p1', async (route) => {
    await route.fulfill({ status: 200, contentType: 'application/json', body: JSON.stringify(PRODUCTS[0]) })
  })
  await page.route('**/api/store/categories', async (route) => {
    await route.fulfill({ status: 200, contentType: 'application/json', body: JSON.stringify(CATEGORIES) })
  })
}

test.describe('Storefront', () => {
  test('home page renders hero, categories, and featured products', async ({ page }) => {
    await setupStoreMock(page)
    await page.goto('/store')
    await expect(page.getByText('متجر ڤندورة').first()).toBeVisible()
    await expect(page.getByText('كل لوازم السباكة')).toBeVisible()
    await expect(page.getByText('مواسير', { exact: true }).first()).toBeVisible()
    await expect(page.getByText('ماسورة ½ بوصة')).toBeVisible()
  })

  test('catalog search filters products', async ({ page }) => {
    await setupStoreMock(page)
    await page.goto('/store/catalog')
    await page.fill('input[placeholder="ابحث بالاسم أو الكود..."]', 'محبس')
    await expect(page.getByText('محبس ¾ بوصة')).toBeVisible()
    await expect(page.getByText('ماسورة ½ بوصة')).not.toBeVisible()
  })

  test('category link deep-links catalog to filtered list', async ({ page }) => {
    await setupStoreMock(page)
    await page.goto('/store')
    await page.getByText('مواسير', { exact: true }).first().click()
    await expect(page.getByText('ماسورة ½ بوصة')).toBeVisible()
  })

  test('add to cart opens cart sidebar with item', async ({ page }) => {
    await setupStoreMock(page)
    await page.goto('/store')
    await page.locator('button[aria-label="أضف للعربة"]').first().click()
    await expect(page.getByRole('heading', { name: /عربة التسوق/ })).toBeVisible()
    await expect(page.getByText('ماسورة ½ بوصة').first()).toBeVisible()
  })

  test('product detail page opens from product card', async ({ page }) => {
    await setupStoreMock(page)
    await page.goto('/store')
    await page.getByText('ماسورة ½ بوصة').click()
    await expect(page).toHaveURL(/\/store\/products\/p1/)
    await expect(page.getByText('ماسورة ½ بوصة').first()).toBeVisible()
    await expect(page.getByText(/ج\.م/).first()).toBeVisible()
  })

  test('wishlist toggle updates badge', async ({ page }) => {
    await setupStoreMock(page)
    await page.goto('/store')
    await page.locator('button[aria-label="أضف للمفضلة"]').first().click()
    await page.goto('/store/wishlist')
    await expect(page.getByText('ماسورة ½ بوصة')).toBeVisible()
  })
})