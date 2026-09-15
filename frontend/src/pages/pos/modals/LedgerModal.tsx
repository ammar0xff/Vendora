import Modal from '../../../components/ui/Modal'
import api from '../../../api/client'
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

export function LedgerModal({ showLedger, onClose, todayLedger, confirmDelItem, setConfirmDelItem, confirmDelReturn, setConfirmDelReturn, confirmDelTx, setConfirmDelTx, shift, qc }: Props) {
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
            <table>
              <thead>
                <tr>
                  <th className="w-7">#</th>
                  <th>اسم الصنف</th>
                  <th className="text-center whitespace-nowrap">الكمية</th>
                  <th className="text-center whitespace-nowrap">السعر</th>
                  <th className="text-center whitespace-nowrap">المجموع</th>
                  <th className="text-center whitespace-nowrap">النوع</th>
                  <th className="whitespace-nowrap">الدفع</th>
                </tr>
              </thead>
              <tbody>
                {/* Sale items */}
                {(todayLedger.sale_items || []).map((item: any, i: number) => (
                  <tr key={`s${i}`}>
                    <td className="text-slate-400 text-xs">{i+1}</td>
                    <td>
                      <p className="font-medium text-sm leading-tight">{item.product_name}</p>
                      <p className="text-xs text-slate-400 leading-tight">{item.invoice_number} · {item.customer}</p>
                    </td>
                    <td className="text-center text-sm">
                      <button className="text-[var(--primary)] hover:underline text-xs font-bold"
                        onClick={() => {
                          const newQty = prompt(`كمية جديدة لـ ${item.product_name} (الحالية: ${item.qty}):`, String(item.qty))
                          if (newQty && Number(newQty) > 0 && Number(newQty) !== item.qty) {
                            api.put(`/sales/${item.sale_id}/items/${item.item_id}`, { qty: Number(newQty) })
                              .then(() => { toast.success('✅ تم تعديل الكمية'); qc.invalidateQueries({ queryKey: ['pos-ledger'] }); qc.invalidateQueries({ queryKey: ['shift-summary', shift?.id] }) })
                              .catch((e: any) => toast.error(e.response?.data?.detail || 'فشل'))
                          }
                        }}>
                        {item.qty}
                      </button>
                    </td>
                    <td className="text-center text-sm">{Number(item.unit_price).toLocaleString('ar-EG')}</td>
                    <td className="text-center font-bold text-sm text-green-700">{Number(item.total).toLocaleString('ar-EG')}</td>
                    <td className="text-center"><span className="badge-green text-xs">مبيعات</span></td>
                    <td className="text-xs text-slate-500 flex items-center gap-1">
                      {item.payment_method}
                      <button className="text-red-400 hover:text-red-600 mr-1"
                        onClick={() => setConfirmDelItem(item)}>✕</button>
                    </td>
                  </tr>
                ))}

                {/* Returns */}
                {(todayLedger.returns || []).map((item: any, i: number) => (
                  <tr key={`r${i}`} className="bg-red-50">
                    <td className="text-slate-400 text-xs">↩</td>
                    <td>
                      <p className="font-medium text-sm leading-tight">{item.product_name}</p>
                      <p className="text-xs text-slate-400 leading-tight">{item.invoice_number}</p>
                    </td>
                    <td className="text-center text-sm">{item.qty}</td>
                    <td className="text-center text-sm">{Number(item.unit_price).toLocaleString('ar-EG')}</td>
                    <td className="text-center font-bold text-sm text-red-600">{Number(item.total).toLocaleString('ar-EG')}</td>
                    <td className="text-center"><span className="badge-red text-xs">مرتجع</span></td>
                    <td className="text-xs text-slate-500 flex items-center gap-1">—
                      {item.item_id && <button className="text-red-400 hover:text-red-600"
                        onClick={() => setConfirmDelReturn(item)}>✕</button>}
                    </td>
                  </tr>
                ))}

                {/* Expenses/Deposits */}
                {(todayLedger.expenses || []).map((e: any, i: number) => (
                  <tr key={`e${i}`} className={e.entry_type === 'deposit' ? 'bg-green-50' : 'bg-amber-50'}>
                    <td className="text-slate-400 text-xs">💸</td>
                    <td>
                      <p className="font-medium text-sm leading-tight">{e.type_ar}</p>
                      <p className="text-xs text-slate-400 leading-tight">{e.note || '—'}</p>
                    </td>
                    <td></td>
                    <td></td>
                    <td className={`text-center font-bold text-sm ${e.entry_type === 'deposit' ? 'text-green-700' : 'text-amber-700'}`}>
                      {Number(e.amount).toLocaleString('ar-EG')}
                    </td>
                    <td className="text-center"><span className={e.entry_type === 'deposit' ? 'badge-green' : 'badge-yellow'}>{e.type_ar}</span></td>
                    <td className="text-xs text-slate-500 flex items-center gap-1">{e.payment_method}
                      {e.tx_id && <button className="text-red-400 hover:text-red-600"
                        onClick={() => setConfirmDelTx(e)}>✕</button>}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      ) : <div className="text-center py-8 text-slate-400">جاري التحميل...</div>}
    </Modal>
  )
}
