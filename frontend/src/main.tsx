import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'

async function registerPWA() {
  try {
    const { registerSW } = await import(/* @vite-ignore */ 'virtual:pwa-register')
    const updateSW = registerSW({
      onNeedRefresh() {
        updateSW()
      },
      onOfflineReady() {
        console.log('التطبيق جاهز للعمل بدون إنترنت')
      },
    })
  } catch {
    // vite-plugin-pwa not active (e.g., CI)
  }
}
registerPWA()

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
