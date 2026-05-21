import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import api from '../../api/client'
import { PageLoader } from '../../components/ui/Loaders'
import { useAppStore } from '../../store/app'

const fmt = (n: number) => Number(n || 0).toLocaleString('ar-EG', { minimumFractionDigits: 0, maximumFractionDigits: 2 })

function SectionCard({ title, icon, color, children }: any) {
  return (
    <div className="card overflow-hidden">
      <div className="px-5 py-3 border-b border-slate-100 flex items-center gap-2" style={{ borderRight: `3px solid ${color}` }}>
        <span>{icon}</span>
        <h3 className="font-bold text-slate-700">{title}</h3>
      </div>
      <div className="p-5">{children}</div>
    </div>
  )
}

function Row({ label, amount, total }: { label: string; amount: number; total: number }) {
  const pct = total > 0 ? (amount / total) * 100 : 0
  return (
    <div className="flex items-center justify-between py-2 border-b border-slate-50 last:border-0">
      <span className="text-sm text-slate-600">{label}</span>
      <div className="flex items-center gap-3">
        <span className="font-bold text-sm" style={{ minWidth: 100, textAlign: 'left', direction: 'ltr' }}>{fmt(amount)} ج.م</span>
        <div className="w-20 h-1.5 bg-slate-100 rounded-full overflow-hidden">
          <div className="h-full rounded-full" style={{ width: `${Math.min(pct, 100)}%`, background: total > 0 ? '#1e3a5f' : '#e5e7eb' }} />
        </div>
      </div>
    </div>
  )
}

export default function CashFlowPage() {
  const today = new Date().toISOString().slice(0, 10)
  const firstDay = new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString().slice(0, 10)
  const [fromDate, setFromDate] = useState(firstDay)
  const [toDate, setToDate] = useState(today)
  const { activeWarehouseId } = useAppStore()

  const { data, isLoading } = useQuery({
    queryKey: ['cash-flow', fromDate, toDate, activeWarehouseId],
    queryFn: () => api.get('/reports/cash-flow', {
      params: { from_date: fromDate, to_date: toDate, warehouse_id: activeWarehouseId || undefined },
    }).then(r => r.data),
    enabled: !!fromDate && !!toDate,
  })

  return (
    <div>
      <div className="page-header mb-5">
        <h1 className="page-title">التدفق النقدي</h1>
      </div>

      {/* Date filter */}
      <div className="flex gap-4 items-end mb-6">
        <div><label className="block text-xs font-medium text-slate-500 mb-1">من تاريخ</label><input type="date" className="input" value={fromDate} onChange={e => setFromDate(e.target.value)} /></div>
        <div><label className="block text-xs font-medium text-slate-500 mb-1">إلى تاريخ</label><input type="date" className="input" value={toDate} onChange={e => setToDate(e.target.value)} /></div>
      </div>

      {isLoading ? <PageLoader text="جاري تحميل التدفق النقدي..." /> : !data ? null : (
        <div className="grid grid-cols-3 gap-6">
          {/* Incoming */}
          <SectionCard title="الوارد" icon="📥" color="#16a34a">
            <Row label="مبيعات نقدي" amount={data.incoming.cash_sales} total={data.incoming.total_incoming} />
            <Row label="مبيعات آجل" amount={data.incoming.credit_sales} total={data.incoming.total_incoming} />
            <Row label="تحصيلات العملاء" amount={data.incoming.customer_payments} total={data.incoming.total_incoming} />
            <Row label="مرتجعات من الموردين" amount={data.incoming.returns_from_suppliers} total={data.incoming.total_incoming} />
            <div className="flex items-center justify-between pt-3 mt-2 border-t-2 border-green-200">
              <span className="text-sm font-black text-green-700">إجمالي الوارد</span>
              <span className="font-black text-green-700">{fmt(data.incoming.total_incoming)} ج.م</span>
            </div>
          </SectionCard>

          {/* Outgoing */}
          <SectionCard title="الصادر" icon="📤" color="#dc2626">
            <Row label="المشتريات" amount={data.outgoing.purchases} total={data.outgoing.total_outgoing} />
            <Row label="المصروفات" amount={data.outgoing.expenses} total={data.outgoing.total_outgoing} />
            <Row label="الرواتب" amount={data.outgoing.payroll} total={data.outgoing.total_outgoing} />
            <Row label="مرتجعات العملاء" amount={data.outgoing.returns_to_customers} total={data.outgoing.total_outgoing} />
            <Row label="مدفوعات الموردين" amount={data.outgoing.supplier_payments} total={data.outgoing.total_outgoing} />
            <div className="flex items-center justify-between pt-3 mt-2 border-t-2 border-red-200">
              <span className="text-sm font-black text-red-700">إجمالي الصادر</span>
              <span className="font-black text-red-700">{fmt(data.outgoing.total_outgoing)} ج.م</span>
            </div>
          </SectionCard>

          {/* Net */}
          <SectionCard title="صافي التدفق" icon="⚖️" color={data.net_cash_flow >= 0 ? '#16a34a' : '#dc2626'}>
            <div className="flex flex-col items-center justify-center py-6">
              <p className="text-4xl font-black" style={{ color: data.net_cash_flow >= 0 ? '#16a34a' : '#dc2626' }}>
                {fmt(data.net_cash_flow)} ج.م
              </p>
              <p className="text-sm text-slate-500 mt-2">
                {data.net_cash_flow >= 0 ? '🟢 الوارد أكبر من الصادر' : '🔴 الصادر أكبر من الوارد'}
              </p>
            </div>
          </SectionCard>

          {/* Expense breakdown */}
          {data.details?.expenses_by_category?.length > 0 && (
            <SectionCard title="تحليل المصروفات حسب الفئة" icon="📊" color="#d97706">
              {data.details.expenses_by_category.map((c: any) => (
                <Row key={c.name} label={c.name} amount={c.amount} total={data.outgoing.expenses} />
              ))}
            </SectionCard>
          )}

          {/* Sales breakdown */}
          {data.details?.sales_by_warehouse?.length > 0 && (
            <SectionCard title="تحليل المبيعات حسب الفرع" icon="🏪" color="#2563eb">
              {data.details.sales_by_warehouse.map((s: any) => (
                <Row key={s.warehouse} label={s.warehouse} amount={s.amount} total={data.incoming.total_incoming} />
              ))}
            </SectionCard>
          )}
        </div>
      )}
    </div>
  )
}
