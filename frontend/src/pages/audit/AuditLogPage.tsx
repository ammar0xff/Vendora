import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '../../components/ui/table'
import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { auditApi } from '../../api/endpoints'
import { PageLoader } from '../../components/ui/Loaders'
import { format } from 'date-fns'
import { arEG } from 'date-fns/locale'
import { Filter } from 'lucide-react'
import { Select } from '../../components/ui/select'
import { Badge } from '../../components/ui/badge'

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
        <Select className="w-44 text-sm" value={entityFilter} onChange={e => setEntityFilter(e.target.value)}>
          <option value="">كل الأنواع</option>
          {Object.entries(entityLabels).map(([k, v]) => (
            <option key={k} value={k}>{v}</option>
          ))}
        </Select>
        <Select className="w-32 text-sm" value={limit} onChange={e => setLimit(Number(e.target.value))}>
          <option value={50}>50</option>
          <option value={100}>100</option>
          <option value={200}>200</option>
        </Select>
      </div>

      {isLoading ? <PageLoader /> : (
        <div className="card p-0 overflow-hidden">
          <div className="table-wrap">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead style={{width:'100px'}}>الوقت</TableHead>
                  <TableHead style={{width:'80px'}}>النوع</TableHead>
                  <TableHead style={{width:'70px'}}>الإجراء</TableHead>
                  <TableHead>المستخدم</TableHead>
                  <TableHead>التفاصيل</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {!data?.length && (
                  <TableRow><TableCell colSpan={5} className="text-center py-8 text-slate-400">لا توجد أحداث</TableCell></TableRow>
                )}
                {data?.map((entry: any) => (
                  <TableRow key={entry.id}>
                    <TableCell className="text-xs text-slate-400 font-mono whitespace-nowrap">
                      {format(new Date(entry.created_at), 'MMM dd HH:mm', { locale: arEG })}
                    </TableCell>
                    <TableCell><Badge className="bg-blue-50 text-blue-700 border-blue-100 text-xs">{entityLabels[entry.entity_type] || entry.entity_type}</Badge></TableCell>
                    <TableCell><Badge className="bg-slate-100 text-slate-600 border-slate-200 text-xs">{actionLabels[entry.action] || entry.action}</Badge></TableCell>
                    <TableCell className="font-medium text-sm">{entry.user_display || entry.user_name || '—'}</TableCell>
                    <TableCell className="text-xs text-slate-500 max-w-xs truncate" title={entry.note || ''}>
                      {entry.note || (entry.changes ? JSON.stringify(entry.changes).slice(0, 80) : '')}
                    </TableCell>
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
