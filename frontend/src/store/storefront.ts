import { create } from 'zustand'
import { persist } from 'zustand/middleware'

export interface StorefrontCartItem {
  product_id: string
  name: string
  unit_price: number
  qty: number
  image_url?: string | null
  unit?: string
}

interface StorefrontState {
  cart: StorefrontCartItem[]
  wishlist: string[]
  isCartOpen: boolean
  addToCart: (item: StorefrontCartItem) => void
  updateQty: (product_id: string, qty: number) => void
  removeFromCart: (product_id: string) => void
  clearCart: () => void
  toggleWishlist: (product_id: string) => void
  openCart: () => void
  closeCart: () => void
}

export const useStorefrontStore = create<StorefrontState>()(
  persist(
    (set, get) => ({
      cart: [],
      wishlist: [],
      isCartOpen: false,

      addToCart: (item) => {
        const existing = get().cart.find((i) => i.product_id === item.product_id)
        if (existing) {
          set({ cart: get().cart.map((i) => (i.product_id === item.product_id ? { ...i, qty: i.qty + (item.qty || 0) } : i)) })
        } else {
          set({ cart: [...get().cart, { ...item, qty: item.qty || 1 }] })
        }
        set({ isCartOpen: true })
      },

      updateQty: (product_id, qty) =>
        set({ cart: qty <= 0 ? get().cart.filter((i) => i.product_id !== product_id) : get().cart.map((i) => (i.product_id === product_id ? { ...i, qty } : i)) }),

      removeFromCart: (product_id) => set({ cart: get().cart.filter((i) => i.product_id !== product_id) }),
      clearCart: () => set({ cart: [] }),

      toggleWishlist: (product_id) =>
        set({ wishlist: get().wishlist.includes(product_id) ? get().wishlist.filter((id) => id !== product_id) : [...get().wishlist, product_id] }),

      openCart: () => set({ isCartOpen: true }),
      closeCart: () => set({ isCartOpen: false }),
    }),
    {
      name: 'storefront',
      partialize: (s) => ({ cart: s.cart, wishlist: s.wishlist }) as StorefrontState,
    }
  )
)
