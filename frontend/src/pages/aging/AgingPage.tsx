import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import api from '../../api/client'
import { PageLoader } from '../../components/ui/Loaders'

const BUCKETS = ['0-30', '30-60', '60-90', '90+']
const BUCKET_LABELS: Record<string, string> = { '0-30': '0-30 يوم', '30-60': '30-60 يوم', '60-90': '60-90 يوم', '90+': '90+ يوم' }
const BUCKET_COLORS: Record<string, string> = { '0-30': '#16a34a', '30-60': '#d97706', '60-90': '#dc2626', '90+': '#7f1d1d' }

function AgingTable({ items, totals }: { items: any[]; totals: any }) {
  const fmt = (n: number) => Number(n || 0).toLocaleString('ar-EG', { minimumFractionDigits: 0, maximumFractionDigits: 2 })
  if (!items?.length) return <div className="text-center py-10 text-slate-400">لا توجد مديونيات</div>
  return (
    <div className="card p-0 overflow-hidden">
      <div className="table-wrap overflow-x-auto">
        <table>
          <thead>
            <tr>
              <th>الاسم</th>
              <th className="text-center" style={{ background: '#f0fdf4' }}>0-30 يوم</th>
              <th className="text-center" style={{ background: '#fffbeb' }}>30-60 يوم</th>
              <th className="text-center" style={{ background: '#fef2f2' }}>60-90 يوم</th>
              <th className="text-center" style={{ background: '#fce7e7' }}>90+ يوم</th>
              <th className="text-center">الإجمالي</th>
            </tr>
          </thead>
          <tbody>
            {items.map((item: any) => (
              <tr key={item.id}>
                <td className="font-semibold text-slate-800">{item.name}</td>
                {BUCKETS.map(b => (
                  <td key={b} className="text-center font-bold" style={{ color: BUCKET_COLORS[b] }}>
                    {item.buckets[b] > 0 ? fmt(item.buckets[b]) : '-'}
                  </td>
                ))}
                <td className="text-center font-black text-slate-800">{fmt(item.total_debt)}</td>
              </tr>
            ))}
          </tbody>
          <tfoot>
            <tr className="bg-slate-50">
              <td className="font-black text-slate-700">الإجمالي</td>
              {BUCKETS.map(b => (
                <td key={b} className="text-center font-black" style={{ color: BUCKET_COLORS[b] }}>
                  {fmt(totals?.[b] || 0)}
                </td>
              ))}
              <td className="text-center font-black text-lg" style={{ color: '#1e3a5f' }}>{fmt(totals?.total || 0)}</td>
            </tr>
          </tfoot>
        </table>
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
          <input type="date" className="input w-40" value={asOf} onChange={e => setAsOf(e.target.value)} />
        </div>
      </div>

      <div className="flex gap-4 mb-5">
        {BUCKETS.map(b => (
          <div key={b} className="flex items-center gap-2 text-sm">
            <div className="w-3 h-3 rounded" style={{ background: BUCKET_COLORS[b] }} />
            <span>{BUCKET_LABELS[b]}</span>
          </div>
        ))}
      </div>

      <div className="flex gap-2 mb-4 border-b border-slate-200">
        {(['customers', 'suppliers'] as const).map(t => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-5 py-2.5 text-sm font-bold border-b-2 -mb-px transition-all ${tab === t ? 'border-blue-600 text-blue-700' : 'border-transparent text-slate-500 hover:text-slate-700'}`}>
            {t === 'customers' ? 'العملاء' : 'الموردون'}
          </button>
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
