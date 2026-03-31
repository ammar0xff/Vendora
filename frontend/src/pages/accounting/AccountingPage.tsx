/**
 * AccountingPage — unified accounting hub
 * Tabs: Dashboard | Income Statement | Financial Ledger | Sales | Debts
 */
import { useState } from 'react'
import { useAppStore } from '../../store/app'
import AdminOverview from '../admin/AdminPage'
import ReportsContent from './ReportsContent'
import FinanceLedgerContent from './FinanceLedgerContent'
import SalesReportContent from './SalesReportContent'
import DebtsContent from './DebtsContent'
import SafesContent from './SafesContent'

const TABS = [
  { id: 'overview',  label: '📊 لوحة التحكم',      roles: ['admin','manager'] },
  { id: 'pnl',       label: '📈 قائمة الدخل',       roles: ['admin','manager','accountant'] },
  { id: 'ledger',    label: '⚖️ الميزان المالي',    roles: ['admin','manager','accountant'] },
  { id: 'sales',     label: '🧾 تقارير المبيعات',   roles: ['admin','manager','accountant','cashier'] },
  { id: 'debts',     label: '💳 المديونيات',         roles: ['admin','manager','accountant'] },
  { id: 'safes',     label: '🏦 الخزنات',            roles: ['admin','manager','accountant'] },
]

export default function AccountingPage() {
  const [tab, setTab] = useState('overview')
  const { activeWarehouseId } = useAppStore()

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">📒 الحسابات</h1>
          <p className="text-slate-500 text-sm mt-1">
            {activeWarehouseId ? 'عرض الفرع المحدد' : 'إجمالي الشركة — كل الفروع'}
          </p>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex gap-0 mb-6 border-b border-slate-200 overflow-x-auto">
        {TABS.map(t => (
          <button key={t.id} onClick={() => setTab(t.id)}
            className={`px-5 py-3 text-sm font-semibold border-b-2 -mb-px whitespace-nowrap transition-all flex-shrink-0
              ${tab === t.id ? 'border-blue-600 text-blue-700' : 'border-transparent text-slate-500 hover:text-slate-700'}`}>
            {t.label}
          </button>
        ))}
      </div>

      {tab === 'overview' && <AdminOverview />}
      {tab === 'pnl'      && <ReportsContent />}
      {tab === 'ledger'   && <FinanceLedgerContent />}
      {tab === 'sales'    && <SalesReportContent />}
      {tab === 'debts'    && <DebtsContent />}
      {tab === 'safes'    && <SafesContent />}
    </div>
  )
}
