import { useEffect } from 'react'

export default function NativeShell() {
  useEffect(() => {
    const cleanups: (() => void)[] = []

    async function initNative() {
      try {
        const { StatusBar, Style } = await import('@capacitor/status-bar')
        await StatusBar.setStyle({ style: Style.Dark })
        await StatusBar.setBackgroundColor({ color: '#1e3a5f' })
      } catch (e) {
        console.warn('StatusBar not available (not running in native app)', e)
      }
      try {
        const { App } = await import('@capacitor/app')
        const { Browser } = await import('@capacitor/browser')
        const { Network } = await import('@capacitor/network')

        const netListener = await Network.addListener('networkStatusChange', () => {})
        cleanups.push(() => netListener.remove())

        const backListener = await App.addListener('backButton', ({ canGoBack }) => {
          if (canGoBack) {
            window.history.back()
          } else {
            App.minimizeApp()
          }
        })
        cleanups.push(() => backListener.remove())

        document.querySelectorAll('a[target="_blank"]').forEach((a) => {
          const handler = (e: Event) => {
            e.preventDefault()
            const href = (a as HTMLAnchorElement).href
            if (href) Browser.open({ url: href })
          }
          a.addEventListener('click', handler)
          cleanups.push(() => a.removeEventListener('click', handler))
        })
      } catch (e) {
        console.warn('Capacitor plugins not available (not running in native app)', e)
      }
    }
    initNative()

    return () => {
      for (const cleanup of cleanups) cleanup()
    }
  }, [])

  return null
}
