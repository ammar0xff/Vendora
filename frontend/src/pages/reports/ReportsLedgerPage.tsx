import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import api from '../../api/client'
import { useAppStore } from '../../store/app'
import { format } from 'date-fns'

const fmt = (n: any) => Number(n || 0).toLocaleString('ar-EG', { minimumFractionDigits: 0, maximumFractionDigits: 2 })

export default function ReportsLedgerPage() {
  const [ledgerPeriod, setLedgerPeriod] = useState<'daily' | 'weekly' | 'monthly' | 'yearly'>('daily')
  const [date, setDate] = useState(format(new Date(), 'yyyy-MM-dd'))
  const { activeWarehouseId } = useAppStore()
  const wh = activeWarehouseId || undefined

  const { data: dailyData, isLoading: loadingDaily } = useQuery({
    queryKey: ['ledger-daily', date, wh],
    queryFn: () => api.get('/reports/ledger/daily-items', { params: { target_date: date, warehouse_id: wh } }).then(r => r.data),
    enabled: ledgerPeriod === 'daily',
  })

  const { data: periodicData, isLoading: loadingPeriodic } = useQuery({
    queryKey: ['ledger-periodic', ledgerPeriod, wh],
    queryFn: () => api.get('/reports/ledger/periodic', { params: { period: ledgerPeriod, warehouse_id: wh } }).then(r => r.data),
    enabled: ledgerPeriod !== 'daily',
  })

  const periodLabels: Record<string, string> = { weekly: 'الأسبوع', monthly: 'الشهر', yearly: 'السنة' }

  return (
    <div>
      {/* Period selector */}
      <div className="flex items-center gap-3 mb-5 flex-wrap">
        <div className="flex rounded-xl overflow-hidden border border-slate-200">
          {(['daily', 'weekly', 'monthly', 'yearly'] as const).map(p => (
            <button key={p} onClick={() => setLedgerPeriod(p)}
              className={`px-4 py-2 text-xs font-bold transition-all ${ledgerPeriod === p ? 'text-white' : 'text-slate-500 hover:bg-slate-50'}`}
              style={ledgerPeriod === p ? { background: 'var(--primary)' } : {}}>
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
                  {dailyData?.expenses?.map((e: any, i: number) => (
                    <tr key={`exp-${i}`} className="bg-amber-50">
                      <td className="text-amber-700 font-medium">💸 {e.note}</td>
                      <td colSpan={3}></td>
                      <td className="text-center font-bold text-amber-700">({fmt(e.total)})</td>
                      <td></td>
                    </tr>
                  ))}
                  {dailyData?.items?.length > 0 && (() => {
                    const totalIncome = dailyData.items.reduce((s: number, i: any) => s + i.total, 0)
                    const totalReturns = dailyData.items.reduce((s: number, i: any) => s + i.returns, 0)
                    return (
                      <tr className="font-black" style={{ background: 'var(--primary)', color: 'white' }}>
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
  )
}