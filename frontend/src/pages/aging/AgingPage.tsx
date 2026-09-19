import { Table, TableHeader, TableBody, TableFooter, TableRow, TableHead, TableCell } from '../../components/ui/table'
import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import api from '../../api/client'
import { PageLoader } from '../../components/ui/Loaders'
import { Input } from '../../components/ui/input'
import { Button } from '../../components/ui/button'

const BUCKETS = ['0-30', '30-60', '60-90', '90+']
const BUCKET_LABELS: Record<string, string> = { '0-30': '0-30 يوم', '30-60': '30-60 يوم', '60-90': '60-90 يوم', '90+': '90+ يوم' }
const BUCKET_COLORS: Record<string, string> = { '0-30': 'text-green-600', '30-60': 'text-amber-600', '60-90': 'text-red-600', '90+': 'text-red-900' }
const BUCKET_BG_COLORS: Record<string, string> = { '0-30': 'bg-green-600', '30-60': 'bg-amber-600', '60-90': 'bg-red-600', '90+': 'bg-red-900' }

function AgingTable({ items, totals }: { items: any[]; totals: any }) {
  const fmt = (n: number) => Number(n || 0).toLocaleString('ar-EG', { minimumFractionDigits: 0, maximumFractionDigits: 2 })
  if (!items?.length) return <div className="text-center py-10 text-slate-400">لا توجد مديونيات</div>
  return (
    <div className="card p-0 overflow-hidden">
      <div className="table-wrap overflow-x-auto">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>الاسم</TableHead>
              <TableHead className="text-center" style={{ background: '#f0fdf4' }}>0-30 يوم</TableHead>
              <TableHead className="text-center" style={{ background: '#fffbeb' }}>30-60 يوم</TableHead>
              <TableHead className="text-center" style={{ background: '#fef2f2' }}>60-90 يوم</TableHead>
              <TableHead className="text-center" style={{ background: '#fce7e7' }}>90+ يوم</TableHead>
              <TableHead className="text-center">الإجمالي</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {items.map((item: any) => (
              <TableRow key={item.id}>
                <TableCell className="font-semibold text-slate-800">{item.name}</TableCell>
                {BUCKETS.map(b => (
                  <TableCell key={b} className={`text-center font-bold ${BUCKET_COLORS[b] || 'text-slate-500'}`}>
                    {item.buckets[b] > 0 ? fmt(item.buckets[b]) : '-'}
                  </TableCell>
                ))}
                <TableCell className="text-center font-black text-slate-800">{fmt(item.total_debt)}</TableCell>
              </TableRow>
            ))}
          </TableBody>
          <TableFooter>
            <TableRow className="bg-slate-50">
              <TableCell className="font-black text-slate-700">الإجمالي</TableCell>
              {BUCKETS.map(b => (
                <TableCell key={b} className={`text-center font-black ${BUCKET_COLORS[b] || 'text-slate-500'}`}>
                  {fmt(totals?.[b] || 0)}
                </TableCell>
              ))}
              <TableCell className="text-center font-black text-lg" style={{ color: 'var(--primary)' }}>{fmt(totals?.total || 0)}</TableCell>
            </TableRow>
          </TableFooter>
        </Table>
      </div>
    </div>
  )
}

export default function AgingPage() {
  const today = new Date().toISOString().slice(0, 10)
  const [asOf, setAsOf] = useState(today)
  const [tab, setTab] = useState<'customers' | 'suppliers'>('customers')

  const { data, isLoading } = useQuery({
    queryKey: ['aging', asOf],
    queryFn: () => api.get('/reports/aging', { params: { as_of: asOf } }).then(r => r.data),
  })

  return (
    <div>
      <div className="flex items-center justify-between mb-5">
        <h1 className="page-title">تقرير أعمار الديون</h1>
        <div className="flex items-center gap-2">
          <label className="text-xs text-slate-500">تاريخ الأساس</label>
          <Input type="date" className="w-40" value={asOf} onChange={e => setAsOf(e.target.value)} />
        </div>
      </div>

      <div className="flex gap-4 mb-5">
        {BUCKETS.map(b => (
          <div key={b} className="flex items-center gap-2 text-sm">
            <div className={`w-3 h-3 rounded ${BUCKET_BG_COLORS[b] || 'bg-slate-400'}`} />
            <span>{BUCKET_LABELS[b]}</span>
          </div>
        ))}
      </div>

      <div className="flex gap-2 mb-4 border-b border-slate-200">
        {(['customers', 'suppliers'] as const).map(t => (
          <Button key={t} variant="ghost" onClick={() => setTab(t)}
            className={`px-5 text-sm font-bold border-b-2 -mb-px transition-all hover:bg-transparent ${tab === t ? 'border-blue-600 text-blue-700' : 'border-transparent text-slate-500 hover:text-slate-700'}`}>
            {t === 'customers' ? 'العملاء' : 'الموردون'}
          </Button>
        ))}
      </div>

      {isLoading ? <PageLoader text="جاري تحميل تقرير الأعمار..." /> : !data ? null : tab === 'customers' ? (
        <AgingTable items={data?.customers?.items} totals={data?.customers?.totals} />
      ) : (
        <AgingTable items={data?.suppliers?.items} totals={data?.suppliers?.totals} />
      )}
    </div>
  )
}
