import api from './client'
import type {
  ProductCreate, SaleCreate, CustomerCreate, UserCreate,
  ExpenseCreate, ExpenseVendorCreate, SupplierCreate, SupplierPriceCreate,
  PurchaseCreate, DrawerTxCreate, ShiftTransfer, RevenueDelivery,
  ShiftClose, StockMovementCreate, StockBulkAdjust, StockTransfer,
} from '../types'

export const authApi = {
  login: (username: string, password: string) =>
    api.post('/auth/login', { username, password }).then(r => r.data),
  me: () => api.get('/auth/me').then(r => r.data),
  changePassword: (current_password: string, new_password: string) =>
    api.put('/auth/me/password', { current_password, new_password }),
  printToken: () => api.post('/auth/print-token').then(r => r.data),
}

export const productsApi = {
  list: (params?: Record<string, unknown>) => api.get('/products', { params }).then(r => r.data?.items ?? r.data),
  listPage: (params?: Record<string, unknown>) => api.get('/products', { params }).then(r => r.data),
  get: (id: string) => api.get(`/products/${id}`).then(r => r.data),
  create: (data: ProductCreate) => api.post('/products', data).then(r => r.data),
  update: (id: string, data: Partial<ProductCreate>) => api.put(`/products/${id}`, data).then(r => r.data),
  delete: (id: string) => api.delete(`/products/${id}`),
  byBarcode: (barcode: string) => api.get(`/products/barcode/${barcode}`).then(r => r.data),
  movements: (id: string) => api.get(`/products/${id}/movements`).then(r => r.data?.items ?? r.data),
  move: (id: string, subcategory_id: string) => api.post(`/products/${id}/move`, { subcategory_id }),
  uploadImage: (id: string, file: File) => {
    const fd = new FormData(); fd.append('file', file)
    return api.post(`/products/${id}/image`, fd).then(r => r.data)
  },
  addBarcode: (productId: string, data: { barcode: string }) => api.post(`/products/${productId}/barcodes`, data).then(r => r.data),
  updateBarcode: (barcodeId: string, data: { barcode: string }) => api.put(`/barcodes/${barcodeId}`, data).then(r => r.data),
  deleteBarcode: (barcodeId: string) => api.delete(`/barcodes/${barcodeId}`),
}

export const categoriesApi = {
  list: () => api.get('/categories').then(r => r.data),
  create: (name: string) => api.post('/categories', { name }).then(r => r.data),
  update: (id: string, name: string) => api.put(`/categories/${id}`, { name }).then(r => r.data),
  delete: (id: string) => api.delete(`/categories/${id}`),
}

export const subcategoriesApi = {
  list: (category_id?: string) => api.get('/subcategories', { params: category_id ? { category_id } : {} }).then(r => r.data),
  create: (category_id: string, name: string) => api.post('/subcategories', { category_id, name }).then(r => r.data),
  update: (id: string, category_id: string, name: string) => api.put(`/subcategories/${id}`, { category_id, name }).then(r => r.data),
  delete: (id: string) => api.delete(`/subcategories/${id}`),
}

export const stockApi = {
  warehouses: () => api.get('/stock/warehouses').then(r => r.data),
  balance: (product_id: string, warehouse_id: string) =>
    api.get('/stock/balance', { params: { product_id, warehouse_id } }).then(r => r.data),
  balanceBulk: (warehouse_id: string, product_ids: string[]) =>
    api.post(`/stock/balance/bulk?warehouse_id=${warehouse_id}`, product_ids).then(r => r.data),
  movements: (params?: Record<string, unknown>) => api.get('/stock/movements', { params }).then(r => r.data),
  addMovement: (data: StockMovementCreate) => api.post('/stock/movements', data).then(r => r.data),
  bulkAdjust: (data: StockBulkAdjust[]) => api.post('/stock/adjustment/bulk', data).then(r => r.data),
  transfer: (data: StockTransfer) => api.post('/stock/transfer', data).then(r => r.data),
  lowStock: (warehouse_id: string, threshold = 5) =>
    api.get('/stock/low-stock', { params: { warehouse_id, threshold } }).then(r => r.data),
  valuation: (warehouse_id: string) =>
    api.get('/stock/valuation', { params: { warehouse_id } }).then(r => r.data),
}

