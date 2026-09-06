import { type ReactNode, useEffect, useState, useMemo } from 'react'
import { NavLink, useLocation, useNavigate } from 'react-router-dom'
import {
  LayoutDashboard, ShoppingCart, Package, BarChart3,
  Archive, Settings, Users, LogOut, FileText,
  Building2, Receipt, Truck, UserCheck, ShieldCheck,
  DollarSign, ClipboardList, Vault, Clock, TrendingDown,
  ChevronDown, ChevronLeft, PanelLeftClose, PanelLeft
} from 'lucide-react'
import { useAuthStore } from '../../store/auth'
import { useAppStore } from '../../store/app'
import { useQuery } from '@tanstack/react-query'
import { stockApi, settingsApi } from '../../api/endpoints'
import { fixUploadUrl } from '../../utils/format'
import { clsx } from 'clsx'
import type { Warehouse } from '../../types'

// ── Navigation structure (VB6 Almodeer menu hierarchy) ──────────────
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

// ── Quick-access toolbar buttons (like VB6 Command buttons) ─────────
const TOOLBAR_ITEMS = [
  { to: '/pos',        icon: ShoppingCart, label: 'نقاطة بيع',  perm: 'pos',        color: 'bg-emerald-500' },
  { to: '/sales',      icon: Receipt,      label: 'المبيعات',    perm: 'sales',      color: 'bg-blue-500' },
  { to: '/quotations', icon: FileText,      label: 'عروض سعر',    perm: 'quotations', color: 'bg-purple-500' },
  { to: '/inventory',  icon: Package,       label: 'الأصناف',     perm: 'inventory',  color: 'bg-amber-500' },
  { to: '/purchases',  icon: Truck,         label: 'المشتريات',   perm: 'inventory',  color: 'bg-orange-500' },
  { to: '/customers',  icon: UserCheck,     label: 'العملاء',     perm: 'customers',  color: 'bg-cyan-500' },
  { to: '/safes',      icon: Vault,         label: 'الخزينة',     perm: 'finance',    color: 'bg-green-600' },
  { to: '/expenses',   icon: DollarSign,    label: 'المصروفات',   perm: 'finance',    color: 'bg-red-400' },
  { to: '/accounting', icon: BarChart3,     label: 'الحسابات',    perm: 'reports',    color: 'bg-indigo-500' },
  { to: '/shifts',     icon: Clock,         label: 'الورديات',    perm: 'shifts',     color: 'bg-slate-500' },
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

  return (
    <div className="flex flex-col h-screen overflow-hidden bg-slate-100" style={{ direction: 'rtl' }}>
      {/* ═══ Top Header Bar ═══ */}
      <header className="h-11 flex items-center gap-3 px-4 border-b border-slate-200 bg-white flex-shrink-0 z-30">
        {/* Sidebar toggle */}
        <button
          onClick={() => setSidebarOpen(!sidebarOpen)}
          className="w-8 h-8 rounded-lg flex items-center justify-center text-slate-500 hover:bg-slate-100 transition-colors"
          title={sidebarOpen ? 'إخفاء القائمة' : 'إظهار القائمة'}
        >
          {sidebarOpen ? <PanelLeftClose size={18} /> : <PanelLeft size={18} />}
        </button>

        {/* Logo + Company */}
        <div className="flex items-center gap-2">
          {logoUrl ? (
            <img src={fixUploadUrl(logoUrl)} alt="logo" className="w-7 h-7 rounded-lg object-contain" />
          ) : (
            <div className="w-8 h-8 rounded-lg flex items-center justify-center overflow-hidden" style={{ background: '#2b1b03' }}>
              <img src="/favicon.svg" alt="logo" className="w-full h-full object-cover" />
            </div>
          )}
          <span className="text-sm font-bold text-slate-700 hidden md:block">{companyName}</span>
        </div>

        {/* Warehouse selector */}
        <select value={activeWarehouseId || ''}
          onChange={e => {
            const wh = warehouses?.find(w => w.id === e.target.value)
            if (wh) setActiveWarehouse(wh.id, wh.name)
            else setActiveWarehouse('', '')
          }}
          className="bg-slate-50 border border-slate-200 rounded-lg px-2.5 py-1 text-xs outline-none focus:border-blue-400 cursor-pointer">
          <option value="">🏢 إدارة شاملة</option>
          <optgroup label="المعارض">
            {warehouses?.filter(w => w.warehouse_type === 'showroom').map(w => (
              <option key={w.id} value={w.id}>🏪 {w.name}</option>
            ))}
          </optgroup>
          <optgroup label="المخازن">
            {warehouses?.filter(w => w.warehouse_type === 'warehouse').map(w => (
              <option key={w.id} value={w.id}>🏭 {w.name}</option>
            ))}
          </optgroup>
        </select>

        {/* Spacer */}
        <div className="flex-1" />

        {/* User info + logout */}
        <div className="flex items-center gap-2">
          <div className="w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold text-white flex-shrink-0" style={{ background: 'var(--primary)' }}>
            {user?.full_name?.[0] || 'م'}
          </div>
          <div className="hidden sm:block text-left">
            <p className="text-xs font-semibold text-slate-700 leading-tight">{user?.full_name}</p>
            <p className="text-[10px] text-slate-400">{isManager ? 'مدير' : 'موظف'}</p>
          </div>
          <button onClick={logout} title="خروج"
            className="w-7 h-7 rounded-lg flex items-center justify-center text-slate-400 hover:text-red-500 hover:bg-red-50 transition-all">
            <LogOut size={14} />
          </button>
        </div>
      </header>

      {/* ═══ Toolbar (VB6-style shortcut buttons) ═══ */}
      <div className="flex items-center gap-1 px-3 py-1.5 bg-white border-b border-slate-200 flex-shrink-0 z-20 overflow-x-auto">
          {TOOLBAR_ITEMS.map((item) => {
            if (!hasPermission(item.perm)) return null
            const Icon = item.icon
            const isActive = location.pathname === item.to
            return (
              <button
                key={item.to}
                onClick={() => navigate(item.to)}
                className={clsx(
                  'flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg text-[11px] font-semibold transition-all whitespace-nowrap',
                  isActive
                    ? 'bg-slate-800 text-white shadow-sm'
                    : 'text-slate-600 hover:bg-slate-100'
                )}
              >
                <div className={clsx('w-5 h-5 rounded-md flex items-center justify-center text-white', isActive ? 'bg-white/20' : item.color)}>
                  <Icon size={11} />
                </div>
                {item.label}
              </button>
            )
          })}
        </div>

      {/* ═══ Main Layout: Sidebar + Content ═══ */}
      <div className="flex flex-1 overflow-hidden">
        {/* ── Left Sidebar (VB6-style tree navigation) ── */}
        {sidebarOpen && (
          <aside className="w-56 flex-shrink-0 bg-white border-l border-slate-200 flex flex-col overflow-hidden z-10">
            <div className="flex-1 overflow-y-auto py-2 px-2">
              {NAV_GROUPS.map((group) => {
                const visibleItems = group.items.filter(isVisible)
                if (!visibleItems.length) return null
                const isExpanded = expandedGroups.has(group.key)
                const isGroupActive = group.key === activeGroupKey
                const GroupIcon = group.icon

                return (
                  <div key={group.key} className="mb-1">
                    {/* Group header */}
                    <button
                      onClick={() => toggleGroup(group.key)}
                      className={clsx(
                        'w-full flex items-center gap-2 px-3 py-2 rounded-lg text-sm font-bold transition-all',
                        isGroupActive
                          ? 'text-[var(--primary)] bg-blue-50'
                          : 'text-slate-600 hover:bg-slate-50'
                      )}
                    >
                      <GroupIcon size={15} className={isGroupActive ? 'text-[var(--primary)]' : 'text-slate-400'} />
                      <span className="flex-1 text-right">{group.label}</span>
                      <ChevronDown
                        size={14}
                        className={clsx(
                          'text-slate-400 transition-transform duration-200',
                          isExpanded ? 'rotate-0' : '-rotate-90'
                        )}
                      />
                    </button>

                    {/* Group items */}
                    {isExpanded && (
                      <div className="mr-2 mt-0.5 space-y-0.5 border-r-2 border-slate-100 pr-2">
                        {visibleItems.map((item) => {
                          const ItemIcon = item.icon
                          const isActive = location.pathname === item.to
                          return (
                            <NavLink
                              key={item.to}
                              to={item.to}
                              className={clsx(
                                'flex items-center gap-2 px-3 py-1.5 rounded-lg text-[13px] font-medium transition-all',
                                isActive
                                  ? 'text-white font-bold'
                                  : 'text-slate-500 hover:text-slate-800 hover:bg-slate-50'
                              )}
                              style={isActive ? { background: 'var(--primary)' } : {}}
                            >
                              <ItemIcon size={13} />
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

            {/* Sidebar footer */}
            <div className="border-t border-slate-100 p-3">
              <div className="text-[10px] text-slate-400 text-center">
                Vendora v1.0
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
