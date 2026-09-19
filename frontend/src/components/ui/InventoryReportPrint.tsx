import { Button } from './button'
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from './table'

interface InventoryReportData {
  store: { name: string; address: string; phone: string }
  warehouse: string
  generated_at: string
  items: Array<{
    category: string; subcategory: string; name: string; unit: string
    qty: number; cost_price: number; retail_price: number; cost_value: number; retail_value: number
  }>
  summary: { total_products: number; total_cost_value: number; total_retail_value: number }
}

export default function InventoryReportPrint({ data, onClose }: { data: InventoryReportData; onClose: () => void }) {
  // Group by category
  const grouped: Record<string, typeof data.items> = {}
  for (const item of data.items) {
    if (!grouped[item.category]) grouped[item.category] = []
    grouped[item.category].push(item)
  }

  return (
    <>
      <div className="print:hidden fixed top-4 left-1/2 -translate-x-1/2 z-50 flex gap-3 bg-white rounded-2xl shadow-xl p-3 border border-slate-200">
        <Button onClick={() => window.print()}>
          🖨️ طباعة
        </Button>
        <Button variant="ghost" onClick={onClose}>
          ✕ إغلاق
        </Button>
      </div>

      <div className="min-h-screen bg-white p-8 print:p-4" style={{ fontFamily: 'Cairo, sans-serif', direction: 'rtl' }}>
        <style>{`
          @media print {
            body * { visibility: hidden; }
            .print-doc, .print-doc * { visibility: visible; }
            .print-doc { position: fixed; top: 0; right: 0; width: 100%; }
            table { page-break-inside: auto; }
            tr { page-break-inside: avoid; }
          }
        `}</style>

        <div className="print-doc max-w-5xl mx-auto">
          {/* Header */}
          <div className="flex items-start justify-between mb-6 pb-4 border-b-2" style={{ borderColor: 'var(--primary)' }}>
            <div>
              <h1 className="text-2xl font-black" style={{ color: 'var(--primary)' }}>{data.store.name}</h1>
              <p className="text-slate-500 text-sm">{data.store.address} | {data.store.phone}</p>
            </div>
            <div className="text-left">
              <h2 className="text-xl font-black" style={{ color: 'var(--primary)' }}>تقرير المخزون</h2>
              <p className="text-slate-600 text-sm font-medium">المخزن: {data.warehouse}</p>
              <p className="text-slate-400 text-xs">{new Date(data.generated_at).toLocaleString('ar-EG')}</p>
            </div>
          </div>

          {/* Summary cards */}
          <div className="grid grid-cols-3 gap-4 mb-6">
            {[
              { label: 'إجمالي المنتجات', value: data.summary.total_products.toLocaleString('ar-EG'), unit: 'منتج' },
              { label: 'القيمة بسعر التكلفة', value: data.summary.total_cost_value.toLocaleString('ar-EG'), unit: 'ج.م' },
              { label: 'القيمة بسعر البيع', value: data.summary.total_retail_value.toLocaleString('ar-EG'), unit: 'ج.م' },
            ].map(({ label, value, unit }) => (
              <div key={label} className="bg-slate-50 rounded-xl p-4 text-center border border-slate-200">
                <p className="text-xs text-slate-500 mb-1">{label}</p>
                <p className="text-xl font-black" style={{ color: 'var(--primary)' }}>{value} <span className="text-sm font-normal text-slate-500">{unit}</span></p>
              </div>
            ))}
          </div>

          {/* Items by category */}
          {Object.entries(grouped).map(([cat, items]) => (
            <div key={cat} className="mb-6">
              <h3 className="font-black text-base mb-2 px-3 py-1.5 rounded-lg text-white" style={{ background: 'var(--primary)' }}>{cat}</h3>
              <Table className="w-full text-xs">
                <TableHeader>
                  <TableRow className="bg-slate-100">
                    <TableHead className="text-right px-3 py-2">المنتج</TableHead>
                    <TableHead className="text-right px-3 py-2">التصنيف</TableHead>
                    <TableHead className="text-center px-3 py-2">الوحدة</TableHead>
                    <TableHead className="text-center px-3 py-2">الكمية</TableHead>
                    <TableHead className="text-center px-3 py-2">سعر التكلفة</TableHead>
                    <TableHead className="text-center px-3 py-2">سعر البيع</TableHead>
                    <TableHead className="text-center px-3 py-2">القيمة (تكلفة)</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {items.map((item, i) => (
                    <TableRow key={i} className={`border-b border-slate-100 ${item.qty <= 0 ? 'bg-red-50' : i % 2 === 0 ? 'bg-white' : 'bg-slate-50'}`}>
                      <TableCell className="px-3 py-2 font-medium">{item.name}</TableCell>
                      <TableCell className="px-3 py-2 text-slate-500">{item.subcategory}</TableCell>
                      <TableCell className="px-3 py-2 text-center">{item.unit}</TableCell>
                      <TableCell className={`px-3 py-2 text-center font-bold ${item.qty <= 0 ? 'text-red-600' : item.qty <= 5 ? 'text-amber-600' : 'text-green-700'}`}>{item.qty}</TableCell>
                      <TableCell className="px-3 py-2 text-center">{item.cost_price.toLocaleString('ar-EG')}</TableCell>
                      <TableCell className="px-3 py-2 text-center">{item.retail_price.toLocaleString('ar-EG')}</TableCell>
                      <TableCell className="px-3 py-2 text-center font-semibold">{item.cost_value.toLocaleString('ar-EG')}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          ))}

          <div className="text-center pt-4 border-t border-slate-200 text-slate-400 text-xs">
            تم إنشاء هذا التقرير بواسطة نظام إدارة المخزون
          </div>
        </div>
      </div>
    </>
  )
}