export const salesApi = {
  list: (params?: Record<string, unknown>) => api.get('/sales', { params }).then(r => r.data),
  get: (id: string) => api.get(`/sales/${id}`).then(r => r.data),
  create: (data: SaleCreate) => api.post('/sales', data).then(r => r.data),
  cancel: (id: string) => api.put(`/sales/${id}/cancel`),
  return: (id: string) => api.post(`/sales/${id}/return`).then(r => r.data),
}

export const shiftsApi = {
  list: (params?: Record<string, unknown>) => api.get('/shifts', { params }).then(r => r.data),
  last: (warehouse_id: string) => api.get('/shifts/last-drawer', { params: { warehouse_id } }).then(r => r.data),
  current: (warehouse_id: string) => api.get('/shifts/current', { params: { warehouse_id } }).then(r => r.data),
  open: (initial_amount: number, warehouse_id: string, supervisor_id?: string) => api.post('/shifts/open', { initial_amount, warehouse_id, supervisor_id }).then(r => r.data),
  close: (id: string, data: ShiftClose) => api.post(`/shifts/${id}/close`, data).then(r => r.data),
  summary: (id: string) => api.get(`/shifts/${id}/summary`).then(r => r.data),
  transactions: (id: string) => api.get(`/shifts/${id}/transactions`).then(r => r.data),
  addTransaction: (id: string, data: DrawerTxCreate) => api.post(`/shifts/${id}/transactions`, data).then(r => r.data),
  transfer: (id: string, data: ShiftTransfer) => api.post(`/shifts/${id}/transfer`, data).then(r => r.data),
  revenueDelivery: (id: string, data: RevenueDelivery) => api.post(`/shifts/${id}/revenue-delivery`, data).then(r => r.data),
}

export const reportsApi = {
  daily: (date: string, warehouse_id?: string) => api.get('/reports/sales/daily', { params: { target_date: date, ...(warehouse_id ? { warehouse_id } : {}) } }).then(r => r.data),
  monthly: (year: number, month: number, warehouse_id?: string) => api.get('/reports/sales/monthly', { params: { year, month, ...(warehouse_id ? { warehouse_id } : {}) } }).then(r => r.data),
  topProducts: (from_date: string, to_date: string) =>
    api.get('/reports/sales/top-products', { params: { from_date, to_date } }).then(r => r.data),
  profit: (from_date: string, to_date: string, warehouse_id?: string) =>
    api.get('/reports/profit', { params: { from_date, to_date, ...(warehouse_id ? { warehouse_id } : {}) } }).then(r => r.data),
  byCashier: (from_date: string, to_date: string, warehouse_id?: string) =>
    api.get('/reports/sales/by-cashier', { params: { from_date, to_date, ...(warehouse_id ? { warehouse_id } : {}) } }).then(r => r.data),
}

export const archiveApi = {
  list: (params?: Record<string, unknown>) => api.get('/archive', { params }).then(r => r.data),
  get: (id: string) => api.get(`/archive/${id}`).then(r => r.data),
  delete: (id: string) => api.delete(`/archive/${id}`),
}

export const usersApi = {
  list: () => api.get('/users').then(r => r.data),
  create: (data: UserCreate) => api.post('/users', data).then(r => r.data),
  update: (id: string, data: Partial<UserCreate>) => api.put(`/users/${id}`, data).then(r => r.data),
  delete: (id: string) => api.delete(`/users/${id}`),
}

export const settingsApi = {
  get: () => api.get('/settings').then(r => r.data),
  update: (data: Record<string, unknown>) => api.put('/settings', { settings: data }),
  getOptions: () => api.get('/settings/product-options').then(r => r.data),
  updateOptions: (data: Record<string, unknown>) => api.put('/settings/product-options', data),
}

