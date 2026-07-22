import { fixUploadUrl } from '../../utils/format'
import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { settingsApi, categoriesApi, subcategoriesApi, stockApi } from '../../api/endpoints'
import api from '../../api/client'
import { PageLoader } from '../../components/ui/Loaders'
import ConfirmDialog from '../../components/ui/ConfirmDialog'
import Modal from '../../components/ui/Modal'
import toast from 'react-hot-toast'
import { Save, Plus, Trash2, Tag, Layers, Warehouse, Wallet, Pencil, ChevronDown, ChevronLeft, Lock } from 'lucide-react'
import PeriodsTab from './PeriodsTab'
import { useAuthStore } from '../../store/auth'

function WalletsTab() {
  const qc = useQueryClient()
  const { data: wallets, isLoading } = useQuery({ queryKey: ['wallets'], queryFn: () => api.get('/wallets').then(r => r.data) })
  const [showAdd, setShowAdd] = useState(false)
  const [form, setForm] = useState({ name: '', type: 'vodafone_cash', phone: '' })
  const [confirmDelWallet, setConfirmDelWallet] = useState<{ id: string } | null>(null)

  const createMut = useMutation({
    mutationFn: () => api.post('/wallets', form).then(r => r.data),
    onSuccess: () => { toast.success('تمت الإضافة'); setShowAdd(false); setForm({ name: '', type: 'vodafone_cash', phone: '' }); qc.invalidateQueries({ queryKey: ['wallets'] }) }
  })
  const deleteMut = useMutation({
    mutationFn: (id: string) => api.delete(`/wallets/${id}`),
    onSuccess: () => { toast.success('تم الحذف'); qc.invalidateQueries({ queryKey: ['wallets'] }) }
  })

  const typeLabel: Record<string, string> = { cash: '💵 نقدي', vodafone_cash: '📱 فودافون كاش', instapay: '🏦 إنستا باي' }

  return (
    <div className="card max-w-lg">
      <div className="flex items-center justify-between mb-4">
        <h3 className="font-bold text-slate-700">وسائل الدفع والمحافظ الإلكترونية</h3>
        <button onClick={() => setShowAdd(true)} className="px-3 py-1.5 rounded-lg text-xs font-bold text-white flex items-center gap-1" style={{ background: '#1e3a5f' }}>
          <Plus size={13} /> إضافة
        </button>
      </div>
      <div className="space-y-2">
        {wallets?.map((w: any) => (
          <div key={w.id} className="flex items-center justify-between p-3 rounded-xl bg-slate-50 border border-slate-100">
            <div>
              <p className="font-semibold text-slate-800 text-sm">{typeLabel[w.type] || w.type} — {w.name}</p>
              {w.phone && <p className="text-xs text-slate-400 font-mono">{w.phone}</p>}
              <p className="text-xs font-bold text-green-700 mt-0.5">رصيد: {Number(w.balance).toLocaleString('ar-EG')} ج.م</p>
            </div>
            {w.type !== 'cash' && (
              <button onClick={() => setConfirmDelWallet({ id: w.id })} className="p-1.5 rounded-lg hover:bg-red-50 text-slate-300 hover:text-red-500"><Trash2 size={13} /></button>
            )}
          </div>
        ))}
      </div>
      {showAdd && (
        <div className="mt-4 p-4 bg-slate-50 rounded-xl border space-y-3">
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-medium text-slate-600 mb-1">النوع</label>
              <select className="input text-sm" value={form.type} onChange={e => setForm(f => ({...f, type: e.target.value}))}>
                <option value="vodafone_cash">📱 فودافون كاش</option>
                <option value="instapay">🏦 إنستا باي</option>
              </select>
            </div>
            <div>
              <label className="block text-xs font-medium text-slate-600 mb-1">الاسم *</label>
              <input className="input text-sm" value={form.name} onChange={e => setForm(f => ({...f, name: e.target.value}))} placeholder="مثال: فودافون — عمار" />
            </div>
            <div className="col-span-2">
              <label className="block text-xs font-medium text-slate-600 mb-1">رقم المحفظة *</label>
              <input className="input text-sm" value={form.phone} onChange={e => setForm(f => ({...f, phone: e.target.value}))} placeholder="01XXXXXXXXX" />
            </div>
          </div>
          <div className="flex gap-2 justify-end">
            <button onClick={() => setShowAdd(false)} className="px-3 py-1.5 rounded-lg text-xs font-semibold bg-white text-slate-600 border">إلغاء</button>
            <button onClick={() => createMut.mutate()} disabled={!form.name || !form.phone} className="px-4 py-1.5 rounded-lg text-xs font-bold text-white disabled:opacity-50" style={{ background: '#1e3a5f' }}>إضافة</button>
          </div>
        </div>
      )}
      <ConfirmDialog
        open={!!confirmDelWallet}
        onClose={() => setConfirmDelWallet(null)}
        onConfirm={() => deleteMut.mutate(confirmDelWallet!.id)}
        message="هل أنت متأكد من حذف وسيلة الدفع؟"
        danger
      />
    </div>
  )
}

