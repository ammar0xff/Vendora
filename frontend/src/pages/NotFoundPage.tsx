import { Link } from 'react-router-dom'

export default function NotFoundPage() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center gap-5 text-center px-6 bg-[var(--bg)]" style={{ direction: 'rtl' }}>
      <div className="text-6xl font-black text-[var(--primary)]">404</div>
      <h1 className="text-2xl font-black text-[var(--text)]">الصفحة غير موجودة</h1>
      <p className="text-[var(--muted)] text-sm max-w-sm">عذراً، الصفحة التي تبحث عنها غير متاحة أو تم نقلها.</p>
      <Link to="/" className="btn btn-primary px-6 py-2.5 rounded-xl font-bold">
        العودة للرئيسية
      </Link>
    </div>
  )
}