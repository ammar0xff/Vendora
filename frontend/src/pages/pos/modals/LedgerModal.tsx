import Modal from '../../../components/ui/Modal'
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '../../../components/ui/table'
import { Button } from '../../../components/ui/button'
import api from '../../../api/client'
import { Badge } from '../../../components/ui/badge'
import toast from 'react-hot-toast'
import { type QueryClient } from '@tanstack/react-query'

interface Props {
  showLedger: boolean
  onClose: () => void
  todayLedger: any
  confirmDelItem: any
  setConfirmDelItem: (v: any) => void
  confirmDelReturn: any
  setConfirmDelReturn: (v: any) => void
  confirmDelTx: any
  setConfirmDelTx: (v: any) => void
  shift: any
  qc: QueryClient
}

export function LedgerModal({ showLedger, onClose, todayLedger, confirmDelItem: _confirmDelItem, setConfirmDelItem, confirmDelReturn: _confirmDelReturn, setConfirmDelReturn, confirmDelTx: _confirmDelTx, setConfirmDelTx, shift, qc }: Props) {
  return (
    <Modal open={showLedger} onClose={onClose} title="سجل اليوم" size="xl">
      {todayLedger ? (
        <div className="space-y-3">
          {/* Summary */}
          <div className="grid grid-cols-9 gap-2 text-center text-xs">
            {[
              { label: 'الرصيد الافتتاحي', val: todayLedger.summary.opening_balance, colorClass: 'text-slate-500' },
              { label: 'إجمالي المبيعات', val: todayLedger.summary.total_sales, colorClass: 'text-green-600' },
              { label: 'نقدي', val: todayLedger.summary.cash_sales, colorClass: 'text-green-700' },
              { label: 'المرتجعات', val: todayLedger.summary.total_returns, colorClass: 'text-red-600' },
              { label: 'الخوارج', val: todayLedger.summary.total_expenses, colorClass: 'text-amber-600' },
              { label: 'الدواخل', val: todayLedger.summary.total_deposits, colorClass: 'text-blue-600' },
              { label: 'توريد إيرادات', val: todayLedger.summary.total_revenue_delivery ?? 0, colorClass: 'text-violet-600' },
              { label: 'الصافي', val: todayLedger.summary.net, colorClass: 'text-[var(--primary)]' },
              { label: 'الدرج (نقدي)', val: todayLedger.summary.cash_closing ?? todayLedger.summary.closing, colorClass: 'text-violet-600' },
            ].map(({ label, val, colorClass }) => (
              <div key={label} className="bg-slate-50 rounded-lg p-2">
                <p className="text-slate-400 mb-0.5">{label}</p>
                <p className={`font-black text-sm tabular-nums ${colorClass}`}>{Number(val ?? 0).toLocaleString('ar-EG')} ج.م</p>
              </div>
            ))}
          </div>

          {/* Single unified table */}
          <div className="table-wrap max-h-[60vh] overflow-y-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="w-7">#</TableHead>
                  <TableHead>اسم الصنف</TableHead>
                  <TableHead className="text-center whitespace-nowrap">الكمية</TableHead>
                  <TableHead className="text-center whitespace-nowrap">السعر</TableHead>
                  <TableHead className="text-center whitespace-nowrap">المجموع</TableHead>
                  <TableHead className="text-center whitespace-nowrap">النوع</TableHead>
                  <TableHead className="whitespace-nowrap">الدفع</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {/* Sale items */}
                {(todayLedger.sale_items || []).map((item: any, i: number) => (
                  <TableRow key={`s${i}`}>
                    <TableCell className="text-slate-400 text-xs">{i+1}</TableCell>
                    <TableCell>
                      <p className="font-medium text-sm leading-tight">{item.product_name}</p>
                      <p className="text-xs text-slate-400 leading-tight">{item.invoice_number} · {item.customer}</p>
                    </TableCell>
                    <TableCell className="text-center text-sm">
                      <Button variant="link" size="xs" className="text-[var(--primary)] hover:underline text-xs font-bold p-0 h-auto"
                        onClick={() => {
                          const newQty = prompt(`كمية جديدة لـ ${item.product_name} (الحالية: ${item.qty}):`, String(item.qty))
                          if (newQty && Number(newQty) > 0 && Number(newQty) !== item.qty) {
                            api.put(`/sales/${item.sale_id}/items/${item.item_id}`, { qty: Number(newQty) })
                              .then(() => { toast.success('✅ تم تعديل الكمية'); qc.invalidateQueries({ queryKey: ['pos-ledger'] }); qc.invalidateQueries({ queryKey: ['shift-summary', shift?.id] }) })
                              .catch((e: any) => toast.error(e.response?.data?.detail || 'فشل'))
                          }
                        }}>
                        {item.qty}
                      </Button>
                    </TableCell>
                    <TableCell className="text-center text-sm">{Number(item.unit_price).toLocaleString('ar-EG')}</TableCell>
                    <TableCell className="text-center font-bold text-sm text-green-700">{Number(item.total).toLocaleString('ar-EG')}</TableCell>
                    <TableCell className="text-center"><Badge className="bg-emerald-50 text-emerald-700 border-emerald-100 text-xs">مبيعات</Badge></TableCell>
                    <TableCell className="text-xs text-slate-500 flex items-center gap-1">
                      {item.payment_method}
                      <Button variant="ghost" size="xs" className="text-red-400 hover:text-red-600 mr-1 p-0 h-auto"
                        onClick={() => setConfirmDelItem(item)}>✕</Button>
                    </TableCell>
                  </TableRow>
                ))}

                {/* Returns */}
                {(todayLedger.returns || []).map((item: any, i: number) => (
                  <TableRow key={`r${i}`} className="bg-red-50">
                    <TableCell className="text-slate-400 text-xs">↩</TableCell>
                    <TableCell>
                      <p className="font-medium text-sm leading-tight">{item.product_name}</p>
                      <p className="text-xs text-slate-400 leading-tight">{item.invoice_number}</p>
                    </TableCell>
                    <TableCell className="text-center text-sm">{item.qty}</TableCell>
                    <TableCell className="text-center text-sm">{Number(item.unit_price).toLocaleString('ar-EG')}</TableCell>
                    <TableCell className="text-center font-bold text-sm text-red-600">{Number(item.total).toLocaleString('ar-EG')}</TableCell>
                    <TableCell className="text-center"><Badge className="bg-red-50 text-red-600 border-red-100 text-xs">مرتجع</Badge></TableCell>
                    <TableCell className="text-xs text-slate-500 flex items-center gap-1">—
                      {item.item_id && <Button variant="ghost" size="xs" className="text-red-400 hover:text-red-600 p-0 h-auto"
                        onClick={() => setConfirmDelReturn(item)}>✕</Button>}
                    </TableCell>
                  </TableRow>
                ))}

                {/* Expenses/Deposits */}
                {(todayLedger.expenses || []).map((e: any, i: number) => (
                  <TableRow key={`e${i}`} className={e.entry_type === 'deposit' ? 'bg-green-50' : 'bg-amber-50'}>
                    <TableCell className="text-slate-400 text-xs">💸</TableCell>
                    <TableCell>
                      <p className="font-medium text-sm leading-tight">{e.type_ar}</p>
                      <p className="text-xs text-slate-400 leading-tight">{e.note || '—'}</p>
                    </TableCell>
                    <TableCell></TableCell>
                    <TableCell></TableCell>
                    <TableCell className={`text-center font-bold text-sm ${e.entry_type === 'deposit' ? 'text-green-700' : 'text-amber-700'}`}>
                      {Number(e.amount).toLocaleString('ar-EG')}
                    </TableCell>
                    <TableCell className="text-center"><Badge variant={e.entry_type === 'deposit' ? 'green' : 'yellow'}>{e.type_ar}</Badge></TableCell>
                    <TableCell className="text-xs text-slate-500 flex items-center gap-1">{e.payment_method}
                      {e.tx_id && <Button variant="ghost" size="xs" className="text-red-400 hover:text-red-600 p-0 h-auto"
                        onClick={() => setConfirmDelTx(e)}>✕</Button>}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        </div>
      ) : <div className="text-center py-8 text-slate-400">جاري التحميل...</div>}
    </Modal>
  )
}
