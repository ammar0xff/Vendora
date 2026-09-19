import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { salesApi } from '../../api/endpoints'
import { customersApi } from '../../api/endpoints'
import api from '../../api/client'
import Modal from '../../components/ui/Modal'
import DataTable from '../../components/ui/DataTable'
import ConfirmDialog from '../../components/ui/ConfirmDialog'
import toast from 'react-hot-toast'
import { Search, Printer, RotateCcw, XCircle, Minus, Plus, FileDown, DollarSign } from 'lucide-react'
import ExportButton from '../../components/ui/ExportButton'
import { Button } from '../../components/ui/button'
import { printUrl, openPrint } from '../../utils/format'
import { clsx } from 'clsx'
import { Input } from '../../components/ui/input'
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '../../components/ui/table'

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

export default function SalesPage() {
  const [search, setSearch] = useState('')
  const [statusFilter, setStatusFilter] = useState('')
  const [returnSale, setReturnSale] = useState<any>(null)
  const [confirmCancel, setConfirmCancel] = useState<any>(null)
  const [returnQtys, setReturnQtys] = useState<Record<string, number>>({})
  // Sale detail modal
  const [selectedSaleId, setSelectedSaleId] = useState<string | null>(null)
  const [salePayAmount, setSalePayAmount] = useState('')
  const [salePayNote, setSalePayNote] = useState('')
  const qc = useQueryClient()

  const { data: sales, isLoading } = useQuery({
    queryKey: ['sales', statusFilter],
    queryFn: () => salesApi.list({ limit: 200, ...(statusFilter ? { status: statusFilter } : {}) }),
  })

  const { data: saleDetail, refetch: refetchDetail } = useQuery({
    queryKey: ['sale-detail', selectedSaleId],
    queryFn: () => salesApi.get(selectedSaleId!),
    enabled: !!selectedSaleId,
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
      openPrint(`/print/pdf/sale/${data.sale_id}`)
    },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })

  const paySaleMut = useMutation({
    mutationFn: () => {
      const sale = saleDetail
      if (!sale?.customer_id) throw new Error('لا يوجد عميل')
      return customersApi.addPayment(sale.customer_id, Number(salePayAmount), salePayNote, sale.id)
    },
    onSuccess: () => {
      toast.success('✅ تم تسجيل الدفعة')
      setSalePayAmount(''); setSalePayNote('')
      refetchDetail()
      qc.invalidateQueries({ queryKey: ['sales'] })
    },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل في تسجيل الدفعة'),
  })

  const handlePrint = (id: string) => {
    openPrint(`/print/pdf/sale/${id}`)
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
          <p className="font-semibold text-[var(--text)]">{s.customer_name || 'عميل عادي'}</p>
          <p className="text-xs text-[var(--muted)] font-mono mt-0.5">{s.invoice_number}</p>
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
          <p className="text-sm text-[var(--text)]">{new Date(s.created_at).toLocaleDateString('ar-EG')}</p>
          <p className="text-xs text-[var(--muted)]">{new Date(s.created_at).toLocaleTimeString('ar-EG', { hour: '2-digit', minute: '2-digit' })}</p>
        </div>
      )
    },
    {
      key: 'net_total', label: 'الإجمالي', width: '100px',
      render: (s: any) => (
        <span className="font-bold text-[var(--text)]">{Number(s.net_total).toLocaleString('ar-EG')}</span>
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
          <Button variant="ghost" size="icon-sm" onClick={e => { e.stopPropagation(); handlePrint(s.id) }} title="طباعة"><Printer size={14} /></Button>
          <a href={printUrl(`/print/pdf/sale/${s.id}`, 'A4')} target="_blank" rel="noreferrer"
            onClick={e => e.stopPropagation()}
            title="تحميل PDF"
            className="p-1.5 rounded-lg hover:bg-red-50 text-[var(--muted)] hover:text-red-600 transition-colors flex items-center">
            <FileDown size={14} />
          </a>
          {s.status === 'confirmed' && (
            <>
              <Button variant="ghost" size="icon-sm" onClick={e => { e.stopPropagation(); setReturnSale(s); const init: Record<string,number> = {}; s.items?.forEach((i: any) => { init[i.product_id] = 0 }); setReturnQtys(init) }} title="مرتجع"><RotateCcw size={14} /></Button>
              <Button variant="ghost" size="icon-sm" onClick={e => { e.stopPropagation(); setConfirmCancel(s.id) }} title="إلغاء"><XCircle size={14} /></Button>
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
        <h1 className="page-title">سجل المبيعات والمرتجعات</h1>
        <div className="flex items-center gap-3">
          <div className="text-sm text-[var(--muted)]">
            {sales?.filter((s: any) => s.status !== 'quotation').length || 0} فاتورة
          </div>
          <ExportButton data={filtered || []} columns={[
            { label: 'رقم الفاتورة', accessor: (s: any) => s.invoice_number },
            { label: 'العميل', accessor: (s: any) => s.customer_name || 'عميل عادي' },
            { label: 'الإجمالي', accessor: (s: any) => Number(s.total) },
            { label: 'طريقة الدفع', accessor: (s: any) => s.payment_method },
            { label: 'التاريخ', accessor: (s: any) => new Date(s.created_at).toLocaleDateString('en-CA') },
            { label: 'المستخدم', accessor: (s: any) => s.created_by_name || '' },
          ]} filename="المبيعات" excelEndpoint="/export/sales" />
        </div>
      </div>

      {/* Status filter pills */}
      <div className="flex gap-2 mb-4 flex-wrap">
        <Button variant="outline" size="sm" onClick={() => setStatusFilter('')}
          className={clsx('rounded-xl text-xs font-bold transition-all', !statusFilter ? 'text-white border-transparent bg-[var(--primary)] hover:bg-[var(--primary)]' : 'bg-[var(--surface)] text-[var(--text-soft)] border-[var(--border)] hover:border-[var(--border-strong)]')}>
          الكل ({sales?.filter((s: any) => s.status !== 'quotation').length || 0})
        </Button>
        {Object.entries(STATUS_CONFIG).filter(([k]) => k !== 'quotation' && k !== 'draft').map(([status, cfg]) => {
          const count = statusCounts[status] || 0
          if (!count) return null
          return (
            <Button key={status} variant="outline" size="sm" onClick={() => setStatusFilter(statusFilter === status ? '' : status)}
              className={clsx('rounded-xl text-xs font-bold transition-all')}
              style={statusFilter === status ? { background: cfg.bg, color: cfg.text, borderColor: cfg.text + '40' } : { background: 'white', color: '#64748b', borderColor: '#e2e8f0' }}>
              {cfg.label} ({count})
            </Button>
          )
        })}
      </div>

      {/* Search */}
      <div className="relative mb-4">
        <Search size={16} className="absolute right-3 top-1/2 -translate-y-1/2 text-[var(--muted)]" />
 <Input className="pr-9" placeholder="بحث بالاسم أو رقم الفاتورة..." value={search} onChange={e => setSearch(e.target.value)}/>
      </div>

      <div className="card p-0 overflow-hidden">
        <DataTable
          columns={columns}
          data={filtered}
          loading={isLoading}
          rowKey={(s: any) => s.id}
          onRowClick={(s: any) => setSelectedSaleId(s.id)}
          emptyMessage="لا توجد مبيعات"
          emptyIcon="🧾"
          maxHeight="calc(100vh - 280px)"
        />
      </div>

      {/* Sale Detail Modal */}
      <Modal open={!!selectedSaleId} onClose={() => { setSelectedSaleId(null); setSalePayAmount(''); setSalePayNote('') }}
        title={saleDetail ? `فاتورة ${saleDetail.invoice_number}` : 'جاري التحميل...'} size="xl">
        {saleDetail && (
          <div className="space-y-5">
            {/* Invoice header */}
            <div className="flex items-start justify-between">
              <div>
                <p className="text-sm text-[var(--muted)]">العميل: <span className="font-bold text-[var(--text)]">{saleDetail.customer_name || 'عميل عادي'}</span></p>
                <p className="text-xs text-[var(--muted)] mt-0.5">
                  {new Date(saleDetail.created_at).toLocaleString('ar-EG')}
                </p>
              </div>
              <StatusPill status={saleDetail.status} />
            </div>

            {/* Items table */}
            <div>
              <p className="text-xs font-bold text-[var(--muted)] mb-2">الأصناف</p>
              <div className="bg-[var(--surface-2)] rounded-xl overflow-hidden border border-[var(--border-faint)]">
                <Table className="w-full text-sm">
                  <TableHeader>
                    <TableRow className="bg-[var(--surface-3)]">
                      <TableHead className="text-right px-3 py-2 text-[var(--muted)]">الصنف</TableHead>
                      <TableHead className="text-right px-3 py-2 text-[var(--muted)]">الكمية</TableHead>
                      <TableHead className="text-right px-3 py-2 text-[var(--muted)]">السعر</TableHead>
                      <TableHead className="text-right px-3 py-2 text-[var(--muted)]">الإجمالي</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {(saleDetail.items || []).map((item: any) => (
                      <TableRow key={item.id} className="border-t border-[var(--border-faint)]">
                        <TableCell className="px-3 py-2 font-semibold text-[var(--text)]">{item.product_name || item.product_id?.slice(0, 8)}</TableCell>
                        <TableCell className="px-3 py-2 text-[var(--text-soft)]">{Number(item.qty).toLocaleString('ar-EG')}</TableCell>
                        <TableCell className="px-3 py-2 text-[var(--text-soft)]">{Number(item.unit_price).toLocaleString('ar-EG')}</TableCell>
                        <TableCell className="px-3 py-2 font-bold text-[var(--text)]">{(Number(item.qty) * Number(item.unit_price)).toLocaleString('ar-EG')}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </div>
            </div>

            {/* Financial summary */}
            <div className="grid grid-cols-4 gap-3">
              {[
                { label: 'الإجمالي', val: Number(saleDetail.net_total).toLocaleString('ar-EG'), color: 'var(--primary)' },
                { label: 'المدفوع', val: Number(saleDetail.paid_amount || 0).toLocaleString('ar-EG'), color: '#16a34a' },
                { label: 'المرتجعات', val: Number(saleDetail.returns_total || 0).toLocaleString('ar-EG'), color: '#dc2626' },
                { label: 'المتبقي', val: Number(saleDetail.remaining || 0).toLocaleString('ar-EG'), color: '#d97706' },
              ].map(({ label, val, color }) => (
                <div key={label} className="bg-[var(--surface-2)] rounded-xl p-3 text-center border border-[var(--border-faint)]">
                  <p className="text-xs text-[var(--muted)] mb-1">{label}</p>
                  <p className="text-lg font-black" style={{ color }}>{val} ج.م</p>
                </div>
              ))}
            </div>

            {/* Payment history */}
            {(saleDetail.payment_history?.length > 0 || Number(saleDetail.returns_total) > 0) && (
              <div>
                <p className="text-xs font-bold text-[var(--muted)] mb-2">سجل الدفعات والمرتجعات</p>
                <div className="space-y-1 max-h-40 overflow-y-auto">
                  {/* Payment entries */}
                  {(saleDetail.payment_history || []).map((p: any) => (
                    <div key={p.id} className="flex items-center justify-between bg-green-50 rounded-lg px-3 py-2 text-sm border border-green-100">
                      <div className="flex items-center gap-2">
                        <DollarSign size={14} className="text-green-600" />
                        <span className="font-bold text-green-700">دفعة</span>
                        <span className="text-xs text-[var(--muted)]">{p.note}</span>
                      </div>
                      <div className="flex items-center gap-3">
                        <span className="text-xs text-[var(--muted)]">{p.created_at ? new Date(p.created_at).toLocaleString('ar-EG') : ''}</span>
                        <span className="font-bold text-green-700">{Number(p.amount).toLocaleString('ar-EG')} ج.م</span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Pay action — only for confirmed credit invoices with remaining > 0 */}
            {saleDetail.status === 'confirmed' && saleDetail.customer_id && Number(saleDetail.remaining) > 0 && (
              <div className="border-t border-[var(--border)] pt-4">
                <p className="text-sm font-bold text-[var(--text)] mb-3">تسديد جزء من الفاتورة</p>
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">المبلغ *</label>
 <Input type="number" className="text-lg font-black" value={salePayAmount}
                      onChange={e => setSalePayAmount(e.target.value)} placeholder="0.00" max={saleDetail.remaining} />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">ملاحظة</label>
 <Input value={salePayNote} onChange={e => setSalePayNote(e.target.value)} placeholder="رقم إيصال..."/>
                  </div>
                </div>
                  <div className="flex gap-3 justify-end mt-3">
                   <Button variant="secondary" size="sm" onClick={() => { setSalePayAmount(''); setSalePayNote('') }}>
                     إلغاء
                   </Button>
                   <Button variant="default" size="sm" onClick={() => paySaleMut.mutate()}
                     disabled={!salePayAmount || Number(salePayAmount) <= 0 || paySaleMut.isPending}
                     className="flex items-center gap-2">
                     <DollarSign size={14} /> تسجيل الدفعة
                   </Button>
                 </div>
              </div>
            )}
          </div>
        )}
      </Modal>

      {/* Partial Return Modal */}
      <Modal open={!!returnSale} onClose={() => setReturnSale(null)} title={`مرتجع من ${returnSale?.invoice_number}`} size="lg">
        {returnSale && (
          <div className="space-y-4">
            <p className="text-sm text-[var(--muted)]">اختر الأصناف والكميات المراد إرجاعها</p>
            <div className="space-y-2 max-h-64 overflow-y-auto">
              {returnSale.items?.map((item: any) => (
                <div key={item.product_id} className="flex items-center justify-between p-3 rounded-xl bg-[var(--surface-2)] border border-[var(--border-faint)]">
                  <div className="flex-1">
                    <p className="font-semibold text-sm">{item.product_name || item.product_id.slice(0, 8)}</p>
                    <p className="text-xs text-[var(--muted)]">الكمية الأصلية: {item.qty} — {Number(item.unit_price).toLocaleString('ar-EG')} ج.م</p>
                  </div>
                  <div className="flex items-center gap-1.5">
                    <Button type="button" variant="ghost" size="icon-sm" onClick={() => setReturnQtys(q => ({ ...q, [item.product_id]: Math.max(0, (q[item.product_id] || 0) - 1) }))} className="w-7 h-7"><Minus size={12} /></Button>
                    <input type="number" aria-label={`كمية مرتجعة ${item.product_name}`} min="0" max={item.qty} value={returnQtys[item.product_id] || 0}
                      onChange={e => setReturnQtys(q => ({ ...q, [item.product_id]: Math.min(Number(e.target.value), item.qty) }))}
                      className="w-14 text-center text-sm font-bold border border-[var(--border)] rounded-lg py-1 outline-none focus:border-[var(--accent)]" />
                    <Button type="button" variant="ghost" size="icon-sm" onClick={() => setReturnQtys(q => ({ ...q, [item.product_id]: Math.min((q[item.product_id] || 0) + 1, item.qty) }))} className="w-7 h-7"><Plus size={12} /></Button>
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
               <Button variant="secondary" size="sm" onClick={() => setReturnSale(null)}>
                 إلغاء
               </Button>
               <Button variant="default" size="sm" onClick={() => partialReturnMut.mutate()}
                 disabled={Object.values(returnQtys).every(v => v === 0) || partialReturnMut.isPending}
                 className="flex items-center gap-2">
                 <RotateCcw size={14} /> تأكيد المرتجع
               </Button>
             </div>
          </div>
        )}
      </Modal>

      <ConfirmDialog open={!!confirmCancel} onClose={() => setConfirmCancel(null)}
        onConfirm={() => cancelMut.mutate(confirmCancel)}
        message="إلغاء الفاتورة؟" danger confirmText="إلغاء" title="تأكيد الإلغاء" />
    </div>
  )
}
