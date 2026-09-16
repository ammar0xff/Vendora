import { type ReactNode, useEffect, useState, useMemo } from 'react'
import { NavLink, useLocation, useNavigate } from 'react-router-dom'
import {
  LayoutDashboard, ShoppingCart, Package, BarChart3,
  Archive, Settings, Users, LogOut, FileText,
  Building2, Receipt, Truck, UserCheck, ShieldCheck,
  DollarSign, ClipboardList, Vault, Clock, TrendingDown,
  ChevronDown, PanelLeftClose, PanelLeft, Store, Boxes, X
} from 'lucide-react'
import { useAuthStore } from '../../store/auth'
import { useAppStore } from '../../store/app'
import { useQuery } from '@tanstack/react-query'
import { stockApi, settingsApi } from '../../api/endpoints'
import { fixUploadUrl } from '../../utils/format'
import { clsx } from 'clsx'
import type { Warehouse } from '../../types'

// ── Navigation structure ─────────────────────────────────────────
const NAV_GROUPS = [
  {
    key: 'home',
    label: 'الرئيسية',
    icon: LayoutDashboard,
    items: [
      { to: '/admin', perm: null, warehouseTypes: ['all'], label: 'لوحة التحكم', icon: LayoutDashboard },
    ]
  },
  {
    key: 'sales',
    label: 'المبيعات',
    icon: ShoppingCart,
    items: [
      { to: '/pos',        icon: ShoppingCart, label: 'نقطة البيع',         perm: 'pos',        warehouseTypes: ['all'] },
      { to: '/sales',      icon: Receipt,      label: 'المبيعات والمرتجعات', perm: 'sales',      warehouseTypes: ['all'] },
      { to: '/quotations', icon: FileText,      label: 'عروض الأسعار',      perm: 'quotations', warehouseTypes: ['all'] },
      { to: '/customers',  icon: UserCheck,    label: 'العملاء',            perm: 'customers',  warehouseTypes: ['all'] },
    ]
  },
  {
    key: 'inventory',
    label: 'المخزون',
    icon: Package,
    items: [
      { to: '/inventory',       icon: Package,       label: 'الأصناف',               perm: 'inventory',  warehouseTypes: ['all'] },
      { to: '/suppliers',       icon: Building2,     label: 'الموردون',              perm: 'inventory',  warehouseTypes: ['all'] },
      { to: '/supplier-prices', icon: TrendingDown,   label: 'مقارنة أسعار الموردين', perm: 'operations', warehouseTypes: ['all'] },
      { to: '/purchases',       icon: Receipt,        label: 'سجل المشتريات',         perm: 'inventory',  warehouseTypes: ['all'] },
      { to: '/purchase-orders', icon: ClipboardList,  label: 'أوامر الشراء',           perm: 'inventory',  warehouseTypes: ['all'] },
      { to: '/stock-adjustments', icon: TrendingDown,  label: 'تعديلات المخزون',       perm: 'inventory',  warehouseTypes: ['all'] },
      { to: '/operations',      icon: Truck,          label: 'المشتريات والعمليات',   perm: 'operations', warehouseTypes: ['all'] },
      { to: '/stocktaking',     icon: ClipboardList,  label: 'الجرد',                 perm: 'inventory',  warehouseTypes: ['all'] },
      { to: '/purchase-bill',   icon: ShoppingCart,   label: 'فاتورة مشتريات',        perm: 'inventory',  warehouseTypes: ['all'] },
    ]
  },
  {
    key: 'finance',
    label: 'المالية',
    icon: BarChart3,
    items: [
      { to: '/accounting', icon: BarChart3, label: 'الحسابات',      perm: 'reports',  warehouseTypes: ['all'] },
      { to: '/aging',      icon: Clock,     label: 'أعمار الديون',  perm: 'finance',  warehouseTypes: ['all'] },
      { to: '/cashflow',   icon: BarChart3, label: 'التدفق النقدي', perm: 'finance',  warehouseTypes: ['all'] },
      { to: '/safes',      icon: Vault,     label: 'الخزن المالية',  perm: 'finance',  warehouseTypes: ['all'] },
      { to: '/expenses',   icon: DollarSign, label: 'المصروفات',    perm: 'finance',  warehouseTypes: ['all'] },
      { to: '/shifts',     icon: Clock,     label: 'الورديات',      perm: 'shifts',   warehouseTypes: ['all'] },
      { to: '/archive',    icon: Archive,   label: 'الأرشيف',       perm: 'archive',  warehouseTypes: ['all'] },
    ]
  },
  {
    key: 'hr',
    label: 'الموارد البشرية',
    icon: DollarSign,
    items: [
      { to: '/payroll', icon: DollarSign, label: 'الرواتب والحضور', perm: 'payroll', warehouseTypes: ['all'] },
    ]
  },
  {
    key: 'admin',
    label: 'الإدارة',
    icon: Settings,
    items: [
      { to: '/users',     icon: Users,       label: 'المستخدمون',  perm: 'users',    warehouseTypes: ['all'] },
      { to: '/audit-log', icon: ShieldCheck,  label: 'سجل التدقيق', perm: 'admin',    warehouseTypes: ['all'] },
      { to: '/settings',  icon: Settings,    label: 'الإعدادات',   perm: 'settings', warehouseTypes: ['all'] },
    ]
  },
]

