import StorefrontHero from '../StorefrontHero'
import StorefrontCategoryShowcase from '../StorefrontCategoryShowcase'
import StorefrontPromo from '../StorefrontPromo'
import StorefrontTestimonials from '../StorefrontTestimonials'
import FeatureStrip from '../sections/StorefrontFeatureStrip'
import FeaturedProducts from '../sections/StorefrontFeaturedProducts'
import type { HomeData, Tone } from './index'
import type { SectionConfig } from './sections'

export default function StorefrontSections({ data, tone, sections }: { data: HomeData; tone: Tone; sections: SectionConfig[] }) {
  return (
    <>
      {sections.filter((s) => s.enabled !== false).map((s) => {
        switch (s.id) {
          case 'hero':
            return (
              <StorefrontHero
                key="hero"
                products={data.items}
                totalProducts={data.totalProducts}
                categoryCount={data.catList.length}
                variant={tone}
                title={data.heroTitle}
                subtitle={data.heroSubtitle}
              />
            )
          case 'categories':
            return data.catList.length > 0 ? <StorefrontCategoryShowcase key="categories" categories={data.catList} heading={s.heading} /> : null
          case 'featured':
            return data.items.length > 0 ? <FeaturedProducts key="featured" items={data.items} heading={s.heading} /> : null
          case 'promo':
            return <StorefrontPromo key="promo" />
          case 'testimonials':
            return <StorefrontTestimonials key="testimonials" />
          case 'features':
            return <FeatureStrip key="features" variant={tone} />
          default:
            return null
        }
      })}
    </>
  )
}