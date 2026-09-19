import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import api from '../../api/client'
import { useAppStore } from '../../store/app'
import { format } from 'date-fns'

const fmt = (n: any) => Number(n || 0).toLocaleString('ar-EG', { minimumFractionDigits: 0, maximumFractionDigits: 2 })

export default function ReportsStatsPage() {
  const [statsFrom, setStatsFrom] = useState(format(new Date(new Date().getFullYear(), new Date().getMonth(), 1), 'yyyy-MM-dd'))
  const [statsTo, setStatsTo] = useState(format(new Date(), 'yyyy-MM-dd'))
  const { activeWarehouseId } = useAppStore()
  const wh = activeWarehouseId || undefined

  const { data: topProducts } = useQuery({
    queryKey: ['top-products', statsFrom, statsTo],
    queryFn: () => api.get('/reports/sales/top-products', { params: { from_date: statsFrom + 'T00:00:00', to_date: statsTo + 'T23:59:59', limit: 15 } }).then(r => r.data),
  })
  const { data: byCashier } = useQuery({
    queryKey: ['by-cashier', statsFrom, statsTo, wh],
    queryFn: () => api.get('/reports/sales/by-cashier', { params: { from_date: statsFrom + 'T00:00:00', to_date: statsTo + 'T23:59:59', warehouse_id: wh } }).then(r => r.data),
  })

  return (
    <div>
      {/* Date range */}
      <div className="flex items-center gap-3 mb-5 flex-wrap">
        <input type="date" className="input w-40 text-sm" value={statsFrom} onChange={e => setStatsFrom(e.target.value)} />
        <span className="text-slate-400 text-sm">إلى</span>
        <input type="date" className="input w-40 text-sm" value={statsTo} onChange={e => setStatsTo(e.target.value)} />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Top products */}
        <div className="card p-0 overflow-hidden">
          <div className="px-5 py-3 border-b border-slate-100">
            <h3 className="font-bold text-slate-700">🏆 أكثر المنتجات مبيعاً</h3>
          </div>
          <div className="table-wrap">
            <table>
              <thead><tr><th>#</th><th>المنتج</th><th style={{ textAlign: 'center' }}>الكمية</th><th style={{ textAlign: 'center' }}>الإيراد</th></tr></thead>
              <tbody>
                {!topProducts?.length && <tr><td colSpan={4} className="text-center py-6 text-slate-400">لا توجد بيانات</td></tr>}
                {topProducts?.map((p: any, i: number) => (
                  <tr key={p.product_id}>
                    <td className="text-slate-400 text-xs">{i + 1}</td>
                    <td className="font-medium text-slate-800">{p.product_name}</td>
                    <td className="text-center text-slate-600">{fmt(p.total_qty)}</td>
                    <td className="text-center font-bold text-green-700">{fmt(p.total_revenue)} ج.م</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* By cashier */}
        <div className="card p-0 overflow-hidden">
          <div className="px-5 py-3 border-b border-slate-100">
            <h3 className="font-bold text-slate-700">👤 مبيعات الكاشيرين</h3>
          </div>
          <div className="table-wrap">
            <table>
              <thead><tr><th>الكاشير</th><th style={{ textAlign: 'center' }}>الفواتير</th><th style={{ textAlign: 'center' }}>الإجمالي</th></tr></thead>
              <tbody>
                {!byCashier?.length && <tr><td colSpan={3} className="text-center py-6 text-slate-400">لا توجد بيانات</td></tr>}
                {byCashier?.map((c: any, idx: number) => (
                  <tr key={c?.cashier_id ?? idx}>
                    <td className="font-semibold text-slate-800">{c.cashier_name}</td>
                    <td className="text-center text-slate-500">{c.invoice_count}</td>
                    <td className="text-center font-bold text-green-700">{fmt(c.total_sales)} ج.م</td>
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