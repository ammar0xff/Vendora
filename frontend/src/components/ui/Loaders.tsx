import { Loader2 } from 'lucide-react'

export function Spinner({ size = 20 }: { size?: number }) {
  return <Loader2 size={size} className="animate-spin text-blue-500" />
}

export function PageLoader() {
  return (
    <div className="flex items-center justify-center h-64">
      <div className="flex flex-col items-center gap-3">
        <Spinner size={36} />
        <p className="text-slate-500 text-sm">جاري التحميل...</p>
      </div>
    </div>
  )
}

export function EmptyState({ message = 'لا توجد بيانات', icon }: { message?: string; icon?: string }) {
  return (
    <div className="flex flex-col items-center justify-center py-16 text-slate-400">
      <div className="text-5xl mb-4">{icon || '📭'}</div>
      <p className="text-base font-medium">{message}</p>
    </div>
  )
}
