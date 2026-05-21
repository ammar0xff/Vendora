import { create } from 'zustand'

interface User { id: string; username: string; full_name: string; role: string; is_manager?: boolean; permissions?: string[] }
interface AuthState {
  token: string | null
  user: User | null
  csrfToken: string | null
  login: (token: string, user: User, csrfToken?: string) => void
  setCsrf: (csrf: string) => void
  logout: () => void
}

export const useAuthStore = create<AuthState>()(
  (set) => ({
    token: null,
    user: null,
    csrfToken: null,
    login: (token, user, csrfToken) => set({ token, user, csrfToken }),
    setCsrf: (csrfToken) => set({ csrfToken }),
    logout: () => { set({ token: null, user: null, csrfToken: null }); window.location.href = '/login' },
  })
)
