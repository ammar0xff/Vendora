import axios from 'axios'
import { useAuthStore } from '../store/auth'
import { useOfflineStore } from '../store/offline'

const isNative = typeof window !== 'undefined' &&
  (window.location.protocol === 'capacitor:' || window.location.protocol === 'ionic:')

const BASE_URL = isNative
  ? (import.meta.env.VITE_API_URL || '') + '/api'
  : '/api'

const api = axios.create({ baseURL: BASE_URL })

const MUTATION_METHODS = ['post', 'put', 'patch', 'delete']

const NO_QUEUE_PATTERNS = [
  /\/auth\//,
]

function shouldQueue(method: string, url: string): boolean {
  if (NO_QUEUE_PATTERNS.some(p => p.test(url))) return false
  return MUTATION_METHODS.includes(method.toLowerCase())
}

api.interceptors.request.use((config) => {
  const { csrfToken } = useAuthStore.getState()
  if (csrfToken && config.method && MUTATION_METHODS.includes(config.method)) {
    config.headers['X-CSRF-Token'] = csrfToken
  }
  return config
})

api.interceptors.response.use(
  (r) => r,
  (err) => {
    if (err.response?.status === 401 && !err.config?.url?.includes('/auth/')) useAuthStore.getState().logout()
    if (!err.response && err.message?.includes('Network Error')) {
      const cfg = err.config
      if (cfg && shouldQueue(cfg.method, cfg.url || '')) {
        const label = `${cfg.method?.toUpperCase()} ${cfg.url}`.slice(0, 60)
        useOfflineStore.getState().enqueue({
          method: cfg.method?.toUpperCase() || 'POST',
          url: cfg.url || '',
          data: cfg.data ? (typeof cfg.data === 'string' ? JSON.parse(cfg.data) : cfg.data) : null,
          label,
        })
        return Promise.resolve({ data: { queued: true, label }, status: 202 })
      }
    }
    return Promise.reject(err)
  }
)

export default api
