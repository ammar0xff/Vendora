import { useQuery } from '@tanstack/react-query'
import api from '../../api/client'
import { TrendingUp } from 'lucide-react'

export default function SafesContent() {
  const { data: safes, isLoading } = useQuery({
    queryKey: ['safes'],
    queryFn: () => api.get('/safes').then(r => r.data),
  })

  const { data: history } = useQuery({
    queryKey: ['safe-deposits-all'],
    queryFn: () => api.get('/archive?limit=100').then(r =>
      r.data.filter((d: any) => d.doc_type === 'safe_deposit')
    ),
  })

  const totalBalance = (safes || []).reduce((s: number, safe: any) => s + Number(safe.balance), 0)

  return (
    <div className="space-y-6">
      {/* Summary */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        {isLoading ? (
          Array.from({length:3}).map((_,i) => <div key={i} className="card h-24 animate-pulse bg-slate-50" />)
        ) : safes?.map((safe: any) => (
          <div key={safe.id} className="card p-4">
            <div className="flex items-start justify-between mb-2">
              <div>
                <p className="text-xs font-bold text-slate-400 uppercase tracking-wide mb-1">🏦 {safe.name}</p>
                {safe.location && <p className="text-xs text-slate-400">{safe.location}</p>}
              </div>
              <TrendingUp size={16} className="text-green-500 mt-1" />
            </div>
            <p className="text-2xl font-black" style={{ color: '#1e3a5f' }}>
              {Number(safe.balance).toLocaleString('ar-EG')} ج.م
            </p>
          </div>
        ))}
      </div>

      {/* Total */}
      <div className="card p-4 flex items-center justify-between" style={{ background: '#1e3a5f' }}>
        <span className="text-white/70 font-semibold">إجمالي الخزنات</span>
        <span className="text-white text-2xl font-black">{totalBalance.toLocaleString('ar-EG')} ج.م</span>
      </div>

      {/* Deposit history */}
      <div className="card p-0 overflow-hidden">
        <div className="px-5 py-3 border-b border-slate-100">
          <h3 className="font-bold text-slate-700 text-sm">سجل التوريدات</h3>
        </div>
        <div className="table-wrap max-h-96 overflow-y-auto">
          <table>
            <thead>
              <tr>
                <th>رقم المستند</th>
                <th>الخزنة</th>
                <th>الفرع</th>
                <th>استلم</th>
                <th>التاريخ</th>
                <th style={{textAlign:'left'}}>المبلغ</th>
              </tr>
            </thead>
            <tbody>
              {!history?.length && (
                <tr><td colSpan={6} className="text-center py-8 text-slate-400">لا توجد توريدات</td></tr>
              )}
              {history?.map((d: any) => {
                const meta = d.metadata_ || d.metadata || {}
                return (
                  <tr key={d.id}>
                    <td className="font-mono text-sm font-bold text-slate-700">{d.doc_number}</td>
                    <td className="font-semibold text-slate-700">{meta.safe_name || '—'}</td>
                    <td className="text-slate-500 text-sm">{meta.warehouse || '—'}</td>
                    <td className="text-slate-600 text-sm">{meta.received_by || '—'}</td>
                    <td className="text-slate-400 text-sm">{new Date(d.created_at).toLocaleString('ar-EG', {dateStyle:'short', timeStyle:'short'})}</td>
                    <td className="font-black text-green-700" style={{textAlign:'left'}}>{Number(d.amount).toLocaleString('ar-EG')} ج.م</td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
