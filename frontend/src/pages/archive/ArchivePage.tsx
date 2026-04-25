import { useState, useMemo } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { archiveApi } from '../../api/endpoints'
import DataTable from '../../components/ui/DataTable'
import toast from 'react-hot-toast'
import { Search, Trash2, Printer, FileText, Truck, Package, Handshake, BarChart2, Receipt, ShoppingBag, Wallet } from 'lucide-react'

const getToken = () => JSON.parse(localStorage.getItem('auth') || '{}')?.state?.token || ''
const pdfUrl = (path: string) => `/api${path}?token=${getToken()}`

const DOC_CONFIG: Record<string, { label: string; icon: any; color: string; pdfPath?: (d: any) => string }> = {
  sale_invoice:    { label: 'فاتورة مبيعات',   icon: Receipt,    color: '#16a34a', pdfPath: d => pdfUrl(`/print/pdf/sale/${d.ref_id}`) },
  quotation:       { label: 'عرض سعر',          icon: FileText,   color: '#c8a84b', pdfPath: d => pdfUrl(`/print/pdf/sale/${d.ref_id}`) },
  purchase_invoice:{ label: 'فاتورة مشتريات',  icon: ShoppingBag,color: '#7c3aed', pdfPath: d => pdfUrl(`/print/pdf/purchase/${d.ref_id}`) },
  dispatch_order:  { label: 'إذن صرف',          icon: Truck,      color: '#1e3a5f', pdfPath: d => pdfUrl(`/print/pdf/dispatch/${d.doc_number}`) },
  goods_receipt:   { label: 'استلام مشتريات',  icon: Package,    color: '#0891b2', pdfPath: d => pdfUrl(`/print/pdf/archive/${d.id}`) },
  stock_request:   { label: 'استلام مشتريات',  icon: Package,    color: '#0891b2', pdfPath: d => pdfUrl(`/print/pdf/archive/${d.id}`) },
  shift_report:    { label: 'تقرير وردية',      icon: BarChart2,  color: '#0891b2', pdfPath: d => pdfUrl(`/print/pdf/archive/${d.id}`) },
  shift_handover:  { label: 'تسليم عهدة',       icon: Handshake,  color: '#dc2626', pdfPath: d => pdfUrl(`/print/pdf/handover/${d.doc_number}`) },
  inventory_report:{ label: 'تقرير مخزون',      icon: BarChart2,  color: '#059669', pdfPath: d => pdfUrl(`/print/pdf/archive/${d.id}`) },
  safe_deposit:    { label: 'توريد خزنة',       icon: Wallet,     color: '#0891b2', pdfPath: d => pdfUrl(`/print/pdf/archive/${d.id}`) },
}

const TYPE_FILTERS = [
  { key: '', label: 'الكل' },
  { key: 'sale_invoice',    label: 'فواتير مبيعات' },
  { key: 'quotation',       label: 'عروض أسعار' },
  { key: 'purchase_invoice',label: 'فواتير مشتريات' },
  { key: 'dispatch_order',  label: 'إذونات صرف' },
  { key: 'goods_receipt',   label: 'استلام مشتريات' },
  { key: 'shift_handover',  label: 'تسليم عهدة' },
  { key: 'safe_deposit',    label: 'توريد خزنة' },
]

