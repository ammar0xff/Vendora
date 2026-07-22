import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'
import toast from 'react-hot-toast'

async function registerPWA() {
  try {
    const { registerSW } = await import('virtual:pwa-register')
    registerSW({
      onNeedRefresh() { toast.success('تم تحديث التطبيق') },
      onOfflineReady() { toast.success('التطبيق جاهز للعمل بدون إنترنت') },
    })
  } catch (e) {
    console.warn('vite-plugin-pwa not active (e.g., CI)', e)
  }
}

async function bootstrap() {
  const isNative = window.location.protocol === 'capacitor:' || window.location.protocol === 'ionic:'
  const isDesktop = '__TAURI__' in window
  await registerPWA()
  if (isNative) {
    const { registerForPushNotifications } = await import('./utils/pushNotifications')
    await registerForPushNotifications()
  }
  if (isNative) {
    const { default: NativeShell } = await import('./components/NativeShell')
    const shell = document.createElement('div')
    document.body.appendChild(shell)
    createRoot(shell).render(<NativeShell />)
  }
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)

bootstrap()
