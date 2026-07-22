import { createAsyncStoragePersister } from '@tanstack/query-async-storage-persister'
import { get, set, del } from 'idb-keyval'

export const persister = createAsyncStoragePersister({
  storage: {
    getItem: async (key: string) => {
      const val = await get(key)
      return val ?? null
    },
    setItem: (key: string, value: string) => set(key, value),
    removeItem: (key: string) => del(key),
  },
  throttleTime: 2000,
})
