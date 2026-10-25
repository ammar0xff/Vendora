import {
  Archive, ArrowLeftRight, BarChart3, Boxes, Clock, Contact, LayoutDashboard, Package, Receipt,
  Settings, ShieldCheck, ShoppingCart, Truck, UserCog, Wallet, type LucideIcon,
} from "lucide-react";

export type NavItem = {
  to: string;
  label: string;
  perm: string; // "" = always visible; checked against the user's real permissions
  icon: LucideIcon;
  group: "main" | "stock" | "money" | "admin";
};

export const NAV_ITEMS: NavItem[] = [
  { to: "/", label: "لوحة التحكم", perm: "", icon: LayoutDashboard, group: "main" },
  { to: "/pos", label: "نقطة البيع", perm: "pos", icon: ShoppingCart, group: "main" },
  { to: "/sales", label: "المبيعات", perm: "sales", icon: Receipt, group: "main" },
  { to: "/shifts", label: "الورديات", perm: "shifts", icon: Clock, group: "main" },
  { to: "/products", label: "المنتجات", perm: "inventory", icon: Package, group: "stock" },
  { to: "/inventory", label: "المخزون", perm: "inventory", icon: Boxes, group: "stock" },
  { to: "/operations", label: "العمليات", perm: "operations", icon: ArrowLeftRight, group: "stock" },
  { to: "/purchases", label: "المشتريات", perm: "purchases", icon: Truck, group: "stock" },
  { to: "/customers", label: "العملاء", perm: "customers", icon: Contact, group: "money" },
  { to: "/suppliers", label: "الموردون", perm: "customers", icon: Truck, group: "money" },
  { to: "/finance", label: "المالية", perm: "finance", icon: Wallet, group: "money" },
  { to: "/reports", label: "التقارير", perm: "reports", icon: BarChart3, group: "money" },
  { to: "/hr", label: "الموظفون", perm: "payroll", icon: UserCog, group: "admin" },
  { to: "/hr/payroll", label: "الرواتب", perm: "payroll", icon: Wallet, group: "admin" },
  { to: "/archive", label: "الأرشيف", perm: "archive", icon: Archive, group: "admin" },
  { to: "/users", label: "المستخدمون والصلاحيات", perm: "users", icon: ShieldCheck, group: "admin" },
  { to: "/settings", label: "الإعدادات", perm: "settings", icon: Settings, group: "admin" },
];

export const NAV_GROUPS: Record<NavItem["group"], string> = {
  main: "التشغيل اليومي",
  stock: "المخزون والتوريد",
  money: "المال والعلاقات",
  admin: "الإدارة",
};
