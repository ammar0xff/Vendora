import { Component } from 'react'

interface Props {
  children: React.ReactNode
  fallback?: React.ReactNode
}

interface State {
  hasError: boolean
  error: Error | null
}

export default class ErrorBoundary extends Component<Props, State> {
  state: State = { hasError: false, error: null }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, info: React.ErrorInfo) {
    console.warn('ErrorBoundary caught:', error.message, info.componentStack)
  }

  render() {
    if (this.state.hasError) {
      if (this.props.fallback) return this.props.fallback
      return (
        <div className="flex flex-col items-center justify-center h-[60vh] gap-4 text-center px-6">
          <div className="text-5xl">⚠️</div>
          <h2 className="text-xl font-black text-slate-800">حدث خطأ غير متوقع</h2>
          <p className="text-slate-500 text-sm max-w-md">
            {this.state.error?.message || 'حاول تحديث الصفحة أو العودة لاحقاً'}
          </p>
          <div className="flex gap-3">
            <button
              onClick={() => this.setState({ hasError: false, error: null })}
              className="px-6 py-3 rounded-xl font-bold text-white text-sm"
              style={{ background: '#1e3a5f' }}
            >
              إعادة المحاولة
            </button>
            <button
              onClick={() => window.location.reload()}
              className="px-6 py-3 rounded-xl font-bold text-slate-600 text-sm border border-slate-300"
            >
              تحديث الصفحة
            </button>
          </div>
        </div>
      )
    }
    return this.props.children
  }
}
