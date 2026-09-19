import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '../../components/ui/table'
import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import api from '../../api/client'
import { useAppStore } from '../../store/app'
import { Input } from '../../components/ui/input'
import { format } from 'date-fns'
import { Button } from '../../components/ui/button'

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
            <Button key={p} variant="ghost" size="sm" onClick={() => setLedgerPeriod(p)}
              className={`px-4 text-xs font-bold transition-all ${ledgerPeriod === p ? 'text-white' : 'text-slate-500 hover:bg-slate-50'}`}
              style={ledgerPeriod === p ? { background: 'var(--primary)' } : {}}>
              {p === 'daily' ? 'يومي' : p === 'weekly' ? 'أسبوعي' : p === 'monthly' ? 'شهري' : 'سنوي'}
            </Button>
          ))}
        </div>
        {ledgerPeriod === 'daily' && (
          <Input type="date" className="w-44 text-sm" value={date} onChange={e => setDate(e.target.value)} />
        )}
      </div>

      {/* Daily table */}
      {ledgerPeriod === 'daily' && (
        <div className="space-y-4">
          <div className="card p-0 overflow-hidden">
            <div className="table-wrap">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>اسم الصنف / البيان</TableHead>
                    <TableHead style={{ textAlign: 'center', width: '60px' }}>الوحدة</TableHead>
                    <TableHead style={{ textAlign: 'center', width: '80px' }}>السعر</TableHead>
                    <TableHead style={{ textAlign: 'center', width: '70px' }}>الكمية</TableHead>
                    <TableHead style={{ textAlign: 'center', width: '100px' }}>الإجمالي</TableHead>
                    <TableHead style={{ textAlign: 'center', width: '90px' }}>المرتجعات</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {loadingDaily && <TableRow><TableCell colSpan={6} className="text-center py-8 text-slate-400">جاري التحميل...</TableCell></TableRow>}
                  {!loadingDaily && !dailyData?.items?.length && (
                    <TableRow><TableCell colSpan={6} className="text-center py-8 text-slate-400">لا توجد مبيعات في هذا اليوم</TableCell></TableRow>
                  )}
                  {dailyData?.items?.map((item: any, i: number) => (
                    <TableRow key={i}>
                      <TableCell className="font-medium text-slate-800">{item.name}</TableCell>
                      <TableCell className="text-center text-slate-500 text-xs">{item.unit}</TableCell>
                      <TableCell className="text-center text-slate-600">{fmt(item.price)}</TableCell>
                      <TableCell className="text-center font-bold">{fmt(item.qty)}</TableCell>
                      <TableCell className="text-center font-bold text-green-700">{fmt(item.total)}</TableCell>
                      <TableCell className="text-center text-red-500">{item.returns > 0 ? fmt(item.returns) : '—'}</TableCell>
                    </TableRow>
                  ))}
                  {dailyData?.expenses?.map((e: any, i: number) => (
                    <TableRow key={`exp-${i}`} className="bg-amber-50">
                      <TableCell className="text-amber-700 font-medium">💸 {e.note}</TableCell>
                      <TableCell colSpan={3}></TableCell>
                      <TableCell className="text-center font-bold text-amber-700">({fmt(e.total)})</TableCell>
                      <TableCell></TableCell>
                    </TableRow>
                  ))}
                  {dailyData?.items?.length > 0 && (() => {
                    const totalIncome = dailyData.items.reduce((s: number, i: any) => s + i.total, 0)
                    const totalReturns = dailyData.items.reduce((s: number, i: any) => s + i.returns, 0)
                    return (
                      <TableRow className="font-black" style={{ background: 'var(--primary)', color: 'white' }}>
                        <TableCell colSpan={4} className="text-white">الإجمالي</TableCell>
                        <TableCell className="text-center text-white">{fmt(totalIncome)}</TableCell>
                        <TableCell className="text-center text-red-300">{totalReturns > 0 ? fmt(totalReturns) : '—'}</TableCell>
                      </TableRow>
                    )
                  })()}
                </TableBody>
              </Table>
            </div>
          </div>
        </div>
      )}

      {/* Periodic table (weekly/monthly/yearly) */}
      {ledgerPeriod !== 'daily' && (
        <div className="card p-0 overflow-hidden">
          <div className="table-wrap">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>{periodLabels[ledgerPeriod]}</TableHead>
                  <TableHead style={{ textAlign: 'center' }}>الدواخل</TableHead>
                  <TableHead style={{ textAlign: 'center' }}>المرتجعات</TableHead>
                  <TableHead style={{ textAlign: 'center' }}>الخوارج</TableHead>
                  <TableHead style={{ textAlign: 'center' }}>إجمالي الإيراد</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {loadingPeriodic && <TableRow><TableCell colSpan={5} className="text-center py-8 text-slate-400">جاري التحميل...</TableCell></TableRow>}
                {!loadingPeriodic && !periodicData?.length && (
                  <TableRow><TableCell colSpan={5} className="text-center py-8 text-slate-400">لا توجد بيانات</TableCell></TableRow>
                )}
                {periodicData?.map((row: any, i: number) => (
                  <TableRow key={i}>
                    <TableCell className="font-bold text-slate-800 font-mono">{row.period}</TableCell>
                    <TableCell className="text-center text-green-700 font-bold">{fmt(row.income)}</TableCell>
                    <TableCell className="text-center text-red-500">{row.returns > 0 ? fmt(row.returns) : '—'}</TableCell>
                    <TableCell className="text-center text-amber-600">{row.expenses > 0 ? fmt(row.expenses) : '—'}</TableCell>
                    <TableCell className={`text-center font-black ${row.net >= 0 ? 'text-green-600' : 'text-red-600'}`}>{fmt(row.net)}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        </div>
      )}
    </div>
  )
}