import { AlertTriangle } from 'lucide-react'
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
  loading?: boolean
}

export default function ConfirmDialog({ open, onClose, onConfirm, title, message, confirmText = 'تأكيد', cancelText = 'إلغاء', danger = false, loading = false }: Props) {
  return (
    <Modal open={open} onClose={loading ? () => {} : onClose} title={title || 'تأكيد'} size="sm"
      footer={
        <div className="flex gap-3 pt-4">
          <button onClick={onClose} disabled={loading}
            className="flex-1 py-2.5 rounded-xl text-sm font-bold text-slate-600 bg-slate-100 hover:bg-slate-200 transition-colors disabled:opacity-50">
            {cancelText}
          </button>
          <button onClick={() => { onConfirm(); if (!loading) onClose() }}
            disabled={loading}
            className={`flex-1 py-2.5 rounded-xl text-sm font-bold text-white transition-colors disabled:opacity-50 ${danger ? 'bg-red-600 hover:bg-red-700' : 'bg-blue-600 hover:bg-blue-700'}`}>
            {loading ? 'جاري...' : confirmText}
          </button>
        </div>
      }>
      {danger && (
        <div className="flex flex-col items-center gap-2 mb-3">
          <div className="w-10 h-10 rounded-full bg-red-50 flex items-center justify-center">
            <AlertTriangle size={20} className="text-red-500" />
          </div>
        </div>
      )}
      <p className="text-slate-600 text-sm leading-relaxed text-center">{message}</p>
    </Modal>
  )
}
