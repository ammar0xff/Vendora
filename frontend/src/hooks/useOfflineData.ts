import { useQuery } from '@tanstack/react-query'
import { useOnlineStatus } from './useOnlineStatus'
import { offlineCache } from '../store/offlineCache'

export function useCachedQuery(options: {
  queryKey: string[]
  queryFn: () => Promise<any>
  cacheKey: string
  staleTime?: number
  gcTime?: number
  enabled?: boolean
}) {
  const isOnline = useOnlineStatus()
  const { queryKey, queryFn, cacheKey, staleTime = 30000, gcTime, enabled = true } = options

  return useQuery({
    queryKey,
    queryFn: async () => {
      const data = await queryFn()
      await offlineCache.set(cacheKey, data)
      return data
    },
    placeholderData: () => undefined,
    staleTime,
    gcTime,
    enabled: enabled && isOnline,
    retry: isOnline ? 1 : 0,
  })
}

export async function getCachedOrFetch<T>(cacheKey: string, fetcher: () => Promise<T>): Promise<T> {
  try {
    return await fetcher()
  } catch {
    const cached = await offlineCache.get<T>(cacheKey)
    if (cached) return cached
    throw new Error('No internet and no cached data')
  }
}

export function useOfflineSearch<T>(
  items: T[] | undefined,
  searchTerm: string,
  fields: (keyof T)[]
): T[] {
  if (!items) return []
  if (!searchTerm.trim()) return items
  const q = searchTerm.toLowerCase()
  return items.filter(item =>
    fields.some(field => {
      const val = item[field]
      return val != null && String(val).toLowerCase().includes(q)
    })
  )
}
