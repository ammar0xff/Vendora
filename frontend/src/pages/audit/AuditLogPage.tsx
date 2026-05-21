import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { auditApi } from '../../api/endpoints'
import { PageLoader } from '../../components/ui/Loaders'
import { format } from 'date-fns'
import { arEG } from 'date-fns/locale'
import { Filter } from 'lucide-react'

const entityLabels: Record<string, string> = {
  sale: 'فاتورة', quotation: 'عرض سعر', product: 'منتج',
  stock: 'مخزون', customer_payment: 'دفعة عميل',
  dispatch: 'إذن صرف', goods_receipt: 'استلام بضاعة',
  sale_item: 'صنف فاتورة',
}

const actionLabels: Record<string, string> = {
  create: 'إنشاء', update: 'تعديل', delete: 'حذف',
  return: 'إرجاع', confirm: 'تأكيد', move: 'نقل',
  adjustment: 'تسوية',
}

export default function AuditLogPage() {
  const [entityFilter, setEntityFilter] = useState('')
  const [limit, setLimit] = useState(100)

  const { data, isLoading } = useQuery({
    queryKey: ['audit-log', entityFilter, limit],
    queryFn: () => auditApi.list({ ...(entityFilter ? { entity_type: entityFilter } : {}), limit }),
    refetchInterval: 15_000,
  })

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">📋 سجل التدقيق</h1>
          <p className="text-slate-500 text-sm mt-1">تتبع كل التغييرات في النظام</p>
        </div>
      </div>

      <div className="flex items-center gap-3 mb-5 flex-wrap">
        <Filter size={16} className="text-slate-400" />
        <select className="input w-44 text-sm" value={entityFilter} onChange={e => setEntityFilter(e.target.value)}>
          <option value="">كل الأنواع</option>
          {Object.entries(entityLabels).map(([k, v]) => (
            <option key={k} value={k}>{v}</option>
          ))}
        </select>
        <select className="input w-32 text-sm" value={limit} onChange={e => setLimit(Number(e.target.value))}>
          <option value={50}>50</option>
          <option value={100}>100</option>
          <option value={200}>200</option>
        </select>
      </div>

      {isLoading ? <PageLoader /> : (
        <div className="card p-0 overflow-hidden">
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th style={{width:'100px'}}>الوقت</th>
                  <th style={{width:'80px'}}>النوع</th>
                  <th style={{width:'70px'}}>الإجراء</th>
                  <th>المستخدم</th>
                  <th>التفاصيل</th>
                </tr>
              </thead>
              <tbody>
                {!data?.length && (
                  <tr><td colSpan={5} className="text-center py-8 text-slate-400">لا توجد أحداث</td></tr>
                )}
                {data?.map((entry: any) => (
                  <tr key={entry.id}>
                    <td className="text-xs text-slate-400 font-mono whitespace-nowrap">
                      {format(new Date(entry.created_at), 'MMM dd HH:mm', { locale: arEG })}
                    </td>
                    <td><span className="badge-blue text-xs">{entityLabels[entry.entity_type] || entry.entity_type}</span></td>
                    <td><span className="badge-gray text-xs">{actionLabels[entry.action] || entry.action}</span></td>
                    <td className="font-medium text-sm">{entry.user_display || entry.user_name || '—'}</td>
                    <td className="text-xs text-slate-500 max-w-xs truncate" title={entry.note || ''}>
                      {entry.note || (entry.changes ? JSON.stringify(entry.changes).slice(0, 80) : '')}
                    </td>
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
