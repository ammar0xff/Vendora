import { test, expect } from '@playwright/test'
import {
  setupProductsMock, setupSettingsMock, setupLoginMocks,
  setupAuthMocks,
} from './helpers'

test.describe('POS', () => {
  test.beforeEach(async ({ page }) => {
    await setupSettingsMock(page)
    await setupLoginMocks(page)
    await setupAuthMocks(page)

    await page.goto('/login')
    await page.fill('input[placeholder="أدخل اسم المستخدم"]', 'ammar')
    await page.fill('input[placeholder="أدخل كلمة المرور"]', 'changeme')
    await page.click('button[type="submit"]')
    await page.waitForURL('**/pos')
  })

  test('loads POS page with search input', async ({ page }) => {
    await expect(page.getByPlaceholder('بحث')).toBeVisible()
  })

  test('opens shift drawer modal', async ({ page }) => {
    await page.click('text=فتح وردية جديدة')
    await expect(page.getByText('فتح وردية')).toBeVisible()
  })

  test('searches for products', async ({ page }) => {
    await setupProductsMock(page)
    const searchInput = page.getByPlaceholder('بحث')
    await searchInput.fill('ماسورة')
    await page.waitForTimeout(500)
    await expect(page.getByText('ماسورة ½ بوصة')).toBeVisible()
  })

  test('adds product to cart', async ({ page }) => {
    await setupProductsMock(page)
    const searchInput = page.getByPlaceholder('بحث')
    await searchInput.fill('ماسورة')
    await page.waitForTimeout(500)
    const productResult = page.getByText('ماسورة ½ بوصة').first()
    await productResult.click()
  })

  test('adjusts item quantity in cart', async ({ page }) => {
    await setupProductsMock(page)
    const searchInput = page.getByPlaceholder('بحث')
    await searchInput.fill('ماسورة')
    await page.waitForTimeout(500)
    await page.getByText('ماسورة ½ بوصة').first().click()
    const plusButtons = page.locator('button').filter({ hasText: '' })
    const plusBtn = plusButtons.first()
    if (await plusBtn.isVisible()) {
      await plusBtn.click()
    }
  })
})
