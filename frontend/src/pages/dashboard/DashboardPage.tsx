import { useQuery, useQueries } from '@tanstack/react-query'
import { stockApi, reportsApi, shiftsApi } from '../../api/endpoints'
import { format, subDays } from 'date-fns'
import { AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from 'recharts'
import { ShoppingCart, Package, AlertTriangle, Wallet } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { useAppStore } from '../../store/app'
import api from '../../api/client'
import { useAuthStore } from '../../store/auth'

const today = format(new Date(), 'yyyy-MM-dd')

function StatCard({ label, value, sub, icon: Icon, color, onClick }: any) {
  return (
    <div onClick={onClick} className={`stat-card ${onClick ? 'cursor-pointer hover:shadow-[var(--shadow-md)] hover:border-[var(--border-strong)] transition-all' : ''}`}>
      <div className="stat-icon flex-shrink-0" style={{ background: color + '12', color }}>
        <Icon size={20} />
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-[11px] font-bold mb-0.5" style={{ color: 'var(--muted)' }}>{label}</p>
        <p className="text-lg font-black text-[var(--text)] truncate tabular">{value}</p>
        {sub && <p className="text-[11px] mt-0.5" style={{ color: 'var(--muted)' }}>{sub}</p>}
      </div>
    </div>
  )
}

export default function DashboardPage() {
  const navigate = useNavigate()
  const { activeWarehouseId } = useAppStore()
  const { user } = useAuthStore()
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
          <h1 className="page-title tabular">{mainWh ? `🏪 ${mainWh.name}` : '🏢 الرئيسية'}</h1>
          <p className="page-subtitle">{new Date().toLocaleDateString('ar-EG', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}</p>
        </div>
        <button onClick={() => navigate('/pos')} className="btn-accent">
          <ShoppingCart size={16} /> فتح نقطة البيع
        </button>
      </div>

      <div className="grid grid-cols-2 xl:grid-cols-4 gap-4 mb-5">
        <StatCard label="مبيعات اليوم" value={`${todaySales.toLocaleString('ar-EG')} ج.م`} sub={`${daily?.invoice_count || 0} فاتورة`} icon={ShoppingCart} color="#1e3a5f" onClick={() => navigate('/sales')} />
        <StatCard label="قيمة المخزون" value={`${Number(valuation?.total_retail_value || 0).toLocaleString('ar-EG')} ج.م`} sub={`${valuation?.product_count || 0} منتج`} icon={Package} color="#15803d" onClick={() => navigate('/inventory')} />
        <StatCard label="منتجات ناقصة" value={lowStock?.length || 0} sub="تحت الحد الأدنى" icon={AlertTriangle} color={lowStock?.length > 0 ? '#d97706' : '#15803d'} onClick={() => navigate('/inventory')} />
        <StatCard label="رصيد الدرج" value={shift ? `${Number(drawerBalance).toLocaleString('ar-EG')} ج.م` : 'مغلق'} sub={shift ? 'وردية مفتوحة' : 'لا توجد وردية'} icon={Wallet} color={shift ? '#7c3aed' : '#94a3b8'} onClick={() => navigate('/pos')} />
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-3 gap-4">
        <div className="card xl:col-span-2">
          <div className="flex items-center justify-between mb-5">
            <div>
              <h3 className="font-bold text-[var(--text)]">المبيعات — آخر 7 أيام</h3>
              <p className="text-[11px] text-[var(--muted)] mt-0.5">إجمالي المبيعات لكل يوم</p>
            </div>
            <button onClick={() => navigate('/accounting')} className="btn-ghost btn-sm text-[var(--primary)]">التقارير</button>
          </div>
          <ResponsiveContainer width="100%" height={220}>
            <AreaChart data={chartData}>
              <defs><linearGradient id="sg" x1="0" y1="0" x2="0" y2="1"><stop offset="5%" stopColor="#1e3a5f" stopOpacity={0.18}/><stop offset="95%" stopColor="#1e3a5f" stopOpacity={0}/></linearGradient></defs>
              <CartesianGrid strokeDasharray="3 3" stroke="#edf0f5"/>
              <XAxis dataKey="name" tick={{ fontSize: 11, fill: '#8a94a6', fontFamily: 'Cairo' }} axisLine={false} tickLine={false} dy={4}/>
              <YAxis tick={{ fontSize: 10, fill: '#8a94a6', fontFamily: 'Cairo' }} axisLine={false} tickLine={false} width={44}/>
              <Tooltip formatter={(v: any) => [`${Number(v).toLocaleString('ar-EG')} ج.م`, 'المبيعات']} contentStyle={{ fontFamily: 'Cairo', direction: 'rtl', borderRadius: 12, border: '1px solid #e4e9f0', boxShadow: '0 8px 24px rgba(15,23,42,0.08)' }} />
              <Area type="monotone" dataKey="مبيعات" stroke="#1e3a5f" strokeWidth={2.5} fill="url(#sg)" dot={{ fill: '#1e3a5f', r: 3, strokeWidth: 0 }} activeDot={{ r: 5 }} />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        <div className="flex flex-col gap-4">
          <div className="card p-4">
            <h3 className="font-bold text-[var(--text)] mb-3 text-sm">الوردية الحالية</h3>
            {shift ? (
              <>
                  <div className="grid grid-cols-2 gap-2 mb-3">
                    <div className="bg-emerald-50 rounded-[var(--r-md)] p-3 text-center border border-emerald-100"><p className="text-[11px] text-emerald-600 font-bold mb-1">المبيعات</p><p className="text-base font-black text-emerald-700 tabular">{Number(shiftSummary?.sales_total || 0).toLocaleString('ar-EG')} ج.م</p></div>
                    <div className="bg-red-50 rounded-[var(--r-md)] p-3 text-center border border-red-100"><p className="text-[11px] text-red-600 font-bold mb-1">المصروفات</p><p className="text-base font-black text-red-700 tabular">{expenses.toLocaleString('ar-EG')} ج.م</p></div>
                  </div>
                {isManager && <div className="text-[11px] text-amber-700 text-center py-1.5 bg-amber-50 rounded-lg border border-amber-100 font-bold">🔑 مدير</div>}
              </>
            ) : (
              <div className="flex flex-col items-center gap-2 py-4">
                <span className="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center text-lg">💤</span>
                <p className="text-[var(--muted)] text-xs">لا توجد وردية مفتوحة</p>
              </div>
            )}
          </div>
          <div className="card p-4 flex-1">
            <div className="flex items-center justify-between mb-3">
              <h3 className="font-bold text-[var(--text)] text-sm flex items-center gap-1.5"><span className="w-2 h-2 rounded-full bg-amber-400 inline-block"/> تنبيهات المخزون</h3>
              <button onClick={() => navigate('/inventory')} className="btn-ghost btn-sm text-[var(--primary)]">عرض الكل</button>
            </div>
            <div className="space-y-2 max-h-48 overflow-y-auto">
              {!lowStock?.length && <p className="text-[var(--muted)] text-xs text-center py-4">✅ المخزون بخير</p>}
              {lowStock?.slice(0, 8).map((item: any) => (
                <div key={item.product_id} className="flex items-center justify-between py-2 border-b border-[#eef1f5] last:border-0">
                  <p className="text-xs font-semibold text-[var(--text)] truncate flex-1 ml-2">{item.product_name}</p>
                  <span className={`text-[11px] font-bold px-2 py-0.5 rounded-full ${item.current_qty <= 0 ? 'bg-red-50 text-red-600 border border-red-100' : 'bg-amber-50 text-amber-700 border border-amber-100'}`}>{item.current_qty} {item.unit}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}