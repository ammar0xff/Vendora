import { NavLink } from 'react-router-dom'
import type { LucideIcon } from 'lucide-react'

export interface SectionTabItem {
  path: string
  label: string
  icon?: LucideIcon
}

export default function SectionTabs({ tabs }: { tabs: SectionTabItem[] }) {
  return (
    <div className="flex gap-0 mb-6 border-b border-slate-200 overflow-x-auto" style={{ WebkitOverflowScrolling: 'touch' }}>
      {tabs.map(t => {
        const Icon = t.icon
        return (
          <NavLink
            key={t.path}
            to={t.path}
            className={({ isActive }) =>
              `flex items-center gap-2 px-5 py-3 text-sm font-semibold border-b-2 -mb-px whitespace-nowrap flex-shrink-0 transition-all ${
                isActive ? 'border-[var(--primary)] text-[var(--primary)]' : 'border-transparent text-slate-500 hover:text-slate-700'
              }`}
          >
            {Icon && <Icon size={16} />}
            {t.label}
          </NavLink>
        )
      })}
    </div>
  )
}