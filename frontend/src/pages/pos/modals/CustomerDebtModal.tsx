import Modal from '../../../components/ui/Modal'

interface Props {
  showCustomerDebt: boolean
  onClose: () => void
  debtCustomer: any
  setDebtCustomer: (v: any) => void
  debtCustomerSearch: string
  setDebtCustomerSearch: (v: string) => void
  debtCustomerResults: any
  debtCustomerAccount: any
  debtCustomerLedger: any
  debtPayAmount: string
  setDebtPayAmount: (v: string) => void
  debtPayNote: string
  setDebtPayNote: (v: string) => void
  debtPayMut: any
  setShowCustomerDebt: (v: boolean) => void
}

export function CustomerDebtModal({ showCustomerDebt, onClose, debtCustomer, setDebtCustomer, debtCustomerSearch, setDebtCustomerSearch, debtCustomerResults, debtCustomerAccount, debtCustomerLedger, debtPayAmount, setDebtPayAmount, debtPayNote, setDebtPayNote, debtPayMut, setShowCustomerDebt }: Props) {
  return (
    <Modal open={showCustomerDebt} onClose={onClose}
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
  )
}
