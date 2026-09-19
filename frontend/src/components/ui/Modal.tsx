import { type ReactNode } from 'react'
import { clsx } from 'clsx'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogClose,
} from './dialog'
import { X } from 'lucide-react'

interface Props {
  open: boolean
  onClose: () => void
  title: string
  children: ReactNode
  footer?: ReactNode
  size?: 'sm' | 'md' | 'lg' | 'xl'
}

const sizes = {
  sm: 'max-w-sm',
  md: 'max-w-lg',
  lg: 'max-w-2xl',
  xl: 'max-w-4xl',
}

export default function Modal({ open, onClose, title, children, footer, size = 'md' }: Props) {
  return (
    <Dialog open={open} onOpenChange={(isOpen) => { if (!isOpen) onClose() }}>
      <DialogContent className={clsx(sizes[size], 'gap-0 p-0')}>
        <DialogHeader className="px-6 pt-6 pb-0">
          <DialogTitle className="text-base font-black">{title}</DialogTitle>
          <DialogDescription className="sr-only">{title}</DialogDescription>
        </DialogHeader>
        <DialogClose onClick={onClose} className="absolute left-4 top-4" aria-label="Close">
          <X size={18} />
        </DialogClose>
        <div className="px-6 py-4">{children}</div>
        {footer && <div className="px-6 pb-6 pt-0">{footer}</div>}
      </DialogContent>
    </Dialog>
  )
}
