import { useQuery } from '@tanstack/react-query'
import { stockApi, reportsApi, shiftsApi } from '../../api/endpoints'
import { format, subDays } from 'date-fns'
import { AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from 'recharts'
import { ShoppingCart, Package, AlertTriangle, Wallet, TrendingUp, TrendingDown, ArrowUpRight, ClipboardList, DollarSign, Truck } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { useAppStore } from '../../store/app'
import FullAdminDashboard from '../admin/AdminPage'
import { useAuthStore } from '../../store/auth'
import api from '../../api/client'

const today = format(new Date(), 'yyyy-MM-dd')
const yesterday = format(subDays(new Date(), 1), 'yyyy-MM-dd')

function StatCard({ label, value, sub, icon: Icon, color, trend, onClick }: any) {
  return (
    <div onClick={onClick} className={`stat-card ${onClick ? 'cursor-pointer hover:shadow-md transition-shadow' : ''}`}>
      <div className="stat-icon" style={{ background: color + '20' }}>
        <Icon size={22} style={{ color }} />
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-slate-500 text-xs font-medium mb-0.5">{label}</p>
        <p className="text-xl font-black text-slate-800 truncate">{value}</p>
        {sub && <p className="text-slate-400 text-xs mt-0.5">{sub}</p>}
      </div>
      {trend !== undefined && (
        <div className={`flex items-center gap-1 text-xs font-bold ${trend >= 0 ? 'text-green-600' : 'text-red-500'}`}>
          {trend >= 0 ? <TrendingUp size={14} /> : <TrendingDown size={14} />}
          {Math.abs(trend)}%
        </div>
      )}
    </div>
  )
}

// ── Admin / Manager dashboard ─────────────────────────────────────────────────
function AdminDashboard({ whId, isCompanyView, warehouses }: any) {
  const navigate = useNavigate()
  const { data: daily } = useQuery({ queryKey: ['daily', today, whId], queryFn: () => reportsApi.daily(today, whId || undefined) })
  const { data: yesterday_data } = useQuery({ queryKey: ['daily', yesterday, whId], queryFn: () => reportsApi.daily(yesterday, whId || undefined) })
  const { data: valuation } = useQuery({ queryKey: ['valuation', whId], queryFn: () => stockApi.valuation(whId!), enabled: !!whId })
  const { data: lowStock } = useQuery({ queryKey: ['lowstock', whId], queryFn: () => stockApi.lowStock(whId!, 5), enabled: !!whId })
  const { data: shift } = useQuery({ queryKey: ['current-shift', whId], queryFn: () => shiftsApi.current(whId!), retry: false, throwOnError: false, enabled: !!whId })

  const days = Array.from({ length: 7 }, (_, i) => {
    const d = subDays(new Date(), 6 - i)
    return { date: format(d, 'yyyy-MM-dd'), label: format(d, 'EEE').replace('Mon','إث').replace('Tue','ثل').replace('Wed','أر').replace('Thu','خم').replace('Fri','جم').replace('Sat','سب').replace('Sun','أح') }
  })
  const dayQueries = days.map(d => useQuery({ queryKey: ['daily', d.date, whId], queryFn: () => reportsApi.daily(d.date, whId || undefined) }))
  const chartData = days.map((d, i) => ({ name: d.label, مبيعات: Number(dayQueries[i].data?.total_sales || 0) }))

  const todaySales = Number(daily?.total_sales || 0)
  const yesterdaySales = Number(yesterday_data?.total_sales || 0)
  const salesTrend = yesterdaySales > 0 ? Math.round(((todaySales - yesterdaySales) / yesterdaySales) * 100) : 0

  return (
    <>
      <div className="grid grid-cols-2 xl:grid-cols-4 gap-4 mb-6">
        <StatCard label="مبيعات اليوم" value={`${todaySales.toLocaleString('ar-EG')} ج.م`} sub={`${daily?.invoice_count || 0} فاتورة`} icon={ShoppingCart} color="#1e3a5f" trend={salesTrend} onClick={() => navigate('/sales')} />
        <StatCard label="قيمة المخزون" value={`${Number(valuation?.total_retail_value || 0).toLocaleString('ar-EG')} ج.م`} sub={`${valuation?.product_count || 0} منتج`} icon={Package} color="#16a34a" onClick={() => navigate('/inventory')} />
        <StatCard label="منتجات ناقصة" value={lowStock?.length || 0} sub="تحت الحد الأدنى" icon={AlertTriangle} color={lowStock?.length > 0 ? '#d97706' : '#16a34a'} onClick={() => navigate('/inventory')} />
        <StatCard label="رصيد الدرج" value={shift ? `${Number(shift.initial_amount).toLocaleString('ar-EG')} ج.م` : 'مغلق'} sub={shift ? 'وردية مفتوحة' : 'لا توجد وردية'} icon={Wallet} color={shift ? '#7c3aed' : '#94a3b8'} onClick={() => navigate('/pos')} />
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-3 gap-5">
        <div className="card xl:col-span-2">
          <div className="flex items-center justify-between mb-5">
            <h3 className="font-bold text-slate-700">المبيعات — آخر 7 أيام</h3>
            <button onClick={() => navigate('/reports')} className="text-xs text-blue-600 hover:underline flex items-center gap-1">التقارير <ArrowUpRight size={12} /></button>
          </div>
          <ResponsiveContainer width="100%" height={200}>
            <AreaChart data={chartData}>
              <defs><linearGradient id="sg" x1="0" y1="0" x2="0" y2="1"><stop offset="5%" stopColor="#1e3a5f" stopOpacity={0.15}/><stop offset="95%" stopColor="#1e3a5f" stopOpacity={0}/></linearGradient></defs>
              <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9"/>
              <XAxis dataKey="name" tick={{ fontSize: 11, fill: '#94a3b8' }} axisLine={false} tickLine={false}/>
              <YAxis tick={{ fontSize: 11, fill: '#94a3b8' }} axisLine={false} tickLine={false}/>
              <Tooltip formatter={(v: any) => [`${Number(v).toLocaleString('ar-EG')} ج.م`, 'المبيعات']}/>
              <Area type="monotone" dataKey="مبيعات" stroke="#1e3a5f" strokeWidth={2.5} fill="url(#sg)" dot={{ fill: '#1e3a5f', r: 3 }} activeDot={{ r: 5 }}/>
            </AreaChart>
          </ResponsiveContainer>
        </div>

        <div className="flex flex-col gap-4">
          <div className="card p-4">
            <h3 className="font-bold text-slate-700 mb-3 text-sm">إجراءات سريعة</h3>
            <div className="grid grid-cols-2 gap-2">
              {[{ label: 'فاتورة بيع', icon: '🧾', to: '/pos' }, { label: 'عرض سعر', icon: '📋', to: '/quotations' }, { label: 'إذن صرف', icon: '🚚', to: '/operations' }, { label: 'تقارير', icon: '📊', to: '/reports' }].map(({ label, icon, to }) => (
                <button key={to} onClick={() => navigate(to)} className="flex items-center gap-2 p-2.5 rounded-xl bg-slate-50 hover:bg-slate-100 transition-colors text-right">
                  <span className="text-lg">{icon}</span><span className="text-xs font-semibold text-slate-700">{label}</span>
                </button>
              ))}
            </div>
          </div>
          <div className="card p-4 flex-1">
            <div className="flex items-center justify-between mb-3">
              <h3 className="font-bold text-slate-700 text-sm flex items-center gap-1.5"><AlertTriangle size={14} className="text-amber-500"/> تنبيهات المخزون</h3>
              <button onClick={() => navigate('/inventory')} className="text-xs text-blue-600 hover:underline">عرض الكل</button>
            </div>
            <div className="space-y-2 max-h-48 overflow-y-auto">
              {!lowStock?.length && <p className="text-slate-400 text-xs text-center py-4">✅ المخزون بخير</p>}
              {lowStock?.slice(0, 8).map((item: any) => (
                <div key={item.product_id} className="flex items-center justify-between py-1.5 border-b border-slate-50 last:border-0">
                  <p className="text-xs font-medium text-slate-700 truncate flex-1 ml-2">{item.product_name}</p>
                  <span className={`text-xs font-bold px-2 py-0.5 rounded-full ${item.current_qty <= 0 ? 'bg-red-100 text-red-600' : 'bg-amber-100 text-amber-700'}`}>{item.current_qty} {item.unit}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </>
  )
}

// ── Cashier dashboard ─────────────────────────────────────────────────────────
function CashierDashboard({ whId }: any) {
  const navigate = useNavigate()
  const { data: shift } = useQuery({ queryKey: ['current-shift', whId], queryFn: () => shiftsApi.current(whId!), retry: false, throwOnError: false, enabled: !!whId })
  const { data: daily } = useQuery({ queryKey: ['daily', today, whId], queryFn: () => reportsApi.daily(today, whId || undefined) })
  const { data: txns } = useQuery({ queryKey: ['shift-txns', shift?.id], queryFn: () => api.get(`/shifts/${shift!.id}/transactions`).then(r => r.data), enabled: !!shift?.id })

  const expenses = txns?.filter((t: any) => t.type === 'expense').reduce((s: number, t: any) => s + Number(t.amount), 0) || 0

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-2 gap-4">
        <StatCard label="مبيعات اليوم" value={`${Number(daily?.total_sales || 0).toLocaleString('ar-EG')} ج.م`} sub={`${daily?.invoice_count || 0} فاتورة`} icon={ShoppingCart} color="#1e3a5f" onClick={() => navigate('/sales')} />
        <StatCard label="رصيد الدرج" value={shift ? `${Number(shift.initial_amount).toLocaleString('ar-EG')} ج.م` : 'مغلق'} sub={shift ? 'وردية مفتوحة' : 'لا توجد وردية'} icon={Wallet} color={shift ? '#7c3aed' : '#94a3b8'} onClick={() => navigate('/pos')} />
      </div>

      {shift ? (
        <div className="card">
          <h3 className="font-bold text-slate-700 mb-4">الوردية الحالية</h3>
          <div className="grid grid-cols-3 gap-4 text-center">
            <div className="bg-green-50 rounded-xl p-3"><p className="text-xs text-green-600 font-medium mb-1">المبيعات</p><p className="text-lg font-black text-green-700">{Number(daily?.total_sales || 0).toLocaleString('ar-EG')} ج.م</p></div>
            <div className="bg-red-50 rounded-xl p-3"><p className="text-xs text-red-600 font-medium mb-1">المصروفات</p><p className="text-lg font-black text-red-700">{expenses.toLocaleString('ar-EG')} ج.م</p></div>
            <div className="bg-blue-50 rounded-xl p-3"><p className="text-xs text-blue-600 font-medium mb-1">الفواتير</p><p className="text-lg font-black text-blue-700">{daily?.invoice_count || 0}</p></div>
          </div>
          <button onClick={() => navigate('/pos')} className="w-full mt-4 py-3 rounded-xl font-bold text-white text-sm" style={{ background: '#1e3a5f' }}>
            🛒 فتح نقطة البيع
          </button>
        </div>
      ) : (
        <div className="card text-center py-8">
          <p className="text-4xl mb-3">🔒</p>
          <p className="font-bold text-slate-700 mb-1">لا توجد وردية مفتوحة</p>
          <p className="text-slate-400 text-sm mb-4">افتح وردية جديدة لبدء العمل</p>
          <button onClick={() => navigate('/pos')} className="px-6 py-2.5 rounded-xl font-bold text-white text-sm" style={{ background: '#1e3a5f' }}>فتح وردية</button>
        </div>
      )}
    </div>
  )
}

// ── Storekeeper dashboard ─────────────────────────────────────────────────────
function StorekeeperDashboard({ whId }: any) {
  const navigate = useNavigate()
  const { data: valuation } = useQuery({ queryKey: ['valuation', whId], queryFn: () => stockApi.valuation(whId!), enabled: !!whId })
  const { data: lowStock } = useQuery({ queryKey: ['lowstock', whId], queryFn: () => stockApi.lowStock(whId!, 5), enabled: !!whId })
  const { data: movements } = useQuery({ queryKey: ['movements-recent', whId], queryFn: () => api.get('/stock/movements', { params: { warehouse_id: whId, limit: 10 } }).then(r => r.data), enabled: !!whId })

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-2 gap-4">
        <StatCard label="قيمة المخزون" value={`${Number(valuation?.total_retail_value || 0).toLocaleString('ar-EG')} ج.م`} sub={`${valuation?.product_count || 0} منتج`} icon={Package} color="#16a34a" onClick={() => navigate('/inventory')} />
        <StatCard label="منتجات ناقصة" value={lowStock?.length || 0} sub="تحت الحد الأدنى" icon={AlertTriangle} color={lowStock?.length > 0 ? '#d97706' : '#16a34a'} onClick={() => navigate('/purchase-orders')} />
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-2 gap-5">
        <div className="card p-4">
          <h3 className="font-bold text-slate-700 mb-3 text-sm">إجراءات سريعة</h3>
          <div className="grid grid-cols-2 gap-2">
            {[{ label: 'الأصناف', icon: '📦', to: '/inventory' }, { label: 'إذن صرف', icon: '🚚', to: '/operations' }, { label: 'استلام بضاعة', icon: '📥', to: '/purchases' }, { label: 'اقتراحات شراء', icon: '🛒', to: '/purchase-orders' }].map(({ label, icon, to }) => (
              <button key={to} onClick={() => navigate(to)} className="flex items-center gap-2 p-2.5 rounded-xl bg-slate-50 hover:bg-slate-100 transition-colors">
                <span className="text-lg">{icon}</span><span className="text-xs font-semibold text-slate-700">{label}</span>
              </button>
            ))}
          </div>
        </div>

        <div className="card p-4">
          <div className="flex items-center justify-between mb-3">
            <h3 className="font-bold text-slate-700 text-sm">آخر حركات المخزون</h3>
            <button onClick={() => navigate('/stock-adjustments')} className="text-xs text-blue-600 hover:underline">عرض الكل</button>
          </div>
          <div className="space-y-2 max-h-48 overflow-y-auto">
            {!movements?.length && <p className="text-slate-400 text-xs text-center py-4">لا توجد حركات</p>}
            {movements?.map((m: any) => (
              <div key={m.id} className="flex items-center justify-between py-1.5 border-b border-slate-50 last:border-0">
                <p className="text-xs font-medium text-slate-700 truncate flex-1">{m.product_name}</p>
                <span className={`text-xs font-bold mr-2 ${['purchase','adjustment_in','opening_stock','transfer_in','return_in'].includes(m.movement_type) ? 'text-green-600' : 'text-red-500'}`}>
                  {['purchase','adjustment_in','opening_stock','transfer_in','return_in'].includes(m.movement_type) ? '+' : '-'}{m.qty}
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}

// ── Accountant dashboard ──────────────────────────────────────────────────────
function AccountantDashboard({ whId }: any) {
  const navigate = useNavigate()
  const { data: profit } = useQuery({ queryKey: ['profit-month', whId], queryFn: () => reportsApi.profit(format(new Date(), 'yyyy-MM-01'), today, whId || undefined) })
  const { data: byCashier } = useQuery({ queryKey: ['cashier-month', whId], queryFn: () => reportsApi.byCashier(format(new Date(), 'yyyy-MM-01'), today, whId || undefined) })

  const days = Array.from({ length: 7 }, (_, i) => {
    const d = subDays(new Date(), 6 - i)
    return { date: format(d, 'yyyy-MM-dd'), label: format(d, 'EEE').replace('Mon','إث').replace('Tue','ثل').replace('Wed','أر').replace('Thu','خم').replace('Fri','جم').replace('Sat','سب').replace('Sun','أح') }
  })
  const dayQueries = days.map(d => useQuery({ queryKey: ['daily', d.date, whId], queryFn: () => reportsApi.daily(d.date, whId || undefined) }))
  const chartData = days.map((d, i) => ({ name: d.label, مبيعات: Number(dayQueries[i].data?.total_sales || 0) }))

  const rev = Number(profit?.total_revenue || 0)
  const gp = Number(profit?.gross_profit || 0)
  const margin = rev > 0 ? Math.round((gp / rev) * 100) : 0

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-3 gap-4">
        <StatCard label="إيرادات الشهر" value={`${rev.toLocaleString('ar-EG')} ج.م`} icon={ShoppingCart} color="#1e3a5f" onClick={() => navigate('/reports')} />
        <StatCard label="صافي الربح" value={`${gp.toLocaleString('ar-EG')} ج.م`} sub={`هامش ${margin}%`} icon={TrendingUp} color={gp >= 0 ? '#16a34a' : '#dc2626'} onClick={() => navigate('/reports')} />
        <StatCard label="الميزان المالي" value="عرض" icon={DollarSign} color="#7c3aed" onClick={() => navigate('/finance')} />
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-2 gap-5">
        <div className="card">
          <h3 className="font-bold text-slate-700 mb-4 text-sm">المبيعات — آخر 7 أيام</h3>
          <ResponsiveContainer width="100%" height={160}>
            <AreaChart data={chartData}>
              <defs><linearGradient id="ag" x1="0" y1="0" x2="0" y2="1"><stop offset="5%" stopColor="#1e3a5f" stopOpacity={0.15}/><stop offset="95%" stopColor="#1e3a5f" stopOpacity={0}/></linearGradient></defs>
              <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9"/>
              <XAxis dataKey="name" tick={{ fontSize: 10, fill: '#94a3b8' }} axisLine={false} tickLine={false}/>
              <YAxis tick={{ fontSize: 10, fill: '#94a3b8' }} axisLine={false} tickLine={false}/>
              <Tooltip formatter={(v: any) => [`${Number(v).toLocaleString('ar-EG')} ج.م`, '']}/>
              <Area type="monotone" dataKey="مبيعات" stroke="#1e3a5f" strokeWidth={2} fill="url(#ag)"/>
            </AreaChart>
          </ResponsiveContainer>
        </div>

        <div className="card p-4">
          <h3 className="font-bold text-slate-700 mb-3 text-sm">مبيعات الكاشيرين — هذا الشهر</h3>
          <div className="space-y-2 max-h-48 overflow-y-auto">
            {!byCashier?.length && <p className="text-slate-400 text-xs text-center py-4">لا توجد بيانات</p>}
            {byCashier?.map((c: any) => (
              <div key={c.cashier_id} className="flex items-center justify-between py-2 border-b border-slate-50 last:border-0">
                <p className="text-sm font-semibold text-slate-700">{c.cashier_name}</p>
                <div className="text-left">
                  <p className="text-sm font-black text-slate-800">{Number(c.total_sales).toLocaleString('ar-EG')} ج.م</p>
                  <p className="text-xs text-slate-400">{c.invoice_count} فاتورة</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}

// ── Main ──────────────────────────────────────────────────────────────────────
export default function DashboardPage() {
  const navigate = useNavigate()
  const { activeWarehouseId } = useAppStore()
  const { user } = useAuthStore()
  const role = (user as any)?.role || 'cashier'
  const isCompanyView = !activeWarehouseId

  const { data: warehouses } = useQuery({ queryKey: ['warehouses'], queryFn: stockApi.warehouses })
  const mainWh = warehouses?.find((w: any) => w.id === activeWarehouseId) ?? null
  const whId = activeWarehouseId || warehouses?.find((w: any) => w.warehouse_type === 'showroom')?.id

  const roleGreeting: Record<string, string> = {
    admin: '🏢 الإدارة الشاملة', manager: '👔 لوحة المشرف',
    cashier: '🛒 لوحة الكاشير', storekeeper: '📦 لوحة أمين المخازن', accountant: '📊 لوحة المحاسب',
  }

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">{mainWh ? `🏪 ${mainWh.name}` : roleGreeting[role] || 'الرئيسية'}</h1>
          <p className="text-slate-500 text-sm mt-1">{new Date().toLocaleDateString('ar-EG', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}</p>
        </div>
        {(role === 'admin' || role === 'manager' || role === 'cashier') && (
          <button onClick={() => navigate('/pos')} className="px-5 py-2.5 rounded-xl font-bold text-sm flex items-center gap-2 shadow-sm" style={{ background: '#c8a84b', color: '#1e3a5f' }}>
            <ShoppingCart size={16} /> فتح نقطة البيع
          </button>
        )}
      </div>

      {(role === 'admin' || role === 'manager') && isCompanyView && <FullAdminDashboard />}
      {(role === 'admin' || role === 'manager') && !isCompanyView && <AdminDashboard whId={whId} isCompanyView={isCompanyView} warehouses={warehouses} />}
      {role === 'cashier' && <CashierDashboard whId={whId} />}
      {role === 'storekeeper' && <StorekeeperDashboard whId={whId} />}
      {role === 'accountant' && <AccountantDashboard whId={whId} />}
    </div>
  )
}
