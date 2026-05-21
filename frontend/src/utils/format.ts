/** Format number with Arabic-Indic digits */
export const toArabicNum = (n: number | string, decimals = 0): string => {
  const num = Number(n)
  if (isNaN(num)) return '—'
  return num.toLocaleString('ar-EG', {
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals,
  })
}

/** Format currency in Egyptian Pounds with Arabic digits */
export const formatEGP = (n: number | string, decimals = 2): string => {
  const num = Number(n)
  if (isNaN(num)) return '—'
  return `${num.toLocaleString('ar-EG', { minimumFractionDigits: decimals, maximumFractionDigits: decimals })} ج.م`
}

/** Format date in Arabic */
export const formatDate = (v: string | Date): string => {
  try {
    return new Date(v).toLocaleDateString('ar-EG', { year: 'numeric', month: '2-digit', day: '2-digit' })
  } catch { return String(v) }
}

/** Format datetime in Arabic */
export const formatDateTime = (v: string | Date): string => {
  try {
    return new Date(v).toLocaleString('ar-EG', { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' })
  } catch { return String(v) }
}

/** Fix upload URLs to go through /api proxy */
export const fixUploadUrl = (url: string | null | undefined): string => {
  if (!url) return ''
  if (url.startsWith('/uploads/')) return '/api' + url
  return url
}

/** Build a full print URL — auth is via httpOnly cookie */
export const printUrl = (path: string, size?: string): string => {
  return `/api${path}${size ? `?paper_size=${size}` : ''}`
}

/** Open a print PDF in a new tab with popup blocker detection */
export const openPrint = (path: string, size?: string): void => {
  const url = printUrl(path, size)
  const win = window.open(url, '_blank')
  if (!win || win.closed || typeof win.closed === 'undefined') {
    import('react-hot-toast').then(m => m.default.error('الرجاء السماح للنوافذ المنبثقة لطباعة الفاتورة', { duration: 4000 }))
  }
}
