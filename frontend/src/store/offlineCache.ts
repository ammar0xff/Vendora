import { get, set, del, keys } from 'idb-keyval'

const CACHE_PREFIX = 'offline-cache:'

export const offlineCache = {
  async set(key: string, data: unknown) {
    await set(CACHE_PREFIX + key, { data, cached_at: Date.now() })
  },

  async get<T>(key: string): Promise<T | null> {
    const entry = await get(CACHE_PREFIX + key)
    if (!entry) return null
    return entry.data as T
  },

  async remove(key: string) {
    await del(CACHE_PREFIX + key)
  },

  async clear() {
    const allKeys = await keys()
    const prefixed = allKeys.filter(k => String(k).startsWith(CACHE_PREFIX))
    await Promise.all(prefixed.map(k => del(k)))
  },
}
