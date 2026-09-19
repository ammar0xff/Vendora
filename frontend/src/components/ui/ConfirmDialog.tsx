import Modal from './Modal'
import { Button } from './button'

interface Props {
  open: boolean
  onClose: () => void
  onConfirm: () => void
  title?: string
  message: string
  confirmText?: string
  cancelText?: string
  danger?: boolean
  closeOnConfirm?: boolean
}

export default function ConfirmDialog({ open, onClose, onConfirm, title, message, confirmText = 'تأكيد', cancelText = 'إلغاء', danger = false, closeOnConfirm = true }: Props) {
  return (
    <Modal open={open} onClose={onClose} title={title || 'تأكيد'} size="sm"
      footer={
        <div className="flex gap-3 pt-1 w-full">
          <Button variant="outline" className="flex-1" onClick={onClose}>
            {cancelText}
          </Button>
          <Button variant={danger ? 'destructive' : 'default'} className="flex-1" onClick={() => { onConfirm(); if (closeOnConfirm) onClose() }}>
            {confirmText}
          </Button>
        </div>
      }>
      <p className="text-[var(--text-soft)] text-sm leading-relaxed text-center py-2">{message}</p>
    </Modal>
  )
}