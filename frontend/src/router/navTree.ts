import { lazy, type ComponentType } from 'react'
import type { LucideIcon } from 'lucide-react'
import {
  LayoutDashboard, ShoppingCart, Package, BarChart3, Archive, Settings, Users,
  FileText, Building2, Receipt, Truck, UserCheck, ShieldCheck, DollarSign,
  ClipboardList, Vault, Clock, TrendingDown, Tag, Warehouse, Wallet, Lock,
} from 'lucide-react'

export interface NavTab {
  path: string
  label: string
  icon?: LucideIcon
  Component: ComponentType
}

export interface NavPage {
  path: string
  label: string
  icon: LucideIcon
  perm: string | null
  Component: ComponentType
  quick?: boolean
  hidden?: boolean
  section?: NavTab[]
  defaultChild?: string
}

export interface NavGroup {
  key: string
  label: string
  icon: LucideIcon
  items: NavPage[]
}

export const NAV_GROUPS: NavGroup[] = [
  {
    key: 'home',
    label: 'الرئيسية',
    icon: LayoutDashboard,
    items: [
      { path: '/admin', label: 'لوحة التحكم', icon: LayoutDashboard, perm: null, Component: lazy(() => import('../pages/dashboard/DashboardPage')) },
    ],
  },
  {
    key: 'sales',
    label: 'المبيعات',
    icon: ShoppingCart,
    items: [
      { path: '/pos', label: 'نقطة البيع', icon: ShoppingCart, perm: 'pos', quick: true, Component: lazy(() => import('../pages/pos/POSPage')) },
      { path: '/sales', label: 'المبيعات والمرتجعات', icon: Receipt, perm: 'sales', quick: true, Component: lazy(() => import('../pages/sales/SalesPage')) },
      { path: '/quotations', label: 'عروض الأسعار', icon: FileText, perm: 'quotations', quick: true, Component: lazy(() => import('../pages/quotations/QuotationsPage')) },
      { path: '/customers', label: 'العملاء', icon: UserCheck, perm: 'customers', quick: true, Component: lazy(() => import('../pages/customers/CustomersPage')) },
    ],
  },
  {
    key: 'inventory',
    label: 'المخزون',
    icon: Package,
    items: [
      { path: '/inventory', label: 'الأصناف', icon: Package, perm: 'inventory', quick: true, Component: lazy(() => import('../pages/inventory/InventoryPage')) },
      { path: '/categories', label: 'الفئات والتصنيفات', icon: Tag, perm: 'inventory', Component: lazy(() => import('../pages/categories/CategoriesPage')) },
      { path: '/warehouses', label: 'المخازن', icon: Warehouse, perm: 'inventory', Component: lazy(() => import('../pages/warehouses/WarehousesPage')) },
      { path: '/suppliers', label: 'الموردون', icon: Building2, perm: 'inventory', Component: lazy(() => import('../pages/suppliers/SuppliersPage')) },
      { path: '/supplier-prices', label: 'مقارنة أسعار الموردين', icon: TrendingDown, perm: 'operations', Component: lazy(() => import('../pages/suppliers/SupplierPricesPage')) },
      { path: '/purchases', label: 'سجل المشتريات', icon: Receipt, perm: 'inventory', quick: true, Component: lazy(() => import('../pages/purchases/PurchasesPage')) },
      { path: '/purchase-orders', label: 'أوامر الشراء', icon: ClipboardList, perm: 'inventory', Component: lazy(() => import('../pages/purchases/PurchaseOrdersPage')) },
      { path: '/stock-adjustments', label: 'تعديلات المخزون', icon: TrendingDown, perm: 'inventory', Component: lazy(() => import('../pages/stock/StockAdjustmentsPage')) },
      {
        path: '/operations',
        label: 'المشتريات والعمليات',
        icon: Truck,
        perm: 'operations',
        Component: lazy(() => import('../pages/operations/OperationsLayout')),
        defaultChild: 'ops',
        section: [
          { path: 'ops', label: 'العمليات والنقل', Component: lazy(() => import('../pages/operations/OperationsOpsPage')) },
          { path: 'purchases', label: 'فواتير المشتريات', Component: lazy(() => import('../pages/purchases/PurchasesPage')) },
        ],
      },
      { path: '/stocktaking', label: 'الجرد', icon: ClipboardList, perm: 'inventory', Component: lazy(() => import('../pages/stock/StocktakingPage')) },
      { path: '/purchase-bill', label: 'فاتورة مشتريات', icon: ShoppingCart, perm: 'inventory', Component: lazy(() => import('../pages/purchases/PurchaseBillPage')) },
    ],
  },
  {
    key: 'finance',
    label: 'المالية',
    icon: BarChart3,
    items: [
      { path: '/accounting', label: 'الحسابات', icon: BarChart3, perm: 'reports', Component: lazy(() => import('../pages/accounting/AccountingLayout')), defaultChild: 'pnl', section: [
        { path: 'pnl', label: 'قائمة الدخل', icon: TrendingDown, Component: lazy(() => import('../pages/accounting/ReportsContent')) },
        { path: 'ledger', label: 'الميزان المالي', icon: BarChart3, Component: lazy(() => import('../pages/accounting/FinanceLedgerContent')) },
        { path: 'ledger-book', label: 'دفتر الأستاذ', icon: ClipboardList, Component: lazy(() => import('../pages/reports/ReportsLedgerPage')) },
        { path: 'stats', label: 'الإحصائيات', icon: BarChart3, Component: lazy(() => import('../pages/reports/ReportsStatsPage')) },
        { path: 'sales', label: 'تقارير المبيعات', icon: Receipt, Component: lazy(() => import('../pages/accounting/SalesReportContent')) },
        { path: 'debts', label: 'المديونيات', icon: DollarSign, Component: lazy(() => import('../pages/accounting/DebtsContent')) },
      ] },
      { path: '/aging', label: 'أعمار الديون', icon: Clock, perm: 'finance', Component: lazy(() => import('../pages/aging/AgingPage')) },
      { path: '/cashflow', label: 'التدفق النقدي', icon: BarChart3, perm: 'finance', Component: lazy(() => import('../pages/cashflow/CashFlowPage')) },
      { path: '/safes', label: 'الخزن المالية', icon: Vault, perm: 'finance', quick: true, Component: lazy(() => import('../pages/safes/SafesPage')) },
      { path: '/wallets', label: 'وسائل الدفع', icon: Wallet, perm: 'finance', Component: lazy(() => import('../pages/wallets/WalletsPage')) },
      { path: '/periods', label: 'إغلاق الشهور', icon: Lock, perm: 'finance', Component: lazy(() => import('../pages/periods/PeriodsPage')) },
      { path: '/expenses', label: 'المصروفات', icon: DollarSign, perm: 'finance', quick: true, Component: lazy(() => import('../pages/expenses/ExpensesPage')) },
      { path: '/shifts', label: 'الورديات', icon: Clock, perm: 'shifts', Component: lazy(() => import('../pages/shifts/ShiftsPage')) },
      { path: '/archive', label: 'الأرشيف', icon: Archive, perm: 'archive', Component: lazy(() => import('../pages/archive/ArchivePage')) },
    ],
  },
  {
    key: 'hr',
    label: 'الموارد البشرية',
    icon: DollarSign,
    items: [
      { path: '/payroll', label: 'الرواتب والحضور', icon: DollarSign, perm: 'payroll', Component: lazy(() => import('../pages/payroll/PayrollPage')) },
    ],
  },
  {
    key: 'admin',
    label: 'الإدارة',
    icon: Settings,
    items: [
      { path: '/users', label: 'المستخدمون', icon: Users, perm: 'users', Component: lazy(() => import('../pages/users/UsersPage')) },
      { path: '/audit-log', label: 'سجل التدقيق', icon: ShieldCheck, perm: 'admin', Component: lazy(() => import('../pages/audit/AuditLogPage')) },
      {
        path: '/settings',
        label: 'الإعدادات',
        icon: Settings,
        perm: 'settings',
        Component: lazy(() => import('../pages/settings/SettingsLayout')),
        defaultChild: 'general',
        section: [
          { path: 'general', label: 'إعدادات المتجر', icon: Settings, Component: lazy(() => import('../pages/settings/GeneralSettingsPage')) },
          { path: 'appearance', label: 'الواجهة والمظهر', icon: Settings, Component: lazy(() => import('../pages/settings/AppearancePage')) },
        ],
      },
    ],
  },
]

export const HIDDEN_PAGES: NavPage[] = [
  { path: '/admin/overview', label: 'لوحة التحكم', icon: LayoutDashboard, perm: 'admin', hidden: true, Component: lazy(() => import('../pages/admin/AdminPage')) },
]

export function allNavPages(): NavPage[] {
  return [...NAV_GROUPS.flatMap(g => g.items), ...HIDDEN_PAGES]
}

export function isTabActive(page: NavPage, pathname: string): boolean {
  return !!page.section?.some(t => pathname === `${page.path}/${t.path}`)
}

export function findNavPage(pathname: string): NavPage | null {
  if (pathname === '/admin') return NAV_GROUPS[0].items[0]
  const pages = allNavPages()
  return pages.find(p => pathname === p.path || isTabActive(p, pathname)) || null
}