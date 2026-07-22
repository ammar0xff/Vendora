import { useEffect, useRef } from 'react'
import { useQueryClient } from '@tanstack/react-query'
import { useOfflineStore } from '../store/offline'
import { usePendingSalesStore } from '../store/pendingSales'
import { useOnlineStatus } from '../hooks/useOnlineStatus'
import api from '../api/client'
import { shiftsApi } from '../api/endpoints'
import toast from 'react-hot-toast'

export default function OfflineSync() {
  const isOnline = useOnlineStatus()
  const queueLen = useOfflineStore(s => s.queue.length)
  const dequeue = useOfflineStore(s => s.dequeue)
  const markFailed = useOfflineStore(s => s.markFailed)
  const markSyncing = useOfflineStore(s => s.markSyncing)
  const qc = useQueryClient()
  const syncingRef = useRef(false)

  useEffect(() => {
    if (!isOnline || syncingRef.current) return
    syncingRef.current = true

    ;(async () => {
      try {
        // Sequential: shift first, then sales, then legacy queue — prevents race conditions
        await syncLocalShift()
        await syncPendingSales()
        await syncLegacyQueue()
      } finally {
        syncingRef.current = false
      }
    })()

    async function syncLegacyQueue() {
      const pending = useOfflineStore.getState().queue.filter(q => q.status === 'pending')
      if (pending.length === 0) return
      let success = 0
      let fail = 0
      for (const op of pending) {
        markSyncing(op.id)
        try {
          const method = op.method.toLowerCase() as 'post' | 'put' | 'patch' | 'delete'
          await (api as any)[method](op.url, op.data)
          dequeue(op.id)
          success++
        } catch (err: any) {
          if (err.response?.status === 409 || err.response?.status === 400) {
            dequeue(op.id)
            success++
            continue
          }
          markFailed(op.id, err.response?.data?.detail || err.message || 'فشل المزامنة')
          fail++
        }
        await new Promise(r => setTimeout(r, 500))
      }
      qc.invalidateQueries()
      if (fail === 0 && success > 0) {
        toast.success(`تمت مزامنة ${success} عملية`)
      } else if (fail > 0) {
        toast.error(`تمت مزامنة ${success} عملية — فشلت ${fail} عملية`)
      }
    }

    async function syncPendingSales() {
      const pendingSales = usePendingSalesStore.getState().sales.filter(s => s.status === 'pending')
      if (pendingSales.length === 0) return
      let success = 0
      let fail = 0
      for (const sale of pendingSales) {
        usePendingSalesStore.getState().markSyncing(sale.id)
        try {
          const res = await api.post('/sales', {
            warehouse_id: sale.warehouse_id,
            sale_mode: sale.sale_mode,
            is_credit: sale.is_credit,
            customer_id: sale.customer_id || null,
            discount_amount: sale.discount_amount,
            payment_method: sale.payment_method,
            wallet_id: sale.wallet_id || undefined,
            local_id: sale.id,
            items: sale.items.map(i => ({
              product_id: i.product_id,
              qty: i.qty,
              unit_price: i.unit_price,
              unit_cost: i.unit_cost,
              discount: i.discount,
            })),
          })
          usePendingSalesStore.getState().markSynced(sale.id, res.data.id)
          success++
        } catch (err: any) {
          const detail = err.response?.data?.detail || err.message || 'فشل'
          if (err.response?.status === 409) {
            usePendingSalesStore.getState().markFailed(sale.id, detail)
            toast.error(`⚠️ تعارض: ${sale.customer_name || 'فاتورة'} — ${detail}`, { duration: 6000 })
          } else if (err.response?.status === 400) {
            usePendingSalesStore.getState().markFailed(sale.id, detail)
          } else {
            usePendingSalesStore.getState().markFailed(sale.id, detail)
          }
          fail++
        }
        await new Promise(r => setTimeout(r, 500))
      }
      if (fail === 0 && success > 0) {
        toast.success(`✅ تمت مزامنة ${success} فاتورة محلية`)
      } else if (fail > 0) {
        toast.error(`تمت مزامنة ${success} فاتورة — فشلت ${fail}`)
      }
    }

    async function syncLocalShift() {
      const { useLocalShiftStore } = await import('../store/localShift')
      const shift = useLocalShiftStore.getState().shift
      if (!shift) return
      try {
        await shiftsApi.open(shift.initial_amount, shift.warehouse_id, shift.supervisor_id || undefined)
        useLocalShiftStore.getState().closeShift()
        toast.success('✅ تمت مزامنة الوردية المحلية')
      } catch (e) {
        console.warn('Local shift sync failed, will retry on next online cycle', e)
      }
    }
  }, [isOnline, queueLen, dequeue, markFailed, markSyncing, qc])

  return null
}
