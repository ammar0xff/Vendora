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

export default function InvoicePrint({ data, onClose }: { data: PrintData; onClose: () => void }) {
  const handlePrint = () => window.print()

  return (
    <>
      {/* Screen controls — hidden when printing */}
      <div className="print:hidden fixed top-4 left-1/2 -translate-x-1/2 z-50 flex gap-3 bg-white rounded-2xl shadow-xl p-3 border border-slate-200">
        <button onClick={handlePrint} className="btn-primary px-6 py-2 rounded-xl font-bold text-sm flex items-center gap-2" style={{ background: '#1e3a5f', color: 'white' }}>
          🖨️ طباعة
        </button>
        <button onClick={onClose} className="px-6 py-2 rounded-xl font-bold text-sm bg-slate-100 text-slate-600 hover:bg-slate-200">
          ✕ إغلاق
        </button>
      </div>

      {/* Print document */}
      <div className="min-h-screen bg-white p-8 print:p-6" style={{ fontFamily: 'Cairo, sans-serif', direction: 'rtl' }}>
        <style>{`
          @media print {
            body * { visibility: hidden; }
            .print-doc, .print-doc * { visibility: visible; }
            .print-doc { position: fixed; top: 0; right: 0; width: 100%; }
          }
        `}</style>

        <div className="print-doc max-w-2xl mx-auto">
          {/* Header */}
          <div className="flex items-start justify-between mb-8 pb-6 border-b-2" style={{ borderColor: '#1e3a5f' }}>
            <div>
              {data.store.logo_url ? (
              <img src={data.store.logo_url} alt="logo" className="h-16 object-contain mb-2" />
            ) : (
              <div className="w-14 h-14 rounded-2xl flex items-center justify-center text-white text-2xl font-black mb-2" style={{ background: '#1e3a5f' }}>
                {(data.store.name || 'م')[0]}
              </div>
            )}
          {data.store.logo_url ? (
              <img src={data.store.logo_url} alt="logo" className="h-14 object-contain mb-2" />
            ) : (
              <div className="w-12 h-12 rounded-xl flex items-center justify-center text-white text-xl font-black mb-2" style={{ background: '#1e3a5f' }}>
                {(data.store.name || 'م')[0]}
              </div>
            )}
          <h1 className="text-3xl font-black mb-1" style={{ color: '#1e3a5f' }}>{data.store.name || 'المتجر'}</h1>
              <p className="text-slate-500 text-sm">{data.store.address}</p>
              <p className="text-slate-500 text-sm">📞 {data.store.phone}</p>
            </div>
            <div className="text-left">
              <div className="inline-block px-4 py-2 rounded-xl text-white font-bold text-lg mb-2" style={{ background: data.status === 'quotation' ? '#c8a84b' : '#1e3a5f' }}>
                {data.document_type}
              </div>
              <p className="text-slate-700 font-bold text-lg">{data.invoice_number}</p>
              <p className="text-slate-500 text-sm">{new Date(data.date).toLocaleDateString('ar-EG', { year: 'numeric', month: 'long', day: 'numeric' })}</p>
            </div>
          </div>

          {/* Customer info */}
          <div className="bg-slate-50 rounded-xl p-4 mb-6 grid grid-cols-2 gap-4">
            <div>
              <p className="text-xs text-slate-400 mb-1">العميل</p>
              <p className="font-bold text-slate-800">{data.customer.name}</p>
              {data.customer.phone && <p className="text-sm text-slate-500">{data.customer.phone}</p>}
            </div>
            <div>
              <p className="text-xs text-slate-400 mb-1">نوع البيع</p>
              <p className="font-bold text-slate-800">{data.sale_mode === 'wholesale' ? 'جملة' : 'قطاعي'}</p>
            </div>
          </div>

          {/* Items table */}
          <table className="w-full mb-6 text-sm">
            <thead>
              <tr style={{ background: '#1e3a5f' }}>
                <th className="text-white text-right px-3 py-2.5 rounded-r-lg">#</th>
                <th className="text-white text-right px-3 py-2.5">المنتج</th>
                <th className="text-white text-center px-3 py-2.5">الوحدة</th>
                <th className="text-white text-center px-3 py-2.5">الكمية</th>
                <th className="text-white text-center px-3 py-2.5">السعر</th>
                <th className="text-white text-center px-3 py-2.5 rounded-l-lg">الإجمالي</th>
              </tr>
            </thead>
            <tbody>
              {data.items.map((item, i) => (
                <tr key={i} className={i % 2 === 0 ? 'bg-white' : 'bg-slate-50'}>
                  <td className="px-3 py-2.5 text-slate-400 text-xs">{i + 1}</td>
                  <td className="px-3 py-2.5 font-medium text-slate-800">{item.product_name}</td>
                  <td className="px-3 py-2.5 text-center text-slate-600">{item.unit}</td>
                  <td className="px-3 py-2.5 text-center font-bold">{item.qty}</td>
                  <td className="px-3 py-2.5 text-center">{item.unit_price.toLocaleString('ar-EG')}</td>
                  <td className="px-3 py-2.5 text-center font-bold" style={{ color: '#1e3a5f' }}>{item.total.toLocaleString('ar-EG')}</td>
                </tr>
              ))}
            </tbody>
          </table>

          {/* Totals */}
          <div className="flex justify-end mb-6">
            <div className="w-64 space-y-2">
              <div className="flex justify-between text-sm text-slate-600">
                <span>المجموع الفرعي</span>
                <span>{data.subtotal.toLocaleString('ar-EG')} ج.م</span>
              </div>
              {data.discount > 0 && (
                <div className="flex justify-between text-sm text-red-600">
                  <span>الخصم</span>
                  <span>- {data.discount.toLocaleString('ar-EG')} ج.م</span>
                </div>
              )}
              <div className="flex justify-between font-black text-lg pt-2 border-t-2" style={{ borderColor: '#1e3a5f', color: '#1e3a5f' }}>
                <span>الإجمالي</span>
                <span>{data.total.toLocaleString('ar-EG')} ج.م</span>
              </div>
            </div>
          </div>

          {/* Notes */}
          {data.notes && (
            <div className="bg-yellow-50 border border-yellow-200 rounded-xl p-4 mb-6">
              <p className="text-xs text-yellow-600 font-bold mb-1">ملاحظات</p>
              <p className="text-sm text-slate-700">{data.notes}</p>
            </div>
          )}

          {/* Footer */}
          <div className="text-center pt-6 border-t border-slate-200">
            {data.created_by_name && <p className="text-slate-400 text-xs mb-1">أنشأه: {data.created_by_name}</p>}
            <p className="text-slate-400 text-xs">شكراً لتعاملكم معنا</p>
            {data.status === 'quotation' && (
              <p className="text-amber-600 text-xs font-bold mt-1">⚠️ هذا عرض سعر وليس فاتورة رسمية</p>
            )}
          </div>
        </div>
      </div>
    </>
  )
}
