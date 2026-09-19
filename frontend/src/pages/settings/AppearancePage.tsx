import { useQuery } from '@tanstack/react-query'
import { settingsApi } from '../../api/endpoints'
import { PageLoader } from '../../components/ui/Loaders'
import AppearanceTab from './AppearanceTab'

export default function AppearancePage() {
  const { data: settings, isLoading } = useQuery({ queryKey: ['settings'], queryFn: settingsApi.get })
  if (isLoading) return <PageLoader />
  return <AppearanceTab settings={settings || {}} />
}