import { type ReactNode, useEffect, useState, useMemo } from 'react'
import { NavLink, useLocation, useNavigate } from 'react-router-dom'
import {
  LayoutDashboard, ShoppingCart, Package, BarChart3,
  Archive, Settings, Users, LogOut, FileText,
  Building2, Receipt, Truck, UserCheck, ShieldCheck,
  DollarSign, ClipboardList, Vault, Clock, TrendingDown
} from 'lucide-react'
import { useAuthStore } from '../../store/auth'
import { useAppStore } from '../../store/app'
import { useQuery } from '@tanstack/react-query'
import { stockApi, settingsApi } from '../../api/endpoints'
import { fixUploadUrl } from '../../utils/format'
import { clsx } from 'clsx'

// Top-level tab groups with icon
const TAB_GROUPS = [
  {
    key: 'home',
    label: 'الرئيسية',
    icon: LayoutDashboard,
    items: [
      { to: '/', perm: null, warehouseTypes: ['all'] },
    ]
  },
  {
    key: 'sales',
    label: 'المبيعات',
    icon: ShoppingCart,
    items: [
      { to: '/pos',        icon: ShoppingCart, label: 'نقطة البيع',         perm: 'pos',        warehouseTypes: ['showroom'] },
      { to: '/sales',      icon: Receipt,      label: 'المبيعات والمرتجعات', perm: 'sales',      warehouseTypes: ['showroom'] },
      { to: '/quotations', icon: FileText,      label: 'عروض الأسعار',      perm: 'quotations', warehouseTypes: ['showroom'] },
      { to: '/customers',  icon: UserCheck,    label: 'العملاء',            perm: 'customers',  warehouseTypes: ['showroom'] },
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

export default function Layout({ children }: { children: ReactNode }) {
  const { user, logout } = useAuthStore()
  const location = useLocation()
  const navigate = useNavigate()
  const { activeWarehouseId, setActiveWarehouse } = useAppStore()
  const { data: warehouses } = useQuery({ queryKey: ['warehouses'], queryFn: stockApi.warehouses })
  const { data: settings } = useQuery({ queryKey: ['settings'], queryFn: settingsApi.get })
  const companyName = settings?.store_name || 'نظام الجرد'
  const logoUrl = settings?.logo_url || ''

  const isManager = (user as any)?.is_manager
  const defaultWhId = (user as any)?.default_warehouse_id

  useEffect(() => {
    if (defaultWhId && warehouses?.length && !activeWarehouseId) {
      const wh = warehouses.find((w: any) => w.id === defaultWhId)
      if (wh) setActiveWarehouse(wh.id, wh.name)
    }
  }, [defaultWhId, warehouses, warehouses?.length, activeWarehouseId, setActiveWarehouse])

  const activeWh = warehouses?.find((w: any) => w.id === activeWarehouseId)
  const defaultWh = warehouses?.find((w: any) => w.id === defaultWhId)
  const whType = activeWh?.warehouse_type || defaultWh?.warehouse_type || 'all'
  const isCompanyView = !activeWarehouseId

  const userPerms: string[] = (user as any)?.permissions || []
  const hasPermission = (perm: string | null) => {
    if (!perm) return true
    return userPerms.includes(perm)
  }
  const isVisible = (item: any) => {
    if (!hasPermission(item.perm)) return false
    if (isManager && isCompanyView) return true
    const effectiveType = whType === 'all' ? 'showroom' : whType
    if (item.warehouseTypes.includes('all')) return true
    return item.warehouseTypes.includes(effectiveType)
  }

  // Determine which tab group is active based on current route
  const activeGroupKey = useMemo(() => {
    for (const group of TAB_GROUPS) {
      if (group.items.some(item => item.to === location.pathname)) {
        return group.key
      }
    }
    return 'home'
  }, [location.pathname])

  const activeGroup = TAB_GROUPS.find(g => g.key === activeGroupKey) || TAB_GROUPS[0]

  // Filter visible sub-items for the active group
  const visibleSubItems = activeGroup.items.filter(isVisible)

  // Auto-navigate to first visible item when switching tabs (if current route not in group)
  const isCurrentRouteInGroup = activeGroup.items.some(item => item.to === location.pathname)

  const handleTabClick = (group: typeof TAB_GROUPS[0]) => {
    const firstVisible = group.items.find(isVisible)
    if (firstVisible && firstVisible.to !== location.pathname) {
      navigate(firstVisible.to)
    }
  }

  // POS page gets a compact layout (no sub-tabs, just the top bar)
  const isPOS = location.pathname === '/pos'

  return (
    <div className="flex flex-col h-screen overflow-hidden bg-slate-50">
      {/* ═══ Top Header Bar ═══ */}
      <header className="h-14 flex items-center gap-4 px-5 border-b border-slate-200 bg-white flex-shrink-0 z-30">
        {/* Logo + Company */}
        <div className="flex items-center gap-2.5">
          {logoUrl ? (
            <img src={fixUploadUrl(logoUrl)} alt="logo" className="w-8 h-8 rounded-lg object-contain" />
          ) : (
            <div className="w-8 h-8 rounded-lg flex items-center justify-center text-sm font-black text-white" style={{ background: 'var(--accent)' }}>
              {companyName[0]}
            </div>
          )}
          <span className="text-sm font-bold text-slate-700 hidden sm:block">{companyName}</span>
        </div>

        {/* Warehouse selector */}
        <select value={activeWarehouseId || ''}
          onChange={e => {
            const wh = warehouses?.find((w: any) => w.id === e.target.value)
            if (wh) setActiveWarehouse(wh.id, wh.name)
            else setActiveWarehouse('', '')
          }}
          className="bg-slate-100 border border-slate-200 rounded-lg px-3 py-1.5 text-xs outline-none focus:border-blue-400 cursor-pointer">
          <option value="">🏢 إدارة شاملة</option>
          <optgroup label="المعارض">
            {warehouses?.filter((w: any) => w.warehouse_type === 'showroom').map((w: any) => (
              <option key={w.id} value={w.id}>🏪 {w.name}</option>
            ))}
          </optgroup>
          <optgroup label="المخازن">
            {warehouses?.filter((w: any) => w.warehouse_type === 'warehouse').map((w: any) => (
              <option key={w.id} value={w.id}>🏭 {w.name}</option>
            ))}
          </optgroup>
        </select>

        {/* Spacer */}
        <div className="flex-1" />

        {/* User info + logout */}
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold text-white flex-shrink-0" style={{ background: 'var(--accent)' }}>
            {user?.full_name?.[0] || 'م'}
          </div>
          <div className="hidden sm:block text-left">
            <p className="text-xs font-semibold text-slate-700 leading-tight">{user?.full_name}</p>
            <p className="text-xs text-slate-400">{isManager ? 'مدير' : 'موظف'}</p>
          </div>
          <button onClick={logout} title="خروج"
            className="w-8 h-8 rounded-lg flex items-center justify-center text-slate-400 hover:text-red-500 hover:bg-red-50 transition-all">
            <LogOut size={15} />
          </button>
        </div>
      </header>

      {/* ═══ Main Category Tabs ═══ */}
      <div className="flex items-center gap-0 px-5 bg-white border-b border-slate-200 flex-shrink-0 z-20">
        {TAB_GROUPS.map((group) => {
          // Check if any item in this group is visible
          const hasVisible = group.items.some(isVisible)
          if (!hasVisible) return null
          const Icon = group.icon
          const isActive = group.key === activeGroupKey

          return (
            <button
              key={group.key}
              onClick={() => handleTabClick(group)}
              className={clsx(
                'flex items-center gap-2 px-4 py-3 text-sm font-semibold transition-all border-b-2 -mb-px whitespace-nowrap',
                isActive
                  ? 'text-blue-600 border-blue-600 bg-blue-50/50'
                  : 'text-slate-500 border-transparent hover:text-slate-700 hover:bg-slate-50'
              )}
            >
              <Icon size={16} />
              {group.label}
            </button>
          )
        })}
      </div>

      {/* ═══ Sub-Tabs (only if not POS and group has sub-items) ═══ */}
      {!isPOS && visibleSubItems.length > 1 && (
        <div className="flex items-center gap-0 px-5 bg-slate-50 border-b border-slate-200 flex-shrink-0 z-10">
          {visibleSubItems.map((item) => {
            const Icon = item.icon
            const isActive = location.pathname === item.to
            return (
              <NavLink
                key={item.to}
                to={item.to}
                className={clsx(
                  'flex items-center gap-1.5 px-3.5 py-2.5 text-xs font-medium transition-all border-b-2 -mb-px whitespace-nowrap',
                  isActive
                    ? 'text-slate-800 border-slate-800 bg-white'
                    : 'text-slate-400 border-transparent hover:text-slate-600 hover:bg-white/60'
                )}
              >
                {Icon && <Icon size={14} />}
                {item.label}
              </NavLink>
            )
          })}
        </div>
      )}

      {/* ═══ Content Area ═══ */}
      <main className="flex-1 overflow-y-auto">
        <div className="p-4 lg:p-6">{children}</div>
      </main>
    </div>
  )
}
