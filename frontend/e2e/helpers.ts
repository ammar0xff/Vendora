import { Page } from '@playwright/test'

const USER_ID = '550e8400-e29b-41d4-a716-446655440000'
export const CSRF_TOKEN = 'test-csrf-token-12345'
const JWT_TOKEN = 'test.jwt.token'

export const MOCK_USER = {
  id: USER_ID,
  username: 'ammar',
  full_name: 'عمار محمد',
  role: 'cashier',
  permissions: ['pos'],
}

export const MOCK_SETTINGS = {
  store_name: 'متبر الكتروني',
  store_address: 'القاهرة',
  store_phone: '0123456789',
  logo_url: '',
}

export const MOCK_PRODUCTS = {
  items: [
    { id: 'p1', name: 'ماسورة ½ بوصة', unit: 'متر', retail_price: 25, cost_price: 18, qty: 100, barcode: '123456' },
    { id: 'p2', name: 'محبس ¾ بوصة', unit: 'قطعة', retail_price: 45, cost_price: 32, qty: 50, barcode: '789012' },
    { id: 'p3', name: 'مواسير صرف pvc 4 بوصة', unit: 'متر', retail_price: 35, cost_price: 22, qty: 200, barcode: '345678' },
  ],
  total: 3, page: 1, size: 20, pages: 1,
}

export const MOCK_CUSTOMERS = [
  { id: 'c1', name: 'أحمد علي', phone: '0111111111', balance: 0 },
  { id: 'c2', name: 'محمد حسن', phone: '0122222222', balance: 500 },
]

export const MOCK_SHIFT = {
  id: 's1',
  initial_amount: 1000,
  status: 'open',
  cashier_name: 'عمار محمد',
  warehouse_name: 'المخزن الرئيسي',
  started_at: new Date().toISOString(),
}

export const MOCK_SALES = [
  {
    id: 'sale1', invoice_number: 'INV-001', status: 'confirmed',
    total: 150, customer_name: 'أحمد علي', payment_method: 'cash',
    created_at: new Date().toISOString(),
  },
  {
    id: 'sale2', invoice_number: 'INV-002', status: 'returned',
    total: 75, customer_name: 'محمد حسن', payment_method: 'wallet',
    created_at: new Date().toISOString(),
  },
  {
    id: 'sale3', invoice_number: 'INV-003', status: 'quotation',
    total: 320, customer_name: 'عمر خالد', payment_method: 'cash',
    created_at: new Date().toISOString(),
  },
]

export const MOCK_WAREHOUSES = [
  { id: 'w1', name: 'المخزن الرئيسي', code: 'WH-01' },
]

export async function setupLoginMocks(page: Page) {
  await page.route('**/api/auth/login', async (route) => {
    await route.fulfill({
      status: 200,
      headers: { 'set-cookie': `access_token=${JWT_TOKEN}; HttpOnly; Path=/` },
      contentType: 'application/json',
      body: JSON.stringify({
        access_token: JWT_TOKEN, token_type: 'bearer',
        user_id: USER_ID, username: MOCK_USER.username,
        full_name: MOCK_USER.full_name, role: MOCK_USER.role,
        csrf_token: CSRF_TOKEN,
      }),
    })
  })
}

export async function setupAuthMocks(page: Page) {
  await page.route('**/api/auth/me', async (route) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({ ...MOCK_USER, csrf_token: CSRF_TOKEN, permissions: ['pos'] }),
    })
  })
}

export async function setupSettingsMock(page: Page) {
  await page.route('**/api/settings', async (route, request) => {
    if (request.method() === 'GET') {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify(MOCK_SETTINGS),
      })
    } else {
      await route.continue()
    }
  })
}

export async function setupProductsMock(page: Page) {
  await page.route('**/api/products', async (route, request) => {
    if (request.method() === 'GET') {
      const url = new URL(request.url())
      const search = url.searchParams.get('search') || ''
      const filtered = search
        ? MOCK_PRODUCTS.items.filter(p => p.name.includes(search))
        : MOCK_PRODUCTS.items
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({ ...MOCK_PRODUCTS, items: filtered, total: filtered.length }),
      })
    } else {
      await route.continue()
    }
  })
}

export async function setupShiftMock(page: Page) {
  await page.route('**/api/shifts/current', async (route) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify(MOCK_SHIFT),
    })
  })
}

export async function setupSalesMock(page: Page) {
  await page.route('**/api/sales*', async (route, request) => {
    if (request.method() === 'GET') {
      const url = new URL(request.url())
      const status = url.searchParams.get('status') || ''
      const filtered = status
        ? MOCK_SALES.filter(s => s.status === status)
        : MOCK_SALES
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify(filtered),
      })
    } else {
      await route.continue()
    }
  })
}

export async function setupWarehousesMock(page: Page) {
  await page.route('**/api/stock/warehouses', async (route) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify(MOCK_WAREHOUSES),
    })
  })
}

export async function setupCustomersMock(page: Page) {
  await page.route('**/api/customers', async (route) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify(MOCK_CUSTOMERS),
    })
  })
}

export async function loginAs(page: Page, _role = 'cashier') {
  await setupLoginMocks(page)
  await setupAuthMocks(page)
  await setupSettingsMock(page)
  await page.goto('/login')
  await page.fill('input[placeholder="أدخل اسم المستخدم"]', 'ammar')
  await page.fill('input[placeholder="أدخل كلمة المرور"]', 'changeme')
  await page.click('button[type="submit"]')
  await page.waitForURL('**/pos')
}
