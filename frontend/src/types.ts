export interface Warehouse {
  id: string
  name: string
  warehouse_type: 'showroom' | 'warehouse'
}

export interface Category {
  id: string
  name: string
}

export interface Subcategory {
  id: string
  name: string
  category_id: string
}

export interface Product {
  id: string
  name: string
  unit: string
  retail_price: number
  wholesale_price: number
  cost_price: number
  barcode: string | null
  subcategory_id: string
  image_url: string | null
  company?: string
  shelf_number?: string
  stock_status?: string
  barcodes?: Array<{ id: string; barcode: string }>
}

export interface Wallet {
  id: string
  name: string
  type: string
  balance: number
}

export interface Customer {
  id: string
  name: string
  phone: string | null
  balance: number
}

export interface User {
  id: string
  username: string
  full_name: string
  role: string
  permissions: string[]
  is_manager: boolean
  default_warehouse_id: string | null
}

export interface Shift {
  id: string
  cashier_id: string
  cashier_name?: string
  supervisor_id?: string | null
  warehouse_id: string
  initial_amount: number
  status: string
  opened_at: string
}

export interface ShiftSummary {
  expected_balance: number
  cash_in_drawer: number
  payment_breakdown: Array<{ method: string; amount: number }>
  wallet_tx_breakdown: Array<{ wallet_name: string; type: string; amount: number }>
}

export interface Sale {
  id: string
  invoice_number: string
  net_total: number
  discount_amount: number
  paid_amount: number
  returns_total: number
  is_credit: boolean
  payment_method: string
  sale_mode: string
  status: string
  customer_id: string | null
  warehouse_id: string
  created_at: string
}

export interface SaleItem {
  id: string
  product_id: string
  qty: number
  unit_price: number
  unit_cost: number
  discount: number
}

export interface Collection {
  id: string
  name: string
  retail_price?: number
  wholesale_price?: number
  items: Array<{
    product_id: string
    product_name: string
    qty: number
    unit_price: number
    wholesale_price?: number
    retail_price?: number
    cost_price?: number
    unit?: string
  }>
}

export interface ProductCreate {
  name: string
  unit?: string
  retail_price?: number
  wholesale_price?: number
  cost_price?: number
  barcode?: string
  subcategory_id?: string
  company?: string
  shelf_number?: string
  stock_status?: string
}

export interface SaleItemCreate {
  product_id: string
  qty: number
  unit_price: number
  unit_cost: number
  discount?: number
}

export interface SaleCreate {
  warehouse_id: string
  shift_id?: string | null
  sale_mode: string
  is_credit: boolean
  customer_id?: string | null
  discount_amount?: number
  payment_method?: string
  wallet_id?: string | null
  paid_amount?: number
  notes?: string
  local_id?: string
  payments?: Array<{ method: string; amount: number; wallet_id?: string | null }>
  items: SaleItemCreate[]
}

export interface CustomerCreate {
  name: string
  phone?: string
}

export interface UserCreate {
  username: string
  password: string
  full_name: string
  role?: string
  permissions?: string[]
  default_warehouse_id?: string | null
}

export interface ExpenseCreate {
  amount: number
  note?: string
  category_id?: string
  vendor_id?: string
  payment_method?: string
  warehouse_id?: string
}

export interface ExpenseVendorCreate {
  name: string
}

export interface SupplierCreate {
  name: string
  phone?: string
  type?: string
  notes?: string
  balance?: number
  credit_limit?: number
}

export interface SupplierPriceCreate {
  product_id: string
  supplier_id: string
  price: number
}

export interface PurchaseCreate {
  supplier_id: string
  warehouse_id: string
  notes?: string
  items: Array<{ product_id: string; qty: number; unit_cost: number }>
}

export interface DrawerTxCreate {
  type: string
  amount: number
  note?: string
  customer_id?: string
  category_id?: string
  payment_method?: string
  wallet_id?: string
}

export interface ShiftTransfer {
  to_user_id: string
  amount: number
}

export interface RevenueDelivery {
  amount: number
  safe_id: string
  manager_id: string
  manager_password: string
  notes?: string
}

export interface ShiftClose {
  closing_balance: number
  next_day_drawer: number
  manager_id: string
  manager_password: string
}

export interface StockMovementCreate {
  product_id: string
  warehouse_id: string
  movement_type: string
  qty: number
  unit_cost?: number
  unit_price?: number
  note?: string
}

export interface StockBulkAdjust {
  product_id: string
  warehouse_id: string
  qty: number
  unit_cost?: number
}

export interface StockTransfer {
  product_id: string
  from_warehouse_id: string
  to_warehouse_id: string
  qty: number
  note?: string
}

export interface LedgerEntry {
  date?: string
  type: string
  ref: string
  note?: string
  party?: string
  credit: number
  debit: number
  balance: number
  items?: Array<{ name: string; qty: number; unit_price: number; total: number }>
}

export interface ShiftSummaryData {
  expected_balance: number
  cash_in_drawer: number
  sales_total?: number
  transaction_count?: number
  payment_breakdown: Array<{ method: string; total: number; wallet_name?: string; wallet_type?: string }>
  wallet_tx_breakdown: Array<{ wallet_name: string; wallet_type: string; tx_type: string; total: number }>
}

export interface SaleDetail {
  id: string
  invoice_number: string
  net_total: number
  discount_amount: number
  paid_amount: number
  returns_total: number
  is_credit: boolean
  payment_method: string
  sale_mode: string
  status: string
  customer_id: string | null
  customer_name?: string
  warehouse_id: string
  shift_id?: string
  created_at: string
  items: Array<{
    id: string
    product_id: string
    product_name?: string
    qty: number
    unit_price: number
    unit_cost: number
    discount: number
    item_discount?: number
    item_discount_pct?: number
  }>
}

export interface ConfirmDeleteItem {
  sale_id: string
  item_id: string
  product_name: string
}

export interface ConfirmDeleteTx {
  tx_id: string
  type_ar: string
  note?: string
}
