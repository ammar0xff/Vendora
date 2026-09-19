import StorefrontNav from '../StorefrontNav'
import StorefrontHero from '../StorefrontHero'
import StorefrontCategoryShowcase from '../StorefrontCategoryShowcase'
import FeatureStrip from '../sections/StorefrontFeatureStrip'
import FeaturedProducts from '../sections/StorefrontFeaturedProducts'
import Footer from '../sections/StorefrontFooter'
import type { HomeData } from './index'

export default function MinimalHome(data: HomeData) {
  return (
    <div className="min-h-screen" style={{ background: 'var(--bg)' }}>
      <StorefrontNav />
      <StorefrontHero products={data.items} totalProducts={data.totalProducts} categoryCount={data.catList.length} variant="minimal" title={data.heroTitle} subtitle={data.heroSubtitle} />
      {data.catList.length > 0 && <StorefrontCategoryShowcase categories={data.catList} />}
      {data.items.length > 0 && <FeaturedProducts items={data.items} />}
      <FeatureStrip variant="minimal" />
      <Footer variant="minimal" />
    </div>
  )
}