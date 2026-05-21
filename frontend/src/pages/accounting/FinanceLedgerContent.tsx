import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import api from '../../api/client'
import { useAppStore } from '../../store/app'
import { PageLoader, EmptyState } from '../../components/ui/Loaders'
import Modal from '../../components/ui/Modal'
import ConfirmDialog from '../../components/ui/ConfirmDialog'
import toast from 'react-hot-toast'
import { format, startOfMonth } from 'date-fns'
import { Plus, Trash2, TrendingUp, TrendingDown, DollarSign, ChevronDown, ChevronLeft } from 'lucide-react'

export default function FinanceLedgerContent() {
  const [from, setFrom] = useState(format(startOfMonth(new Date()), 'yyyy-MM-dd'))
  const [to, setTo] = useState(format(new Date(), 'yyyy-MM-dd'))
  const [expandedCat, setExpandedCat] = useState<string | null>(null)
  const [showManageCats, setShowManageCats] = useState(false)
  const [newCatName, setNewCatName] = useState('')
  const [newCatType, setNewCatType] = useState('expense')
  const [newCatColor, setNewCatColor] = useState('#dc2626')
  const [confirmDelCat, setConfirmDelCat] = useState<string | null>(null)
  const { activeWarehouseId } = useAppStore()
  const isCompanyView = !activeWarehouseId
  const qc = useQueryClient()

  const { data: ledger, isLoading } = useQuery({
    queryKey: ['financial-ledger', from, to, activeWarehouseId],
    queryFn: () => api.get('/financial-ledger', {
      params: { from_date: from, to_date: to, ...(activeWarehouseId ? { warehouse_id: activeWarehouseId } : {}) }
    }).then(r => r.data),
  })

  const { data: categories } = useQuery({
    queryKey: ['financial-categories'],
    queryFn: () => api.get('/financial-categories').then(r => r.data),
  })

  const addCatMut = useMutation({
    mutationFn: () => api.post('/financial-categories', { name: newCatName, type: newCatType, color: newCatColor }),
    onSuccess: () => { toast.success('تمت الإضافة'); setNewCatName(''); qc.invalidateQueries({ queryKey: ['financial-categories'] }) },
  })
  const deleteCatMut = useMutation({
    mutationFn: (id: string) => api.delete(`/financial-categories/${id}`),
    onSuccess: () => { toast.success('تم الحذف'); qc.invalidateQueries({ queryKey: ['financial-categories'] }) },
  })

  const expenses = ledger?.categories?.filter((c: any) => c.type === 'expense') || []
  const incomes  = ledger?.categories?.filter((c: any) => c.type === 'income')  || []

  const txTypeLabel: Record<string, string> = { expense: 'خوارج', deposit: 'دواخل', withdrawal: 'سحب' }

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">الميزان المالي</h1>
          <p className="text-slate-500 text-sm mt-1">تتبع كل جنيه داخل وخارج الشركة بالتفصيل</p>
        </div>
        <button onClick={() => setShowManageCats(true)} className="px-4 py-2.5 rounded-xl text-sm font-bold text-white flex items-center gap-2" style={{ background: '#1e3a5f' }}>
          <Plus size={15} /> إدارة الفئات
        </button>
      </div>

      {/* Date filter */}
      <div className="flex gap-3 items-center mb-6 flex-wrap">
        <label className="text-sm text-slate-500">من</label>
        <input type="date" className="input w-40" value={from} onChange={e => setFrom(e.target.value)} />
        <label className="text-sm text-slate-500">إلى</label>
        <input type="date" className="input w-40" value={to} onChange={e => setTo(e.target.value)} />
      </div>

      {/* Company view notice */}
      {isCompanyView && (
        <div className="mb-4 p-3 bg-blue-50 border border-blue-200 rounded-xl text-sm text-blue-700 font-medium flex items-center gap-2">
          🏢 عرض إجمالي — كل الفروع مجمعة. اختر فرعاً من القائمة الجانبية لعرض فرع بعينه.
        </div>
      )}

      {/* Summary cards */}
      {ledger && (
        <div className="grid grid-cols-3 gap-4 mb-6">
          <div className="stat-card">
            <div className="stat-icon" style={{ background: '#fef2f2' }}><TrendingDown size={20} style={{ color: '#dc2626' }} /></div>
            <div><p className="text-slate-500 text-xs mb-1">إجمالي الخوارج</p><p className="text-xl font-black text-red-600">{Number(ledger.total_expense).toLocaleString('ar-EG')} ج.م</p></div>
          </div>
          <div className="stat-card">
            <div className="stat-icon" style={{ background: '#f0fdf4' }}><TrendingUp size={20} style={{ color: '#16a34a' }} /></div>
            <div><p className="text-slate-500 text-xs mb-1">إجمالي الدواخل</p><p className="text-xl font-black text-green-600">{Number(ledger.total_income).toLocaleString('ar-EG')} ج.م</p></div>
          </div>
          <div className="stat-card">
            <div className="stat-icon" style={{ background: Number(ledger.net) >= 0 ? '#f0fdf4' : '#fef2f2' }}><DollarSign size={20} style={{ color: Number(ledger.net) >= 0 ? '#16a34a' : '#dc2626' }} /></div>
            <div><p className="text-slate-500 text-xs mb-1">الصافي</p><p className={`text-xl font-black ${Number(ledger.net) >= 0 ? 'text-green-600' : 'text-red-600'}`}>{Number(ledger.net).toLocaleString('ar-EG')} ج.م</p></div>
          </div>
        </div>
      )}

      {isLoading ? <PageLoader /> : (
        <div className="grid grid-cols-1 xl:grid-cols-2 gap-6">
          {/* Expenses */}
          <div>
            <h3 className="font-bold text-red-700 mb-3 flex items-center gap-2"><TrendingDown size={16} /> الخوارج بالفئات</h3>
            <div className="space-y-2">
              {!expenses.length && <EmptyState message="لا توجد خوارج" icon="💸" />}
              {expenses.map((cat: any) => (
                <div key={cat.name} className="card p-0 overflow-hidden">
                  <button onClick={() => setExpandedCat(expandedCat === cat.name + 'e' ? null : cat.name + 'e')}
                    className="w-full flex items-center justify-between p-4 hover:bg-slate-50 transition-colors">
                    <div className="flex items-center gap-3">
                      <div className="w-3 h-3 rounded-full" style={{ background: cat.color }} />
                      <div className="text-right">
                        <p className="font-bold text-slate-800">{cat.name}</p>
                        <p className="text-xs text-slate-400">{cat.count} عملية</p>
                      </div>
                    </div>
                    <div className="flex items-center gap-3">
                      <span className="font-black text-red-600">{Number(cat.total).toLocaleString('ar-EG')} ج.م</span>
                      {expandedCat === cat.name + 'e' ? <ChevronDown size={16} className="text-slate-400" /> : <ChevronLeft size={16} className="text-slate-400" />}
                    </div>
                  </button>
                  {expandedCat === cat.name + 'e' && (
                    <div className="border-t border-slate-100">
                      {cat.entries.map((e: any) => (
                        <div key={e.id} className="flex items-center justify-between px-4 py-2.5 border-b border-slate-50 last:border-0 hover:bg-slate-50">
                          <div>
                            <p className="text-sm font-medium text-slate-700">{e.note || txTypeLabel[e.type] || e.type}</p>
                            <p className="text-xs text-slate-400">{isCompanyView && e.warehouse_name && <span className="inline-block bg-blue-50 text-blue-600 px-1.5 py-0.5 rounded text-xs font-medium ml-1">{e.warehouse_name}</span>}{new Date(e.created_at).toLocaleString('ar-EG')}</p>
                          </div>
                          <span className="font-bold text-red-600 text-sm">{Number(e.amount).toLocaleString('ar-EG')} ج.م</span>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              ))}
            </div>
          </div>

          {/* Income */}
          <div>
            <h3 className="font-bold text-green-700 mb-3 flex items-center gap-2"><TrendingUp size={16} /> الدواخل بالفئات</h3>
            <div className="space-y-2">
              {!incomes.length && <EmptyState message="لا توجد دواخل" icon="💰" />}
              {incomes.map((cat: any) => (
                <div key={cat.name} className="card p-0 overflow-hidden">
                  <button onClick={() => setExpandedCat(expandedCat === cat.name + 'i' ? null : cat.name + 'i')}
                    className="w-full flex items-center justify-between p-4 hover:bg-slate-50 transition-colors">
                    <div className="flex items-center gap-3">
                      <div className="w-3 h-3 rounded-full" style={{ background: cat.color }} />
                      <div className="text-right">
                        <p className="font-bold text-slate-800">{cat.name}</p>
                        <p className="text-xs text-slate-400">{cat.count} عملية</p>
                      </div>
                    </div>
                    <div className="flex items-center gap-3">
                      <span className="font-black text-green-600">{Number(cat.total).toLocaleString('ar-EG')} ج.م</span>
                      {expandedCat === cat.name + 'i' ? <ChevronDown size={16} className="text-slate-400" /> : <ChevronLeft size={16} className="text-slate-400" />}
                    </div>
                  </button>
                  {expandedCat === cat.name + 'i' && (
                    <div className="border-t border-slate-100">
                      {cat.entries.map((e: any) => (
                        <div key={e.id} className="flex items-center justify-between px-4 py-2.5 border-b border-slate-50 last:border-0 hover:bg-slate-50">
                          <div>
                            <p className="text-sm font-medium text-slate-700">{e.note || txTypeLabel[e.type] || e.type}</p>
                            <p className="text-xs text-slate-400">{isCompanyView && e.warehouse_name && <span className="inline-block bg-blue-50 text-blue-600 px-1.5 py-0.5 rounded text-xs font-medium ml-1">{e.warehouse_name}</span>}{new Date(e.created_at).toLocaleString('ar-EG')}</p>
                          </div>
                          <span className="font-bold text-green-600 text-sm">{Number(e.amount).toLocaleString('ar-EG')} ج.م</span>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Manage Categories Modal */}
      <Modal open={showManageCats} onClose={() => setShowManageCats(false)} title="إدارة الفئات المالية" size="lg">
        <div className="space-y-4">
          {/* Add new */}
          <div className="bg-slate-50 rounded-xl p-4 space-y-3">
            <p className="text-sm font-bold text-slate-600">إضافة فئة جديدة</p>
            <div className="grid grid-cols-3 gap-3">
              <input className="input col-span-1" placeholder="اسم الفئة" value={newCatName} onChange={e => setNewCatName(e.target.value)} />
              <select className="input" value={newCatType} onChange={e => setNewCatType(e.target.value)}>
                <option value="expense">خوارج</option>
                <option value="income">دواخل</option>
              </select>
              <div className="flex gap-2 items-center">
                <input type="color" value={newCatColor} onChange={e => setNewCatColor(e.target.value)} className="w-10 h-10 rounded-lg border border-slate-200 cursor-pointer" />
                <button onClick={() => addCatMut.mutate()} disabled={!newCatName} className="flex-1 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#1e3a5f' }}>إضافة</button>
              </div>
            </div>
          </div>
          {/* List */}
          <div className="space-y-2 max-h-64 overflow-y-auto">
            {categories?.map((c: any) => (
              <div key={c.id} className="flex items-center justify-between p-3 rounded-xl bg-slate-50">
                <div className="flex items-center gap-3">
                  <div className="w-4 h-4 rounded-full" style={{ background: c.color }} />
                  <div>
                    <p className="font-semibold text-sm text-slate-800">{c.name}</p>
                    <span className={c.type === 'expense' ? 'badge-red text-xs' : 'badge-green text-xs'}>{c.type === 'expense' ? 'خوارج' : 'دواخل'}</span>
                  </div>
                </div>
                <button onClick={() => setConfirmDelCat(c.id)} className="text-slate-300 hover:text-red-500 transition-colors"><Trash2 size={14} /></button>
              </div>
            ))}
          </div>
        </div>
      </Modal>
      <ConfirmDialog open={!!confirmDelCat} onClose={() => setConfirmDelCat(null)}
        onConfirm={() => { deleteCatMut.mutate(confirmDelCat); setConfirmDelCat(null) }}
        message="حذف الفئة؟" danger confirmText="حذف" />
    </div>
  )
}
