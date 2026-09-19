import { Outlet } from 'react-router-dom'
import SectionTabs from '../../components/ui/SectionTabs'
import { Save, Palette } from 'lucide-react'

const TABS = [
  { path: '/settings/general', label: 'إعدادات المتجر', icon: Save },
  { path: '/settings/appearance', label: 'الواجهة والمظهر', icon: Palette },
]

export default function SettingsLayout() {
  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">الإعدادات</h1>
      </div>
      <SectionTabs tabs={TABS} />
      <Outlet />
    </div>
  )
}