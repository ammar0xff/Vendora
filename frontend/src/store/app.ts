import { create } from 'zustand'
import { persist } from 'zustand/middleware'

interface AppState {
  activeWarehouseId: string | null
  activeWarehouseName: string | null
  setActiveWarehouse: (id: string, name: string) => void
}

export const useAppStore = create<AppState>()(
  persist(
    (set) => ({
      activeWarehouseId: null,
      activeWarehouseName: null,
      setActiveWarehouse: (id, name) => set({ activeWarehouseId: id, activeWarehouseName: name }),
    }),
    { name: 'app-settings' }
  )
)
