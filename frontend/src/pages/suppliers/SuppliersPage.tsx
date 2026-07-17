import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { suppliersApi } from '../../api/endpoints'
import DataTable from '../../components/ui/DataTable'
import Modal from '../../components/ui/Modal'
import toast from 'react-hot-toast'
import { Plus, Eye, Edit2, Trash2, TrendingUp, TrendingDown } from 'lucide-react'
import ExportButton from '../../components/ui/ExportButton'
import ConfirmDialog from '../../components/ui/ConfirmDialog'

function SupplierForm({ initial, onSave, onClose, saving }: any) {
  const [form, setForm] = useState(initial || { name: '', phone: '', address: '', type: 'supplier', notes: '' })
  const set = (k: string, v: any) => setForm((f: any) => ({ ...f, [k]: v }))
  return (
    <form onSubmit={e => { e.preventDefault(); onSave(form) }} className="space-y-4">
      <div className="grid grid-cols-2 gap-4">
        <div className="col-span-2"><label className="block text-sm font-medium text-slate-600 mb-1">الاسم *</label><input className="input" value={form.name} onChange={e => set('name', e.target.value)} required /></div>
        <div><label className="block text-sm font-medium text-slate-600 mb-1">الهاتف</label><input className="input" value={form.phone || ''} onChange={e => set('phone', e.target.value)} /></div>
  
        <div className="col-span-2"><label className="block text-sm font-medium text-slate-600 mb-1">العنوان</label><input className="input" value={form.address || ''} onChange={e => set('address', e.target.value)} /></div>
        <div className="col-span-2"><label className="block text-sm font-medium text-slate-600 mb-1">ملاحظات</label><textarea className="input" rows={2} value={form.notes || ''} onChange={e => set('notes', e.target.value)} /></div>
      </div>
      <div className="flex gap-3 justify-end">
        <button type="button" onClick={onClose} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
        <button type="submit" disabled={saving} className="px-5 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#1e3a5f' }}>{saving ? 'جاري الحفظ...' : 'حفظ'}</button>
      </div>
    </form>
  )
}

function TxForm({ supplierId, onClose }: any) {
  const [form, setForm] = useState({ amount: '', type: 'debit', reference_doc: '', notes: '' })
  const qc = useQueryClient()
  const mut = useMutation({
    mutationFn: () => suppliersApi.addTx(supplierId, { ...form, amount: Number(form.amount) }),
    onSuccess: () => { toast.success('تمت الإضافة'); qc.invalidateQueries({ queryKey: ['supplier-ledger', supplierId] }); qc.invalidateQueries({ queryKey: ['suppliers'] }); onClose() },
    onError: () => toast.error('فشل')
  })
  return (
    <form onSubmit={e => { e.preventDefault(); mut.mutate() }} className="space-y-4">
      <div className="grid grid-cols-2 gap-4">
        <div><label className="block text-sm font-medium text-slate-600 mb-1">النوع</label>
          <select className="input" value={form.type} onChange={e => setForm(f => ({ ...f, type: e.target.value }))}>
            <option value="debit">مديونية (علينا)</option>
            <option value="credit">دفعة / خصم</option>
          </select>
        </div>
        <div><label className="block text-sm font-medium text-slate-600 mb-1">المبلغ *</label>
          <input type="number" className="input" value={form.amount} onChange={e => setForm(f => ({ ...f, amount: e.target.value }))} required min="0.01" step="0.01" />
        </div>
        <div><label className="block text-sm font-medium text-slate-600 mb-1">رقم المستند</label><input className="input" value={form.reference_doc} onChange={e => setForm(f => ({ ...f, reference_doc: e.target.value }))} /></div>
        <div><label className="block text-sm font-medium text-slate-600 mb-1">ملاحظات</label><input className="input" value={form.notes} onChange={e => setForm(f => ({ ...f, notes: e.target.value }))} /></div>
      </div>
      <div className="flex gap-3 justify-end">
        <button type="button" onClick={onClose} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
        <button type="submit" disabled={mut.isPending} className="px-5 py-2 rounded-xl text-sm font-bold text-white" style={{ background: '#1e3a5f' }}>إضافة</button>
      </div>
    </form>
  )
}

