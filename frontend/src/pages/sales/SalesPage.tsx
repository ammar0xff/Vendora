import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { salesApi } from '../../api/endpoints'
import api from '../../api/client'
import { PageLoader } from '../../components/ui/Loaders'
import Modal from '../../components/ui/Modal'
import DataTable from '../../components/ui/DataTable'
import toast from 'react-hot-toast'
import { Search, Printer, RotateCcw, XCircle, Minus, Plus, Filter } from 'lucide-react'
import { clsx } from 'clsx'

const STATUS_CONFIG: Record<string, { label: string; bg: string; text: string }> = {
  confirmed: { label: 'مؤكدة',   bg: '#dcfce7', text: '#166534' },
  returned:  { label: 'مرتجعة',  bg: '#fef3c7', text: '#92400e' },
  cancelled: { label: 'ملغاة',   bg: '#fee2e2', text: '#991b1b' },
  quotation: { label: 'عرض سعر', bg: '#ede9fe', text: '#5b21b6' },
  draft:     { label: 'مسودة',   bg: '#f1f5f9', text: '#475569' },
}

function StatusPill({ status }: { status: string }) {
  const cfg = STATUS_CONFIG[status] || { label: status, bg: '#f1f5f9', text: '#475569' }
  return (
    <span className="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold"
      style={{ background: cfg.bg, color: cfg.text }}>
      {cfg.label}
    </span>
  )
}

const getToken = () => JSON.parse(localStorage.getItem('auth') || '{}')?.state?.token || ''
const printUrl = (path: string) => `/api${path}?token=${getToken()}`

