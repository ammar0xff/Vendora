import { motion } from 'framer-motion'
import { Star } from 'lucide-react'

const testimonials = [
  {
    name: 'محمود عبد الله',
    role: 'تاجر — حلوان',
    quote: 'الأسعار هنا هي نفس أسعار جملتنا فعلًا، والباركود بيوفر وقت كتير. بطلب وأنا في المحل والطلب بيوصل قبل ما أقفل.',
    product: 'مواسير ووصلات',
    rating: 5,
  },
  {
    name: 'كريم السيد',
    role: 'محل سباكة — المنيب',
    quote: 'كنت بضيع وقت في المكالمات للتأكد من المتوفر. دلوقتي بشوف المخزون والصور قدامي وأطلب مباشرة.',
    product: 'خلاطات وأطقم',
    rating: 5,
  },
  {
    name: 'هبة مصطفى',
    role: 'مهندسة ديكور',
    quote: 'التصنيفات مريحه جدًا، بوصل للأصناف بتاعتي في ثواني وبعمل مقارنة سعرية قبل ما أموّن المشروع.',
    product: 'أدوات صحية',
    rating: 4,
  },
]

export default function StorefrontTestimonials() {
  return (
    <section style={{ background: 'var(--surface-2)' }}>
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8 py-16">
        <div className="text-center mb-10">
          <p className="text-sm font-bold uppercase tracking-wider" style={{ color: 'var(--accent)' }}>آراء عملائنا</p>
          <h2 className="text-2xl sm:text-3xl font-black tracking-tight mt-2 text-[var(--ink)]">ثقة التجار والمحلات</h2>
        </div>
        <div className="grid md:grid-cols-3 gap-6">
          {testimonials.map((t, i) => (
            <motion.div
              key={t.name}
              initial={{ opacity: 0, y: 16 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.4, delay: i * 0.08 }}
              className="bg-white rounded-2xl border p-6 shadow-sm"
              style={{ borderColor: 'var(--border)' }}
            >
              <div className="flex items-center gap-1 mb-4">
                {[...Array(5)].map((_, j) => (
                  <Star
                    key={j}
                    className={`h-4 w-4 ${j < t.rating ? 'fill-[var(--accent)] text-[var(--accent)]' : 'text-slate-200'}`}
                  />
                ))}
              </div>
              <p className="text-[var(--ink)] leading-relaxed text-right font-medium">&ldquo;{t.quote}&rdquo;</p>
              <div className="mt-5 flex items-center gap-3">
                <div className="h-10 w-10 rounded-full bg-[var(--primary-soft)] flex items-center justify-center text-sm font-bold text-[var(--primary)]">
                  {t.name.split(' ').map((n) => n[0]).join('')}
                </div>
                <div className="text-right">
                  <p className="text-sm font-bold text-[var(--ink)]">{t.name}</p>
                  <p className="text-xs text-[var(--muted)]">{t.role}</p>
                </div>
              </div>
              <p className="mt-3 text-xs text-[var(--muted)] italic">اشترى: {t.product}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}