export const expensesApi = {
  list: (params?: Record<string, unknown>) => api.get('/expenses', { params }).then(r => r.data),
  create: (data: ExpenseCreate) => api.post('/expenses', data).then(r => r.data),
  update: (id: string, data: Partial<ExpenseCreate>) => api.put(`/expenses/${id}`, data).then(r => r.data),
  approve: (id: string, data: { approved: boolean }) => api.post(`/expenses/${id}/approve`, data).then(r => r.data),
  delete: (id: string) => api.delete(`/expenses/${id}`),
  summary: (params?: Record<string, unknown>) => api.get('/expenses/summary', { params }).then(r => r.data),
  vendors: {
    list: (search?: string) => api.get('/expense-vendors', { params: search ? { search } : {} }).then(r => r.data),
    create: (data: ExpenseVendorCreate) => api.post('/expense-vendors', data).then(r => r.data),
    update: (id: string, data: Partial<ExpenseVendorCreate>) => api.put(`/expense-vendors/${id}`, data).then(r => r.data),
  },
}

export const auditApi = {
  list: (params?: Record<string, unknown>) => api.get('/audit-log', { params }).then(r => r.data),
}

export const customersApi = {
  list: (search?: string) => api.get('/customers', { params: search ? { search } : {} }).then(r => r.data),
  create: (data: CustomerCreate) => api.post('/customers', data).then(r => r.data),
  update: (id: string, data: Partial<CustomerCreate & { balance?: number }>) => api.put(`/customers/${id}`, data).then(r => r.data),
  delete: (id: string) => api.delete(`/customers/${id}`),
  account: (id: string) => api.get(`/customers/${id}/account`).then(r => r.data),
  ledger: (id: string) => api.get(`/customers/${id}/ledger`).then(r => r.data),
  addPayment: (id: string, amount: number, note: string, sale_id?: string) => api.post(`/customers/${id}/payments`, { amount, note, sale_id }).then(r => r.data),
  setBalance: (id: string, balance: number) => api.put(`/customers/${id}/balance`, { balance }).then(r => r.data),
}

export const supplierPricesApi = {
  getProductPrices: (productId: string) => api.get(`/purchases/supplier-prices/product/${productId}`).then(r => r.data),
  create: (data: SupplierPriceCreate) => api.post('/purchases/supplier-prices', data).then(r => r.data),
  update: (id: string, data: Partial<SupplierPriceCreate>) => api.put(`/purchases/supplier-prices/${id}`, data).then(r => r.data),
  delete: (id: string) => api.delete(`/purchases/supplier-prices/${id}`),
}

export const purchasesApi = {
  create: (data: PurchaseCreate) => api.post('/purchases', data).then(r => r.data),
  receive: (id: string, data: { received_qty?: number; notes?: string }) => api.post(`/purchases/${id}/receive`, data).then(r => r.data),
  list: () => api.get('/purchases').then(r => r.data?.items ?? r.data),
  get: (id: string) => api.get(`/purchases/${id}`).then(r => r.data),
}

export const suppliersApi = {
  list: (type?: string) => api.get('/suppliers', { params: type ? { type } : {} }).then(r => r.data?.items ?? r.data),
  create: (d: SupplierCreate) => api.post('/suppliers', d).then(r => r.data),
  update: (id: string, d: Partial<SupplierCreate>) => api.put(`/suppliers/${id}`, d).then(r => r.data),
  delete: (id: string) => api.delete(`/suppliers/${id}`),
  ledger: (id: string) => api.get(`/suppliers/${id}/ledger`).then(r => r.data),
  addTx: (id: string, d: { type: string; amount: number; note?: string }) => api.post(`/suppliers/${id}/transactions`, d).then(r => r.data),
}

export const notificationsApi = {
  register: (data: { token: string; platform: string; device_name?: string }) =>
    api.post('/notifications/register', data).then(r => r.data),
  unregister: (token: string) =>
    api.post('/notifications/unregister', null, { params: { token } }).then(r => r.data),
  send: (data: { user_id: string; title: string; body: string; data?: Record<string, string> }) =>
    api.post('/notifications/send', data).then(r => r.data),
  tokens: (userId?: string) =>
    api.get('/notifications/tokens', { params: userId ? { user_id: userId } : {} }).then(r => r.data),
}