export default function SalesPage() {
  const [search, setSearch] = useState('')
  const [statusFilter, setStatusFilter] = useState('')
  const [returnSale, setReturnSale] = useState<any>(null)
  const [returnQtys, setReturnQtys] = useState<Record<string, number>>({})
  const qc = useQueryClient()

  const { data: sales, isLoading } = useQuery({
    queryKey: ['sales', statusFilter],
    queryFn: () => salesApi.list({ limit: 200, ...(statusFilter ? { status: statusFilter } : {}) }),
  })

  const cancelMut = useMutation({
    mutationFn: (id: string) => salesApi.cancel(id),
    onSuccess: () => { toast.success('تم الإلغاء'); qc.invalidateQueries({ queryKey: ['sales'] }) },
  })
  const partialReturnMut = useMutation({
    mutationFn: () => api.post(`/sales/${returnSale.id}/partial-return`, {
      items: Object.entries(returnQtys).filter(([, qty]) => qty > 0).map(([product_id, qty]) => ({ product_id, qty }))
    }).then(r => r.data),
    onSuccess: (data: any) => {
      toast.success(`✅ مرتجع ${data.doc_number}`)
      setReturnSale(null); setReturnQtys({})
      qc.invalidateQueries({ queryKey: ['sales'] })
    },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })

  const handlePrint = (id: string) => {
    window.open(printUrl(`/print/sale/${id}`), '_blank')
  }

  const filtered = sales?.filter((s: any) =>
    s.status !== 'quotation' &&
    (!search || s.invoice_number.toLowerCase().includes(search.toLowerCase()) ||
     (s.customer_name || '').toLowerCase().includes(search.toLowerCase()))
  )


  const columns = [
    {
      key: 'customer', label: 'العميل / الفاتورة',
      render: (s: any) => (
        <div>
          <p className="font-semibold text-slate-800">{s.customer_name || 'عميل عادي'}</p>
          <p className="text-xs text-slate-400 font-mono mt-0.5">{s.invoice_number}</p>
        </div>
      )
    },
    {
      key: 'sale_mode', label: 'النوع', width: '90px',
      render: (s: any) => (
        <span className="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold"
          style={{ background: s.sale_mode === 'wholesale' ? '#dbeafe' : '#f0fdf4', color: s.sale_mode === 'wholesale' ? '#1e40af' : '#166534' }}>
          {s.sale_mode === 'wholesale' ? 'جملة' : 'قطاعي'}
        </span>
      )
    },
    {
      key: 'created_at', label: 'التاريخ والوقت',
      render: (s: any) => (
        <div>
          <p className="text-sm text-slate-700">{new Date(s.created_at).toLocaleDateString('ar-EG')}</p>
          <p className="text-xs text-slate-400">{new Date(s.created_at).toLocaleTimeString('ar-EG', { hour: '2-digit', minute: '2-digit' })}</p>
        </div>
      )
    },
    {
      key: 'status', label: 'الحالة', width: '100px',
      render: (s: any) => <StatusPill status={s.status} />
    },
    {
      key: 'actions', label: '', width: '140px',
      render: (s: any) => (
        <div className="flex gap-1 justify-end">
          <button onClick={e => { e.stopPropagation(); handlePrint(s.id) }}
            title="طباعة"
            className="p-1.5 rounded-lg hover:bg-blue-50 text-slate-400 hover:text-blue-600 transition-colors">
            <Printer size={14} />
          </button>
          {s.status === 'confirmed' && (
            <>
              <button onClick={e => { e.stopPropagation(); setReturnSale(s); const init: Record<string,number> = {}; s.items?.forEach((i: any) => { init[i.product_id] = 0 }); setReturnQtys(init) }}
                title="مرتجع"
                className="p-1.5 rounded-lg hover:bg-amber-50 text-slate-400 hover:text-amber-600 transition-colors">
                <RotateCcw size={14} />
              </button>
              <button onClick={e => { e.stopPropagation(); if (confirm('إلغاء الفاتورة؟')) cancelMut.mutate(s.id) }}
                title="إلغاء"
                className="p-1.5 rounded-lg hover:bg-red-50 text-slate-400 hover:text-red-500 transition-colors">
                <XCircle size={14} />
              </button>
            </>
          )}
        </div>
      )
    },
  ]

  const statusCounts = sales?.reduce((acc: any, s: any) => {
    if (s.status !== 'quotation') acc[s.status] = (acc[s.status] || 0) + 1
    return acc
  }, {}) || {}

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">سجل المبيعات</h1>
        <div className="text-sm text-slate-500">
          {sales?.filter((s: any) => s.status !== 'quotation').length || 0} فاتورة
        </div>
      </div>

      {/* Status filter pills */}
      <div className="flex gap-2 mb-4 flex-wrap">
        <button onClick={() => setStatusFilter('')}
          className={clsx('px-3 py-1.5 rounded-xl text-xs font-bold transition-all border', !statusFilter ? 'text-white border-transparent' : 'bg-white text-slate-600 border-slate-200 hover:border-slate-300')}
          style={!statusFilter ? { background: '#1e3a5f' } : {}}>
          الكل ({sales?.filter((s: any) => s.status !== 'quotation').length || 0})
        </button>
        {Object.entries(STATUS_CONFIG).filter(([k]) => k !== 'quotation' && k !== 'draft').map(([status, cfg]) => {
          const count = statusCounts[status] || 0
          if (!count) return null
          return (
            <button key={status} onClick={() => setStatusFilter(statusFilter === status ? '' : status)}
              className={clsx('px-3 py-1.5 rounded-xl text-xs font-bold transition-all border')}
              style={statusFilter === status ? { background: cfg.bg, color: cfg.text, borderColor: cfg.text + '40' } : { background: 'white', color: '#64748b', borderColor: '#e2e8f0' }}>
              {cfg.label} ({count})
            </button>
          )
        })}
      </div>

      {/* Search */}
      <div className="relative mb-4">
        <Search size={16} className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400" />
        <input className="input pr-9" placeholder="بحث بالاسم أو رقم الفاتورة..." value={search} onChange={e => setSearch(e.target.value)} />
      </div>

      <div className="card p-0 overflow-hidden">
        <DataTable
          columns={columns}
          data={filtered}
          loading={isLoading}
          rowKey={(s: any) => s.id}
          emptyMessage="لا توجد مبيعات"
          emptyIcon="🧾"
          maxHeight="calc(100vh - 280px)"
        />
      </div>

      {/* Partial Return Modal */}
      <Modal open={!!returnSale} onClose={() => setReturnSale(null)} title={`مرتجع من ${returnSale?.invoice_number}`} size="lg">
        {returnSale && (
          <div className="space-y-4">
            <p className="text-sm text-slate-500">اختر الأصناف والكميات المراد إرجاعها</p>
            <div className="space-y-2 max-h-64 overflow-y-auto">
              {returnSale.items?.map((item: any) => (
                <div key={item.product_id} className="flex items-center justify-between p-3 rounded-xl bg-slate-50 border border-slate-100">
                  <div className="flex-1">
                    <p className="font-semibold text-sm">{item.product_name || item.product_id.slice(0, 8)}</p>
                    <p className="text-xs text-slate-400">الكمية الأصلية: {item.qty} — {Number(item.unit_price).toLocaleString('ar-EG')} ج.م</p>
                  </div>
                  <div className="flex items-center gap-1.5">
                    <button onClick={() => setReturnQtys(q => ({ ...q, [item.product_id]: Math.max(0, (q[item.product_id] || 0) - 1) }))}
                      className="w-7 h-7 rounded-lg bg-slate-200 hover:bg-slate-300 flex items-center justify-center"><Minus size={12} /></button>
                    <input type="number" min="0" max={item.qty} value={returnQtys[item.product_id] || 0}
                      onChange={e => setReturnQtys(q => ({ ...q, [item.product_id]: Math.min(Number(e.target.value), item.qty) }))}
                      className="w-14 text-center text-sm font-bold border border-slate-200 rounded-lg py-1 outline-none focus:border-blue-300" />
                    <button onClick={() => setReturnQtys(q => ({ ...q, [item.product_id]: Math.min((q[item.product_id] || 0) + 1, item.qty) }))}
                      className="w-7 h-7 rounded-lg bg-slate-200 hover:bg-slate-300 flex items-center justify-center"><Plus size={12} /></button>
                  </div>
                </div>
              ))}
            </div>
            <div className="bg-amber-50 border border-amber-200 rounded-xl p-3 text-sm text-amber-700">
              إجمالي المرتجع: <span className="font-black">
                {returnSale.items?.reduce((s: number, i: any) => s + (returnQtys[i.product_id] || 0) * Number(i.unit_price), 0).toLocaleString('ar-EG')} ج.م
              </span>
            </div>
            <div className="flex gap-3 justify-end">
              <button onClick={() => setReturnSale(null)} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
              <button onClick={() => partialReturnMut.mutate()}
                disabled={Object.values(returnQtys).every(v => v === 0) || partialReturnMut.isPending}
                className="px-5 py-2 rounded-xl text-sm font-bold text-white bg-amber-500 hover:bg-amber-600 disabled:opacity-50 flex items-center gap-2">
                <RotateCcw size={14} /> تأكيد المرتجع
              </button>
            </div>
          </div>
        )}
      </Modal>
    </div>
  )
}
