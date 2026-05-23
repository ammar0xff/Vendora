import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { reportsApi } from '../../api/endpoints'
import { useAppStore } from '../../store/app'
import { format, startOfMonth } from 'date-fns'
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from 'recharts'

const today = format(new Date(), 'yyyy-MM-dd')
const monthStart = format(startOfMonth(new Date()), 'yyyy-MM-dd')

export default function SalesReportContent() {
  const [from, setFrom] = useState(monthStart)
  const [to, setTo] = useState(today)
  const { activeWarehouseId } = useAppStore()
  const wh = activeWarehouseId || undefined

  const { data: byCashier } = useQuery({
    queryKey: ['cashier', from, to, wh],
    queryFn: () => reportsApi.byCashier(from, to, wh),
  })
  const { data: topProducts } = useQuery({
    queryKey: ['top-products', from, to],
    queryFn: () => reportsApi.topProducts(from, to),
  })

  return (
    <div className="space-y-6">
      {/* Date filter */}
      <div className="flex gap-3 items-center flex-wrap">
        <span className="text-sm text-slate-500 font-medium">الفترة:</span>
        <input type="date" className="input w-40 text-sm" value={from} onChange={e => setFrom(e.target.value)} />
        <span className="text-slate-400 text-sm">إلى</span>
        <input type="date" className="input w-40 text-sm" value={to} onChange={e => setTo(e.target.value)} />
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-2 gap-6">
        {/* By cashier */}
        <div className="card">
          <h3 className="font-bold text-slate-700 mb-4">مبيعات الكاشيرين</h3>
          {byCashier?.length ? (
            <>
              <ResponsiveContainer width="100%" height={180}>
                <BarChart data={byCashier}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9"/>
                  <XAxis dataKey="cashier_name" tick={{ fontSize: 10, fill: '#94a3b8' }} axisLine={false} tickLine={false}/>
                  <YAxis tick={{ fontSize: 10, fill: '#94a3b8' }} axisLine={false} tickLine={false}/>
                  <Tooltip formatter={(v: any) => [`${Number(v).toLocaleString('ar-EG')} ج.م`]}/>
                  <Bar dataKey="total_sales" name="المبيعات" fill="#1e3a5f" radius={[4,4,0,0]}/>
                </BarChart>
              </ResponsiveContainer>
              <div className="mt-4 space-y-2">
                {byCashier.map((c: any, idx: number) => (
                  <div key={c?.cashier_id ?? idx} className="flex justify-between items-center py-2 border-b border-slate-50 last:border-0">
                    <span className="font-semibold text-slate-700 text-sm">{c.cashier_name}</span>
                    <div className="text-left">
                      <span className="font-black text-slate-800">{Number(c.total_sales).toLocaleString('ar-EG')} ج.م</span>
                      <span className="text-xs text-slate-400 mr-2">{c.invoice_count} فاتورة</span>
                    </div>
                  </div>
                ))}
              </div>
            </>
          ) : <p className="text-slate-400 text-center py-8">لا توجد بيانات</p>}
        </div>

        {/* Top products */}
        <div className="card">
          <h3 className="font-bold text-slate-700 mb-4">أكثر المنتجات مبيعاً</h3>
          <div className="space-y-3">
            {topProducts?.slice(0, 10).map((p: any, i: number) => {
              const max = Number(topProducts[0]?.total_revenue || 1)
              const pct = Math.round((Number(p.total_revenue) / max) * 100)
              const colors = ['#1e3a5f','#16a34a','#c8a84b','#7c3aed','#0891b2','#dc2626','#d97706','#059669','#6366f1','#ec4899']
              return (
                <div key={p.product_id}>
                  <div className="flex justify-between mb-1">
                    <span className="text-xs font-semibold text-slate-700 truncate flex-1">{i+1}. {p.product_name}</span>
                    <span className="text-xs font-black ml-2 flex-shrink-0" style={{ color: colors[i] }}>
                      {Number(p.total_revenue).toLocaleString('ar-EG')} ج.م · {Number(p.total_qty).toLocaleString('ar-EG')} {p.unit}
                    </span>
                  </div>
                  <div className="h-1.5 bg-slate-100 rounded-full">
                    <div className="h-full rounded-full" style={{ width: `${pct}%`, background: colors[i] }} />
                  </div>
                </div>
              )
            })}
            {!topProducts?.length && <p className="text-slate-400 text-center py-8">لا توجد بيانات</p>}
          </div>
        </div>
      </div>
    </div>
  )
}
