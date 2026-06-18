import { test, expect } from '@playwright/test'
import {
  setupSettingsMock,
  CSRF_TOKEN,
} from './helpers'

const MOCK_CATEGORIES = [
  { id: 'cat1', name: 'مواسير' },
  { id: 'cat2', name: 'محابس' },
]

const MOCK_SUBCATEGORIES = [
  { id: 'sub1', name: 'مواسير حديد', category_id: 'cat1' },
  { id: 'sub2', name: 'مواسير بلاستيك', category_id: 'cat1' },
  { id: 'sub3', name: 'محابس نحاس', category_id: 'cat2' },
]

const ADMIN_USER = {
  id: 'admin-id', username: 'admin',
  full_name: 'Admin', role: 'admin',
  csrf_token: CSRF_TOKEN, permissions: [],
}

async function loginAsAdmin(page: any) {
  await page.route('**/api/auth/login', async (route: any) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({
        access_token: 'jwt', token_type: 'bearer',
        user_id: 'admin-id', username: 'admin',
        full_name: 'Admin', role: 'admin',
        csrf_token: CSRF_TOKEN,
      }),
    })
  })
  await page.route('**/api/auth/me', async (route: any) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify(ADMIN_USER),
    })
  })
}

async function setupCategoriesMock(page: any) {
  await page.route('**/api/categories', async (route: any) => {
    if (route.request().method() === 'GET') {
      await route.fulfill({ status: 200, contentType: 'application/json', body: JSON.stringify(MOCK_CATEGORIES) })
    } else {
      await route.continue()
    }
  })
}

async function setupSubcategoriesMock(page: any) {
  await page.route('**/api/subcategories*', async (route: any) => {
    if (route.request().method() === 'GET') {
      await route.fulfill({ status: 200, contentType: 'application/json', body: JSON.stringify(MOCK_SUBCATEGORIES) })
    } else {
      await route.continue()
    }
  })
}

test.describe('Settings - Subcategory Delete Dialog', () => {
  test.beforeEach(async ({ page }) => {
    await setupSettingsMock(page)
    await loginAsAdmin(page)
    await setupCategoriesMock(page)
    await setupSubcategoriesMock(page)

    await page.goto('/login')
    await page.fill('input[placeholder="أدخل اسم المستخدم"]', 'admin')
    await page.fill('input[placeholder="أدخل كلمة المرور"]', 'admin')
    await page.click('button[type="submit"]')
    await page.waitForURL('**/')
    await page.goto('/settings')
    await page.waitForLoadState('networkidle')
  })

  test('opens delete confirmation dialog when clicking delete', async ({ page }) => {
    await page.click('button:has-text("الفئات والتصنيفات")')
    await page.waitForTimeout(500)

    // First subcategory delete button
    const deleteBtn = page.locator('button[title="حذف"]').first()
    await expect(deleteBtn).toBeVisible()
    await deleteBtn.click()

    // Verify only ONE dialog appears
    const dialogs = page.locator('.modal-overlay')
    await expect(dialogs).toHaveCount(1)

    // Verify dialog has confirm message
    await expect(page.getByText('حذف "مواسير حديد"؟')).toBeVisible()
  })

  test('calls delete API on confirm and closes dialog', async ({ page }) => {
    let deleteCalled = false

    await page.route('**/api/subcategories/sub1', async (route: any) => {
      if (route.request().method() === 'DELETE') {
        deleteCalled = true
        await route.fulfill({ status: 204 })
      } else {
        await route.continue()
      }
    })

    await page.click('button:has-text("الفئات والتصنيفات")')
    await page.waitForTimeout(500)

    // Click delete on first subcategory
    await page.locator('button[title="حذف"]').first().click()
    await page.waitForTimeout(300)

    // Click confirm
    await page.locator('button:has-text("تأكيد")').click()

    // Wait for API to be called and dialog to close
    await page.waitForTimeout(1000)
    expect(deleteCalled).toBe(true)

    // Dialog should be closed
    await expect(page.locator('.modal-overlay')).toHaveCount(0)
  })

  test('shows error toast when API returns error', async ({ page }) => {
    await page.route('**/api/subcategories/sub1', async (route: any) => {
      if (route.request().method() === 'DELETE') {
        await route.fulfill({
          status: 400,
          contentType: 'application/json',
          body: JSON.stringify({ detail: 'لا يمكن حذف التصنيف الفرعي — يوجد 3 منتج نشط مرتبط به' }),
        })
      } else {
        await route.continue()
      }
    })

    await page.click('button:has-text("الفئات والتصنيفات")')
    await page.waitForTimeout(500)

    await page.locator('button[title="حذف"]').first().click()
    await page.waitForTimeout(300)

    await page.locator('button:has-text("تأكيد")').click()
    await page.waitForTimeout(500)

    // Error toast should appear
    await expect(page.getByText('فشل الحذف')).toBeVisible()

    // Dialog should close after error
    await expect(page.locator('.modal-overlay')).toHaveCount(0)
  })

  test('does not open multiple dialogs on rapid clicks', async ({ page }) => {
    await page.click('button:has-text("الفئات والتصنيفات")')
    await page.waitForTimeout(500)

    const deleteBtn = page.locator('button[title="حذف"]').first()
    await deleteBtn.click()
    await deleteBtn.click()
    await deleteBtn.click()
    await page.waitForTimeout(300)

    // Only one dialog should exist
    const dialogs = page.locator('.modal-overlay')
    await expect(dialogs).toHaveCount(1)
  })

  test('cancel button closes dialog without API call', async ({ page }) => {
    let deleteCalled = false

    await page.route('**/api/subcategories/**', async (route: any) => {
      if (route.request().method() === 'DELETE') {
        deleteCalled = true
        await route.fulfill({ status: 204 })
      } else {
        await route.continue()
      }
    })

    await page.click('button:has-text("الفئات والتصنيفات")')
    await page.waitForTimeout(500)

    await page.locator('button[title="حذف"]').first().click()
    await page.waitForTimeout(300)

    // Click cancel
    await page.locator('button:has-text("إلغاء")').click()
    await page.waitForTimeout(300)

    expect(deleteCalled).toBe(false)
    await expect(page.locator('.modal-overlay')).toHaveCount(0)
  })
})
