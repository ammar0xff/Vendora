import { lazy, Suspense } from "react";
const DashboardPage = lazy(() => import("@/features/dashboard/DashboardPage"));
const PosPage = lazy(() => import("@/features/pos/PosPage"));
const ProductsPage = lazy(() => import("@/features/products/ProductsPage"));
const SalesPage = lazy(() => import("@/features/sales/SalesPage"));
const PurchasesPage = lazy(() => import("@/features/purchases/PurchasesPage"));
const PayrollPage = lazy(() => import("@/features/hr/PayrollPage"));
const ShiftsPage = lazy(() => import("@/features/shifts/ShiftsPage"));
const CustomersPage = lazy(() => import("@/features/customers/CustomersPage"));
const SettingsPage = lazy(() => import("@/features/settings/SettingsPage"));
const FinancePage = lazy(() => import("@/features/finance/FinancePage"));
const SuppliersPage = lazy(() => import("@/features/suppliers/SuppliersPage"));
const UsersPage = lazy(() => import("@/features/users/UsersPage"));
const HrPage = lazy(() => import("@/features/hr/HrPage"));
const InventoryPage = lazy(() => import("@/features/inventory/InventoryPage"));
const ReportsPage = lazy(() => import("@/features/reports/ReportsPage"));
const ArchivePage = lazy(() => import("@/features/archive/ArchivePage"));
const OperationsPage = lazy(() => import("@/features/operations/OperationsPage"));
import { Navigate, Route, Routes } from "react-router-dom";
import { useAuth } from "@/stores/auth";
import Shell from "@/components/AppShell";
import LoginPage from "@/features/auth/LoginPage";

function Page({ children }: { children: React.ReactNode }) {
  return <Suspense fallback={<div className="grid place-items-center p-16"><span className="h-6 w-6 animate-spin rounded-full border-2 border-brand border-t-transparent" /></div>}>{children}</Suspense>;
}

function Guard({ perm, children }: { perm: string; children: React.ReactNode }) {
  const { token, user } = useAuth();
  if (!token || !user) return <Navigate to="/login" replace />;
  if (perm && !user.permissions.includes(perm)) {
    return (
      <div className="p-10 text-center text-muted">
        ليس لديك صلاحية للوصول إلى هذه الصفحة
      </div>
    );
  }
  return <Page>{children}</Page>;
}

export default function App() {
  const token = useAuth((s) => s.token);
  return (
    <Routes>
      <Route path="/login" element={token ? <Navigate to="/" replace /> : <LoginPage />} />
      <Route
        element={
          <Guard perm="">
            <Shell />
          </Guard>
        }
      >
        <Route index element={<DashboardPage />} />
        <Route path="/pos" element={<Guard perm="pos"><PosPage /></Guard>} />
        <Route path="/products" element={<Guard perm="inventory"><ProductsPage /></Guard>} />
        <Route path="/sales" element={<Guard perm="sales"><SalesPage /></Guard>} />
        <Route path="/inventory" element={<Guard perm="inventory"><InventoryPage /></Guard>} />
        <Route path="/operations" element={<Guard perm="operations"><OperationsPage /></Guard>} />
        <Route path="/purchases" element={<Guard perm="purchases"><PurchasesPage /></Guard>} />
        <Route path="/customers" element={<Guard perm="customers"><CustomersPage /></Guard>} />
        <Route path="/suppliers" element={<Guard perm="customers"><SuppliersPage /></Guard>} />
        <Route path="/finance" element={<Guard perm="finance"><FinancePage /></Guard>} />
        <Route path="/hr" element={<Guard perm="payroll"><HrPage /></Guard>} />
        <Route path="/hr/payroll" element={<Guard perm="payroll"><PayrollPage /></Guard>} />
        <Route path="/shifts" element={<Guard perm="shifts"><ShiftsPage /></Guard>} />
        <Route path="/archive" element={<Guard perm="archive"><ArchivePage /></Guard>} />
        <Route path="/reports" element={<Guard perm="reports"><ReportsPage /></Guard>} />
        <Route path="/users" element={<Guard perm="users"><UsersPage /></Guard>} />
        <Route path="/settings" element={<Guard perm="settings"><SettingsPage /></Guard>} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Route>
    </Routes>
  );
}
