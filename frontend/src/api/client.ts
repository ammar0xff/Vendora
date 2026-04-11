import axios from 'axios'
import { useAuthStore } from '../store/auth'

// When running as a native Capacitor app, window.location is capacitor://localhost
// so relative /api won't work — use the configured server URL instead.
const isNative = typeof window !== 'undefined' &&
  (window.location.protocol === 'capacitor:' || window.location.protocol === 'ionic:')

const BASE_URL = isNative
  ? (import.meta.env.VITE_API_URL || 'http://192.168.1.50') + '/api'
  : '/api'

const api = axios.create({ baseURL: BASE_URL })

api.interceptors.request.use((config) => {
  const token = useAuthStore.getState().token
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

api.interceptors.response.use(
  (r) => r,
  (err) => {
    if (err.response?.status === 401) useAuthStore.getState().logout()
    return Promise.reject(err)
  }
)

export default api
