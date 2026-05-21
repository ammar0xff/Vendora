import { test, expect } from '@playwright/test'
import {
  setupLoginMocks, setupAuthMocks, setupSettingsMock,
  MOCK_USER, CSRF_TOKEN,
} from './helpers'

test.describe('Login', () => {
  test('shows login page with company name', async ({ page }) => {
    await setupSettingsMock(page)
    await page.goto('/login')
    await expect(page.getByText('تسجيل الدخول')).toBeVisible()
    await expect(page.getByText('متبر الكتروني')).toBeVisible()
  })

  test('successful login redirects cashier to POS', async ({ page }) => {
    await setupSettingsMock(page)
    await setupLoginMocks(page)
    await setupAuthMocks(page)

    await page.goto('/login')
    await page.fill('input[placeholder="أدخل اسم المستخدم"]', MOCK_USER.username)
    await page.fill('input[placeholder="أدخل كلمة المرور"]', 'changeme')
    await page.click('button[type="submit"]')

    await page.waitForURL('**/pos')
    await expect(page).toHaveURL(/\/pos/)
  })

  test('displays error on invalid credentials', async ({ page }) => {
    await setupSettingsMock(page)
    await page.route('**/api/auth/login', async (route) => {
      await route.fulfill({ status: 401, body: JSON.stringify({ detail: 'Invalid credentials' }) })
    })

    await page.goto('/login')
    await page.fill('input[placeholder="أدخل اسم المستخدم"]', 'wrong')
    await page.fill('input[placeholder="أدخل كلمة المرور"]', 'wrong')
    await page.click('button[type="submit"]')

    await expect(page.getByText('اسم المستخدم أو كلمة المرور غير صحيحة')).toBeVisible()
  })

  test('login button shows loading state', async ({ page }) => {
    await setupSettingsMock(page)
    await page.route('**/api/auth/login', async () => {
      await new Promise(r => setTimeout(r, 1000))
    })

    await page.goto('/login')
    await page.fill('input[placeholder="أدخل اسم المستخدم"]', MOCK_USER.username)
    await page.fill('input[placeholder="أدخل كلمة المرور"]', 'changeme')
    await page.click('button[type="submit"]')

    await expect(page.getByText('جاري تسجيل الدخول...')).toBeVisible()
  })

  test('admin user redirects to dashboard', async ({ page }) => {
    await setupSettingsMock(page)
    await page.route('**/api/auth/login', async (route) => {
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
    await page.route('**/api/auth/me', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({ id: 'admin-id', username: 'admin', full_name: 'Admin', role: 'admin', csrf_token: CSRF_TOKEN, permissions: [] }),
      })
    })

    await page.goto('/login')
    await page.fill('input[placeholder="أدخل اسم المستخدم"]', 'admin')
    await page.fill('input[placeholder="أدخل كلمة المرور"]', 'admin')
    await page.click('button[type="submit"]')

    await page.waitForURL('**/')
    await expect(page).not.toHaveURL(/\/login/)
  })

  test('shows validation for empty fields', async ({ page }) => {
    await page.goto('/login')
    const submitBtn = page.locator('button[type="submit"]')
    await expect(submitBtn).toBeDisabled()
  })
})
