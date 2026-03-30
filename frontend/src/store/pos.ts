import { create } from 'zustand'

interface CartItem {
  product_id: string
  name: string
  qty: number
  unit_price: number
  unit_cost: number
  unit: string
  item_discount: number      // جنيه خصم على الصنف
  item_discount_pct: number  // % خصم على الصنف
}

interface POSState {
  items: CartItem[]
  mode: 'retail' | 'wholesale'
  customer: string
  invoice_discount: number      // خصم على الإجمالي بالجنيه
  invoice_discount_pct: number  // خصم على الإجمالي بالنسبة
  setMode: (m: 'retail' | 'wholesale') => void
  setCustomer: (c: string) => void
  setInvoiceDiscount: (amount: number, pct: number) => void
  addItem: (item: Omit<CartItem, 'qty' | 'item_discount' | 'item_discount_pct'>) => void
  updateQty: (product_id: string, qty: number) => void
  updateItemDiscount: (product_id: string, discount: number, pct: number) => void
  removeItem: (product_id: string) => void
  clear: () => void
  subtotal: () => number   // before invoice discount
  totalDiscount: () => number
  total: () => number      // after all discounts
}

export const usePOSStore = create<POSState>((set, get) => ({
  items: [],
  mode: 'retail',
  customer: '',
  invoice_discount: 0,
  invoice_discount_pct: 0,
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
  removeItem: (product_id) => set({ items: get().items.filter(i => i.product_id !== product_id) }),
  clear: () => set({ items: [], customer: '', invoice_discount: 0, invoice_discount_pct: 0 }),
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
}))
