import { create } from 'zustand'
import { persist } from 'zustand/middleware'

interface LocalShift {
  id: string
  warehouse_id: string
  warehouse_name: string
  initial_amount: number
  cashier_id: string
  cashier_name: string
  supervisor_id?: string | null
  opened_at: number
}

interface LocalShiftState {
  shift: LocalShift | null
  openShift: (shift: LocalShift) => void
  closeShift: () => void
}

export const useLocalShiftStore = create<LocalShiftState>()(
  persist(
    (set) => ({
      shift: null,
      openShift: (shift) => set({ shift }),
      closeShift: () => set({ shift: null }),
    }),
    { name: 'local-shift' }
  )
)
