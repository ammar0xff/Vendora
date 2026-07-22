import { Download, FileSpreadsheet } from 'lucide-react'

interface ExportColumn {
  label: string
  accessor: (row: any) => string | number
}

function sanitizeCsvField(val: string): string {
  const str = String(val ?? '')
  if (str.includes(',') || str.includes('"') || str.includes('\n') || str.includes('\r')) {
    return `"${str.replace(/"/g, '""')}"`
  }
  return str
}

export default function ExportButton({ data, columns, filename = 'export', excelEndpoint }: {
  data: any[]
  columns: ExportColumn[]
  filename?: string
  excelEndpoint?: string
}) {
  const safeFilename = filename.replace(/[^a-zA-Z0-9_-\u0600-\u06FF]/g, '_')

  const handleCsv = () => {
    if (!data?.length) return
    const header = columns.map(c => sanitizeCsvField(c.label))
    const rows = data.map(row => columns.map(c => sanitizeCsvField(String(c.accessor(row) ?? ''))))
    const csv = [header, ...rows].map(r => r.join(',')).join('\n')
    const bom = '\uFEFF'
    const blob = new Blob([bom + csv], { type: 'text/csv;charset=utf-8;' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `${safeFilename}.csv`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
  }

  const handleExcel = async () => {
    if (!excelEndpoint) return
    try {
      const { default: api } = await import('../../api/client')
      const res = await api.get(`/api${excelEndpoint}`, { responseType: 'blob' })
      const blob = new Blob([res.data], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `${safeFilename}.xlsx`
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)
    } catch {
      const { default: toast } = await import('react-hot-toast')
      toast.error('فشل تحميل ملف Excel')
    }
  }

  return (
    <div className="flex gap-1">
      <button onClick={handleCsv} disabled={!data?.length}
        className="px-3 py-1.5 rounded-xl text-xs font-bold flex items-center gap-1.5 border border-slate-300 text-slate-600 hover:bg-slate-50 disabled:opacity-40 disabled:cursor-not-allowed transition-colors">
        <Download size={13} /> CSV
      </button>
      {excelEndpoint && (
        <button onClick={handleExcel}
          className="px-3 py-1.5 rounded-xl text-xs font-bold flex items-center gap-1.5 border border-green-300 text-green-700 hover:bg-green-50 transition-colors">
          <FileSpreadsheet size={13} /> Excel
        </button>
      )}
    </div>
  )
}