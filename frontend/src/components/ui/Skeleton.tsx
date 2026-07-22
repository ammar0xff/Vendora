export function Skeleton({ className = '' }: { className?: string }) {
  return <div className={`animate-pulse rounded-2xl bg-slate-200 ${className}`} />
}
export function SkeletonRow() {
  return (
    <div className="flex items-center gap-3 p-3">
      <Skeleton className="w-8 h-8 rounded-lg flex-shrink-0" />
      <div className="flex-1 space-y-2">
        <Skeleton className="h-3 w-40" />
        <Skeleton className="h-2.5 w-24" />
      </div>
      <Skeleton className="h-6 w-16" />
      <Skeleton className="h-6 w-20" />
      <Skeleton className="h-6 w-20" />
    </div>
  )
}
export function SkeletonSidebar() {
  return (
    <div className="flex flex-col gap-2 p-3">
      <Skeleton className="h-3 w-16 mb-2" />
      {Array.from({ length: 8 }).map((_, i) => (
        <Skeleton key={i} className={`h-8 ${i % 3 === 0 ? 'w-full' : 'w-4/5'}`} />
      ))}
    </div>
  )
}
