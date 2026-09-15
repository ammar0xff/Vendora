import Modal from './Modal'

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
          <button onClick={onClose}
            className="btn-outline flex-1">
            {cancelText}
          </button>
          <button onClick={() => { onConfirm(); if (closeOnConfirm) onClose() }}
            className={`${danger ? 'btn-danger' : 'btn-primary'} flex-1`}>
            {confirmText}
          </button>
        </div>
      }>
      <p className="text-[var(--text-soft)] text-sm leading-relaxed text-center py-2">{message}</p>
    </Modal>
  )
}