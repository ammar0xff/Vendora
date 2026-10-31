
import type { LucideIcon } from 'lucide-react'
import { AlertTriangle, Inbox, RotateCcw, Search } from 'lucide-react'
import { Button } from '@/components/kit/button'
import { Empty, EmptyContent, EmptyDescription, EmptyHeader, EmptyMedia, EmptyTitle } from '@/components/kit/empty'
import { InputGroup, InputGroupAddon, InputGroupInput } from '@/components/kit/input-group'
import { Select, SelectContent, SelectGroup, SelectItem, SelectTrigger, SelectValue } from '@/components/kit/select'
import { Skeleton } from '@/components/kit/skeleton'
import { formatMoney, formatNumber } from '@/lib/format'
import { cn } from '@/lib/utils'

export function Money({ value, className, currency = true }: { value: number; className?: string; currency?: boolean }) {
  return (
    <span className={cn('inline-flex items-baseline gap-1 whitespace-nowrap', className)}>
      <span className="num">{formatMoney(value)}</span>
      {currency && <span className="text-xs font-normal text-muted-foreground">ج.م</span>}
    </span>
  )
}

export function Num({ value, className }: { value: number | string; className?: string }) {
  return <span className={cn('num', className)}>{typeof value === 'number' ? formatNumber(value) : value}</span>
}

export function PageHeader({
  title,
  description,
  actions,
}: {
  title: string
  description?: string
  actions?: React.ReactNode
}) {
  return (
    <div className="flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
      <div className="flex flex-col gap-1">
        <h1 className="text-balance text-2xl font-semibold tracking-tight">{title}</h1>
        {description && <p className="text-pretty text-sm text-muted-foreground">{description}</p>}
      </div>
      {actions && <div className="flex flex-wrap items-center gap-2">{actions}</div>}
    </div>
  )
}

export function StatCard({
  label,
  value,
  hint,
  icon: Icon,
  tone = 'default',
}: {
  label: string
  value: React.ReactNode
  hint?: React.ReactNode
  icon?: LucideIcon
  tone?: 'default' | 'success' | 'warning' | 'destructive'
}) {
  return (
    <div className="flex flex-col gap-1">
      <p className="flex items-center gap-1.5 text-xs font-medium text-muted-foreground">
        {Icon && (
          <Icon
            className={cn(
              'size-3.5 shrink-0',
              tone === 'success' && 'text-success',
              tone === 'warning' && 'text-warning',
              tone === 'destructive' && 'text-destructive',
            )}
            aria-hidden
          />
        )}
        <span>{label}</span>
      </p>
      <p className="text-2xl font-semibold tracking-tight">{value}</p>
      {hint && <p className="text-xs text-muted-foreground">{hint}</p>}
    </div>
  )
}

type ListStateProps = {
  status: 'loading' | 'error' | 'ready'
  isEmpty: boolean
  onRetry: () => void
  emptyTitle: string
  emptyDescription: string
  emptyIcon?: LucideIcon
  emptyAction?: React.ReactNode
  skeleton?: 'table' | 'grid'
  children: React.ReactNode
}

export function ListState({
  status,
  isEmpty,
  onRetry,
  emptyTitle,
  emptyDescription,
  emptyIcon: EmptyIcon = Inbox,
  emptyAction,
  skeleton = 'table',
  children,
}: ListStateProps) {
  if (status === 'loading') {
    return skeleton === 'grid' ? (
      <div className="grid grid-cols-2 gap-3 md:grid-cols-3 xl:grid-cols-4" aria-busy="true" aria-label="جارٍ التحميل">
        {Array.from({ length: 8 }).map((_, i) => (
          <Skeleton key={i} className="aspect-[4/5] rounded-xl" />
        ))}
      </div>
    ) : (
      <div className="flex flex-col gap-2" aria-busy="true" aria-label="جارٍ التحميل">
        <Skeleton className="h-10 w-full" />
        {Array.from({ length: 6 }).map((_, i) => (
          <Skeleton key={i} className="h-12 w-full" />
        ))}
      </div>
    )
  }

  if (status === 'error') {
    return (
      <Empty className="border border-dashed">
        <EmptyHeader>
          <EmptyMedia variant="icon">
            <AlertTriangle className="text-destructive" />
          </EmptyMedia>
          <EmptyTitle>تعذّر تحميل البيانات</EmptyTitle>
          <EmptyDescription>حدث خطأ أثناء الاتصال بالخادم. تحقق من الاتصال ثم أعد المحاولة.</EmptyDescription>
        </EmptyHeader>
        <EmptyContent>
          <Button variant="outline" onClick={onRetry}>
            <RotateCcw data-icon="inline-start" />
            إعادة المحاولة
          </Button>
        </EmptyContent>
      </Empty>
    )
  }

  if (isEmpty) {
    return (
      <Empty className="border border-dashed">
        <EmptyHeader>
          <EmptyMedia variant="icon">
            <EmptyIcon />
          </EmptyMedia>
          <EmptyTitle>{emptyTitle}</EmptyTitle>
          <EmptyDescription>{emptyDescription}</EmptyDescription>
        </EmptyHeader>
        {emptyAction && <EmptyContent>{emptyAction}</EmptyContent>}
      </Empty>
    )
  }

  return <>{children}</>
}

