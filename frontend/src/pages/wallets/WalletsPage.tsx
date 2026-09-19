import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import api from '../../api/client'
import ConfirmDialog from '../../components/ui/ConfirmDialog'
import toast from 'react-hot-toast'
import { Plus, Trash2 } from 'lucide-react'

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
        <button onClick={() => setShowAdd(true)} className="px-3 py-1.5 rounded-lg text-xs font-bold text-white flex items-center gap-1" style={{ background: 'var(--primary)' }}>
          <Plus size={13} /> إضافة
        </button>
      </div>
      {isLoading ? (
        <div className="text-center py-8 text-slate-400 text-sm">جارٍ التحميل…</div>
      ) : (
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
      )}
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
            <button onClick={() => createMut.mutate()} disabled={!form.name || !form.phone} className="px-4 py-1.5 rounded-lg text-xs font-bold text-white disabled:opacity-50" style={{ background: 'var(--primary)' }}>إضافة</button>
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

export default function WalletsPage() {
  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">وسائل الدفع</h1>
      </div>
      <WalletsTab />
    </div>
  )
}