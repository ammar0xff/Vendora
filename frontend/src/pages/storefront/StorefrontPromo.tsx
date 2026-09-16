import { motion } from 'framer-motion'
import { Link } from 'react-router-dom'
import { ArrowLeft, Calculator, Percent } from 'lucide-react'

export default function StorefrontPromo() {
  return (
    <section className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8 py-6">
      <motion.div
        initial={{ opacity: 0, y: 16 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true }}
        transition={{ duration: 0.5 }}
        className="relative overflow-hidden rounded-3xl"
      >
        <div className="absolute inset-0" style={{ background: 'linear-gradient(120deg, var(--primary) 0%, var(--primary-strong) 55%, var(--primary-deep) 100%)' }} />
        <div className="absolute inset-0 opacity-[0.07] pointer-events-none" style={{ backgroundImage: 'radial-gradient(circle at 80% 20%, #fff 1px, transparent 1px)', backgroundSize: '22px 22px' }} />
        <div className="relative px-8 py-14 sm:px-12 sm:py-16 lg:px-16">
          <div className="flex items-center gap-2 text-sm font-bold uppercase tracking-wider mb-3" style={{ color: 'var(--accent)' }}>
            <Percent className="h-4 w-4" /> عروض الكميات
          </div>
          <h2 className="mt-2 text-3xl sm:text-4xl font-black tracking-tight text-white max-w-lg text-right">
            محتاج أسعار جملة؟
            <br />
            خلّي نظامك يشتغل ليك
          </h2>
          <p className="mt-4 text-white/75 max-w-md text-sm sm:text-base text-right leading-relaxed">
            الأسعار المعروضة هنا هي أسعارك الفعلية من ڤندورة. للتجار والمحلات — اطلب عرض سعر رسمي أو تواصل معنا
            لفتح حساب جملة بخصومات خاصة.
          </p>
          <div className="mt-7 flex flex-wrap gap-3">
            <Link
              to="/store/catalog"
              className="inline-flex items-center gap-2 px-7 py-3.5 rounded-xl font-bold transition-colors"
              style={{ background: 'var(--accent)', color: '#fff' }}
            >
              تصفح العروض <ArrowLeft className="h-4 w-4" />
            </Link>
            <Link
              to="/login"
              className="inline-flex items-center gap-2 border border-white/25 text-white px-7 py-3.5 rounded-xl font-bold hover:bg-white/10 transition-colors"
            >
              <Calculator className="h-4 w-4" /> أسعار الجملة المخصصة
            </Link>
          </div>
        </div>
      </motion.div>
    </section>
  )
}