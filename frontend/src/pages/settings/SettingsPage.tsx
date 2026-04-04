import { fixUploadUrl } from '../../utils/format'
import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { settingsApi, categoriesApi, subcategoriesApi, stockApi } from '../../api/endpoints'
import api from '../../api/client'
import { PageLoader } from '../../components/ui/Loaders'
import Modal from '../../components/ui/Modal'
import toast from 'react-hot-toast'
import { Save, Plus, Trash2, Tag, Layers, Warehouse, Wallet, Pencil } from 'lucide-react'

function WalletsTab() {
  const qc = useQueryClient()
  const { data: wallets, isLoading } = useQuery({ queryKey: ['wallets'], queryFn: () => api.get('/wallets').then(r => r.data) })
  const [showAdd, setShowAdd] = useState(false)
  const [form, setForm] = useState({ name: '', type: 'vodafone_cash', phone: '' })

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
              <button onClick={() => { if (confirm('حذف؟')) deleteMut.mutate(w.id) }} className="p-1.5 rounded-lg hover:bg-red-50 text-slate-300 hover:text-red-500"><Trash2 size={13} /></button>
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
    </div>
  )
}

export default function SettingsPage() {
  const [tab, setTab] = useState<'store' | 'categories' | 'options' | 'warehouses' | 'wallets'>('store')
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
  const deleteCat = useMutation({
    mutationFn: categoriesApi.delete,
    onSuccess: () => { toast.success('تم الحذف'); qc.invalidateQueries({ queryKey: ['categories'] }) },
  })
  const addSub = useMutation({
    mutationFn: () => subcategoriesApi.create(selectedCatForSub, newSubName),
    onSuccess: () => { toast.success('تمت الإضافة'); setShowAddSub(false); setNewSubName(''); qc.invalidateQueries({ queryKey: ['subcategories'] }) },
  })
  const deleteSub = useMutation({
    mutationFn: subcategoriesApi.delete,
    onSuccess: () => { toast.success('تم الحذف'); qc.invalidateQueries({ queryKey: ['subcategories'] }) },
  })
  const updateCatMut = useMutation({
    mutationFn: ({ id, name }: any) => categoriesApi.update(id, name),
    onSuccess: () => { toast.success('تم التعديل'); setEditCat(null); qc.invalidateQueries({ queryKey: ['categories'] }) },
  })
  const updateSubMut = useMutation({
    mutationFn: ({ id, category_id, name }: any) => subcategoriesApi.update(id, category_id, name),
    onSuccess: () => { toast.success('تم التعديل'); setEditSub(null); qc.invalidateQueries({ queryKey: ['subcategories'] }) },
  })

  if (isLoading) return <PageLoader />

  const sf = storeForm || settings || {}

  const tabs = [
    { id: 'store', label: 'إعدادات المتجر', icon: Save },
    { id: 'categories', label: 'الفئات والتصنيفات', icon: Tag },
    { id: 'options', label: 'خيارات المنتجات', icon: Layers },
    { id: 'warehouses', label: 'المخازن', icon: Warehouse },
    { id: 'wallets', label: 'وسائل الدفع', icon: Wallet },
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
              <label className="block text-sm font-medium text-slate-600 mb-2">أرقام التواصل (تظهر في الفواتير)</label>
              <div className="space-y-2">
                {(sf.contact_phones || [{ name: '', phone: '' }, { name: '', phone: '' }, { name: '', phone: '' }]).map((c: any, i: number) => (
                  <div key={i} className="flex gap-2">
                    <input className="input flex-1 text-sm" placeholder="الاسم" value={c.name || ''} onChange={e => {
                      const arr = [...(sf.contact_phones || [{},{},{}])]
                      arr[i] = { ...arr[i], name: e.target.value }
                      setStoreForm({ ...sf, contact_phones: arr })
                    }} />
                    <input className="input flex-1 text-sm" placeholder="رقم التليفون" value={c.phone || ''} onChange={e => {
                      const arr = [...(sf.contact_phones || [{},{},{}])]
                      arr[i] = { ...arr[i], phone: e.target.value }
                      setStoreForm({ ...sf, contact_phones: arr })
                    }} />
                  </div>
                ))}
              </div>
            </div>

            <button onClick={() => saveSettings.mutate(sf)} className="px-5 py-2.5 rounded-xl text-sm font-bold text-white w-full flex items-center justify-center gap-2" style={{ background: '#1e3a5f' }}>
              <Save size={16} /> حفظ الإعدادات
            </button>
          </div>
        </div>
      )}

      {/* Categories */}
      {tab === 'categories' && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="card">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-bold text-slate-700">الفئات الرئيسية ({categories?.length || 0})</h3>
              <button onClick={() => setShowAddCat(true)} className="btn-primary btn-sm"><Plus size={14} /> إضافة</button>
            </div>
            <div className="space-y-2 max-h-80 overflow-y-auto">
              {categories?.map((c: any) => (
                <div key={c.id} className="flex items-center justify-between p-3 rounded-xl bg-slate-50 hover:bg-slate-100 transition-colors">
                  <span className="font-medium text-sm text-slate-700">{c.name}</span>
                  <div className="flex gap-1"><button onClick={() => setEditCat(c)} className="text-slate-300 hover:text-blue-500 transition-colors"><Pencil size={14} /></button><button onClick={() => { if (confirm('حذف الفئة؟')) deleteCat.mutate(c.id) }} className="text-slate-300 hover:text-red-500 transition-colors"><Trash2 size={14} /></button></div>
                </div>
              ))}
            </div>
          </div>

          <div className="card">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-bold text-slate-700">التصنيفات الفرعية ({subcategories?.length || 0})</h3>
              <button onClick={() => setShowAddSub(true)} className="btn-primary btn-sm"><Plus size={14} /> إضافة</button>
            </div>
            <div className="space-y-2 max-h-80 overflow-y-auto">
              {subcategories?.map((s: any) => (
                <div key={s.id} className="flex items-center justify-between p-3 rounded-xl bg-slate-50 hover:bg-slate-100 transition-colors">
                  <span className="font-medium text-sm text-slate-700">{s.name}</span>
                  <div className="flex gap-1"><button onClick={() => setEditSub(s)} className="text-slate-300 hover:text-blue-500 transition-colors"><Pencil size={14} /></button><button onClick={() => { if (confirm('حذف التصنيف؟')) deleteSub.mutate(s.id) }} className="text-slate-300 hover:text-red-500 transition-colors"><Trash2 size={14} /></button></div>
                </div>
              ))}
            </div>
          </div>
        </div>
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
              <h3 className="font-bold text-slate-700 mb-3">{label} ({options[key]?.length || 0})</h3>
              <div className="flex flex-wrap gap-2 max-h-48 overflow-y-auto">
                {options[key]?.map((v: string) => (
                  <span key={v} className="badge-blue text-xs">{v}</span>
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
                      <button onClick={() => renameWh.mutate()} className="px-3 py-1 rounded-lg text-xs font-bold text-white bg-green-600">حفظ</button>
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
                  {w.code !== 'main' && (
                    <button onClick={() => { if (confirm('حذف؟')) deleteWh.mutate(w.id) }} className="p-1 rounded-lg hover:bg-red-50 text-slate-300 hover:text-red-500"><Trash2 size={13} /></button>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {tab === 'wallets' && <WalletsTab />}

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
            <input className="input" value={newWhCode} onChange={e => setNewWhCode(e.target.value)} placeholder={newWhType==='showroom' ? 'مثال: SH4' : 'مثال: WH6'} />
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
            <button onClick={() => addCat.mutate()} className="px-4 py-2 rounded-xl text-sm font-bold text-white" style={{ background: '#1e3a5f' }}>إضافة</button>
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
            <button onClick={() => addSub.mutate()} disabled={!selectedCatForSub} className="px-4 py-2 rounded-xl text-sm font-bold text-white" style={{ background: '#1e3a5f' }}>إضافة</button>
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
