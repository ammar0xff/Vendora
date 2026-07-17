import Modal from '../../../components/ui/Modal'
import { customersApi } from '../../../api/endpoints'

interface Props {
  showPhoneModal: boolean
  onClose: () => void
  pendingCustomerName: string
  setPendingCustomerName: (v: string) => void
  newCustomerPhone: string
  setNewCustomerPhone: (v: string) => void
  setSelectedCustomer: (v: any) => void
  setCustomer: (v: string) => void
  setCustomerSearch: (v: string) => void
}

export function PhoneModal({ showPhoneModal, onClose, pendingCustomerName, setPendingCustomerName, newCustomerPhone, setNewCustomerPhone, setSelectedCustomer, setCustomer, setCustomerSearch }: Props) {
  return (
    <Modal open={showPhoneModal} onClose={onClose} title="بيانات العميل — آجل">
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
          <button onClick={onClose} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-600">إلغاء</button>
          <button
            disabled={!newCustomerPhone.trim() || !pendingCustomerName.trim()}
            onClick={async () => {
              const c = await customersApi.create({ name: pendingCustomerName, phone: newCustomerPhone })
              setSelectedCustomer(c)
              setCustomer(c.name)
              setCustomerSearch('')
              onClose()
              setPendingCustomerName('')
              setNewCustomerPhone('')
            }}
            className="px-5 py-2 rounded-xl text-sm font-bold text-white disabled:opacity-50" style={{ background: '#1e3a5f' }}>
            إضافة وتأكيد
          </button>
        </div>
      </div>
    </Modal>
  )
}
