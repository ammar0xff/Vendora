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
        <Route path="/inventory" element={<Guard perm="inventory"><ListPage module="inventory" /></Guard>} />
        <Route path="/operations" element={<Guard perm="operations"><ListPage module="operations" /></Guard>} />
        <Route path="/purchases" element={<Guard perm="purchases"><PurchasesPage /></Guard>} />
        <Route path="/customers" element={<Guard perm="customers"><CustomersPage /></Guard>} />
        <Route path="/suppliers" element={<Guard perm="customers"><ListPage module="suppliers" /></Guard>} />
        <Route path="/finance" element={<Guard perm="finance"><ListPage module="finance" /></Guard>} />
        <Route path="/hr" element={<Guard perm="payroll"><ListPage module="hr" /></Guard>} />
        <Route path="/hr/payroll" element={<Guard perm="payroll"><PayrollPage /></Guard>} />
        <Route path="/shifts" element={<Guard perm="shifts"><ShiftsPage /></Guard>} />
        <Route path="/archive" element={<Guard perm="archive"><ListPage module="archive" /></Guard>} />
        <Route path="/reports" element={<Guard perm="reports"><ListPage module="reports" /></Guard>} />
        <Route path="/users" element={<Guard perm="users"><ListPage module="users" /></Guard>} />
        <Route path="/settings" element={<Guard perm="settings"><SettingsPage /></Guard>} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Route>
    </Routes>
  );
}
