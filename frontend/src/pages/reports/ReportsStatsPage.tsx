import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '../../components/ui/table'
import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import api from '../../api/client'
import { useAppStore } from '../../store/app'
import { Input } from '../../components/ui/input'
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
        <Input type="date" className="w-40 text-sm" value={statsFrom} onChange={e => setStatsFrom(e.target.value)} />
        <span className="text-slate-400 text-sm">إلى</span>
        <Input type="date" className="w-40 text-sm" value={statsTo} onChange={e => setStatsTo(e.target.value)} />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Top products */}
        <div className="card p-0 overflow-hidden">
          <div className="px-5 py-3 border-b border-slate-100">
            <h3 className="font-bold text-slate-700">🏆 أكثر المنتجات مبيعاً</h3>
          </div>
          <div className="table-wrap">
            <Table>
              <TableHeader><TableRow><TableHead>#</TableHead><TableHead>المنتج</TableHead><TableHead style={{ textAlign: 'center' }}>الكمية</TableHead><TableHead style={{ textAlign: 'center' }}>الإيراد</TableHead></TableRow></TableHeader>
              <TableBody>
                {!topProducts?.length && <TableRow><TableCell colSpan={4} className="text-center py-6 text-slate-400">لا توجد بيانات</TableCell></TableRow>}
                {topProducts?.map((p: any, i: number) => (
                  <TableRow key={p.product_id}>
                    <TableCell className="text-slate-400 text-xs">{i + 1}</TableCell>
                    <TableCell className="font-medium text-slate-800">{p.product_name}</TableCell>
                    <TableCell className="text-center text-slate-600">{fmt(p.total_qty)}</TableCell>
                    <TableCell className="text-center font-bold text-green-700">{fmt(p.total_revenue)} ج.م</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        </div>

        {/* By cashier */}
        <div className="card p-0 overflow-hidden">
          <div className="px-5 py-3 border-b border-slate-100">
            <h3 className="font-bold text-slate-700">👤 مبيعات الكاشيرين</h3>
          </div>
          <div className="table-wrap">
            <Table>
              <TableHeader><TableRow><TableHead>الكاشير</TableHead><TableHead style={{ textAlign: 'center' }}>الفواتير</TableHead><TableHead style={{ textAlign: 'center' }}>الإجمالي</TableHead></TableRow></TableHeader>
              <TableBody>
                {!byCashier?.length && <TableRow><TableCell colSpan={3} className="text-center py-6 text-slate-400">لا توجد بيانات</TableCell></TableRow>}
                {byCashier?.map((c: any, idx: number) => (
                  <TableRow key={c?.cashier_id ?? idx}>
                    <TableCell className="font-semibold text-slate-800">{c.cashier_name}</TableCell>
                    <TableCell className="text-center text-slate-500">{c.invoice_count}</TableCell>
                    <TableCell className="text-center font-bold text-green-700">{fmt(c.total_sales)} ج.م</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        </div>
      </div>
    </div>
  )
}