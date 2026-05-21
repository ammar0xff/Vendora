import { useState } from 'react'
import { useQuery, useQueries } from '@tanstack/react-query'
import api from '../../api/client'
import { format, subDays, startOfMonth } from 'date-fns'
import { AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid, BarChart, Bar } from 'recharts'
import { TrendingUp, TrendingDown, Package, Wallet, AlertTriangle, Users, Building2 } from 'lucide-react'

const today = format(new Date(), 'yyyy-MM-dd')
const monthStart = format(startOfMonth(new Date()), 'yyyy-MM-dd')

function KPI({ label, value, sub, color = '#1e3a5f', icon: Icon, trend }: any) {
  return (
    <div className="card p-4">
      <div className="flex items-start justify-between mb-2">
        <p className="text-xs font-bold text-slate-400 uppercase tracking-wide">{label}</p>
        <div className="w-8 h-8 rounded-lg flex items-center justify-center" style={{ background: color + '15' }}>
          <Icon size={15} style={{ color }} />
        </div>
      </div>
      <p className="text-2xl font-black text-slate-800">{value}</p>
      {sub && <p className="text-xs text-slate-400 mt-1">{sub}</p>}
      {trend !== undefined && (
        <div className={`flex items-center gap-1 text-xs font-bold mt-1 ${trend >= 0 ? 'text-green-600' : 'text-red-500'}`}>
          {trend >= 0 ? <TrendingUp size={12} /> : <TrendingDown size={12} />}
          {Math.abs(trend)}%
        </div>
      )}
    </div>
  )
}

function fmt(n: any) { return Number(n || 0).toLocaleString('ar-EG') }
function fmtEGP(n: any) { return `${fmt(n)} ج.م` }

