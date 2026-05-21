import { useOfflineStore } from '../store/offline'
import { usePendingSalesStore } from '../store/pendingSales'
import { useLocalShiftStore } from '../store/localShift'
import { useOnlineStatus } from '../hooks/useOnlineStatus'
import { WifiOff, RefreshCw } from 'lucide-react'

export default function OfflineBanner() {
  const isOnline = useOnlineStatus()
  const queue = useOfflineStore(s => s.queue)
  const pendingSales = usePendingSalesStore(s => s.sales.filter(s => s.status === 'pending').length)
  const localShift = useLocalShiftStore(s => s.shift)

  const hasOfflineData = !isOnline || queue.length > 0 || pendingSales > 0 || localShift !== null

  if (!hasOfflineData) return null

  const pendingCount = queue.filter(q => q.status === 'pending').length
  const failedCount = queue.filter(q => q.status === 'failed').length
  const syncingCount = queue.filter(q => q.status === 'syncing').length

  return (
    <div className={`fixed top-0 left-0 right-0 z-[9999] px-4 py-2 text-sm font-bold text-center flex items-center justify-center gap-2 ${isOnline ? 'bg-amber-50 text-amber-800 border-b border-amber-200' : 'bg-red-50 text-red-700 border-b border-red-200'}`}>
      {isOnline ? (
        <>
          <RefreshCw size={14} className="animate-spin" />
          {syncingCount > 0 && `جاري المزامنة... `}
          {pendingCount > 0 && `${pendingCount} عملية في انتظار المزامنة `}
          {pendingSales > 0 && `${pendingSales} فاتورة محلية `}
          {localShift && `وردية محلية `}
          {failedCount > 0 && `(${failedCount} فشلت)`}
          {pendingCount === 0 && pendingSales === 0 && !localShift && failedCount === 0 && 'جاري المزامنة...'}
        </>
      ) : (
        <>
          <WifiOff size={14} />
          لا يوجد اتصال — سيتم حفظ العمليات محلياً ومزامنتها تلقائياً
          {pendingSales > 0 && ` (${pendingSales} فاتورة محلية)`}
        </>
      )}
    </div>
  )
}
