import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import { clear as clearIDB } from 'idb-keyval'

interface User { id: string; username: string; full_name: string; role: string; is_manager?: boolean; permissions?: string[] }
interface AuthState {
  token: string | null
  user: User | null
  csrfToken: string | null
  login: (token: string, user: User, csrfToken?: string) => void
  setCsrf: (csrf: string) => void
  logout: () => void
}

const PERSIST_KEYS = ['auth', 'app-settings', 'offline-queue', 'pending-sales', 'local-shift', 'pos-cart']

function clearCache() {
  for (const key of PERSIST_KEYS) localStorage.removeItem(key)
  clearIDB().catch((e) => console.warn('Failed to clear idb-keyval cache', e))
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      token: null,
      user: null,
      csrfToken: null,
      login: (token, user, csrfToken) => set({ token, user, csrfToken }),
      setCsrf: (csrfToken) => set({ csrfToken }),
      logout: () => {
        set({ token: null, user: null, csrfToken: null })
        clearCache()
      },
    }),
    { name: 'auth' }
  )
)
