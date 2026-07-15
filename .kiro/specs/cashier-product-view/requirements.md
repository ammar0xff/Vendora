# Requirements Document

## Introduction

يضيف هذا المتطلب إلى واجهة كاشير نقطة البيع وضعَي عرض صريحَين للمنتجات:

1. **عرض الجدول** (الافتراضي): قائمة منبسطة بالمنتجات مع شريط جانبي للتصفية حسب الفئة.
2. **عرض الفئات/المجلدات**: تصفح تدريجي — الفئات الرئيسية كبطاقات مجلدات ← الضغط لعرض الفئات الفرعية ← الضغط لعرض المنتجات.

يتحكم في التبديل بين الوضعين زر مُسمَّى بوضوح. لا تغييرات في الواجهة الخلفية مطلوبة.

---

## Glossary

- **POSPage**: مكوّن React الرئيسي لصفحة الكاشير (`POSPage.tsx`)
- **ViewMode**: نوع TypeScript للوضع الحالي للعرض، قيمه `'table' | 'cards'`
- **ToggleButton**: زر التبديل بين عرض الجدول وعرض الفئات
- **CategoryCardBrowser**: مكوّن React المسؤول عن التصفح التدريجي (فئات ← فئات فرعية ← منتجات) (`CategoryCardBrowser.tsx`)
- **TableView**: وضع العرض الجدولي المنبسط للمنتجات مع الشريط الجانبي
- **CategorySidebar**: الشريط الجانبي لشجرة التصفية بالفئات (يظهر في وضع الجدول فقط، عند عرض ≥1024px)
- **BreadcrumbNav**: شريط التنقل التدريجي داخل `CategoryCardBrowser`
- **BackButton**: زر "رجوع" داخل `CategoryCardBrowser` للعودة للمستوى السابق

---

## Requirements

### Requirement 1: الوضع الافتراضي لعرض المنتجات

**User Story:** بصفتي كاشيراً، أريد أن يبدأ النظام بعرض الجدول عند فتح صفحة الكاشير، حتى أتمكن من البحث والتصفية المألوفَين فوراً دون أي خطوة إضافية.

#### Acceptance Criteria

1. THE POSPage SHALL initialize `viewMode` to `'table'` on first render before any user interaction.
2. WHEN POSPage mounts for the first time, THE TableView SHALL be visible and THE CategoryCardBrowser SHALL not be mounted in the DOM.
3. THE `viewMode` initial value `'table'` SHALL persist across page refreshes unless the user explicitly changes it.

---

### Requirement 2: زر التبديل بين وضعَي العرض

**User Story:** بصفتي كاشيراً، أريد زراً واضح التسمية يشرح لي ما سأنتقل إليه عند الضغط عليه، حتى لا أتردد في استخدامه.

#### Acceptance Criteria

1. WHEN `viewMode` equals `'table'`, THE ToggleButton SHALL display the label "عرض الفئات" accompanied by a `LayoutGrid` icon (size 14px).
2. WHEN `viewMode` equals `'cards'`, THE ToggleButton SHALL display the label "عرض الجدول" accompanied by a `List` icon (size 14px).
3. WHEN the ToggleButton is clicked and `viewMode` equals `'table'`, THE POSPage SHALL set `viewMode` to `'cards'`.
4. WHEN the ToggleButton is clicked and `viewMode` equals `'cards'`, THE POSPage SHALL set `viewMode` to `'table'`.
5. THE ToggleButton SHALL be visible and interactable in both the desktop layout (≥1024px) and the mobile layout (<1024px) of POSPage.
6. WHEN ToggleButton is clicked twice starting from any `viewMode` value, THE POSPage SHALL return `viewMode` to its original value (involution property).

---

### Requirement 3: عرض الجدول (Table View)

**User Story:** بصفتي كاشيراً، أريد رؤية قائمة منبسطة بجميع المنتجات مع شريط جانبي للتصفية، حتى أتمكن من إيجاد المنتج بسرعة عبر الكتابة أو اختيار الفئة.

#### Acceptance Criteria

1. WHILE `viewMode` equals `'table'`, THE TableView SHALL be rendered showing a flat list of products in tabular format with columns for product name, company, shelf number, retail price, wholesale price, and stock quantity.
2. WHILE `viewMode` equals `'table'` AND the viewport width is ≥1024px, THE CategorySidebar SHALL be visible for filtering products by category and subcategory.
3. WHILE `viewMode` equals `'cards'`, THE CategorySidebar SHALL not be rendered in the DOM.
4. WHEN the user types in the search field while `viewMode` equals `'table'`, THE TableView SHALL filter displayed products to those whose name contains the search string (case-insensitive).
5. WHEN the user selects a category in the CategorySidebar, THE TableView SHALL display only products belonging to that category or its subcategories.

