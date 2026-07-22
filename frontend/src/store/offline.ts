import { create } from 'zustand'
import { persist } from 'zustand/middleware'

export interface QueuedOp {
  id: string
  method: string
  url: string
  data: any
  created_at: number
  label: string
  status: 'pending' | 'syncing' | 'failed'
  error?: string
}

interface OfflineState {
  isOnline: boolean
  queue: QueuedOp[]
  setOnline: (v: boolean) => void
  enqueue: (op: Omit<QueuedOp, 'id' | 'created_at' | 'status'>) => void
  dequeue: (id: string) => void
  markFailed: (id: string, error: string) => void
  markSyncing: (id: string) => void
  clearAll: () => void
}

export const useOfflineStore = create<OfflineState>()(
  persist(
    (set, get) => ({
      isOnline: navigator.onLine,
      queue: [],
      setOnline: (v) => set({ isOnline: v }),
      enqueue: (op) => {
        const id = crypto.randomUUID?.() ?? `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`
        set({ queue: [...get().queue, { ...op, id, created_at: Date.now(), status: 'pending' }] })
      },
      dequeue: (id) => set({ queue: get().queue.filter(q => q.id !== id) }),
      markFailed: (id, error) => set({
        queue: get().queue.map(q => q.id === id ? { ...q, status: 'failed', error } : q)
      }),
      markSyncing: (id) => set({
        queue: get().queue.map(q => q.id === id ? { ...q, status: 'syncing' } : q)
      }),
      clearAll: () => set({ queue: [] }),
    }),
    { name: 'offline-queue' }
  )
)
