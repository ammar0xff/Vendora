import { test, expect } from '@playwright/test'
import {
  setupProductsMock, setupSettingsMock, setupLoginMocks,
  setupAuthMocks, setupWarehousesMock,
} from './helpers'

test.describe('Inventory', () => {
  test.beforeEach(async ({ page }) => {
    await setupSettingsMock(page)
    await setupLoginMocks(page)
    await setupAuthMocks(page)
    await setupWarehousesMock(page)

    await page.goto('/login')
    await page.fill('input[placeholder="أدخل اسم المستخدم"]', 'ammar')
    await page.fill('input[placeholder="أدخل كلمة المرور"]', 'changeme')
    await page.click('button[type="submit"]')
    await page.waitForURL('**/pos')

    // Navigate to inventory
    await page.goto('/inventory')
    await page.waitForLoadState('networkidle')
  })

  test('loads inventory page', async ({ page }) => {
    await expect(page).toHaveURL(/\/inventory/)
  })

  test('shows search input', async ({ page }) => {
    const searchInput = page.locator('input[placeholder*="بحث"]')
    await expect(searchInput).toBeVisible()
  })

  test('searches for product by name', async ({ page }) => {
    await setupProductsMock(page)
    const searchInput = page.locator('input[placeholder*="بحث"]')
    await searchInput.fill('ماسورة')
    await page.waitForTimeout(500)
    await expect(page.getByText('ماسورة ½ بوصة')).toBeVisible()
  })

  test('returns no results for unmatched search', async ({ page }) => {
    await setupProductsMock(page)
    const searchInput = page.locator('input[placeholder*="بحث"]')
    await searchInput.fill('XXXXXX')
    await page.waitForTimeout(500)
    await expect(page.getByText('لا توجد')).toBeVisible()
  })

  test('displays product details in table', async ({ page }) => {
    await setupProductsMock(page)
    await page.waitForTimeout(500)
    await expect(page.getByText('ماسورة ½ بوصة')).toBeVisible()
    await expect(page.getByText('محبس ¾ بوصة')).toBeVisible()
    await expect(page.getByText('مواسير صرف pvc 4 بوصة')).toBeVisible()
  })
})
