import { useState, useEffect, useRef, useCallback } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { productsApi, salesApi, stockApi, shiftsApi, customersApi, categoriesApi, subcategoriesApi } from '../../api/endpoints'
import api from '../../api/client'
import { usePOSStore } from '../../store/pos'
import { usePendingSalesStore } from '../../store/pendingSales'
import { useLocalShiftStore } from '../../store/localShift'
import { useOnlineStatus } from '../../hooks/useOnlineStatus'
import { offlineCache } from '../../store/offlineCache'
import { PageLoader } from '../../components/ui/Loaders'
import Modal from '../../components/ui/Modal'
import ConfirmDialog from '../../components/ui/ConfirmDialog'
import toast from 'react-hot-toast'
import { openPrint } from '../../utils/format'
import Decimal from 'decimal.js'
import {
  Search, ShoppingCart, Trash2, Plus, Minus, CheckCircle,
  X, Wallet, ArrowLeftRight, Lock, Printer, RotateCcw, AlertCircle,
  ChevronDown, ChevronLeft, Tag, Layers, DollarSign, BookOpen,
  LayoutGrid, List, Landmark
} from 'lucide-react'
import { clsx } from 'clsx'
import { useAuthStore } from '../../store/auth'
import { useAppStore } from '../../store/app'
import type { Warehouse, Wallet, Customer, Product, Category, Subcategory, Collection, SaleDetail, ConfirmDeleteItem, ConfirmDeleteTx, ShiftSummaryData, User } from '../../types'
import type { CartItem } from '../../store/pos'
import CategoryCardBrowser from './CategoryCardBrowser'
import { HeldInvoicesModal } from './modals/HeldInvoicesModal'
import { ReturnModal } from './modals/ReturnModal'
import { DrawerEntryModal } from './modals/DrawerEntryModal'
import { CustomerDebtModal } from './modals/CustomerDebtModal'
import { LedgerModal } from './modals/LedgerModal'
import { OpenShiftModal } from './modals/OpenShiftModal'
import { HandoverModal } from './modals/HandoverModal'
import { CloseShiftModal } from './modals/CloseShiftModal'
import { RevenueDeliveryModal } from './modals/RevenueDeliveryModal'
import { SplitPaymentModal } from './modals/SplitPaymentModal'
import { PhoneModal } from './modals/PhoneModal'

// ── Drawer Balance Badge ──────────────────────────────────────────────────
function DrawerBadge({ shift, summary, onOpen, onHandover, onClose, onRevenueDelivery, warehouseName, supervisorName, wallets, currentUserId }: {
  shift: { id: string; initial_amount: number; cashier_id: string; cashier_name?: string; supervisor_id?: string | null } | null
  summary: ShiftSummaryData | null | undefined
  onOpen: () => void; onHandover: () => void; onClose: () => void;
  onRevenueDelivery: () => void; warehouseName: string; supervisorName: string | null;
  wallets: Wallet[]; currentUserId: string
}) {
  if (!shift) return (
    <div className="flex items-center gap-2">
      <button onClick={onOpen} className="flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-bold text-white" style={{ background: '#16a34a' }}>
        <Wallet size={15} /> فتح وردية جديدة
      </button>
    </div>
  )
  if (!summary) return (
    <div className="flex items-center gap-2">
      <div className="flex items-center gap-2 px-4 py-2 rounded-xl text-white text-sm font-bold" style={{ background: '#1e3a5f', opacity: 0.6 }}>
        <Wallet size={15} />
        <span>جاري تحميل الدرج...</span>
      </div>
    </div>
  )
  const balance = Number(summary.expected_balance ?? shift.initial_amount)
  const cashInDrawer = Number(summary.cash_in_drawer ?? balance)
  const breakdown = summary.payment_breakdown || []
  const walletTxBreakdown = summary.wallet_tx_breakdown || []

  // Merge wallet sales + wallet deposits per wallet
  const walletMap: Record<string, { name: string; type: string; total: number }> = {}
  breakdown.filter((p: { method: string; total: number; wallet_name?: string; wallet_type?: string }) => p.method !== 'cash').forEach((p: { method: string; total: number; wallet_name: string; wallet_type: string }) => {
    const k = p.wallet_name
    if (!walletMap[k]) walletMap[k] = { name: p.wallet_name, type: p.wallet_type, total: 0 }
    walletMap[k].total += Number(p.total)
  })
  walletTxBreakdown.forEach((t: { wallet_name: string; wallet_type: string; tx_type: string; total: number }) => {
    const k = t.wallet_name
    if (!walletMap[k]) walletMap[k] = { name: t.wallet_name, type: t.wallet_type, total: 0 }
    walletMap[k].total += t.tx_type === 'deposit' ? Number(t.total) : -Number(t.total)
  })
  return (
    <div className="flex items-center gap-2">
      {warehouseName && (
        <div className="flex items-center gap-1.5 px-3 py-2 rounded-xl bg-slate-100 text-slate-600 text-sm font-semibold">
          🏪 {warehouseName}
        </div>
      )}
      {supervisorName && (
        <div className="flex items-center gap-1.5 px-3 py-2 rounded-xl bg-purple-50 text-purple-700 text-xs font-semibold">
          👤 مشرف: {supervisorName}
        </div>
      )}
      {shift?.cashier_name && shift.cashier_id !== currentUserId && (
        <div className="flex items-center gap-1.5 px-3 py-2 rounded-xl bg-amber-50 text-amber-700 text-xs font-semibold border border-amber-200">
          🧑‍💼 الكاشير: {shift.cashier_name}
        </div>
      )}
      <div className="relative group">
        <div className="flex items-center gap-2 px-4 py-2 rounded-xl text-white text-sm font-bold cursor-default" style={{ background: '#1e3a5f' }}>
          <Wallet size={15} />
          <span>الدرج: {cashInDrawer.toLocaleString('ar-EG')} ج.م</span>
        </div>
        {/* Hover tooltip */}
        <div className="absolute top-full right-0 mt-1 bg-white border border-slate-200 rounded-xl shadow-xl z-50 min-w-52 p-3 hidden group-hover:block">
          <p className="text-xs font-bold text-slate-500 mb-2">مبيعات الوردية الحالية</p>
          <div className="space-y-1.5">
            <div className="flex justify-between text-xs">
              <span className="text-slate-600">💵 نقدي (الدرج)</span>
              <span className="font-bold text-slate-800">{cashInDrawer.toLocaleString('ar-EG')} ج.م</span>
            </div>
            {Object.values(walletMap).map((w: { name: string; type: string; total: number }) => (
              <div key={w.name} className="flex justify-between text-xs">
                <span className="text-slate-600">{w.type === 'vodafone_cash' ? '📱' : '💳'} {w.name}</span>
                <span className="font-bold text-slate-800">{Number(w.total).toLocaleString('ar-EG')} ج.م</span>
              </div>
            ))}
            <div className="border-t border-slate-100 pt-1.5 flex justify-between text-xs">
              <span className="font-bold text-slate-700">إجمالي الوردية</span>
              <span className="font-black" style={{color:'#1e3a5f'}}>{Number(summary?.expected_balance ?? 0).toLocaleString('ar-EG')} ج.م</span>
            </div>
            <div className="border-t border-slate-200 mt-1.5 pt-1 text-[10px] text-slate-400 space-y-0.5">
              <div className="flex justify-between">
                <span>🟢 الافتتاحي:</span>
                <span>{Number(shift.initial_amount).toLocaleString('ar-EG')} ج.م</span>
              </div>
              <div className="flex justify-between">
                <span>📊 المبيعات:</span>
                <span>{Number(summary.sales_total ?? 0).toLocaleString('ar-EG')} ج.م</span>
              </div>
              <div className="flex justify-between">
                <span>🧾 حركات:</span>
                <span>{summary.transaction_count ?? '...'}</span>
              </div>
              <div className="border-t border-slate-200/50 mt-0.5 pt-0.5 flex justify-between font-medium text-slate-500">
                <span>📋 المتوقع:</span>
                <span>{Number(summary.expected_balance ?? 0).toLocaleString('ar-EG')} ج.م</span>
              </div>
            </div>
          </div>
        </div>
      </div>
      <button onClick={onHandover} className="flex items-center gap-1.5 px-3 py-2 rounded-xl text-sm font-semibold bg-amber-100 text-amber-700 hover:bg-amber-200 transition-colors">
        <ArrowLeftRight size={14} /> تسليم
      </button>
      <button onClick={onClose} className="flex items-center gap-1.5 px-3 py-2 rounded-xl text-sm font-semibold bg-red-100 text-red-600 hover:bg-red-200 transition-colors">
        <Lock size={14} /> إغلاق
      </button>
      <button onClick={onRevenueDelivery} className="flex items-center gap-1.5 px-3 py-2 rounded-xl text-sm font-semibold bg-blue-100 text-blue-700 hover:bg-blue-200 transition-colors">
        <Landmark size={14} /> توريد إيرادات
      </button>
    </div>
  )
}

function LedgerRow({ e, hasItems, singleItem }: { e: LedgerEntry; hasItems: boolean; singleItem?: LedgerEntry['items'] extends Array<infer T> ? T : never }) {
  const [open, setOpen] = useState(false)
  return (
    <>
      <tr className={hasItems ? 'cursor-pointer hover:bg-slate-50' : ''} onClick={() => hasItems && setOpen(o => !o)}>
        <td className="text-xs text-slate-500">{e.date ? new Date(e.date).toLocaleTimeString('ar-EG') : '—'}</td>
        <td><span className={e.credit > 0 ? 'badge-green' : 'badge-red'}>{e.type}</span></td>
        <td>
          {singleItem ? (
            <div>
              <p className="text-sm font-medium">{singleItem.name}</p>
              <p className="text-xs text-slate-400">{e.ref} · {singleItem.qty} × {Number(singleItem.unit_price).toLocaleString('ar-EG')} ج.م</p>
            </div>
          ) : (
            <div className="flex items-center gap-1">
              <span className="text-sm font-medium">{e.ref}</span>
              {hasItems && <span className="text-xs text-slate-400">({e.items.length} بند) {open ? '▲' : '▼'}</span>}
              {!hasItems && e.note && <span className="text-xs text-slate-400">{e.note}</span>}
            </div>
          )}
        </td>
        <td className="text-sm text-slate-600">{e.party || '—'}</td>
        <td className="text-green-700 font-semibold text-sm">{e.credit > 0 ? Number(e.credit).toLocaleString('ar-EG') : ''}</td>
        <td className="text-red-600 font-semibold text-sm">{e.debit > 0 ? Number(e.debit).toLocaleString('ar-EG') : ''}</td>
        <td className={`font-black text-sm ${e.balance >= 0 ? 'text-green-700' : 'text-red-600'}`}>{Number(e.balance).toLocaleString('ar-EG')}</td>
      </tr>
      {hasItems && open && e.items?.map((item, idx) => (
        <tr key={idx} className="bg-slate-50 border-r-2 border-blue-200">
          <td></td>
          <td></td>
          <td className="text-xs text-slate-600 pr-4">
            <span className="font-medium">{item.name}</span>
            <span className="text-slate-400 mr-2">{item.qty} × {Number(item.unit_price).toLocaleString('ar-EG')} ج.م</span>
          </td>
          <td></td>
          <td className="text-xs text-green-600">{Number(item.total).toLocaleString('ar-EG')}</td>
          <td></td>
          <td></td>
        </tr>
      ))}
    </>
  )
}

