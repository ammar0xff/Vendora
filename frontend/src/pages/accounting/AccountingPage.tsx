/**
 * AccountingPage — unified accounting hub
 * Tabs: Dashboard | Income Statement | Financial Ledger | Sales | Debts
 */
import { useState, useMemo } from 'react'
import { useAppStore } from '../../store/app'
import { useAuthStore } from '../../store/auth'
import AdminOverview from '../admin/AdminPage'
import ReportsContent from './ReportsContent'
import FinanceLedgerContent from './FinanceLedgerContent'
import SalesReportContent from './SalesReportContent'
import DebtsContent from './DebtsContent'
import SafesContent from './SafesContent'
import ReportsPage from '../reports/ReportsPage'

const TABS = [
  { id: 'overview',  label: '📊 لوحة التحكم',      roles: ['admin','manager'] },
  { id: 'pnl',       label: '📈 قائمة الدخل',       roles: ['admin','manager','accountant'] },
  { id: 'ledger',    label: '⚖️ الميزان المالي',    roles: ['admin','manager','accountant'] },
  { id: 'reports',   label: '📒 دفتر الأستاذ',      roles: ['admin','manager','accountant'] },
  { id: 'sales',     label: '🧾 تقارير المبيعات',   roles: ['admin','manager','accountant','cashier'] },
  { id: 'debts',     label: '💳 المديونيات',         roles: ['admin','manager','accountant'] },
  { id: 'safes',     label: '🏦 الخزنات',            roles: ['admin','manager','accountant'] },
]

export default function AccountingPage() {
  const { activeWarehouseId } = useAppStore()
  const user = useAuthStore(s => s.user)
  const visibleTabs = useMemo(() => TABS.filter(t => t.roles.includes(user?.role || '')), [user?.role])
  const [tab, setTab] = useState(visibleTabs[0]?.id || 'overview')
  const activeTab = visibleTabs.some(t => t.id === tab) ? tab : visibleTabs[0]?.id || 'overview'

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
        {visibleTabs.map(t => (
          <button key={t.id} onClick={() => setTab(t.id)}
            className={`px-5 py-3 text-sm font-semibold border-b-2 -mb-px whitespace-nowrap transition-all flex-shrink-0
              ${activeTab === t.id ? 'border-blue-600 text-blue-700' : 'border-transparent text-slate-500 hover:text-slate-700'}`}>
            {t.label}
          </button>
        ))}
      </div>

      {activeTab === 'overview' && <AdminOverview />}
      {activeTab === 'pnl'      && <ReportsContent />}
      {activeTab === 'ledger'   && <FinanceLedgerContent />}
      {activeTab === 'reports'  && <ReportsPage />}
      {activeTab === 'sales'    && <SalesReportContent />}
      {activeTab === 'debts'    && <DebtsContent />}
      {activeTab === 'safes'    && <SafesContent />}
    </div>
  )
}
