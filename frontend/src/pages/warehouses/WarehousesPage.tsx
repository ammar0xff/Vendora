import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { stockApi } from '../../api/endpoints'
import api from '../../api/client'
import { Plus, Trash2, Pencil } from 'lucide-react'
import Modal from '../../components/ui/Modal'
import ConfirmDialog from '../../components/ui/ConfirmDialog'
import { Button } from '../../components/ui/button'
import toast from 'react-hot-toast'
import { useAuthStore } from '../../store/auth'
import { Input } from '../../components/ui/input'
import { Badge } from '../../components/ui/badge'

export default function WarehousesPage() {
  const qc = useQueryClient()
  const { data: warehouses } = useQuery({ queryKey: ['warehouses'], queryFn: stockApi.warehouses })
  const [showAddWh, setShowAddWh] = useState(false)
  const [newWhCode, setNewWhCode] = useState('')
  const [newWhName, setNewWhName] = useState('')
  const [newWhType, setNewWhType] = useState('showroom')
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

  const currentUser = useAuthStore((s: any) => s.user)
  const hasPerm = (p: string) => currentUser?.permissions?.includes(p)

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">المخازن</h1>
      </div>

      <div className="card max-w-lg">
        <div className="flex items-center justify-between mb-4">
          <h3 className="font-bold text-slate-700">المخازن ({warehouses?.length || 0})</h3>
          <Button size="sm" onClick={() => setShowAddWh(true)}>
            <Plus size={13} /> إضافة مخزن
          </Button>
        </div>
        <div className="space-y-2">
          {warehouses?.map((w: any) => (
            <div key={w.id} className="flex items-center justify-between p-3 rounded-xl bg-slate-50 border border-slate-100">
              <div className="flex-1">
                <p className="font-semibold text-slate-800">{w.name}</p>
                <div className="flex gap-2 mt-0.5"><p className="text-xs text-slate-400 font-mono">{w.code}</p><Badge variant={w.warehouse_type === 'showroom' ? 'blue' : 'gray'} className="text-xs">{w.warehouse_type === 'showroom' ? 'معرض' : 'مخزن'}</Badge></div>
              </div>
              <div className="flex gap-1">
                <Button variant="ghost" size="icon" className="size-7" onClick={() => { setRenameWhId({ id: w.id, name: w.name }); setRenameWhName(w.name) }}>
                  <Pencil size={13} />
                </Button>
                {hasPerm('settings') && (
                  <Button
                    variant="ghost"
                    size="icon"
                    className="size-7 text-warning hover:text-warning"
                    onClick={() => setConfirmResetWh({ id: w.id, name: w.name })}
                    title="تصفير الجرد">
                    🗑️
                  </Button>
                )}
                {w.code !== 'main' && (
                  <Button variant="ghost" size="icon" className="size-7 text-destructive hover:text-destructive" onClick={() => setConfirmDelWh({ id: w.id })}>
                    <Trash2 size={13} />
                  </Button>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>

      <Modal open={showAddWh} onClose={() => setShowAddWh(false)} title="إضافة مخزن جديد">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">النوع</label>
            <div className="flex gap-2">
              {[{v:'showroom',l:'🏪 معرض'},{v:'warehouse',l:'🏭 مخزن'}].map(({v,l}) => (
                <Button key={v} variant={newWhType===v ? 'default' : 'outline'} className="flex-1" onClick={() => setNewWhType(v)}>
                  {l}
                </Button>
              ))}
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">الكود (بالإنجليزية)</label>
 <Input value={newWhCode} onChange={e => setNewWhCode(e.target.value.toUpperCase().replace(/[^A-Z0-9_-]/g, ''))} placeholder={newWhType==='showroom' ? 'مثال: SH4' : 'مثال: WH6'}/>
            {newWhCode && !/^[A-Z0-9_-]+$/.test(newWhCode) && <p className="text-xs text-red-500 mt-1">يُسمح فقط بأحرف إنجليزية وأرقام و _ و -</p>}
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-600 mb-1">الاسم</label>
 <Input value={newWhName} onChange={e => setNewWhName(e.target.value)} placeholder={newWhType==='showroom' ? 'مثال: المعرض الرابع' : 'مثال: المخزن السادس'}/>
          </div>
          <div className="flex gap-3 justify-end">
            <Button variant="ghost" onClick={() => setShowAddWh(false)}>إلغاء</Button>
            <Button onClick={() => addWh.mutate()} disabled={!newWhCode || !newWhName}>إضافة</Button>
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
 <Input value={renameWhName} onChange={e => setRenameWhName(e.target.value)}
            onKeyDown={e => { if (e.key === 'Enter' && renameWhName.trim()) renameWh.mutate() }}
            placeholder="اكتب الاسم..." autoFocus />
          <div className="flex gap-3 justify-end">
            <Button variant="outline" onClick={() => setRenameWhId(null)}>إلغاء</Button>
            <Button onClick={() => renameWh.mutate()} disabled={!renameWhName.trim() || renameWh.isPending}>
              {renameWh.isPending ? 'جاري...' : 'حفظ'}
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  )
}