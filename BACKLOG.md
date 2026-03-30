# BACKLOG — ما تبقى من الـ PRD

> آخر تحديث: 2026-03-30
> الـ PRD الأصلي: `/run/media/ammar/Data/New folder (2)/AMMAR/do not enter/EG-CO/PRD -EN -FINAL.md`

---

## 🔴 مش موجود خالص

### 1. Expenses Module (مصروفات الشركة)
- مصروفات متكررة (إيجار شهري، مرافق، إنترنت...)
- مصروفات لمرة واحدة مع إرفاق مستند
- مصروفات مخصصة لفرع معين
- **الرواتب تتسجل تلقائياً كمصروف** عند إغلاق الشهر

### 2. Cash Flow Statement
- تقرير تدفق نقدي رسمي (وارد / صادر / صافي)
- مقسم: مبيعات / مشتريات / رواتب / مصروفات / مرتجعات
- قابل للتصدير PDF

### 3. Split Payments في الـ POS
- دفع جزء نقدي + جزء كارت
- دفع جزء نقدي + جزء آجل

### 4. Offline-first POS
- الـ POS يشتغل بدون إنترنت ويتزامن لما يرجع
- يحتاج Service Worker + IndexedDB

### 5. Fingerprint / CSV Attendance Sync
- استيراد CSV من جهاز البصمة
- أو API مباشر من الجهاز على الـ LAN

---

## 🟡 موجود جزئياً — محتاج تحسين

### 6. Customer Credit Limits
- حد أقصى للمديونية لكل عميل
- منع البيع الآجل لو تجاوز الحد

### 7. Aging Reports (عمر الديون)
- تقرير يقسم المديونيات: 0-30 / 30-60 / 60-90 / +90 يوم
- للعملاء والموردين

### 8. Supplier Price Comparison
- مقارنة سعر نفس المنتج من موردين مختلفين
- تاريخ أسعار الشراء لكل مورد

### 9. Multiple Barcodes per Product
- كل منتج ممكن يكون له أكتر من باركود
- (مثلاً: باركود الكرتونة + باركود القطعة)

### 10. Hold / Resume Bills في الـ POS
- تعليق فاتورة والبدء في فاتورة جديدة
- الرجوع للفاتورة المعلقة

### 11. Audit Log شامل
- دلوقتي موجود للـ HR بس
- محتاج يشمل: المبيعات، المخزون، تغيير الأسعار، المرتجعات

### 12. Export Excel / PDF للجداول
- كل جدول في النظام يكون فيه زرار تصدير
- Excel للمحاسبة، PDF للإدارة

### 13. Payroll Approval Workflow
- الراتب يمر بـ: مسودة → مراجعة → اعتماد → صرف
- دلوقتي بيتحسب مباشرة بدون workflow

---

## ترتيب الأولوية المقترح

1. **Expenses Module** — أهم حاجة ناقصة للصورة المالية الكاملة
2. **Cash Flow Statement** — مطلوب للإدارة
3. **Aging Reports** — مطلوب للمحاسب
4. **Customer Credit Limits** — مطلوب للكاشير
5. **Split Payments** — مطلوب للـ POS
6. **Audit Log شامل** — compliance
7. **Export Excel/PDF** — UX
8. **Hold/Resume Bills** — UX
9. **Multiple Barcodes** — inventory
10. **Payroll Workflow** — HR
11. **Supplier Price Comparison** — purchasing
12. **CSV Attendance Sync** — HR
13. **Offline POS** — infrastructure (الأصعب)