function LedgerModal({ supplier, onClose }: any) {
  const [showTxForm, setShowTxForm] = useState(false)
  const { data, isLoading } = useQuery({ queryKey: ['supplier-ledger', supplier.id], queryFn: () => suppliersApi.ledger(supplier.id) })
  const balance = Number(data?.supplier?.balance || 0)

  return (
    <div>
      {/* Balance summary */}
      <div className={`rounded-xl p-4 mb-5 flex items-center justify-between ${balance > 0 ? 'bg-red-50 border border-red-200' : balance < 0 ? 'bg-green-50 border border-green-200' : 'bg-slate-50 border border-slate-200'}`}>
        <div>
          <p className="text-sm font-medium text-slate-600">الرصيد الحالي</p>
          <p className={`text-2xl font-black ${balance > 0 ? 'text-red-600' : balance < 0 ? 'text-green-600' : 'text-slate-600'}`}>
            {Math.abs(balance).toLocaleString('ar-EG')} ج.م
          </p>
          <p className="text-xs text-slate-500 mt-0.5">
            {balance > 0 ? '🔴 مديون لنا' : balance < 0 ? '🟢 نحن مدينون له' : '✅ متوازن'}
          </p>
        </div>
        <button onClick={() => setShowTxForm(true)} className="px-4 py-2 rounded-xl text-sm font-bold text-white flex items-center gap-2" style={{ background: '#1e3a5f' }}>
          <Plus size={14} /> حركة جديدة
        </button>
      </div>

      {showTxForm && <div className="mb-5 p-4 bg-slate-50 rounded-xl border"><TxForm supplierId={supplier.id} onClose={() => setShowTxForm(false)} /></div>}

      {/* Transactions */}
      <div className="space-y-2 max-h-80 overflow-y-auto">
        {isLoading && <p className="text-center text-slate-400 py-4">جاري التحميل...</p>}
        {!isLoading && !data?.transactions?.length && <p className="text-center text-slate-400 py-8">لا توجد حركات</p>}
        {data?.transactions?.map((tx: any) => (
          <div key={tx.id} className="flex items-center justify-between p-3 rounded-xl bg-white border border-slate-100">
            <div className="flex items-center gap-3">
              <div className={`w-8 h-8 rounded-lg flex items-center justify-center ${tx.type === 'debit' ? 'bg-red-100' : 'bg-green-100'}`}>
                {tx.type === 'debit' ? <TrendingUp size={14} className="text-red-600" /> : <TrendingDown size={14} className="text-green-600" />}
              </div>
              <div>
                <p className="text-sm font-semibold text-slate-700">{tx.type === 'debit' ? 'مديونية' : 'دفعة / خصم'}</p>
                {tx.reference_doc && <p className="text-xs text-slate-400">{tx.reference_doc}</p>}
                {tx.notes && <p className="text-xs text-slate-400">{tx.notes}</p>}
              </div>
            </div>
            <div className="text-right">
              <p className={`font-bold ${tx.type === 'debit' ? 'text-red-600' : 'text-green-600'}`}>
                {tx.type === 'debit' ? '+' : '-'}{Number(tx.amount).toLocaleString('ar-EG')} ج.م
              </p>
              <p className="text-xs text-slate-400">{new Date(tx.created_at).toLocaleDateString('ar-EG')}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

export default function SuppliersPage() {

  const [showAdd, setShowAdd] = useState(false)
  const [editItem, setEditItem] = useState<any>(null)
  const [ledgerItem, setLedgerItem] = useState<any>(null)
  const [search, setSearch] = useState('')
  const [confirmDelSupplier, setConfirmDelSupplier] = useState<any>(null)
  const qc = useQueryClient()

  const { data: suppliers, isLoading } = useQuery({ queryKey: ['suppliers'], queryFn: () => suppliersApi.list() })

  const createMut = useMutation({ mutationFn: suppliersApi.create, onSuccess: () => { toast.success('تمت الإضافة'); setShowAdd(false); qc.invalidateQueries({ queryKey: ['suppliers'] }) } })
  const updateMut = useMutation({ mutationFn: ({ id, d }: any) => suppliersApi.update(id, d), onSuccess: () => { toast.success('تم التحديث'); setEditItem(null); qc.invalidateQueries({ queryKey: ['suppliers'] }) } })
  const deleteMut = useMutation({ mutationFn: suppliersApi.delete, onSuccess: () => { toast.success('تم الحذف'); qc.invalidateQueries({ queryKey: ['suppliers'] }) } })

  const filtered = (suppliers || []).filter((s: any) => s.name.includes(search) || (s.phone || '').includes(search))

  const columns = [
    { key: 'name', label: 'الاسم', render: (r: any) => <span className="font-bold text-slate-800">{r.name}</span> },
    { key: 'phone', label: 'الهاتف', render: (r: any) => <span className="text-slate-500 text-sm">{r.phone || '—'}</span> },
    { key: 'address', label: 'العنوان', render: (r: any) => <span className="text-slate-500 text-sm truncate max-w-xs block">{r.address || '—'}</span> },
    {
      key: 'balance', label: 'الرصيد', render: (r: any) => {
        const b = Number(r.balance)
        return <span className={`font-bold ${b > 0 ? 'text-red-600' : b < 0 ? 'text-green-600' : 'text-slate-400'}`}>
          {b === 0 ? '—' : `${Math.abs(b).toLocaleString('ar-EG')} ج.م`}
          {b > 0 && <span className="text-xs mr-1 text-red-400">مديون</span>}
          {b < 0 && <span className="text-xs mr-1 text-green-400">دائن</span>}
        </span>
      }
    },
    {
      key: 'actions', label: '', render: (r: any) => (
        <div className="flex gap-1 justify-end">
          <button onClick={() => setLedgerItem(r)} className="p-1.5 rounded-lg hover:bg-blue-50 text-slate-400 hover:text-blue-600" title="كشف الحساب"><Eye size={14} /></button>
          <button onClick={() => setEditItem(r)} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400" title="تعديل"><Edit2 size={14} /></button>
          <button onClick={() => setConfirmDelSupplier(r.id)} className="p-1.5 rounded-lg hover:bg-red-50 text-slate-300 hover:text-red-500" title="حذف"><Trash2 size={14} /></button>
        </div>
      )
    },
  ]

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">🏭 الموردون والتجار</h1>
        <div className="flex items-center gap-3">
          <ExportButton data={filtered || []} columns={[
            { label: 'الاسم', accessor: (r: any) => r.name },
            { label: 'الهاتف', accessor: (r: any) => r.phone || '' },
            { label: 'الرصيد', accessor: (r: any) => Number(r.balance) },
          ]} filename="الموردون" excelEndpoint="/export/suppliers" />
          <button onClick={() => setShowAdd(true)} className="px-4 py-2.5 rounded-xl text-sm font-bold text-white flex items-center gap-2" style={{ background: '#1e3a5f' }}>
            <Plus size={15} /> إضافة
          </button>
        </div>
      </div>

      <div className="mb-4">
        <input className="input max-w-xs" placeholder="بحث بالاسم أو الهاتف..." value={search} onChange={e => setSearch(e.target.value)} />
      </div>

      <DataTable columns={columns} data={filtered} loading={isLoading} rowKey={(r: any) => r.id}
        emptyMessage="لا يوجد موردون" emptyIcon="🏭"
        emptyAction={{ label: 'إضافة مورد', onClick: () => setShowAdd(true) }} />

      <Modal open={showAdd} onClose={() => setShowAdd(false)} title="إضافة جديد">
        <SupplierForm saving={createMut.isPending} onSave={(d: any) => createMut.mutate(d)} onClose={() => setShowAdd(false)} />
      </Modal>
      <Modal open={!!editItem} onClose={() => setEditItem(null)} title="تعديل">
        {editItem && <SupplierForm saving={updateMut.isPending} initial={editItem} onSave={(d: any) => updateMut.mutate({ id: editItem.id, d })} onClose={() => setEditItem(null)} />}
      </Modal>
      <Modal open={!!ledgerItem} onClose={() => setLedgerItem(null)} title={`كشف حساب — ${ledgerItem?.name}`} size="lg">
        {ledgerItem && <LedgerModal supplier={ledgerItem} onClose={() => setLedgerItem(null)} />}
      </Modal>
      <ConfirmDialog open={!!confirmDelSupplier} onClose={() => setConfirmDelSupplier(null)} onConfirm={() => { deleteMut.mutate(confirmDelSupplier); setConfirmDelSupplier(null) }} message="حذف المورد؟" danger confirmText="حذف" />
    </div>
  )
}