---

### Requirement 4: عرض الفئات — المستوى الأول (الفئات الرئيسية)

**User Story:** بصفتي كاشيراً، أريد رؤية الفئات الرئيسية كبطاقات مجلدات عند تفعيل عرض الفئات، حتى أتصفح المنتجات بشكل بصري ومنظم.

#### Acceptance Criteria

1. WHEN `viewMode` changes to `'cards'` and no category is selected, THE CategoryCardBrowser SHALL render all top-level categories as folder cards in a responsive grid layout.
2. WHEN `viewMode` changes to `'cards'`, THE CategoryCardBrowser SHALL fetch categories from the `/categories` API endpoint using React Query with caching.
3. WHEN the `/categories` fetch is in progress, THE CategoryCardBrowser SHALL render an empty grid (no cards) without crashing.
4. WHEN `viewMode` changes to `'cards'` and the `/categories` response returns N categories, THE CategoryCardBrowser SHALL render exactly N folder cards at the root level.
5. WHEN `viewMode` changes to `'cards'` and the `/categories` response returns an empty array, THE CategoryCardBrowser SHALL render an empty grid with no folder cards.

---

### Requirement 5: التصفح التدريجي — المستوى الثاني (الفئات الفرعية)

**User Story:** بصفتي كاشيراً، أريد عند الضغط على فئة رئيسية أن تظهر لي الفئات الفرعية الخاصة بها، حتى أضيق نطاق البحث تدريجياً.

#### Acceptance Criteria

1. WHEN a category folder card is clicked and that category has at least one subcategory, THE CategoryCardBrowser SHALL display only the subcategory folder cards whose `category_id` matches the clicked category's `id`.
2. WHEN a category folder card is clicked and that category has at least one subcategory, THE CategoryCardBrowser SHALL display a BreadcrumbNav showing the selected category name and a BackButton labeled "رجوع".
3. WHEN the BackButton is clicked while viewing subcategories, THE CategoryCardBrowser SHALL return to the top-level category grid (clearing `selectedCatId`).
4. WHEN a category folder card is clicked and that category has zero subcategories, THE CategoryCardBrowser SHALL skip the subcategory level and display product cards for that category directly.
5. WHEN a category has zero subcategories and its folder card is clicked, THE CategoryCardBrowser SHALL set `selectedSubId` to `'__all__'` to trigger the product-level query.

---

### Requirement 6: التصفح التدريجي — المستوى الثالث (المنتجات)

**User Story:** بصفتي كاشيراً، أريد عند الضغط على فئة فرعية أن تظهر لي بطاقات المنتجات الخاصة بها، حتى أضيف المنتج المطلوب إلى السلة بنقرة واحدة.

#### Acceptance Criteria

1. WHEN a subcategory folder card is clicked, THE CategoryCardBrowser SHALL fetch products from `/products` with `subcategory_id` equal to the clicked subcategory's `id` and display them as product cards.
2. WHEN displaying product cards, THE CategoryCardBrowser SHALL show each product's name, price (determined by `mode` prop), and a stock status indicator with three distinct visual states: green badge for `qty > 5`, amber badge for `1 ≤ qty ≤ 5`, red badge for `qty = 0` (only when `stock_status = 'tracked'`); no badge for `stock_status = 'untracked'`.
3. WHEN displaying product cards, THE CategoryCardBrowser SHALL show a BreadcrumbNav with the format "category name / subcategory name" and a BackButton labeled "رجوع".
4. WHEN a product card is clicked, THE CategoryCardBrowser SHALL invoke the `onAddProduct` callback with the exact product object that was clicked.
5. IF a subcategory has zero products with `qty > 0` (after stock filtering), THEN THE CategoryCardBrowser SHALL display the text "لا توجد منتجات" instead of a product grid.
6. IF the `/products` API call fails, THEN THE CategoryCardBrowser SHALL render an empty product area with no crash and React Query SHALL retry automatically.

---

### Requirement 7: التنقل بزر الرجوع

