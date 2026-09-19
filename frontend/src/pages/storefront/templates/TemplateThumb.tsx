import type { Tone } from './index'

/** Tiny CSS mock used as the template picker thumbnail (no images). */
export default function TemplateThumb({ tone }: { tone: Tone }) {
  const primary = tone === 'minimal' ? '#cbd5e1' : '#1e3a5f'
  const accent = '#c8a84b'
  const solid = tone !== 'minimal'
  return (
    <div className="w-full rounded-xl border border-slate-200 bg-white p-2" dir="ltr">
      <div className="rounded-lg overflow-hidden">
        {/* nav */}
        <div className="flex items-center gap-1 px-2 py-1.5" style={{ background: solid ? primary : '#f8fafc' }}>
          <span className="h-2 w-2 rounded bg-[var(--primary)]" />
          <span className="h-1 w-8 rounded" style={{ background: solid ? 'rgba(255,255,255,.85)' : '#94a3b8' }} />
          <span className="ml-auto h-2 w-2 rounded" style={{ background: accent }} />
        </div>
        {/* hero */}
        <div className="px-2 py-2.5" style={{ background: solid ? '#274d79' : '#ffffff' }}>
          <div className="space-y-1">
            <span className="block h-1.5 w-3/4 rounded" style={{ background: solid ? 'rgba(255,255,255,.85)' : '#94a3b8' }} />
            <span className={`block h-1.5 rounded ${tone === 'bold' ? 'w-3/4' : 'w-1/2'}`} style={{ background: tone === 'bold' ? '#fff' : solid ? 'rgba(255,255,255,.6)' : '#cbd5e1' }} />
            <span className="block h-1 w-1/3 rounded" style={{ background: solid ? 'rgba(255,255,255,.45)' : '#e2e8f0' }} />
          </div>
          <span className="mt-1.5 inline-block h-2 w-14 rounded" style={{ background: accent }} />
        </div>
        {/* section blocks */}
        <div className="flex gap-1 px-2 py-2">
          <span className="h-5 w-5 rounded" style={{ background: tone === 'minimal' ? '#eef2f7' : '#dbe4ee' }} />
          <span className="h-5 w-5 rounded" style={{ background: tone === 'minimal' ? '#eef2f7' : '#dbe4ee' }} />
          <span className="h-5 w-5 rounded" style={{ background: tone === 'minimal' ? '#eef2f7' : '#dbe4ee' }} />
          <span className="h-5 w-5 rounded" style={{ background: tone === 'minimal' ? '#eef2f7' : '#dbe4ee' }} />
        </div>
      </div>
    </div>
  )
}