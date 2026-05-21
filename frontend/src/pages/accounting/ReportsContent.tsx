import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { reportsApi, stockApi } from '../../api/endpoints'
import { useAppStore } from '../../store/app'
import toast from 'react-hot-toast'
import { format, subMonths } from 'date-fns'
import { openPrint } from '../../utils/format'
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from 'recharts'
import { BarChart3, TrendingUp, Package, Users, Printer } from 'lucide-react'

const COLORS = ['#1e3a5f', '#c8a84b', '#16a34a', '#7c3aed', '#dc2626', '#0891b2']

export default function ReportsContent() {
  const today = format(new Date(), 'yyyy-MM-dd')
  const monthStart = format(new Date(new Date().getFullYear(), new Date().getMonth(), 1), 'yyyy-MM-dd')
  const [from, setFrom] = useState(monthStart)
  const [to, setTo] = useState(today)
  const [printing, setPrinting] = useState(false)
  const dateError = from > to

  const { data: warehouses } = useQuery({ queryKey: ['warehouses'], queryFn: stockApi.warehouses })
  const { activeWarehouseId } = useAppStore()
  const mainWh = activeWarehouseId || warehouses?.[0]?.id

  const { data: profit } = useQuery({
    queryKey: ['profit', from, to, activeWarehouseId], queryFn: () => reportsApi.profit(from, to, activeWarehouseId || undefined),
    enabled: !dateError,
  })
  const { data: topProducts } = useQuery({
    queryKey: ['top-products', from, to], queryFn: () => reportsApi.topProducts(from, to),
    enabled: !dateError,
  })
  const { data: byCashier } = useQuery({
    queryKey: ['by-cashier', from, to, activeWarehouseId], queryFn: () => reportsApi.byCashier(from, to, activeWarehouseId || undefined),
    enabled: !dateError,
  })

  const handleInventoryPrint = () => {
    if (!mainWh) return toast.error('اختر فرعاً أولاً')
    setPrinting(true)
    openPrint(`/print/inventory/${mainWh}`)
    setTimeout(() => setPrinting(false), 3000)
  }

  // Monthly trend
  const months = Array.from({ length: 6 }, (_, i) => {
    const d = subMonths(new Date(), 5 - i)
    return { year: d.getFullYear(), month: d.getMonth() + 1, label: d.toLocaleString('ar-EG', { month: 'short' }) }
  })
  const m0 = useQuery({ queryKey: ['m', months[0].year, months[0].month], queryFn: () => reportsApi.monthly(months[0].year, months[0].month, activeWarehouseId || undefined) })
  const m1 = useQuery({ queryKey: ['m', months[1].year, months[1].month], queryFn: () => reportsApi.monthly(months[1].year, months[1].month, activeWarehouseId || undefined) })
  const m2 = useQuery({ queryKey: ['m', months[2].year, months[2].month], queryFn: () => reportsApi.monthly(months[2].year, months[2].month, activeWarehouseId || undefined) })
  const m3 = useQuery({ queryKey: ['m', months[3].year, months[3].month], queryFn: () => reportsApi.monthly(months[3].year, months[3].month, activeWarehouseId || undefined) })
  const m4 = useQuery({ queryKey: ['m', months[4].year, months[4].month], queryFn: () => reportsApi.monthly(months[4].year, months[4].month, activeWarehouseId || undefined) })
  const m5 = useQuery({ queryKey: ['m', months[5].year, months[5].month], queryFn: () => reportsApi.monthly(months[5].year, months[5].month, activeWarehouseId || undefined) })
  const chartData = [m0, m1, m2, m3, m4, m5].map((q, i) => ({ name: months[i].label, مبيعات: Number(q.data?.total_sales || 0) }))

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">التقارير والإحصائيات</h1>
        <div className="flex gap-3 items-center flex-wrap">
          <button onClick={handleInventoryPrint} disabled={printing} className="btn-ghost px-4 py-2 rounded-xl font-semibold text-sm flex items-center gap-2 border border-slate-200 disabled:opacity-50">
            <Printer size={16} /> {printing ? 'جاري التحميل...' : 'طباعة تقرير المخزون'}
          </button>
          <label className="text-sm text-slate-500">من</label>
          <input type="date" className="input w-40" value={from} onChange={e => setFrom(e.target.value)} />
          <label className="text-sm text-slate-500">إلى</label>
          <input type="date" className="input w-40" value={to} onChange={e => setTo(e.target.value)} />
          {dateError && <span className="text-red-500 text-xs font-semibold">تاريخ البداية بعد تاريخ النهاية</span>}
        </div>
      </div>

      {dateError && (
        <div className="card p-8 text-center mb-6">
          <p className="text-slate-400">يرجى تصحيح التواريخ — تاريخ البداية يجب أن يكون قبل تاريخ النهاية</p>
        </div>
      )}

      {!dateError && profit && (
        <>
          {/* P&L Summary */}
          <div className="card mb-6">
            <h3 className="font-bold text-slate-700 mb-4">قائمة الأرباح والخسائر</h3>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-4">
              {[
                { label: 'إجمالي الإيرادات', value: profit.total_revenue, color: '#16a34a', icon: TrendingUp },
                { label: 'تكلفة البضاعة (COGS)', value: profit.total_cogs, color: '#dc2626', icon: Package },
                { label: 'مجمل الربح', value: profit.gross_profit, sub: `${profit.gross_margin}%`, color: '#1e3a5f', icon: BarChart3 },
                { label: 'صافي الربح', value: profit.net_profit, sub: `${profit.net_margin}%`, color: Number(profit.net_profit) >= 0 ? '#16a34a' : '#dc2626', icon: TrendingUp },
              ].map(({ label, value, sub, color, icon: Icon }) => (
                <div key={label} className="stat-card">
                  <div className="stat-icon" style={{ background: color + '20' }}><Icon size={22} style={{ color }} /></div>
                  <div>
                    <p className="text-slate-500 text-xs mb-1">{label}</p>
                    <p className="text-xl font-black" style={{ color }}>{Number(value).toLocaleString('ar-EG')} ج.م</p>
                    {sub && <p className="text-xs text-slate-400">{sub}</p>}
                  </div>
                </div>
              ))}
            </div>

            {/* P&L waterfall */}
            <div className="border border-slate-100 rounded-xl overflow-hidden text-sm">
              {[
                { label: 'إيرادات المبيعات', value: profit.total_revenue, type: 'revenue' },
                { label: 'المرتجعات', value: -Number(profit.total_returns || 0), type: 'deduct' },
                { label: 'صافي الإيرادات', value: profit.net_revenue, type: 'subtotal' },
                { label: 'تكلفة البضاعة المباعة', value: -Number(profit.total_cogs), type: 'deduct' },
                { label: 'مجمل الربح', value: profit.gross_profit, type: 'subtotal' },
                ...(profit.expenses_detail || []).map((e: any) => ({ label: `مصروف: ${e.note}`, value: -e.amount, type: 'deduct' })),
                { label: 'إجمالي المصروفات', value: -Number(profit.total_expenses || 0), type: 'deduct' },
                { label: 'صافي الربح', value: profit.net_profit, type: 'total' },
              ].map((row, i) => (
                <div key={i} className={`flex justify-between px-4 py-2.5 border-b border-slate-50 last:border-0 ${row.type === 'total' ? 'bg-slate-800 text-white font-black' : row.type === 'subtotal' ? 'bg-slate-50 font-bold' : ''}`}>
                  <span className={row.type === 'total' ? 'text-white' : 'text-slate-600'}>{row.label}</span>
                  <span className={`font-bold ${row.type === 'total' ? 'text-white text-base' : Number(row.value) < 0 ? 'text-red-600' : 'text-green-700'}`}>
                    {Number(row.value) < 0 ? '(' : ''}{Math.abs(Number(row.value)).toLocaleString('ar-EG')} ج.م{Number(row.value) < 0 ? ')' : ''}
                  </span>
                </div>
              ))}
            </div>
          </div>
        </>
      )}

      <div className="grid grid-cols-1 xl:grid-cols-2 gap-6 mb-6">
        {/* Monthly trend */}
        <div className="card">
          <h3 className="font-bold text-slate-700 mb-5 flex items-center gap-2"><BarChart3 size={18} /> اتجاه المبيعات الشهري</h3>
          <ResponsiveContainer width="100%" height={220}>
            <BarChart data={chartData} barSize={28}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
              <XAxis dataKey="name" tick={{ fontSize: 12, fill: '#94a3b8' }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fontSize: 11, fill: '#94a3b8' }} axisLine={false} tickLine={false} />
              <Tooltip formatter={(v: any) => [`${Number(v).toLocaleString('ar-EG')} ج.م`, 'المبيعات']} />
              <Bar dataKey="مبيعات" fill="#1e3a5f" radius={[6, 6, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Top products — horizontal bar */}
        <div className="card">
          <h3 className="font-bold text-slate-700 mb-4 flex items-center gap-2"><Package size={18} /> أكثر المنتجات مبيعاً</h3>
          {topProducts?.length ? (
            <div className="space-y-3">
              {topProducts.slice(0, 8).map((p: any, i: number) => {
                const maxRev = Number(topProducts[0]?.total_revenue || 1)
                const pct = Math.round((Number(p.total_revenue) / maxRev) * 100)
                return (
                  <div key={p.product_id}>
                    <div className="flex items-center justify-between mb-1">
                      <span className="text-sm font-semibold text-slate-700 truncate flex-1 ml-3">{i+1}. {p.product_name}</span>
                      <div className="text-left flex-shrink-0">
                        <span className="text-sm font-black" style={{ color: COLORS[i % COLORS.length] }}>{Number(p.total_revenue).toLocaleString('ar-EG')} ج.م</span>
                        <span className="text-xs text-slate-400 mr-2">{Number(p.total_qty).toLocaleString('ar-EG')} {p.unit}</span>
                      </div>
                    </div>
                    <div className="h-2 bg-slate-100 rounded-full overflow-hidden">
                      <div className="h-full rounded-full transition-all" style={{ width: `${pct}%`, background: COLORS[i % COLORS.length] }} />
                    </div>
                  </div>
                )
              })}
            </div>
          ) : <p className="text-slate-400 text-center py-12">لا توجد بيانات</p>}
        </div>
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-2 gap-6">
        {/* Top products table — compact */}
        <div className="card">
          <h3 className="font-bold text-slate-700 mb-4">تفاصيل المبيعات بالمنتج</h3>
          <div className="table-wrap max-h-64 overflow-y-auto">
            <table>
              <thead><tr><th style={{width:'32px'}}>#</th><th>المنتج</th><th style={{textAlign:'center'}}>الكمية</th><th style={{textAlign:'left'}}>الإيراد</th></tr></thead>
              <tbody>
                {topProducts?.map((p: any, i: number) => (
                  <tr key={p.product_id}>
                    <td className="text-slate-400 text-xs">{i + 1}</td>
                    <td className="font-semibold text-sm">{p.product_name}</td>
                    <td className="text-center text-slate-600">{Number(p.total_qty).toLocaleString('ar-EG')} {p.unit}</td>
                    <td className="font-black text-green-700" style={{textAlign:'left'}}>{Number(p.total_revenue).toLocaleString('ar-EG')} ج.م</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* By cashier */}
        <div className="card">
          <h3 className="font-bold text-slate-700 mb-4 flex items-center gap-2"><Users size={16} /> مبيعات الكاشيرين</h3>
          <div className="table-wrap max-h-64 overflow-y-auto">
            <table>
              <thead><tr><th>الموظف</th><th>الفواتير</th><th>الإجمالي</th></tr></thead>
              <tbody>
                {byCashier?.map((c: any) => (
                  <tr key={c.cashier_id}>
                    <td className="font-medium">{c.cashier_name}</td>
                    <td>{c.invoice_count}</td>
                    <td className="font-bold text-green-700">{Number(c.total_sales).toLocaleString('ar-EG')} ج.م</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  )
}
