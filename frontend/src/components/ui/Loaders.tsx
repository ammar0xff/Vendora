import { Loader2 } from 'lucide-react'

export function Spinner({ size = 20 }: { size?: number }) {
  return <Loader2 size={size} className="animate-spin text-blue-500" />
}

export function PageLoader({ text = 'جاري التحميل...' }: { text?: string }) {
  return (
    <div className="flex items-center justify-center h-64">
      <div className="flex flex-col items-center gap-3">
        <div className="w-10 h-10 border-4 border-slate-200 border-t-blue-600 rounded-full animate-spin" />
        <p className="text-slate-500 text-sm">{text}</p>
      </div>
    </div>
  )
}

export function EmptyState({ message = 'لا توجد بيانات', subtext, icon }: { message?: string; subtext?: string; icon?: string }) {
  return (
    <div className="flex flex-col items-center justify-center py-16 text-slate-400">
      <div className="text-5xl mb-4">{icon || '📭'}</div>
      <p className="text-base font-medium mb-1">{message}</p>
      {subtext && <p className="text-sm text-slate-400">{subtext}</p>}
    </div>
  )
}
