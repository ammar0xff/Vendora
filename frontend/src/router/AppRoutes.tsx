import { Route, Routes, Navigate, useLocation, useParams } from 'react-router-dom'
import { useEffect } from 'react'
import LoginPage from '../pages/LoginPage'
import StorefrontHomePage from '../pages/storefront/StorefrontHomePage'
import StorefrontCatalogPage from '../pages/storefront/StorefrontCatalogPage'
import StorefrontCartPage from '../pages/storefront/StorefrontCartPage'
import StorefrontWishlistPage from '../pages/storefront/StorefrontWishlistPage'
import StorefrontProductDetailPage from '../pages/storefront/StorefrontProductDetailPage'
import StorefrontAboutPage from '../pages/storefront/StorefrontAboutPage'
import NotFoundPage from '../pages/NotFoundPage'
import { NAV_GROUPS, HIDDEN_PAGES } from './navTree'
import AdminLayout from './AdminLayout'

/** Redirect a legacy /store/product/:id URL to the root path, preserving the id */
function ProductRedirect() {
  const { id } = useParams()
  return <Navigate to={`/products/${id}`} replace />
}

/** Redirect /print/* → /api/print/* so nginx proxies it to the backend */
function PrintRedirect() {
  const location = useLocation()
  useEffect(() => {
    const url = `/api${location.pathname}${location.search}`
    window.location.replace(url)
  }, [location.pathname, location.search])
  return <div style={{ fontFamily: 'var(--font-body, Cairo, sans-serif)', padding: 32, direction: 'rtl', fontSize: 16 }}>جارٍ فتح الفاتورة…</div>
}

export default function AppRoutes() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />

      {/* Public storefront — no auth, served at root */}
      <Route path="/" element={<StorefrontHomePage />} />
      <Route path="/catalog" element={<StorefrontCatalogPage />} />
      <Route path="/cart" element={<StorefrontCartPage />} />
      <Route path="/wishlist" element={<StorefrontWishlistPage />} />
      <Route path="/products/:id" element={<StorefrontProductDetailPage />} />
      <Route path="/about" element={<StorefrontAboutPage />} />

      {/* Legacy /store/* links → redirect to root storefront */}
      <Route path="/store" element={<Navigate to="/" replace />} />
      <Route path="/store/catalog" element={<Navigate to="/catalog" replace />} />
      <Route path="/store/cart" element={<Navigate to="/cart" replace />} />
      <Route path="/store/wishlist" element={<Navigate to="/wishlist" replace />} />
      <Route path="/store/products/:id" element={<ProductRedirect />} />
      <Route path="/store/about" element={<Navigate to="/about" replace />} />

      {/* Admin panel — auth + permission guard, Layout shell */}
      <Route element={<AdminLayout />}>
        {NAV_GROUPS.flatMap(g => g.items).map(page =>
          page.section ? (
            <Route key={page.path} path={page.path} element={<page.Component />}>
              <Route index element={<Navigate to={`${page.path}/${page.defaultChild}`} replace />} />
              {page.section.map(tab => (
                <Route key={tab.path} path={tab.path} element={<tab.Component />} />
              ))}
            </Route>
          ) : (
            <Route key={page.path} path={page.path} element={<page.Component />} />
          )
        )}
        {HIDDEN_PAGES.map(page => (
          <Route key={page.path} path={page.path} element={<page.Component />} />
        ))}
        <Route path="/reports" element={<Navigate to="/accounting" replace />} />
      </Route>

      {/* Print routes — redirect to backend with auth token */}
      <Route path="/print/*" element={<PrintRedirect />} />
      <Route path="*" element={<NotFoundPage />} />
    </Routes>
  )
}