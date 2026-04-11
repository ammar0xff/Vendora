import { useState, useMemo, useEffect } from 'react'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { productsApi, stockApi } from '../../api/endpoints'
import { useAppStore } from '../../store/app'
import api from '../../api/client'
import toast from 'react-hot-toast'
import { Search, CheckCircle } from 'lucide-react'

const MOVEMENT_LABELS: Record<string, string> = {
  opening_stock: 'رصيد افتتاحي',
  adjustment_in: 'تصحيح جرد +',
  adjustment_out: 'تصحيح جرد −',
  purchase: 'بضاعة جديدة',
  transfer_in: 'استلام تحويل',
}

export default function StocktakingPage() {
  const { activeWarehouseId } = useAppStore()
  const qc = useQueryClient()
  const [search, setSearch] = useState('')
  const [filter, setFilter] = useState<'all' | 'untracked' | 'tracked'>('untracked')
  const [entries, setEntries] = useState<Record<string, { qty: string; type: string }>>({})
  const [saving, setSaving] = useState(false)

  const { data: warehouses } = useQuery({ queryKey: ['warehouses'], queryFn: stockApi.warehouses })

  // Reset entries and refresh balances when warehouse changes
  useEffect(() => {
    setEntries({})
    qc.invalidateQueries({ queryKey: ['balances-stocktaking'] })
    qc.invalidateQueries({ queryKey: ['products-all-stocktaking'] })
  }, [activeWarehouseId])
  const activeWh = warehouses?.find((w: any) => w.id === activeWarehouseId)

  const { data: products, isLoading } = useQuery({
    queryKey: ['products-all-stocktaking'],
    queryFn: () => productsApi.list({}),
    staleTime: 0,
  })

  const productIds = (products || []).map((p: any) => p.id)
  const { data: balances } = useQuery({
    queryKey: ['balances-stocktaking', activeWarehouseId],
    queryFn: () => activeWarehouseId
      ? api.post(`/stock/balance/bulk?warehouse_id=${activeWarehouseId}`, productIds).then(r => r.data)
      : api.post('/stock/balance/total', productIds).then(r => r.data),
    enabled: productIds.length > 0,
    staleTime: 0,
  })

  const filtered = useMemo(() => {
    if (!products) return []
    return products.filter((p: any) => {
      if (filter === 'untracked' && p.stock_status !== 'untracked') return false
      if (filter === 'tracked' && p.stock_status !== 'tracked') return false
      if (search && !p.name.includes(search) && !(p.barcode || '').includes(search)) return false
      return true
    })
  }, [products, filter, search])

  const untrackedCount = products?.filter((p: any) => p.stock_status === 'untracked').length || 0
  const trackedCount = products?.filter((p: any) => p.stock_status === 'tracked').length || 0
  const pendingCount = Object.values(entries).filter(e => e.qty).length

  const setEntry = (id: string, field: string, val: string) =>
    setEntries(prev => { const cur = prev[id] || { qty: '', type: 'opening_stock' }; return { ...prev, [id]: { ...cur, [field]: val } } })

  const saveAll = async () => {
    if (!activeWarehouseId) return toast.error('اختر فرعاً من القائمة الجانبية أولاً')
    const toSave = Object.entries(entries).filter(([, e]) => e.qty && Number(e.qty) >= 0)
    if (!toSave.length) return toast.error('لا توجد كميات لحفظها')
    setSaving(true)
    try {
      for (const [pid, e] of toSave) {
        const product = products?.find((p: any) => p.id === pid)
        await api.post('/stock/movements', {
          product_id: pid,
          warehouse_id: activeWarehouseId,
          movement_type: e.type || 'opening_stock',
          qty: Number(e.qty),
          unit_cost: Number(product?.cost_price) || 0,
          note: e.type === 'opening_stock' ? 'رصيد افتتاحي' : 'تصحيح جرد',
        })
      }
      toast.success(`✅ تم حفظ ${toSave.length} منتج في ${activeWh?.name}`)
      setEntries({})
      qc.invalidateQueries({ queryKey: ['products-all-stocktaking'] })
      qc.invalidateQueries({ queryKey: ['balances'] }); qc.invalidateQueries({ queryKey: ['balances-stocktaking'] })
    } catch (e: any) {
      console.error('Save error:', e.response?.data || e.message)
      toast.error(e.response?.data?.detail || e.message || 'فشل الحفظ')
    } finally {
      setSaving(false)
    }
  }

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">📋 الجرد وإدخال المخزون</h1>
          <p className="text-slate-500 text-sm mt-1">
            {activeWh
              ? <span>الفرع: <span className="font-bold text-slate-700">{activeWh.name}</span></span>
              : <span className="text-red-500 font-medium">⚠️ اختر فرعاً من القائمة الجانبية أولاً</span>}
          </p>
        </div>
        {pendingCount > 0 && (
          <button onClick={saveAll} disabled={saving || !activeWarehouseId}
            className="px-5 py-2.5 rounded-xl font-bold text-sm text-white flex items-center gap-2 disabled:opacity-50"
            style={{ background: '#16a34a' }}>
            <CheckCircle size={16} /> حفظ {pendingCount} منتج {activeWh ? `في ${activeWh.name}` : ''}
          </button>
        )}
      </div>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-4 mb-5">
        {[
          { key: 'untracked', label: '⚠️ غير مجرود', count: untrackedCount, color: '#d97706' },
          { key: 'tracked',   label: '✅ مجرود',      count: trackedCount,   color: '#16a34a' },
          { key: 'all',       label: '📦 الكل',        count: products?.length || 0, color: '#1e3a5f' },
        ].map(({ key, label, count, color }) => (
          <div key={key} onClick={() => setFilter(key as any)}
            className="card p-4 text-center cursor-pointer border-2 transition-all"
            style={{ borderColor: filter === key ? color : 'transparent' }}>
            <p className="text-2xl font-black" style={{ color }}>{count}</p>
            <p className="text-xs text-slate-500 mt-1">{label}</p>
          </div>
        ))}
      </div>

      {/* Search */}
      <div className="relative mb-4 max-w-sm">
        <Search size={15} className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400" />
        <input className="input pr-9 text-sm" placeholder="بحث بالاسم أو الباركود..." value={search} onChange={e => setSearch(e.target.value)} />
      </div>

      {/* Table — desktop */}
      <div className="card p-0 overflow-hidden hidden sm:block">
        <div className="table-wrap" style={{ maxHeight: "calc(100vh - 300px)", overflowX: "auto" }}>
          <table style={{ minWidth: "600px" }}>
            <thead>
              <tr>
                <th style={{ minWidth: '200px' }}>المنتج</th>
                <th style={{ width: '140px', textAlign: 'center', whiteSpace: 'nowrap' }}>الكمية</th>
                <th style={{ width: '160px', textAlign: 'center', whiteSpace: 'nowrap' }}>نوع الحركة</th>
                <th style={{ width: '90px', textAlign: 'center', whiteSpace: 'nowrap' }}>الكمية الحالية</th>
                <th style={{ width: '90px', textAlign: 'center', whiteSpace: 'nowrap' }}>الحالة</th>
              </tr>
            </thead>
            <tbody>
              {isLoading && Array.from({ length: 8 }).map((_, i) => (
                <tr key={i}><td colSpan={5}><div className="h-4 bg-slate-100 rounded animate-pulse my-2" /></td></tr>
              ))}
              {!isLoading && !filtered.length && (
                <tr><td colSpan={5} className="text-center py-12 text-slate-400">
                  {filter === 'untracked' ? '✅ كل المنتجات مجرودة!' : 'لا توجد منتجات'}
                </td></tr>
              )}
              {filtered.map((p: any) => {
                const e = entries[p.id] || {}
                const hasEntry = !!e.qty
                return (
                  <tr key={p.id} className={hasEntry ? 'bg-green-50' : ''}>
                    <td>
                      <p className="font-semibold text-slate-800 text-sm" style={{ whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", maxWidth: "280px" }}>{p.name}</p>
                      <p className="text-xs text-slate-400">{p.unit}{p.company ? ` · ${p.company}` : ''}</p>
                    </td>
                    <td className="text-center">
                      <input type="number" className={`input text-sm text-center py-1 ${hasEntry ? 'border-green-400 bg-green-50' : ''}`} style={{ minWidth: "120px" }}
                        placeholder="0" min="0" step="any" value={e.qty || ''}
                        onChange={ev => setEntry(p.id, 'qty', ev.target.value)} />
                    </td>
                    <td className="text-center">
                      <select className="input text-xs py-1 w-full" style={{ minWidth: "150px" }} value={e.type || 'opening_stock'}
                        onChange={ev => setEntry(p.id, 'type', ev.target.value)}>
                        {Object.entries(MOVEMENT_LABELS).map(([v, l]) => <option key={v} value={v}>{l}</option>)}
                      </select>
                    </td>
                    <td className="text-center">
                      {p.stock_status === 'untracked'
                        ? <span className="text-xs text-slate-400">—</span>
                        : <span className="font-bold text-sm" style={{ color: '#1e3a5f' }}>{balances?.[p.id] ?? '...'} {p.unit}</span>}
                    </td>
                    <td className="text-center">
                      {p.stock_status === 'untracked'
                        ? <span className="text-xs px-2 py-0.5 rounded-full bg-amber-100 text-amber-700 font-bold whitespace-nowrap">⚠️ غير محدد</span>
                        : <span className="text-xs px-2 py-0.5 rounded-full bg-green-100 text-green-700 font-bold whitespace-nowrap">✅ محدد</span>}
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
      </div>

      {/* Mobile card list */}
      <div className="sm:hidden space-y-2">
        {isLoading && Array.from({ length: 6 }).map((_, i) => (
          <div key={i} className="card p-3"><div className="h-4 bg-slate-100 rounded animate-pulse" /></div>
        ))}
        {!isLoading && !filtered.length && (
          <div className="text-center py-12 text-slate-400">
            {filter === 'untracked' ? '✅ كل المنتجات مجرودة!' : 'لا توجد منتجات'}
          </div>
        )}
        {filtered.map((p: any) => {
          const e = entries[p.id] || {}
          const hasEntry = !!e.qty
          return (
            <div key={p.id} className={`card p-3 ${hasEntry ? 'border-green-300 bg-green-50' : ''}`}>
              <div className="flex items-center justify-between gap-3">
                <div className="min-w-0 flex-1">
                  <p className="font-semibold text-slate-800 text-sm truncate">{p.name}</p>
                  <div className="flex items-center gap-2 mt-0.5">
                    <span className="text-xs text-slate-400">{p.unit}</span>
                    {p.stock_status !== 'untracked' && balances?.[p.id] != null && (
                      <span className="text-xs font-bold" style={{ color: '#1e3a5f' }}>الحالي: {balances[p.id]}</span>
                    )}
                  </div>
                </div>
                <div className="flex items-center gap-2 flex-shrink-0">
                  <select className="input text-xs py-1 w-28" value={e.type || 'opening_stock'}
                    onChange={ev => setEntry(p.id, 'type', ev.target.value)}>
                    {Object.entries(MOVEMENT_LABELS).map(([v, l]) => <option key={v} value={v}>{l}</option>)}
                  </select>
                  <input type="number" className={`input text-sm text-center py-1 w-20 ${hasEntry ? 'border-green-400' : ''}`}
                    placeholder="0" min="0" step="any" value={e.qty || ''}
                    onChange={ev => setEntry(p.id, 'qty', ev.target.value)} />
                </div>
              </div>
            </div>
          )
        })}
      </div>

      {/* Floating save button */}
      {pendingCount > 0 && (
        <div className="fixed bottom-6 left-1/2 -translate-x-1/2 z-50">
          <button onClick={saveAll} disabled={saving || !activeWarehouseId}
            className="px-8 py-3 rounded-2xl font-bold text-white shadow-2xl flex items-center gap-3 disabled:opacity-50"
            style={{ background: '#16a34a' }}>
            <CheckCircle size={18} />
            حفظ {pendingCount} منتج {activeWh ? `في ${activeWh.name}` : '— اختر فرعاً أولاً'}
          </button>
        </div>
      )}
    </div>
  )
}
