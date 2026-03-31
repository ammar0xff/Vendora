import { type ReactNode, useRef, useEffect, useState } from 'react'
import { NavLink, useNavigate, useLocation } from 'react-router-dom'
import {
  LayoutDashboard, ShoppingCart, Package, BarChart3,
  Archive, Settings, Users, LogOut, Wallet, FileText,
  Building2, Receipt, Truck, UserCheck, ShieldCheck,
  DollarSign, Scale, ShoppingBag, ChevronLeft, ChevronRight
} from 'lucide-react'
import { useAuthStore } from '../../store/auth'
import { useAppStore } from '../../store/app'
import { useQuery } from '@tanstack/react-query'
import { stockApi, settingsApi } from '../../api/endpoints'
import { fixUploadUrl } from '../../utils/format'
import { clsx } from 'clsx'

// Grouped nav structure
const NAV_GROUPS = [
  {
    label: null, // no header for top items
    items: [
      { to: '/admin', icon: ShieldCheck, label: 'الإدارة', perm: 'admin', warehouseTypes: ['all'] },
      { to: '/', icon: LayoutDashboard, label: 'الرئيسية', perm: null, warehouseTypes: ['all'] },
    ]
  },
  {
    label: 'المبيعات',
    items: [
      { to: '/pos',        icon: ShoppingCart, label: 'نقطة البيع',    perm: 'pos',        warehouseTypes: ['showroom'] },
      { to: '/sales',      icon: Receipt,      label: 'الفواتير',      perm: 'sales',      warehouseTypes: ['showroom'] },
      { to: '/quotations', icon: FileText,      label: 'عروض الأسعار', perm: 'quotations', warehouseTypes: ['showroom'] },
      { to: '/customers',  icon: UserCheck,    label: 'العملاء',       perm: 'customers',  warehouseTypes: ['showroom'] },
    ]
  },
  {
    label: 'المخزون',
    items: [
      { to: '/inventory',  icon: Package,  label: 'الأصناف',   perm: 'inventory',  warehouseTypes: ['all'] },
      { to: '/suppliers',  icon: Building2, label: 'الموردون',  perm: 'inventory',  warehouseTypes: ['all'] },
      { to: '/purchases',       icon: ShoppingBag, label: 'المشتريات',      perm: 'inventory', warehouseTypes: ['all'] },
      { to: '/purchase-orders', icon: ShoppingBag, label: 'اقتراحات الشراء', perm: 'inventory', warehouseTypes: ['all'] },
      { to: '/operations',        icon: Truck,       label: 'العمليات',       perm: 'operations', warehouseTypes: ['all'] },
      { to: '/stock-adjustments', icon: Package,    label: 'تسويات المخزون', perm: 'inventory',  warehouseTypes: ['all'] },
    ]
  },
  {
    label: 'المالية',
    items: [
      { to: '/reports',  icon: BarChart3, label: 'التقارير',       perm: 'reports',  warehouseTypes: ['all'] },
      { to: '/finance',  icon: Scale,     label: 'الميزان المالي', perm: 'finance',  warehouseTypes: ['all'] },
      { to: '/archive',  icon: Archive,   label: 'الأرشيف',        perm: 'archive',  warehouseTypes: ['all'] },
    ]
  },
  {
    label: 'الموارد البشرية',
    items: [
      { to: '/payroll', icon: DollarSign, label: 'الرواتب والحضور', perm: 'payroll', warehouseTypes: ['all'] },
    ]
  },
  {
    label: 'الإدارة',
    items: [
      { to: '/users',    icon: Users,    label: 'المستخدمون', perm: 'users',    warehouseTypes: ['all'] },
      { to: '/settings', icon: Settings, label: 'الإعدادات',  perm: 'settings', warehouseTypes: ['all'] },
    ]
  },
]