**User Story:** بصفتي كاشيراً، أريد زر رجوع يعيدني للمستوى السابق داخل عرض الفئات، حتى أصحح مساري دون الحاجة لإعادة تشغيل الوضع.

#### Acceptance Criteria

1. WHEN the BackButton is pressed and `selectedSubId` is non-null, THE CategoryCardBrowser SHALL set `selectedSubId` to `null` and display the subcategory folder cards for `selectedCatId`, leaving `selectedCatId` unchanged.
2. WHEN the BackButton is pressed and `selectedCatId` is non-null and `selectedSubId` is null, THE CategoryCardBrowser SHALL set `selectedCatId` to `null` and display the top-level category folder cards.
3. WHILE `selectedCatId` is null and `selectedSubId` is null (top-level category grid), THE CategoryCardBrowser SHALL not render a BackButton.

---

### Requirement 8: إضافة المنتج إلى السلة من كلا الوضعَين

**User Story:** بصفتي كاشيراً، أريد أن تعمل إضافة المنتجات إلى السلة بنفس الطريقة سواء كنت في عرض الجدول أو عرض الفئات، حتى لا أضطر لتغيير عاداتي عند استخدام الوضعين.

#### Acceptance Criteria

1. WHEN a product row is clicked in the TableView, THE POSPage SHALL invoke `handleAddProduct` with that product object.
2. THE CategoryCardBrowser component SHALL declare `onAddProduct: (product: any) => void` as a required prop, and SHALL invoke it with the clicked product object when a product card is clicked.
3. WHEN `handleAddProduct` is invoked from either the TableView or the CategoryCardBrowser, THE cart state (Zustand `usePOSStore`) SHALL be updated identically regardless of which view triggered the call.

---

### Requirement 9: عرض السعر الصحيح حسب وضع البيع

**User Story:** بصفتي كاشيراً، أريد أن يعرض النظام السعر المناسب (جملة أو تجزئة) في كلا الوضعَين، حتى لا أخطئ في تسعير المنتج.

#### Acceptance Criteria

1. WHILE the sale `mode` is `'retail'`, THE CategoryCardBrowser SHALL display `product.retail_price` for each product card.
2. WHILE the sale `mode` is `'wholesale'`, THE CategoryCardBrowser SHALL display `product.wholesale_price` for each product card; IF `product.wholesale_price` is null or zero, THE CategoryCardBrowser SHALL fall back to `product.retail_price`.
3. THE CategoryCardBrowser component SHALL declare `mode: 'retail' | 'wholesale'` as a required prop; THE component SHALL not render product prices unless this prop is provided with a valid value.

---

### Requirement 10: تصفية المنتجات حسب المخزون

**User Story:** بصفتي كاشيراً، أريد أن لا تظهر لي المنتجات النافدة التي لا يمكن بيعها، حتى لا أضيف منتجاً غير متاح للسلة بالخطأ.

#### Acceptance Criteria

1. WHILE displaying products in the CategoryCardBrowser, THE CategoryCardBrowser SHALL not render product cards whose `stock_status` equals `'tracked'` and whose `quantity_on_hand` (from the stock bulk API) is less than or equal to zero.
2. WHILE displaying products in the CategoryCardBrowser, THE CategoryCardBrowser SHALL render product cards whose `stock_status` equals `'untracked'` regardless of any quantity value, showing no stock badge.
3. WHILE displaying products in the TableView, THE TableView SHALL apply the identical filter: hide rows where `stock_status === 'tracked'` AND `quantity_on_hand <= 0`, and show all rows where `stock_status === 'untracked'`.

---

### Requirement 11: معالجة أخطاء جلب البيانات

**User Story:** بصفتي كاشيراً، أريد أن لا يتعطل النظام عند فشل جلب الفئات أو المنتجات، حتى أتمكن من الاستمرار في العمل أو المحاولة مجدداً.

#### Acceptance Criteria

1. IF the API call to `/categories` or `/subcategories` fails, THEN THE CategoryCardBrowser SHALL render an empty grid (no cards visible, no JavaScript exception thrown) and THE rest of the POSPage SHALL remain functional.
2. IF the API call to `/products` fails after a subcategory is selected, THEN THE CategoryCardBrowser SHALL render an empty product area with an error indicator (no product cards, no crash) and THE BackButton SHALL remain available so the user can navigate back.
3. WHEN a previously failed API call is retried by React Query and succeeds, THE CategoryCardBrowser SHALL automatically re-render with the correct data without requiring a page reload.