export default function AdminPage() {
  const [from, setFrom] = useState(monthStart)
  const [to, setTo] = useState(today)

  const { data, isLoading } = useQuery({
    queryKey: ['admin-overview', from, to],
    queryFn: () => api.get(`/admin/overview?from_date=${from}&to_date=${to}`).then(r => r.data),
  })

  const s = data?.summary || {}

  // 7-day chart
  const days = Array.from({ length: 7 }, (_, i) => {
    const d = subDays(new Date(), 6 - i)
    return { date: format(d, 'yyyy-MM-dd'), label: format(d, 'EEE').replace('Mon','إث').replace('Tue','ثل').replace('Wed','أر').replace('Thu','خم').replace('Fri','جم').replace('Sat','سب').replace('Sun','أح') }
  })
  const dayQueries = useQueries({
    queries: days.map(d => ({
      queryKey: ['admin-overview-day', d.date],
      queryFn: () => api.get(`/admin/overview?from_date=${d.date}&to_date=${d.date}`).then(r => r.data),
    })),
  })
  const chartData = days.map((d, i) => ({
    name: d.label,
    إيرادات: Number(dayQueries[i].data?.summary?.total_revenue || 0),
    ربح: Number(dayQueries[i].data?.summary?.total_profit || 0),
  }))

  return (
    <div className="space-y-6">
      {/* Date filter */}
      <div className="flex gap-2 items-center mb-4">
        <span className="text-sm text-slate-500 font-medium">الفترة:</span>
        <input type="date" className="input w-36 text-sm" value={from} onChange={e => setFrom(e.target.value)} />
        <span className="text-slate-400 text-sm">إلى</span>
        <input type="date" className="input w-36 text-sm" value={to} onChange={e => setTo(e.target.value)} />
      </div>

      {isLoading ? (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          {Array.from({length:8}).map((_,i) => <div key={i} className="card p-4 h-24 animate-pulse bg-slate-50" />)}
        </div>
      ) : (
        <>
          {/* KPIs */}
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
            <KPI label="إجمالي الإيرادات" value={fmtEGP(s.total_revenue)} sub={`هامش ${s.profit_margin}%`} icon={TrendingUp} color="#16a34a" />
            <KPI label="صافي الربح" value={fmtEGP(s.total_profit)} icon={TrendingUp} color="#16a34a" />
            <KPI label="قيمة المخزون (تكلفة)" value={fmtEGP(s.total_stock_cost)} sub={`بيع: ${fmtEGP(s.total_stock_retail)}`} icon={Package} color="#1e3a5f" />
            <KPI label="نقدي في الدرج" value={fmtEGP(s.total_cash_in_drawers)} icon={Wallet} color="#7c3aed" />
            <KPI label="مديونية العملاء" value={fmtEGP(s.total_customer_debt)} sub="علينا تحصيلها" icon={Users} color="#d97706" />
            <KPI label="مديونية الموردين" value={fmtEGP(s.total_supplier_debt)} sub="علينا دفعها" icon={Building2} color="#dc2626" />
            <KPI label="رأس المال الصافي" value={fmtEGP(s.net_capital)} sub="مخزون + نقدي - موردين" icon={TrendingUp} color="#1e3a5f" />
            <KPI label="نواقص المخزون" value={data?.low_stock?.length || 0} sub="منتج تحت الحد" icon={AlertTriangle} color={data?.low_stock?.length > 0 ? '#d97706' : '#16a34a'} />
          </div>

          {/* Charts */}
          <div className="grid grid-cols-1 xl:grid-cols-2 gap-5">
            {/* 7-day trend */}
            <div className="card">
              <h3 className="font-bold text-slate-700 mb-4">الإيرادات والأرباح — آخر 7 أيام</h3>
              <ResponsiveContainer width="100%" height={180}>
                <AreaChart data={chartData}>
                  <defs>
                    <linearGradient id="rg" x1="0" y1="0" x2="0" y2="1"><stop offset="5%" stopColor="#1e3a5f" stopOpacity={0.15}/><stop offset="95%" stopColor="#1e3a5f" stopOpacity={0}/></linearGradient>
                    <linearGradient id="pg" x1="0" y1="0" x2="0" y2="1"><stop offset="5%" stopColor="#16a34a" stopOpacity={0.15}/><stop offset="95%" stopColor="#16a34a" stopOpacity={0}/></linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9"/>
                  <XAxis dataKey="name" tick={{ fontSize: 11, fill: '#94a3b8' }} axisLine={false} tickLine={false}/>
                  <YAxis tick={{ fontSize: 10, fill: '#94a3b8' }} axisLine={false} tickLine={false}/>
                  <Tooltip formatter={(v: any, n: any) => [`${Number(v).toLocaleString('ar-EG')} ج.م`, n]}/>
                  <Area type="monotone" dataKey="إيرادات" stroke="#1e3a5f" strokeWidth={2} fill="url(#rg)"/>
                  <Area type="monotone" dataKey="ربح" stroke="#16a34a" strokeWidth={2} fill="url(#pg)"/>
                </AreaChart>
              </ResponsiveContainer>
            </div>

            {/* Branch comparison */}
            <div className="card">
              <h3 className="font-bold text-slate-700 mb-4">مقارنة الفروع — الإيرادات</h3>
              <ResponsiveContainer width="100%" height={180}>
                <BarChart data={data?.branches?.filter((b: any) => Number(b.revenue) > 0).slice(0, 6)}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9"/>
                  <XAxis dataKey="name" tick={{ fontSize: 10, fill: '#94a3b8' }} axisLine={false} tickLine={false}/>
                  <YAxis tick={{ fontSize: 10, fill: '#94a3b8' }} axisLine={false} tickLine={false}/>
                  <Tooltip formatter={(v: any) => [`${Number(v).toLocaleString('ar-EG')} ج.م`]}/>
                  <Bar dataKey="revenue" name="إيرادات" fill="#1e3a5f" radius={[4,4,0,0]}/>
                  <Bar dataKey="gross_profit" name="ربح" fill="#16a34a" radius={[4,4,0,0]}/>
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Tables row */}
          <div className="grid grid-cols-1 xl:grid-cols-3 gap-5">

            {/* Branch details */}
            <div className="card xl:col-span-1">
              <h3 className="font-bold text-slate-700 mb-3 text-sm">تفاصيل الفروع</h3>
              <div className="space-y-2">
                {data?.branches?.filter((b: any) => Number(b.revenue) > 0).map((b: any) => (
                  <div key={b.id} className="flex items-center justify-between p-2.5 bg-slate-50 rounded-xl">
                    <div>
                      <p className="font-semibold text-slate-800 text-sm">{b.warehouse_type === 'showroom' ? '🏪' : '🏭'} {b.name}</p>
                      <p className="text-xs text-slate-400">{b.invoice_count} فاتورة · نقدي: {fmtEGP(b.cash_sales)}</p>
                    </div>
                    <div className="text-left">
                      <p className="font-black text-sm" style={{ color: '#1e3a5f' }}>{fmtEGP(b.revenue)}</p>
                      <p className="text-xs text-green-600">ربح: {fmtEGP(b.gross_profit)}</p>
                    </div>
                  </div>
                ))}
                {!data?.branches?.some((b: any) => Number(b.revenue) > 0) && (
                  <p className="text-slate-400 text-xs text-center py-4">لا توجد مبيعات في هذه الفترة</p>
                )}
              </div>
            </div>

            {/* Customer debts */}
            <div className="card">
              <h3 className="font-bold text-slate-700 mb-3 text-sm flex items-center gap-2">
                <Users size={14} className="text-amber-500"/> مديونية العملاء
              </h3>
              <div className="space-y-2 max-h-64 overflow-y-auto">
                {!data?.customer_debts?.length && <p className="text-slate-400 text-xs text-center py-4">لا توجد مديونيات</p>}
                {data?.customer_debts?.map((c: any) => (
                  <div key={c.id} className="flex items-center justify-between py-2 border-b border-slate-50 last:border-0">
                    <div>
                      <p className="font-semibold text-slate-800 text-sm">{c.name}</p>
                      {c.phone && <p className="text-xs text-slate-400">{c.phone}</p>}
                    </div>
                    <span className="font-black text-amber-700 text-sm">{fmtEGP(c.balance_due)}</span>
                  </div>
                ))}
              </div>
              {data?.customer_debts?.length > 0 && (
                <div className="mt-3 pt-3 border-t border-slate-100 flex justify-between text-sm">
                  <span className="text-slate-500">الإجمالي</span>
                  <span className="font-black text-amber-700">{fmtEGP(s.total_customer_debt)}</span>
                </div>
              )}
            </div>

            {/* Supplier debts + low stock */}
            <div className="flex flex-col gap-4">
              <div className="card p-4">
                <h3 className="font-bold text-slate-700 mb-3 text-sm flex items-center gap-2">
                  <Building2 size={14} className="text-red-500"/> مديونية الموردين
                </h3>
                <div className="space-y-2 max-h-32 overflow-y-auto">
                  {!data?.supplier_debts?.length && <p className="text-slate-400 text-xs text-center py-2">لا توجد مديونيات</p>}
                  {data?.supplier_debts?.map((s: any) => (
                    <div key={s.id} className="flex justify-between py-1.5 border-b border-slate-50 last:border-0">
                      <span className="text-sm font-semibold text-slate-700">{s.name}</span>
                      <span className="font-black text-red-600 text-sm">{fmtEGP(s.balance)}</span>
                    </div>
                  ))}
                </div>
              </div>

              <div className="card p-4 flex-1">
                <h3 className="font-bold text-slate-700 mb-3 text-sm flex items-center gap-2">
                  <AlertTriangle size={14} className="text-amber-500"/> نواقص المخزون
                </h3>
                <div className="space-y-2 max-h-32 overflow-y-auto">
                  {!data?.low_stock?.length && <p className="text-slate-400 text-xs text-center py-2">✅ المخزون بخير</p>}
                  {data?.low_stock?.map((p: any) => (
                    <div key={p.name} className="flex justify-between py-1.5 border-b border-slate-50 last:border-0">
                      <span className="text-xs font-medium text-slate-700 truncate flex-1">{p.name}</span>
                      <span className={`text-xs font-black mr-2 ${Number(p.total_qty) <= 0 ? 'text-red-600' : 'text-amber-600'}`}>
                        {fmt(p.total_qty)} {p.unit}
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>

          {/* Stock per warehouse */}
          <div className="card">
            <h3 className="font-bold text-slate-700 mb-4 text-sm">قيمة المخزون لكل فرع</h3>
            <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3">
              {data?.stock_per_warehouse?.map((w: any) => (
                <div key={w.id} className="bg-slate-50 rounded-xl p-3 border border-slate-100">
                  <p className="text-xs font-bold text-slate-500 mb-1">{w.warehouse_type === 'showroom' ? '🏪' : '🏭'} {w.name}</p>
                  <p className="font-black text-slate-800">{fmtEGP(w.stock_cost_value)}</p>
                  <p className="text-xs text-slate-400">بيع: {fmtEGP(w.stock_retail_value)}</p>
                </div>
              ))}
            </div>
          </div>

          {/* Cash drawers */}
          {data?.cash_drawers?.length > 0 && (
            <div className="card">
              <h3 className="font-bold text-slate-700 mb-3 text-sm">💵 النقدي في الدرج — الورديات المفتوحة</h3>
              <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3">
                {data.cash_drawers.map((c: any) => (
                  <div key={c.name} className="bg-purple-50 rounded-xl p-3 border border-purple-100">
                    <p className="text-xs font-bold text-purple-600 mb-1">{c.name}</p>
                    <p className="font-black text-purple-800">{fmtEGP(Number(c.initial_amount) + Number(c.net_movement))}</p>
                    <p className="text-xs text-purple-400">بداية: {fmtEGP(c.initial_amount)}</p>
                  </div>
                ))}
              </div>
            </div>
          )}
        </>
      )}
    </div>
  )
}
