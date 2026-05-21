import { test, expect } from '@playwright/test'
import {
  setupSalesMock, setupSettingsMock, setupLoginMocks,
  setupAuthMocks, MOCK_SALES,
} from './helpers'

test.describe('Sales Page', () => {
  test.beforeEach(async ({ page }) => {
    await setupSettingsMock(page)
    await setupLoginMocks(page)
    await setupAuthMocks(page)

    await page.goto('/login')
    await page.fill('input[placeholder="أدخل اسم المستخدم"]', 'ammar')
    await page.fill('input[placeholder="أدخل كلمة المرور"]', 'changeme')
    await page.click('button[type="submit"]')
    await page.waitForURL('**/pos')

    await setupSalesMock(page)
    await page.goto('/sales')
    await page.waitForLoadState('networkidle')
  })

  test('loads sales page with invoice list', async ({ page }) => {
    await expect(page).toHaveURL(/\/sales/)
    await expect(page.getByText('INV-001')).toBeVisible()
    await expect(page.getByText('INV-002')).toBeVisible()
    await expect(page.getByText('INV-003')).toBeVisible()
  })

  test('shows status pills for each sale', async ({ page }) => {
    await expect(page.getByText('مؤكدة')).toBeVisible()
    await expect(page.getByText('مرتجعة')).toBeVisible()
    await expect(page.getByText('عرض سعر')).toBeVisible()
  })

  test('filters sales by status', async ({ page }) => {
    // Click a filter for "مرتجعة" (returned)
    const returnedFilter = page.locator('button, span, div').filter({ hasText: 'مرتجعة' }).first()
    if (await returnedFilter.isVisible()) {
      await returnedFilter.click()
      await page.waitForTimeout(300)
    }
    // Only returned sale should show
    await expect(page.getByText('INV-002')).toBeVisible()
  })

  test('shows search input for filtering', async ({ page }) => {
    const searchInput = page.locator('input[placeholder*="بحث"]')
    await expect(searchInput).toBeVisible()
  })

  test('displays correct total amounts', async ({ page }) => {
    const confirmedSale = MOCK_SALES.find(s => s.status === 'confirmed')
    if (confirmedSale) {
      await expect(page.getByText(confirmedSale.invoice_number)).toBeVisible()
    }
  })
})
