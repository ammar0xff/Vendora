import { Navigate, Outlet } from 'react-router-dom'
import { useAuthStore } from '../store/auth'
import Layout from '../components/layout/Layout'

export default function AdminLayout() {
  const token = useAuthStore(s => s.token)
  if (!token) return <Navigate to="/login" replace />
  return (
    <Layout>
      <Outlet />
    </Layout>
  )
}