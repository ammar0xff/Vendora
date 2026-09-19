/**
 * PrintView — renders a print-ready document and triggers window.print()
 * Used for both invoices and quotations.
 */
interface PrintItem {
  product_name: string
  unit: string
  qty: number
  unit_price: number
  discount: number
  total: number
}

interface PrintData {
  store: { name: string; address: string; phone: string; logo_url?: string }
  document_type: string
  invoice_number: string
  date: string
  sale_mode: string
  status: string
  customer: { name: string; phone: string }
  items: PrintItem[]
  subtotal: number
  discount: number
  total: number
  notes: string
  created_by_name?: string
}

import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from './table'
import { Button } from './button'

export default function InvoicePrint({ data, onClose }: { data: PrintData; onClose: () => void }) {
  const handlePrint = () => window.print()

  return (
    <>
      {/* Screen controls — hidden when printing */}
      <div className="print:hidden fixed top-4 left-1/2 -translate-x-1/2 z-50 flex gap-3 bg-white rounded-2xl shadow-xl p-3 border border-slate-200">
        <Button type="button" onClick={handlePrint} className="px-6 py-2 rounded-xl font-bold text-sm flex items-center gap-2" style={{ background: 'var(--primary)', color: 'white' }}>
          🖨️ طباعة
        </Button>
        <Button type="button" onClick={onClose} className="px-6 py-2 rounded-xl font-bold text-sm bg-slate-100 text-slate-600 hover:bg-slate-200">
          ✕ إغلاق
        </Button>
      </div>

      {/* Print document */}
      <div className="min-h-screen bg-white p-8 print:p-4" style={{ fontFamily: 'Cairo, sans-serif', direction: 'rtl' }}>
        <style>{`
          @media print {
            body * { visibility: hidden; }
            .print-doc, .print-doc * { visibility: visible; }
            .print-doc { position: fixed; top: 0; right: 0; width: 100%; padding: 16px; }
            .print-doc table { font-size: 13pt !important; }
            .print-doc td, .print-doc th { font-size: 13pt !important; padding: 8px 10px !important; }
            .print-doc h1 { font-size: 22pt !important; }
            .print-doc .text-xs { font-size: 11pt !important; }
            .print-doc .text-sm { font-size: 13pt !important; }
            .print-doc .text-base { font-size: 14pt !important; }
            .print-doc .text-lg { font-size: 16pt !important; }
            .print-doc .text-xl { font-size: 18pt !important; }
            .print-doc .total-row { font-size: 16pt !important; }
          }
        `}</style>

        <div className="print-doc max-w-2xl mx-auto">
          {/* Header */}
          <div className="flex items-start justify-between mb-6 pb-5 border-b-2" style={{ borderColor: 'var(--primary)' }}>
            <div>
              {data.store.logo_url ? (
                <img src={data.store.logo_url} alt="logo" className="h-16 object-contain mb-2" />
              ) : (
                <div className="w-14 h-14 rounded-2xl flex items-center justify-center text-white text-2xl font-black mb-2" style={{ background: 'var(--primary)' }}>
                  {(data.store.name || 'م')[0]}
                </div>
              )}
              <h1 className="text-3xl font-black mb-1" style={{ color: 'var(--primary)' }}>{data.store.name || 'المتجر'}</h1>
              <p className="text-base text-slate-600">{data.store.address}</p>
              <p className="text-base text-slate-600">📞 {data.store.phone}</p>
            </div>
            <div className="text-left">
              <div className="inline-block px-4 py-2 rounded-xl text-white font-bold text-lg mb-3" style={{ background: data.status === 'quotation' ? 'var(--accent)' : 'var(--primary)' }}>
                {data.document_type}
              </div>
              <p className="text-slate-800 font-bold text-xl">{data.invoice_number}</p>
              <p className="text-slate-600 text-base mt-1">{new Date(data.date).toLocaleDateString('ar-EG', { year: 'numeric', month: 'long', day: 'numeric' })}</p>
            </div>
          </div>

          {/* Customer info */}
          <div className="bg-slate-50 rounded-xl p-4 mb-5 grid grid-cols-2 gap-4">
            <div>
              <p className="text-sm text-slate-400 mb-1">العميل</p>
              <p className="font-bold text-base text-slate-800">{data.customer.name}</p>
              {data.customer.phone && <p className="text-base text-slate-600 mt-0.5">{data.customer.phone}</p>}
            </div>
            <div>
              <p className="text-sm text-slate-400 mb-1">نوع البيع</p>
              <p className="font-bold text-base text-slate-800">{data.sale_mode === 'wholesale' ? 'جملة' : 'قطاعي'}</p>
            </div>
          </div>

          {/* Items table */}
          <Table className="w-full mb-5 border-collapse" style={{ fontSize: '14px' }}>
            <TableHeader>
              <TableRow style={{ background: 'var(--primary)' }}>
                <TableHead className="text-white text-right px-3 py-3 rounded-r-lg" style={{ fontSize: '14px' }}>#</TableHead>
                <TableHead className="text-white text-right px-3 py-3" style={{ fontSize: '14px' }}>المنتج</TableHead>
                <TableHead className="text-white text-center px-3 py-3" style={{ fontSize: '14px' }}>الوحدة</TableHead>
                <TableHead className="text-white text-center px-3 py-3" style={{ fontSize: '14px' }}>الكمية</TableHead>
                <TableHead className="text-white text-center px-3 py-3" style={{ fontSize: '14px' }}>السعر</TableHead>
                {data.items.some(i => i.discount > 0) && (
                  <TableHead className="text-white text-center px-3 py-3" style={{ fontSize: '14px' }}>الخصم</TableHead>
                )}
                <TableHead className="text-white text-center px-3 py-3 rounded-l-lg" style={{ fontSize: '14px' }}>الإجمالي</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {data.items.map((item, i) => (
                <TableRow key={i} className={i % 2 === 0 ? 'bg-white' : 'bg-slate-50'}>
                  <TableCell className="px-3 py-3 text-slate-500" style={{ fontSize: '13px' }}>{i + 1}</TableCell>
                  <TableCell className="px-3 py-3 font-semibold text-slate-800" style={{ fontSize: '14px' }}>{item.product_name}</TableCell>
                  <TableCell className="px-3 py-3 text-center text-slate-600" style={{ fontSize: '13px' }}>{item.unit}</TableCell>
                  <TableCell className="px-3 py-3 text-center font-bold" style={{ fontSize: '14px' }}>{item.qty}</TableCell>
                  <TableCell className="px-3 py-3 text-center" style={{ fontSize: '13px' }}>{item.unit_price.toLocaleString('ar-EG')}</TableCell>
                  {data.items.some(i => i.discount > 0) && (
                    <TableCell className="px-3 py-3 text-center text-red-600" style={{ fontSize: '13px' }}>
                      {item.discount > 0 ? `- ${item.discount.toLocaleString('ar-EG')}` : '—'}
                    </TableCell>
                  )}
                  <TableCell className="px-3 py-3 text-center font-bold" style={{ fontSize: '14px', color: 'var(--primary)' }}>
                    {item.total.toLocaleString('ar-EG')}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>

          {/* Totals */}
          <div className="flex justify-end mb-5">
            <div className="w-72 space-y-2">
              <div className="flex justify-between text-base text-slate-600 py-1">
                <span>المجموع الفرعي</span>
                <span>{data.subtotal.toLocaleString('ar-EG')} ج.م</span>
              </div>
              {data.discount > 0 && (
                <div className="flex justify-between text-base text-red-600 py-1">
                  <span>الخصم</span>
                  <span>- {data.discount.toLocaleString('ar-EG')} ج.م</span>
                </div>
              )}
              <div className="total-row flex justify-between font-black text-xl pt-3 border-t-2" style={{ borderColor: 'var(--primary)', color: 'var(--primary)' }}>
                <span>الإجمالي</span>
                <span>{data.total.toLocaleString('ar-EG')} ج.م</span>
              </div>
            </div>
          </div>

          {/* Notes */}
          {data.notes && (
            <div className="bg-yellow-50 border border-yellow-200 rounded-xl p-4 mb-5">
              <p className="text-sm text-yellow-700 font-bold mb-1">ملاحظات</p>
              <p className="text-base text-slate-700">{data.notes}</p>
            </div>
          )}

          {/* Footer */}
          <div className="text-center pt-5 border-t border-slate-200">
            {data.created_by_name && <p className="text-slate-500 text-sm mb-1">أنشأه: {data.created_by_name}</p>}
            <p className="text-slate-500 text-sm">شكراً لتعاملكم معنا</p>
            {data.status === 'quotation' && (
              <p className="text-amber-600 text-base font-bold mt-2">⚠️ هذا عرض سعر وليس فاتورة رسمية</p>
            )}
          </div>
        </div>
      </div>
    </>
  )
}
