import { useState, useEffect, useRef } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { productsApi, salesApi, stockApi, shiftsApi, customersApi } from '../../api/endpoints'
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
import {
  Search, ShoppingCart, Trash2, Plus, Minus, CheckCircle,
  X, Wallet, ArrowLeftRight, Lock, Printer, RotateCcw, AlertCircle,
  ChevronDown, ChevronLeft, Tag, Layers, DollarSign, BookOpen
} from 'lucide-react'
import { clsx } from 'clsx'
import { useAuthStore } from '../../store/auth'
import { useAppStore } from '../../store/app'

// ── Drawer Balance Badge ──────────────────────────────────────────────────
function DrawerBadge({ shift, summary, onOpen, onHandover, onClose, warehouseName, supervisorName, wallets, currentUserId }: any) {
  if (!shift) return (
    <div className="flex items-center gap-2">
      <button onClick={onOpen} className="flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-bold text-white" style={{ background: '#16a34a' }}>
        <Wallet size={15} /> فتح وردية جديدة
      </button>
    </div>
  )
  const balance = Number(summary?.expected_balance ?? shift.initial_amount)
  const cashInDrawer = Number(summary?.cash_in_drawer ?? balance)
  const breakdown = summary?.payment_breakdown || []
  const walletTxBreakdown = summary?.wallet_tx_breakdown || []

  // Merge wallet sales + wallet deposits per wallet
  const walletMap: Record<string, { name: string; type: string; total: number }> = {}
  breakdown.filter((p: any) => p.method !== 'cash').forEach((p: any) => {
    const k = p.wallet_name
    if (!walletMap[k]) walletMap[k] = { name: p.wallet_name, type: p.wallet_type, total: 0 }
    walletMap[k].total += Number(p.total)
  })
  walletTxBreakdown.forEach((t: any) => {
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
            {Object.values(walletMap).map((w: any) => (
              <div key={w.name} className="flex justify-between text-xs">
                <span className="text-slate-600">{w.type === 'vodafone_cash' ? '📱' : '💳'} {w.name}</span>
                <span className="font-bold text-slate-800">{Number(w.total).toLocaleString('ar-EG')} ج.م</span>
              </div>
            ))}
            <div className="border-t border-slate-100 pt-1.5 flex justify-between text-xs">
              <span className="font-bold text-slate-700">إجمالي الوردية</span>
              <span className="font-black" style={{color:'#1e3a5f'}}>{Number(summary?.expected_balance ?? 0).toLocaleString('ar-EG')} ج.م</span>
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
    </div>
  )
}

function LedgerRow({ e, hasItems, singleItem }: any) {
  const [open, setOpen] = useState(false)
  return (
    <>
      <tr className={hasItems ? 'cursor-pointer hover:bg-slate-50' : ''} onClick={() => hasItems && setOpen(o => !o)}>
        <td className="text-xs text-slate-500">{new Date(e.date).toLocaleTimeString('ar-EG')}</td>
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
      {hasItems && open && e.items.map((item: any, idx: number) => (
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
  const [selectedCustomer, setSelectedCustomer] = useState<any>(null)
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
  const [showDrawerEntry, setShowDrawerEntry] = useState(false)
  const [showLedger, setShowLedger] = useState(false)
  const [showExpense, setShowExpense] = useState(false)
  const [showCustomerDebt, setShowCustomerDebt] = useState(false)
  // Debt payment state
  const [debtCustomerSearch, setDebtCustomerSearch] = useState('')
  const [debtCustomer, setDebtCustomer] = useState<any>(null)
  const [debtPayAmount, setDebtPayAmount] = useState('')
  const [debtPayNote, setDebtPayNote] = useState('')
  // Drawer entry state
  const [drawerEntryType, setDrawerEntryType] = useState<'expense'|'deposit'>('expense')
  const [drawerEntryAmount, setDrawerEntryAmount] = useState('')
  const [drawerEntryNote, setDrawerEntryNote] = useState('')
  const [drawerEntryCategoryId, setDrawerEntryCategoryId] = useState('')
  const [drawerEntryPaymentMethod, setDrawerEntryPaymentMethod] = useState('cash')
  const [drawerEntryWalletId, setDrawerEntryWalletId] = useState('')
  const [drawerEntryCustomer, setDrawerEntryCustomer] = useState<any>(null)
  const [drawerCustomerSearch, setDrawerCustomerSearch] = useState('')
  const [expandedCats, setExpandedCats] = useState<Set<string>>(new Set())
  const [supervisorId, setSupervisorId] = useState('')
  const [managerIdForClose, setManagerIdForClose] = useState('')
  const [managerPasswordForClose, setManagerPasswordForClose] = useState('')
  const [closeSafeId, setCloseSafeId] = useState('')
  const [isCredit, setIsCredit] = useState(false)

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

  const { data: warehouses } = useQuery({ queryKey: ['warehouses'], queryFn: stockApi.warehouses })
  const { activeWarehouseId } = useAppStore()
  const { setActiveWarehouse } = useAppStore()
  // Strictly use selected warehouse — no fallback
  const mainWh = warehouses?.find((w: any) => w.id === activeWarehouseId) ?? null

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

  const localShiftData = useLocalShiftStore(s => s.shift)
  const { data: serverShift } = useQuery({
    queryKey: ['current-shift', mainWh?.id], queryFn: () => shiftsApi.current(mainWh!.id),
    retry: false, throwOnError: false, refetchInterval: 30_000, enabled: !!mainWh?.id,
  })
  const shift = serverShift || (localShiftData?.warehouse_id === mainWh?.id
    ? { ...localShiftData, cashier_id: localShiftData.cashier_id || '', started_at: new Date(localShiftData.opened_at).toISOString(), status: 'open' }
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
  })

  // Collections — shown in search results
  const { data: collections } = useQuery({
    queryKey: ['collections'],
    queryFn: () => api.get('/collections').then(r => r.data),
  })
  const filteredCollections = search
    ? (collections || []).filter((c: any) => c.name.includes(search))
    : (collections || [])

  // Bulk stock balances for displayed products
  const { data: stockMap } = useQuery({
    queryKey: ['stock-bulk', mainWh?.id, products?.map((p: any) => p.id).join(',')],
    queryFn: () => stockApi.balanceBulk(mainWh!.id, products!.map((p: any) => p.id)),
    enabled: !!mainWh?.id && !!products?.length,
    staleTime: 10_000,
  })
  const { data: categories } = useQuery({ queryKey: ['categories'], queryFn: () => import('../../api/endpoints').then(m => m.categoriesApi.list()) })
  const { data: subcategories } = useQuery({ queryKey: ['subcategories'], queryFn: () => import('../../api/endpoints').then(m => m.subcategoriesApi.list()) })
  const getSubsForCat = (catId: string) => (subcategories as any[])?.filter((s: any) => s.category_id === catId) || []
  const toggleCat = (id: string) => setExpandedCats(prev => { const s = new Set(prev); if (s.has(id)) s.delete(id); else s.add(id); return s })

  const { data: allUsers } = useQuery({ queryKey: ['users-managers'], queryFn: () => api.get('/users/staff').then(r => r.data) })
  const { data: wallets } = useQuery({ queryKey: ['wallets'], queryFn: () => api.get('/wallets').then(r => r.data), staleTime: 10_000, refetchInterval: 30_000 })
  const { data: safes } = useQuery({ queryKey: ['safes'], queryFn: () => api.get('/safes').then(r => r.data), enabled: showClose })
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
    queryKey: ['sales-for-return'],
    queryFn: () => salesApi.list({ status: 'confirmed', limit: 100 }),
    enabled: showReturn,
  })

  const [mobileTab, setMobileTab] = useState<'products' | 'cart'>('products')
  const [confirmReturn, setConfirmReturn] = useState<number | null>(null)
  const [confirmDelItem, setConfirmDelItem] = useState<any>(null)
  const [confirmDelReturn, setConfirmDelReturn] = useState<any>(null)
  const [confirmDelTx, setConfirmDelTx] = useState<any>(null)
  const [confirmClear, setConfirmClear] = useState(false)

  const handleAddProduct = (p: any) => {
    if (!shift) { toast.error('افتح وردية أولاً قبل البيع', { icon: '🔒' }); return }
    const price = mode === 'wholesale' ? Number(p.wholesale_price) || Number(p.retail_price) : Number(p.retail_price)
    addItem({ product_id: p.id, name: p.name, unit_price: price, unit_cost: Number(p.cost_price), unit: p.unit })
    toast.success(`تمت إضافة ${p.name}`, { duration: 800 })
  }

  const handleAddCollection = (c: any) => {
    if (!shift) { toast.error('افتح وردية أولاً قبل البيع', { icon: '🔒' }); return }
    if (!c.items?.length) return
    c.items.forEach((item: any) => {
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
    } catch { /* normal search */ }
  }

  const isOnline = useOnlineStatus()

  const checkoutMut = useMutation({
    mutationFn: async () => {
      const useSplits = splitPayments.length > 0
      const total = items.reduce((s, i) => s + i.qty * i.unit_price - (i.item_discount_pct > 0 ? i.qty * i.unit_price * (i.item_discount_pct / 100) : i.item_discount), 0) - totalDiscount()

      if (!isOnline) {
        const saleItems = items.map(i => {
          const lineTotal = i.qty * i.unit_price
          const itemDisc = i.item_discount_pct > 0 ? lineTotal * (i.item_discount_pct / 100) : i.item_discount
          return { product_id: i.product_id, name: i.name, qty: i.qty, unit_price: i.unit_price, unit_cost: i.unit_cost, discount: itemDisc }
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
          const lineTotal = i.qty * i.unit_price
          const itemDisc = i.item_discount_pct > 0 ? lineTotal * (i.item_discount_pct / 100) : i.item_discount
          return { product_id: i.product_id, qty: i.qty, unit_price: i.unit_price, unit_cost: i.unit_cost, discount: itemDisc }
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
    mutationFn: salesApi.return,
    onSuccess: () => { toast.success('تم تسجيل المرتجع'); qc.invalidateQueries({ queryKey: ['shift-summary', shift?.id] }); qc.invalidateQueries({ queryKey: ['recent-sales'] }) },
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
      // Verify receiving employee credentials first
      const loginRes = await import('../../api/client').then(m =>
        m.default.post('/auth/login', { username: handoverUsername, password: handoverPassword })
      )
      const toUserId = loginRes.data.user_id
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
    onSuccess: (d: any) => {
      toast.success('✅ تم إغلاق الوردية وتسليم الدرج')
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

  useEffect(() => { searchRef.current?.focus() }, [])



  // ── Shift open but belongs to another cashier (non-admins only) ──────
  const isAdmin = user?.role === 'admin' || user?.role === 'manager' || user?.is_manager === true || user?.permissions?.includes('manage_shifts')
  const shiftOwner = shift && shift.cashier_id !== user?.id && !isAdmin
    ? (shift.cashier_name || (allUsers as any[])?.find((u: any) => u.id === shift.cashier_id)?.full_name || 'موظف آخر')
    : null

  if (shiftOwner) return (
    <div className="flex flex-col h-[calc(100vh-3rem)]">
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
    <div className="flex flex-col h-[calc(100vh-3rem)]">
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
      <Modal open={showOpenShift} onClose={() => setShowOpenShift(false)} title="فتح وردية جديدة">
        <div className="space-y-4">
          <div className="bg-slate-50 rounded-xl p-4 border border-slate-200">
            <p className="text-slate-500 text-xs mb-1">الفرع</p>
            <p className="font-bold text-slate-800">🏪 {mainWh?.name || '—'}</p>
          </div>
          <div className="bg-slate-50 rounded-xl p-5 text-center border border-slate-200">
            <p className="text-slate-500 text-sm mb-1">الرصيد الافتتاحي (فكة اليوم السابق)</p>
            <p className="text-4xl font-black" style={{ color: '#1e3a5f' }}>
              {Number(lastDrawer?.amount || 0).toLocaleString('ar-EG')} ج.م
            </p>
            <p className="text-xs text-slate-400 mt-1">لا يمكن تعديله — يُحسب تلقائياً</p>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">المشرف العام (اختياري)</label>
            <select className="input" value={supervisorId} onChange={e => setSupervisorId(e.target.value)}>
              <option value="">بدون مشرف</option>
              {(allUsers as any[])?.map((u: any) => (
                <option key={u.id} value={u.id}>{u.full_name}</option>
              ))}
            </select>
          </div>
          <div className="flex gap-3 justify-end">
            <button onClick={() => setShowOpenShift(false)} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
            <button onClick={() => openShiftMut.mutate()} disabled={openShiftMut.isPending || !mainWh?.id}
              className="px-5 py-2 rounded-xl text-sm font-bold text-white flex items-center gap-2 disabled:opacity-50"
              style={{ background: '#16a34a' }}>
              <Wallet size={15} /> تأكيد فتح الوردية
            </button>
          </div>
        </div>
      </Modal>
    </div>
  )

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
          {warehouses.filter((w: any) => w.warehouse_type === 'showroom').map((w: any) => (
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
    <div className="hidden lg:flex flex-col h-[calc(100vh-3rem)] gap-0">
      {/* Top bar — drawer balance */}
      <div className="flex items-center justify-between mb-4 flex-shrink-0">
        <h1 className="page-title">نقطة البيع — {mainWh?.name}</h1>
        <div className="flex items-center gap-3">
          <button onClick={() => setShowLedger(true)} className="flex items-center gap-1.5 px-3 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600 hover:bg-slate-200 transition-colors">
            <BookOpen size={14} /> سجل اليوم
          </button>
          <DrawerBadge shift={shift} summary={summary} onOpen={() => setShowOpenShift(true)} onHandover={() => setShowHandover(true)} onClose={() => setShowClose(true)} warehouseName={mainWh?.name}
            supervisorName={shift?.supervisor_id ? (allUsers as any[])?.find((u: any) => u.id === shift.supervisor_id)?.full_name : null}
            wallets={wallets} currentUserId={user?.id} />

        </div>
      </div>

      <div className="flex gap-5 flex-1 min-h-0">
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
            {(categories as any[])?.map((cat: any) => {
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
                  {isExpanded && subs.map((sub: any) => {
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

        {/* ── Products + Cart ── */}
        <div className="flex-1 flex flex-col min-w-0">
          {/* Search */}
          <div className="relative mb-3 flex-shrink-0">
            <Search size={16} className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input ref={searchRef} value={search}
              onChange={e => { setSearch(e.target.value); if (e.target.value) { setSelectedCat(null); setSelectedSub(null) } }}
              onKeyDown={e => e.key === 'Enter' && handleBarcodeSearch()}
              className="input pr-10" placeholder="ابحث بالاسم أو امسح الباركود..." />
          </div>

          {isLoading ? <PageLoader /> : (
            <div className="flex-1 overflow-y-auto relative">

              {/* Collections */}
              {filteredCollections.length > 0 && (
                <div className="mb-3">
                  <p className="text-xs font-bold text-slate-400 mb-2 flex items-center gap-1">📦 كوليكشنات</p>
                  <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-3 xl:grid-cols-4 gap-3">
                    {filteredCollections.map((c: any) => {
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
                      <th className="py-2 px-3">القطاعي</th>
                      <th className="py-2 px-3">الجملة</th>
                      <th className="py-2 px-3">المخزون</th>
                      <th className="py-2 px-3"></th>
                    </tr>
                  </thead>
                  <tbody>
                    {products?.length === 0 && (
                      <tr><td colSpan={6} className="text-center py-12 text-slate-400">لا توجد منتجات</td></tr>
                    )}
                    {products?.map((p: any) => {
                      const retailPrice = Number(p.retail_price)
                      const wholesalePrice = Number(p.wholesale_price) || retailPrice
                      const qty = p.stock_status === 'untracked' ? null : (stockMap?.[p.id] ?? null)
                      return (
                        <tr key={p.id} onClick={() => handleAddProduct(p)}
                          className="border-t border-slate-100 hover:bg-blue-50 cursor-pointer transition-colors">
                          <td className="py-2 px-3 font-semibold text-slate-800">{p.name}</td>
                          <td className="py-2 px-3 text-slate-400">{p.company || '—'}</td>
                          <td className="py-2 px-3 font-black" style={{ color: '#c8a84b' }}>{retailPrice.toLocaleString('ar-EG')}</td>
                          <td className="py-2 px-3 text-slate-600">{wholesalePrice.toLocaleString('ar-EG')}</td>
                          <td className="py-2 px-3">
                            {qty !== null ? (
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
        </div>

        {/* Cart panel */}
        <div className="w-80 flex-shrink-0 flex flex-col bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">

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
                  {(wallets || []).filter((w: any) => w.type !== 'cash').length > 0 && (
                    <div className="relative flex-1">
                      <select value={paymentWalletId}
                        onChange={e => { setPaymentMethod('wallet'); setPaymentWalletId(e.target.value) }}
                        className="w-full rounded-lg text-xs font-bold border px-3 py-2 bg-white/10 border-white/20 text-white/60 outline-none">
                        <option value="" style={{ background: '#1e3a5f', color: '#fff' }}>💳 تحويل إلكتروني...</option>
                        {(wallets || []).filter((w: any) => w.type !== 'cash').map((w: any) => (
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
                  {customerResults?.map((c: any) => (
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
          <div className="flex-1 overflow-y-auto p-3 space-y-2">
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
        </div>
      </div>

    </div>{/* end desktop */}

    {/* ── MOBILE layout (< lg) ── */}
    <div className="lg:hidden flex flex-col" style={{ height: 'calc(100vh - 3rem)' }}>

      {/* Mobile top bar */}
      <div className="flex items-center justify-between px-3 py-2 flex-shrink-0" style={{ background: '#1e3a5f' }}>
        <span className="text-white font-bold text-sm">🏪 {mainWh?.name}</span>
        <div className="flex items-center gap-2">
          {shift ? (
            <>
              <span className="text-white/80 text-xs font-semibold">
                💵 {Number(summary?.cash_in_drawer ?? shift.initial_amount).toLocaleString('ar-EG')} ج.م
              </span>
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
          {/* Search */}
          <div className="relative mb-3 flex-shrink-0">
            <Search size={16} className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input ref={searchRef} value={search}
              onChange={e => { setSearch(e.target.value); if (e.target.value) { setSelectedCat(null); setSelectedSub(null) } }}
              onKeyDown={e => e.key === 'Enter' && handleBarcodeSearch()}
              className="input pr-10" placeholder="ابحث أو امسح الباركود..." autoFocus />
          </div>
          {/* Category pills */}
          <div className="flex gap-2 overflow-x-auto pb-2 flex-shrink-0" style={{ WebkitOverflowScrolling: 'touch' }}>
            <button onClick={() => { setSelectedCat(null); setSelectedSub(null) }}
              className="flex-shrink-0 px-3 py-1.5 rounded-full text-xs font-bold transition-all"
              style={!selectedCat ? { background: '#1e3a5f', color: 'white' } : { background: '#f1f5f9', color: '#64748b' }}>
              الكل
            </button>
            {(categories as any[])?.map((cat: any) => (
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
                  <th className="py-2 px-2">السعر</th>
                  <th className="py-2 px-2">المخزون</th>
                  <th className="py-2 px-2"></th>
                </tr>
              </thead>
              <tbody>
                {products?.length === 0 && (
                  <tr><td colSpan={4} className="text-center py-12 text-slate-400">لا توجد منتجات</td></tr>
                )}
                {products?.map((p: any) => {
                  const price = mode === 'wholesale' ? Number(p.wholesale_price) || Number(p.retail_price) : Number(p.retail_price)
                  const qty = p.stock_status === 'untracked' ? null : (stockMap?.[p.id] ?? null)
                  return (
                    <tr key={p.id} onClick={() => handleAddProduct(p)}
                      className="border-t border-slate-100 hover:bg-blue-50 cursor-pointer transition-colors">
                      <td className="py-2 px-2 font-semibold text-slate-800">{p.name}</td>
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
                    {(wallets || []).filter((w: any) => w.type !== 'cash').map((w: any) => (
                      <button key={w.id} onClick={() => { setPaymentMethod('wallet'); setPaymentWalletId(w.id) }}
                        className={`px-2 py-1 rounded-lg text-xs font-bold ${paymentMethod === 'wallet' && paymentWalletId === w.id ? 'bg-blue-500 text-white' : 'text-white/60 border border-white/20'}`}>
                        {w.type === 'vodafone_cash' ? '📱' : '💳'}
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
              {showCustomerDrop && customerResults?.length > 0 && (
                <div className="absolute top-full right-0 left-0 mt-1 bg-white rounded-xl shadow-xl border border-slate-200 z-50 max-h-40 overflow-y-auto">
                  {customerResults?.map((c: any) => (
                    <button key={c.id} onMouseDown={() => { setSelectedCustomer(c); setCustomer(c.name); setCustomerSearch(''); setShowCustomerDrop(false) }}
                      className="w-full text-right px-4 py-2.5 hover:bg-slate-50 text-sm border-b border-slate-50 last:border-0">
                      <p className="font-semibold text-slate-800">{c.name}</p>
                    </button>
                  ))}
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
            {items.map((item: any) => {
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


      <Modal open={showHeld} onClose={() => setShowHeld(false)} title="الفواتير المعلقة" size="lg">
        <div className="space-y-3">
          <div className="flex gap-2">
            <input
              className="input flex-1"
              placeholder="اسم الفاتورة (اختياري)"
              value={holdLabel}
              onChange={e => setHoldLabel(e.target.value)}
            />
            <button
              className="px-4 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50"
              style={{ background: '#1e3a5f' }}
              disabled={items.length === 0}
              onClick={() => { holdCurrent({ label: holdLabel, warehouse_id: mainWh?.id, shift_id: shift?.id }); setHoldLabel('') }}
            >
              تعليق الحالية
            </button>
          </div>

          {suspended.length === 0 ? (
            <div className="text-center py-10 text-slate-400">لا توجد فواتير معلقة</div>
          ) : (
            <div className="space-y-2 max-h-96 overflow-y-auto">
              {suspended.map((b: any) => {
                const sameWarehouse = !b.warehouse_id || b.warehouse_id === mainWh?.id
                const sameShift = !b.shift_id || b.shift_id === shift?.id
                const canResume = sameWarehouse && sameShift
                return (
                  <div key={b.id} className="p-3 rounded-xl border border-slate-200 bg-white flex items-center justify-between gap-3">
                    <div className="min-w-0">
                      <p className="font-bold text-slate-800 truncate">{b.label}</p>
                      <p className="text-xs text-slate-500">{new Date(b.created_at).toLocaleString('ar-EG')} · {b.items.length} بند</p>
                      {!canResume && (
                        <p className="text-xs text-amber-700 mt-1">لا يمكن الاستئناف: مختلف مخزن/وردية</p>
                      )}
                    </div>
                    <div className="flex items-center gap-2 flex-shrink-0">
                      <button
                        className="px-3 py-2 rounded-xl text-xs font-bold text-white disabled:opacity-50"
                        style={{ background: '#16a34a' }}
                        disabled={!canResume || items.length > 0}
                        title={items.length > 0 ? 'امسح السلة الحالية أولاً' : ''}
                        onClick={() => { resume(b.id); setShowHeld(false) }}
                      >
                        استئناف
                      </button>
                      <button
                        className="px-3 py-2 rounded-xl text-xs font-bold bg-red-50 text-red-600 border border-red-200"
                        onClick={() => deleteHeld(b.id)}
                      >
                        حذف
                      </button>
                    </div>
                  </div>
                )
              })}
            </div>
          )}
        </div>
      </Modal>


      <Modal open={showReturn} onClose={() => setShowReturn(false)} title="اختر فاتورة للمرتجع" size="lg">
        <div className="space-y-2 max-h-96 overflow-y-auto">
          {!allSales?.length && <p className="text-center py-8 text-slate-400">لا توجد فواتير مؤكدة</p>}
          {allSales?.map((s: any) => (
            <div key={s.id} className="flex items-center justify-between p-3 rounded-xl border border-slate-100 hover:bg-slate-50">
              <div>
                <p className="font-semibold text-slate-800">{s.customer_name || 'عميل عادي'}</p>
                <p className="text-xs text-slate-400 font-mono">{s.invoice_number} — {new Date(s.created_at).toLocaleString('ar-EG')} — {s.sale_mode === 'wholesale' ? 'جملة' : 'قطاعي'} — {s.items?.length || 0} صنف</p>
              </div>
              <button
                onClick={() => setConfirmReturn(s.id)}
                className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-bold text-white bg-amber-500 hover:bg-amber-600 transition-colors">
                <RotateCcw size={12} /> مرتجع
              </button>
            </div>
          ))}
        </div>
      </Modal>

      {/* Drawer Entry Modal (خوارج / دواخل) */}
      <Modal open={showDrawerEntry} onClose={() => setShowDrawerEntry(false)}
        title={drawerEntryType === 'expense' ? 'تسجيل خوارج' : 'تسجيل دواخل مالية'}>
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">المبلغ (ج.م) *</label>
            <input type="number" className="input text-xl font-black" value={drawerEntryAmount}
              onChange={e => setDrawerEntryAmount(e.target.value)} placeholder="0.00" autoFocus />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">الفئة</label>
            <select className="input" value={drawerEntryCategoryId} onChange={e => setDrawerEntryCategoryId(e.target.value)}>
              <option value="">بدون فئة</option>
              {(finCategories as any[])?.filter((c: any) => c.type === drawerEntryType || (drawerEntryType === 'deposit' && c.type === 'income')).map((c: any) => (
                <option key={c.id} value={c.id}>{c.name}</option>
              ))}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">وسيلة الدفع</label>
            <div className="flex gap-2">
              <button type="button" onClick={() => { setDrawerEntryPaymentMethod('cash'); setDrawerEntryWalletId('') }}
                className={`flex-1 py-2 rounded-lg text-sm font-bold border transition-all ${drawerEntryPaymentMethod === 'cash' ? 'bg-slate-800 text-white border-slate-800' : 'border-slate-300 text-slate-600'}`}>
                💵 نقدي
              </button>
              {(wallets || []).filter((w: any) => w.type !== 'cash').map((w: any) => (
                <button key={w.id} type="button"
                  onClick={() => { setDrawerEntryPaymentMethod('wallet'); setDrawerEntryWalletId(w.id) }}
                  className={`flex-1 py-2 rounded-lg text-sm font-bold border transition-all ${drawerEntryPaymentMethod === 'wallet' && drawerEntryWalletId === w.id ? 'bg-slate-800 text-white border-slate-800' : 'border-slate-300 text-slate-600'}`}>
                  {w.type === 'vodafone_cash' ? '📱' : '💳'} {w.name}
                </button>
              ))}
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">البيان</label>
            <input className="input" value={drawerEntryNote} onChange={e => setDrawerEntryNote(e.target.value)}
              placeholder={drawerEntryType === 'expense' ? 'إيجار، كهرباء، مصاريف...' : 'مصدر الدخل...'} />
          </div>
          <div className="flex gap-3 justify-end">
            <button onClick={() => setShowDrawerEntry(false)} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
            <button onClick={() => drawerEntryMut.mutate()} disabled={!drawerEntryAmount || drawerEntryMut.isPending}
              className="px-5 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50"
              style={{ background: drawerEntryType === 'expense' ? '#dc2626' : '#16a34a' }}>
              تسجيل
            </button>
          </div>
        </div>
      </Modal>

      {/* Customer Debt Payment Modal */}
      <Modal open={showCustomerDebt} onClose={() => { setShowCustomerDebt(false); setDebtCustomer(null); setDebtCustomerSearch('') }}
        title="دفع عميل آجل" size="xl">
        <div className="space-y-4">
          {/* Customer search — always visible */}
          <div className="relative">
            <label className="block text-sm font-medium text-slate-600 mb-1">
              {debtCustomer ? 'العميل المحدد' : 'ابحث عن العميل'}
            </label>
            {debtCustomer ? (
              <div className="flex items-center justify-between bg-blue-50 border border-blue-200 rounded-xl px-4 py-3">
                <div>
                  <p className="font-black text-slate-800">{debtCustomer.name}</p>
                  {debtCustomerAccount && (
                    <p className="text-sm mt-0.5">
                      المتبقي: <span className={`font-black ${Number(debtCustomerAccount.balance_due) > 0 ? 'text-red-600' : 'text-green-600'}`}>
                        {Number(debtCustomerAccount.balance_due).toLocaleString('ar-EG')} ج.م
                      </span>
                    </p>
                  )}
                </div>
                <button onClick={() => { setDebtCustomer(null); setDebtCustomerSearch('') }}
                  className="text-slate-400 hover:text-red-500 text-xs px-2 py-1 rounded-lg hover:bg-red-50">
                  تغيير
                </button>
              </div>
            ) : (
              <input className="input text-base" value={debtCustomerSearch}
                onChange={e => setDebtCustomerSearch(e.target.value)}
                placeholder="اكتب اسم العميل للبحث..." autoFocus />
            )}

            {/* Search results dropdown */}
            {!debtCustomer && debtCustomerSearch.length > 1 && (
              <div className="absolute z-20 w-full bg-white border border-slate-200 rounded-xl shadow-xl mt-1 max-h-52 overflow-y-auto">
                {!(debtCustomerResults as any[])?.length
                  ? <p className="text-center py-6 text-slate-400 text-sm">لا توجد نتائج</p>
                  : (debtCustomerResults as any[])?.map((c: any) => (
                    <button key={c.id} onMouseDown={() => { setDebtCustomer(c); setDebtCustomerSearch('') }}
                      className="w-full text-right px-4 py-3 hover:bg-blue-50 border-b border-slate-50 last:border-0 transition-colors">
                      <p className="font-bold text-slate-800">{c.name}</p>
                      {c.phone && <p className="text-xs text-slate-400">{c.phone}</p>}
                    </button>
                  ))
                }
              </div>
            )}
          </div>

          {/* Empty state — show instructions when no customer yet */}
          {!debtCustomer && (
            <div className="flex flex-col items-center justify-center py-16 text-slate-300 border-2 border-dashed border-slate-200 rounded-2xl">
              <div className="text-5xl mb-4">👤</div>
              <p className="text-base font-semibold text-slate-400">ابحث عن العميل أعلاه</p>
              <p className="text-sm text-slate-300 mt-1">سيظهر رصيده وفواتيره هنا</p>
            </div>
          )}

          {/* Customer detail — invoices + payment */}
          {debtCustomer && (
            <>

              {/* Invoices oldest→newest (pay oldest first) */}
              {debtCustomerLedger && (
                <div className="max-h-40 overflow-y-auto space-y-1">
                  <p className="text-xs font-bold text-slate-400 mb-2">الفواتير المستحقة (من الأقدم للأحدث)</p>
                  {(debtCustomerLedger as any[])
                    .filter((e: any) => e.type === 'invoice')
                    .sort((a: any, b: any) => a.date.localeCompare(b.date))
                    .map((e: any) => (
                      <div key={e.ref} className="flex justify-between items-center bg-slate-50 rounded-lg px-3 py-2 text-sm">
                        <span className="font-mono text-blue-700 font-bold">{e.ref}</span>
                        <span className="text-slate-500 text-xs">{new Date(e.date).toLocaleDateString('ar-EG')}</span>
                        <span className="font-bold text-slate-800">{Number(e.amount).toLocaleString('ar-EG')} ج.م</span>
                      </div>
                    ))}
                </div>
              )}

              {/* Payment entry */}
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-sm font-medium text-slate-600 mb-1">المبلغ المدفوع *</label>
                  <input type="number" className="input text-lg font-black" value={debtPayAmount}
                    onChange={e => setDebtPayAmount(e.target.value)} placeholder="0.00" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-slate-600 mb-1">ملاحظة</label>
                  <input className="input" value={debtPayNote} onChange={e => setDebtPayNote(e.target.value)} placeholder="رقم إيصال..." />
                </div>
              </div>
              <div className="flex gap-3 justify-end">
                <button onClick={() => { setShowCustomerDebt(false); setDebtCustomer(null) }}
                  className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
                <button onClick={() => debtPayMut.mutate()} disabled={!debtPayAmount || debtPayMut.isPending}
                  className="px-5 py-2 rounded-xl text-sm font-bold text-white bg-green-600 hover:bg-green-700 disabled:opacity-50">
                  تسجيل الدفعة
                </button>
              </div>
            </>
          )}
        </div>
      </Modal>

      {/* Today's Ledger Modal */}
      <Modal open={showLedger} onClose={() => setShowLedger(false)} title="سجل اليوم" size="xl">
        {todayLedger ? (
          <div className="space-y-3">
            {/* Summary */}
            <div className="grid grid-cols-4 gap-2 text-center text-xs">
              {[
                { label: 'المبيعات', val: todayLedger.summary.total_sales, color: '#16a34a' },
                { label: 'المرتجعات', val: todayLedger.summary.total_returns, color: '#dc2626' },
                { label: 'الخوارج', val: todayLedger.summary.total_expenses, color: '#d97706' },
                { label: 'الصافي', val: todayLedger.summary.net, color: '#1e3a5f' },
              ].map(({ label, val, color }) => (
                <div key={label} className="bg-slate-50 rounded-lg p-2">
                  <p className="text-slate-400 mb-0.5">{label}</p>
                  <p className="font-black text-sm" style={{ color }}>{Number(val).toLocaleString('ar-EG')} ج.م</p>
                </div>
              ))}
            </div>

            {/* Single unified table */}
            <div className="table-wrap max-h-[60vh] overflow-y-auto">
              <table>
                <thead>
                  <tr>
                    <th style={{width:'28px'}}>#</th>
                    <th>اسم الصنف</th>
                    <th style={{textAlign:'center',whiteSpace:'nowrap'}}>الكمية</th>
                    <th style={{textAlign:'center',whiteSpace:'nowrap'}}>السعر</th>
                    <th style={{textAlign:'center',whiteSpace:'nowrap'}}>المجموع</th>
                    <th style={{textAlign:'center',whiteSpace:'nowrap'}}>النوع</th>
                    <th style={{whiteSpace:'nowrap'}}>الدفع</th>
                  </tr>
                </thead>
                <tbody>
                  {/* Sale items */}
                  {(todayLedger.sale_items || []).map((item: any, i: number) => (
                    <tr key={`s${i}`}>
                      <td className="text-slate-400 text-xs">{i+1}</td>
                      <td>
                        <p className="font-medium text-sm leading-tight">{item.product_name}</p>
                        <p className="text-xs text-slate-400 leading-tight">{item.invoice_number} · {item.customer}</p>
                      </td>
                      <td className="text-center text-sm">
                        <button className="text-blue-500 hover:text-blue-700 text-xs underline"
                          onClick={() => {
                            const newQty = prompt(`كمية جديدة لـ ${item.product_name} (الحالية: ${item.qty}):`, String(item.qty))
                            if (newQty && Number(newQty) > 0 && Number(newQty) !== item.qty) {
                              api.put(`/sales/${item.sale_id}/items/${item.item_id}`, { qty: Number(newQty) })
                                .then(() => { toast.success('✅ تم تعديل الكمية'); qc.invalidateQueries({ queryKey: ['pos-ledger'] }); qc.invalidateQueries({ queryKey: ['shift-summary'] }) })
                                .catch((e: any) => toast.error(e.response?.data?.detail || 'فشل'))
                            }
                          }}>
                          {item.qty}
                        </button>
                      </td>
                      <td className="text-center text-sm">{Number(item.unit_price).toLocaleString('ar-EG')}</td>
                      <td className="text-center font-bold text-sm text-green-700">{Number(item.total).toLocaleString('ar-EG')}</td>
                      <td className="text-center"><span className="badge-green text-xs">مبيعات</span></td>
                      <td className="text-xs text-slate-500 flex items-center gap-1">
                        {item.payment_method}
                        <button className="text-red-400 hover:text-red-600 mr-1"
                          onClick={() => setConfirmDelItem(item)}>✕</button>
                      </td>
                    </tr>
                  ))}

                  {/* Returns */}
                  {(todayLedger.returns || []).map((item: any, i: number) => (
                    <tr key={`r${i}`} className="bg-red-50">
                      <td className="text-slate-400 text-xs">↩</td>
                      <td>
                        <p className="font-medium text-sm leading-tight">{item.product_name}</p>
                        <p className="text-xs text-slate-400 leading-tight">{item.invoice_number}</p>
                      </td>
                      <td className="text-center text-sm">{item.qty}</td>
                      <td className="text-center text-sm">{Number(item.unit_price).toLocaleString('ar-EG')}</td>
                      <td className="text-center font-bold text-sm text-red-600">{Number(item.total).toLocaleString('ar-EG')}</td>
                      <td className="text-center"><span className="badge-red text-xs">مرتجع</span></td>
                      <td className="text-xs text-slate-500 flex items-center gap-1">—
                        {item.item_id && <button className="text-red-400 hover:text-red-600"
                          onClick={() => setConfirmDelReturn(item)}>✕</button>}
                      </td>
                    </tr>
                  ))}

                  {/* Expenses/Deposits */}
                  {(todayLedger.expenses || []).map((e: any, i: number) => (
                    <tr key={`e${i}`} className={e.entry_type === 'deposit' ? 'bg-green-50' : 'bg-amber-50'}>
                      <td className="text-slate-400 text-xs">💸</td>
                      <td>
                        <p className="font-medium text-sm leading-tight">{e.type_ar}</p>
                        <p className="text-xs text-slate-400 leading-tight">{e.note || '—'}</p>
                      </td>
                      <td></td>
                      <td></td>
                      <td className={`text-center font-bold text-sm ${e.entry_type === 'deposit' ? 'text-green-700' : 'text-amber-700'}`}>
                        {Number(e.amount).toLocaleString('ar-EG')}
                      </td>
                      <td className="text-center"><span className={e.entry_type === 'deposit' ? 'badge-green' : 'badge-yellow'}>{e.type_ar}</span></td>
                      <td className="text-xs text-slate-500 flex items-center gap-1">{e.payment_method}
                        {e.tx_id && <button className="text-red-400 hover:text-red-600"
                          onClick={() => setConfirmDelTx(e)}>✕</button>}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        ) : <div className="text-center py-8 text-slate-400">جاري التحميل...</div>}
      </Modal>

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
      <Modal open={showOpenShift} onClose={() => setShowOpenShift(false)} title="فتح وردية جديدة">
        <div className="space-y-4">
          <div className="bg-slate-50 rounded-xl p-4 border border-slate-200">
            <p className="text-slate-500 text-xs mb-1">الفرع</p>
            <p className="font-bold text-slate-800">🏪 {mainWh?.name || '—'}</p>
          </div>
          <div className="bg-slate-50 rounded-xl p-5 text-center border border-slate-200">
            <p className="text-slate-500 text-sm mb-1">الرصيد الافتتاحي (فكة اليوم السابق)</p>
            <p className="text-4xl font-black" style={{ color: '#1e3a5f' }}>
              {Number(lastDrawer?.amount || 0).toLocaleString('ar-EG')} ج.م
            </p>
            <p className="text-xs text-slate-400 mt-1">لا يمكن تعديله — يُحسب تلقائياً</p>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">المشرف العام (اختياري)</label>
            <select className="input" value={supervisorId} onChange={e => setSupervisorId(e.target.value)}>
              <option value="">بدون مشرف</option>
              {(allUsers as any[])?.map((u: any) => (
                <option key={u.id} value={u.id}>{u.full_name}</option>
              ))}
            </select>
          </div>
          <div className="flex gap-3 justify-end">
            <button onClick={() => setShowOpenShift(false)} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
            <button onClick={() => openShiftMut.mutate()} disabled={openShiftMut.isPending || !mainWh?.id}
              className="px-5 py-2 rounded-xl text-sm font-bold text-white flex items-center gap-2 disabled:opacity-50"
              style={{ background: '#16a34a' }}>
              <Wallet size={15} /> تأكيد فتح الوردية
            </button>
          </div>
        </div>
      </Modal>

      {/* Handover Modal — requires receiving employee password */}
      <Modal open={showHandover} onClose={() => setShowHandover(false)} title="تسليم الدرج لموظف آخر">
        <div className="space-y-4">
          {summary && (
            <div className="bg-blue-50 border border-blue-200 rounded-xl p-4">
              <p className="text-sm text-blue-700 font-semibold">الرصيد الحالي للتسليم</p>
              <p className="text-2xl font-black text-blue-800 mt-1">{Number(summary.expected_balance).toLocaleString('ar-EG')} ج.م</p>
            </div>
          )}
          <div className="bg-amber-50 border border-amber-200 rounded-xl p-3 text-sm text-amber-700">
            🔐 يجب على الموظف المستلم إدخال بياناته لتأكيد الاستلام
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">اسم المستخدم للموظف المستلم</label>
            <input className="input" value={handoverUsername} onChange={e => setHandoverUsername(e.target.value)} placeholder="username" />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">كلمة المرور</label>
            <input type="password" className="input" value={handoverPassword} onChange={e => setHandoverPassword(e.target.value)} placeholder="••••••••" />
          </div>
          <div className="flex gap-3 justify-end">
            <button onClick={() => setShowHandover(false)} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
            <button onClick={() => handoverMut.mutate()} disabled={!handoverUsername || !handoverPassword || handoverMut.isPending}
              className="px-5 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50 flex items-center gap-2"
              style={{ background: '#c8a84b', color: '#1e3a5f' }}>
              <ArrowLeftRight size={15} /> تأكيد التسليم
            </button>
          </div>
        </div>
      </Modal>

      {/* Close Shift Modal */}
      <Modal open={showClose} onClose={() => setShowClose(false)} title="إغلاق الوردية">
        <div className="space-y-4">
          {summary && (
            <div className="bg-slate-50 rounded-xl p-4 space-y-2 text-sm">
              <div className="flex justify-between"><span className="text-slate-500">المبيعات</span><span className="font-bold text-green-700">{Number(summary.sales_total).toLocaleString('ar-EG')} ج.م</span></div>
              <div className="flex justify-between"><span className="text-slate-500">المرتجعات</span><span className="font-bold text-amber-600">{Number(summary.returns_total).toLocaleString('ar-EG')} ج.م</span></div>
              <div className="flex justify-between"><span className="text-slate-500">المصروفات</span><span className="font-bold text-red-600">{Number(summary.expenses_total).toLocaleString('ar-EG')} ج.م</span></div>
              <div className="flex justify-between border-t border-slate-200 pt-2"><span className="font-semibold">الرصيد المتوقع</span><span className="font-black text-base">{Number(summary.expected_balance).toLocaleString('ar-EG')} ج.م</span></div>
            </div>
          )}
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">الرصيد الفعلي في الدرج</label>
            <input type="number" className="input text-lg font-bold" value={closingBalance} onChange={e => setClosingBalance(e.target.value)} placeholder="0.00" />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">الفكة للغد (يبقى في الدرج)</label>
            <input type="number" className="input" value={nextDayDrawer} onChange={e => setNextDayDrawer(e.target.value)} placeholder="0.00" />
          </div>
          {closingBalance && nextDayDrawer && (
            <div className="bg-blue-50 border border-blue-200 rounded-xl p-3 text-sm space-y-1">
              <div className="flex justify-between font-semibold text-blue-800">
                <span>المبلغ المورَّد (التوريد)</span>
                <span>{(Number(closingBalance) - Number(nextDayDrawer)).toLocaleString('ar-EG')} ج.م</span>
              </div>
              {summary && (
                <div className={clsx('flex justify-between text-xs', Number(closingBalance) >= Number(summary.expected_balance) ? 'text-green-600' : 'text-red-600')}>
                  <span>الفرق عن المتوقع</span>
                  <span>{(Number(closingBalance) - Number(summary.expected_balance)).toLocaleString('ar-EG')} ج.م</span>
                </div>
              )}
            </div>
          )}
          {/* Manager verification */}
          <div className="bg-amber-50 border border-amber-200 rounded-xl p-4 space-y-3">
            <p className="text-sm font-bold text-amber-800 flex items-center gap-2">🔐 يجب على المدير تأكيد استلام التوريد</p>
            <div>
              <label className="block text-xs font-medium text-amber-700 mb-1">توريد الدرج إلى خزنة *</label>
              <select className="input text-sm" value={closeSafeId} onChange={e => setCloseSafeId(e.target.value)}>
                <option value="">اختر الخزنة...</option>
                {(safes as any[])?.map((s: any) => (
                  <option key={s.id} value={s.id}>{s.name} — {Number(s.balance).toLocaleString('ar-EG')} ج.م</option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-xs font-medium text-amber-700 mb-1">المدير المستلم</label>
              <select className="input text-sm" value={managerIdForClose} onChange={e => setManagerIdForClose(e.target.value)}>
                <option value="">اختر المدير...</option>
                {(allUsers as any[])?.filter((u: any) => u.is_manager || u.role === 'admin').map((u: any) => (
                  <option key={u.id} value={u.id}>{u.full_name}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-xs font-medium text-amber-700 mb-1">كلمة مرور المدير</label>
              <input type="password" className="input text-sm" value={managerPasswordForClose}
                onChange={e => setManagerPasswordForClose(e.target.value)} placeholder="••••••••" />
            </div>
          </div>
          <div className="flex gap-3 justify-end">
            <button onClick={() => setShowClose(false)} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
            <button onClick={() => closeMut.mutate()} disabled={!closingBalance || !managerIdForClose || !managerPasswordForClose || !closeSafeId || closeMut.isPending}
              className="px-5 py-2 rounded-xl text-sm font-bold text-white bg-red-600 hover:bg-red-700 disabled:opacity-50 flex items-center gap-2">
              <Lock size={15} /> إغلاق الوردية
            </button>
          </div>
        </div>
      </Modal>

      {/* Phone required modal for credit customers */}
      {/* Split payment modal */}
      <Modal open={showSplitModal} onClose={() => setShowSplitModal(false)} title="إضافة قسط دفع">
        <div className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-slate-600 mb-1">طريقة الدفع</label>
              <select className="input" value={splitMethod} onChange={e => { setSplitMethod(e.target.value); setSplitWalletId('') }}>
                <option value="cash">💵 نقدي</option>
                {(wallets || []).filter((w: any) => w.type !== 'cash').map((w: any) => (
                  <option key={w.id} value={w.id}>{w.type === 'vodafone_cash' ? '📱' : '💳'} {w.name}</option>
                ))}
                <option value="credit">📋 آجل</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-600 mb-1">المبلغ (ج.م)</label>
              <input type="number" className="input text-lg font-bold" value={splitAmount} onChange={e => setSplitAmount(e.target.value)} autoFocus />
            </div>
          </div>
          <div className="text-xs text-slate-400">
            المتبقي من الفاتورة: {(total() - splitPayments.reduce((s, p) => s + p.amount, 0)).toLocaleString('ar-EG')} ج.م
          </div>
          <div className="flex gap-3 justify-end">
            <button onClick={() => setShowSplitModal(false)} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
            <button onClick={() => {
              const amt = Number(splitAmount)
              const maxRemaining = total() - splitPayments.reduce((s, p) => s + p.amount, 0)
              if (!amt || amt <= 0) { toast.error('المبلغ يجب أن يكون أكبر من 0'); return }
              if (amt > maxRemaining + 0.01) { toast.error(`المبلغ يتجاوز المتبقي (${maxRemaining.toLocaleString('ar-EG')})`); return }
              const isWalletMethod = splitMethod !== 'cash' && splitMethod !== 'credit'
              setSplitPayments(p => [...p, { method: isWalletMethod ? 'wallet' : splitMethod, amount: amt, walletId: isWalletMethod ? splitMethod : undefined }])
              setSplitAmount(''); setShowSplitModal(false)
            }} disabled={!splitAmount || Number(splitAmount) <= 0}
              className="px-5 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#1e3a5f' }}>
              إضافة القسط
            </button>
          </div>
        </div>
      </Modal>

      <Modal open={showPhoneModal} onClose={() => setShowPhoneModal(false)} title="بيانات العميل — آجل">
        <div className="space-y-4">
          <div className="bg-amber-50 border border-amber-200 rounded-xl p-3 text-sm text-amber-800 font-medium">
            ⚠️ البيع الآجل يتطلب تسجيل رقم تليفون العميل
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">الاسم</label>
            <input className="input" value={pendingCustomerName} onChange={e => setPendingCustomerName(e.target.value)} />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">رقم التليفون *</label>
            <input className="input" type="tel" value={newCustomerPhone} onChange={e => setNewCustomerPhone(e.target.value)} placeholder="01xxxxxxxxx" autoFocus />
          </div>
          <div className="flex gap-3 justify-end">
            <button onClick={() => setShowPhoneModal(false)} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
            <button
              disabled={!newCustomerPhone.trim() || !pendingCustomerName.trim()}
              onClick={async () => {
                const c = await customersApi.create({ name: pendingCustomerName, phone: newCustomerPhone })
                setSelectedCustomer(c)
                setCustomer(c.name)
                setCustomerSearch('')
                setShowPhoneModal(false)
                setPendingCustomerName('')
                setNewCustomerPhone('')
              }}
              className="px-5 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#1e3a5f' }}>
              إضافة وتأكيد
            </button>
          </div>
        </div>
      </Modal>

      <ConfirmDialog open={!!confirmReturn} onClose={() => setConfirmReturn(null)}
        onConfirm={() => { returnMut.mutate(confirmReturn!); setShowReturn(false) }}
        message={`مرتجع فاتورة ${confirmReturn || ''}؟`} danger confirmText="مرتجع" />
      <ConfirmDialog open={!!confirmDelItem} onClose={() => setConfirmDelItem(null)}
        onConfirm={() => { const item = confirmDelItem; api.delete(`/sales/${item.sale_id}/items/${item.item_id}`).then(() => { toast.success('✅ تم حذف البند'); qc.invalidateQueries({ queryKey: ['pos-ledger'] }); qc.invalidateQueries({ queryKey: ['shift-summary'] }) }).catch((e: any) => toast.error(e.response?.data?.detail || 'فشل')) }}
        message={`حذف "${confirmDelItem?.product_name || ''}" من الفاتورة؟`} danger />
      <ConfirmDialog open={!!confirmDelReturn} onClose={() => setConfirmDelReturn(null)}
        onConfirm={() => { const item = confirmDelReturn; api.delete(`/sales/${item.sale_id}/items/${item.item_id}`).then(() => { toast.success('✅ تم الحذف'); qc.invalidateQueries({ queryKey: ['pos-ledger'] }); qc.invalidateQueries({ queryKey: ['shift-summary'] }) }).catch((e: any) => toast.error(e.response?.data?.detail || 'فشل')) }}
        message={`حذف مرتجع "${confirmDelReturn?.product_name || ''}"؟`} danger />
      <ConfirmDialog open={!!confirmDelTx} onClose={() => setConfirmDelTx(null)}
        onConfirm={() => { const e = confirmDelTx; api.delete(`/shifts/transactions/${e.tx_id}`).then(() => { toast.success('✅ تم الحذف'); qc.invalidateQueries({ queryKey: ['pos-ledger'] }); qc.invalidateQueries({ queryKey: ['shift-summary'] }) }).catch((ex: any) => toast.error(ex.response?.data?.detail || 'فشل')) }}
        message={`حذف "${confirmDelTx?.type_ar || ''} — ${confirmDelTx?.note || ''}"؟`} danger />
      <ConfirmDialog open={confirmClear} onClose={() => setConfirmClear(false)}
        onConfirm={() => { clear(); setConfirmClear(false) }}
        message="مسح جميع الأصناف من السلة؟" danger confirmText="مسح" title="تأكيد المسح" />
    </div>
  )
}
