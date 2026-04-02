import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { Toaster } from 'react-hot-toast'
import { useAuthStore } from './store/auth'
import Layout from './components/layout/Layout'
import LoginPage from './pages/LoginPage'
import DashboardPage from './pages/dashboard/DashboardPage'
import POSPage from './pages/pos/POSPage'
import InventoryPage from './pages/inventory/InventoryPage'
import ShiftsPage from './pages/shifts/ShiftsPage'
import ReportsPage from './pages/reports/ReportsPage'
import ArchivePage from './pages/archive/ArchivePage'
import SuppliersPage from './pages/suppliers/SuppliersPage'
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
import FinanceLedgerPage from './pages/finance/FinanceLedgerPage'

const qc = new QueryClient({ defaultOptions: { queries: { staleTime: 30_000, retry: 1 } } })

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { token } = useAuthStore()
  if (!token) return <Navigate to="/login" replace />
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
      <FaviconUpdater />
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<LoginPage />} />
          <Route path="/" element={<ProtectedRoute><DashboardPage /></ProtectedRoute>} />
          <Route path="/pos" element={<ProtectedRoute><POSPage /></ProtectedRoute>} />
          <Route path="/sales" element={<ProtectedRoute><SalesPage /></ProtectedRoute>} />
          <Route path="/quotations" element={<ProtectedRoute><QuotationsPage /></ProtectedRoute>} />
          <Route path="/finance" element={<ProtectedRoute><FinanceLedgerPage /></ProtectedRoute>} />
          <Route path="/payroll" element={<ProtectedRoute><PayrollPage /></ProtectedRoute>} />
          <Route path="/admin" element={<ProtectedRoute><AdminPage /></ProtectedRoute>} />
          <Route path="/customers" element={<ProtectedRoute><CustomersPage /></ProtectedRoute>} />
          <Route path="/operations" element={<ProtectedRoute><OperationsPage /></ProtectedRoute>} />
          <Route path="/inventory" element={<ProtectedRoute><InventoryPage /></ProtectedRoute>} />
          <Route path="/shifts" element={<ProtectedRoute><ShiftsPage /></ProtectedRoute>} />
          <Route path="/reports" element={<ProtectedRoute><ReportsPage /></ProtectedRoute>} />
          <Route path="/archive" element={<ProtectedRoute><ArchivePage /></ProtectedRoute>} />
          <Route path="/suppliers" element={<ProtectedRoute><SuppliersPage /></ProtectedRoute>} />
          <Route path="/purchases" element={<ProtectedRoute><PurchasesPage /></ProtectedRoute>} />
          <Route path="/purchase-orders" element={<ProtectedRoute><PurchaseOrdersPage /></ProtectedRoute>} />
          <Route path="/stock-adjustments" element={<ProtectedRoute><StockAdjustmentsPage /></ProtectedRoute>} />
          <Route path="/stocktaking" element={<ProtectedRoute><StocktakingPage /></ProtectedRoute>} />
          <Route path="/safes" element={<ProtectedRoute><SafesPage /></ProtectedRoute>} />
          <Route path="/accounting" element={<ProtectedRoute><AccountingPage /></ProtectedRoute>} />
          <Route path="/users" element={<ProtectedRoute><UsersPage /></ProtectedRoute>} />
          <Route path="/settings" element={<ProtectedRoute><SettingsPage /></ProtectedRoute>} />
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