function CategoriesTree({ categories, subcategories }: { categories: any[], subcategories: any[] }) {
  const qc = useQueryClient()
  const [expanded, setExpanded] = useState<Set<string>>(new Set(categories.map((c: any) => c.id)))
  const [confirmDelCat, setConfirmDelCat] = useState<{ id: string; name: string; subsCount: number } | null>(null)
  const [confirmDelSub, setConfirmDelSub] = useState<{ id: string; name: string } | null>(null)
  const [newSubCatId, setNewSubCatId] = useState<string | null>(null)
  const [newSubName, setNewSubName] = useState('')
  const [showNewCat, setShowNewCat] = useState(false)
  const [newCatName, setNewCatName] = useState('')
  const [editCatId, setEditCatId] = useState<{ id: string; name: string } | null>(null)
  const [editCatName, setEditCatName] = useState('')
  const [editSubId, setEditSubId] = useState<{ id: string; catId: string; name: string } | null>(null)
  const [editSubName, setEditSubName] = useState('')

  const toggle = (id: string) => setExpanded(s => { const n = new Set(s); if (n.has(id)) n.delete(id); else n.add(id); return n })
  const getSubs = (catId: string) => subcategories.filter((s: any) => s.category_id === catId)

  const addCatMut = useMutation({
    mutationFn: () => categoriesApi.create(newCatName),
    onSuccess: () => { toast.success('تمت الإضافة'); setShowNewCat(false); setNewCatName(''); qc.invalidateQueries({ queryKey: ['categories'] }) },
    onError: () => toast.error('فشل الحفظ'),
  })

  const editCatMut = useMutation({
    mutationFn: () => categoriesApi.update(editCatId!.id, editCatName),
    onSuccess: () => { toast.success('تم التعديل'); setEditCatId(null); qc.invalidateQueries({ queryKey: ['categories'] }) },
    onError: () => toast.error('فشل الحفظ'),
  })

  const editSubMut = useMutation({
    mutationFn: () => subcategoriesApi.update(editSubId!.id, editSubId!.catId, editSubName),
    onSuccess: () => { toast.success('تم التعديل'); setEditSubId(null); qc.invalidateQueries({ queryKey: ['subcategories'] }) },
    onError: () => toast.error('فشل الحفظ'),
  })

  const addSubMut = useMutation({
    mutationFn: () => subcategoriesApi.create(newSubCatId!, newSubName),
    onSuccess: () => { toast.success('تمت الإضافة'); setNewSubCatId(null); setNewSubName(''); qc.invalidateQueries({ queryKey: ['subcategories'] }) },
    onError: () => toast.error('فشل الحفظ'),
  })

  const deleteCat = useMutation({
    mutationFn: categoriesApi.delete,
    onSuccess: () => { toast.success('تم الحذف'); setConfirmDelCat(null); qc.invalidateQueries({ queryKey: ['categories'] }); qc.invalidateQueries({ queryKey: ['subcategories'] }) },
    onError: () => { toast.error('فشل الحذف — قد تكون الفئة مرتبطة بمنتجات'); setConfirmDelCat(null) },
  })

  const deleteSub = useMutation({
    mutationFn: subcategoriesApi.delete,
    onSuccess: () => { toast.success('تم الحذف'); setConfirmDelSub(null); qc.invalidateQueries({ queryKey: ['subcategories'] }) },
    onError: () => { toast.error('فشل الحذف — قد يكون التصنيف مرتبطاً بمنتجات'); setConfirmDelSub(null) },
  })

  const ActBtn = ({ onClick, color, hoverColor, children, title, size = 'md' }: {
    onClick: () => void; color: string; hoverColor: string; children: React.ReactNode; title?: string; size?: 'sm' | 'md'
  }) => {
    const dim = size === 'sm' ? 'w-7 h-7' : 'w-8 h-8'
    return (
      <button onClick={onClick} title={title}
        className={`${dim} rounded-lg flex items-center justify-center`}
        style={{ color, background: hoverColor ? `${hoverColor}18` : `${color}12` }}>
        {children}
      </button>
    )
  }

  return (
    <>
      <div className="card w-full">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h3 className="font-bold text-slate-800">الفئات والتصنيفات</h3>
            <p className="text-xs text-slate-400 mt-0.5">{categories.length} فئة · {subcategories.length} تصنيف فرعي</p>
          </div>
          <button onClick={() => { setShowNewCat(true); setNewCatName('') }}
            className="flex items-center gap-1.5 px-4 py-2.5 rounded-xl text-xs font-bold text-white"
            style={{ background: '#1e3a5f' }}>
            <Plus size={15} /> فئة جديدة
          </button>
        </div>

        {!categories.length && (
          <div className="text-center py-10 text-slate-400">
            <Tag size={28} className="mx-auto mb-2 opacity-30" />
            <p className="text-sm">لا توجد فئات — اضغط "فئة جديدة" للبدء</p>
          </div>
        )}

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          {categories.map((cat: any) => {
            const subs = getSubs(cat.id)

            return (
              <div key={cat.id} className="rounded-2xl border border-slate-200 bg-white p-4">
                <div className="flex items-center justify-between gap-3">
                  <div className="flex items-center gap-3">
                    <div className="w-9 h-9 rounded-xl flex items-center justify-center text-white" style={{ background: '#1e3a5f' }}>
                      <Tag size={15} />
                    </div>
                    <div>
                      <p className="font-semibold text-sm text-slate-900 leading-tight">{cat.name}</p>
                      <p className="text-xs text-slate-400">{subs.length} تصنيف فرعي</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <ActBtn onClick={() => { setEditCatId({ id: cat.id, name: cat.name }); setEditCatName(cat.name) }}
                      color="#d97706" hoverColor="#d97706" title="تعديل الاسم"><Pencil size={14} /></ActBtn>
                    <ActBtn onClick={() => setConfirmDelCat({ id: cat.id, name: cat.name, subsCount: subs.length })}
                      color="#ef4444" hoverColor="#ef4444" title="حذف"><Trash2 size={14} /></ActBtn>
                  </div>
                </div>

                {subs.length > 0 && (
                  <div className="mt-3 flex flex-wrap gap-2">
                    {subs.map((sub: any) => (
                      <span key={sub.id} className="inline-flex items-center gap-2 px-3 py-1.5 rounded-xl bg-slate-50 border border-slate-200 text-xs text-slate-700">
                        <span className="font-medium">{sub.name}</span>
                        <button onClick={() => { setEditSubId({ id: sub.id, catId: sub.category_id, name: sub.name }); setEditSubName(sub.name) }} className="text-slate-400 hover:text-slate-600"><Pencil size={12} /></button>
                        <button onClick={() => setConfirmDelSub({ id: sub.id, name: sub.name })} className="text-slate-400 hover:text-red-500"><Trash2 size={12} /></button>
                      </span>
                    ))}
                  </div>
                )}

                <button onClick={() => { setNewSubCatId(cat.id); setNewSubName('') }}
                  className="mt-3 w-full py-2 rounded-xl text-xs font-semibold border border-dashed"
                  style={{ color: '#2563eb', borderColor: '#93c5fd', background: '#eff6ff' }}>
                  إضافة تصنيف فرعي
                </button>
              </div>
            )
          })}
        </div>
      </div>

      {/* New Category Modal */}
      <Modal open={showNewCat} onClose={() => setShowNewCat(false)} title="إضافة فئة جديدة">
        <div className="space-y-4">
          <input className="input" value={newCatName} onChange={e => setNewCatName(e.target.value)}
            onKeyDown={e => { if (e.key === 'Enter' && newCatName.trim()) addCatMut.mutate() }}
            placeholder="اكتب اسم الفئة..." autoFocus />
          <div className="flex gap-3 justify-end">
            <button onClick={() => setShowNewCat(false)} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600 hover:bg-slate-200">إلغاء</button>
            <button onClick={() => addCatMut.mutate()} disabled={!newCatName.trim() || addCatMut.isPending}
              className="px-4 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#1e3a5f' }}>
              {addCatMut.isPending ? 'جاري...' : 'إضافة'}
            </button>
          </div>
        </div>
      </Modal>

      {/* Edit Category Modal */}
      <Modal open={!!editCatId} onClose={() => setEditCatId(null)} title="تعديل اسم الفئة">
        <div className="space-y-4">
          <input className="input" value={editCatName} onChange={e => setEditCatName(e.target.value)}
            onKeyDown={e => { if (e.key === 'Enter' && editCatName.trim()) editCatMut.mutate() }}
            placeholder="اكتب الاسم..." autoFocus />
          <div className="flex gap-3 justify-end">
            <button onClick={() => setEditCatId(null)} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600 hover:bg-slate-200">إلغاء</button>
            <button onClick={() => editCatMut.mutate()} disabled={!editCatName.trim() || editCatMut.isPending}
              className="px-4 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#1e3a5f' }}>
              {editCatMut.isPending ? 'جاري...' : 'حفظ'}
            </button>
          </div>
        </div>
      </Modal>

      {/* Edit Subcategory Modal */}
      <Modal open={!!editSubId} onClose={() => setEditSubId(null)} title="تعديل اسم التصنيف الفرعي">
        <div className="space-y-4">
          <input className="input" value={editSubName} onChange={e => setEditSubName(e.target.value)}
            onKeyDown={e => { if (e.key === 'Enter' && editSubName.trim()) editSubMut.mutate() }}
            placeholder="اكتب الاسم..." autoFocus />
          <div className="flex gap-3 justify-end">
            <button onClick={() => setEditSubId(null)} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600 hover:bg-slate-200">إلغاء</button>
            <button onClick={() => editSubMut.mutate()} disabled={!editSubName.trim() || editSubMut.isPending}
              className="px-4 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#1e3a5f' }}>
              {editSubMut.isPending ? 'جاري...' : 'حفظ'}
            </button>
          </div>
        </div>
      </Modal>

      {/* New Subcategory Modal */}
      <Modal open={!!newSubCatId} onClose={() => setNewSubCatId(null)} title="إضافة تصنيف فرعي">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">الفئة الرئيسية</label>
            <p className="text-sm font-semibold text-slate-800">{categories.find((c: any) => c.id === newSubCatId)?.name}</p>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">اسم التصنيف الفرعي</label>
            <input className="input" value={newSubName} onChange={e => setNewSubName(e.target.value)}
              onKeyDown={e => { if (e.key === 'Enter' && newSubName.trim()) addSubMut.mutate() }}
              placeholder="اكتب الاسم..." autoFocus />
          </div>
          <div className="flex gap-3 justify-end">
            <button onClick={() => setNewSubCatId(null)} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600 hover:bg-slate-200">إلغاء</button>
            <button onClick={() => addSubMut.mutate()} disabled={!newSubName.trim() || addSubMut.isPending}
              className="px-4 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#1e3a5f' }}>
              {addSubMut.isPending ? 'جاري...' : 'إضافة'}
            </button>
          </div>
        </div>
      </Modal>

      <ConfirmDialog
        open={!!confirmDelCat}
        onClose={() => setConfirmDelCat(null)}
        onConfirm={() => deleteCat.mutate(confirmDelCat!.id)}
        message={`حذف "${confirmDelCat?.name}" وكل تصنيفاتها الفرعية (${confirmDelCat?.subsCount})؟`}
        danger
        closeOnConfirm={false}
      />
      <ConfirmDialog
        open={!!confirmDelSub}
        onClose={() => setConfirmDelSub(null)}
        onConfirm={() => deleteSub.mutate(confirmDelSub!.id)}
        message={`حذف "${confirmDelSub?.name}"؟`}
        danger
        closeOnConfirm={false}
      />
    </>
  )
}

