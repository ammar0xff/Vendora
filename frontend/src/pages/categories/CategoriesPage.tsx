import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { categoriesApi, subcategoriesApi } from '../../api/endpoints'
import ConfirmDialog from '../../components/ui/ConfirmDialog'
import Modal from '../../components/ui/Modal'
import { Button } from '../../components/ui/button'
import toast from 'react-hot-toast'
import { Plus, Trash2, Tag, Pencil } from 'lucide-react'
import { Input } from '../../components/ui/input'

function CategoriesTree({ categories, subcategories }: { categories: any[], subcategories: any[] }) {
  const qc = useQueryClient()
  const [confirmDelCat, setConfirmDelCat] = useState<{ id: string; name: string; subsCount: number } | null>(null)
  const [confirmDelSub, setConfirmDelSub] = useState<{ id: string; name: string } | null>(null)
  const [newSubCatId, setNewSubCatId] = useState<string | null>(null)
  const [newSubName, setNewSubName] = useState('')
  const [newSubCode, setNewSubCode] = useState('')
  const [showNewCat, setShowNewCat] = useState(false)
  const [newCatName, setNewCatName] = useState('')
  const [newCatCode, setNewCatCode] = useState('')
  const [editCatId, setEditCatId] = useState<{ id: string; name: string; code: string } | null>(null)
  const [editCatName, setEditCatName] = useState('')
  const [editCatCode, setEditCatCode] = useState('')
  const [editSubId, setEditSubId] = useState<{ id: string; catId: string; name: string; code: string } | null>(null)
  const [editSubName, setEditSubName] = useState('')
  const [editSubCode, setEditSubCode] = useState('')

  const getSubs = (catId: string) => subcategories.filter((s: any) => s.category_id === catId)

  const addCatMut = useMutation({
    mutationFn: () => categoriesApi.create(newCatName, newCatCode),
    onSuccess: () => { toast.success('تمت الإضافة'); setShowNewCat(false); setNewCatName(''); setNewCatCode(''); qc.invalidateQueries({ queryKey: ['categories'] }) },
    onError: () => toast.error('فشل الحفظ'),
  })

  const editCatMut = useMutation({
    mutationFn: () => categoriesApi.update(editCatId!.id, editCatName, editCatCode),
    onSuccess: () => { toast.success('تم التعديل'); setEditCatId(null); qc.invalidateQueries({ queryKey: ['categories'] }) },
    onError: () => toast.error('فشل الحفظ'),
  })

  const editSubMut = useMutation({
    mutationFn: () => subcategoriesApi.update(editSubId!.id, editSubId!.catId, editSubName, editSubCode),
    onSuccess: () => { toast.success('تم التعديل'); setEditSubId(null); qc.invalidateQueries({ queryKey: ['subcategories'] }) },
    onError: () => toast.error('فشل الحفظ'),
  })

  const addSubMut = useMutation({
    mutationFn: () => subcategoriesApi.create(newSubCatId!, newSubName, newSubCode),
    onSuccess: () => { toast.success('تمت الإضافة'); setNewSubCatId(null); setNewSubName(''); setNewSubCode(''); qc.invalidateQueries({ queryKey: ['subcategories'] }) },
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

  return (
    <>
      <div className="card w-full">
        <div className="flex items-center justify-between mb-4">
          <div>
            <p className="font-bold text-[var(--text)]">{categories.length} فئة · {subcategories.length} تصنيف فرعي</p>
            <p className="text-xs text-[var(--muted)] mt-0.5">إدارة الفئات الرئيسية والتصنيفات الفرعية للأصناف</p>
          </div>
          <Button onClick={() => { setShowNewCat(true); setNewCatName('') }}>
            <Plus size={15} /> فئة جديدة
          </Button>
        </div>

        {!categories.length && (
          <div className="text-center py-10 text-[var(--muted)]">
            <Tag size={28} className="mx-auto mb-2 opacity-30" />
            <p className="text-sm">لا توجد فئات — اضغط "فئة جديدة" للبدء</p>
          </div>
        )}

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
          {categories.map((cat: any) => {
            const subs = getSubs(cat.id)

            return (
              <div key={cat.id} className="rounded-2xl border border-[var(--border)] bg-[var(--surface)] p-4">
                <div className="flex items-center justify-between gap-3">
                  <div className="flex items-center gap-3">
                    <div className="w-9 h-9 rounded-xl flex items-center justify-center text-white bg-primary">
                      <Tag size={15} />
                    </div>
                    <div>
                      <p className="font-semibold text-sm text-[var(--text)] leading-tight">
                        {cat.code ? <span className="text-xs font-mono font-bold text-[var(--muted)] ml-1.5" dir="ltr">{cat.code}</span> : null}{cat.name}
                      </p>
                      <p className="text-xs text-[var(--muted)]">{subs.length} تصنيف فرعي</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-1">
                    <Button variant="ghost" size="icon" onClick={() => { setEditCatId({ id: cat.id, name: cat.name, code: cat.code || '' }); setEditCatName(cat.name); setEditCatCode(cat.code || '') }} title="تعديل">
                      <Pencil size={14} />
                    </Button>
                    <Button variant="ghost" size="icon" className="text-destructive hover:text-destructive" onClick={() => setConfirmDelCat({ id: cat.id, name: cat.name, subsCount: subs.length })} title="حذف" data-testid="delete-category">
                      <Trash2 size={14} />
                    </Button>
                  </div>
                </div>

                {subs.length > 0 && (
                  <div className="mt-3 flex flex-wrap gap-2">
                    {subs.map((sub: any) => (
                      <span key={sub.id} className="inline-flex items-center gap-2 px-3 py-1.5 rounded-xl bg-[var(--surface-2)] border border-[var(--border)] text-xs text-[var(--text)]">
                        {sub.code ? <span className="text-[10px] font-mono font-bold text-[var(--muted)]" dir="ltr">{sub.code}</span> : null}
                        <span className="font-medium">{sub.name}</span>
                        <Button variant="ghost" size="icon" className="size-5 h-5" onClick={() => { setEditSubId({ id: sub.id, catId: sub.category_id, name: sub.name, code: sub.code || '' }); setEditSubName(sub.name); setEditSubCode(sub.code || '') }}>
                          <Pencil size={12} />
                        </Button>
                        <Button variant="ghost" size="icon" className="size-5 h-5 text-destructive hover:text-destructive" onClick={() => setConfirmDelSub({ id: sub.id, name: sub.name })} data-testid="delete-subcategory" title="حذف التصنيف">
                          <Trash2 size={12} />
                        </Button>
                      </span>
                    ))}
                  </div>
                )}

                <Button variant="outline" className="mt-3 w-full border-dashed" onClick={() => { setNewSubCatId(cat.id); setNewSubName(''); setNewSubCode('') }}>
                  إضافة تصنيف فرعي
                </Button>
              </div>
            )
          })}
        </div>
      </div>

      {/* New Category Modal */}
      <Modal open={showNewCat} onClose={() => setShowNewCat(false)} title="إضافة فئة جديدة">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">اسم الفئة</label>
 <Input value={newCatName} onChange={e => setNewCatName(e.target.value)}
              onKeyDown={e => { if (e.key === 'Enter' && newCatName.trim()) addCatMut.mutate() }}
              placeholder="اكتب اسم الفئة..." autoFocus />
          </div>
          <div>
            <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الكود (اختياري — للترتيب والتمييز)</label>
 <Input className="font-mono" dir="ltr" value={newCatCode} onChange={e => setNewCatCode(e.target.value)}
              placeholder="مثال: CAT-01" />
          </div>
          <div className="flex gap-3 justify-end">
            <Button variant="outline" onClick={() => setShowNewCat(false)}>إلغاء</Button>
            <Button onClick={() => addCatMut.mutate()} disabled={!newCatName.trim() || addCatMut.isPending}>
              {addCatMut.isPending ? 'جاري...' : 'إضافة'}
            </Button>
          </div>
        </div>
      </Modal>

      {/* Edit Category Modal */}
      <Modal open={!!editCatId} onClose={() => setEditCatId(null)} title="تعديل الفئة">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">اسم الفئة</label>
 <Input value={editCatName} onChange={e => setEditCatName(e.target.value)}
              onKeyDown={e => { if (e.key === 'Enter' && editCatName.trim()) editCatMut.mutate() }}
              placeholder="اكتب الاسم..." autoFocus />
          </div>
          <div>
            <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الكود (اختياري — للترتيب والتمييز)</label>
 <Input className="font-mono" dir="ltr" value={editCatCode} onChange={e => setEditCatCode(e.target.value)}
              placeholder="مثال: CAT-01" />
          </div>
          <div className="flex gap-3 justify-end">
            <Button variant="outline" onClick={() => setEditCatId(null)}>إلغاء</Button>
            <Button onClick={() => editCatMut.mutate()} disabled={!editCatName.trim() || editCatMut.isPending}>
              {editCatMut.isPending ? 'جاري...' : 'حفظ'}
            </Button>
          </div>
        </div>
      </Modal>

      {/* Edit Subcategory Modal */}
      <Modal open={!!editSubId} onClose={() => setEditSubId(null)} title="تعديل التصنيف الفرعي">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">اسم التصنيف الفرعي</label>
 <Input value={editSubName} onChange={e => setEditSubName(e.target.value)}
              onKeyDown={e => { if (e.key === 'Enter' && editSubName.trim()) editSubMut.mutate() }}
              placeholder="اكتب الاسم..." autoFocus />
          </div>
          <div>
            <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الكود (اختياري — للترتيب والتمييز)</label>
 <Input className="font-mono" dir="ltr" value={editSubCode} onChange={e => setEditSubCode(e.target.value)}
              placeholder="مثال: SUB-05" />
          </div>
          <div className="flex gap-3 justify-end">
            <Button variant="outline" onClick={() => setEditSubId(null)}>إلغاء</Button>
            <Button onClick={() => editSubMut.mutate()} disabled={!editSubName.trim() || editSubMut.isPending}>
              {editSubMut.isPending ? 'جاري...' : 'حفظ'}
            </Button>
          </div>
        </div>
      </Modal>

      {/* New Subcategory Modal */}
      <Modal open={!!newSubCatId} onClose={() => setNewSubCatId(null)} title="إضافة تصنيف فرعي">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الفئة الرئيسية</label>
            <p className="text-sm font-semibold text-[var(--text)]">{categories.find((c: any) => c.id === newSubCatId)?.name}</p>
          </div>
          <div>
            <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">اسم التصنيف الفرعي</label>
 <Input value={newSubName} onChange={e => setNewSubName(e.target.value)}
              onKeyDown={e => { if (e.key === 'Enter' && newSubName.trim()) addSubMut.mutate() }}
              placeholder="اكتب الاسم..." autoFocus />
          </div>
          <div>
            <label className="block text-sm font-medium text-[var(--text-soft)] mb-1">الكود (اختياري — للترتيب والتمييز)</label>
 <Input className="font-mono" dir="ltr" value={newSubCode} onChange={e => setNewSubCode(e.target.value)}
              placeholder="مثال: SUB-05" />
          </div>
          <div className="flex gap-3 justify-end">
            <Button variant="outline" onClick={() => setNewSubCatId(null)}>إلغاء</Button>
            <Button onClick={() => addSubMut.mutate()} disabled={!newSubName.trim() || addSubMut.isPending}>
              {addSubMut.isPending ? 'جاري...' : 'إضافة'}
            </Button>
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

export default function CategoriesPage() {
  const { data: categories } = useQuery({ queryKey: ['categories'], queryFn: categoriesApi.list })
  const { data: subcategories } = useQuery({ queryKey: ['subcategories'], queryFn: () => subcategoriesApi.list() })

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">الفئات والتصنيفات</h1>
      </div>
      <CategoriesTree categories={categories || []} subcategories={subcategories || []} />
    </div>
  )
}