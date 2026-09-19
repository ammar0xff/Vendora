import { Outlet } from 'react-router-dom'
import SectionTabs from '../../components/ui/SectionTabs'

const TABS = [
  { path: '/operations/ops', label: 'العمليات والنقل' },
  { path: '/operations/purchases', label: 'فواتير المشتريات' },
]

export default function OperationsLayout() {
  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">المشتريات والعمليات</h1>
      </div>
      <SectionTabs tabs={TABS} />
      <Outlet />
    </div>
  )
}