// ── Quick-access shortcuts (merged into the sidebar) ────────────
const QUICK_ITEMS = [
  { to: '/pos',        icon: ShoppingCart, label: 'نقطة بيع', perm: 'pos' },
  { to: '/inventory',  icon: Package,      label: 'الأصناف',   perm: 'inventory' },
  { to: '/sales',      icon: Receipt,      label: 'المبيعات',  perm: 'sales' },
  { to: '/quotations', icon: FileText,     label: 'عروض سعر',  perm: 'quotations' },
  { to: '/purchases',  icon: Truck,        label: 'المشتريات', perm: 'inventory' },
  { to: '/customers',  icon: UserCheck,    label: 'العملاء',   perm: 'customers' },
  { to: '/safes',      icon: Vault,        label: 'الخزينة',   perm: 'finance' },
  { to: '/expenses',   icon: DollarSign,   label: 'المصروفات', perm: 'finance' },
]

export default function Layout({ children }: { children: ReactNode }) {
  const { user, logout } = useAuthStore()
  const location = useLocation()
  const navigate = useNavigate()
  const { activeWarehouseId, setActiveWarehouse } = useAppStore()
  const { data: warehouses } = useQuery<Warehouse[]>({ queryKey: ['warehouses'], queryFn: stockApi.warehouses })
  const { data: settings } = useQuery({ queryKey: ['settings'], queryFn: settingsApi.get })
  const companyName = settings?.store_name || 'Vendora'
  const logoUrl = settings?.logo_url || ''

  const [collapsed, setCollapsed] = useState(false)
  const [mobileOpen, setMobileOpen] = useState(false)
  const [expandedGroups, setExpandedGroups] = useState<Set<string>>(() => new Set(['home']))

  const isManager = (user as any)?.is_manager
  const defaultWhId = (user as any)?.default_warehouse_id

  useEffect(() => {
    if (defaultWhId && warehouses?.length && !activeWarehouseId) {
      const wh = warehouses.find(w => w.id === defaultWhId)
      if (wh) setActiveWarehouse(wh.id, wh.name)
    }
  }, [defaultWhId, warehouses, warehouses?.length, activeWarehouseId, setActiveWarehouse])

  const activeWh = warehouses?.find(w => w.id === activeWarehouseId)
  const defaultWh = warehouses?.find(w => w.id === defaultWhId)
  const whType = activeWh?.warehouse_type || defaultWh?.warehouse_type || 'all'
  const isCompanyView = !activeWarehouseId

  const userPerms: string[] = (user as any)?.permissions || []
  const hasPermission = (perm: string | null) => {
    if (!perm) return true
    return userPerms.includes(perm)
  }
  const isVisible = (item: { perm: string | null; warehouseTypes: string[] }) => {
    if (!hasPermission(item.perm)) return false
    if (isManager && isCompanyView) return true
    if (item.warehouseTypes.includes('all')) return true
    const effectiveType = whType === 'all' ? 'showroom' : whType
    return item.warehouseTypes.includes(effectiveType)
  }

  // Which group is active based on route
  const activeGroupKey = useMemo(() => {
    for (const group of NAV_GROUPS) {
      if (group.items.some(item => item.to === location.pathname)) {
        return group.key
      }
    }
    return 'home'
  }, [location.pathname])

  // Auto-expand the active group
  useEffect(() => {
    setExpandedGroups(prev => {
      const next = new Set(prev)
      next.add(activeGroupKey)
      return next
    })
  }, [activeGroupKey])

  const toggleGroup = (key: string) => {
    setExpandedGroups(prev => {
      const next = new Set(prev)
      if (next.has(key)) next.delete(key)
      else next.add(key)
      return next
    })
  }

  const showroomCount = warehouses?.filter(w => w.warehouse_type === 'showroom').length || 0
  const warehouseCount = warehouses?.filter(w => w.warehouse_type === 'warehouse').length || 0

  const quickItems = QUICK_ITEMS.filter(q => hasPermission(q.perm))

  const navigateClose = (to: string) => {
    navigate(to)
    setMobileOpen(false)
  }

  // Desktop rail collapses to icons only; the mobile drawer stays expanded
  const isRail = collapsed && !mobileOpen

  // Fully rendered group set (respects permission/visibility)
  const renderableGroups = NAV_GROUPS.map(group => ({
    ...group,
    items: group.items.filter(isVisible),
  })).filter(g => g.items.length > 0)

  const SidebarBody = (
    <div className="flex-1 overflow-y-auto overflow-x-hidden px-2.5 py-4">
      {!isRail && (
        <>
          <div className="mb-5">
            <p className="sidebar-section-label px-3 mb-2">وصول سريع</p>
            <div className="grid grid-cols-2 gap-1.5">
              {quickItems.map(item => {
                const isActive = location.pathname === item.to
                return (
                  <button
                    key={item.to}
                    onClick={() => navigateClose(item.to)}
                    className={clsx('quick-tile', isActive && 'active')}
                    title={item.label}
                  >
                    <span className={clsx('quick-tile-icon', isActive ? 'bg-[var(--primary)] text-white' : 'bg-[var(--primary-soft)] text-[var(--primary)]')}>
                      <item.icon size={15} />
                    </span>
                    <span className="truncate-1 w-full">{item.label}</span>
                  </button>
                )
              })}
            </div>
          </div>

          <p className="sidebar-section-label px-3 mb-2">القائمة الرئيسية</p>
        </>
      )}

      <div className="space-y-0.5">
        {renderableGroups.map((group) => {
          const isExpanded = expandedGroups.has(group.key)
          const isGroupActive = group.key === activeGroupKey
          const GroupIcon = group.icon

          if (isRail) {
            return (
              <button
                key={group.key}
                onClick={() => { setCollapsed(false); toggleGroup(group.key); }}
                className={clsx('sidebar-group-btn justify-center !px-2', isGroupActive && 'active')}
                title={group.label}
                aria-label={group.label}
              >
                <GroupIcon size={18} className={isGroupActive ? 'text-[var(--primary)]' : 'text-[var(--muted)]'} />
              </button>
            )
          }

          return (
            <div key={group.key}>
              <button
                onClick={() => toggleGroup(group.key)}
                className={clsx('sidebar-group-btn', isGroupActive && 'active')}
                aria-expanded={isExpanded}
              >
                <GroupIcon size={16} className={isGroupActive ? 'text-[var(--primary)]' : 'text-[var(--muted)]'} />
                <span className="flex-1 text-right">{group.label}</span>
                <ChevronDown
                  size={14}
                  className={clsx(
                    'text-[var(--muted)] transition-transform duration-200 flex-shrink-0',
                    isExpanded ? 'rotate-0' : '-rotate-90'
                  )}
                />
              </button>

              {isExpanded && (
                <div className="mr-3 mt-1 space-y-0.5 border-r-2 border-[var(--primary-soft)] pr-1.5">
                  {group.items.map((item) => {
                    const ItemIcon = item.icon
                    const isActive = location.pathname === item.to
                    return (
                      <NavLink
                        key={item.to}
                        to={item.to}
                        onClick={() => setMobileOpen(false)}
                        className={clsx('sidebar-link', isActive && 'active')}
                      >
                        <ItemIcon size={15} className={isActive ? 'text-[var(--primary)]' : 'text-[var(--muted)]'} />
                        {item.label}
                      </NavLink>
                    )
                  })}
                </div>
              )}
            </div>
          )
        })}
      </div>
    </div>
  )

  const SidebarFooter = (
    <div className="border-t border-[var(--border)] p-3.5">
      <div className="flex items-center justify-between px-1">
        <div className="flex items-center gap-2 min-w-0">
          <Boxes size={14} className="text-[var(--muted)] flex-shrink-0" />
          <span className="text-[11px] font-bold text-[var(--text-soft)] truncate-1">{companyName}</span>
        </div>
        {!isRail && <span className="text-[10px] text-[var(--muted)] flex-shrink-0">v1.0</span>}
      </div>
    </div>
  )

  return (
    <div className="flex flex-col h-screen overflow-hidden bg-[var(--bg)]" style={{ direction: 'rtl' }}>
      {/* ═══ Top Header Bar ═══ */}
      <header className="h-14 flex items-center gap-3 px-4 border-b border-[var(--border)] bg-white flex-shrink-0 z-30">
        <button
          onClick={() => setCollapsed(c => !c)}
          className="btn-ghost btn-icon hidden lg:flex"
          title={collapsed ? 'توسيع القائمة' : 'طي القائمة'}
        >
          {collapsed ? <PanelLeft size={18} /> : <PanelLeftClose size={18} />}
        </button>
        <button
          onClick={() => setMobileOpen(true)}
          className="btn-ghost btn-icon lg:hidden"
          title="فتح القائمة"
        >
          <PanelLeft size={18} />
        </button>

        {/* Logo + Company */}
        <div className="flex items-center gap-2.5 min-w-0">
          {logoUrl ? (
            <img src={fixUploadUrl(logoUrl)} alt="logo" className="w-8 h-8 rounded-[10px] object-contain flex-shrink-0" />
          ) : (
            <div className="w-8 h-8 rounded-[10px] flex items-center justify-center overflow-hidden bg-[var(--primary)] flex-shrink-0">
              <img src="/favicon.svg" alt="logo" className="w-full h-full object-cover" />
            </div>
          )}
          <span className="text-sm font-black text-[var(--text)] hidden md:block truncate-1">{companyName}</span>
        </div>

        {/* Warehouse selector */}
        <div className="relative hidden sm:block">
          <Store size={14} className="absolute right-2.5 top-1/2 -translate-y-1/2 text-[var(--muted)] pointer-events-none" />
          <select value={activeWarehouseId || ''}
            onChange={e => {
              const wh = warehouses?.find(w => w.id === e.target.value)
              if (wh) setActiveWarehouse(wh.id, wh.name)
              else setActiveWarehouse('', '')
            }}
            aria-label="اختيار الفرع"
            className="select-arrow bg-[var(--surface-2)] border border-[var(--border)] rounded-[var(--r-md)] pl-8 pr-8 py-2 text-xs font-bold text-[var(--text-soft)] outline-none focus:border-[var(--primary)] cursor-pointer min-w-[200px]">
            <option value="">إدارة شاملة ({warehouses?.length || 0} فروع)</option>
            {showroomCount > 0 && (
              <optgroup label="المعارض">
                {warehouses?.filter(w => w.warehouse_type === 'showroom').map(w => (
                  <option key={w.id} value={w.id}>🏪 {w.name}</option>
                ))}
              </optgroup>
            )}
            {warehouseCount > 0 && (
              <optgroup label="المخازن">
                {warehouses?.filter(w => w.warehouse_type === 'warehouse').map(w => (
                  <option key={w.id} value={w.id}>🏭 {w.name}</option>
                ))}
              </optgroup>
            )}
          </select>
        </div>

        <div className="flex-1" />

        {/* User info + logout */}
        <div className="flex items-center gap-2">
          <div className="hidden sm:flex items-center gap-2.5 px-3 py-1.5 rounded-[var(--r-lg)] bg-[var(--surface-2)] border border-[var(--border)]">
            <div className="w-8 h-8 rounded-full flex items-center justify-center text-xs font-black text-white flex-shrink-0 bg-[var(--primary)]">
              {user?.full_name?.[0] || 'م'}
            </div>
            <div className="text-right leading-tight">
              <p className="text-xs font-black text-[var(--text)]">{user?.full_name}</p>
              <p className="text-[10px] font-semibold text-[var(--muted)]">{isManager ? 'مدير' : 'موظف'}</p>
            </div>
          </div>
          <button onClick={logout} title="تسجيل الخروج" aria-label="تسجيل الخروج"
            className="btn-ghost btn-icon text-[var(--muted)] hover:text-[var(--danger)] hover:bg-[var(--danger-soft)]">
            <LogOut size={16} />
          </button>
        </div>
      </header>

      {/* ═══ Main Layout: Sidebar + Content ═══ */}
      <div className="flex flex-1 overflow-hidden">
        {/* ── Desktop Sidebar (right, RTL) ── */}
        <aside className={clsx(
          'hidden lg:flex flex-col bg-white border-l border-[var(--border)] flex-shrink-0 transition-[width] duration-200 z-10',
          collapsed ? 'w-[76px]' : 'w-60'
        )}>
          {SidebarBody}
          {SidebarFooter}
        </aside>

        {/* ── Mobile Drawer ── */}
        {mobileOpen && (
          <div className="fixed inset-0 z-50 lg:hidden">
            <div className="absolute inset-0 bg-[rgba(15,23,42,0.5)] backdrop-blur-[2px] fade-in" onClick={() => setMobileOpen(false)} />
            <aside className="absolute top-0 bottom-0 right-0 w-[280px] max-w-[85vw] bg-white border-l border-[var(--border)] flex flex-col shadow-[var(--shadow-lg)] slide-in">
              <div className="flex items-center justify-between px-4 h-14 border-b border-[var(--border)] flex-shrink-0">
                <div className="flex items-center gap-2">
                  {logoUrl ? (
                    <img src={fixUploadUrl(logoUrl)} alt="logo" className="w-7 h-7 rounded-lg object-contain" />
                  ) : (
                    <div className="w-7 h-7 rounded-lg overflow-hidden bg-[var(--primary)] flex items-center justify-center">
                      <img src="/favicon.svg" alt="logo" className="w-full h-full object-cover" />
                    </div>
                  )}
                  <span className="text-sm font-black text-[var(--text)]">{companyName}</span>
                </div>
                <button onClick={() => setMobileOpen(false)} aria-label="إغلاق القائمة" className="btn-ghost btn-icon">
                  <X size={18} />
                </button>
              </div>
              {SidebarBody}
              {SidebarFooter}
            </aside>
          </div>
        )}

        {/* ── Content Area ── */}
        <main className="flex-1 overflow-y-auto bg-[var(--bg)]">
          <div className="p-4 lg:p-6">{children}</div>
        </main>
      </div>
    </div>
  )
}