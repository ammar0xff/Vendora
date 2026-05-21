import { useEffect } from 'react'

export default function NativeShell() {
  useEffect(() => {
    async function initNative() {
      try {
        const { StatusBar, Style } = await import('@capacitor/status-bar')
        await StatusBar.setStyle({ style: Style.Dark })
        await StatusBar.setBackgroundColor({ color: '#1e3a5f' })
      } catch {
        // not running in native app
      }
      try {
        const { App } = await import('@capacitor/app')
        const { Browser } = await import('@capacitor/browser')
        const { Network } = await import('@capacitor/network')

        Network.addListener('networkStatusChange', () => {})

        App.addListener('backButton', ({ canGoBack }) => {
          if (canGoBack) {
            window.history.back()
          } else {
            App.minimizeApp()
          }
        })

        document.querySelectorAll('a[target="_blank"]').forEach((a) => {
          a.addEventListener('click', (e) => {
            e.preventDefault()
            const href = (a as HTMLAnchorElement).href
            if (href) Browser.open({ url: href })
          })
        })
      } catch {
        // not running in native app
      }
    }
    initNative()
  }, [])

  return null
}
