import { type ReactNode } from 'react'
import { clsx } from 'clsx'

interface Props {
  label: string
  error?: string
  hint?: string
  required?: boolean
  children: ReactNode
  htmlFor?: string
  className?: string
}

/**
 * Wraps a form control with a visible label, error message, and optional hint.
 * Every form field should use this to be WCAG-compliant.
 *
 * Usage:
 *   <Field label="الاسم" htmlFor="name" required>
 *     <input id="name" className="input" />
 *   </Field>
 *
 *   <Field label="المبلغ" error={errors.amount}>
 *     <input type="number" className={clsx('input', errors.amount && 'input-error')} />
 *   </Field>
 */
export default function Field({ label, error, hint, required, children, htmlFor, className }: Props) {
  return (
    <div className={clsx('', className)}>
      <label htmlFor={htmlFor} className="field-label">
        {label}
        {required && <span className="text-[var(--danger)] mr-0.5">*</span>}
      </label>
      {children}
      {error && <p className="field-error">{error}</p>}
      {!error && hint && <p className="field-hint">{hint}</p>}
    </div>
  )
}