export default function POSPage() {
  const [search, setSearch] = useState('')
  const [debouncedSearch, setDebouncedSearch] = useState('')
  const [selectedCat, setSelectedCat] = useState<string | null>(null)
  const [selectedSub, setSelectedSub] = useState<string | null>(null)
  const [customerInput, setCustomerInput] = useState('')
  const [selectedCustomer, setSelectedCustomer] = useState<Customer | null>(null)
  const [newCustomerPhone, setNewCustomerPhone] = useState('')
  const [pendingCustomerName, setPendingCustomerName] = useState('')
  const [showPhoneModal, setShowPhoneModal] = useState(false)
  const [customerSearch, setCustomerSearch] = useState('')
  const [showCustomerDrop, setShowCustomerDrop] = useState(false)
  // Modal visibility states
  const [showClose, setShowClose] = useState(false)
  const [showOpenShift, setShowOpenShift] = useState(false)
  const [showHandover, setShowHandover] = useState(false)
  const [showReturn, setShowReturn] = useState(false)
  const [returnSearch, setReturnSearch] = useState('')
  const [showDrawerEntry, setShowDrawerEntry] = useState(false)
  const [showLedger, setShowLedger] = useState(false)
  const [showExpense, setShowExpense] = useState(false)
  const [showCustomerDebt, setShowCustomerDebt] = useState(false)
  // Debt payment state
  const [debtCustomerSearch, setDebtCustomerSearch] = useState('')
  const [debtCustomer, setDebtCustomer] = useState<Customer | null>(null)
  const [debtPayAmount, setDebtPayAmount] = useState('')
  const [debtPayNote, setDebtPayNote] = useState('')
  // Drawer entry state
  const [drawerEntryType, setDrawerEntryType] = useState<'expense'|'deposit'>('expense')
  const [drawerEntryAmount, setDrawerEntryAmount] = useState('')
  const [drawerEntryNote, setDrawerEntryNote] = useState('')
  const [drawerEntryCategoryId, setDrawerEntryCategoryId] = useState('')
  const [drawerEntryPaymentMethod, setDrawerEntryPaymentMethod] = useState('cash')
  const [drawerEntryWalletId, setDrawerEntryWalletId] = useState('')
  const [drawerEntryCustomer, setDrawerEntryCustomer] = useState<Customer | null>(null)
  const [drawerCustomerSearch, setDrawerCustomerSearch] = useState('')
  const [expandedCats, setExpandedCats] = useState<Set<string>>(new Set())
  const [supervisorId, setSupervisorId] = useState('')
  const [managerIdForClose, setManagerIdForClose] = useState('')
  const [managerPasswordForClose, setManagerPasswordForClose] = useState('')
  const [closeSafeId, setCloseSafeId] = useState('')
  const [isCredit, setIsCredit] = useState(false)
  // Revenue delivery state
  const [showRevenueDelivery, setShowRevenueDelivery] = useState(false)
  const [revenueAmount, setRevenueAmount] = useState('')
  const [revenueSafeId, setRevenueSafeId] = useState('')
  const [revenueManagerId, setRevenueManagerId] = useState('')
  const [revenueManagerPassword, setRevenueManagerPassword] = useState('')
  const [revenueNotes, setRevenueNotes] = useState('')

  const [paymentMethod, setPaymentMethod] = useState('cash')

  const [paymentWalletId, setPaymentWalletId] = useState('')

  const [splitPayments, setSplitPayments] = useState<{method: string; amount: number; walletId?: string}[]>([])
  const [showSplitModal, setShowSplitModal] = useState(false)
  const [splitMethod, setSplitMethod] = useState('cash')
  const [splitAmount, setSplitAmount] = useState('')
  const [splitWalletId, setSplitWalletId] = useState('')
  const [handoverUsername, setHandoverUsername] = useState('')
  const [handoverPassword, setHandoverPassword] = useState('')
  const [closingBalance, setClosingBalance] = useState('')
  const [nextDayDrawer, setNextDayDrawer] = useState('')
  const [expenseAmount, setExpenseAmount] = useState('')
  const [expenseNote, setExpenseNote] = useState('')
  const [showDiscount, setShowDiscount] = useState(false)
  const [discountInput, setDiscountInput] = useState('')
  const [discountType, setDiscountType] = useState<'pct'|'amount'>('pct')
  const searchRef = useRef<HTMLInputElement>(null)
  const qc = useQueryClient()
  const { user } = useAuthStore()

  const [showHeld, setShowHeld] = useState(false)
  const [holdLabel, setHoldLabel] = useState('')
  const prevWarehouseRef = useRef<string | null>(null)
  const prevShiftRef = useRef<string | null>(null)

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedSearch(search), 300)
    return () => clearTimeout(timer)
  }, [search])

  const {
    items, mode, customer,
    suspended, holdCurrent, resume, deleteHeld,
    setMode, setCustomer, addItem, updateQty, updateItemDiscount, updatePrice, removeItem, clear,
    subtotal, totalDiscount, total, invoice_discount, invoice_discount_pct, setInvoiceDiscount,
  } = usePOSStore()

  const { data: warehouses } = useQuery<Warehouse[]>({ queryKey: ['warehouses'], queryFn: stockApi.warehouses })
  const { activeWarehouseId } = useAppStore()
  const { setActiveWarehouse } = useAppStore()
  // Strictly use selected warehouse — no fallback
  const mainWh = warehouses?.find(w => w.id === activeWarehouseId) ?? null

  // If user switches warehouse, cart cannot be trusted (different stock/shift).
  useEffect(() => {
    const wh = mainWh?.id || null
    if (prevWarehouseRef.current && wh && prevWarehouseRef.current !== wh) {
      clear()
      setSelectedCustomer(null)
      setIsCredit(false)
      setSplitPayments([])
    }
    prevWarehouseRef.current = wh
  }, [mainWh?.id])

  const isOnline = useOnlineStatus()
  const localShiftData = useLocalShiftStore(s => s.shift)
  const { data: serverShift, isError: shiftError } = useQuery({
    queryKey: ['current-shift', mainWh?.id], queryFn: () => shiftsApi.current(mainWh!.id),
    retry: false, throwOnError: false, refetchInterval: 30_000, enabled: !!mainWh?.id,
  })
  // Clear stale local shift when online and server has no open shift
  useEffect(() => {
    if (isOnline && shiftError && localShiftData) useLocalShiftStore.getState().closeShift()
  }, [isOnline, shiftError])
  const shift = serverShift || (!isOnline && localShiftData?.warehouse_id === mainWh?.id
    ? { ...localShiftData, cashier_id: localShiftData.cashier_id || '', started_at: localShiftData.opened_at ? new Date(localShiftData.opened_at).toISOString() : new Date().toISOString(), status: 'open' }
    : null)

  // If shift changes (closed/handed over), clear persisted cart state.
  useEffect(() => {
    const sid = shift?.id || null
    if (prevShiftRef.current && sid && prevShiftRef.current !== sid) {
      clear()
      setSelectedCustomer(null)
      setIsCredit(false)
      setSplitPayments([])
    }
    prevShiftRef.current = sid
  }, [shift?.id])
  const { data: summary } = useQuery({
    queryKey: ['shift-summary', shift?.id], queryFn: () => shiftsApi.summary(shift!.id),
    enabled: !!shift?.id, refetchInterval: 15_000,
  })

  const { data: products, isLoading } = useQuery({
    queryKey: ['products', debouncedSearch, selectedCat, selectedSub],
    queryFn: () => productsApi.list({ page_size: 5000, ...(debouncedSearch ? { search: debouncedSearch } : {}), ...(selectedSub ? { subcategory_id: selectedSub } : selectedCat ? { category_id: selectedCat } : {}) }),
    staleTime: 30_000,
  })

  // Collections — shown in search results
  const { data: collections } = useQuery({
    queryKey: ['collections'],
    queryFn: () => api.get('/collections').then(r => r.data),
  })
  const filteredCollections = search
    ? (collections || []).filter((c: Collection) => c.name.includes(search))
    : (collections || [])

  // Bulk stock balances for displayed products
  const { data: stockMap } = useQuery({
    queryKey: ['stock-bulk', mainWh?.id, products?.map((p: Product) => p.id)?.join(',') ?? ''],
    queryFn: () => stockApi.balanceBulk(mainWh!.id, products!.map((p: Product) => p.id)),
    enabled: !!mainWh?.id && !!products?.length,
    staleTime: 10_000,
  })
  const { data: categories } = useQuery({ queryKey: ['categories'], queryFn: categoriesApi.list })
  const { data: subcategories } = useQuery({ queryKey: ['subcategories'], queryFn: subcategoriesApi.list })
  const getSubsForCat = (catId: string) => (subcategories as Subcategory[])?.filter((s) => s.category_id === catId) || []
  const toggleCat = (id: string) => setExpandedCats(prev => { const s = new Set(prev); if (s.has(id)) s.delete(id); else s.add(id); return s })

  const { data: allUsers } = useQuery({ queryKey: ['users-managers'], queryFn: () => api.get('/users/staff').then(r => r.data) })
  const { data: wallets } = useQuery<Wallet[]>({ queryKey: ['wallets'], queryFn: () => api.get('/wallets').then(r => r.data), staleTime: 10_000, refetchInterval: 30_000 })
  const { data: safes } = useQuery({ queryKey: ['safes'], queryFn: () => api.get('/safes').then(r => r.data), enabled: showClose || showRevenueDelivery })
  const { data: finCategories } = useQuery({ queryKey: ['financial-categories'], queryFn: () => api.get('/financial-categories').then(r => r.data) })

  const { data: customerResults } = useQuery({
    queryKey: ['customer-search', customerSearch],
    queryFn: () => customersApi.list(customerSearch),
    enabled: customerSearch.length > 0,
    staleTime: 5000,
  })

  // Auto-fill last next_day_drawer when no shift open
  const { data: lastDrawer } = useQuery({
    queryKey: ['last-drawer'],
    queryFn: () => shiftsApi.last(mainWh!.id),
    enabled: !shift && !!mainWh?.id,
  })
  const today = new Date().toISOString().split('T')[0]
  const { data: todayLedger } = useQuery({
    queryKey: ['pos-ledger', today, mainWh?.id],
    queryFn: () => api.get('/reports/ledger', { params: { from_date: today + 'T00:00:00', to_date: today + 'T23:59:59', warehouse_id: mainWh?.id } }).then(r => r.data),
    enabled: showLedger && !!mainWh?.id,
  })

  const { data: allSales } = useQuery({
    queryKey: ['sales-for-return', returnSearch],
    queryFn: () => salesApi.list({ status: 'confirmed', limit: 100, ...(returnSearch.trim() ? { product_search: returnSearch.trim() } : {}) }),
    enabled: showReturn,
  })

  const [mobileTab, setMobileTab] = useState<'products' | 'cart'>('products')
  const [viewMode, setViewMode] = useState<'table' | 'cards'>('table')
  const [cartWidth, setCartWidth] = useState(320)
  const cartElRef = useRef<HTMLDivElement | null>(null)
  const dragRef = useRef<{ startX: number; startW: number } | null>(null)
  const handleDragStart = useCallback((e: React.MouseEvent) => {
    e.preventDefault()
    const el = cartElRef.current
    if (!el) return
    const startW = el.getBoundingClientRect().width
    dragRef.current = { startX: e.clientX, startW }
    const onMove = (ev: MouseEvent) => {
      if (!dragRef.current) return
      const w = Math.max(280, Math.min(560, dragRef.current.startW + (ev.clientX - dragRef.current.startX)))
      el.style.width = w + 'px'
    }
    const onUp = () => {
      if (cartElRef.current) setCartWidth(cartElRef.current.getBoundingClientRect().width)
      dragRef.current = null
      document.removeEventListener('mousemove', onMove)
      document.removeEventListener('mouseup', onUp)
    }
    document.addEventListener('mousemove', onMove)
    document.addEventListener('mouseup', onUp)
  }, [])
  const [returnSaleDetails, setReturnSaleDetails] = useState<SaleDetail | null>(null)
  const [returnQtys, setReturnQtys] = useState<Record<string, number>>({})
  const [confirmDelItem, setConfirmDelItem] = useState<ConfirmDeleteItem | null>(null)
  const [confirmDelReturn, setConfirmDelReturn] = useState<ConfirmDeleteItem | null>(null)
  const [confirmDelTx, setConfirmDelTx] = useState<ConfirmDeleteTx | null>(null)
  const [confirmClear, setConfirmClear] = useState(false)

  const handleAddProduct = (p: Product) => {
    if (!shift) { toast.error('افتح وردية أولاً قبل البيع', { icon: '🔒' }); return }
    const price = mode === 'wholesale' ? Number(p.wholesale_price) || Number(p.retail_price) : Number(p.retail_price)
    addItem({ product_id: p.id, name: p.name, unit_price: price, unit_cost: Number(p.cost_price), unit: p.unit })
    toast.success(`تمت إضافة ${p.name}`, { duration: 800 })
  }

  const handleAddCollection = (c: Collection) => {
    if (!shift) { toast.error('افتح وردية أولاً قبل البيع', { icon: '🔒' }); return }
    if (!c.items?.length) return
    c.items.forEach((item) => {
      const price = mode === 'wholesale' ? Number(item.wholesale_price) || Number(item.retail_price) : Number(item.retail_price)
      addItem({ product_id: item.product_id, name: item.product_name, unit_price: price, unit_cost: Number(item.cost_price || 0), unit: item.unit })
      if (Number(item.qty) > 1) updateQty(item.product_id, Number(item.qty))
    })
    toast.success(`✅ تمت إضافة ${c.name} (${c.items.length} منتج)`, { duration: 1200 })
  }

  const handleBarcodeSearch = async () => {
    if (!search.trim()) return
    try {
      const p = await productsApi.byBarcode(search.trim())
      handleAddProduct(p); setSearch('')
    } catch { /* barcode not found, fall through to normal search */ }
  }

  const checkoutMut = useMutation({
    mutationFn: async () => {
      const useSplits = splitPayments.length > 0
      const total = items.reduce((s, i) => {
        const lineTotal = new Decimal(i.qty).mul(i.unit_price)
        const itemDisc = i.item_discount_pct > 0 ? lineTotal.mul(i.item_discount_pct).div(100) : new Decimal(i.item_discount)
        return s.add(lineTotal).sub(itemDisc)
      }, new Decimal(0)).sub(totalDiscount()).toNumber()

      if (!isOnline) {
        const saleItems = items.map(i => {
          const lineTotal = new Decimal(i.qty).mul(i.unit_price)
          const itemDisc = i.item_discount_pct > 0 ? lineTotal.mul(i.item_discount_pct).div(100) : new Decimal(i.item_discount)
          return { product_id: i.product_id, name: i.name, qty: i.qty, unit_price: i.unit_price, unit_cost: i.unit_cost, discount: itemDisc.toNumber() }
        })
        usePendingSalesStore.getState().addSale({
          local_id: crypto.randomUUID?.() || String(Date.now()),
          warehouse_id: mainWh?.id || '',
          warehouse_name: mainWh?.name || '',
          sale_mode: mode,
          is_credit: useSplits ? splitPayments.some(p => p.method === 'credit') : isCredit,
          customer_id: selectedCustomer?.id || null,
          customer_name: selectedCustomer?.name || null,
          discount_amount: totalDiscount(),
          payment_method: useSplits ? splitPayments[0]?.method : (isCredit ? 'credit' : paymentMethod),
          wallet_id: useSplits ? (splitPayments.find(p => p.method === 'wallet')?.walletId || undefined) : (paymentWalletId || undefined),
          items: saleItems,
          total,
        })
        return { queued: true }
      }

      return salesApi.create({
        warehouse_id: mainWh?.id,
        shift_id: shift?.id || null,
        sale_mode: mode,
        is_credit: useSplits ? splitPayments.some(p => p.method === 'credit') : isCredit,
        customer_id: selectedCustomer?.id || null,
        discount_amount: totalDiscount(),
        payment_method: useSplits ? splitPayments[0]?.method : (isCredit ? 'credit' : paymentMethod),
        wallet_id: useSplits ? (splitPayments.find(p => p.method === 'wallet')?.walletId || undefined) : (paymentWalletId || undefined),
        payments: useSplits ? splitPayments.map(p => ({ method: p.method, amount: p.amount, wallet_id: p.walletId || null })) : undefined,
        items: items.map(i => {
          const lineTotal = new Decimal(i.qty).mul(i.unit_price)
          const itemDisc = i.item_discount_pct > 0 ? lineTotal.mul(i.item_discount_pct).div(100) : new Decimal(i.item_discount)
          return { product_id: i.product_id, qty: i.qty, unit_price: i.unit_price, unit_cost: i.unit_cost, discount: itemDisc.toNumber() }
        }),
      })
    },
    onSuccess: async (data) => {
      if (data.queued) {
        toast.success('✅ تم حفظ الفاتورة محلياً — ستتم المزامنة عند الاتصال', { duration: 5000 })
        clear()
        setSelectedCustomer(null)
        setCustomerSearch('')
        setIsCredit(false)
        setSplitPayments([])
        return
      }
      toast.success(`✅ فاتورة ${data.invoice_number}`)
      clear()
      setSelectedCustomer(null)
      setCustomerSearch('')
      setIsCredit(false)
      setSplitPayments([])
      qc.invalidateQueries({ queryKey: ['shift-summary', shift?.id] })
      qc.invalidateQueries({ queryKey: ['recent-sales'] })
      qc.invalidateQueries({ queryKey: ['wallets'] })
      openPrint(`/print/pdf/sale/${data.id}`)
    },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل في إتمام البيع'),
  })

  const returnMut = useMutation({
    mutationFn: async () => {
      if (!returnSaleDetails) return
      const allFull = returnSaleDetails.items?.every(
        (i) => (returnQtys[i.product_id] || 0) >= Number(i.qty)
      )
      if (allFull) {
        return salesApi.return(returnSaleDetails.id)
      }
      const { data } = await api.post(`/sales/${returnSaleDetails.id}/partial-return`, {
        items: Object.entries(returnQtys).filter(([, qty]) => Number(qty) > 0).map(([product_id, qty]) => ({ product_id, qty }))
      })
      return data
    },
    onSuccess: (data: { sale_id?: string } | undefined) => {
      toast.success('تم تسجيل المرتجع')
      const printId = data?.sale_id || (returnSaleDetails?.id)
      if (printId) openPrint(`/print/pdf/sale/${printId}`)
      setReturnSaleDetails(null)
      setReturnQtys({})
      setShowReturn(false)
      qc.invalidateQueries({ queryKey: ['shift-summary', shift?.id] })
      qc.invalidateQueries({ queryKey: ['recent-sales'] })
    },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })

  const expenseMut = useMutation({
    mutationFn: () => shiftsApi.addTransaction(shift!.id, { type: 'expense', amount: Number(expenseAmount), note: expenseNote }),
    onSuccess: () => { toast.success('تم تسجيل الخوارج'); setShowExpense(false); setExpenseAmount(''); setExpenseNote(''); qc.invalidateQueries({ queryKey: ['shift-summary', shift?.id] }) },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })

  const { data: debtCustomerResults } = useQuery({
    queryKey: ['debt-customer-search', debtCustomerSearch],
    queryFn: () => customersApi.list(debtCustomerSearch),
    enabled: debtCustomerSearch.length > 1,
  })
  const { data: debtCustomerAccount } = useQuery({
    queryKey: ['customer-account', debtCustomer?.id],
    queryFn: () => customersApi.account(debtCustomer!.id),
    enabled: !!debtCustomer,
  })
  const { data: debtCustomerLedger } = useQuery({
    queryKey: ['customer-ledger', debtCustomer?.id],
    queryFn: () => customersApi.ledger(debtCustomer!.id),
    enabled: !!debtCustomer,
  })

  const debtPayMut = useMutation({
    mutationFn: () => shiftsApi.addTransaction(shift!.id, {
      type: 'deposit', amount: Number(debtPayAmount),
      note: debtPayNote || `دفعة من ${debtCustomer?.name}`,
      customer_id: debtCustomer?.id,
    }),
    onSuccess: () => {
      toast.success(`✅ تم تسجيل دفعة ${debtCustomer?.name}`)
      setDebtPayAmount(''); setDebtPayNote('')
      qc.invalidateQueries({ queryKey: ['shift-summary', shift?.id] })
      qc.invalidateQueries({ queryKey: ['customer-account', debtCustomer?.id] })
      qc.invalidateQueries({ queryKey: ['customer-ledger', debtCustomer?.id] })
    },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })

  const drawerEntryMut = useMutation({
    mutationFn: () => shiftsApi.addTransaction(shift!.id, {
      type: drawerEntryType,
      amount: Number(drawerEntryAmount),
      note: drawerEntryNote || undefined,
      customer_id: drawerEntryCustomer?.id || undefined,
      category_id: drawerEntryCategoryId || undefined,
      payment_method: drawerEntryPaymentMethod === 'wallet' ? 'wallet' : 'cash',
      wallet_id: drawerEntryPaymentMethod === 'wallet' ? drawerEntryWalletId || undefined : undefined,
    }),
    onSuccess: () => {
      toast.success('تم تسجيل البند')
      setShowDrawerEntry(false); setDrawerEntryAmount(''); setDrawerEntryNote(''); setDrawerEntryCustomer(null); setDrawerCustomerSearch(''); setDrawerEntryCategoryId(''); setDrawerEntryPaymentMethod('cash'); setDrawerEntryWalletId('')
      qc.invalidateQueries({ queryKey: ['shift-summary', shift?.id] })
      qc.invalidateQueries({ queryKey: ['wallets'] })
      if (drawerEntryCustomer) qc.invalidateQueries({ queryKey: ['customer-account', drawerEntryCustomer.id] })
    },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })

  const openShiftMut = useMutation({
    mutationFn: async () => {
      if (!isOnline) {
        const { user } = useAuthStore.getState()
        useLocalShiftStore.getState().openShift({
          id: crypto.randomUUID?.() || String(Date.now()),
          warehouse_id: mainWh!.id,
          warehouse_name: mainWh!.name,
          initial_amount: Number(lastDrawer?.amount) || 0,
          cashier_id: user?.id || '',
          cashier_name: user?.full_name || user?.username || '',
          supervisor_id: supervisorId || null,
          opened_at: Date.now(),
        })
        return { id: 'local', initial_amount: Number(lastDrawer?.amount) || 0 }
      }
      return shiftsApi.open(Number(lastDrawer?.amount) || 0, mainWh!.id, supervisorId || undefined)
    },
    onSuccess: (data) => {
      toast.success(isOnline ? 'تم فتح الوردية' : 'تم فتح الوردية محلياً — ستتم المزامنة عند الاتصال')
      setShowOpenShift(false)
      if (isOnline) {
        qc.setQueryData(['current-shift', mainWh?.id], data)
        qc.invalidateQueries({ queryKey: ['last-drawer'] })
      }
    },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل في فتح الوردية'),
  })

  const handoverMut = useMutation({
    mutationFn: async () => {
      // Verify receiving employee credentials without creating a new session
      const authRes = await api.post('/auth/reauthenticate', { username: handoverUsername, password: handoverPassword })
      const toUserId = authRes.data.user_id
      return shiftsApi.transfer(shift!.id, { to_user_id: toUserId, amount: Number(summary?.expected_balance ?? 0) })
    },
    onSuccess: () => {
      toast.success(`✅ تم تسليم الدرج إلى ${handoverUsername} — الوردية لا تزال مفتوحة باسمه`, { duration: 5000 })
      if (shift?.id) openPrint(`/print/pdf/shift/${shift.id}`)
      setShowHandover(false)
      setHandoverUsername('')
      setHandoverPassword('')
      qc.setQueryData(['current-shift'], null)
      qc.setQueryData(['shift-summary', shift?.id], null)
      qc.invalidateQueries({ queryKey: ['shifts'] })
    },
    onError: (e: any) => toast.error(e.response?.data?.detail === 'Invalid credentials' ? 'كلمة المرور غير صحيحة' : e.response?.data?.detail || 'فشل'),
  })

  const closeMut = useMutation({
    mutationFn: async () => {
      const res = await api.post(`/shifts/${shift!.id}/close-with-manager`, {
        closing_balance: Number(closingBalance),
        next_day_drawer: Number(nextDayDrawer),
        manager_id: managerIdForClose,
        manager_password: managerPasswordForClose,
      })
      if (closeSafeId) {
        const cashAmt = Number(closingBalance) - Number(nextDayDrawer || 0)
        if (cashAmt > 0) {
          await api.post(`/safes/${closeSafeId}/deposit`, {
            amount: cashAmt,
            shift_id: shift!.id,
            warehouse_id: mainWh?.id,
            received_by_id: managerIdForClose,
            notes: 'تسليم الدرج عند إغلاق الوردية',
          })
        }
      }
      return res.data
    },
    onSuccess: (d: { closing_balance?: number }) => {
      const closBal = Number(d.closing_balance || 0)
      toast.success(`✅ إغلاق الوردية — الدرج: ${closBal.toLocaleString('ar-EG')} ج.م`)
      if (shift?.id) openPrint(`/print/pdf/shift/${shift.id}`)
      setShowClose(false)
      setClosingBalance('')
      setNextDayDrawer('')
      setManagerIdForClose('')
      setManagerPasswordForClose('')
      setCloseSafeId('')
      qc.setQueryData(['current-shift', mainWh?.id], null)
      qc.setQueryData(['shift-summary', shift?.id], null)
      qc.invalidateQueries({ queryKey: ['shifts'] })
    },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل'),
  })
  const revenueMut = useMutation({
    mutationFn: () => shiftsApi.revenueDelivery(shift!.id, {
      amount: Number(revenueAmount),
      safe_id: revenueSafeId,
      manager_id: revenueManagerId,
      manager_password: revenueManagerPassword,
      notes: revenueNotes || undefined,
    }),
    onSuccess: (d: { amount: number; safe: string; doc_number: string }) => {
      toast.success(`✅ تم تسليم ${Number(d.amount).toLocaleString('ar-EG')} ج.م إلى ${d.safe} — مستند: ${d.doc_number}`)
      setShowRevenueDelivery(false); setRevenueAmount(''); setRevenueSafeId('')
      setRevenueManagerId(''); setRevenueManagerPassword(''); setRevenueNotes('')
      qc.invalidateQueries({ queryKey: ['shift-summary', shift?.id] })
      qc.invalidateQueries({ queryKey: ['safes'] })
    },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل تسليم الإيرادات'),
  })

  const convertToQuotationMut = useMutation({
    mutationFn: async (bill: HeldBill) => {
      const items = bill.items.map((i) => {
        const lineTotal = new Decimal(i.qty).mul(i.unit_price)
        const discount = i.item_discount_pct > 0 ? lineTotal.mul(i.item_discount_pct).div(100) : new Decimal(i.item_discount || 0)
        return { product_id: i.product_id, qty: i.qty, unit_price: i.unit_price, unit_cost: i.unit_cost || 0, discount: discount.toNumber() }
      })
      return api.post('/sales/quotations', {
        warehouse_id: bill.warehouse_id || mainWh?.id,
        shift_id: bill.shift_id,
        sale_mode: mode,
        items,
        discount_amount: bill.invoice_discount || 0,
        notes: `مأخوذة من فاتورة معلقة: ${bill.label}`,
      }).then(r => r.data)
    },
    onSuccess: (_data: unknown, bill: HeldBill) => {
      deleteHeld(bill.id)
      toast.success(`✅ تم تحويل "${bill.label}" إلى عرض سعر`)
    },
    onError: (e: any) => toast.error(e.response?.data?.detail || 'فشل تحويل عرض السعر'),
  })

  useEffect(() => { searchRef.current?.focus() }, [])



  // ── Shift open but belongs to another cashier (non-admins only) ──────
  const canUseAnyShift = user?.is_manager === true
  const shiftOwner = shift && shift.cashier_id !== user?.id && !canUseAnyShift
    ? (shift.cashier_name || (allUsers as User[])?.find((u) => u.id === shift.cashier_id)?.full_name || 'موظف آخر')
    : null

  if (shiftOwner) return (
    <div className="flex flex-col h-[calc(100vh-7rem)]">
      <div className="absolute inset-0 z-0 overflow-hidden pointer-events-none" style={{ filter: 'blur(6px)', opacity: 0.12 }}>
        <div className="grid grid-cols-5 gap-3 p-8">
          {Array.from({ length: 20 }).map((_, i) => <div key={i} className="bg-white rounded-xl h-32 border border-slate-200" />)}
        </div>
      </div>
      <div className="relative z-10 flex-1 flex items-center justify-center">
        <div className="bg-white rounded-3xl shadow-2xl border border-slate-200 p-10 text-center max-w-sm w-full mx-4">
          <div className="w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-6 text-3xl font-black text-white" style={{ background: '#c8a84b' }}>
            {typeof shiftOwner === 'string' ? shiftOwner[0] : '؟'}
          </div>
          <h2 className="text-xl font-black text-slate-800 mb-1">الدرج مع موظف آخر</h2>
          <p className="text-2xl font-black mb-1" style={{ color: '#1e3a5f' }}>{shiftOwner}</p>
          <p className="text-slate-400 text-sm mb-2">🏪 {mainWh?.name}</p>
          <p className="text-slate-400 text-xs mb-8">
            رصيد الدرج: <span className="font-bold text-slate-600">{Number(summary?.expected_balance ?? shift.initial_amount).toLocaleString('ar-EG')} ج.م</span>
          </p>
          <div className="bg-amber-50 border border-amber-200 rounded-2xl p-4 text-sm text-amber-700">
            لإجراء أي عملية بيع، يجب أن يسلّم <strong>{shiftOwner}</strong> الدرج إليك أولاً
          </div>
        </div>
      </div>
    </div>
  )

  // ── Lock screen when no shift at all ─────────────────────────────────
  if (!shift && mainWh) return (
    <div className="flex flex-col h-[calc(100vh-7rem)]">
      {/* Blurred POS background hint */}
      <div className="absolute inset-0 z-0 overflow-hidden pointer-events-none" style={{ filter: 'blur(6px)', opacity: 0.15 }}>
        <div className="grid grid-cols-5 gap-3 p-8">
          {Array.from({ length: 20 }).map((_, i) => (
            <div key={i} className="bg-white rounded-xl h-32 border border-slate-200" />
          ))}
        </div>
      </div>

      {/* Lock overlay */}
      <div className="relative z-10 flex-1 flex items-center justify-center">
        <div className="bg-white rounded-3xl shadow-2xl border border-slate-200 p-10 text-center max-w-sm w-full mx-4">
          <div className="w-20 h-20 rounded-2xl flex items-center justify-center mx-auto mb-6" style={{ background: '#1e3a5f' }}>
            <Lock size={36} className="text-white" />
          </div>
          <h2 className="text-2xl font-black text-slate-800 mb-2">نقطة البيع مقفولة</h2>
          <p className="text-slate-500 text-sm mb-2">
            {mainWh ? <>الفرع: <span className="font-semibold text-slate-700">🏪 {mainWh.name}</span></> : 'اختر الفرع أولاً'}
          </p>
          <p className="text-slate-400 text-xs mb-8">لا توجد وردية مفتوحة في هذا الفرع</p>
          <button
            onClick={() => setShowOpenShift(true)}
            className="w-full py-4 rounded-2xl font-black text-lg text-white flex items-center justify-center gap-3 transition-all active:scale-95 hover:opacity-90"
            style={{ background: 'linear-gradient(135deg, #16a34a, #15803d)' }}
          >
            <Wallet size={22} /> فتح الوردية
          </button>
          {lastDrawer?.amount > 0 && (
            <p className="text-slate-400 text-xs mt-4">
              الفكة المتبقية: <span className="font-bold text-slate-600">{Number(lastDrawer.amount).toLocaleString('ar-EG')} ج.م</span>
            </p>
          )}
        </div>
      </div>

      {/* Open shift modal still accessible */}
      <OpenShiftModal showOpenShift={showOpenShift} onClose={() => setShowOpenShift(false)} mainWh={mainWh} lastDrawer={lastDrawer} supervisorId={supervisorId} setSupervisorId={setSupervisorId} allUsers={allUsers} openShiftMut={openShiftMut} />
    </div>
  )

  // Loading warehouses
  if (!warehouses) {
    return <PageLoader />
  }

  // Guard: must select a warehouse first
  if (!mainWh && warehouses) {
    return (
      <div className="flex flex-col items-center justify-center h-[60vh] gap-6 text-center">
        <div className="text-6xl">🏪</div>
        <div>
          <h2 className="text-xl font-black text-slate-800 mb-1">اختر الفرع أولاً</h2>
          <p className="text-slate-500 text-sm">يجب اختيار معرض أو مخزن من القائمة الجانبية قبل فتح نقطة البيع</p>
        </div>
        <div className="flex flex-wrap gap-3 justify-center">
          {warehouses.filter(w => w.warehouse_type === 'showroom').map(w => (
            <button key={w.id} onClick={() => setActiveWarehouse(w.id, w.name)}
              className="px-5 py-3 rounded-xl font-bold text-white text-sm" style={{ background: '#1e3a5f' }}>
              🏪 {w.name}
            </button>
          ))}
        </div>
      </div>
    )
  }

  return (
    <div>
    {/* ── DESKTOP layout (lg+) ── */}
    <div className="hidden lg:flex flex-col h-[calc(100vh-7rem)] gap-0">
      {/* Top bar — drawer balance */}
      <div className="flex items-center justify-between mb-4 flex-shrink-0">
        <h1 className="page-title">نقطة البيع — {mainWh?.name}</h1>
        <div className="flex items-center gap-3">
          <button onClick={() => setShowLedger(true)} className="flex items-center gap-1.5 px-3 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600 hover:bg-slate-200 transition-colors">
            <BookOpen size={14} /> سجل اليوم
          </button>
          <DrawerBadge shift={shift} summary={summary} onOpen={() => setShowOpenShift(true)} onHandover={() => setShowHandover(true)} onClose={() => setShowClose(true)} onRevenueDelivery={() => setShowRevenueDelivery(true)} warehouseName={mainWh?.name}
            supervisorName={shift?.supervisor_id ? (allUsers as User[])?.find((u) => u.id === shift.supervisor_id)?.full_name : null}
            wallets={wallets} currentUserId={user?.id} />

        </div>
      </div>

      <div className="flex gap-5 flex-1 min-h-0">
        {viewMode === 'table' && (<>
        {/* ── Category Tree Sidebar ── */}
        <aside className="w-52 flex-shrink-0 flex flex-col bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
          <div className="px-3 py-2.5 border-b border-slate-100 flex-shrink-0">
            <p className="text-xs font-bold text-slate-400 uppercase tracking-wide">الأصناف</p>
          </div>
          <div className="flex-1 overflow-y-auto py-1.5">
            <button
              onClick={() => { setSelectedCat(null); setSelectedSub(null) }}
              className={clsx('w-full text-right px-3 py-2 text-xs font-bold transition-colors rounded-lg mx-1.5 flex items-center gap-1.5',
                !selectedCat ? 'text-white' : 'text-slate-600 hover:bg-slate-50')}
              style={!selectedCat ? { background: '#1e3a5f', width: 'calc(100% - 12px)' } : { width: 'calc(100% - 12px)' }}
            >
              الكل
            </button>
            {(categories as Category[])?.map((cat) => {
              const subs = getSubsForCat(cat.id)
              const isExpanded = expandedCats.has(cat.id)
              const isCatActive = selectedCat === cat.id && !selectedSub
              return (
                <div key={cat.id}>
                  <div className="flex items-center pr-1.5">
                    <button
                      onClick={() => { setSelectedCat(cat.id); setSelectedSub(null); if (!isExpanded && subs.length) toggleCat(cat.id) }}
                      title={cat.name}
                      className={clsx('flex-1 text-right px-2 py-1.5 text-xs font-semibold transition-colors rounded-lg flex items-center gap-1.5',
                        isCatActive ? 'text-white' : 'text-slate-700 hover:bg-slate-50')}
                      style={isCatActive ? { background: '#1e3a5f' } : {}}
                    >
                      <Tag size={10} className="flex-shrink-0 opacity-60" />
                      <span className="truncate leading-tight">{cat.name}</span>
                    </button>
                    {subs.length > 0 && (
                      <button onClick={() => toggleCat(cat.id)} className="p-1 text-slate-300 hover:text-slate-500 flex-shrink-0">
                        {isExpanded ? <ChevronDown size={11} /> : <ChevronLeft size={11} />}
                      </button>
                    )}
                  </div>
                  {isExpanded && subs.map((sub) => {
                    const isSubActive = selectedSub === sub.id
                    return (
                      <button key={sub.id}
                        onClick={() => { setSelectedCat(cat.id); setSelectedSub(sub.id) }}
                        title={sub.name}
                        className={clsx('w-full text-right pr-6 pl-2 py-1 text-xs transition-colors rounded-lg mx-1.5 flex items-center gap-1',
                          isSubActive ? 'text-white font-semibold' : 'text-slate-500 hover:bg-slate-50 hover:text-slate-700')}
                        style={isSubActive ? { background: '#2d5a8e', width: 'calc(100% - 12px)' } : { width: 'calc(100% - 12px)' }}
                      >
                        <Layers size={9} className="flex-shrink-0 opacity-50 shrink-0" />
                        <span className="truncate leading-tight">{sub.name}</span>
                      </button>
                    )
                  })}
                </div>
              )
            })}
          </div>
        </aside>
        </>)}

        {/* ── Products + Cart ── */}
        <div className="flex-1 flex flex-col min-w-0">
          {/* Search + view toggle */}
          <div className="flex items-center gap-2 mb-3 flex-shrink-0">
            <div className="relative flex-1">
              <Search size={16} className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400" />
              <input ref={searchRef} value={search}
                onChange={e => { setSearch(e.target.value); if (e.target.value) { setSelectedCat(null); setSelectedSub(null) } }}
                onKeyDown={e => e.key === 'Enter' && handleBarcodeSearch()}
                className="input pr-10" placeholder="ابحث بالاسم أو امسح الباركود..." />
            </div>
            <button onClick={() => setViewMode(viewMode === 'table' ? 'cards' : 'table')}
              className="flex items-center gap-1.5 px-3 py-2 rounded-xl text-xs font-bold border border-slate-200 text-slate-500 hover:bg-slate-100 transition-colors flex-shrink-0">
              {viewMode === 'table'
                ? <><LayoutGrid size={14} /> عرض الفئات</>
                : <><List size={14} /> عرض الجدول</>
              }
            </button>
          </div>

          {viewMode === 'cards' ? (
            <div className="flex-1 min-h-0">
              <CategoryCardBrowser warehouseId={mainWh?.id} mode={mode} onAddProduct={(p) => { handleAddProduct(p); }} />
            </div>
          ) : (
          <>
          {isLoading ? <PageLoader /> : (
            <div className="flex-1 overflow-y-auto relative">

              {/* Collections */}
              {filteredCollections.length > 0 && (
                <div className="mb-3">
                  <p className="text-xs font-bold text-slate-400 mb-2 flex items-center gap-1">📦 كوليكشنات</p>
                  <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-3 xl:grid-cols-4 gap-3">
                    {filteredCollections.map((c) => {
                      const price = mode === 'wholesale' ? Number(c.wholesale_price) || Number(c.retail_price) : Number(c.retail_price)
                      return (
                        <button key={c.id} onClick={() => handleAddCollection(c)}
                          className="bg-white rounded-xl border-2 border-amber-200 p-3 text-right hover:border-amber-400 hover:shadow-md transition-all active:scale-95">
                          <div className="w-full h-10 rounded-lg mb-2 flex items-center justify-center text-base font-black text-white"
                            style={{ background: 'linear-gradient(135deg, #c8a84b, #e8c96b)' }}>
                            📦
                          </div>
                          <p className="text-xs font-bold text-slate-800 leading-tight line-clamp-2 mb-0.5">{c.name}</p>
                          <p className="text-xs text-slate-400">{c.items?.length || 0} منتج</p>
                          <div className="flex items-end justify-between mt-1.5">
                            <div>
                              <p className="text-sm font-black leading-none" style={{ color: '#c8a84b' }}>{price.toLocaleString('ar-EG')}</p>
                              <p className="text-xs text-slate-400 leading-none">ج.م</p>
                            </div>
                          </div>
                        </button>
                      )
                    })}
                  </div>
                </div>
              )}

              <div className="overflow-y-auto flex-1 border border-slate-200 rounded-xl">
                <table className="w-full text-right text-xs">
                  <thead className="sticky top-0 bg-slate-100 z-10">
                    <tr className="text-slate-500 font-semibold">
                      <th className="py-2 px-3">المنتج</th>
                      <th className="py-2 px-3">الشركة</th>
                      <th className="py-2 px-3">الرف</th>
                      <th className="py-2 px-3">القطاعي</th>
                      <th className="py-2 px-3">الجملة</th>
                      <th className="py-2 px-3">المخزون</th>
                      <th className="py-2 px-3"></th>
                    </tr>
                  </thead>
                  <tbody>
                    {products?.length === 0 && (
                      <tr><td colSpan={7} className="text-center py-12 text-slate-400">لا توجد منتجات</td></tr>
                    )}
                    {products?.filter((p: Product) => {
                      const q = p.stock_status === 'untracked' ? null : (stockMap?.[p.id] ?? null)
                      return q === null || q > 0
                    })?.map((p: Product) => {
                      const retailPrice = Number(p.retail_price)
                      const wholesalePrice = Number(p.wholesale_price) || retailPrice
                      const qty = p.stock_status === 'untracked' ? null : (stockMap?.[p.id] ?? null)
                      return (
                        <tr key={p.id} onClick={() => handleAddProduct(p)}
                          className="border-t border-slate-100 hover:bg-blue-50 cursor-pointer transition-colors">
                          <td className="py-2 px-3 font-semibold text-slate-800">{p.name}</td>
                          <td className="py-2 px-3 text-slate-400">{p.company || '—'}</td>
                          <td className="py-2 px-3">{p.shelf_number ? <span className="text-xs px-1.5 py-0.5 rounded bg-indigo-50 text-indigo-600 font-bold">{p.shelf_number}</span> : <span className="text-slate-300">—</span>}</td>
                          <td className="py-2 px-3 font-black" style={{ color: '#c8a84b' }}>{retailPrice.toLocaleString('ar-EG')}</td>
                          <td className="py-2 px-3 text-slate-600">{wholesalePrice.toLocaleString('ar-EG')}</td>
                          <td className="py-2 px-3">
                            {qty != null ? (
                              <span className={`font-bold px-1.5 py-0.5 rounded-md ${
                                qty <= 0 ? 'bg-red-100 text-red-600' :
                                qty <= 5 ? 'bg-amber-100 text-amber-700' :
                                'bg-green-100 text-green-700'
                              }`}>{qty}</span>
                            ) : <span className="text-slate-300">—</span>}
                          </td>
                          <td className="py-2 px-3">
                            <span className="text-blue-500 font-bold text-sm">+</span>
                          </td>
                        </tr>
                      )
                    })}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* Action buttons — 4 */}
          <div className="mt-3 grid grid-cols-2 gap-1.5 flex-shrink-0">
            <button onClick={() => setShowReturn(true)}
              className="flex items-center justify-center gap-1.5 py-2 rounded-xl text-xs font-bold border-2 border-amber-200 text-amber-700 bg-amber-50 hover:bg-amber-100 transition-colors">
              <RotateCcw size={13} /> مرتجع
            </button>
            <button onClick={() => { setShowDrawerEntry(true); setDrawerEntryType('expense') }} disabled={!shift}
              className="flex items-center justify-center gap-1.5 py-2 rounded-xl text-xs font-bold border-2 border-red-200 text-red-600 bg-red-50 hover:bg-red-100 transition-colors disabled:opacity-40">
              <Trash2 size={13} /> خوارج
            </button>
            <button onClick={() => { setShowDrawerEntry(true); setDrawerEntryType('deposit') }} disabled={!shift}
              className="flex items-center justify-center gap-1.5 py-2 rounded-xl text-xs font-bold border-2 border-green-200 text-green-700 bg-green-50 hover:bg-green-100 transition-colors disabled:opacity-40">
              <DollarSign size={13} /> دواخل مالية
            </button>
            <button onClick={() => setShowCustomerDebt(true)} disabled={!shift}
              className="flex items-center justify-center gap-1.5 py-2 rounded-xl text-xs font-bold border-2 border-blue-200 text-blue-700 bg-blue-50 hover:bg-blue-100 transition-colors disabled:opacity-40">
              <DollarSign size={13} /> دفع عميل آجل
            </button>
          </div>
          </>
          )}
        </div>

        {/* Cart panel */}
        <div ref={cartElRef} className="flex-shrink-0 flex relative" style={{ width: cartWidth }}>
          <div className="absolute right-0 top-0 bottom-0 w-1.5 cursor-col-resize z-10 group flex items-center justify-center"
            onMouseDown={handleDragStart}>
            <div className="w-0.5 h-8 rounded-full bg-slate-200 group-hover:bg-blue-400 transition-colors" />
          </div>
          <div className="flex-1 flex flex-col bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">

          {/* Cart header — customer + mode */}
          <div className="p-4 border-b border-slate-100 flex-shrink-0" style={{ background: '#1e3a5f' }}>
            <div className="flex items-center justify-between mb-3">
              <h2 className="text-white font-bold flex items-center gap-2"><ShoppingCart size={16} /> السلة ({items.length})</h2>
              <div className="flex items-center gap-2">
                {/* Retail / Wholesale toggle inside cart */}
                <div className="flex rounded-lg overflow-hidden border border-white/20">
                  <button onClick={() => setMode('retail')} className={clsx('px-2.5 py-1 text-xs font-bold transition-all', mode === 'retail' ? 'bg-white text-slate-800' : 'text-white/70 hover:text-white')}>قطاعي</button>
                  <button onClick={() => setMode('wholesale')} className={clsx('px-2.5 py-1 text-xs font-bold transition-all', mode === 'wholesale' ? 'bg-white text-slate-800' : 'text-white/70 hover:text-white')}>جملة</button>
                </div>
                {/* آجل toggle */}
                <button onClick={() => setIsCredit(v => !v)}
                  className={clsx('px-2.5 py-1 rounded-lg text-xs font-bold border transition-all', isCredit ? 'bg-amber-400 text-slate-900 border-amber-300' : 'border-white/20 text-white/60 hover:text-white')}>
                  آجل
                </button>
                <button onClick={() => setShowHeld(true)} className="text-white/70 hover:text-white text-xs">
                  معلقة ({suspended.length})
                </button>
                {items.length > 0 && (
                  <button
                    onClick={() => { holdCurrent({ label: holdLabel, warehouse_id: mainWh?.id, shift_id: shift?.id }); setHoldLabel('') }}
                    className="text-white/70 hover:text-white text-xs"
                  >
                    تعليق
                  </button>
                )}
                {items.length > 0 && <button onClick={() => setConfirmClear(true)} className="text-white/50 hover:text-white text-xs">مسح</button>}
              </div>
            </div>

            {/* Split payment builder */}
            <div className="mb-2 space-y-1.5">
              {splitPayments.length === 0 && !isCredit && (
                <div className="flex gap-2 items-center">
                  <button type="button"
                    onClick={() => { setPaymentMethod('cash'); setPaymentWalletId('') }}
                    className={clsx('px-3 py-2 rounded-lg text-xs font-bold border transition-all flex-shrink-0',
                      'bg-blue-500 text-white border-blue-400')}>
                    💵 نقدي
                  </button>
                   {(wallets || []).filter(w => w.type !== 'cash').length > 0 && (
                    <div className="relative flex-1">
                      <select value={paymentWalletId}
                        onChange={e => { setPaymentMethod('wallet'); setPaymentWalletId(e.target.value) }}
                        className="w-full rounded-lg text-xs font-bold border px-3 py-2 bg-white/10 border-white/20 text-white/60 outline-none">
                        <option value="" style={{ background: '#1e3a5f', color: '#fff' }}>💳 تحويل إلكتروني...</option>
                        {(wallets || []).filter(w => w.type !== 'cash').map(w => (
                          <option key={w.id} value={w.id} style={{ background: '#1e3a5f', color: '#fff' }}>
                            {w.type === 'vodafone_cash' ? '📱' : '💳'} {w.name}
                          </option>
                        ))}
                      </select>
                    </div>
                  )}
                  <button onClick={() => { setSplitPayments([{ method: 'cash', amount: total() }]); setPaymentMethod('cash'); setPaymentWalletId('') }}
                    className="text-[10px] text-white/40 hover:text-white underline whitespace-nowrap">
                    تقسيم الدفع
                  </button>
                </div>
              )}
              {splitPayments.length > 0 && !isCredit && (
                <div className="space-y-1">
                  {splitPayments.map((sp, i) => (
                    <div key={i} className="flex items-center gap-1.5 text-xs">
                      <span className="text-white/70 w-16">
                        {sp.method === 'cash' ? '💵 نقدي' : sp.method === 'wallet' ? '💳 محفظة' : sp.method === 'credit' ? '📋 آجل' : sp.method}
                      </span>
                      <span className="font-bold text-white">{sp.amount.toLocaleString('ar-EG')} ج.م</span>
                      <button onClick={() => { setSplitPayments(p => p.filter((_, j) => j !== i)); if (splitPayments.length <= 1) { setSplitPayments([]); setPaymentMethod('cash') } }}
                        className="text-red-300 hover:text-red-200 mr-1">✕</button>
                    </div>
                  ))}
                  <div className="flex gap-1.5 items-center pt-0.5">
                    <button onClick={() => setShowSplitModal(true)}
                      className="text-[10px] text-white/40 hover:text-white underline">+ إضافة قسط</button>
                    <span className="text-[10px] text-white/30">|</span>
                    <span className="text-[10px] text-white/50">المجموع: {splitPayments.reduce((s, p) => s + p.amount, 0).toLocaleString('ar-EG')} / {total().toLocaleString('ar-EG')} ج.م</span>
                    {Math.abs(splitPayments.reduce((s, p) => s + p.amount, 0) - total()) > 0.01 && (
                      <span className="text-[10px] text-red-300">⚠️ غير متطابق</span>
                    )}
                  </div>
                </div>
              )}
            </div>
            {/* Customer smart search */}
            <div className="relative">
              <input
                value={selectedCustomer ? selectedCustomer.name : customerInput}
                onChange={e => { setCustomerSearch(e.target.value); setSelectedCustomer(null); setCustomerInput(e.target.value); setShowCustomerDrop(true) }}
                onFocus={() => setShowCustomerDrop(true)}
                onBlur={() => setTimeout(() => setShowCustomerDrop(false), 200)}
                className="w-full bg-white/10 border border-white/20 rounded-lg px-3 py-2 text-white text-sm placeholder-white/30 outline-none focus:border-yellow-400 focus:bg-white/15 transition-all"
                placeholder="اسم العميل — يُترك فارغاً للعميل العادي" />
              {showCustomerDrop && (customerResults?.length > 0 || customerSearch.length > 1) && (
                <div className="absolute top-full right-0 left-0 mt-1 bg-white rounded-xl shadow-xl border border-slate-200 z-50 max-h-48 overflow-y-auto">
                  {customerResults?.map((c: Customer) => (
                    <button key={c.id} onMouseDown={() => { setSelectedCustomer(c); setCustomer(c.name); setCustomerSearch(''); setShowCustomerDrop(false) }}
                      className="w-full text-right px-4 py-2.5 hover:bg-slate-50 text-sm border-b border-slate-50 last:border-0">
                      <p className="font-semibold text-slate-800">{c.name}</p>
                      {c.phone && <p className="text-xs text-slate-400">{c.phone}</p>}
                    </button>
                  ))}
                  {customerSearch.length > 1 && (
                    <button onMouseDown={() => {
                      if (isCredit) {
                        setPendingCustomerName(customerSearch)
                        setNewCustomerPhone('')
                        setShowPhoneModal(true)
                        setShowCustomerDrop(false)
                      } else {
                        customersApi.create({ name: customerSearch }).then(c => {
                          setSelectedCustomer(c); setCustomer(c.name); setCustomerSearch(''); setShowCustomerDrop(false)
                        })
                      }
                    }} className="w-full text-right px-4 py-2.5 hover:bg-green-50 text-sm text-green-700 font-semibold flex items-center gap-2">
                      <span>+</span> إضافة "{customerSearch}" كعميل جديد{isCredit ? ' (آجل — يلزم تليفون)' : ''}
                    </button>
                  )}
                </div>
              )}
            </div>
          </div>

          {/* Cart items */}
          <div className="flex-1 overflow-y-auto p-3 space-y-2 max-h-[55vh]">
            {!items.length && (
              <div className="text-center py-10 text-slate-400">
                <ShoppingCart size={36} className="mx-auto mb-2 opacity-30" />
                <p className="text-sm">السلة فارغة</p>
              </div>
            )}
            {items.map(item => {
              const lineTotal = item.qty * item.unit_price
              const itemDiscAmt = item.item_discount_pct > 0 ? lineTotal * (item.item_discount_pct / 100) : item.item_discount
              const lineNet = lineTotal - itemDiscAmt
              const belowCost = lineNet < item.qty * item.unit_cost
              return (
                <div key={item.product_id} className={clsx('rounded-xl p-3 border', belowCost ? 'bg-red-50 border-red-200' : 'bg-slate-50 border-transparent')}>
                  <div className="flex items-start justify-between mb-2">
                    <p className="text-xs font-semibold text-slate-700 leading-tight flex-1 ml-2">{item.name}</p>
                    <button onClick={() => removeItem(item.product_id)} className="text-slate-300 hover:text-red-500 transition-colors flex-shrink-0"><X size={13} /></button>
                  </div>
                  <div className="flex items-center justify-between mb-1.5">
                    <div className="flex items-center gap-1">
                      <button onClick={() => updateQty(item.product_id, item.qty - 1)} className="w-6 h-6 rounded-lg bg-slate-200 hover:bg-slate-300 flex items-center justify-center"><Minus size={11} /></button>
                      <input type="number" min="1"
                        value={item.qty}
                        onChange={e => updateQty(item.product_id, Number(e.target.value) || 1)}
                        className="w-12 text-center text-sm font-bold border border-slate-200 rounded-lg py-0.5 outline-none focus:border-blue-300" />
                      <button onClick={() => updateQty(item.product_id, item.qty + 1)} className="w-6 h-6 rounded-lg bg-slate-200 hover:bg-slate-300 flex items-center justify-center"><Plus size={11} /></button>
                    </div>
                    <div className="flex items-center gap-1">
                      <input type="number" min="0" step="0.5"
                        value={item.unit_price}
                        onChange={e => {
                          const newPrice = Number(e.target.value)
                          if (newPrice > 0) updatePrice(item.product_id, newPrice)
                        }}
                        onBlur={e => {
                          const newPrice = Number(e.target.value)
                          if (newPrice < item.unit_cost) updatePrice(item.product_id, item.unit_cost)
                        }}
                        className={clsx('w-20 text-center text-sm font-bold border rounded-lg py-0.5 outline-none focus:border-blue-300',
                          item.unit_price < item.unit_cost ? 'border-red-300 bg-red-50' : 'border-slate-200')}
                        title="سعر البيع" />
                      <span className="text-xs text-slate-400">ج.م</span>
                    </div>
                    <div className="text-left">
                      {itemDiscAmt > 0 && <p className="text-xs text-slate-400 line-through leading-none">{lineTotal.toLocaleString('ar-EG')}</p>}
                      <p className={clsx('text-sm font-black leading-none', belowCost ? 'text-red-600' : '')} style={!belowCost ? { color: '#1e3a5f' } : {}}>{lineNet.toLocaleString('ar-EG')} ج.م</p>
                    </div>
                  </div>
                  {/* Per-item discount row */}
                  <div className="flex items-center gap-1.5 mt-1">
                    <span className="text-xs text-slate-400">خصم:</span>
                    <div className="flex items-center gap-1 flex-1">
                      <input type="number" min="0"
                        value={item.item_discount_pct || ''}
                        onChange={e => {
                          const pct = Number(e.target.value)
                          updateItemDiscount(item.product_id, 0, pct)
                        }}
                        className="w-14 text-center text-xs border border-slate-200 rounded-md px-1 py-0.5 outline-none focus:border-blue-300"
                        placeholder="%" />
                      <span className="text-xs text-slate-400">%</span>
                      <span className="text-xs text-slate-300 mx-0.5">أو</span>
                      <input type="number" min="0"
                        value={item.item_discount || ''}
                        onChange={e => {
                          const amt = Number(e.target.value)
                          updateItemDiscount(item.product_id, amt, 0)
                        }}
                        className="w-16 text-center text-xs border border-slate-200 rounded-md px-1 py-0.5 outline-none focus:border-blue-300"
                        placeholder="ج.م" />
                    </div>
                    {belowCost && <span className="text-xs text-red-500 font-bold flex-shrink-0">⚠️ خسارة</span>}
                  </div>
                </div>
              )
            })}
          </div>

          {/* Totals + invoice discount + checkout */}
          <div className="p-4 border-t border-slate-100 flex-shrink-0 space-y-3">
            {/* Invoice-level discount */}
            {items.length > 0 && (
              <div className="bg-slate-50 rounded-xl p-3 space-y-2">
                <p className="text-xs font-bold text-slate-500">خصم على الفاتورة</p>
                <div className="flex gap-2">
                  <div className="flex-1 relative">
                    <input type="number" min="0" max="100"
                      value={invoice_discount_pct || ''}
                      onChange={e => setInvoiceDiscount(0, Number(e.target.value))}
                      className="w-full text-center text-sm border border-slate-200 rounded-lg px-2 py-1.5 outline-none focus:border-blue-300"
                      placeholder="%" />
                    <span className="absolute left-2 top-1/2 -translate-y-1/2 text-xs text-slate-400">%</span>
                  </div>
                  <div className="flex-1 relative">
                    <input type="number" min="0"
                      value={invoice_discount || ''}
                      onChange={e => setInvoiceDiscount(Number(e.target.value), 0)}
                      className="w-full text-center text-sm border border-slate-200 rounded-lg px-2 py-1.5 outline-none focus:border-blue-300"
                      placeholder="ج.م" />
                    <span className="absolute left-2 top-1/2 -translate-y-1/2 text-xs text-slate-400">ج</span>
                  </div>
                </div>
              </div>
            )}

            {/* Summary */}
            <div className="space-y-1">
              {totalDiscount() > 0 && (
                <>
                  <div className="flex justify-between text-xs text-slate-500">
                    <span>المجموع</span><span>{subtotal().toLocaleString('ar-EG')} ج.م</span>
                  </div>
                  <div className="flex justify-between text-xs text-red-500 font-semibold">
                    <span>الخصم</span><span>- {totalDiscount().toLocaleString('ar-EG')} ج.م</span>
                  </div>
                </>
              )}
              <div className="flex justify-between items-center">
                <span className="text-slate-500 font-medium text-sm">الإجمالي</span>
                <span className="text-2xl font-black" style={{ color: '#1e3a5f' }}>{total().toLocaleString('ar-EG')} ج.م</span>
              </div>
            </div>

            {!shift && (
              <div className="flex items-center gap-2 bg-amber-50 border border-amber-200 rounded-xl p-3 text-amber-700 text-xs">
                <AlertCircle size={14} /><span>افتح وردية أولاً</span>
              </div>
            )}
            <button
              onClick={() => checkoutMut.mutate()}
              disabled={!items.length || checkoutMut.isPending || (isCredit && !selectedCustomer)}
              className="w-full py-4 rounded-xl font-black text-lg transition-all active:scale-95 disabled:opacity-50 flex items-center justify-center gap-2"
              style={{ background: items.length ? '#c8a84b' : '#e2e8f0', color: items.length ? '#1e3a5f' : '#94a3b8' }}
            >
              <CheckCircle size={20} />
              {checkoutMut.isPending ? 'جاري...' : isCredit && !selectedCustomer ? '⚠️ حدد عميل للآجل' : isCredit ? '✓ تأكيد — آجل' : 'تأكيد الدفع'}
            </button>
          </div>
        </div>{/* end cart inner */}
      </div>{/* end cart wrapper */}
      </div>{/* end main-row */}

    </div>{/* end desktop */}

    {/* ── MOBILE layout (< lg) ── */}
    <div className="lg:hidden flex flex-col" style={{ height: 'calc(100vh - 7rem)' }}>

      {/* Mobile top bar */}
      <div className="flex items-center justify-between px-3 py-2 flex-shrink-0" style={{ background: '#1e3a5f' }}>
        <span className="text-white font-bold text-sm">🏪 {mainWh?.name}</span>
        <div className="flex items-center gap-2">
          {shift ? (
            <>
              <span className="text-white/80 text-xs font-semibold">
                💵 {summary ? Number(summary.expected_balance ?? shift.initial_amount).toLocaleString('ar-EG') : '...'} ج.م
              </span>
              <button onClick={() => setShowRevenueDelivery(true)} className="px-2 py-1 rounded-lg text-xs font-bold bg-blue-500 text-white">💰 توريد</button>
              <button onClick={() => setShowHandover(true)} className="px-2 py-1 rounded-lg text-xs font-bold bg-amber-400 text-slate-900">تسليم</button>
              <button onClick={() => setShowClose(true)} className="px-2 py-1 rounded-lg text-xs font-bold bg-red-500 text-white">إغلاق</button>
            </>
          ) : (
            <button onClick={() => setShowOpenShift(true)} className="px-3 py-1.5 rounded-lg text-xs font-bold bg-green-500 text-white">فتح وردية</button>
          )}
        </div>
      </div>

      {/* Products tab */}
      {mobileTab === 'products' && (
        <div className="flex-1 flex flex-col min-h-0 p-3">
          {/* Search + view toggle */}
          <div className="flex items-center gap-2 mb-3 flex-shrink-0">
            <div className="relative flex-1">
              <Search size={16} className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400" />
              <input ref={searchRef} value={search}
                onChange={e => { setSearch(e.target.value); if (e.target.value) { setSelectedCat(null); setSelectedSub(null) } }}
                onKeyDown={e => e.key === 'Enter' && handleBarcodeSearch()}
                className="input pr-10" placeholder="ابحث أو امسح الباركود..." autoFocus />
            </div>
            <button onClick={() => setViewMode(viewMode === 'table' ? 'cards' : 'table')}
              className="flex items-center gap-1.5 px-3 py-2 rounded-xl text-xs font-bold border border-slate-200 text-slate-500 hover:bg-slate-100 transition-colors flex-shrink-0">
              {viewMode === 'table'
                ? <><LayoutGrid size={14} /> عرض الفئات</>
                : <><List size={14} /> عرض الجدول</>
              }
            </button>
          </div>

          {viewMode === 'cards' ? (
            <div className="flex-1 min-h-0">
              <CategoryCardBrowser warehouseId={mainWh?.id} mode={mode} onAddProduct={(p) => { handleAddProduct(p); }} />
            </div>
          ) : (
          <>
          {/* Category pills */}
          <div className="flex gap-2 overflow-x-auto pb-2 flex-shrink-0" style={{ WebkitOverflowScrolling: 'touch' }}>
            <button onClick={() => { setSelectedCat(null); setSelectedSub(null) }}
              className="flex-shrink-0 px-3 py-1.5 rounded-full text-xs font-bold transition-all"
              style={!selectedCat ? { background: '#1e3a5f', color: 'white' } : { background: '#f1f5f9', color: '#64748b' }}>
              الكل
            </button>
            {(categories as Category[])?.map((cat) => (
              <button key={cat.id} onClick={() => { setSelectedCat(cat.id); setSelectedSub(null) }}
                className="flex-shrink-0 px-3 py-1.5 rounded-full text-xs font-bold transition-all"
                style={selectedCat === cat.id ? { background: '#1e3a5f', color: 'white' } : { background: '#f1f5f9', color: '#64748b' }}>
                {cat.name}
              </button>
            ))}
          </div>
          {/* Product table */}
          <div className="flex-1 overflow-y-auto border border-slate-200 rounded-xl">
            <table className="w-full text-right text-xs">
              <thead className="sticky top-0 bg-slate-100 z-10">
                <tr className="text-slate-500 font-semibold">
                  <th className="py-2 px-2">المنتج</th>
                  <th className="py-2 px-2">الرف</th>
                  <th className="py-2 px-2">السعر</th>
                  <th className="py-2 px-2">المخزون</th>
                  <th className="py-2 px-2"></th>
                </tr>
              </thead>
              <tbody>
                {products?.length === 0 && (
                  <tr><td colSpan={5} className="text-center py-12 text-slate-400">لا توجد منتجات</td></tr>
                )}
                {(products || []).filter((p: Product) => {
                  const q = p.stock_status === 'untracked' ? null : (stockMap?.[p.id] ?? null)
                  return q === null || q > 0
                }).map((p: Product) => {
                  const price = mode === 'wholesale' ? Number(p.wholesale_price) || Number(p.retail_price) : Number(p.retail_price)
                  const qty = p.stock_status === 'untracked' ? null : (stockMap?.[p.id] ?? null)
                  return (
                    <tr key={p.id} onClick={() => handleAddProduct(p)}
                      className="border-t border-slate-100 hover:bg-blue-50 cursor-pointer transition-colors">
                      <td className="py-2 px-2 font-semibold text-slate-800">{p.name}</td>
                      <td className="py-2 px-2">{p.shelf_number ? <span className="text-xs px-1 py-0.5 rounded bg-indigo-50 text-indigo-600 font-bold">{p.shelf_number}</span> : <span className="text-slate-300">—</span>}</td>
                      <td className="py-2 px-2 font-black" style={{ color: '#c8a84b' }}>{price.toLocaleString('ar-EG')}</td>
                      <td className="py-2 px-2">
                        {qty !== null ? (
                          <span className={`font-bold px-1 rounded ${
                            qty <= 0 ? 'text-red-500' : qty <= 5 ? 'text-amber-600' : 'text-green-600'
                          }`}>{qty}</span>
                        ) : <span className="text-slate-300">—</span>}
                      </td>
                      <td className="py-2 px-2 text-blue-500 font-bold text-sm">+</td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
          </>
          )}
        </div>
      )}

      {/* Cart tab */}
      {mobileTab === 'cart' && (
        <div className="flex-1 flex flex-col min-h-0">
          {/* Cart header */}
          <div className="px-4 py-3 flex-shrink-0" style={{ background: '#1e3a5f' }}>
            <div className="flex items-center justify-between mb-2">
              <div className="flex gap-1">
                <button onClick={() => setMode('retail')} className={`px-2.5 py-1 rounded-lg text-xs font-bold ${mode === 'retail' ? 'bg-white text-slate-800' : 'text-white/60'}`}>قطاعي</button>
                <button onClick={() => setMode('wholesale')} className={`px-2.5 py-1 rounded-lg text-xs font-bold ${mode === 'wholesale' ? 'bg-white text-slate-800' : 'text-white/60'}`}>جملة</button>
                <button onClick={() => setIsCredit(v => !v)} className={`px-2.5 py-1 rounded-lg text-xs font-bold border ${isCredit ? 'bg-amber-400 text-slate-900 border-amber-300' : 'border-white/20 text-white/60'}`}>آجل</button>
              </div>
              <div className="flex gap-1">
                {splitPayments.length === 0 && !isCredit ? (
                  <>
                    <button onClick={() => { setPaymentMethod('cash'); setPaymentWalletId('') }}
                      className={`px-2 py-1 rounded-lg text-xs font-bold ${paymentMethod === 'cash' ? 'bg-blue-500 text-white' : 'text-white/60 border border-white/20'}`}>💵</button>
                    {(wallets || []).filter(w => w.type !== 'cash').map(w => (
                      <button key={w.id} onClick={() => { setPaymentMethod('wallet'); setPaymentWalletId(w.id) }}
                        className={`px-2 py-1 rounded-lg text-xs font-bold whitespace-nowrap ${paymentMethod === 'wallet' && paymentWalletId === w.id ? 'bg-blue-500 text-white' : 'text-white/60 border border-white/20'}`}>
                        {w.type === 'vodafone_cash' ? '📱' : '💳'} {w.name}
                      </button>
                    ))}
                    <button onClick={() => { setSplitPayments([{ method: 'cash', amount: total() }]); setPaymentMethod('cash'); setPaymentWalletId('') }}
                      className="px-2 py-1 rounded-lg text-xs font-bold text-white/60 border border-white/20">قسط</button>
                  </>
                ) : isCredit ? null : (
                  <div className="flex items-center gap-1">
                    <span className="text-[10px] text-white/50">{splitPayments.length} أقساط</span>
                    <button onClick={() => setSplitPayments([])} className="text-white/50 text-xs px-1">✕</button>
                  </div>
                )}
                {items.length > 0 && <button onClick={() => setConfirmClear(true)} className="text-white/50 text-xs px-1">✕</button>}
              </div>
            </div>
            {/* Customer */}
            <div className="relative">
              <input
                value={selectedCustomer ? selectedCustomer.name : customerInput}
                onChange={e => { setCustomerSearch(e.target.value); setSelectedCustomer(null); setCustomerInput(e.target.value); setShowCustomerDrop(true) }}
                onFocus={() => setShowCustomerDrop(true)}
                onBlur={() => setTimeout(() => setShowCustomerDrop(false), 200)}
                className="w-full bg-white/10 border border-white/20 rounded-lg px-3 py-2 text-white text-sm placeholder-white/30 outline-none focus:border-yellow-400 transition-all"
                placeholder="اسم العميل (اختياري)" />
              {showCustomerDrop && (customerResults?.length > 0 || customerSearch.length > 1) && (
                <div className="absolute top-full right-0 left-0 mt-1 bg-white rounded-xl shadow-xl border border-slate-200 z-50 max-h-40 overflow-y-auto">
                  {customerResults?.map((c: Customer) => (
                    <button key={c.id} onMouseDown={() => { setSelectedCustomer(c); setCustomer(c.name); setCustomerSearch(''); setShowCustomerDrop(false) }}
                      className="w-full text-right px-4 py-2.5 hover:bg-slate-50 text-sm border-b border-slate-50 last:border-0">
                      <p className="font-semibold text-slate-800">{c.name}</p>
                    </button>
                  ))}
                  {customerSearch.length > 1 && (
                    <button onMouseDown={() => {
                      if (isCredit) { setPendingCustomerName(customerSearch); setNewCustomerPhone(''); setShowPhoneModal(true); setShowCustomerDrop(false); return }
                      customersApi.create({ name: customerSearch }).then(c => {
                        setSelectedCustomer(c); setCustomer(c.name); setCustomerSearch(''); setShowCustomerDrop(false)
                      })
                    }} className="w-full text-right px-4 py-2.5 hover:bg-slate-50 text-sm border-t border-slate-100 flex items-center gap-2 text-blue-600">
                      <span>+</span> إضافة "{customerSearch}" كعميل جديد{isCredit ? ' (آجل — يلزم تليفون)' : ''}
                    </button>
                  )}
                </div>
              )}
            </div>
          </div>

          {/* Cart items */}
          <div className="flex-1 overflow-y-auto p-3 space-y-2">
            {!items.length && (
              <div className="text-center py-16 text-slate-300">
                <ShoppingCart size={40} className="mx-auto mb-3 opacity-30" />
                <p className="text-sm">السلة فارغة</p>
              </div>
            )}
            {items.map((item) => {
              const lineTotal = item.qty * item.unit_price
              const itemDiscAmt = item.item_discount || (item.item_discount_pct ? lineTotal * item.item_discount_pct / 100 : 0)
              const lineNet = lineTotal - itemDiscAmt
              const belowCost = item.unit_price < item.unit_cost
              return (
                <div key={item.product_id} className={`bg-white rounded-xl border p-3 ${belowCost ? 'border-red-200' : 'border-slate-100'}`}>
                  <div className="flex items-start justify-between gap-2">
                    <div className="flex-1 min-w-0">
                      <p className="font-bold text-slate-800 text-sm leading-tight truncate">{item.name}</p>
                      <p className="text-xs text-slate-400">{item.unit}</p>
                    </div>
                    <button onClick={() => removeItem(item.product_id)} className="text-slate-300 hover:text-red-500 flex-shrink-0">
                      <X size={14} />
                    </button>
                  </div>
                  <div className="flex items-center justify-between mt-2">
                    {/* Qty */}
                    <div className="flex items-center gap-1">
                      <button onClick={() => updateQty(item.product_id, item.qty - 1)} className="w-7 h-7 rounded-lg bg-slate-100 flex items-center justify-center text-slate-600 active:scale-90"><Minus size={12} /></button>
                      <span className="w-8 text-center font-bold text-sm">{item.qty}</span>
                      <button onClick={() => updateQty(item.product_id, item.qty + 1)} className="w-7 h-7 rounded-lg bg-slate-100 flex items-center justify-center text-slate-600 active:scale-90"><Plus size={12} /></button>
                    </div>
                    {/* Price */}
                    <input type="number" min="0" step="0.01"
                      value={item.unit_price}
                      onChange={e => { const v = Number(e.target.value); if (v > 0) updatePrice(item.product_id, v) }}
                      onBlur={e => { if (Number(e.target.value) < item.unit_cost) updatePrice(item.product_id, item.unit_cost) }}
                      className={`w-20 text-center text-sm font-bold border rounded-lg py-1 outline-none ${belowCost ? 'border-red-300 bg-red-50' : 'border-slate-200'}`} />
                    {/* Total */}
                    <p className="font-black text-sm w-16 text-left" style={{ color: belowCost ? '#dc2626' : '#1e3a5f' }}>{lineNet.toLocaleString('ar-EG')}</p>
                  </div>
                </div>
              )
            })}
          </div>

          {/* Checkout footer */}
          <div className="p-3 border-t border-slate-100 flex-shrink-0 space-y-2">
            {totalDiscount() > 0 && (
              <div className="flex justify-between text-xs text-red-500"><span>الخصم</span><span>- {totalDiscount().toLocaleString('ar-EG')} ج.م</span></div>
            )}
            <div className="flex justify-between items-center">
              <span className="text-slate-500 text-sm">الإجمالي</span>
              <span className="text-2xl font-black" style={{ color: '#1e3a5f' }}>{total().toLocaleString('ar-EG')} ج.م</span>
            </div>
            <button onClick={() => checkoutMut.mutate()}
              disabled={!items.length || checkoutMut.isPending || (isCredit && !selectedCustomer)}
              className="w-full py-4 rounded-xl font-black text-lg active:scale-95 disabled:opacity-50 flex items-center justify-center gap-2"
              style={{ background: items.length ? '#c8a84b' : '#e2e8f0', color: items.length ? '#1e3a5f' : '#94a3b8' }}>
              <CheckCircle size={20} />
              {checkoutMut.isPending ? 'جاري...' : isCredit && !selectedCustomer ? '⚠️ حدد عميل' : 'تأكيد الدفع'}
            </button>
            {/* Quick actions */}
            <div className="grid grid-cols-4 gap-1.5">
              <button onClick={() => setShowReturn(true)} className="py-2 rounded-xl text-xs font-bold bg-amber-50 text-amber-700 border border-amber-200">↩ مرتجع</button>
              <button onClick={() => { setShowDrawerEntry(true); setDrawerEntryType('expense') }} disabled={!shift} className="py-2 rounded-xl text-xs font-bold bg-red-50 text-red-600 border border-red-200 disabled:opacity-40">خوارج</button>
              <button onClick={() => { setShowDrawerEntry(true); setDrawerEntryType('deposit') }} disabled={!shift} className="py-2 rounded-xl text-xs font-bold bg-green-50 text-green-700 border border-green-200 disabled:opacity-40">دواخل</button>
              <button onClick={() => setShowLedger(true)} className="py-2 rounded-xl text-xs font-bold bg-slate-100 text-slate-600">سجل</button>
            </div>
          </div>
        </div>
      )}

      {/* Bottom tab bar */}
      <div className="flex-shrink-0 border-t border-slate-200 bg-white flex" style={{ paddingBottom: 'env(safe-area-inset-bottom)' }}>
        <button onClick={() => setMobileTab('products')}
          className={`flex-1 py-3 flex flex-col items-center gap-0.5 text-xs font-bold transition-colors ${mobileTab === 'products' ? 'text-blue-600' : 'text-slate-400'}`}>
          <Search size={20} />
          <span>منتجات</span>
        </button>
        <button onClick={() => setMobileTab('cart')}
          className={`flex-1 py-3 flex flex-col items-center gap-0.5 text-xs font-bold transition-colors relative ${mobileTab === 'cart' ? 'text-blue-600' : 'text-slate-400'}`}>
          <ShoppingCart size={20} />
          <span>السلة</span>
          {items.length > 0 && (
            <span className="absolute top-2 right-1/2 translate-x-4 -translate-y-0.5 w-5 h-5 rounded-full bg-red-500 text-white text-xs flex items-center justify-center font-black">{items.length}</span>
          )}
        </button>
      </div>
    </div>{/* end mobile */}


      <HeldInvoicesModal showHeld={showHeld} onClose={() => setShowHeld(false)} holdLabel={holdLabel} setHoldLabel={setHoldLabel} suspended={suspended} items={items} mainWh={mainWh} shift={shift} holdCurrent={holdCurrent} resume={resume} deleteHeld={deleteHeld} convertToQuotationMut={convertToQuotationMut} setShowHeld={setShowHeld} />


      <ReturnModal showReturn={showReturn} onClose={() => setShowReturn(false)} returnSearch={returnSearch} setReturnSearch={setReturnSearch} allSales={allSales} setShowReturn={setShowReturn} setReturnSaleDetails={setReturnSaleDetails} setReturnQtys={setReturnQtys} returnSaleDetails={returnSaleDetails} returnQtys={returnQtys} returnMut={returnMut} />

      {/* Drawer Entry Modal (خوارج / دواخل) */}
      <DrawerEntryModal showDrawerEntry={showDrawerEntry} onClose={() => setShowDrawerEntry(false)} drawerEntryType={drawerEntryType} drawerEntryAmount={drawerEntryAmount} setDrawerEntryAmount={setDrawerEntryAmount} drawerEntryCategoryId={drawerEntryCategoryId} setDrawerEntryCategoryId={setDrawerEntryCategoryId} drawerEntryPaymentMethod={drawerEntryPaymentMethod} setDrawerEntryPaymentMethod={setDrawerEntryPaymentMethod} drawerEntryWalletId={drawerEntryWalletId} setDrawerEntryWalletId={setDrawerEntryWalletId} drawerEntryNote={drawerEntryNote} setDrawerEntryNote={setDrawerEntryNote} finCategories={finCategories} wallets={wallets} drawerEntryMut={drawerEntryMut} />

      {/* Customer Debt Payment Modal */}
      <CustomerDebtModal showCustomerDebt={showCustomerDebt} onClose={() => { setShowCustomerDebt(false); setDebtCustomer(null); setDebtCustomerSearch('') }} debtCustomer={debtCustomer} setDebtCustomer={setDebtCustomer} debtCustomerSearch={debtCustomerSearch} setDebtCustomerSearch={setDebtCustomerSearch} debtCustomerResults={debtCustomerResults} debtCustomerAccount={debtCustomerAccount} debtCustomerLedger={debtCustomerLedger} debtPayAmount={debtPayAmount} setDebtPayAmount={setDebtPayAmount} debtPayNote={debtPayNote} setDebtPayNote={setDebtPayNote} debtPayMut={debtPayMut} setShowCustomerDebt={setShowCustomerDebt} />

      {/* Today's Ledger Modal */}
      <LedgerModal showLedger={showLedger} onClose={() => setShowLedger(false)} todayLedger={todayLedger} confirmDelItem={confirmDelItem} setConfirmDelItem={setConfirmDelItem} confirmDelReturn={confirmDelReturn} setConfirmDelReturn={setConfirmDelReturn} confirmDelTx={confirmDelTx} setConfirmDelTx={setConfirmDelTx} shift={shift} qc={qc} />

      {/* Legacy expense modal — kept for backward compat, hidden */}
      <Modal open={showExpense} onClose={() => setShowExpense(false)} title="تسجيل خوارج">
        <div className="space-y-4">
          <div><label className="block text-sm font-medium text-slate-600 mb-1">المبلغ</label><input type="number" className="input" value={expenseAmount} onChange={e => setExpenseAmount(e.target.value)} /></div>
          <div><label className="block text-sm font-medium text-slate-600 mb-1">البيان</label><input className="input" value={expenseNote} onChange={e => setExpenseNote(e.target.value)} /></div>
          <div className="flex gap-3 justify-end">
            <button onClick={() => setShowExpense(false)} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
            <button onClick={() => expenseMut.mutate()} disabled={!expenseAmount} className="px-5 py-2 rounded-xl text-sm font-bold text-white bg-red-600">تسجيل</button>
          </div>
        </div>
      </Modal>
      {/* Open Shift Modal */}
      <OpenShiftModal showOpenShift={showOpenShift} onClose={() => setShowOpenShift(false)} mainWh={mainWh} lastDrawer={lastDrawer} supervisorId={supervisorId} setSupervisorId={setSupervisorId} allUsers={allUsers} openShiftMut={openShiftMut} />

      {/* Handover Modal — requires receiving employee password */}
      <HandoverModal showHandover={showHandover} onClose={() => setShowHandover(false)} summary={summary} handoverUsername={handoverUsername} setHandoverUsername={setHandoverUsername} handoverPassword={handoverPassword} setHandoverPassword={setHandoverPassword} handoverMut={handoverMut} />

      {/* Close Shift Modal */}
      <CloseShiftModal showClose={showClose} onClose={() => setShowClose(false)} summary={summary} closingBalance={closingBalance} setClosingBalance={setClosingBalance} nextDayDrawer={nextDayDrawer} setNextDayDrawer={setNextDayDrawer} closeSafeId={closeSafeId} setCloseSafeId={setCloseSafeId} managerIdForClose={managerIdForClose} setManagerIdForClose={setManagerIdForClose} managerPasswordForClose={managerPasswordForClose} setManagerPasswordForClose={setManagerPasswordForClose} allUsers={allUsers} safes={safes} closeMut={closeMut} />

      {/* Phone required modal for credit customers */}
      {/* Revenue delivery modal */}
      <RevenueDeliveryModal showRevenueDelivery={showRevenueDelivery} onClose={() => { setShowRevenueDelivery(false); setRevenueAmount(''); setRevenueSafeId(''); setRevenueManagerId(''); setRevenueManagerPassword(''); setRevenueNotes('') }} summary={summary} revenueAmount={revenueAmount} setRevenueAmount={setRevenueAmount} revenueSafeId={revenueSafeId} setRevenueSafeId={setRevenueSafeId} revenueNotes={revenueNotes} setRevenueNotes={setRevenueNotes} revenueManagerId={revenueManagerId} setRevenueManagerId={setRevenueManagerId} revenueManagerPassword={revenueManagerPassword} setRevenueManagerPassword={setRevenueManagerPassword} allUsers={allUsers} safes={safes} revenueMut={revenueMut} />

      {/* Split payment modal */}
      <SplitPaymentModal showSplitModal={showSplitModal} onClose={() => setShowSplitModal(false)} splitMethod={splitMethod} setSplitMethod={setSplitMethod} splitAmount={splitAmount} setSplitAmount={setSplitAmount} splitWalletId={splitWalletId} setSplitWalletId={setSplitWalletId} wallets={wallets} total={total} splitPayments={splitPayments} setSplitPayments={setSplitPayments} setShowSplitModal={setShowSplitModal} />

      <PhoneModal showPhoneModal={showPhoneModal} onClose={() => setShowPhoneModal(false)} pendingCustomerName={pendingCustomerName} setPendingCustomerName={setPendingCustomerName} newCustomerPhone={newCustomerPhone} setNewCustomerPhone={setNewCustomerPhone} setSelectedCustomer={setSelectedCustomer} setCustomer={setCustomer} setCustomerSearch={setCustomerSearch} />


      <ConfirmDialog open={!!confirmDelItem} onClose={() => setConfirmDelItem(null)}
        onConfirm={() => { const item = confirmDelItem; api.delete(`/sales/${item.sale_id}/items/${item.item_id}`).then(() => { toast.success('✅ تم حذف البند'); qc.invalidateQueries({ queryKey: ['pos-ledger'] }); qc.invalidateQueries({ queryKey: ['shift-summary', shift?.id] }) }).catch((e: any) => toast.error(e.response?.data?.detail || 'فشل')) }}
        message={`حذف "${confirmDelItem?.product_name || ''}" من الفاتورة؟`} danger />
      <ConfirmDialog open={!!confirmDelReturn} onClose={() => setConfirmDelReturn(null)}
        onConfirm={() => { const item = confirmDelReturn; api.delete(`/sales/${item.sale_id}/items/${item.item_id}`).then(() => { toast.success('✅ تم الحذف'); qc.invalidateQueries({ queryKey: ['pos-ledger'] }); qc.invalidateQueries({ queryKey: ['shift-summary', shift?.id] }) }).catch((e: any) => toast.error(e.response?.data?.detail || 'فشل')) }}
        message={`حذف مرتجع "${confirmDelReturn?.product_name || ''}"؟`} danger />
      <ConfirmDialog open={!!confirmDelTx} onClose={() => setConfirmDelTx(null)}
        onConfirm={() => { const e = confirmDelTx; api.delete(`/shifts/transactions/${e.tx_id}`).then(() => { toast.success('✅ تم الحذف'); qc.invalidateQueries({ queryKey: ['pos-ledger'] }); qc.invalidateQueries({ queryKey: ['shift-summary', shift?.id] }) }).catch((ex: any) => toast.error(ex.response?.data?.detail || 'فشل')) }}
        message={`حذف "${confirmDelTx?.type_ar || ''} — ${confirmDelTx?.note || ''}"؟`} danger />
      <ConfirmDialog open={confirmClear} onClose={() => setConfirmClear(false)}
        onConfirm={() => { clear(); setConfirmClear(false) }}
        message="مسح جميع الأصناف من السلة؟" danger confirmText="مسح" title="تأكيد المسح" />
    </div>
  )
}
