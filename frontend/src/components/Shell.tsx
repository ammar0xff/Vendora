import { useState } from "react";
import { NavLink, Outlet, useLocation, useNavigate } from "react-router-dom";
import { AnimatePresence, motion } from "motion/react";
import {
  Archive, BarChart3, Boxes, ChevronLeft, Clock, Coins, LayoutDashboard, LogOut,
  Menu, Moon, Package, Receipt, Settings, ShoppingCart, Store, Sun, Truck,
  UserSquare2, Users, Wallet, Wrench,
} from "lucide-react";
import { useAuth } from "@/stores/auth";
import { PageTransition, spring } from "@/components/motion";

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
  { to: "/hr", label: "الموظفون", perm: "payroll", icon: <UserSquare2 size={18} /> },
  { to: "/hr/payroll", label: "الرواتب", perm: "payroll", icon: <Coins size={18} /> },
  { to: "/shifts", label: "الورديات", perm: "shifts", icon: <Clock size={18} /> },
  { to: "/archive", label: "الأرشيف", perm: "archive", icon: <Archive size={18} /> },
  { to: "/reports", label: "التقارير", perm: "reports", icon: <BarChart3 size={18} /> },
  { to: "/users", label: "المستخدمون", perm: "users", icon: <Users size={18} /> },
  { to: "/settings", label: "الإعدادات", perm: "settings", icon: <Settings size={18} /> },
];

function NavItems({ collapsed, onNavigate }: { collapsed: boolean; onNavigate?: () => void }) {
  const { can } = useAuth();
  const items = NAV.filter((n) => !n.perm || can(n.perm));
  return (
    <nav className="flex h-full flex-col gap-1 p-3" aria-label="القائمة الرئيسية">
      <div className="mb-4 flex items-center gap-2 px-2 py-1">
        <div className="grid h-9 w-9 shrink-0 place-items-center rounded-xl bg-brand font-black text-brand-ink">ف</div>
        <AnimatePresence initial={false}>
          {!collapsed && (
            <motion.span
              initial={{ opacity: 0, x: 6 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 6 }}
              transition={{ duration: 0.15 }}
              className="text-lg font-extrabold"
            >
              فيندورا
            </motion.span>
          )}
        </AnimatePresence>
      </div>
      {items.map((n) => (
        <NavLink
          key={n.to}
          to={n.to}
          end={n.to === "/"}
          onClick={onNavigate}
          title={n.label}
          className={({ isActive }) =>
            `relative flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition ${
              isActive ? "text-brand-ink" : "text-muted hover:bg-elevated hover:text-ink"
            } ${collapsed ? "justify-center" : ""}`
          }
        >
          {({ isActive }) => (
            <>
              {isActive && (
                <motion.span
                  layoutId="nav-active-pill"
                  transition={spring}
                  className="absolute inset-0 -z-10 rounded-lg bg-brand"
                />
              )}
              {n.icon}
              {!collapsed && <span>{n.label}</span>}
            </>
          )}
        </NavLink>
      ))}
    </nav>
  );
}

export default function Shell() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
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

  return (
    <div className="flex min-h-screen bg-bg">
      {/* Desktop sidebar — animated width */}
      <motion.aside
        animate={{ width: collapsed ? 68 : 240 }}
        transition={spring}
        initial={false}
        className="sticky top-0 hidden h-screen shrink-0 overflow-hidden border-l border-line bg-surface lg:block"
      >
        <NavItems collapsed={collapsed} />
        <button
          onClick={toggleSidebar}
          className={`absolute bottom-4 left-1/2 flex -translate-x-1/2 items-center gap-3 rounded-lg px-3 py-2 text-sm text-muted transition hover:bg-elevated hover:text-ink ${
            collapsed ? "justify-center" : ""
          }`}
          aria-label={collapsed ? "توسيع القائمة" : "طي القائمة"}
        >
          <ChevronLeft size={18} className={`transition-transform duration-300 ${collapsed ? "rotate-180" : ""}`} />
          {!collapsed && <span>طي القائمة</span>}
        </button>
      </motion.aside>

      {/* Mobile drawer */}
      <AnimatePresence>
        {mobileOpen && (
          <>
            <motion.div
              className="fixed inset-0 z-40 bg-black/50 lg:hidden"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setMobileOpen(false)}
            />
            <motion.aside
              className="absolute right-0 top-0 z-50 h-full w-64 border-l border-line bg-surface lg:hidden"
              initial={{ x: "100%" }}
              animate={{ x: 0 }}
              exit={{ x: "100%" }}
              transition={spring}
            >
              <NavItems collapsed={false} onNavigate={() => setMobileOpen(false)} />
            </motion.aside>
          </>
        )}
      </AnimatePresence>

      <div className="flex min-w-0 flex-1 flex-col">
        <header className="sticky top-0 z-30 flex items-center gap-3 border-b border-line bg-surface/95 px-4 py-3 backdrop-blur">
          <button className="rounded-lg p-2 hover:bg-elevated lg:hidden" onClick={() => setMobileOpen(true)} aria-label="القائمة">
            <Menu size={20} />
          </button>
          <div className="min-w-0 flex-1">
            <p className="truncate text-sm font-bold">{user?.full_name}</p>
            <p className="truncate text-xs text-muted">{user?.username}</p>
          </div>
          <a
            href="https://vendora-backend-six.vercel.app/api/storefront"
            target="_blank"
            rel="noreferrer"
            className="hidden items-center gap-2 rounded-lg border border-line px-3 py-2 text-sm text-muted transition hover:text-ink sm:flex"
          >
            <Store size={16} />
            المتجر
          </a>
          <motion.button
            whileTap={{ scale: 0.9 }}
            onClick={toggleTheme}
            className="rounded-lg p-2 hover:bg-elevated"
            aria-label="تبديل السمة"
          >
            <AnimatePresence mode="wait" initial={false}>
              <motion.span
                key={dark ? "sun" : "moon"}
                initial={{ opacity: 0, rotate: -30 }}
                animate={{ opacity: 1, rotate: 0 }}
                exit={{ opacity: 0, rotate: 30 }}
                transition={{ duration: 0.15 }}
                className="block"
              >
                {dark ? <Sun size={18} /> : <Moon size={18} />}
              </motion.span>
            </AnimatePresence>
          </motion.button>
          <button onClick={doLogout} className="rounded-lg p-2 text-danger transition hover:bg-elevated" aria-label="تسجيل الخروج">
            <LogOut size={18} />
          </button>
        </header>
        <main className="min-w-0 flex-1 p-4 lg:p-6">
          <PageTransition routeKey={location.pathname}>
            <Outlet />
          </PageTransition>
        </main>
      </div>
    </div>
  );
}
