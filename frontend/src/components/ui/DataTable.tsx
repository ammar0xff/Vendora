import { useState, useMemo, useRef, useEffect, type ReactNode } from 'react'
import { ChevronUp, ChevronDown, ChevronsUpDown, Plus, Search } from 'lucide-react'
import { Button } from './button'
import { Input } from './input'
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from './table'
import { cn } from 'cn'

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
  emptyIcon?: ReactNode
  emptyAction?: { label: string; onClick: () => void }
  rowKey: (row: T) => string
  onRowClick?: (row: T) => void
  maxHeight?: string
  defaultSort?: { key: string; dir: 'asc' | 'desc' }
  toolbar?: ReactNode
  searchPlaceholder?: string
  searchValue?: string
  onSearchChange?: (value: string) => void
  className?: string
}

function SkeletonRow({ cols, index }: { cols: number; index: number }) {
  const widths = [
    ['65%', '45%', '35%', '55%'],
    ['50%', '30%', '60%', '40%'],
    ['70%', '55%', '25%', '50%'],
    ['40%', '60%', '45%', '70%'],
    ['55%', '35%', '50%', '30%'],
  ]
  const pattern = widths[index % widths.length]
  return (
    <TableRow className="border-b border-border-faint">
      {Array.from({ length: cols }).map((_, i) => (
        <TableCell key={i} className="px-4 py-3">
          <div className="flex items-center gap-2.5">
            {i === 0 && (
              <div className="skeleton w-8 h-8 rounded-lg flex-shrink-0" />
            )}
            <div className="flex-1 space-y-2">
              <div className="skeleton h-3 rounded-md" style={{ width: pattern[i % pattern.length] }} />
              {i <= 1 && <div className="skeleton h-2.5 rounded-md" style={{ width: '35%' }} />}
            </div>
          </div>
        </TableCell>
      ))}
    </TableRow>
  )
}

export default function DataTable<T>({ columns, data, loading, emptyMessage = 'لا توجد بيانات', emptyIcon, emptyAction, rowKey, onRowClick, maxHeight, defaultSort, toolbar, searchPlaceholder, searchValue, onSearchChange, className }: Props<T>) {
  const [sortKey, setSortKey] = useState<string | null>(defaultSort?.key ?? null)
  const [sortDir, setSortDir] = useState<'asc' | 'desc'>(defaultSort?.dir ?? 'desc')
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

  const hasToolbar = toolbar || (searchPlaceholder && onSearchChange)

  return (
    <div className={className}>
      {hasToolbar && (
        <div className="table-tools">
          <div className="flex items-center gap-3 flex-wrap flex-1">
            {searchPlaceholder && onSearchChange && (
              <div className="relative max-w-xs w-full">
                <Search size={14} className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
                <Input
                  type="search"
                  placeholder={searchPlaceholder}
                  value={searchValue ?? ''}
                  onChange={e => onSearchChange(e.target.value)}
                  className="pr-9 pl-3 py-2 text-xs min-h-[34px]"
                />
              </div>
            )}
            {toolbar}
          </div>
        </div>
      )}

      <div className="table-wrap" ref={wrapRef} style={maxHeight ? { maxHeight, overflowY: 'auto' } : {}}>
        <Table>
          <TableHeader>
            <TableRow>
              {columns.map(col => (
                <TableHead key={col.key} style={col.width ? { width: col.width } : {}}
                  className={cn(col.sortable && 'cursor-pointer select-none hover:bg-primary-soft transition-colors')}
                  onClick={col.sortable ? () => handleSort(col.key) : undefined}>
                  <div className="flex items-center gap-1">
                    {col.label}
                    {col.sortable && (
                      <span className="text-muted-foreground flex-shrink-0">
                        {sortKey === col.key
                          ? sortDir === 'desc' ? <ChevronDown size={13} className="text-primary" /> : <ChevronUp size={13} className="text-primary" />
                          : <ChevronsUpDown size={13} />}
                      </span>
                    )}
                  </div>
                </TableHead>
              ))}
            </TableRow>
          </TableHeader>
          <TableBody>
            {loading && Array.from({ length: 5 }).map((_, i) => <SkeletonRow key={i} cols={columns.length} index={i} />)}
            {!loading && !sorted?.length && (
              <TableRow>
                <TableCell colSpan={columns.length}>
                  <div className="empty-state">
                    <div className="empty-icon">
                      {emptyIcon ?? <span className="text-3xl opacity-50">📭</span>}
                    </div>
                    <p className="empty-title">{emptyMessage}</p>
                    {emptyAction && (
                      <div className="mt-3">
                        <Button size="sm" onClick={emptyAction.onClick}>
                          <Plus size={14} /> {emptyAction.label}
                        </Button>
                      </div>
                    )}
                  </div>
                </TableCell>
              </TableRow>
            )}
            {!loading && sorted?.map(row => (
              <TableRow key={rowKey(row)} onClick={() => onRowClick?.(row)}
                className={onRowClick ? 't-row-click' : ''}>
                {columns.map(col => (
                  <TableCell key={col.key}>
                    {col.render ? col.render(row) : (row as any)[col.key]}
                  </TableCell>
                ))}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}
