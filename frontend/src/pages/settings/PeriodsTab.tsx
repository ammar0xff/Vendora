import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import api from '../../api/client'
import toast from 'react-hot-toast'
import { Lock, Unlock, Calendar } from 'lucide-react'

export default function PeriodsTab() {
  const qc = useQueryClient()
  const { data: periods, isLoading } = useQuery({
    queryKey: ['periods'],
    queryFn: () => api.get('/periods').then(r => r.data),
  })

  const closeMut = useMutation({
    mutationFn: (month: string) => api.post(`/periods/${month}/close`),
    onSuccess: () => { toast.success('تم إغلاق الشهر'); qc.invalidateQueries({ queryKey: ['periods'] }) },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل الإغلاق'),
  })

  const reopenMut = useMutation({
    mutationFn: (month: string) => api.post(`/periods/${month}/reopen`),
    onSuccess: () => { toast.success('تم فتح الشهر'); qc.invalidateQueries({ queryKey: ['periods'] }) },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل الفتح'),
  })

  const now = new Date()
  const months: string[] = []
  for (let i = 0; i < 12; i++) {
    const d = new Date(now.getFullYear(), now.getMonth() - i, 1)
    months.push(d.toISOString().slice(0, 7))
  }

  const periodMap = new Map(periods?.map((p: any) => [p.month, p]))

  return (
    <div className="space-y-4">
      <p className="text-sm text-slate-500">إدارة إغلاق الشهور — منع إضافة أو تعديل المعاملات في الشهور المغلقة</p>
      <div className="space-y-1">
        {months.map(m => {
          const p = periodMap.get(m)
          const isClosed = p?.status === 'closed'
          const isCurrent = m === now.toISOString().slice(0, 7)
          const isFuture = m > now.toISOString().slice(0, 7)
          const arabicMonth = new Date(m + '-01').toLocaleDateString('ar-EG', { month: 'long', year: 'numeric' })
          return (
            <div key={m} className={`flex items-center justify-between p-3 rounded-xl border transition-colors ${
              isClosed ? 'bg-red-50 border-red-200' : 'bg-white border-slate-100'
            }`}>
              <div className="flex items-center gap-3">
                <Calendar size={16} className={isClosed ? 'text-red-400' : 'text-slate-400'} />
                <span className={`font-semibold ${isClosed ? 'text-red-700' : 'text-slate-700'}`}>
                  {arabicMonth}
                  {isCurrent && <span className="text-xs text-blue-500 mr-2">(الحالي)</span>}
                  {isFuture && <span className="text-xs text-slate-400 mr-2">(مستقبلي)</span>}
                </span>
                {isClosed && (
                  <span className="text-xs px-2 py-0.5 rounded-full bg-red-100 text-red-600 font-bold whitespace-nowrap">
                    مغلق
                  </span>
                )}
              </div>
              <div>
                {isClosed ? (
                  <button onClick={() => reopenMut.mutate(m)} disabled={reopenMut.isPending}
                    className="px-3 py-1.5 rounded-lg text-xs font-bold bg-amber-100 text-amber-700 hover:bg-amber-200 disabled:opacity-50 transition-colors flex items-center gap-1.5">
                    <Unlock size={12} /> إعادة فتح
                  </button>
                ) : (
                  <button onClick={() => closeMut.mutate(m)} disabled={closeMut.isPending || isCurrent || isFuture}
                    className="px-3 py-1.5 rounded-lg text-xs font-bold bg-red-100 text-red-600 hover:bg-red-200 disabled:opacity-40 disabled:cursor-not-allowed transition-colors flex items-center gap-1.5"
                    title={isCurrent ? 'لا يمكن إغلاق الشهر الحالي' : isFuture ? 'لا يمكن إغلاق شهر مستقبلي' : ''}>
                    <Lock size={12} /> إغلاق
                  </button>
                )}
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}
