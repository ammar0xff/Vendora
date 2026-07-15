import { create } from 'zustand'
import { persist } from 'zustand/middleware'

export interface PurchaseCartItem {
  product_id: string
  name: string
  unit_cost: number
  new_qty: number
  unit: string
  current_stock: number
}

interface PurchaseCartState {
  items: PurchaseCartItem[]
  addItem: (p: { product_id: string; name: string; unit_cost: number; unit: string; current_stock: number }) => void
  updateQty: (product_id: string, qty: number) => void
  updateCost: (product_id: string, cost: number) => void
  removeItem: (product_id: string) => void
  clear: () => void
  totalCost: () => number
}

export const usePurchaseCartStore = create<PurchaseCartState>()(
  persist(
    (set, get) => ({
      items: [],
      addItem: (p) => {
        const existing = get().items.find(i => i.product_id === p.product_id)
        if (existing) return
        set({ items: [...get().items, { ...p, new_qty: p.current_stock + 1 }] })
      },
      updateQty: (product_id, qty) => {
        if (qty <= 0) { get().removeItem(product_id); return }
        set({ items: get().items.map(i => i.product_id === product_id ? { ...i, new_qty: qty } : i) })
      },
      updateCost: (product_id, cost) => {
        set({ items: get().items.map(i => i.product_id === product_id ? { ...i, unit_cost: cost } : i) })
      },
      removeItem: (product_id) => set({ items: get().items.filter(i => i.product_id !== product_id) }),
      clear: () => set({ items: [] }),
      totalCost: () => get().items.reduce((s, i) => s + i.new_qty * i.unit_cost, 0),
    }),
    { name: 'purchase-cart' }
  )
)
