import { Outlet } from 'react-router-dom'
import SectionTabs from '../../components/ui/SectionTabs'

const TABS = [
  { path: '/accounting/pnl', label: 'قائمة الدخل' },
  { path: '/accounting/ledger', label: 'الميزان المالي' },
  { path: '/accounting/ledger-book', label: 'دفتر الأستاذ' },
  { path: '/accounting/stats', label: 'الإحصائيات' },
  { path: '/accounting/sales', label: 'تقارير المبيعات' },
  { path: '/accounting/debts', label: 'المديونيات' },
]

export default function AccountingLayout() {
  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">الحسابات</h1>
      </div>
      <SectionTabs tabs={TABS} />
      <Outlet />
    </div>
  )
}