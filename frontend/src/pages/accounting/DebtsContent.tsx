import { useQuery } from '@tanstack/react-query'
import { customersApi, suppliersApi } from '../../api/endpoints'

export default function DebtsContent() {
  const { data: customers, isLoading: loadingCustomers } = useQuery({ queryKey: ['customers'], queryFn: () => customersApi.list() })
  const { data: suppliers, isLoading: loadingSuppliers } = useQuery({ queryKey: ['suppliers'], queryFn: () => suppliersApi.list() })

  if (loadingCustomers || loadingSuppliers) {
    return (
      <div className="space-y-6">
        <div className="grid grid-cols-2 gap-4">
          <div className="card h-24 animate-pulse bg-slate-50" />
          <div className="card h-24 animate-pulse bg-slate-50" />
        </div>
      </div>
    )
  }

  const customerDebts = (customers || []).filter((c: any) => Number(c.balance_due || 0) > 0)
    .sort((a: any, b: any) => Number(b.balance_due) - Number(a.balance_due))
  const supplierDebts = (suppliers || []).filter((s: any) => Number(s.balance || 0) > 0)
    .sort((a: any, b: any) => Number(b.balance) - Number(a.balance))

  const totalCustomer = customerDebts.reduce((s: number, c: any) => s + Number(c.balance_due), 0)
  const totalSupplier = supplierDebts.reduce((s: number, c: any) => s + Number(c.balance), 0)

  return (
    <div className="space-y-6">
      {/* Summary */}
      <div className="grid grid-cols-2 gap-4">
        <div className="card p-4 border-r-4" style={{ borderColor: '#d97706' }}>
          <p className="text-xs font-bold text-slate-400 uppercase mb-1">مديونية العملاء (لنا)</p>
          <p className="text-2xl font-black text-amber-700">{totalCustomer.toLocaleString('ar-EG')} ج.م</p>
          <p className="text-xs text-slate-400 mt-1">{customerDebts.length} عميل</p>
        </div>
        <div className="card p-4 border-r-4" style={{ borderColor: '#dc2626' }}>
          <p className="text-xs font-bold text-slate-400 uppercase mb-1">مديونية الموردين (علينا)</p>
          <p className="text-2xl font-black text-red-600">{totalSupplier.toLocaleString('ar-EG')} ج.م</p>
          <p className="text-xs text-slate-400 mt-1">{supplierDebts.length} مورد</p>
        </div>
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-2 gap-6">
        {/* Customer debts */}
        <div className="card">
          <h3 className="font-bold text-slate-700 mb-4 flex items-center justify-between">
            <span>👤 مديونية العملاء</span>
            <span className="text-sm font-black text-amber-700">{totalCustomer.toLocaleString('ar-EG')} ج.م</span>
          </h3>
          {!customerDebts.length
            ? <p className="text-slate-400 text-center py-8">✅ لا توجد مديونيات</p>
            : (
              <div className="space-y-0">
                <div className="grid grid-cols-3 text-xs font-bold text-slate-400 px-2 pb-2 border-b border-slate-100">
                  <span>العميل</span><span className="text-center">التليفون</span><span className="text-left">المديونية</span>
                </div>
                {customerDebts.map((c: any) => (
                  <div key={c.id} className="grid grid-cols-3 items-center py-2.5 px-2 border-b border-slate-50 last:border-0 hover:bg-slate-50">
                    <span className="font-semibold text-slate-800 text-sm truncate">{c.name}</span>
                    <span className="text-center text-xs text-slate-400">{c.phone || '—'}</span>
                    <span className="text-left font-black text-amber-700">{Number(c.balance_due).toLocaleString('ar-EG')} ج.م</span>
                  </div>
                ))}
                <div className="flex justify-between pt-3 border-t-2 border-slate-200 font-black text-slate-800 px-2">
                  <span>الإجمالي</span><span className="text-amber-700">{totalCustomer.toLocaleString('ar-EG')} ج.م</span>
                </div>
              </div>
            )}
        </div>

        {/* Supplier debts */}
        <div className="card">
          <h3 className="font-bold text-slate-700 mb-4 flex items-center justify-between">
            <span>🏭 مديونية الموردين</span>
            <span className="text-sm font-black text-red-600">{totalSupplier.toLocaleString('ar-EG')} ج.م</span>
          </h3>
          {!supplierDebts.length
            ? <p className="text-slate-400 text-center py-8">✅ لا توجد مديونيات</p>
            : (
              <div className="space-y-0">
                <div className="grid grid-cols-3 text-xs font-bold text-slate-400 px-2 pb-2 border-b border-slate-100">
                  <span>المورد</span><span className="text-center">التليفون</span><span className="text-left">المديونية</span>
                </div>
                {supplierDebts.map((s: any) => (
                  <div key={s.id} className="grid grid-cols-3 items-center py-2.5 px-2 border-b border-slate-50 last:border-0 hover:bg-slate-50">
                    <span className="font-semibold text-slate-800 text-sm truncate">{s.name}</span>
                    <span className="text-center text-xs text-slate-400">{s.phone || '—'}</span>
                    <span className="text-left font-black text-red-600">{Number(s.balance).toLocaleString('ar-EG')} ج.م</span>
                  </div>
                ))}
                <div className="flex justify-between pt-3 border-t-2 border-slate-200 font-black text-slate-800 px-2">
                  <span>الإجمالي</span><span className="text-red-600">{totalSupplier.toLocaleString('ar-EG')} ج.م</span>
                </div>
              </div>
            )}
        </div>
      </div>
    </div>
  )
}