export default function Layout({ children }: { children: ReactNode }) {
  const { user, logout } = useAuthStore()
  const navigate = useNavigate()
  const location = useLocation()
  const { activeWarehouseId, setActiveWarehouse } = useAppStore()
  const { data: warehouses } = useQuery({ queryKey: ['warehouses'], queryFn: stockApi.warehouses })
  const { data: settings } = useQuery({ queryKey: ['settings'], queryFn: settingsApi.get })
  const companyName = settings?.store_name || 'نظام الجرد'
  const logoUrl = settings?.logo_url || ''
  const [collapsed, setCollapsed] = useState(false)

  const isAdmin = (user as any)?.role === 'admin'
  const defaultWhId = (user as any)?.default_warehouse_id

  useEffect(() => {
    if (!isAdmin && defaultWhId && warehouses?.length) {
      const wh = warehouses.find((w: any) => w.id === defaultWhId)
      if (wh) setActiveWarehouse(wh.id, wh.name)
    }
  }, [defaultWhId, warehouses?.length])

  const activeWh = warehouses?.find((w: any) => w.id === activeWarehouseId)
  const defaultWh = warehouses?.find((w: any) => w.id === defaultWhId)
  // Use active warehouse type, or default warehouse type for non-admins (before useEffect fires)
  const whType = activeWh?.warehouse_type || defaultWh?.warehouse_type || 'all'
  // Non-admins with a default warehouse are never in company view
  const isCompanyView = !activeWarehouseId && (isAdmin || !defaultWhId)

  const userPerms: string[] = (user as any)?.permissions || []
  const hasPermission = (perm: string | null) => {
    if (!perm) return true
    if ((user as any)?.role === 'admin') return true
    return userPerms.includes(perm)
  }
  const isVisible = (item: any) => {
    if (!hasPermission(item.perm)) return false
    // Admin in company view sees everything
    if (isAdmin && isCompanyView) return true
    // Non-admin: use their warehouse type, or show 'all' items while loading
    const effectiveType = whType === 'all' ? 'showroom' : whType  // default to showroom while loading
    if (item.warehouseTypes.includes('all')) return true
    return item.warehouseTypes.includes(effectiveType)
  }

  // Current page label for breadcrumb
  const currentLabel = NAV_GROUPS.flatMap(g => g.items).find(i => i.to === location.pathname)?.label || ''

  const [mobileOpen, setMobileOpen] = useState(false)

  return (
    <div className="flex h-screen overflow-hidden">
      {/* Mobile overlay */}
      {mobileOpen && (
        <div className="fixed inset-0 bg-black/50 z-40 lg:hidden" onClick={() => setMobileOpen(false)} />
      )}

      {/* Mobile menu button */}
      <button onClick={() => setMobileOpen(true)}
        className="fixed top-3 right-3 z-50 lg:hidden w-9 h-9 rounded-xl flex items-center justify-center text-white shadow-lg"
        style={{ background: '#1e3a5f' }}>
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
          <line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/>
        </svg>
      </button>

      {/* Sidebar */}
      <aside className={`
        fixed lg:relative inset-y-0 right-0 z-50
        ${mobileOpen ? 'translate-x-0' : 'translate-x-full lg:translate-x-0'}
        ${collapsed ? 'w-14' : 'w-64 lg:w-52'}
        flex-shrink-0 flex flex-col overflow-y-auto transition-all duration-200
      `} style={{ background: 'linear-gradient(180deg, #1e3a5f 0%, #152d4a 100%)' }}>

        {/* Logo + Company + collapse toggle */}
        <div className="p-3 border-b border-white/10 flex-shrink-0 flex items-center gap-2">
          {logoUrl ? (
            <img src={fixUploadUrl(logoUrl)} alt="logo" className="w-8 h-8 rounded-lg object-contain flex-shrink-0 cursor-pointer" onClick={() => setCollapsed(c => !c)} />
          ) : (
            <div className="w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0 text-sm font-black text-white cursor-pointer" style={{ background: 'var(--accent)' }} onClick={() => setCollapsed(c => !c)}>
              {companyName[0]}
            </div>
          )}
          {!collapsed && (
            <div className="flex-1 min-w-0">
              <p className="text-white font-bold leading-tight" style={{ fontSize: '0.72rem' }}>{companyName}</p>
              <p className="text-white/40 text-xs">نظام إدارة الأعمال</p>
            </div>
          )}
          <button onClick={() => setCollapsed(c => !c)} className="text-white/40 hover:text-white/80 flex-shrink-0 mr-auto">
            {collapsed ? <ChevronLeft size={14} /> : <ChevronRight size={14} />}
          </button>
        </div>

        {/* Branch selector */}
        {!collapsed && isAdmin && (
          <div className="px-3 py-2.5 border-b border-white/10 flex-shrink-0">
            <select value={activeWarehouseId || ''}
              onChange={e => {
                const wh = warehouses?.find((w: any) => w.id === e.target.value)
                if (wh) setActiveWarehouse(wh.id, wh.name)
                else setActiveWarehouse('', '')
              }}
              className="w-full bg-white/10 border border-white/15 rounded-lg px-2.5 py-1.5 text-white text-xs outline-none focus:border-yellow-400 cursor-pointer">
              <option value="" className="text-slate-800">🏢 إدارة شاملة</option>
              <optgroup label="المعارض" className="text-slate-800">
                {warehouses?.filter((w: any) => w.warehouse_type === 'showroom').map((w: any) => (
                  <option key={w.id} value={w.id} className="text-slate-800">🏪 {w.name}</option>
                ))}
              </optgroup>
              <optgroup label="المخازن" className="text-slate-800">
                {warehouses?.filter((w: any) => w.warehouse_type === 'warehouse').map((w: any) => (
                  <option key={w.id} value={w.id} className="text-slate-800">🏭 {w.name}</option>
                ))}
              </optgroup>
            </select>
          </div>
        )}
        {!collapsed && !isAdmin && activeWh && (
          <div className="px-3 py-2 border-b border-white/10 flex-shrink-0">
            <div className="flex items-center gap-2 bg-white/10 rounded-lg px-2.5 py-1.5">
              <span className="text-sm">{activeWh.warehouse_type === 'showroom' ? '🏪' : '🏭'}</span>
              <span className="text-white text-xs font-semibold truncate">{activeWh.name}</span>
            </div>
          </div>
        )}

        {/* Nav groups */}
        <nav className="flex-1 px-2 py-2 space-y-0.5 overflow-y-auto">
          {NAV_GROUPS.map((group, gi) => {
            const visibleItems = group.items.filter(isVisible)
            if (!visibleItems.length) return null
            return (
              <div key={gi} className={gi > 0 ? 'pt-2' : ''}>
                {!collapsed && group.label && (
                  <p className="text-white/30 text-xs font-bold uppercase tracking-wider px-3 py-1.5">{group.label}</p>
                )}
                {visibleItems.map(({ to, icon: Icon, label }) => (
                  <NavLink key={to} to={to} end={to === '/'}
                    title={collapsed ? label : undefined}
                    onClick={() => setMobileOpen(false)}
                    className={({ isActive }) => clsx(
                      collapsed ? 'flex items-center justify-center p-2.5 rounded-xl transition-all' : 'sidebar-link',
                      isActive && (collapsed ? 'bg-white/20 text-white' : 'active'),
                      !isActive && collapsed && 'text-white/60 hover:bg-white/10 hover:text-white'
                    )}>
                    <Icon size={15} className="flex-shrink-0" />
                    {!collapsed && <span className="truncate text-xs">{label}</span>}
                  </NavLink>
                ))}
              </div>
            )
          })}
        </nav>

        {/* User */}
        <div className="p-3 border-t border-white/10 flex-shrink-0">
          {!collapsed && (
            <div className="flex items-center gap-2.5 mb-2">
              <div className="w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold text-white flex-shrink-0" style={{ background: 'var(--accent)' }}>
                {user?.full_name?.[0] || 'م'}
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-white text-xs font-semibold truncate">{user?.full_name}</p>
                <p className="text-white/40 text-xs">{(user as any)?.role === 'admin' ? 'مدير' : 'موظف'}</p>
              </div>
            </div>
          )}
          <button onClick={logout} title="خروج"
            className={clsx('text-red-300 hover:text-red-200 hover:bg-red-500/20 rounded-xl transition-all text-xs',
              collapsed ? 'w-full flex items-center justify-center p-2.5' : 'sidebar-link w-full')}>
            <LogOut size={13} />{!collapsed && <span>خروج</span>}
          </button>
        </div>
      </aside>

      <main className="flex-1 overflow-y-auto bg-slate-50 flex flex-col">
        {/* Top breadcrumb bar */}
        <div className="flex items-center gap-2 px-6 py-2.5 bg-white border-b border-slate-100 flex-shrink-0">
          <span className="text-slate-400 text-xs">{companyName}</span>
          {currentLabel && <>
            <span className="text-slate-300 text-xs">/</span>
            <span className="text-slate-700 text-xs font-semibold">{currentLabel}</span>
          </>}
          {activeWh && (
            <span className="mr-auto text-xs px-2 py-0.5 rounded-full bg-blue-50 text-blue-600 font-medium">
              {activeWh.warehouse_type === 'showroom' ? '🏪' : '🏭'} {activeWh.name}
            </span>
          )}
          {isCompanyView && isAdmin && (
            <span className="mr-auto text-xs px-2 py-0.5 rounded-full bg-slate-100 text-slate-500 font-medium">🏢 إدارة شاملة</span>
          )}
        </div>
        <div className="flex-1 p-4 lg:p-6 pt-14 lg:pt-6">{children}</div>
      </main>
    </div>
  )
}
