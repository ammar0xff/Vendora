import { create } from 'zustand'
import { persist } from 'zustand/middleware'

export interface PendingSaleItem {
  product_id: string
  name: string
  qty: number
  unit_price: number
  unit_cost: number
  discount: number
}

export interface PendingSale {
  id: string
  local_id: string
  created_at: number
  warehouse_id: string
  warehouse_name: string
  sale_mode: 'retail' | 'wholesale'
  is_credit: boolean
  customer_id?: string | null
  customer_name?: string | null
  discount_amount: number
  payment_method: string
  wallet_id?: string
  items: PendingSaleItem[]
  total: number
  status: 'pending' | 'syncing' | 'synced' | 'failed'
  server_id?: string
  error?: string
}

interface PendingSalesState {
  sales: PendingSale[]
  addSale: (sale: Omit<PendingSale, 'id' | 'created_at' | 'status'>) => void
  markSynced: (local_id: string, server_id: string) => void
  markFailed: (local_id: string, error: string) => void
  markSyncing: (local_id: string) => void
  removeSale: (local_id: string) => void
  clearAll: () => void
}

export const usePendingSalesStore = create<PendingSalesState>()(
  persist(
    (set, get) => ({
      sales: [],
      addSale: (sale) => {
        const id = crypto.randomUUID?.() || String(Date.now())
        set({ sales: [...get().sales, { ...sale, id, created_at: Date.now(), status: 'pending' }] })
      },
      markSynced: (local_id, server_id) => set({
        sales: get().sales.map(s => s.id === local_id ? { ...s, status: 'synced', server_id } : s),
      }),
      markFailed: (local_id, error) => set({
        sales: get().sales.map(s => s.id === local_id ? { ...s, status: 'failed', error } : s),
      }),
      markSyncing: (local_id) => set({
        sales: get().sales.map(s => s.id === local_id ? { ...s, status: 'syncing' } : s),
      }),
      removeSale: (local_id) => set({
        sales: get().sales.filter(s => s.id !== local_id),
      }),
      clearAll: () => set({ sales: [] }),
    }),
    { name: 'pending-sales' }
  )
)
