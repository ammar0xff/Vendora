import { X } from 'lucide-react'
import { type ReactNode } from 'react'
import { clsx } from 'clsx'

interface Props {
  open: boolean
  onClose: () => void
  title: string
  children: ReactNode
  footer?: ReactNode
  size?: 'sm' | 'md' | 'lg' | 'xl'
}

const sizes = { sm: 'max-w-sm', md: 'max-w-lg', lg: 'max-w-2xl', xl: 'max-w-4xl' }

export default function Modal({ open, onClose, title, children, footer, size = 'md' }: Props) {
  if (!open) return null
  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className={clsx('modal', sizes[size])} onClick={e => e.stopPropagation()}>
        <div className="modal-header">
          <h2 className="text-lg font-bold text-slate-800">{title}</h2>
          <button onClick={onClose} className="btn-ghost btn-sm rounded-lg p-1.5"><X size={18} /></button>
        </div>
        <div className="modal-body">{children}</div>
        {footer && <div className="modal-footer">{footer}</div>}
      </div>
    </div>
  )
}