export default function ArchivePage() {
  const [search, setSearch] = useState('')
  const [fromDate, setFromDate] = useState('')
  const [toDate, setToDate] = useState('')
  const [docType, setDocType] = useState('')
  const qc = useQueryClient()

  const { data: docs, isLoading } = useQuery({
    queryKey: ['archive'],
    queryFn: () => archiveApi.list({ limit: 1000 }),
    staleTime: 30_000,
  })

  const deleteMut = useMutation({
    mutationFn: archiveApi.delete,
    onSuccess: () => { toast.success('تم الحذف'); qc.invalidateQueries({ queryKey: ['archive'] }) },
    onError: () => toast.error('فشل الحذف'),
  })

  const counts = useMemo(() =>
    (docs || []).reduce((acc: any, d: any) => { acc[d.doc_type] = (acc[d.doc_type] || 0) + 1; return acc }, {}),
    [docs])

  const filtered = useMemo(() =>
    (docs || []).filter((d: any) => {
      if (docType && d.doc_type !== docType) return false
      if (search && !d.doc_number.includes(search) && !(d.customer_name || '').includes(search)) return false
      if (fromDate && d.created_at < fromDate) return false
      if (toDate && d.created_at > toDate + 'T23:59:59') return false
      return true
    }),
    [docs, docType, search, fromDate, toDate])

  const columns = [
    {
      key: 'doc', label: 'المستند', render: (d: any) => {
        const cfg = DOC_CONFIG[d.doc_type]
        const Icon = cfg?.icon || FileText
        const meta = d.metadata_ || d.metadata || {}
        let summary = ''
        let sub = ''

        if (d.doc_type === 'sale_invoice' || d.doc_type === 'quotation') {
          summary = d.customer_name || 'عميل نقدي'
          if (d.amount) sub = `${Number(d.amount).toLocaleString('ar-EG')} ج.م`
          if (meta.items?.length) sub += `  ·  ${meta.items.length} صنف`
        } else if (d.doc_type === 'safe_deposit') {
          summary = meta.safe_name || 'خزنة'
          if (d.amount) sub = `${Number(d.amount).toLocaleString('ar-EG')} ج.م`
          if (meta.received_by) sub += `  ·  استلم: ${meta.received_by}`
        } else if (d.doc_type === 'purchase_invoice') {
          summary = meta.supplier || 'مورد غير محدد'
          if (d.amount) sub = `${Number(d.amount).toLocaleString('ar-EG')} ج.م`
          if (meta.items_count) sub += `  ·  ${meta.items_count} صنف`
        } else if (d.doc_type === 'dispatch_order') {
          summary = `${meta.from_warehouse || meta.from || '—'} ← ${meta.to_warehouse || meta.to || '—'}`
          if (meta.items?.length) sub = `${meta.items.length} صنف`
        } else if (d.doc_type === 'shift_handover') {
          summary = `${meta.from_user_name || meta.from_user || '—'} → ${meta.to_user_name || meta.to_user || '—'}`
          if (d.amount) sub = `${Number(d.amount).toLocaleString('ar-EG')} ج.م`
        } else if (d.doc_type === 'goods_receipt' || d.doc_type === 'stock_request') {
          summary = meta.supplier || meta.from || 'استلام مشتريات'
          if (meta.items?.length) sub = `${meta.items.length} صنف`
        } else {
          summary = d.customer_name || meta.warehouse || ''
        }

        return (
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0"
              style={{ background: (cfg?.color || '#64748b') + '15' }}>
              <Icon size={16} style={{ color: cfg?.color || '#64748b' }} />
            </div>
            <div className="min-w-0">
              <div className="flex items-center gap-2 flex-wrap">
                <span className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-bold"
                  style={{ background: (cfg?.color || '#64748b') + '15', color: cfg?.color || '#64748b' }}>
                  {cfg?.label || d.doc_type}
                </span>
                <p className="font-mono text-xs text-slate-400">{d.doc_number}</p>
              </div>
              {summary && <p className="font-semibold text-slate-800 text-sm truncate mt-0.5">{summary}</p>}
              {sub && <p className="text-xs text-slate-400">{sub}</p>}
            </div>
          </div>
        )
      }
    },
    {
      key: 'created_at', label: 'التاريخ', width: '110px', sortable: true, render: (d: any) => (
        <div>
          <p className="text-sm text-slate-600">{new Date(d.created_at).toLocaleDateString('ar-EG')}</p>
          <p className="text-xs text-slate-400">{new Date(d.created_at).toLocaleTimeString('ar-EG', { hour: '2-digit', minute: '2-digit' })}</p>
          {d.created_by_name && <p className="text-xs text-slate-400 mt-0.5">👤 {d.created_by_name}</p>}
        </div>
      )
    },
    {
      key: 'actions', label: '', width: '70px', render: (d: any) => {
        const cfg = DOC_CONFIG[d.doc_type]
        return (
          <div className="flex gap-1 justify-end">
            {cfg?.pdfPath && (
              <button onClick={e => { e.stopPropagation(); window.open(cfg.pdfPath!(d), '_blank') }}
                className="p-1.5 rounded-lg hover:bg-blue-50 text-slate-300 hover:text-blue-600" title="طباعة / PDF">
                <Printer size={14} />
              </button>
            )}
            <button onClick={e => { e.stopPropagation(); if (confirm('حذف المستند؟')) deleteMut.mutate(d.id) }}
              className="p-1.5 rounded-lg hover:bg-red-50 text-slate-300 hover:text-red-500" title="حذف">
              <Trash2 size={14} />
            </button>
          </div>
        )
      }
    },
  ]

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">📁 الأرشيف</h1>
          <p className="text-slate-500 text-sm mt-1">{filtered.length} من {docs?.length || 0} مستند</p>
        </div>
      </div>

      {/* Type filter pills */}
      <div className="flex gap-2 mb-4 overflow-x-auto pb-1" style={{ WebkitOverflowScrolling: 'touch' }}>
        {TYPE_FILTERS.map(({ key, label }) => {
          const count = key ? (counts[key] || 0) : (docs?.length || 0)
          if (key && !count) return null
          const cfg = key ? DOC_CONFIG[key] : null
          const isActive = docType === key
          return (
            <button key={key} onClick={() => setDocType(key)}
              className="flex items-center gap-1.5 px-3.5 py-2 rounded-xl text-xs font-bold flex-shrink-0 transition-all border"
              style={isActive
                ? { background: cfg?.color || '#1e3a5f', color: 'white', borderColor: 'transparent' }
                : { background: 'white', color: '#64748b', borderColor: '#e2e8f0' }}>
              {label}
              <span className={`px-1.5 py-0.5 rounded-full text-xs ${isActive ? 'bg-white/25 text-white' : 'bg-slate-100 text-slate-500'}`}>{count}</span>
            </button>
          )
        })}
      </div>

      {/* Filters */}
      <div className="flex gap-3 mb-4 flex-wrap items-center">
        <div className="relative">
          <Search size={15} className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input className="input pr-9 text-sm w-56" placeholder="بحث برقم المستند أو العميل..." value={search} onChange={e => setSearch(e.target.value)} />
        </div>
        <input type="date" className="input text-sm w-40" value={fromDate} onChange={e => setFromDate(e.target.value)} />
        <input type="date" className="input text-sm w-40" value={toDate} onChange={e => setToDate(e.target.value)} />
        {(fromDate || toDate || search) && (
          <button onClick={() => { setSearch(''); setFromDate(''); setToDate('') }}
            className="text-xs text-slate-400 hover:text-red-500 px-2 py-1 rounded-lg hover:bg-red-50">✕ مسح</button>
        )}
      </div>

      <div className="card p-0 overflow-hidden">
        <DataTable columns={columns} data={filtered} loading={isLoading}
          rowKey={(d: any) => d.id} emptyMessage="لا توجد مستندات" emptyIcon="📁"
          maxHeight="calc(100vh - 280px)" />
      </div>
    </div>
  )
}
