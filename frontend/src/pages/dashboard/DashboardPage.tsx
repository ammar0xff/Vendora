import { useQuery, useQueries } from '@tanstack/react-query'
import { stockApi, reportsApi, shiftsApi } from '../../api/endpoints'
import { format, subDays } from 'date-fns'
import { AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from 'recharts'
import { ShoppingCart, Package, AlertTriangle, Wallet, ArrowUpRight } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { useAppStore } from '../../store/app'
import api from '../../api/client'
import { useAuthStore } from '../../store/auth'

const today = format(new Date(), 'yyyy-MM-dd')

function StatCard({ label, value, sub, icon: Icon, color, onClick }: any) {
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
    </div>
  )
}

export default function DashboardPage() {
  const navigate = useNavigate()
  const { activeWarehouseId } = useAppStore()
  const { user } = useAuthStore()
  const isCompanyView = !activeWarehouseId
  const isManager = (user as any)?.is_manager

  const { data: warehouses } = useQuery({ queryKey: ['warehouses'], queryFn: stockApi.warehouses })
  const mainWh = warehouses?.find((w: any) => w.id === activeWarehouseId) ?? null
  const whId = activeWarehouseId || warehouses?.find((w: any) => w.warehouse_type === 'showroom')?.id

  const { data: daily } = useQuery({ queryKey: ['daily', today, whId], queryFn: () => reportsApi.daily(today, whId || undefined) })
  const { data: valuation } = useQuery({ queryKey: ['valuation', whId], queryFn: () => stockApi.valuation(whId!), enabled: !!whId })
  const { data: lowStock } = useQuery({ queryKey: ['lowstock', whId], queryFn: () => stockApi.lowStock(whId!, 5), enabled: !!whId })
  const { data: shift } = useQuery({ queryKey: ['current-shift', whId], queryFn: () => shiftsApi.current(whId!), retry: false, throwOnError: false, enabled: !!whId })
  const { data: shiftSummary } = useQuery({ queryKey: ['shift-summary', shift?.id], queryFn: () => api.get(`/shifts/${shift!.id}/summary`).then(r => r.data), enabled: !!shift?.id })

  const todaySales = Number(daily?.total_sales || 0)

  const days = Array.from({ length: 7 }, (_, i) => {
    const d = subDays(new Date(), 6 - i)
    return { date: format(d, 'yyyy-MM-dd'), label: format(d, 'EEE').replace('Mon','إث').replace('Tue','ثل').replace('Wed','أر').replace('Thu','خم').replace('Fri','جم').replace('Sat','سب').replace('Sun','أح') }
  })
  const dayQueries = days.map(d => ({ queryKey: ['daily', d.date, whId], queryFn: () => reportsApi.daily(d.date, whId || undefined) }))
  const dayResults = useQueries({ queries: dayQueries })

  const expenses = Number(shiftSummary?.expenses_total || 0) + Number(shiftSummary?.withdrawals_total || 0)
  const drawerBalance = shiftSummary?.cash_in_drawer ?? shift?.initial_amount
  const chartData = days.map((d, i) => ({ name: d.label, مبيعات: Number(dayResults[i]?.data?.total_sales || 0) }))

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">{mainWh ? `🏪 ${mainWh.name}` : '🏢 الرئيسية'}</h1>
          <p className="text-slate-500 text-sm mt-1">{new Date().toLocaleDateString('ar-EG', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}</p>
        </div>
        <button onClick={() => navigate('/pos')} className="px-5 py-2.5 rounded-xl font-bold text-sm flex items-center gap-2 shadow-sm" style={{ background: '#c8a84b', color: '#1e3a5f' }}>
          <ShoppingCart size={16} /> فتح نقطة البيع
        </button>
      </div>

      <div className="grid grid-cols-2 xl:grid-cols-4 gap-4 mb-6">
        <StatCard label="مبيعات اليوم" value={`${todaySales.toLocaleString('ar-EG')} ج.م`} sub={`${daily?.invoice_count || 0} فاتورة`} icon={ShoppingCart} color="#1e3a5f" onClick={() => navigate('/sales')} />
        <StatCard label="قيمة المخزون" value={`${Number(valuation?.total_retail_value || 0).toLocaleString('ar-EG')} ج.م`} sub={`${valuation?.product_count || 0} منتج`} icon={Package} color="#16a34a" onClick={() => navigate('/inventory')} />
        <StatCard label="منتجات ناقصة" value={lowStock?.length || 0} sub="تحت الحد الأدنى" icon={AlertTriangle} color={lowStock?.length > 0 ? '#d97706' : '#16a34a'} onClick={() => navigate('/inventory')} />
        <StatCard label="رصيد الدرج" value={shift ? `${Number(drawerBalance).toLocaleString('ar-EG')} ج.م` : 'مغلق'} sub={shift ? 'وردية مفتوحة' : 'لا توجد وردية'} icon={Wallet} color={shift ? '#7c3aed' : '#94a3b8'} onClick={() => navigate('/pos')} />
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-3 gap-5">
        <div className="card xl:col-span-2">
          <div className="flex items-center justify-between mb-5">
            <h3 className="font-bold text-slate-700">المبيعات — آخر 7 أيام</h3>
            <button onClick={() => navigate('/accounting')} className="text-xs text-blue-600 hover:underline flex items-center gap-1">التقارير <ArrowUpRight size={12} /></button>
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
            <h3 className="font-bold text-slate-700 mb-3 text-sm">الوردية الحالية</h3>
            {shift ? (
              <>
                  <div className="grid grid-cols-2 gap-2 mb-3">
                    <div className="bg-green-50 rounded-xl p-3 text-center"><p className="text-xs text-green-600 font-medium mb-1">المبيعات</p><p className="text-base font-black text-green-700">{Number(shiftSummary?.sales_total || 0).toLocaleString('ar-EG')} ج.م</p></div>
                    <div className="bg-red-50 rounded-xl p-3 text-center"><p className="text-xs text-red-600 font-medium mb-1">المصروفات</p><p className="text-base font-black text-red-700">{expenses.toLocaleString('ar-EG')} ج.م</p></div>
                  </div>
                {isManager && <div className="text-xs text-amber-700 text-center py-1 bg-amber-50 rounded-lg">🔑 مدير</div>}
              </>
            ) : (
              <p className="text-slate-400 text-xs text-center py-3">لا توجد وردية مفتوحة</p>
            )}
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
    </div>
  )
}
