import { type ReactNode, useEffect, useState, useMemo } from 'react'
import { NavLink, useLocation, useNavigate } from 'react-router-dom'
import {
  LayoutDashboard, ShoppingCart, Package, BarChart3,
  Archive, Settings, Users, LogOut, FileText,
  Building2, Receipt, Truck, UserCheck, ShieldCheck,
  DollarSign, ClipboardList, Vault, Clock, TrendingDown,
  ChevronDown, PanelLeftClose, PanelLeft, Store, Boxes
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
      { to: '/', perm: null, warehouseTypes: ['all'], label: 'لوحة التحكم', icon: LayoutDashboard },
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

  const [sidebarOpen, setSidebarOpen] = useState(true)
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

  return (
    <div className="flex flex-col h-screen overflow-hidden bg-[var(--bg)]" style={{ direction: 'rtl' }}>
      {/* ═══ Top Header Bar ═══ */}
      <header className="h-14 flex items-center gap-3 px-4 border-b border-[var(--border)] bg-white flex-shrink-0 z-30">
        {/* Sidebar toggle */}
        <button
          onClick={() => setSidebarOpen(!sidebarOpen)}
          className="btn-ghost btn-icon"
          title={sidebarOpen ? 'إخفاء القائمة' : 'إظهار القائمة'}
        >
          {sidebarOpen ? <PanelLeftClose size={18} /> : <PanelLeft size={18} />}
        </button>

        {/* Logo + Company */}
        <div className="flex items-center gap-2.5">
          {logoUrl ? (
            <img src={fixUploadUrl(logoUrl)} alt="logo" className="w-8 h-8 rounded-[10px] object-contain" />
          ) : (
            <div className="w-8 h-8 rounded-[10px] flex items-center justify-center overflow-hidden bg-[var(--primary)]">
              <img src="/favicon.svg" alt="logo" className="w-full h-full object-cover" />
            </div>
          )}
          <span className="text-sm font-black text-[var(--text)] hidden md:block">{companyName}</span>
        </div>

        {/* Warehouse selector */}
        <div className="relative">
          <Store size={14} className="absolute right-2.5 top-1/2 -translate-y-1/2 text-[var(--muted)] pointer-events-none" />
          <select value={activeWarehouseId || ''}
            onChange={e => {
              const wh = warehouses?.find(w => w.id === e.target.value)
              if (wh) setActiveWarehouse(wh.id, wh.name)
              else setActiveWarehouse('', '')
            }}
            className="select-arrow bg-[var(--surface-2)] border border-[var(--border)] rounded-[var(--r-md)] pl-8 pr-8 py-2 text-xs font-semibold text-[var(--text-soft)] outline-none focus:border-[var(--primary)] cursor-pointer min-w-[200px]">
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

        {/* Spacer */}
        <div className="flex-1" />

        {/* User info + logout */}
        <div className="flex items-center gap-2">
          <div className="hidden sm:flex items-center gap-2.5 px-3 py-1.5 rounded-[var(--r-md)] bg-[var(--surface-2)] border border-[var(--border)]">
            <div className="w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold text-white flex-shrink-0 bg-[var(--primary)]">
              {user?.full_name?.[0] || 'م'}
            </div>
            <div className="text-right">
              <p className="text-xs font-bold text-[var(--text)] leading-tight">{user?.full_name}</p>
              <p className="text-[10px] text-[var(--muted)]">{isManager ? 'مدير' : 'موظف'}</p>
            </div>
          </div>
          <button onClick={logout} title="تسجيل الخروج"
            className="btn-ghost btn-icon text-[var(--muted)] hover:text-red-500">
            <LogOut size={16} />
          </button>
        </div>
      </header>

      {/* ═══ Main Layout: Sidebar + Content ═══ */}
      <div className="flex flex-1 overflow-hidden">
        {/* ── Right Sidebar ── */}
        {sidebarOpen && (
          <aside className="w-60 flex-shrink-0 bg-white border-l border-[var(--border)] flex flex-col overflow-hidden z-10">
            <div className="flex-1 overflow-y-auto px-2.5 py-3">
              {/* Quick access */}
              <div className="mb-4">
                <p className="sidebar-section-label px-3 mb-2">وصول سريع</p>
                <div className="grid grid-cols-2 gap-1.5">
                  {quickItems.map(item => {
                    const isActive = location.pathname === item.to
                    return (
                      <button
                        key={item.to}
                        onClick={() => navigate(item.to)}
                        className={clsx('quick-tile', isActive && 'active')}
                      >
                        <span className={clsx('quick-tile-icon', isActive ? 'bg-[var(--primary)] text-white' : 'bg-[var(--primary-soft)] text-[var(--primary)]')}>
                          <item.icon size={15} />
                        </span>
                        {item.label}
                      </button>
                    )
                  })}
                </div>
              </div>

              {/* Main navigation */}
              <p className="sidebar-section-label px-3 mb-2">القائمة الرئيسية</p>
              <div className="space-y-0.5">
              {NAV_GROUPS.map((group) => {
                const visibleItems = group.items.filter(isVisible)
                if (!visibleItems.length) return null
                const isExpanded = expandedGroups.has(group.key)
                const isGroupActive = group.key === activeGroupKey
                const GroupIcon = group.icon

                return (
                  <div key={group.key}>
                    {/* Group header */}
                    <button
                      onClick={() => toggleGroup(group.key)}
                      className={clsx('sidebar-group-btn', isGroupActive && 'active')}
                    >
                      <GroupIcon size={16} className={isGroupActive ? 'text-[var(--primary)]' : 'text-[var(--muted)]'} />
                      <span className="flex-1 text-right">{group.label}</span>
                      <ChevronDown
                        size={14}
                        className={clsx(
                          'text-[var(--muted)] transition-transform duration-200',
                          isExpanded ? 'rotate-0' : '-rotate-90'
                        )}
                      />
                    </button>

                    {/* Group items */}
                    {isExpanded && (
                      <div className="mr-3 mt-0.5 space-y-0.5 border-r-2 border-[var(--primary-soft)] pr-1.5">
                        {visibleItems.map((item) => {
                          const ItemIcon = item.icon
                          const isActive = location.pathname === item.to
                          return (
                            <NavLink
                              key={item.to}
                              to={item.to}
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

            {/* Sidebar footer */}
            <div className="border-t border-[var(--border)] p-3.5">
              <div className="flex items-center justify-between px-1">
                <div className="flex items-center gap-2">
                  <Boxes size={14} className="text-[var(--muted)]" />
                  <span className="text-[11px] font-semibold text-[var(--text-soft)]">{companyName}</span>
                </div>
                <span className="text-[10px] text-[var(--muted)]">v1.0</span>
              </div>
            </div>
          </aside>
        )}

        {/* ── Content Area ── */}
        <main className="flex-1 overflow-y-auto">
          <div className="p-4 lg:p-5">{children}</div>
        </main>
      </div>
    </div>
  )
}