import { useState, useMemo, type ReactNode } from 'react'
import { ChevronUp, ChevronDown, ChevronsUpDown } from 'lucide-react'

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
  rowKey: (row: T) => string
  onRowClick?: (row: T) => void
  maxHeight?: string
}

function SkeletonRow({ cols }: { cols: number }) {
  return (
    <tr className="border-b border-slate-50">
      {Array.from({ length: cols }).map((_, i) => (
        <td key={i} className="px-4 py-3">
          <div className="h-4 bg-slate-100 rounded-lg animate-pulse" style={{ width: `${60 + (i * 17) % 40}%` }} />
        </td>
      ))}
    </tr>
  )
}

export default function DataTable<T>({ columns, data, loading, emptyMessage = 'لا توجد بيانات', emptyIcon = '📭', rowKey, onRowClick, maxHeight }: Props<T>) {
  const [sortKey, setSortKey] = useState<string | null>(null)
  const [sortDir, setSortDir] = useState<'asc' | 'desc'>('desc')

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
    <div className="table-wrap" style={maxHeight ? { maxHeight, overflowY: 'auto' } : {}}>
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
          {loading && Array.from({ length: 5 }).map((_, i) => <SkeletonRow key={i} cols={columns.length} />)}
          {!loading && !sorted?.length && (
            <tr>
              <td colSpan={columns.length}>
                <div className="flex flex-col items-center justify-center py-16 text-slate-400">
                  <div className="text-4xl mb-3">{emptyIcon}</div>
                  <p className="text-sm font-medium">{emptyMessage}</p>
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
