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

function InlineInput({ editing, setEditing, handleSave, isSaving, onCancel }: {
  editing: any; setEditing: (f: any) => void; handleSave: () => void; isSaving: boolean; onCancel: () => void
}) {
  return (
    <div className="flex items-center gap-2 px-3 py-2 rounded-xl bg-blue-50 border border-blue-200">
      <input autoFocus className="flex-1 bg-transparent text-sm font-medium text-slate-800 outline-none placeholder-slate-400"
        placeholder="اكتب الاسم..."
        value={editing?.name || ''}
        onChange={e => setEditing((p: any) => ({ ...p, name: e.target.value }))}
        onKeyDown={e => { if (e.key === 'Enter') handleSave(); if (e.key === 'Escape') onCancel() }} />
      <button onClick={handleSave} disabled={isSaving}
        className="px-3 py-1 rounded-lg text-xs font-bold text-white disabled:opacity-50"
        style={{ background: '#1e3a5f' }}>
        {isSaving ? '...' : 'حفظ'}
      </button>
      <button onClick={onCancel} className="px-2 py-1 rounded-lg text-xs text-slate-500 hover:bg-slate-100">إلغاء</button>
    </div>
  )
}

function CategoriesTree({ categories, subcategories }: { categories: any[], subcategories: any[] }) {
  const qc = useQueryClient()
  const [expanded, setExpanded] = useState<Set<string>>(new Set(categories.map((c: any) => c.id)))
  // editing: { type: 'cat'|'sub'|'new-cat'|'new-sub', id?, catId?, name }
  const [editing, setEditing] = useState<any>(null)
  const [confirmDelCat, setConfirmDelCat] = useState<{ id: string; name: string; subsCount: number } | null>(null)
  const [confirmDelSub, setConfirmDelSub] = useState<{ id: string; name: string } | null>(null)

  const toggle = (id: string) => setExpanded(prev => { const s = new Set(prev); if (s.has(id)) s.delete(id); else s.add(id); return s })
  const getSubs = (catId: string) => subcategories.filter((s: any) => s.category_id === catId)

  const saveCat = useMutation({
    mutationFn: (e: any) => e.id ? categoriesApi.update(e.id, e.name) : categoriesApi.create(e.name),
    onSuccess: (_, e) => {
      toast.success(e.id ? 'تم التعديل' : 'تمت الإضافة')
      setEditing(null)
      qc.invalidateQueries({ queryKey: ['categories'] })
    },
    onError: () => toast.error('فشل الحفظ — تأكد من الاتصال'),
  })

  const saveSub = useMutation({
    mutationFn: (e: any) => e.id
      ? subcategoriesApi.update(e.id, e.catId, e.name)
      : subcategoriesApi.create(e.catId, e.name),
    onSuccess: (_, e) => {
      toast.success(e.id ? 'تم التعديل' : 'تمت الإضافة')
      setEditing(null)
      qc.invalidateQueries({ queryKey: ['subcategories'] })
    },
    onError: () => toast.error('فشل الحفظ — تأكد من الاتصال'),
  })

  const deleteCat = useMutation({
    mutationFn: categoriesApi.delete,
    onSuccess: () => { toast.success('تم الحذف'); qc.invalidateQueries({ queryKey: ['categories'] }); qc.invalidateQueries({ queryKey: ['subcategories'] }) },
    onError: () => toast.error('فشل الحذف — قد تكون الفئة مرتبطة بمنتجات'),
  })

  const deleteSub = useMutation({
    mutationFn: subcategoriesApi.delete,
    onSuccess: () => { toast.success('تم الحذف'); qc.invalidateQueries({ queryKey: ['subcategories'] }) },
    onError: () => toast.error('فشل الحذف — قد يكون التصنيف مرتبطاً بمنتجات'),
  })

  const handleSave = () => {
    if (!editing?.name?.trim()) { toast.error('الاسم مطلوب'); return }
    if (editing.type === 'cat' || editing.type === 'new-cat') saveCat.mutate(editing)
    else saveSub.mutate(editing)
  }

  const isSaving = saveCat.isPending || saveSub.isPending

  return (
    <div className="card max-w-2xl">
      <div className="flex items-center justify-between mb-4">
        <div>
          <h3 className="font-bold text-slate-800">الفئات والتصنيفات</h3>
          <p className="text-xs text-slate-400 mt-0.5">{categories.length} فئة · {subcategories.length} تصنيف فرعي</p>
        </div>
        <button onClick={() => setEditing({ type: 'new-cat', name: '' })}
          className="flex items-center gap-1.5 px-3 py-2 rounded-xl text-xs font-bold text-white"
          style={{ background: '#1e3a5f' }}>
          <Plus size={13} /> فئة جديدة
        </button>
      </div>

      {/* New category input */}
      {editing?.type === 'new-cat' && (
        <div className="mb-3">
          <InlineInput editing={editing} setEditing={setEditing} handleSave={handleSave} isSaving={isSaving} onCancel={() => setEditing(null)} />
        </div>
      )}

      {!categories.length && !editing && (
        <div className="text-center py-10 text-slate-400">
          <Tag size={28} className="mx-auto mb-2 opacity-30" />
          <p className="text-sm">لا توجد فئات — اضغط "فئة جديدة" للبدء</p>
        </div>
      )}

      <div className="space-y-0.5">
        {categories.map((cat: any) => {
          const subs = getSubs(cat.id)
          const isOpen = expanded.has(cat.id)
          const isEditingCat = editing?.type === 'cat' && editing?.id === cat.id

          return (
            <div key={cat.id}>
              {/* Category row */}
              {isEditingCat ? (
                <div className="mb-1"><InlineInput onCancel={() => setEditing(null)} /></div>
              ) : (
                <div className="flex items-center gap-2 px-3 py-2.5 rounded-xl hover:bg-slate-50 group transition-colors">
                  <button onClick={() => toggle(cat.id)}
                    className="w-5 h-5 flex items-center justify-center text-slate-400 hover:text-slate-600 flex-shrink-0">
                    {subs.length > 0
                      ? (isOpen ? <ChevronDown size={14} /> : <ChevronLeft size={14} />)
                      : <span className="w-3 h-px bg-slate-200 block" />}
                  </button>
                  <div className="w-7 h-7 rounded-lg flex items-center justify-center flex-shrink-0" style={{ background: '#1e3a5f12' }}>
                    <Tag size={13} style={{ color: '#1e3a5f' }} />
                  </div>
                  <span className="flex-1 font-semibold text-sm text-slate-800">{cat.name}</span>
                  {subs.length > 0 && (
                    <span className="text-xs px-2 py-0.5 rounded-full bg-slate-100 text-slate-500">{subs.length}</span>
                  )}
                  <div className="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                    <button onClick={() => { setEditing({ type: 'new-sub', catId: cat.id, name: '' }); setExpanded(p => new Set([...p, cat.id])) }}
                      className="p-1.5 rounded-lg hover:bg-blue-50 text-slate-300 hover:text-blue-600" title="إضافة تصنيف فرعي">
                      <Plus size={13} />
                    </button>
                    <button onClick={() => setEditing({ type: 'cat', id: cat.id, name: cat.name })}
                      className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-300 hover:text-slate-600" title="تعديل">
                      <Pencil size={13} />
                    </button>
                    <button onClick={() => setConfirmDelCat({ id: cat.id, name: cat.name, subsCount: subs.length })}
                      className="p-1.5 rounded-lg hover:bg-red-50 text-slate-300 hover:text-red-500" title="حذف">
                      <Trash2 size={13} />
                    </button>
                  </div>
                </div>
              )}

              {/* Subcategories */}
              {isOpen && (
                <div className="mr-10 border-r-2 border-slate-100 pr-3 mb-1 space-y-0.5">
                  {subs.map((sub: any) => {
                    const isEditingSub = editing?.type === 'sub' && editing?.id === sub.id
                    return isEditingSub ? (
                      <div key={sub.id}><InlineInput onCancel={() => setEditing(null)} /></div>
                    ) : (
                      <div key={sub.id} className="flex items-center gap-2 px-3 py-2 rounded-xl hover:bg-slate-50 group transition-colors">
                        <div className="w-6 h-6 rounded-lg flex items-center justify-center flex-shrink-0" style={{ background: '#c8a84b15' }}>
                          <Layers size={11} style={{ color: '#c8a84b' }} />
                        </div>
                        <span className="flex-1 text-sm text-slate-600">{sub.name}</span>
                        <div className="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                          <button onClick={() => setEditing({ type: 'sub', id: sub.id, catId: sub.category_id, name: sub.name })}
                            className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-300 hover:text-slate-600" title="تعديل">
                            <Pencil size={12} />
                          </button>
                          <button onClick={() => setConfirmDelSub({ id: sub.id, name: sub.name })}
                            className="p-1.5 rounded-lg hover:bg-red-50 text-slate-300 hover:text-red-500" title="حذف">
                            <Trash2 size={12} />
                          </button>
                        </div>
                      </div>
                    )
                  })}

                  {/* New sub input */}
                  {editing?.type === 'new-sub' && editing?.catId === cat.id ? (
                    <InlineInput editing={editing} setEditing={setEditing} handleSave={handleSave} isSaving={isSaving} onCancel={() => setEditing(null)} />
                  ) : (
                    <button onClick={() => { setEditing({ type: 'new-sub', catId: cat.id, name: '' }); setExpanded(p => new Set([...p, cat.id])) }}
                      className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs text-slate-400 hover:text-blue-600 hover:bg-blue-50 transition-colors w-full">
                      <Plus size={11} /> تصنيف فرعي جديد
                    </button>
                  )}
                </div>
              )}
            </div>
          )
        })}
      </div>
      <ConfirmDialog
        open={!!confirmDelCat}
        onClose={() => setConfirmDelCat(null)}
        onConfirm={() => deleteCat.mutate(confirmDelCat!.id)}
        message={`حذف "${confirmDelCat?.name}" وكل تصنيفاتها الفرعية (${confirmDelCat?.subsCount})؟`}
        danger
      />
      <ConfirmDialog
        open={!!confirmDelSub}
        onClose={() => setConfirmDelSub(null)}
        onConfirm={() => deleteSub.mutate(confirmDelSub!.id)}
        message={`حذف "${confirmDelSub?.name}"؟`}
        danger
      />
    </div>
  )
}

