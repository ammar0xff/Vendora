import { useState } from "react";
import { NavLink, Outlet, useNavigate } from "react-router-dom";
import {
  Archive, BarChart3, Boxes, ChevronLeft, LayoutDashboard, LogOut, Menu, Moon,
  Package, Receipt, Settings, ShoppingCart, Store, Sun, Truck, Users, UserSquare2,
  Wallet, Wrench, Clock,
} from "lucide-react";
import { useAuth } from "@/stores/auth";

const NAV: { to: string; label: string; perm: string; icon: React.ReactNode }[] = [
  { to: "/", label: "الرئيسية", perm: "", icon: <LayoutDashboard size={18} /> },
  { to: "/pos", label: "نقطة البيع", perm: "pos", icon: <ShoppingCart size={18} /> },
  { to: "/sales", label: "المبيعات", perm: "sales", icon: <Receipt size={18} /> },
  { to: "/products", label: "المنتجات", perm: "inventory", icon: <Package size={18} /> },
  { to: "/inventory", label: "المخزون", perm: "inventory", icon: <Boxes size={18} /> },
  { to: "/operations", label: "العمليات", perm: "operations", icon: <Wrench size={18} /> },
  { to: "/purchases", label: "المشتريات", perm: "purchases", icon: <Truck size={18} /> },
  { to: "/customers", label: "العملاء", perm: "customers", icon: <Users size={18} /> },
  { to: "/suppliers", label: "الموردون", perm: "customers", icon: <Truck size={18} className="rotate-180" /> },
  { to: "/finance", label: "المالية", perm: "finance", icon: <Wallet size={18} /> },
  { to: "/hr", label: "الموارد البشرية", perm: "payroll", icon: <UserSquare2 size={18} /> },
  { to: "/shifts", label: "الورديات", perm: "shifts", icon: <Clock size={18} /> },
  { to: "/archive", label: "الأرشيف", perm: "archive", icon: <Archive size={18} /> },
  { to: "/reports", label: "التقارير", perm: "reports", icon: <BarChart3 size={18} /> },
  { to: "/users", label: "المستخدمون", perm: "users", icon: <Users size={18} /> },
  { to: "/settings", label: "الإعدادات", perm: "settings", icon: <Settings size={18} /> },
];

export default function Shell() {
  const { user, can, logout } = useAuth();
  const navigate = useNavigate();
  const [collapsed, setCollapsed] = useState(() => localStorage.getItem("vendora.sidebar") === "1");
  const [dark, setDark] = useState(() => document.documentElement.classList.contains("dark"));
  const [mobileOpen, setMobileOpen] = useState(false);

  function toggleSidebar() {
    setCollapsed((c) => {
      localStorage.setItem("vendora.sidebar", c ? "0" : "1");
      return !c;
    });
  }
  function toggleTheme() {
    setDark((d) => {
      document.documentElement.classList.toggle("dark", !d);
      localStorage.setItem("vendora.theme", !d ? "dark" : "light");
      return !d;
    });
  }
  function doLogout() {
    logout();
    navigate("/login", { replace: true });
  }

  const items = NAV.filter((n) => !n.perm || can(n.perm));

  const sidebar = (
    <nav className="flex h-full flex-col gap-1 p-3" aria-label="القائمة الرئيسية">
      <div className="mb-4 flex items-center gap-2 px-2 py-1">
        <div className="grid h-9 w-9 shrink-0 place-items-center rounded-xl bg-brand font-black text-brand-ink">ف</div>
        {!collapsed && <span className="text-lg font-extrabold">فيندورا</span>}
      </div>
      {items.map((n) => (
        <NavLink
          key={n.to}
          to={n.to}
          end={n.to === "/"}
          onClick={() => setMobileOpen(false)}
          className={({ isActive }) =>
            `flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition ${
              isActive ? "bg-brand text-brand-ink" : "text-muted hover:bg-elevated hover:text-ink"
            } ${collapsed ? "justify-center" : ""}`
          }
          title={n.label}
        >
          {n.icon}
          {!collapsed && <span>{n.label}</span>}
        </NavLink>
      ))}
      <div className="mt-auto">
        <button
          onClick={toggleSidebar}
          className={`hidden w-full items-center gap-3 rounded-lg px-3 py-2 text-sm text-muted hover:bg-elevated hover:text-ink lg:flex ${collapsed ? "justify-center" : ""}`}
          aria-label={collapsed ? "توسيع القائمة" : "طي القائمة"}
        >
          <ChevronLeft size={18} className={`transition-transform ${collapsed ? "rotate-180" : ""}`} />
          {!collapsed && <span>طي القائمة</span>}
        </button>
      </div>
    </nav>
  );

  return (
    <div className="flex min-h-screen bg-bg">
      {/* Desktop sidebar */}
      <aside
        className={`sticky top-0 hidden h-screen shrink-0 border-l border-line bg-surface lg:block ${
          collapsed ? "w-[68px]" : "w-60"
        }`}
      >
        {sidebar}
      </aside>

      {/* Mobile drawer */}
      {mobileOpen && (
        <div className="fixed inset-0 z-40 lg:hidden" onMouseDown={(e) => e.target === e.currentTarget && setMobileOpen(false)}>
          <div className="absolute inset-0 bg-black/50" />
          <aside className="absolute right-0 top-0 h-full w-64 border-l border-line bg-surface">{sidebar}</aside>
        </div>
      )}

      <div className="flex min-w-0 flex-1 flex-col">
        <header className="sticky top-0 z-30 flex items-center gap-3 border-b border-line bg-surface/95 px-4 py-3 backdrop-blur">
          <button className="rounded-lg p-2 hover:bg-elevated lg:hidden" onClick={() => setMobileOpen(true)} aria-label="القائمة">
            <Menu size={20} />
          </button>
          <div className="min-w-0 flex-1">
            <p className="truncate text-sm font-bold">{user?.full_name}</p>
            <p className="text-xs text-muted">{user?.username}</p>
          </div>
          <a
            href="https://vendora-backend-six.vercel.app/api/storefront"
            target="_blank"
            rel="noreferrer"
            className="hidden items-center gap-2 rounded-lg border border-line px-3 py-2 text-sm text-muted hover:text-ink sm:flex"
          >
            <Store size={16} />
            المتجر
          </a>
          <button onClick={toggleTheme} className="rounded-lg p-2 hover:bg-elevated" aria-label="تبديل السمة">
            {dark ? <Sun size={18} /> : <Moon size={18} />}
          </button>
          <button onClick={doLogout} className="rounded-lg p-2 text-danger hover:bg-elevated" aria-label="تسجيل الخروج">
            <LogOut size={18} />
          </button>
        </header>
        <main className="min-w-0 flex-1 p-4 lg:p-6">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
