import { useState, useMemo } from 'react'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { productsApi, stockApi } from '../../api/endpoints'
import { useAppStore } from '../../store/app'
import api from '../../api/client'
import toast from 'react-hot-toast'
import { Search, CheckCircle, AlertTriangle, Package } from 'lucide-react'

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
  const [entries, setEntries] = useState<Record<string, { qty: string; cost: string; type: string; note: string }>>({})
  const [saving, setSaving] = useState(false)

  const { data: products, isLoading } = useQuery({
    queryKey: ['products-all-stocktaking'],
    queryFn: () => productsApi.list({}),
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

  const setEntry = (id: string, field: string, val: string) =>
    setEntries(prev => { const cur = prev[id] || { qty: '', cost: '', type: 'opening_stock', note: '' }; return { ...prev, [id]: { ...cur, [field]: val } } })

  const saveAll = async () => {
    if (!activeWarehouseId) return toast.error('اختر فرعاً أولاً')
    const toSave = Object.entries(entries).filter(([, e]) => e.qty && Number(e.qty) >= 0)
    if (!toSave.length) return toast.error('لا توجد كميات لحفظها')
    setSaving(true)
    try {
      for (const [pid, e] of toSave) {
        await api.post('/stock/movements', {
          product_id: pid,
          warehouse_id: activeWarehouseId,
          movement_type: e.type || 'opening_stock',
          qty: Number(e.qty),
          unit_cost: Number(e.cost) || 0,
          note: e.note || (e.type === 'opening_stock' ? 'رصيد افتتاحي' : 'تصحيح جرد'),
        })
      }
      toast.success(`✅ تم حفظ ${toSave.length} منتج`)
      setEntries({})
      qc.invalidateQueries({ queryKey: ['products-all-stocktaking'] })
      qc.invalidateQueries({ queryKey: ['balances'] })
    } catch (e: any) {
      toast.error(e.response?.data?.detail || 'فشل الحفظ')
    } finally {
      setSaving(false)
    }
  }

  const pendingCount = Object.values(entries).filter(e => e.qty).length

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">📋 الجرد وإدخال المخزون</h1>
          <p className="text-slate-500 text-sm mt-1">
            {activeWarehouseId ? 'إدخال كميات للفرع المحدد' : '⚠️ اختر فرعاً من القائمة الجانبية'}
          </p>
        </div>
        {pendingCount > 0 && (
          <button onClick={saveAll} disabled={saving || !activeWarehouseId}
            className="px-5 py-2.5 rounded-xl font-bold text-sm text-white flex items-center gap-2 disabled:opacity-50"
            style={{ background: '#16a34a' }}>
            <CheckCircle size={16} /> حفظ {pendingCount} منتج
          </button>
        )}
      </div>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-4 mb-5">
        <div className="card p-4 text-center cursor-pointer border-2 transition-all" style={{ borderColor: filter === 'untracked' ? '#d97706' : 'transparent' }} onClick={() => setFilter('untracked')}>
          <p className="text-2xl font-black text-amber-600">{untrackedCount}</p>
          <p className="text-xs text-slate-500 mt-1">⚠️ غير مجرود</p>
        </div>
        <div className="card p-4 text-center cursor-pointer border-2 transition-all" style={{ borderColor: filter === 'tracked' ? '#16a34a' : 'transparent' }} onClick={() => setFilter('tracked')}>
          <p className="text-2xl font-black text-green-600">{trackedCount}</p>
          <p className="text-xs text-slate-500 mt-1">✅ مجرود</p>
        </div>
        <div className="card p-4 text-center cursor-pointer border-2 transition-all" style={{ borderColor: filter === 'all' ? '#1e3a5f' : 'transparent' }} onClick={() => setFilter('all')}>
          <p className="text-2xl font-black" style={{ color: '#1e3a5f' }}>{products?.length || 0}</p>
          <p className="text-xs text-slate-500 mt-1">📦 الكل</p>
        </div>
      </div>

      {/* Search */}
      <div className="relative mb-4 max-w-sm">
        <Search size={15} className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400" />
        <input className="input pr-9 text-sm" placeholder="بحث بالاسم أو الباركود..." value={search} onChange={e => setSearch(e.target.value)} />
      </div>

      {/* Table */}
      <div className="card p-0 overflow-hidden">
        <div className="table-wrap" style={{ maxHeight: 'calc(100vh - 320px)' }}>
          <table>
            <thead>
              <tr>
                <th>المنتج</th>
                <th style={{ width: '100px', textAlign: 'center' }}>الحالة</th>
                <th style={{ width: '120px', textAlign: 'center' }}>نوع الحركة</th>
                <th style={{ width: '100px', textAlign: 'center' }}>الكمية</th>
                <th style={{ width: '100px', textAlign: 'center' }}>التكلفة</th>
                <th style={{ width: '140px' }}>ملاحظة</th>
              </tr>
            </thead>
            <tbody>
              {isLoading && Array.from({ length: 8 }).map((_, i) => (
                <tr key={i}><td colSpan={6}><div className="h-4 bg-slate-100 rounded animate-pulse my-2" /></td></tr>
              ))}
              {!isLoading && !filtered.length && (
                <tr><td colSpan={6} className="text-center py-12 text-slate-400">
                  {filter === 'untracked' ? '✅ كل المنتجات مجرودة!' : 'لا توجد منتجات'}
                </td></tr>
              )}
              {filtered.map((p: any) => {
                const e = entries[p.id] || {}
                const hasEntry = !!e.qty
                return (
                  <tr key={p.id} className={hasEntry ? 'bg-green-50' : ''}>
                    <td>
                      <p className="font-semibold text-slate-800 text-sm">{p.name}</p>
                      <p className="text-xs text-slate-400">{p.unit} · {p.company || ''}</p>
                    </td>
                    <td className="text-center">
                      {p.stock_status === 'untracked'
                        ? <span className="text-xs px-2 py-0.5 rounded-full bg-amber-100 text-amber-700 font-bold">⚠️ غير محدد</span>
                        : <span className="text-xs px-2 py-0.5 rounded-full bg-green-100 text-green-700 font-bold">✅ محدد</span>}
                    </td>
                    <td className="text-center">
                      <select className="input text-xs py-1 w-full" value={e.type || 'opening_stock'}
                        onChange={ev => setEntry(p.id, 'type', ev.target.value)}>
                        {Object.entries(MOVEMENT_LABELS).map(([v, l]) => <option key={v} value={v}>{l}</option>)}
                      </select>
                    </td>
                    <td className="text-center">
                      <input type="number" className={`input text-sm text-center py-1 ${hasEntry ? 'border-green-400 bg-green-50' : ''}`}
                        placeholder="0" min="0" step="any"
                        value={e.qty || ''}
                        onChange={ev => setEntry(p.id, 'qty', ev.target.value)} />
                    </td>
                    <td className="text-center">
                      <input type="number" className="input text-sm text-center py-1"
                        placeholder={String(p.cost_price || 0)} min="0" step="0.01"
                        value={e.cost || ''}
                        onChange={ev => setEntry(p.id, 'cost', ev.target.value)} />
                    </td>
                    <td>
                      <input className="input text-xs py-1" placeholder="اختياري..."
                        value={e.note || ''}
                        onChange={ev => setEntry(p.id, 'note', ev.target.value)} />
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
      </div>

      {pendingCount > 0 && (
        <div className="fixed bottom-6 left-1/2 -translate-x-1/2 z-50">
          <button onClick={saveAll} disabled={saving || !activeWarehouseId}
            className="px-8 py-3 rounded-2xl font-bold text-white shadow-2xl flex items-center gap-3 disabled:opacity-50"
            style={{ background: '#16a34a' }}>
            <CheckCircle size={18} />
            حفظ {pendingCount} منتج
            {!activeWarehouseId && ' — اختر فرعاً أولاً'}
          </button>
        </div>
      )}
    </div>
  )
}