export default function SettingsPage() {
  const [tab, setTab] = useState<'store' | 'categories' | 'options' | 'warehouses' | 'wallets' | 'periods'>('store')
  const [storeForm, setStoreForm] = useState<any>(null)
  const [showAddCat, setShowAddCat] = useState(false)
  const [showAddSub, setShowAddSub] = useState(false)
  const [newCatName, setNewCatName] = useState('')
  const [newSubName, setNewSubName] = useState('')
  const [editCat, setEditCat] = useState<any>(null)
  const [editSub, setEditSub] = useState<any>(null)
  const [selectedCatForSub, setSelectedCatForSub] = useState('')
  const qc = useQueryClient()

  const [showAddWh, setShowAddWh] = useState(false)
  const [newWhCode, setNewWhCode] = useState('')
  const [newWhName, setNewWhName] = useState('')
  const [newWhType, setNewWhType] = useState('showroom')

  const { data: warehouses } = useQuery({ queryKey: ['warehouses'], queryFn: stockApi.warehouses })
  const [editingWh, setEditingWh] = useState<any>(null)
  const [editWhName, setEditWhName] = useState('')
  const [confirmResetWh, setConfirmResetWh] = useState<{ id: string; name: string } | null>(null)
  const [confirmDelWh, setConfirmDelWh] = useState<{ id: string } | null>(null)
  const renameWh = useMutation({
    mutationFn: () => api.put(`/stock/warehouses/${editingWh.id}`, { name: editWhName }).then(r => r.data),
    onSuccess: () => { toast.success('تم تعديل الاسم'); setEditingWh(null); qc.invalidateQueries({ queryKey: ['warehouses'] }) },
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
  const addCat = useMutation({
    mutationFn: () => categoriesApi.create(newCatName),
    onSuccess: () => { toast.success('تمت الإضافة'); setShowAddCat(false); setNewCatName(''); qc.invalidateQueries({ queryKey: ['categories'] }) },
  })
  const addSub = useMutation({
    mutationFn: () => subcategoriesApi.create(selectedCatForSub, newSubName),
    onSuccess: () => { toast.success('تمت الإضافة'); setShowAddSub(false); setNewSubName(''); qc.invalidateQueries({ queryKey: ['subcategories'] }) },
  })
  const updateCatMut = useMutation({
    mutationFn: ({ id, name }: any) => categoriesApi.update(id, name),
    onSuccess: () => { toast.success('تم التعديل'); setEditCat(null); qc.invalidateQueries({ queryKey: ['categories'] }) },
  })
  const updateSubMut = useMutation({
    mutationFn: ({ id, category_id, name }: any) => subcategoriesApi.update(id, category_id, name),
    onSuccess: () => { toast.success('تم التعديل'); setEditSub(null); qc.invalidateQueries({ queryKey: ['subcategories'] }) },
  })

  const currentUser = useAuthStore((s: any) => s.user)
  const isAdmin = currentUser?.role === 'admin'
  const hasPerm = (p: string) => isAdmin || currentUser?.permissions?.includes(p)

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
            className={`flex items-center gap-2 px-5 py-3 text-sm font-semibold border-b-2 transition-all -mb-px ${tab === id ? 'border-blue-600 text-blue-700' : 'border-transparent text-slate-500 hover:text-slate-700'}`}
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
                <button onClick={() => { setOptionKey(key); setNewOption('') }} className="text-xs px-2 py-1 rounded bg-blue-100 text-blue-600 font-medium">+ إضافة</button>
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
                  {editingWh?.id === w.id ? (
                    <div className="flex gap-2">
                      <input className="input text-sm py-1" value={editWhName} onChange={e => setEditWhName(e.target.value)} autoFocus />
                      <button onClick={() => renameWh.mutate()} disabled={renameWh.isPending} className="px-3 py-1 rounded-lg text-xs font-bold text-white bg-green-600 disabled:opacity-50">
                        {renameWh.isPending ? '...' : 'حفظ'}
                      </button>
                      <button onClick={() => setEditingWh(null)} className="px-2 py-1 rounded-lg text-xs bg-slate-100">إلغاء</button>
                    </div>
                  ) : (
                    <>
                      <p className="font-semibold text-slate-800">{w.name}</p>
                      <div className="flex gap-2 mt-0.5"><p className="text-xs text-slate-400 font-mono">{w.code}</p><span className={w.warehouse_type === 'showroom' ? 'badge-blue text-xs' : 'badge-gray text-xs'}>{w.warehouse_type === 'showroom' ? 'معرض' : 'مخزن'}</span></div>
                    </>
                  )}
                </div>
                <div className="flex gap-1">
                  <button onClick={() => { setEditingWh(w); setEditWhName(w.name) }} className="p-1 rounded-lg hover:bg-slate-100 text-slate-400 hover:text-slate-600"><svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg></button>
                  {isAdmin && (
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

       <Modal open={showAddCat} onClose={() => setShowAddCat(false)} title="إضافة فئة جديدة">
         <div className="space-y-4">
           <input className="input" placeholder="اسم الفئة" value={newCatName} onChange={e => setNewCatName(e.target.value)} />
           <div className="flex gap-3 justify-end">
             <button onClick={() => setShowAddCat(false)} className="btn-ghost px-4 py-2 rounded-xl text-sm font-semibold">إلغاء</button>
             <button onClick={() => addCat.mutate()} disabled={!newCatName.trim() || addCat.isPending} className="px-4 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#1e3a5f' }}>
               {addCat.isPending ? 'جاري...' : 'إضافة'}
             </button>
           </div>
         </div>
       </Modal>

      <Modal open={showAddSub} onClose={() => setShowAddSub(false)} title="إضافة تصنيف فرعي">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">الفئة الرئيسية</label>
            <select className="input" value={selectedCatForSub} onChange={e => setSelectedCatForSub(e.target.value)}>
              <option value="">اختر فئة...</option>
              {categories?.map((c: any) => <option key={c.id} value={c.id}>{c.name}</option>)}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">اسم التصنيف</label>
            <input className="input" value={newSubName} onChange={e => setNewSubName(e.target.value)} />
          </div>
          <div className="flex gap-3 justify-end">
            <button onClick={() => setShowAddSub(false)} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600 hover:bg-slate-200">إلغاء</button>
            <button onClick={() => addSub.mutate()} disabled={!selectedCatForSub || !newSubName.trim()} className="px-4 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#1e3a5f' }}>إضافة</button>
          </div>
        </div>
      </Modal>

      {/* Edit Category */}
      <Modal open={!!editCat} onClose={() => setEditCat(null)} title="تعديل الفئة">
        <div className="space-y-3">
          <input className="input" value={editCat?.name || ''} onChange={e => setEditCat((c: any) => ({ ...c, name: e.target.value }))} autoFocus />
          <div className="flex gap-3 justify-end">
            <button onClick={() => setEditCat(null)} className="btn-ghost">إلغاء</button>
            <button onClick={() => updateCatMut.mutate({ id: editCat.id, name: editCat.name })} disabled={updateCatMut.isPending} className="px-4 py-2 rounded-xl text-sm font-bold text-white" style={{ background: '#1e3a5f' }}>حفظ</button>
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

      {/* Edit Subcategory */}
      <Modal open={!!editSub} onClose={() => setEditSub(null)} title="تعديل التصنيف الفرعي">
        <div className="space-y-3">
          <input className="input" value={editSub?.name || ''} onChange={e => setEditSub((s: any) => ({ ...s, name: e.target.value }))} autoFocus />
          <div className="flex gap-3 justify-end">
            <button onClick={() => setEditSub(null)} className="btn-ghost">إلغاء</button>
            <button onClick={() => updateSubMut.mutate({ id: editSub.id, category_id: editSub.category_id, name: editSub.name })} disabled={updateSubMut.isPending} className="px-4 py-2 rounded-xl text-sm font-bold text-white" style={{ background: '#1e3a5f' }}>حفظ</button>
          </div>
        </div>
      </Modal>
    </div>
  )
}
