import { describe, it, expect, beforeEach, vi } from 'vitest'
import { useOfflineStore } from '../offline'

beforeEach(() => {
  useOfflineStore.setState({ isOnline: true, queue: [] })
  localStorage.clear()
  vi.restoreAllMocks()
})

describe('offline store', () => {
  it('starts online by default', () => {
    expect(useOfflineStore.getState().isOnline).toBe(true)
  })

  it('setOnline updates online status', () => {
    useOfflineStore.getState().setOnline(false)
    expect(useOfflineStore.getState().isOnline).toBe(false)
    useOfflineStore.getState().setOnline(true)
    expect(useOfflineStore.getState().isOnline).toBe(true)
  })

  it('enqueue adds a pending operation', () => {
    const op = { method: 'POST', url: '/sales', data: { total: 100 }, label: 'POST /sales' }
    useOfflineStore.getState().enqueue(op)

    const queue = useOfflineStore.getState().queue
    expect(queue).toHaveLength(1)
    expect(queue[0].method).toBe('POST')
    expect(queue[0].url).toBe('/sales')
    expect(queue[0].data).toEqual({ total: 100 })
    expect(queue[0].label).toBe('POST /sales')
    expect(queue[0].status).toBe('pending')
    expect(queue[0].id).toBeDefined()
    expect(queue[0].created_at).toBeGreaterThan(0)
  })

  it('enqueue generates unique IDs', () => {
    useOfflineStore.getState().enqueue({ method: 'POST', url: '/a', data: null, label: 'a' })
    useOfflineStore.getState().enqueue({ method: 'POST', url: '/b', data: null, label: 'b' })

    const ids = useOfflineStore.getState().queue.map(q => q.id)
    expect(ids[0]).not.toBe(ids[1])
  })

  it('dequeue removes an operation by id', () => {
    useOfflineStore.getState().enqueue({ method: 'POST', url: '/test', data: null, label: 'test' })
    const id = useOfflineStore.getState().queue[0].id

    useOfflineStore.getState().dequeue(id)
    expect(useOfflineStore.getState().queue).toHaveLength(0)
  })

  it('dequeue does nothing for unknown id', () => {
    useOfflineStore.getState().enqueue({ method: 'POST', url: '/test', data: null, label: 'test' })
    useOfflineStore.getState().dequeue('nonexistent')
    expect(useOfflineStore.getState().queue).toHaveLength(1)
  })

  it('markFailed updates status and error', () => {
    useOfflineStore.getState().enqueue({ method: 'POST', url: '/test', data: null, label: 'test' })
    const id = useOfflineStore.getState().queue[0].id

    useOfflineStore.getState().markFailed(id, 'Network timeout')
    const op = useOfflineStore.getState().queue[0]
    expect(op.status).toBe('failed')
    expect(op.error).toBe('Network timeout')
  })

  it('markSyncing updates status to syncing', () => {
    useOfflineStore.getState().enqueue({ method: 'POST', url: '/test', data: null, label: 'test' })
    const id = useOfflineStore.getState().queue[0].id

    useOfflineStore.getState().markSyncing(id)
    expect(useOfflineStore.getState().queue[0].status).toBe('syncing')
  })

  it('clearAll empties the queue', () => {
    useOfflineStore.getState().enqueue({ method: 'POST', url: '/a', data: null, label: 'a' })
    useOfflineStore.getState().enqueue({ method: 'POST', url: '/b', data: null, label: 'b' })
    expect(useOfflineStore.getState().queue).toHaveLength(2)

    useOfflineStore.getState().clearAll()
    expect(useOfflineStore.getState().queue).toHaveLength(0)
  })

  it('handles multiple operations in order', () => {
    useOfflineStore.getState().enqueue({ method: 'POST', url: '/first', data: { n: 1 }, label: 'first' })
    useOfflineStore.getState().enqueue({ method: 'PUT', url: '/second', data: { n: 2 }, label: 'second' })
    useOfflineStore.getState().enqueue({ method: 'DELETE', url: '/third', data: null, label: 'third' })

    const queue = useOfflineStore.getState().queue
    expect(queue).toHaveLength(3)
    expect(queue[0].url).toBe('/first')
    expect(queue[1].url).toBe('/second')
    expect(queue[2].url).toBe('/third')

    useOfflineStore.getState().dequeue(queue[1].id)
    expect(useOfflineStore.getState().queue).toHaveLength(2)
    expect(useOfflineStore.getState().queue[0].url).toBe('/first')
    expect(useOfflineStore.getState().queue[1].url).toBe('/third')
  })

  it('persists state to localStorage', () => {
    const storeKey = 'offline-queue'
    useOfflineStore.getState().enqueue({ method: 'POST', url: '/persist-test', data: { x: 1 }, label: 'persist' })

    const saved = JSON.parse(localStorage.getItem(storeKey) || '{}')
    expect(saved.state.queue).toHaveLength(1)
    expect(saved.state.queue[0].url).toBe('/persist-test')
    expect(saved.state.queue[0].data).toEqual({ x: 1 })
  })
})
