export interface Plan {
  id: string;
  name: string;
  price_egp: number | null;
  popular?: boolean;
  tagline: string;
  features: string[];
}

/* Mirrors backend app/api/routers/platform.py PLANS */
export const PLANS: Plan[] = [
  {
    id: "basic", name: "أساسي", price_egp: 499,
    tagline: "ابدأ صح — فرع واحد جاهز للبيع",
    features: ["فرع واحد · 3 مستخدمين", "نقطة بيع + مخزون + مبيعات", "عملاء وموردون", "تقارير أساسية"],
  },
  {
    id: "pro", name: "احترافي", price_egp: 999, popular: true,
    tagline: "للمحلات اللي بتكبر — كل الميزات",
    features: ["حتى 3 فروع · 15 مستخدمًا", "كل ميزات أساسي", "مشتريات وذمم وخزائن", "تقارير متقدمة + تصدير"],
  },
  {
    id: "enterprise", name: "مؤسسي", price_egp: null,
    tagline: "سلاسل وفروع كثيرة",
    features: ["فروع ومستخدمون بلا حدود", "صلاحيات متقدمة", "أولوية دعم", "تهيئة وتدريب فريق العمل"],
  },
];

export const TRIAL_DAYS = 14;

export const SECTOR_OPTIONS = [
  { value: "plumbing", label: "أدوات صحية وسباكة" },
  { value: "electrical", label: "كهرباء وإضاءة" },
  { value: "tiles", label: "سيراميك وبورسلان" },
  { value: "paint", label: "دهانات وأصباغ" },
];

export const SCALE_OPTIONS = [
  { value: "small", label: "فرع واحد", desc: "محل واحد وفريق صغير" },
  { value: "medium", label: "٢–٣ فروع", desc: "أكثر من فرع ومخزن" },
  { value: "large", label: "٤ فروع وأكثر", desc: "سلسلة وفروع متعددة" },
];

export const PALETTE_OPTIONS = [
  { value: "water", hue: 250, label: "أزرق مائي", desc: "الافتراضي — يليق بالسباكة والتوريدات" },
  { value: "emerald", hue: 155, label: "أخضر زمردي", desc: "نمو ونقاء" },
  { value: "copper", hue: 55, label: "نحاسي", desc: "دفء وحرفة" },
  { value: "midnight", hue: 230, label: "أزرق ليلي", desc: "رصانة وفخامة" },
];

export const FEATURE_OPTIONS = [
  { value: "credit", label: "البيع الآجل", desc: "ذمم العملاء وحدود الائتمان" },
  { value: "quotations", label: "عروض الأسعار", desc: "تحويل عرض سعر لفاتورة بضغطة" },
  { value: "purchases", label: "المشتريات", desc: "أوامر شراء واستلام من الموردين" },
  { value: "hr", label: "الموارد البشرية", desc: "موظفين، حضور، ورواتب" },
];
