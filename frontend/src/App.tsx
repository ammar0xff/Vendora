import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { persistQueryClient } from '@tanstack/react-query-persist-client'
import { Toaster } from 'react-hot-toast'
import { useAuthStore } from './store/auth'
import { persister } from './store/queryPersister'
import Layout from './components/layout/Layout'
import LoginPage from './pages/LoginPage'
import DashboardPage from './pages/dashboard/DashboardPage'
import POSPage from './pages/pos/POSPage'
import InventoryPage from './pages/inventory/InventoryPage'
import ShiftsPage from './pages/shifts/ShiftsPage'
import ArchivePage from './pages/archive/ArchivePage'
import SuppliersPage from './pages/suppliers/SuppliersPage'
import SupplierPricesPage from './pages/suppliers/SupplierPricesPage'
import PurchasesPage from './pages/purchases/PurchasesPage'
import PurchaseOrdersPage from './pages/purchases/PurchaseOrdersPage'
import StockAdjustmentsPage from './pages/stock/StockAdjustmentsPage'
import StocktakingPage from './pages/stock/StocktakingPage'
import SafesPage from './pages/safes/SafesPage'
import AccountingPage from './pages/accounting/AccountingPage'
import UsersPage from './pages/users/UsersPage'
import SettingsPage from './pages/settings/SettingsPage'
import QuotationsPage from './pages/quotations/QuotationsPage'
import SalesPage from './pages/sales/SalesPage'
import OperationsPage from './pages/operations/OperationsPage'
import CustomersPage from './pages/customers/CustomersPage'
import AdminPage from './pages/admin/AdminPage'
import PayrollPage from './pages/payroll/PayrollPage'
import ExpensesPage from './pages/expenses/ExpensesPage'
import CashFlowPage from './pages/cashflow/CashFlowPage'
import AgingPage from './pages/aging/AgingPage'
import AuditLogPage from './pages/audit/AuditLogPage'
import OfflineSync from './components/OfflineSync'
import OfflineBanner from './components/OfflineBanner'

const qc = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 30_000,
      retry: 1,
      gcTime: 1000 * 60 * 60 * 24,
    },
  },
})

persistQueryClient({
  queryClient: qc,
  persister,
  maxAge: 1000 * 60 * 60 * 24,
})

function ProtectedRoute({ children, perm }: { children: React.ReactNode; perm?: string }) {
  const { token, user } = useAuthStore()
  if (!token) return <Navigate to="/login" replace />
  if (perm) {
    const role = (user as any)?.role
    const perms: string[] = (user as any)?.permissions || []
    if (role !== 'admin' && !perms.includes(perm)) {
      return <Layout><div className="flex flex-col items-center justify-center h-[60vh] gap-4 text-center">
        <div className="text-5xl">🔒</div>
        <h2 className="text-xl font-black text-slate-800">غير مصرح</h2>
        <p className="text-slate-500 text-sm">ليس لديك صلاحية الوصول لهذه الصفحة</p>
      </div></Layout>
    }
  }
  return <Layout>{children}</Layout>
}

import { useEffect } from 'react'
import { useQuery } from '@tanstack/react-query'
import { settingsApi } from './api/endpoints'

function FaviconUpdater() {
  const { data: settings } = useQuery({ queryKey: ['settings'], queryFn: settingsApi.get, staleTime: 60_000, retry: false })
  useEffect(() => {
    const logo = settings?.logo_url
    const name = settings?.store_name || 'ERP'
    document.title = name
    const link = document.querySelector<HTMLLinkElement>("link[rel='icon']") || (() => {
      const el = document.createElement('link'); el.rel = 'icon'; document.head.appendChild(el); return el
    })()
    if (logo) {
      link.href = logo + '?v=' + Date.now()
    } else {
      link.href = '/favicon.svg'
    }
  }, [settings?.logo_url, settings?.store_name])
  return null
}

export default function App() {
  return (
    <QueryClientProvider client={qc}>
      <OfflineBanner />
      <OfflineSync />
      <FaviconUpdater />
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<LoginPage />} />
          <Route path="/" element={<ProtectedRoute><DashboardPage /></ProtectedRoute>} />
          <Route path="/pos" element={<ProtectedRoute perm="pos"><POSPage /></ProtectedRoute>} />
          <Route path="/sales" element={<ProtectedRoute perm="sales"><SalesPage /></ProtectedRoute>} />
          <Route path="/quotations" element={<ProtectedRoute perm="quotations"><QuotationsPage /></ProtectedRoute>} />
          <Route path="/payroll" element={<ProtectedRoute perm="payroll"><PayrollPage /></ProtectedRoute>} />
          <Route path="/admin" element={<ProtectedRoute perm="admin"><AdminPage /></ProtectedRoute>} />
          <Route path="/customers" element={<ProtectedRoute perm="customers"><CustomersPage /></ProtectedRoute>} />
          <Route path="/operations" element={<ProtectedRoute perm="operations"><OperationsPage /></ProtectedRoute>} />
          <Route path="/inventory" element={<ProtectedRoute perm="inventory"><InventoryPage /></ProtectedRoute>} />
          <Route path="/shifts" element={<ProtectedRoute perm="shifts"><ShiftsPage /></ProtectedRoute>} />
          <Route path="/reports" element={<Navigate to="/accounting" replace />} />
          <Route path="/archive" element={<ProtectedRoute perm="archive"><ArchivePage /></ProtectedRoute>} />
          <Route path="/expenses" element={<ProtectedRoute perm="finance"><ExpensesPage /></ProtectedRoute>} />
          <Route path="/cashflow" element={<ProtectedRoute perm="finance"><CashFlowPage /></ProtectedRoute>} />
          <Route path="/aging" element={<ProtectedRoute perm="finance"><AgingPage /></ProtectedRoute>} />
          <Route path="/audit-log" element={<ProtectedRoute perm="admin"><AuditLogPage /></ProtectedRoute>} />
          <Route path="/suppliers" element={<ProtectedRoute perm="inventory"><SuppliersPage /></ProtectedRoute>} />
          <Route path="/supplier-prices" element={<ProtectedRoute perm="operations"><SupplierPricesPage /></ProtectedRoute>} />
          <Route path="/purchases" element={<ProtectedRoute perm="inventory"><PurchasesPage /></ProtectedRoute>} />
          <Route path="/purchase-orders" element={<ProtectedRoute perm="inventory"><PurchaseOrdersPage /></ProtectedRoute>} />
          <Route path="/stock-adjustments" element={<ProtectedRoute perm="inventory"><StockAdjustmentsPage /></ProtectedRoute>} />
          <Route path="/stocktaking" element={<ProtectedRoute perm="inventory"><StocktakingPage /></ProtectedRoute>} />
          <Route path="/safes" element={<ProtectedRoute perm="finance"><SafesPage /></ProtectedRoute>} />
          <Route path="/accounting" element={<ProtectedRoute perm="reports"><AccountingPage /></ProtectedRoute>} />
          <Route path="/users" element={<ProtectedRoute perm="users"><UsersPage /></ProtectedRoute>} />
          <Route path="/settings" element={<ProtectedRoute perm="settings"><SettingsPage /></ProtectedRoute>} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
      <Toaster position="top-center" toastOptions={{
        style: { fontFamily: 'Cairo, sans-serif', direction: 'rtl', borderRadius: '12px' },
        success: { style: { background: '#f0fdf4', border: '1px solid #bbf7d0', color: '#166534' } },
        error: { style: { background: '#fef2f2', border: '1px solid #fecaca', color: '#991b1b' } },
      }} />
    </QueryClientProvider>
  )
}
