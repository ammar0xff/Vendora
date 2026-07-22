import { useEffect, useState } from 'react'
import { useOfflineStore } from '../store/offline'

const isCapacitor = typeof window !== 'undefined' &&
  (window.location.protocol === 'capacitor:' || window.location.protocol === 'ionic:')

export function useOnlineStatus() {
  const storeOnline = useOfflineStore(s => s.isOnline)
  const setOnline = useOfflineStore(s => s.setOnline)
  const [networkStatus, setNetworkStatus] = useState<'online' | 'offline' | 'unknown'>(
    navigator.onLine ? 'online' : 'offline'
  )

  useEffect(() => {
    const goOnline = () => { setOnline(true); setNetworkStatus('online') }
    const goOffline = () => { setOnline(false); setNetworkStatus('offline') }

    window.addEventListener('online', goOnline)
    window.addEventListener('offline', goOffline)

    let removeNetworkListener: (() => void) | undefined
    let cancelled = false

    if (isCapacitor) {
      import('@capacitor/network').then(({ Network }) => {
        Network.getStatus().then(s => {
          if (!cancelled) {
            setOnline(s.connected)
            setNetworkStatus(s.connected ? 'online' : 'offline')
          }
        })
        Network.addListener('networkStatusChange', (s) => {
          if (!cancelled) {
            setOnline(s.connected)
            setNetworkStatus(s.connected ? 'online' : 'offline')
          }
        }).then(l => { if (!cancelled) removeNetworkListener = l.remove })
      }).catch((e) => console.warn('Capacitor Network plugin not available', e))
    }

    return () => {
      cancelled = true
      window.removeEventListener('online', goOnline)
      window.removeEventListener('offline', goOffline)
      removeNetworkListener?.()
    }
  }, [setOnline])

  return storeOnline
}

export function useNetworkType() {
  return useOnlineStatus()
}
