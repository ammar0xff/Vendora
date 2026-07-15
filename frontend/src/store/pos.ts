import { create } from 'zustand'
import { persist } from 'zustand/middleware'

export interface CartItem {
  product_id: string
  name: string
  qty: number
  unit_price: number
  unit_cost: number
  unit: string
  item_discount: number
  item_discount_pct: number
}

export interface HeldBill {
  id: string
  label: string
  items: CartItem[]
  created_at: number
  warehouse_id?: string
  shift_id?: string
  customer?: string
  invoice_discount?: number
  invoice_discount_pct?: number
}

interface POSState {
  items: CartItem[]
  mode: 'retail' | 'wholesale'
  customer: string
  invoice_discount: number
  invoice_discount_pct: number
  suspended: HeldBill[]

  setMode: (m: 'retail' | 'wholesale') => void
  setCustomer: (c: string) => void
  setInvoiceDiscount: (amount: number, pct: number) => void
  addItem: (item: Omit<CartItem, 'qty' | 'item_discount' | 'item_discount_pct'>) => void
  updateQty: (product_id: string, qty: number) => void
  updateItemDiscount: (product_id: string, discount: number, pct: number) => void
  updatePrice: (product_id: string, price: number) => void
  removeItem: (product_id: string) => void
  clear: () => void
  holdCurrent: (opts?: { label?: string; warehouse_id?: string; shift_id?: string }) => void
  resume: (id: string) => void
  deleteHeld: (id: string) => void
  subtotal: () => number
  totalDiscount: () => number
  total: () => number
}

export const usePOSStore = create<POSState>()(
  persist(
    (set, get) => ({
      items: [],
      mode: 'retail',
      customer: '',
      invoice_discount: 0,
      invoice_discount_pct: 0,
      suspended: [],

      setMode: (mode) => set({ mode }),
      setCustomer: (customer) => set({ customer }),
      setInvoiceDiscount: (invoice_discount, invoice_discount_pct) => set({ invoice_discount, invoice_discount_pct }),

      addItem: (item) => {
        const existing = get().items.find(i => i.product_id === item.product_id)
        if (existing) {
          set({ items: get().items.map(i => i.product_id === item.product_id ? { ...i, qty: i.qty + 1 } : i) })
        } else {
          set({ items: [...get().items, { ...item, qty: 1, item_discount: 0, item_discount_pct: 0 }] })
        }
      },

      updateQty: (product_id, qty) => {
        if (qty <= 0) { get().removeItem(product_id); return }
        set({ items: get().items.map(i => i.product_id === product_id ? { ...i, qty } : i) })
      },

      updateItemDiscount: (product_id, discount, pct) => {
        set({ items: get().items.map(i => i.product_id === product_id ? { ...i, item_discount: discount, item_discount_pct: pct } : i) })
      },

      updatePrice: (product_id, price) => {
        set({ items: get().items.map(i => i.product_id === product_id ? { ...i, unit_price: price, item_discount: 0, item_discount_pct: 0 } : i) })
      },

      removeItem: (product_id) => set({ items: get().items.filter(i => i.product_id !== product_id) }),

      clear: () => set({ items: [], customer: '', invoice_discount: 0, invoice_discount_pct: 0 }),

      holdCurrent: (opts) => {
        const state = get()
        const bill: HeldBill = {
          id: crypto.randomUUID?.() || String(Date.now()),
          label: opts?.label || `فاتورة #${state.suspended.length + 1}`,
          items: [...state.items],
          created_at: Date.now(),
          warehouse_id: opts?.warehouse_id,
          shift_id: opts?.shift_id,
          customer: state.customer || undefined,
          invoice_discount: state.invoice_discount,
          invoice_discount_pct: state.invoice_discount_pct,
        }
        set({ suspended: [...state.suspended, bill], items: [], customer: '', invoice_discount: 0, invoice_discount_pct: 0 })
      },

      resume: (id) => {
        const state = get()
        const bill = state.suspended.find(b => b.id === id)
        if (!bill) return
        set({
          items: bill.items,
          suspended: state.suspended.filter(b => b.id !== id),
          customer: bill.customer || '',
          invoice_discount: bill.invoice_discount || 0,
          invoice_discount_pct: bill.invoice_discount_pct || 0,
        })
      },

      deleteHeld: (id) => set({ suspended: get().suspended.filter(b => b.id !== id) }),

      subtotal: () => get().items.reduce((s, i) => {
        const lineTotal = i.qty * i.unit_price
        const itemDisc = i.item_discount_pct > 0 ? lineTotal * (i.item_discount_pct / 100) : i.item_discount
        return s + lineTotal - itemDisc
      }, 0),

      totalDiscount: () => {
        const sub = get().subtotal()
        const { invoice_discount, invoice_discount_pct } = get()
        return invoice_discount_pct > 0 ? sub * (invoice_discount_pct / 100) : invoice_discount
      },

      total: () => Math.max(0, get().subtotal() - get().totalDiscount()),
    }),
    { name: 'pos-cart' }
  )
)
