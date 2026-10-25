import { Navigate, Route, Routes } from "react-router-dom";
import { useAuth } from "@/stores/auth";
import Shell from "@/components/Shell";
import LoginPage from "@/features/auth/LoginPage";
import DashboardPage from "@/features/dashboard/DashboardPage";
import PosPage from "@/features/pos/PosPage";
import ProductsPage from "@/features/products/ProductsPage";
import SalesPage from "@/features/sales/SalesPage";
import ListPage from "@/features/common/ListPage";
import PurchasesPage from "@/features/purchases/PurchasesPage";
import PayrollPage from "@/features/hr/PayrollPage";
import ShiftsPage from "@/features/shifts/ShiftsPage";
import CustomersPage from "@/features/customers/CustomersPage";
import SettingsPage from "@/features/settings/SettingsPage";
import FinancePage from "@/features/finance/FinancePage";
import SuppliersPage from "@/features/suppliers/SuppliersPage";
import UsersPage from "@/features/users/UsersPage";
import HrPage from "@/features/hr/HrPage";
import InventoryPage from "@/features/inventory/InventoryPage";
import ReportsPage from "@/features/reports/ReportsPage";
import ArchivePage from "@/features/archive/ArchivePage";

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
  return <>{children}</>;
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
        <Route path="/operations" element={<Guard perm="operations"><ListPage module="operations" /></Guard>} />
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