export default function SettingsPage() {
  const [tab, setTab] = useState<'store' | 'categories' | 'options' | 'warehouses' | 'wallets' | 'periods'>('store')
  const [storeForm, setStoreForm] = useState<any>(null)
  const qc = useQueryClient()

  const [showAddWh, setShowAddWh] = useState(false)
  const [newWhCode, setNewWhCode] = useState('')
  const [newWhName, setNewWhName] = useState('')
  const [newWhType, setNewWhType] = useState('showroom')

  const { data: warehouses } = useQuery({ queryKey: ['warehouses'], queryFn: stockApi.warehouses })
  const [renameWhId, setRenameWhId] = useState<{ id: string; name: string } | null>(null)
  const [renameWhName, setRenameWhName] = useState('')
  const [confirmResetWh, setConfirmResetWh] = useState<{ id: string; name: string } | null>(null)
  const [confirmDelWh, setConfirmDelWh] = useState<{ id: string } | null>(null)
  const renameWh = useMutation({
    mutationFn: () => api.put(`/stock/warehouses/${renameWhId!.id}`, { name: renameWhName }).then(r => r.data),
    onSuccess: () => { toast.success('تم تعديل الاسم'); setRenameWhId(null); qc.invalidateQueries({ queryKey: ['warehouses'] }) },
  })

  const addWh = useMutation({
    mutationFn: () => api.post('/stock/warehouses', { code: newWhCode, name: newWhName, warehouse_type: newWhType }).then(r => r.data),
    onSuccess: () => { toast.success('تمت الإضافة'); setShowAddWh(false); setNewWhCode(''); setNewWhName(''); setNewWhType('showroom'); qc.invalidateQueries({ queryKey: ['warehouses'] }) },
  })
  const deleteWh = useMutation({
    mutationFn: (id: string) => api.delete(`/stock/warehouses/${id}`),
    onSuccess: () => { toast.success('تم حذف المخزن'); qc.invalidateQueries({ queryKey: ['warehouses'] }) },
  })

  const { data: settings, isLoading } = useQuery({ queryKey: ['settings'], queryFn: settingsApi.get })
  const { data: options } = useQuery({ queryKey: ['product-options'], queryFn: settingsApi.getOptions })
  const [addOptionKey, setAddOptionKey] = useState('')
  const [addOptionVal, setAddOptionVal] = useState('')
  const addOptionMut = useMutation({
    mutationFn: async () => {
      const curr = options?.[addOptionKey] || []
      await api.put('/settings/product-options', { [addOptionKey]: [...curr, addOptionVal] })
    },
    onSuccess: () => { toast.success('تمت الإضافة'); setAddOptionKey(''); setAddOptionVal(''); qc.invalidateQueries({ queryKey: ['product-options'] }) },
  })
  const deleteOptionMut = useMutation({
    mutationFn: async ({ key, value }: { key: string; value: string }) => {
      const curr: string[] = options?.[key] || []
      await api.put('/settings/product-options', { [key]: curr.filter(v => v !== value) })
    },
    onSuccess: () => { toast.success('تم الحذف'); qc.invalidateQueries({ queryKey: ['product-options'] }) },
  })
  const { data: categories } = useQuery({ queryKey: ['categories'], queryFn: categoriesApi.list })
  const { data: subcategories } = useQuery({ queryKey: ['subcategories'], queryFn: () => subcategoriesApi.list() })

  const uploadLogo = async (file: File) => {
    if (!file.type.startsWith('image/')) {
      toast.error('يرجى اختيار ملف صورة فقط')
      return
    }
    if (file.size > 2 * 1024 * 1024) {
      toast.error('حجم الصورة يجب أن يكون أقل من 2 ميجابايت')
      return
    }
    const fd = new FormData()
    fd.append('file', file)
    try {
      const r = await api.post('/settings/upload-logo', fd, { headers: { 'Content-Type': 'multipart/form-data' } })
      setStoreForm((f: any) => ({ ...(f || settings || {}), logo_url: r.data.logo_url }))
      qc.invalidateQueries({ queryKey: ['settings'] })
      toast.success('تم رفع الشعار')
    } catch { toast.error('فشل رفع الشعار') }
  }

  const saveSettings = useMutation({
    mutationFn: (data: any) => settingsApi.update(data),
    onSuccess: () => { toast.success('تم حفظ الإعدادات'); qc.invalidateQueries({ queryKey: ['settings'] }) },
  })
  const currentUser = useAuthStore((s: any) => s.user)
  const hasPerm = (p: string) => currentUser?.permissions?.includes(p)

  if (isLoading) return <PageLoader />

  const sf = storeForm || settings || {}

  const tabs = [
    { id: 'store', label: 'إعدادات المتجر', icon: Save },
    { id: 'categories', label: 'الفئات والتصنيفات', icon: Tag },
    { id: 'options', label: 'خيارات المنتجات', icon: Layers },
    ...(hasPerm('inventory') ? [{ id: 'warehouses', label: 'المخازن', icon: Warehouse }] : []),
    ...(hasPerm('finance') ? [{ id: 'wallets', label: 'وسائل الدفع', icon: Wallet }] : []),
    ...(hasPerm('finance') ? [{ id: 'periods', label: 'إغلاق الشهور', icon: Lock }] : []),
  ]

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">الإعدادات</h1>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 mb-6 border-b border-slate-200 pb-0">
        {tabs.map(({ id, label, icon: Icon }) => (
          <button
            key={id}
            onClick={() => setTab(id as any)}
            className={`flex items-center gap-2 px-5 py-3 text-sm font-semibold border-b-2 -mb-px ${tab === id ? 'border-blue-600 text-blue-700' : 'border-transparent text-slate-500 hover:text-slate-700'}`}
          >
            <Icon size={16} />{label}
          </button>
        ))}
      </div>

      {/* Store settings */}
      {tab === 'store' && (
        <div className="card max-w-lg">
          <h3 className="font-bold text-slate-700 mb-5">بيانات المتجر</h3>
          <div className="space-y-4">
            {/* Logo */}
            <div>
              <label className="block text-sm font-medium text-slate-600 mb-2">شعار الشركة (Logo)</label>
              <div className="flex items-center gap-4">
                {sf.logo_url ? (
                  <img src={fixUploadUrl(sf.logo_url)} alt="logo" className="w-16 h-16 rounded-xl object-contain border border-slate-200" />
                ) : (
                  <div className="w-16 h-16 rounded-xl bg-slate-100 flex items-center justify-center text-slate-400 text-2xl border-2 border-dashed border-slate-300">🏢</div>
                )}
                <div className="flex-1 space-y-2">
                  <input className="input text-sm" value={sf.logo_url || ''} onChange={e => setStoreForm({ ...sf, logo_url: e.target.value })} placeholder="رابط الصورة (URL)" />
                  <div className="flex items-center gap-2">
                    <label className="cursor-pointer px-3 py-1.5 rounded-lg text-xs font-semibold bg-slate-100 text-slate-600 hover:bg-slate-200">
                      📁 رفع صورة
                      <input type="file" accept="image/*" className="hidden" onChange={e => {
                        const file = e.target.files?.[0]
                        if (file) uploadLogo(file)
                        e.target.value = ''
                      }} />
                    </label>
                    <p className="text-xs text-slate-400">PNG مربع 512×512 للأفضل</p>
                  </div>
                </div>
              </div>
            </div>
            {[
              { key: 'store_name', label: 'اسم الشركة' },
              { key: 'store_address', label: 'العنوان' },
              { key: 'store_phone', label: 'رقم الهاتف' },
              { key: 'currency', label: 'العملة' },
            ].map(({ key, label }) => (
              <div key={key}>
                <label className="block text-sm font-medium text-slate-600 mb-1">{label}</label>
                <input className="input" value={sf[key] || ''} onChange={e => setStoreForm({ ...sf, [key]: e.target.value })} />
              </div>
            ))}

            {/* Paper size */}
            <div>
              <label className="block text-sm font-medium text-slate-600 mb-1">حجم ورق الطباعة والـ PDF</label>
              <select className="input" value={sf.paper_size || 'A4'} onChange={e => setStoreForm({ ...sf, paper_size: e.target.value })}>
                <option value="A4">A4 (210 × 297 mm) — الأكثر شيوعاً</option>
                <option value="A5">A5 (148 × 210 mm) — فواتير صغيرة</option>
                <option value="Letter">Letter (216 × 279 mm) — أمريكي</option>
              </select>
            </div>

            {/* Contact phones */}
            <div>
              <div className="flex items-center justify-between mb-2">
                <label className="block text-sm font-medium text-slate-600">أرقام التواصل (تظهر في الفواتير)</label>
                <button onClick={() => {
                  const arr = [...(sf.contact_phones || []), { name: '', phone: '' }]
                  setStoreForm({ ...sf, contact_phones: arr })
                }} className="text-xs px-2 py-1 rounded bg-blue-100 text-blue-600 font-medium">+ إضافة رقم</button>
              </div>
              <div className="space-y-2">
                {(sf.contact_phones || [{ name: '', phone: '' }]).map((c: any, i: number) => (
                  <div key={i} className="flex gap-2">
                    <input className="input flex-1 text-sm" placeholder="الاسم" value={c.name || ''} onChange={e => {
                      const arr = [...(sf.contact_phones || [])]
                      arr[i] = { ...arr[i], name: e.target.value }
                      setStoreForm({ ...sf, contact_phones: arr })
                    }} />
                    <input className="input flex-1 text-sm" placeholder="رقم التليفون" value={c.phone || ''} onChange={e => {
                      const arr = [...(sf.contact_phones || [])]
                      arr[i] = { ...arr[i], phone: e.target.value }
                      setStoreForm({ ...sf, contact_phones: arr })
                    }} />
                    <button onClick={() => {
                      const arr = sf.contact_phones?.filter((_: any, j: number) => j !== i) || []
                      setStoreForm({ ...sf, contact_phones: arr })
                    }} className="p-1.5 rounded-lg hover:bg-red-50 text-slate-300 hover:text-red-500 flex-shrink-0"><Trash2 size={14} /></button>
                  </div>
                ))}
              </div>
            </div>

            <button onClick={() => saveSettings.mutate(sf)} disabled={saveSettings.isPending} className="px-5 py-2.5 rounded-xl text-sm font-bold text-white w-full flex items-center justify-center gap-2" style={{ background: '#1e3a5f' }}>
              <Save size={16} /> {saveSettings.isPending ? 'جاري...' : 'حفظ الإعدادات'}
            </button>
          </div>
        </div>
      )}

      {/* Categories */}
      {tab === 'categories' && (
        <CategoriesTree categories={categories || []} subcategories={subcategories || []} />
      )}

      {/* Product options */}
      {tab === 'options' && options && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {[
            { key: 'sizes', label: 'المقاسات' },
            { key: 'companies', label: 'الشركات / الموردون' },
            { key: 'materials', label: 'الخامات' },
            { key: 'units', label: 'الوحدات' },
          ].map(({ key, label }) => (
            <div key={key} className="card">
              <div className="flex items-center justify-between mb-3">
                <h3 className="font-bold text-slate-700">{label} ({options[key]?.length || 0})</h3>
                <button onClick={() => { setAddOptionKey(key); setAddOptionVal('') }} className="text-xs px-2 py-1 rounded bg-blue-100 text-blue-600 font-medium">+ إضافة</button>
              </div>
              <div className="flex flex-wrap gap-2 max-h-48 overflow-y-auto">
                {options[key]?.map((v: string) => (
                  <span key={v} className="inline-flex items-center gap-1 badge-blue text-xs">
                    {v}
                    <button onClick={() => deleteOptionMut.mutate({ key, value: v })} className="hover:text-red-600 mr-1">&times;</button>
                  </span>
                ))}
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Add Option Modal */}
      <Modal open={!!addOptionKey} onClose={() => setAddOptionKey('')} title="إضافة خيار">
        <div className="space-y-4">
          <p className="text-sm font-semibold text-slate-800">
            {addOptionKey === 'sizes' ? 'المقاسات' : addOptionKey === 'companies' ? 'الشركات / الموردون' : addOptionKey === 'materials' ? 'الخامات' : 'الوحدات'}
          </p>
          <input className="input" value={addOptionVal} onChange={e => setAddOptionVal(e.target.value)}
            onKeyDown={e => { if (e.key === 'Enter' && addOptionVal.trim()) addOptionMut.mutate() }}
            placeholder="اكتب القيمة..." autoFocus />
          <div className="flex gap-3 justify-end">
            <button onClick={() => setAddOptionKey('')} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600 hover:bg-slate-200">إلغاء</button>
            <button onClick={() => addOptionMut.mutate()} disabled={!addOptionVal.trim() || addOptionMut.isPending}
              className="px-4 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#1e3a5f' }}>
              {addOptionMut.isPending ? 'جاري...' : 'إضافة'}
            </button>
          </div>
        </div>
      </Modal>

      {/* Warehouses */}
      {tab === 'warehouses' && (
        <div className="card max-w-lg">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-bold text-slate-700">المخازن ({warehouses?.length || 0})</h3>
            <button onClick={() => setShowAddWh(true)} className="btn-primary btn-sm px-3 py-1.5 rounded-lg text-xs text-white flex items-center gap-1" style={{ background: '#1e3a5f' }}>
              <Plus size={13} /> إضافة مخزن
            </button>
          </div>
          <div className="space-y-2">
            {warehouses?.map((w: any) => (
              <div key={w.id} className="flex items-center justify-between p-3 rounded-xl bg-slate-50 border border-slate-100">
                <div className="flex-1">
                  <p className="font-semibold text-slate-800">{w.name}</p>
                  <div className="flex gap-2 mt-0.5"><p className="text-xs text-slate-400 font-mono">{w.code}</p><span className={w.warehouse_type === 'showroom' ? 'badge-blue text-xs' : 'badge-gray text-xs'}>{w.warehouse_type === 'showroom' ? 'معرض' : 'مخزن'}</span></div>
                </div>
                <div className="flex gap-1">
                  <button onClick={() => { setRenameWhId({ id: w.id, name: w.name }); setRenameWhName(w.name) }} className="p-1 rounded-lg hover:bg-slate-100 text-slate-400 hover:text-slate-600"><Pencil size={13} /></button>
                  {hasPerm('settings') && (
                    <button
                      onClick={() => setConfirmResetWh({ id: w.id, name: w.name })}
                      className="p-1 rounded-lg hover:bg-amber-50 text-slate-300 hover:text-amber-600"
                      title="تصفير الجرد">
                      🗑️
                    </button>
                  )}
                  {w.code !== 'main' && (
                    <button onClick={() => setConfirmDelWh({ id: w.id })} className="p-1 rounded-lg hover:bg-red-50 text-slate-300 hover:text-red-500"><Trash2 size={13} /></button>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {tab === 'wallets' && <WalletsTab />}
      {tab === 'periods' && <PeriodsTab />}

      <Modal open={showAddWh} onClose={() => setShowAddWh(false)} title="إضافة مخزن جديد">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">النوع</label>
            <div className="flex gap-2">
              {[{v:'showroom',l:'🏪 معرض'},{v:'warehouse',l:'🏭 مخزن'}].map(({v,l}) => (
                <button key={v} onClick={() => setNewWhType(v)}
                  className={`flex-1 py-2.5 rounded-xl text-sm font-bold border-2 transition-all ${newWhType===v ? 'text-white border-transparent' : 'bg-white text-slate-600 border-slate-200'}`}
                  style={newWhType===v ? {background:'#1e3a5f'} : {}}>
                  {l}
                </button>
              ))}
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">الكود (بالإنجليزية)</label>
            <input className="input" value={newWhCode} onChange={e => setNewWhCode(e.target.value.toUpperCase().replace(/[^A-Z0-9_-]/g, ''))} placeholder={newWhType==='showroom' ? 'مثال: SH4' : 'مثال: WH6'} />
            {newWhCode && !/^[A-Z0-9_-]+$/.test(newWhCode) && <p className="text-xs text-red-500 mt-1">يُسمح فقط بأحرف إنجليزية وأرقام و _ و -</p>}
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">الاسم</label>
            <input className="input" value={newWhName} onChange={e => setNewWhName(e.target.value)} placeholder={newWhType==='showroom' ? 'مثال: المعرض الرابع' : 'مثال: المخزن السادس'} />
          </div>
          <div className="flex gap-3 justify-end">
            <button onClick={() => setShowAddWh(false)} className="btn-ghost px-4 py-2 rounded-xl text-sm font-semibold">إلغاء</button>
            <button onClick={() => addWh.mutate()} disabled={!newWhCode || !newWhName} className="px-4 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#1e3a5f' }}>إضافة</button>
          </div>
        </div>
        </Modal>

      <ConfirmDialog
        open={!!confirmResetWh}
        onClose={() => setConfirmResetWh(null)}
        onConfirm={async () => {
          if (!confirmResetWh) return
          await api.delete(`/stock/movements?warehouse_id=${confirmResetWh.id}`)
          toast.success(`✅ تم تصفير جرد ${confirmResetWh.name}`)
          qc.invalidateQueries({ queryKey: ['balances'] })
        }}
        message={confirmResetWh ? `تصفير جرد "${confirmResetWh.name}"؟\nسيتم حذف كل حركات المخزون لهذا الفرع ولا يمكن التراجع.` : ''}
        confirmText="تصفير"
        danger
      />
      <ConfirmDialog
        open={!!confirmDelWh}
        onClose={() => setConfirmDelWh(null)}
        onConfirm={() => deleteWh.mutate(confirmDelWh!.id)}
        message="هل أنت متأكد من حذف المخزن؟"
        danger
      />

      {/* Rename Warehouse Modal */}
      <Modal open={!!renameWhId} onClose={() => setRenameWhId(null)} title="تعديل اسم المخزن">
        <div className="space-y-4">
          <input className="input" value={renameWhName} onChange={e => setRenameWhName(e.target.value)}
            onKeyDown={e => { if (e.key === 'Enter' && renameWhName.trim()) renameWh.mutate() }}
            placeholder="اكتب الاسم..." autoFocus />
          <div className="flex gap-3 justify-end">
            <button onClick={() => setRenameWhId(null)} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600 hover:bg-slate-200">إلغاء</button>
            <button onClick={() => renameWh.mutate()} disabled={!renameWhName.trim() || renameWh.isPending}
              className="px-4 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#1e3a5f' }}>
              {renameWh.isPending ? 'جاري...' : 'حفظ'}
            </button>
          </div>
        </div>
      </Modal>

    </div>
  )
}
