import axios from 'axios'
import { useAuthStore } from '../store/auth'

// VITE_API_URL (no trailing slash) drives the API root when provided; otherwise
// keep the same-origin reverse-proxy path (/api) used by the self-hosted nginx
// and native Capacitor builds (server.url points at the backend). This lets a
// pure-static GitHub Pages build target a separate backend without a proxy.
const apiRoot = (import.meta.env.VITE_API_URL || '').replace(/\/$/, '')
const BASE_URL = apiRoot ? `${apiRoot}/api` : '/api'

const api = axios.create({
  baseURL: BASE_URL,
  timeout: 30_000,
  withCredentials: true,
  xsrfCookieName: 'XSRF-TOKEN',
  xsrfHeaderName: 'X-XSRF-TOKEN',
})

let logoutTimer: ReturnType<typeof setTimeout> | null = null

api.interceptors.request.use((config) => {
  const { token } = useAuthStore.getState()
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

api.interceptors.response.use(
  (r) => r,
  (err) => {
    if (err.response?.status === 401 && !err.config?.url?.includes('/auth/')) {
      if (!logoutTimer) {
        logoutTimer = setTimeout(() => { logoutTimer = null }, 1000)
        useAuthStore.getState().logout()
      }
    }
    return Promise.reject(err)
  }
)

export default api
