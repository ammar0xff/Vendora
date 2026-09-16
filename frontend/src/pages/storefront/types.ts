export interface StorefrontCategory {
  id: string
  name: string
  code?: string | null
  product_count: number
}

export interface StorefrontProduct {
  id: string
  name: string
  code: string | null
  unit: string
  retail_price: number | string
  wholesale_price: number | string
  company: string | null
  size: string | null
  image_url: string | null
  subcategory_id: string | null
  category_id: string | null
  category_name: string | null
}

export interface StorefrontPage {
  items: StorefrontProduct[]
  total: number
  page: number
  size: number
  pages: number
}