import axios from 'axios'
import { useAuthStore } from '../store/auth'

const isNative = typeof window !== 'undefined' &&
  (window.location.protocol === 'capacitor:' || window.location.protocol === 'ionic:')

const BASE_URL = isNative
  ? (import.meta.env.VITE_API_URL || '') + '/api'
  : '/api'

const api = axios.create({ baseURL: BASE_URL })

api.interceptors.request.use((config) => {
  const { token } = useAuthStore.getState()
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

api.interceptors.response.use(
  (r) => r,
  (err) => {
    if (err.response?.status === 401 && !err.config?.url?.includes('/auth/')) useAuthStore.getState().logout()
    return Promise.reject(err)
  }
)

export default api
