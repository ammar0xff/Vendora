import { useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { settingsApi } from '../../api/endpoints'
import api from '../../api/client'
import { PageLoader } from '../../components/ui/Loaders'
import toast from 'react-hot-toast'
import { Save, Trash2 } from 'lucide-react'
import { fixUploadUrl } from '../../utils/format'
import { Button } from '../../components/ui/button'
import { Input } from '../../components/ui/input'
import { Select } from '../../components/ui/select'

export default function GeneralSettingsPage() {
  const qc = useQueryClient()
  const { data: settings, isLoading } = useQuery({ queryKey: ['settings'], queryFn: settingsApi.get })
  const [storeForm, setStoreForm] = useState<any>(null)

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

  if (isLoading) return <PageLoader />

  const sf = storeForm || settings || {}

  return (
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
 <Input className="text-sm" value={sf.logo_url || ''} onChange={e => setStoreForm({ ...sf, logo_url: e.target.value })} placeholder="رابط الصورة (URL)"/>
              <div className="flex items-center gap-2">
                <label className="cursor-pointer px-3 py-1.5 rounded-lg text-xs font-semibold bg-slate-100 text-slate-600 hover:bg-slate-200">
                  📁 رفع صورة
                  <input type="file" accept="image/*" className="hidden" aria-label="رفع صورة الشعار" onChange={e => {
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
 <Input value={sf[key] || ''} onChange={e => setStoreForm({ ...sf, [key]: e.target.value })}/>
          </div>
        ))}

        {/* Paper size */}
        <div>
          <label className="block text-sm font-medium text-slate-600 mb-1">حجم ورق الطباعة والـ PDF</label>
          <Select value={sf.paper_size || 'A4'} onChange={e => setStoreForm({ ...sf, paper_size: e.target.value })}>
            <option value="A4">A4 (210 × 297 mm) — الأكثر شيوعاً</option>
            <option value="A5">A5 (148 × 210 mm) — فواتير صغيرة</option>
            <option value="Letter">Letter (216 × 279 mm) — أمريكي</option>
          </Select>
        </div>

        {/* Contact phones */}
        <div>
          <div className="flex items-center justify-between mb-2">
            <label className="block text-sm font-medium text-slate-600">أرقام التواصل (تظهر في الفواتير)</label>
            <Button variant="secondary" size="sm" onClick={() => {
              const arr = [...(sf.contact_phones || []), { name: '', phone: '' }]
              setStoreForm({ ...sf, contact_phones: arr })
            }} className="text-xs">+ إضافة رقم</Button>
          </div>
          <div className="space-y-2">
            {(sf.contact_phones || [{ name: '', phone: '' }]).map((c: any, i: number) => (
              <div key={i} className="flex gap-2">
 <Input className="flex-1 text-sm" placeholder="الاسم" value={c.name || ''} onChange={e => {
                  const arr = [...(sf.contact_phones || [])]
                  arr[i] = { ...arr[i], name: e.target.value }
                  setStoreForm({ ...sf, contact_phones: arr })
                }} />
 <Input className="flex-1 text-sm" placeholder="رقم التليفون" value={c.phone || ''} onChange={e => {
                  const arr = [...(sf.contact_phones || [])]
                  arr[i] = { ...arr[i], phone: e.target.value }
                  setStoreForm({ ...sf, contact_phones: arr })
                }} />
                <Button variant="ghost" size="icon-sm" onClick={() => {
                  const arr = sf.contact_phones?.filter((_: any, j: number) => j !== i) || []
                  setStoreForm({ ...sf, contact_phones: arr })
                }} className="text-slate-300 hover:text-red-500 hover:bg-red-50 flex-shrink-0"><Trash2 size={14} /></Button>
              </div>
            ))}
          </div>
        </div>

        <Button onClick={() => saveSettings.mutate(sf)} disabled={saveSettings.isPending} className="w-full flex items-center justify-center gap-2">
          <Save size={16} /> {saveSettings.isPending ? 'جاري...' : 'حفظ الإعدادات'}
        </Button>
      </div>
    </div>
  )
}