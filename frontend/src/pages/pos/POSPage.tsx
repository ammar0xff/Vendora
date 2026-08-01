import { useState, useEffect, useRef, useCallback } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { productsApi, salesApi, stockApi, shiftsApi, customersApi, categoriesApi, subcategoriesApi } from '../../api/endpoints'
import api from '../../api/client'
import { usePOSStore, type HeldBill } from '../../store/pos'
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
  X, Wallet, ArrowLeftRight, Lock, Printer, RotateCcw,
  ChevronDown, ChevronLeft, Tag, DollarSign, BookOpen,
  LayoutGrid, List, Landmark, Package
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
  const [productPage, setProductPage] = useState(1)

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
  useEffect(() => { setProductPage(1) }, [debouncedSearch, selectedCat, selectedSub])
  const { data: summary } = useQuery({
    queryKey: ['shift-summary', shift?.id], queryFn: () => shiftsApi.summary(shift!.id),
    enabled: !!shift?.id, refetchInterval: 15_000,
  })

  const { data: productsPage, isLoading } = useQuery({
    queryKey: ['products', debouncedSearch, selectedCat, selectedSub, productPage, mainWh?.id],
    queryFn: () => productsApi.listPage({ 
      page: productPage, 
      page_size: 24,
      ...(debouncedSearch ? { search: debouncedSearch } : {}), 
      ...(selectedSub ? { subcategory_id: selectedSub } : selectedCat ? { category_id: selectedCat } : {}),
      ...(mainWh?.id ? { warehouse_id: mainWh?.id } : {}) 
    }),
    staleTime: 30_000,
  })
  const products = productsPage?.items
  const productsTotal = productsPage?.total || 0
  const productPages = productsPage?.pages || 1

  // Collections — shown in search results
  const { data: collections } = useQuery({
    queryKey: ['collections'],
    queryFn: () => api.get('/collections').then(r => r.data?.items ?? r.data),
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
  const [catPage, setCatPage] = useState(0)
  const [subPage, setSubPage] = useState(0)
  const CATS_PER_PAGE = 8
  const SUBS_PER_PAGE = 8
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
      handleAddProduct(p); setSearch(''); setDebouncedSearch('')
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
    <div className="hidden lg:flex flex-col h-[calc(100vh-7rem)]">

      {/* POS Header bar (VB6-style: title + nav buttons + drawer badge) */}
      <div className="flex items-center justify-between px-4 py-2 bg-white border border-slate-200 rounded-t-xl flex-shrink-0">
        <div className="flex items-center gap-3">
          <DrawerBadge shift={shift} summary={summary} onOpen={() => setShowOpenShift(true)} onHandover={() => setShowHandover(true)} onClose={() => setShowClose(true)} onRevenueDelivery={() => setShowRevenueDelivery(true)} warehouseName={mainWh?.name}
            supervisorName={shift?.supervisor_id ? (allUsers as User[])?.find((u) => u.id === shift.supervisor_id)?.full_name : null}
            wallets={wallets} currentUserId={user?.id} />
        </div>
        <h1 className="text-sm font-bold text-slate-600">فاتورة كاشير — {mainWh?.name}</h1>
      </div>

      {/* ═══ Split screen: RIGHT panel (Products+Cats) | LEFT panel (Cart) ═══ */}
      <div className="flex flex-1 min-h-0 border-x border-b border-slate-200 rounded-b-xl overflow-hidden">

        {/* ══════ RIGHT PANEL (Products & Categories) ══════ */}
        <div className="flex flex-col flex-1 min-w-0">

          {/* ── Search bar at top ── */}
          <div className="relative px-3 pt-2 pb-1 flex-shrink-0">
            <Search size={14} className="absolute right-5 top-1/2 -translate-y-1/2 text-slate-400" />
            <input value={search}
              onChange={e => { setSearch(e.target.value); if (e.target.value) { setSelectedCat(null); setSelectedSub(null) } }}
              onKeyDown={e => e.key === 'Enter' && handleBarcodeSearch()}
              className="w-full pr-8 pl-3 py-1.5 rounded-lg text-xs border border-slate-200 bg-white text-slate-700 placeholder-slate-400 outline-none focus:border-blue-400 transition-all"
              placeholder="ابحث عن صنف أو امسح الباركود..." />
          </div>

          {/* ── Horizontal Categories Bar ── */}
          <div className="flex-shrink-0 bg-white border-b border-slate-200">
            {/* Main categories row */}
            {(() => {
              const allCats = (categories as Category[]) || []
              const totalCatPages = Math.max(1, Math.ceil(allCats.length / CATS_PER_PAGE))
              const catStart = catPage * CATS_PER_PAGE
              const visibleCats = allCats.slice(catStart, catStart + CATS_PER_PAGE)
              return (
                <div className="flex items-center gap-1 px-2 py-1.5">
                  <button onClick={() => setCatPage(p => Math.max(0, p - 1))}
                    disabled={catPage === 0}
                    className="flex-shrink-0 w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold transition-colors disabled:opacity-20 disabled:cursor-default bg-slate-100 hover:bg-slate-200 text-slate-500">
                    ▶
                  </button>
                  <div className="flex gap-1 flex-1 overflow-hidden">
                    <button onClick={() => { setSelectedCat(null); setSelectedSub(null); setCatPage(0) }}
                      className={clsx('flex-shrink-0 px-3 py-1.5 rounded-lg text-[10px] font-bold transition-colors whitespace-nowrap',
                        !selectedCat ? 'bg-[#1e3a5f] text-white' : 'bg-slate-100 text-slate-600 hover:bg-slate-200')}>
                      الكل
                    </button>
                    {visibleCats.map(cat => (
                      <button key={cat.id} onClick={() => { setSelectedCat(cat.id); setSelectedSub(null); setSubPage(0) }}
                        className={clsx('flex-shrink-0 px-3 py-1.5 rounded-lg text-[10px] font-bold transition-colors whitespace-nowrap',
                          selectedCat === cat.id && !selectedSub ? 'bg-[#1e3a5f] text-white' : 'bg-slate-100 text-slate-600 hover:bg-slate-200')}>
                        {cat.name}
                      </button>
                    ))}
                  </div>
                  <button onClick={() => setCatPage(p => Math.min(totalCatPages - 1, p + 1))}
                    disabled={catPage >= totalCatPages - 1}
                    className="flex-shrink-0 w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold transition-colors disabled:opacity-20 disabled:cursor-default bg-slate-100 hover:bg-slate-200 text-slate-500">
                    ◀
                  </button>
                </div>
              )
            })()}

            {/* Subcategories row (visible when a main category is selected) */}
            {selectedCat && getSubsForCat(selectedCat).length > 0 && (() => {
              const subs = getSubsForCat(selectedCat)
              const totalSubPages = Math.max(1, Math.ceil(subs.length / SUBS_PER_PAGE))
              const subStart = subPage * SUBS_PER_PAGE
              const visibleSubs = subs.slice(subStart, subStart + SUBS_PER_PAGE)
              return (
                <div className="flex items-center gap-1 px-2 py-1.5 border-t border-slate-100">
                  <button onClick={() => setSubPage(p => Math.max(0, p - 1))}
                    disabled={subPage === 0}
                    className="flex-shrink-0 w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold transition-colors disabled:opacity-20 disabled:cursor-default bg-slate-100 hover:bg-slate-200 text-slate-500">
                    ▶
                  </button>
                  <div className="flex gap-1 flex-1 overflow-hidden">
                    <button onClick={() => setSelectedSub(null)}
                      className={clsx('flex-shrink-0 px-3 py-1.5 rounded-lg text-[10px] font-bold transition-colors whitespace-nowrap',
                        !selectedSub ? 'bg-amber-500 text-white' : 'bg-amber-50 text-amber-700 hover:bg-amber-100')}>
                      {(categories as Category[])?.find(c => c.id === selectedCat)?.name || 'الكل'}
                    </button>
                    {visibleSubs.map(sub => (
                      <button key={sub.id} onClick={() => setSelectedSub(sub.id)}
                        className={clsx('flex-shrink-0 px-3 py-1.5 rounded-lg text-[10px] font-bold transition-colors whitespace-nowrap',
                          selectedSub === sub.id ? 'bg-[#2d5a8e] text-white' : 'bg-slate-100 text-slate-500 hover:bg-slate-200')}>
                        {sub.name}
                      </button>
                    ))}
                  </div>
                  <button onClick={() => setSubPage(p => Math.min(totalSubPages - 1, p + 1))}
                    disabled={subPage >= totalSubPages - 1}
                    className="flex-shrink-0 w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold transition-colors disabled:opacity-20 disabled:cursor-default bg-slate-100 hover:bg-slate-200 text-slate-500">
                    ◀
                  </button>
                </div>
              )
            })()}
          </div>

          {/* ── Center: Product display grid ── */}
          <div className="flex-1 flex flex-col bg-slate-50 min-w-0 overflow-hidden">
            {/* Header */}
            <div className="flex items-center justify-between px-4 py-2 border-b border-slate-200 bg-white flex-shrink-0">
              <h3 className="text-xs font-bold text-slate-600">أصناف المجموعة</h3>
              <button onClick={() => setViewMode(viewMode === 'table' ? 'cards' : 'table')}
                className="flex items-center gap-1 px-2 py-1 rounded-lg text-[10px] font-bold border border-slate-200 text-slate-500 hover:bg-slate-100 transition-colors">
                {viewMode === 'table' ? <><LayoutGrid size={11} /> كروت</> : <><List size={11} /> جدول</>}
              </button>
            </div>

            {/* Product content */}
            {debouncedSearch ? (
              <div className="flex-1 overflow-y-auto px-3 py-3">
                {isLoading ? <PageLoader /> : !products?.length ? (
                  <div className="text-center py-12 text-slate-400 text-xs">لا توجد نتائج</div>
                ) : (
                  <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-2">
                    {products.map((p: any) => {
                      const price = mode === 'wholesale' ? Number(p.wholesale_price) || Number(p.retail_price) : Number(p.retail_price)
                      return (
                        <button key={p.id} onClick={() => handleAddProduct(p)}
                          className="bg-white rounded-xl border border-slate-200 p-2.5 text-right hover:border-blue-300 hover:shadow-md transition-all active:scale-95 flex flex-col">
                          <div className="flex items-start justify-between mb-1.5">
                            <div className="w-7 h-7 rounded-lg bg-gradient-to-br from-blue-100 to-blue-200 flex items-center justify-center flex-shrink-0">
                              <Package size={12} className="text-blue-600" />
                            </div>
                          </div>
                          <p className="text-[11px] font-bold text-slate-800 leading-tight line-clamp-2 mb-0.5">{p.name}</p>
                          {p.company && <p className="text-[10px] text-slate-400 mb-1">{p.company}</p>}
                          <div className="mt-auto">
                            <p className="text-xs font-black leading-none" style={{ color: '#c8a84b' }}>{Number(price).toLocaleString('ar-EG')} ج.م</p>
                          </div>
                        </button>
                      )
                    })}
                  </div>
                )}
                {productPages > 1 && (
                  <div className="flex items-center justify-center gap-2 pt-3">
                    <button onClick={() => setProductPage(p => Math.max(1, p - 1))}
                      disabled={productPage <= 1}
                      className="px-3 py-1.5 rounded-lg text-xs font-bold transition-all disabled:opacity-30 bg-slate-200 hover:bg-slate-300 text-slate-700">
                      السابق
                    </button>
                    <span className="text-xs text-slate-500 px-2">{productPage} / {productPages}</span>
                    <button onClick={() => setProductPage(p => Math.min(productPages, p + 1))}
                      disabled={productPage >= productPages}
                      className="px-3 py-1.5 rounded-lg text-xs font-bold transition-all disabled:opacity-30 bg-slate-200 hover:bg-slate-300 text-slate-700">
                      التالي
                    </button>
                  </div>
                )}
              </div>
            ) : viewMode === 'cards' ? (
              <div className="flex-1 min-h-0">
                <CategoryCardBrowser warehouseId={mainWh?.id} mode={mode} onAddProduct={(p) => handleAddProduct(p)} />
              </div>
            ) : (
              <div className="flex-1 overflow-y-auto">
                {isLoading ? <PageLoader /> : (
                  <>
                    {filteredCollections.length > 0 && (
                      <div className="px-3 pt-3">
                        <p className="text-[10px] font-bold text-slate-400 mb-1.5">📦 كوليكشنات</p>
                        <div className="grid grid-cols-3 gap-2 mb-3">
                          {filteredCollections.map((c) => {
                            const price = mode === 'wholesale' ? Number(c.wholesale_price) || Number(c.retail_price) : Number(c.retail_price)
                            return (
                              <button key={c.id} onClick={() => handleAddCollection(c)}
                                className="bg-white rounded-lg border border-amber-200 p-2 text-right hover:border-amber-400 hover:shadow-sm transition-all active:scale-95">
                                <p className="text-[10px] font-bold text-slate-700 leading-tight truncate">{c.name}</p>
                                <p className="text-[10px] text-slate-400">{c.items?.length || 0} منتج</p>
                                <p className="text-xs font-black mt-0.5" style={{ color: '#c8a84b' }}>{price.toLocaleString('ar-EG')} ج.م</p>
                              </button>
                            )
                          })}
                        </div>
                      </div>
                    )}
                    <table className="w-full text-right text-[11px]">
                      <thead className="sticky top-0 z-10" style={{ background: '#2d5a8e' }}>
                        <tr className="text-white font-bold">
                          <th className="py-1.5 px-2">المنتج</th>
                          <th className="py-1.5 px-2">الشركة</th>
                          <th className="py-1.5 px-2">الرف</th>
                          <th className="py-1.5 px-2">القطاعي</th>
                          <th className="py-1.5 px-2">الجملة</th>
                          <th className="py-1.5 px-2">المخزون</th>
                          <th className="py-1.5 px-2 w-6"></th>
                        </tr>
                      </thead>
                      <tbody>
                        {products?.length === 0 && (
                          <tr><td colSpan={7} className="text-center py-12 text-slate-400 text-xs">لا توجد أصناف في هذه المجموعة</td></tr>
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
                              className="border-b border-slate-200 hover:bg-blue-50 cursor-pointer transition-colors">
                              <td className="py-1.5 px-2 font-semibold text-slate-700">{p.name}</td>
                              <td className="py-1.5 px-2 text-slate-400 text-[10px]">{p.company || '—'}</td>
                              <td className="py-1.5 px-2">{p.shelf_number ? <span className="text-[10px] px-1 py-0.5 rounded bg-indigo-50 text-indigo-600 font-bold">{p.shelf_number}</span> : <span className="text-slate-300">—</span>}</td>
                              <td className="py-1.5 px-2 font-black" style={{ color: '#c8a84b' }}>{retailPrice.toLocaleString('ar-EG')}</td>
                              <td className="py-1.5 px-2 text-slate-600">{wholesalePrice.toLocaleString('ar-EG')}</td>
                              <td className="py-1.5 px-2">
                                {qty != null ? (
                                  <span className={`font-bold px-1 rounded ${qty <= 0 ? 'text-red-500' : qty <= 5 ? 'text-amber-600' : 'text-green-600'}`}>{qty}</span>
                                ) : <span className="text-slate-300">—</span>}
                              </td>
                              <td className="py-1.5 px-2 text-blue-500 font-bold text-sm">+</td>
                            </tr>
                          )
                        })}
                      </tbody>
                    </table>
                  </>
                )}
              </div>
            )}

            {/* Pagination controls */}
            {productPages > 1 && (
            <div className="flex items-center justify-center gap-4 py-2 border-t border-slate-200 bg-white flex-shrink-0">
              <button onClick={() => setProductPage(p => Math.max(1, p - 1))}
                disabled={productPage <= 1}
                className="flex items-center gap-1 px-3 py-1.5 rounded-lg text-[10px] font-bold transition-all disabled:opacity-30 text-slate-500 hover:bg-slate-100 border border-slate-200">
                <ChevronDown size={12} className="rotate-90" /> أصناف سابقة
              </button>
              <span className="text-[10px] text-slate-500">{productPage} / {productPages}</span>
              <button onClick={() => setProductPage(p => Math.min(productPages, p + 1))}
                disabled={productPage >= productPages}
                className="flex items-center gap-1 px-3 py-1.5 rounded-lg text-[10px] font-bold transition-all disabled:opacity-30 text-slate-500 hover:bg-slate-100 border border-slate-200">
                أصناف تالية <ChevronLeft size={12} />
              </button>
            </div>
            )}

            {/* Discount block */}
            <div className="px-4 py-2.5 border-t border-slate-200 bg-white flex-shrink-0">
              <div className="flex items-center gap-2">
                <span className="text-[11px] font-bold text-slate-500 whitespace-nowrap">خصم أصناف</span>
                <div className="relative flex-1 max-w-[120px]">
                  <input type="number" min="0" max="100" value={discountInput}
                    onChange={e => setDiscountInput(e.target.value)}
                    className="w-full text-center text-xs border border-slate-200 rounded-lg px-2 py-1.5 outline-none focus:border-blue-400" placeholder="0.00" />
                  <span className="absolute left-2 top-1/2 -translate-y-1/2 text-[10px] text-slate-400">%</span>
                </div>
                <button
                  onClick={() => { if (!discountInput) return; const pct = Number(discountInput); items.forEach(i => updateItemDiscount(i.product_id, 0, pct)); setDiscountInput(''); toast.success('تم تطبيق الخصم') }}
                  disabled={!discountInput || !items.length}
                  className="px-3 py-1.5 rounded-lg text-[10px] font-bold bg-slate-100 text-slate-600 hover:bg-slate-200 transition-colors disabled:opacity-40 border border-slate-200">
                  تطبيق خصم
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* ══════ LEFT PANEL (Transaction & Cart) ══════ */}
        <div ref={cartElRef} className="flex flex-col bg-white border-r border-slate-200 overflow-hidden" style={{ width: cartWidth }}>
          <div className="absolute right-0 top-0 bottom-0 w-1.5 cursor-col-resize z-10 group flex items-center justify-center"
            onMouseDown={handleDragStart}>
            <div className="w-0.5 h-8 rounded-full bg-slate-200 group-hover:bg-blue-400 transition-colors" />
          </div>

          {/* Top: Total display + Warehouse dropdown + mode toggles */}
          <div className="px-4 py-3 border-b border-slate-200 flex-shrink-0">
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <div className="flex rounded-lg overflow-hidden border border-slate-200">
                  <button onClick={() => setMode('retail')} className={clsx('px-2.5 py-1 text-[10px] font-bold transition-all', mode === 'retail' ? 'text-white' : 'text-slate-500 hover:bg-slate-50')} style={mode === 'retail' ? { background: '#1e3a5f' } : {}}>قطاعي</button>
                  <button onClick={() => setMode('wholesale')} className={clsx('px-2.5 py-1 text-[10px] font-bold transition-all', mode === 'wholesale' ? 'text-white' : 'text-slate-500 hover:bg-slate-50')} style={mode === 'wholesale' ? { background: '#1e3a5f' } : {}}>جملة</button>
                </div>
                <button onClick={() => setIsCredit(v => !v)}
                  className={clsx('px-2 py-1 rounded-lg text-[10px] font-bold border transition-all', isCredit ? 'bg-amber-400 text-slate-900 border-amber-300' : 'border-slate-200 text-slate-500 hover:bg-slate-50')}>
                  آجل
                </button>
              </div>
              <div className="flex items-center gap-2">
                <button onClick={() => setShowHeld(true)} className="text-[10px] text-slate-400 hover:text-slate-600">معلقة ({suspended.length})</button>
                {items.length > 0 && <button onClick={() => { holdCurrent({ label: holdLabel, warehouse_id: mainWh?.id, shift_id: shift?.id }); setHoldLabel('') }} className="text-[10px] text-slate-400 hover:text-slate-600">تعليق</button>}
                {items.length > 0 && <button onClick={() => setConfirmClear(true)} className="text-[10px] text-red-400 hover:text-red-600">مسح</button>}
              </div>
            </div>
            <div className="text-center mb-2">
              <p className="text-4xl font-black text-red-500 leading-none">{total().toLocaleString('ar-EG', { minimumFractionDigits: 2 })}</p>
              <p className="text-[10px] text-slate-400 mt-1">المبلغ الإجمالي — ج.م</p>
            </div>
            {/* Customer search */}
            <div className="relative">
              <input value={selectedCustomer ? selectedCustomer.name : customerInput}
                onChange={e => { setCustomerSearch(e.target.value); setSelectedCustomer(null); setCustomerInput(e.target.value); setShowCustomerDrop(true) }}
                onFocus={() => setShowCustomerDrop(true)}
                onBlur={() => setTimeout(() => setShowCustomerDrop(false), 200)}
                className="w-full bg-slate-50 border border-slate-200 rounded-lg px-3 py-1.5 text-[11px] text-slate-700 placeholder-slate-400 outline-none focus:border-blue-400 transition-all"
                placeholder="اسم العميل (اختياري)" />
              {showCustomerDrop && (customerResults?.length > 0 || customerSearch.length > 1) && (
                <div className="absolute top-full right-0 left-0 mt-1 bg-white rounded-xl shadow-xl border border-slate-200 z-50 max-h-40 overflow-y-auto">
                  {customerResults?.map((c: Customer) => (
                    <button key={c.id} onMouseDown={() => { setSelectedCustomer(c); setCustomer(c.name); setCustomerSearch(''); setShowCustomerDrop(false) }}
                      className="w-full text-right px-3 py-2 hover:bg-slate-50 text-xs border-b border-slate-50 last:border-0">
                      <p className="font-semibold text-slate-800">{c.name}</p>
                      {c.phone && <p className="text-[10px] text-slate-400">{c.phone}</p>}
                    </button>
                  ))}
                  {customerSearch.length > 1 && (
                    <button onMouseDown={() => {
                      if (isCredit) { setPendingCustomerName(customerSearch); setNewCustomerPhone(''); setShowPhoneModal(true); setShowCustomerDrop(false); return }
                      customersApi.create({ name: customerSearch }).then(c => { setSelectedCustomer(c); setCustomer(c.name); setCustomerSearch(''); setShowCustomerDrop(false) })
                    }} className="w-full text-right px-3 py-2 hover:bg-green-50 text-xs text-green-700 font-semibold">
                      + إضافة "{customerSearch}"{isCredit ? ' (يلزم تليفون)' : ''}
                    </button>
                  )}
                </div>
              )}
            </div>
          </div>

          {/* Item counter */}
          <div className="px-4 py-1.5 border-b border-slate-200 flex-shrink-0 bg-slate-50">
            <span className="text-[11px] font-bold text-slate-500">{items.length} / {items.reduce((s, i) => s + i.qty, 0)} صنف</span>
          </div>

          {/* Transaction table (VB6-style: كود الصنف | إسم الصنف | السعر | الكمية | الإجمالي) */}
          <div className="flex-1 overflow-y-auto">
            {!items.length ? (
              <div className="text-center py-12 text-slate-300">
                <ShoppingCart size={28} className="mx-auto mb-2 opacity-30" />
                <p className="text-[11px]">لا توجد أصناف</p>
              </div>
            ) : (
              <table className="w-full text-right text-[11px]">
                <thead className="sticky top-0 z-10" style={{ background: '#2d5a8e' }}>
                  <tr className="text-white font-bold">
                    <th className="py-1.5 px-2">كود الصنف</th>
                    <th className="py-1.5 px-2">إسم الصنف</th>
                    <th className="py-1.5 px-2 text-center">السعر</th>
                    <th className="py-1.5 px-2 text-center">الكمية</th>
                    <th className="py-1.5 px-2 text-center">الإجمالي</th>
                  </tr>
                </thead>
                <tbody>
                  {items.map((item, idx) => {
                    const lineTotal = item.qty * item.unit_price
                    const itemDiscAmt = item.item_discount_pct > 0 ? lineTotal * (item.item_discount_pct / 100) : item.item_discount
                    const lineNet = lineTotal - itemDiscAmt
                    const belowCost = lineNet < item.qty * item.unit_cost
                    return (
                      <tr key={item.product_id} onClick={() => removeItem(item.product_id)}
                        className={clsx('border-b border-slate-100 cursor-pointer', belowCost ? 'bg-red-50' : 'hover:bg-slate-50')}>
                        <td className="py-1.5 px-2 text-slate-400 font-mono text-[10px]">{idx + 1}</td>
                        <td className="py-1.5 px-2 font-semibold text-slate-700 max-w-[100px] truncate" title={item.name}>{item.name}</td>
                        <td className="py-1.5 px-2 text-center">
                          <input type="number" min="0" step="0.5" value={item.unit_price} onClick={e => e.stopPropagation()}
                            onChange={e => { const v = Number(e.target.value); if (v > 0) updatePrice(item.product_id, v) }}
                            onBlur={e => { if (Number(e.target.value) < item.unit_cost) updatePrice(item.product_id, item.unit_cost) }}
                            className={clsx('w-12 text-center text-[10px] font-bold border rounded py-0.5 outline-none',
                              item.unit_price < item.unit_cost ? 'border-red-300 bg-red-50' : 'border-slate-200')} />
                        </td>
                        <td className="py-1.5 px-2 text-center">
                          <div className="flex items-center justify-center gap-0.5" onClick={e => e.stopPropagation()}>
                            <button onClick={() => updateQty(item.product_id, item.qty - 1)} className="w-5 h-5 rounded bg-slate-200 hover:bg-slate-300 flex items-center justify-center"><Minus size={9} /></button>
                            <span className="w-6 text-center font-bold text-[11px]">{item.qty}</span>
                            <button onClick={() => updateQty(item.product_id, item.qty + 1)} className="w-5 h-5 rounded bg-slate-200 hover:bg-slate-300 flex items-center justify-center"><Plus size={9} /></button>
                          </div>
                        </td>
                        <td className={clsx('py-1.5 px-2 text-center font-black', belowCost ? 'text-red-600' : '')} style={!belowCost ? { color: '#1e3a5f' } : {}}>
                          {lineNet.toLocaleString('ar-EG')}
                        </td>
                      </tr>
                    )
                  })}
                </tbody>
              </table>
            )}
          </div>

          {/* Bottom checkout bar */}
          <div className="border-t border-slate-200 p-2 flex-shrink-0">
            <button onClick={() => checkoutMut.mutate()}
              disabled={!items.length || checkoutMut.isPending || (isCredit && !selectedCustomer)}
              className="w-full py-2 rounded-lg text-[11px] font-bold text-white transition-all disabled:opacity-40"
              style={{ background: items.length ? '#16a34a' : '#cbd5e1' }}>
              <Printer size={12} className="inline ml-1" />
              {checkoutMut.isPending ? 'جاري...' : `طباعة حفظ — ${total().toLocaleString('ar-EG', { minimumFractionDigits: 2 })} ج.م`}
            </button>
          </div>
        </div>{/* end LEFT panel */}

      </div>{/* end split screen */}

      {/* Invoice-level discount + checkout (only when items exist) */}
      {items.length > 0 && (
        <div className="flex items-center gap-3 px-4 py-2 bg-white border border-slate-200 rounded-b-xl flex-shrink-0 -mt-px">
          {splitPayments.length > 0 && !isCredit && (
            <div className="flex items-center gap-1 text-[10px] text-slate-400">
              <span>{splitPayments.length} أقساط</span>
              <button onClick={() => setSplitPayments([])} className="text-red-400 hover:text-red-600">✕</button>
            </div>
          )}
          <div className="flex-1" />
          <div className="flex items-center gap-2 text-xs text-slate-500">
            <span>خصم: <span className="font-bold text-red-500">{totalDiscount().toLocaleString('ar-EG')} ج.م</span></span>
            <span className="text-slate-300">|</span>
            <span>الإجمالي: <span className="font-black text-lg" style={{ color: '#1e3a5f' }}>{total().toLocaleString('ar-EG')} ج.م</span></span>
          </div>
          <button onClick={() => checkoutMut.mutate()}
            disabled={!items.length || checkoutMut.isPending || (isCredit && !selectedCustomer)}
            className="px-6 py-2 rounded-xl font-black text-sm transition-all active:scale-95 disabled:opacity-50 flex items-center gap-2"
            style={{ background: items.length ? '#c8a84b' : '#e2e8f0', color: items.length ? '#1e3a5f' : '#94a3b8' }}>
            <CheckCircle size={16} />
            {checkoutMut.isPending ? 'جاري...' : isCredit && !selectedCustomer ? 'حدد عميل' : isCredit ? 'تأكيد — آجل' : 'تأكيد الدفع'}
          </button>
        </div>
      )}

      {/* ── Bottom toolbar (VB6-style action buttons + discount) ── */}
      <div className="flex-shrink-0 mt-2 flex items-stretch gap-3">
        {/* Discount section */}
        <div className="flex items-center gap-2 bg-white rounded-xl border border-slate-200 px-3 py-2">
          <Tag size={13} className="text-slate-400" />
          <span className="text-[10px] font-bold text-slate-500">خصم أصناف</span>
          <div className="relative">
            <input type="number" min="0" max="100" value={discountInput}
              onChange={e => setDiscountInput(e.target.value)}
              className="w-16 text-center text-xs border border-slate-200 rounded-lg px-1 py-1 outline-none focus:border-blue-300" placeholder="%" />
            <span className="absolute left-1 top-1/2 -translate-y-1/2 text-[9px] text-slate-400">%</span>
          </div>
          <button
            onClick={() => { if (!discountInput) return; const pct = Number(discountInput); items.forEach(i => updateItemDiscount(i.product_id, 0, pct)); setDiscountInput(''); toast.success('تم تطبيق الخصم') }}
            disabled={!discountInput || !items.length}
            className="px-2 py-1 rounded-lg text-[10px] font-bold bg-slate-100 text-slate-600 hover:bg-slate-200 transition-colors disabled:opacity-40">
            تطبيق
          </button>
        </div>

        {/* Separator */}
        <div className="w-px bg-slate-200" />

        {/* Action buttons */}
        <div className="flex items-center gap-1.5 flex-wrap flex-1">
          {/* Barcode / code entry */}
          <div className="flex items-center gap-1 bg-white rounded-xl border border-slate-200 px-2 py-1.5">
            <Search size={12} className="text-slate-400" />
            <input ref={searchRef} value={search}
              onChange={e => { setSearch(e.target.value); if (e.target.value) { setSelectedCat(null); setSelectedSub(null) } }}
              onKeyDown={e => e.key === 'Enter' && handleBarcodeSearch()}
              className="w-32 text-[11px] bg-transparent outline-none placeholder-slate-400" placeholder="إدخال كود / باركود..." />
          </div>

          {/* Quick action buttons */}
          <button onClick={() => setShowReturn(true)}
            className="flex items-center gap-1 px-2.5 py-1.5 rounded-xl text-[10px] font-bold bg-amber-50 text-amber-700 border border-amber-200 hover:bg-amber-100 transition-colors">
            <RotateCcw size={11} /> مرتجع
          </button>
          <button onClick={() => { setShowDrawerEntry(true); setDrawerEntryType('expense') }} disabled={!shift}
            className="flex items-center gap-1 px-2.5 py-1.5 rounded-xl text-[10px] font-bold bg-red-50 text-red-600 border border-red-200 hover:bg-red-100 transition-colors disabled:opacity-40">
            <Trash2 size={11} /> خوارج
          </button>
          <button onClick={() => { setShowDrawerEntry(true); setDrawerEntryType('deposit') }} disabled={!shift}
            className="flex items-center gap-1 px-2.5 py-1.5 rounded-xl text-[10px] font-bold bg-green-50 text-green-700 border border-green-200 hover:bg-green-100 transition-colors disabled:opacity-40">
            <DollarSign size={11} /> دواخل
          </button>
          <button onClick={() => setShowCustomerDebt(true)} disabled={!shift}
            className="flex items-center gap-1 px-2.5 py-1.5 rounded-xl text-[10px] font-bold bg-blue-50 text-blue-700 border border-blue-200 hover:bg-blue-100 transition-colors disabled:opacity-40">
            <DollarSign size={11} /> دفع عميل
          </button>
          <button onClick={() => setShowLedger(true)}
            className="flex items-center gap-1 px-2.5 py-1.5 rounded-xl text-[10px] font-bold bg-slate-100 text-slate-600 border border-slate-200 hover:bg-slate-200 transition-colors">
            <BookOpen size={11} /> سجل اليوم
          </button>
          {items.length > 0 && (
            <button onClick={() => { setMode(mode === 'wholesale' ? 'retail' : 'wholesale') }}
              className="flex items-center gap-1 px-2.5 py-1.5 rounded-xl text-[10px] font-bold bg-indigo-50 text-indigo-600 border border-indigo-200 hover:bg-indigo-100 transition-colors">
              <Tag size={11} /> {mode === 'wholesale' ? 'جملة' : 'قطاعي'}
            </button>
          )}
        </div>
      </div>

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

          {debouncedSearch ? (
            <div className="flex-1 min-h-0 overflow-y-auto">
              {isLoading ? <PageLoader /> : !products?.length ? (
                <div className="text-center py-12 text-slate-400 text-xs">لا توجد نتائج</div>
              ) : (
                <div className="grid grid-cols-2 gap-2.5">
                  {products.map((p: any) => {
                    const price = mode === 'wholesale' ? Number(p.wholesale_price) || Number(p.retail_price) : Number(p.retail_price)
                    return (
                      <button key={p.id} onClick={() => handleAddProduct(p)}
                        className="bg-white rounded-xl border border-slate-200 p-3 text-right hover:border-blue-300 hover:shadow-md transition-all active:scale-95 flex flex-col">
                        <div className="flex items-start justify-between mb-1.5">
                          <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-blue-100 to-blue-200 flex items-center justify-center flex-shrink-0">
                            <Package size={14} className="text-blue-600" />
                          </div>
                        </div>
                        <p className="text-xs font-bold text-slate-800 leading-tight line-clamp-2 mb-0.5">{p.name}</p>
                        {p.company && <p className="text-[10px] text-slate-400 mb-1">{p.company}</p>}
                        <div className="mt-auto">
                          <p className="text-sm font-black leading-none" style={{ color: '#c8a84b' }}>{Number(price).toLocaleString('ar-EG')} ج.م</p>
                        </div>
                      </button>
                    )
                  })}
                </div>
              )}
              {productPages > 1 && (
                <div className="flex items-center justify-center gap-2 pt-3 pb-1">
                  <button onClick={() => setProductPage(p => Math.max(1, p - 1))}
                    disabled={productPage <= 1}
                    className="px-3 py-1.5 rounded-lg text-xs font-bold transition-all disabled:opacity-30 bg-slate-200 hover:bg-slate-300 text-slate-700">
                    السابق
                  </button>
                  <span className="text-xs text-slate-500 px-2">{productPage} / {productPages}</span>
                  <button onClick={() => setProductPage(p => Math.min(productPages, p + 1))}
                    disabled={productPage >= productPages}
                    className="px-3 py-1.5 rounded-lg text-xs font-bold transition-all disabled:opacity-30 bg-slate-200 hover:bg-slate-300 text-slate-700">
                    التالي
                  </button>
                </div>
              )}
            </div>
          ) : viewMode === 'cards' ? (
            <div className="flex-1 min-h-0 flex flex-col">
              <CategoryCardBrowser warehouseId={mainWh?.id} mode={mode} onAddProduct={(p) => { handleAddProduct(p); }} />
            </div>
          ) : (
          <>
          {/* Category pills with paging */}
          <div className="flex items-center gap-1 pb-2 flex-shrink-0">
            {(() => {
              const cats = (categories as Category[]) || []
              const totalPages = Math.max(1, Math.ceil(cats.length / 6))
              return <>
                <button onClick={() => setCatPage(p => Math.min(totalPages - 1, p + 1))}
                  disabled={catPage >= totalPages - 1}
                  className="flex-shrink-0 w-5 h-5 rounded-full flex items-center justify-center text-[10px] font-bold transition-colors disabled:opacity-20 disabled:cursor-default bg-slate-200 text-slate-500">
                  ▶
                </button>
                <div className="flex gap-1.5 flex-1 overflow-hidden">
                  <button onClick={() => { setSelectedCat(null); setSelectedSub(null); setCatPage(0) }}
                    className="flex-shrink-0 px-3 py-1.5 rounded-full text-xs font-bold transition-all whitespace-nowrap"
                    style={!selectedCat ? { background: '#1e3a5f', color: 'white' } : { background: '#f1f5f9', color: '#64748b' }}>
                    الكل
                  </button>
                  {cats.slice(catPage * 6, (catPage + 1) * 6).map((cat) => (
                    <button key={cat.id} onClick={() => { setSelectedCat(cat.id); setSelectedSub(null); setSubPage(0) }}
                      className="flex-shrink-0 px-3 py-1.5 rounded-full text-xs font-bold transition-all whitespace-nowrap"
                      style={selectedCat === cat.id ? { background: '#1e3a5f', color: 'white' } : { background: '#f1f5f9', color: '#64748b' }}>
                      {cat.name}
                    </button>
                  ))}
                </div>
                <button onClick={() => setCatPage(p => Math.max(0, p - 1))}
                  disabled={catPage === 0}
                  className="flex-shrink-0 w-5 h-5 rounded-full flex items-center justify-center text-[10px] font-bold transition-colors disabled:opacity-20 disabled:cursor-default bg-slate-200 text-slate-500">
                  ◀
                </button>
              </>
            })()}
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
          {productPages > 1 && (
            <div className="flex items-center justify-center gap-2 pt-3 pb-1">
              <button onClick={() => setProductPage(p => Math.max(1, p - 1))}
                disabled={productPage <= 1}
                className="px-3 py-1.5 rounded-lg text-xs font-bold transition-all disabled:opacity-30 bg-slate-200 hover:bg-slate-300 text-slate-700">
                السابق
              </button>
              <span className="text-xs text-slate-500 px-2">
                {productPage} / {productPages}
              </span>
              <button onClick={() => setProductPage(p => Math.min(productPages, p + 1))}
                disabled={productPage >= productPages}
                className="px-3 py-1.5 rounded-lg text-xs font-bold transition-all disabled:opacity-30 bg-slate-200 hover:bg-slate-300 text-slate-700">
                التالي
              </button>
            </div>
          )}
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