export function SearchField({
  value,
  onChange,
  placeholder,
  className,
  label = 'بحث',
}: {
  value: string
  onChange: (v: string) => void
  placeholder: string
  className?: string
  label?: string
}) {
  return (
    <InputGroup className={cn('w-full sm:w-72', className)}>
      <InputGroupInput
        type="search"
        aria-label={label}
        placeholder={placeholder}
        value={value}
        onChange={(e) => onChange(e.target.value)}
      />
      <InputGroupAddon>
        <Search />
      </InputGroupAddon>
    </InputGroup>
  )
}

export type Option = { value: string; label: string }

export function SimpleSelect({
  value,
  onValueChange,
  options,
  placeholder,
  label,
  className,
  id,
}: {
  value: string
  onValueChange: (v: string) => void
  options: Option[]
  placeholder?: string
  label?: string
  className?: string
  id?: string
}) {
  return (
    <Select items={options} value={value} onValueChange={(v) => v !== null && onValueChange(String(v))}>
      <SelectTrigger id={id} aria-label={label} className={cn('min-w-40', className)}>
        <SelectValue placeholder={placeholder} />
      </SelectTrigger>
      <SelectContent>
        <SelectGroup>
          {options.map((o) => (
            <SelectItem key={o.value} value={o.value}>
              {o.label}
            </SelectItem>
          ))}
        </SelectGroup>
      </SelectContent>
    </Select>
  )
}

const STATUS_VARIANT: Record<string, 'success' | 'warning' | 'destructive' | 'info' | 'secondary' | 'outline'> = {
  مكتملة: 'success',
  مدفوعة: 'success',
  مدفوع: 'success',
  معتمد: 'success',
  مفتوحة: 'success',
  آجل: 'warning',
  'عرض سعر': 'info',
  'مرتجع كلي': 'destructive',
  محسوب: 'info',
  'بانتظار الاعتماد': 'warning',
  مغلقة: 'secondary',
  مقفلة: 'secondary',
  مستلم: 'success',
  حاضر: 'success',
  نشط: 'success',
  إيراد: 'success',
  آجلة: 'warning',
  'قيد النقل': 'info',
  مرسل: 'info',
  'مستلم جزئيًا': 'warning',
  'مرتجع جزئي': 'warning',
  متأخر: 'warning',
  إجازة: 'info',
  مسودة: 'secondary',
  ملغاة: 'destructive',
  ملغي: 'destructive',
  مرفوض: 'destructive',
  غائب: 'destructive',
  موقوف: 'destructive',
  مصروف: 'destructive',
  // API (English) statuses from the backend
  confirmed: 'success',
  paid: 'success',
  received: 'success',
  approved: 'success',
  submitted: 'info',
  active: 'success',
  present: 'success',
  credit: 'warning',
  partial: 'warning',
  delayed: 'warning',
  draft: 'secondary',
  closed: 'secondary',
  quotation: 'info',
  cancelled: 'destructive',
  rejected: 'destructive',
  returned: 'destructive',
  suspended: 'destructive',
}

const STATUS_DOT: Record<string, string> = {
  success: 'bg-success',
  warning: 'bg-warning',
  destructive: 'bg-destructive',
  info: 'bg-chart-4',
  secondary: 'bg-muted-foreground/40',
  outline: 'border border-border bg-transparent',
}

export function StatusBadge({ status }: { status: string }) {
  const variant = STATUS_VARIANT[status] ?? 'outline'
  return (
    <span className="inline-flex items-center gap-1.5 whitespace-nowrap text-xs font-medium text-foreground/80">
      <span className={cn('size-1.5 shrink-0 rounded-full', STATUS_DOT[variant])} aria-hidden />
      {status}
    </span>
  )
}

export function TableShell({ children }: { children: React.ReactNode }) {
  return <div className="overflow-x-auto">{children}</div>
}
