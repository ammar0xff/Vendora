import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import { clear as clearIDB } from 'idb-keyval'

interface User { id: string; username: string; full_name: string; role: string; is_manager?: boolean; permissions?: string[] }
interface AuthState {
  token: string | null
  user: User | null
  login: (token: string, user: User) => void
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
      login: (token, user) => set({ token, user }),
      logout: () => {
        set({ token: null, user: null })
        clearCache()
      },
    }),
    { name: 'auth' }
  )
)
