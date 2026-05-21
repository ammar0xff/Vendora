import { useState, useMemo, useRef, useEffect, type ReactNode } from 'react'
import { ChevronUp, ChevronDown, ChevronsUpDown, Plus } from 'lucide-react'

interface Column<T> {
  key: string
  label: string
  width?: string
  render?: (row: T) => ReactNode
  sortable?: boolean
}

interface Props<T> {
  columns: Column<T>[]
  data: T[] | undefined
  loading?: boolean
  emptyMessage?: string
  emptyIcon?: string
  emptyAction?: { label: string; onClick: () => void }
  rowKey: (row: T) => string
  onRowClick?: (row: T) => void
  maxHeight?: string
}

function SkeletonRow({ cols, index }: { cols: number; index: number }) {
  const variants = [
    ['65%', '45%', '35%', '55%'],
    ['50%', '30%', '60%', '40%'],
    ['70%', '55%', '25%', '50%'],
    ['40%', '60%', '45%', '70%'],
    ['55%', '35%', '50%', '30%'],
  ]
  const pattern = variants[index % variants.length]
  return (
    <tr className="border-b border-slate-50">
      {Array.from({ length: cols }).map((_, i) => (
        <td key={i} className="px-4 py-3">
          <div className="flex items-center gap-2">
            {i === 0 && <div className="w-8 h-8 rounded-lg bg-slate-100 animate-pulse flex-shrink-0" />}
            <div className="flex-1 space-y-1.5">
              <div className="h-3.5 bg-slate-100 rounded-lg animate-pulse" style={{ width: pattern[i % pattern.length] }} />
              {i <= 1 && <div className="h-2.5 bg-slate-50 rounded-lg animate-pulse" style={{ width: '35%' }} />}
            </div>
          </div>
        </td>
      ))}
    </tr>
  )
}

export default function DataTable<T>({ columns, data, loading, emptyMessage = 'لا توجد بيانات', emptyIcon = '📭', emptyAction, rowKey, onRowClick, maxHeight }: Props<T>) {
  const [sortKey, setSortKey] = useState<string | null>(null)
  const [sortDir, setSortDir] = useState<'asc' | 'desc'>('desc')
  const wrapRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const el = wrapRef.current
    if (!el) return
    const check = () => el.classList.toggle('has-overflow', el.scrollWidth > el.clientWidth + 4)
    check()
    const ro = new ResizeObserver(check)
    ro.observe(el)
    return () => ro.disconnect()
  }, [data])

  const handleSort = (key: string) => {
    if (sortKey === key) {
      setSortDir(d => d === 'desc' ? 'asc' : 'desc')
    } else {
      setSortKey(key)
      setSortDir('desc')
    }
  }

  const sorted = useMemo(() => {
    if (!sortKey || !data) return data
    return [...data].sort((a, b) => {
      const av = (a as any)[sortKey]
      const bv = (b as any)[sortKey]
      const cmp = typeof av === 'number' && typeof bv === 'number'
        ? av - bv
        : String(av ?? '').localeCompare(String(bv ?? ''), 'ar')
      return sortDir === 'asc' ? cmp : -cmp
    })
  }, [data, sortKey, sortDir])

  return (
    <div className="table-wrap" ref={wrapRef} style={maxHeight ? { maxHeight, overflowY: 'auto' } : {}}>
      <table>
        <thead>
          <tr>
            {columns.map(col => (
              <th key={col.key} style={col.width ? { width: col.width } : {}}
                className={col.sortable ? 'cursor-pointer select-none hover:bg-slate-100 transition-colors' : ''}
                onClick={col.sortable ? () => handleSort(col.key) : undefined}>
                <div className="flex items-center gap-1">
                  {col.label}
                  {col.sortable && (
                    <span className="text-slate-400 flex-shrink-0">
                      {sortKey === col.key
                        ? sortDir === 'desc' ? <ChevronDown size={13} className="text-blue-500" /> : <ChevronUp size={13} className="text-blue-500" />
                        : <ChevronsUpDown size={13} />}
                    </span>
                  )}
                </div>
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {loading && Array.from({ length: 5 }).map((_, i) => <SkeletonRow key={i} cols={columns.length} index={i} />)}
          {!loading && !sorted?.length && (
            <tr>
              <td colSpan={columns.length}>
                <div className="flex flex-col items-center justify-center py-16 text-slate-400">
                  <div className="text-4xl mb-3">{emptyIcon}</div>
                  <p className="text-sm font-medium mb-4">{emptyMessage}</p>
                  {emptyAction && (
                    <button onClick={emptyAction.onClick}
                      className="px-4 py-2 rounded-xl text-sm font-bold text-white flex items-center gap-2"
                      style={{ background: '#1e3a5f' }}>
                      <Plus size={14} /> {emptyAction.label}
                    </button>
                  )}
                </div>
              </td>
            </tr>
          )}
          {!loading && sorted?.map(row => (
            <tr key={rowKey(row)} onClick={() => onRowClick?.(row)}
              className={onRowClick ? 'cursor-pointer' : ''}>
              {columns.map(col => (
                <td key={col.key}>
                  {col.render ? col.render(row) : (row as any)[col.key]}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
