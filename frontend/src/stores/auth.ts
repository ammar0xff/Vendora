import { create } from "zustand";

export type Role = "admin" | "manager" | "cashier" | "storekeeper" | "accountant";

export interface User {
  id: string;
  username: string;
  full_name: string;
  role: Role;
  permissions: string[];
  is_manager: boolean;
  default_warehouse_id: string | null;
}

interface AuthState {
  token: string | null;
  user: User | null;
  login: (token: string, user: User) => void;
  setUser: (user: User) => void;
  logout: () => void;
  can: (perm: string) => boolean;
}

const KEY = "vendora.session";

function load(): { token: string | null; user: User | null } {
  try {
    const raw = localStorage.getItem(KEY);
    if (raw) return JSON.parse(raw);
  } catch {
    /* corrupted session — start fresh */
  }
  return { token: null, user: null };
}

export const useAuth = create<AuthState>((set, get) => ({
  ...load(),
  login: (token, user) => {
    localStorage.setItem(KEY, JSON.stringify({ token, user }));
    set({ token, user });
  },
  setUser: (user) => {
    const token = get().token;
    if (token) localStorage.setItem(KEY, JSON.stringify({ token, user }));
    set({ user });
  },
  logout: () => {
    localStorage.removeItem(KEY);
    set({ token: null, user: null });
  },
  can: (perm) => {
    const u = get().user;
    return !!u && u.permissions.includes(perm);
  },
}));
