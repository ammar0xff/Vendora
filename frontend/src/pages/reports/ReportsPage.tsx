import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import api from '../../api/client'
import { useAppStore } from '../../store/app'
import { format, startOfWeek, endOfWeek } from 'date-fns'

const fmt = (n: any) => Number(n || 0).toLocaleString('ar-EG', { minimumFractionDigits: 0, maximumFractionDigits: 2 })

export default function ReportsPage() {
  const [tab, setTab] = useState<'ledger' | 'stats'>('ledger')
  const [ledgerPeriod, setLedgerPeriod] = useState<'daily' | 'weekly' | 'monthly' | 'yearly'>('daily')
  const [date, setDate] = useState(format(new Date(), 'yyyy-MM-dd'))
  const [statsFrom, setStatsFrom] = useState(format(new Date(new Date().getFullYear(), new Date().getMonth(), 1), 'yyyy-MM-dd'))
  const [statsTo, setStatsTo] = useState(format(new Date(), 'yyyy-MM-dd'))
  const { activeWarehouseId } = useAppStore()
  const wh = activeWarehouseId || undefined

  // Daily items
  const { data: dailyData, isLoading: loadingDaily } = useQuery({
    queryKey: ['ledger-daily', date, wh],
    queryFn: () => api.get('/reports/ledger/daily-items', { params: { target_date: date, warehouse_id: wh } }).then(r => r.data),
    enabled: ledgerPeriod === 'daily',
  })

  // Periodic (weekly/monthly/yearly)
  const { data: periodicData, isLoading: loadingPeriodic } = useQuery({
    queryKey: ['ledger-periodic', ledgerPeriod, wh],
    queryFn: () => api.get('/reports/ledger/periodic', { params: { period: ledgerPeriod, warehouse_id: wh } }).then(r => r.data),
    enabled: ledgerPeriod !== 'daily',
  })

  // Stats
  const { data: topProducts } = useQuery({
    queryKey: ['top-products', statsFrom, statsTo],
    queryFn: () => api.get('/reports/sales/top-products', { params: { from_date: statsFrom + 'T00:00:00', to_date: statsTo + 'T23:59:59', limit: 15 } }).then(r => r.data),
    enabled: tab === 'stats',
  })
  const { data: byCashier } = useQuery({
    queryKey: ['by-cashier', statsFrom, statsTo, wh],
    queryFn: () => api.get('/reports/sales/by-cashier', { params: { from_date: statsFrom + 'T00:00:00', to_date: statsTo + 'T23:59:59', warehouse_id: wh } }).then(r => r.data),
    enabled: tab === 'stats',
  })

  const periodLabels: Record<string, string> = { weekly: 'الأسبوع', monthly: 'الشهر', yearly: 'السنة' }

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">التقارير المالية</h1>
      </div>

      {/* Main tabs */}
      <div className="flex gap-0 mb-6 border-b border-slate-200">
        {[{ id: 'ledger', label: '📒 دفتر الأستاذ' }, { id: 'stats', label: '📊 الإحصائيات' }].map(t => (
          <button key={t.id} onClick={() => setTab(t.id as any)}
            className={`px-6 py-3 text-sm font-semibold border-b-2 transition-all -mb-px ${tab === t.id ? 'border-blue-600 text-blue-700' : 'border-transparent text-slate-500 hover:text-slate-700'}`}>
            {t.label}
          </button>
        ))}
      </div>

      {/* ── LEDGER TAB ── */}
      {tab === 'ledger' && (
        <div>
          {/* Period selector */}
          <div className="flex items-center gap-3 mb-5 flex-wrap">
            <div className="flex rounded-xl overflow-hidden border border-slate-200">
              {(['daily', 'weekly', 'monthly', 'yearly'] as const).map(p => (
                <button key={p} onClick={() => setLedgerPeriod(p)}
                  className={`px-4 py-2 text-xs font-bold transition-all ${ledgerPeriod === p ? 'text-white' : 'text-slate-500 hover:bg-slate-50'}`}
                  style={ledgerPeriod === p ? { background: '#1e3a5f' } : {}}>
                  {p === 'daily' ? 'يومي' : p === 'weekly' ? 'أسبوعي' : p === 'monthly' ? 'شهري' : 'سنوي'}
                </button>
              ))}
            </div>
            {ledgerPeriod === 'daily' && (
              <input type="date" className="input w-44 text-sm" value={date} onChange={e => setDate(e.target.value)} />
            )}
          </div>

          {/* Daily table */}
          {ledgerPeriod === 'daily' && (
            <div className="space-y-4">
              <div className="card p-0 overflow-hidden">
                <div className="table-wrap">
                  <table>
                    <thead>
                      <tr>
                        <th>اسم الصنف / البيان</th>
                        <th style={{ textAlign: 'center', width: '60px' }}>الوحدة</th>
                        <th style={{ textAlign: 'center', width: '80px' }}>السعر</th>
                        <th style={{ textAlign: 'center', width: '70px' }}>الكمية</th>
                        <th style={{ textAlign: 'center', width: '100px' }}>الإجمالي</th>
                        <th style={{ textAlign: 'center', width: '90px' }}>المرتجعات</th>
                      </tr>
                    </thead>
                    <tbody>
                      {loadingDaily && <tr><td colSpan={6} className="text-center py-8 text-slate-400">جاري التحميل...</td></tr>}
                      {!loadingDaily && !dailyData?.items?.length && (
                        <tr><td colSpan={6} className="text-center py-8 text-slate-400">لا توجد مبيعات في هذا اليوم</td></tr>
                      )}
                      {dailyData?.items?.map((item: any, i: number) => (
                        <tr key={i}>
                          <td className="font-medium text-slate-800">{item.name}</td>
                          <td className="text-center text-slate-500 text-xs">{item.unit}</td>
                          <td className="text-center text-slate-600">{fmt(item.price)}</td>
                          <td className="text-center font-bold">{fmt(item.qty)}</td>
                          <td className="text-center font-bold text-green-700">{fmt(item.total)}</td>
                          <td className="text-center text-red-500">{item.returns > 0 ? fmt(item.returns) : '—'}</td>
                        </tr>
                      ))}
                      {/* Expenses rows */}
                      {dailyData?.expenses?.map((e: any, i: number) => (
                        <tr key={`exp-${i}`} className="bg-amber-50">
                          <td className="text-amber-700 font-medium">💸 {e.note}</td>
                          <td colSpan={3}></td>
                          <td className="text-center font-bold text-amber-700">({fmt(e.total)})</td>
                          <td></td>
                        </tr>
                      ))}
                      {/* Totals */}
                      {dailyData?.items?.length > 0 && (() => {
                        const totalIncome = dailyData.items.reduce((s: number, i: any) => s + i.total, 0)
                        const totalReturns = dailyData.items.reduce((s: number, i: any) => s + i.returns, 0)
                        const totalExpenses = (dailyData.expenses || []).reduce((s: number, e: any) => s + e.total, 0)
                        return (
                          <tr className="font-black" style={{ background: '#1e3a5f', color: 'white' }}>
                            <td colSpan={4} className="text-white">الإجمالي</td>
                            <td className="text-center text-white">{fmt(totalIncome)}</td>
                            <td className="text-center text-red-300">{totalReturns > 0 ? fmt(totalReturns) : '—'}</td>
                          </tr>
                        )
                      })()}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}

          {/* Periodic table (weekly/monthly/yearly) */}
          {ledgerPeriod !== 'daily' && (
            <div className="card p-0 overflow-hidden">
              <div className="table-wrap">
                <table>
                  <thead>
                    <tr>
                      <th>{periodLabels[ledgerPeriod]}</th>
                      <th style={{ textAlign: 'center' }}>الدواخل</th>
                      <th style={{ textAlign: 'center' }}>المرتجعات</th>
                      <th style={{ textAlign: 'center' }}>الخوارج</th>
                      <th style={{ textAlign: 'center' }}>إجمالي الإيراد</th>
                    </tr>
                  </thead>
                  <tbody>
                    {loadingPeriodic && <tr><td colSpan={5} className="text-center py-8 text-slate-400">جاري التحميل...</td></tr>}
                    {!loadingPeriodic && !periodicData?.length && (
                      <tr><td colSpan={5} className="text-center py-8 text-slate-400">لا توجد بيانات</td></tr>
                    )}
                    {periodicData?.map((row: any, i: number) => (
                      <tr key={i}>
                        <td className="font-bold text-slate-800 font-mono">{row.period}</td>
                        <td className="text-center text-green-700 font-bold">{fmt(row.income)}</td>
                        <td className="text-center text-red-500">{row.returns > 0 ? fmt(row.returns) : '—'}</td>
                        <td className="text-center text-amber-600">{row.expenses > 0 ? fmt(row.expenses) : '—'}</td>
                        <td className="text-center font-black" style={{ color: row.net >= 0 ? '#16a34a' : '#dc2626' }}>{fmt(row.net)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </div>
      )}

      {/* ── STATS TAB ── */}
      {tab === 'stats' && (
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
      )}
    </div>
  )
}
