import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'
import NativeShell from './components/NativeShell.tsx'
import toast from 'react-hot-toast'

async function registerPWA() {
  try {
    const { registerSW } = await import('virtual:pwa-register')
    const updateSW = registerSW({
      onNeedRefresh() {
        toast.success('تم تحديث التطبيق')
      },
      onOfflineReady() {
        toast.success('التطبيق جاهز للعمل بدون إنترنت')
      },
    })
  } catch (e) {
    console.warn('vite-plugin-pwa not active (e.g., CI)', e)
  }
}
registerPWA()

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <NativeShell />
    <App />
  </StrictMode>,
)
