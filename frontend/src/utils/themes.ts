/* Curated color themes (50 popular 2026 web/brand/UI palettes) sourced from the
   ScreenSnap Pro "50 Color Palette Ideas" article, plus the Vendora default.
   Each maps to theme_primary / theme_accent / theme_bg; theme_ink is left empty so
   resolveTheme adapts text color automatically (auto dark-mode for dark backgrounds). */

export interface ThemePreset {
  id: string
  name: string
  nameEn: string
  primary: string
  accent: string
  bg: string
}

export const THEME_PRESETS: ThemePreset[] = [
  { id: 'default', name: 'كحلي كلاسيكي', nameEn: 'Default Navy', primary: '#1e3a5f', accent: '#c8a84b', bg: '#f3f5fa' },
  { id: 'soft-calm', name: 'هادئ', nameEn: 'Soft Calm', primary: '#26A69A', accent: '#FF715B', bg: '#E0F2F1' },
  { id: 'cloud-mist', name: 'ضباب سحابي', nameEn: 'Cloud Mist', primary: '#3E4C59', accent: '#FF9F1C', bg: '#F5F7FA' },
  { id: 'vibrant-pop', name: 'بوب نابض', nameEn: 'Vibrant Pop', primary: '#8338EC', accent: '#FFBE0B', bg: '#FAF7FF' },
  { id: 'electric-citrus', name: 'حمضي كهربائي', nameEn: 'Electric Citrus', primary: '#FF5400', accent: '#8E2DE2', bg: '#FFF7EF' },
  { id: 'moody-dusk', name: 'غسق هادئ', nameEn: 'Moody Dusk', primary: '#4A4E69', accent: '#C9ADA7', bg: '#F2E9E4' },
  { id: 'midnight-ink', name: 'حبر منتصف الليل', nameEn: 'Midnight Ink', primary: '#1B263B', accent: '#C9A961', bg: '#0D1B2A' },
  { id: 'romantic-blush', name: 'وَرْد خجول', nameEn: 'Romantic Blush', primary: '#FB6F92', accent: '#8C7BD7', bg: '#FFF5F8' },
  { id: 'velvet-rose', name: 'ورد مخملي', nameEn: 'Velvet Rose', primary: '#A11D33', accent: '#C9A961', bg: '#FBECEE' },
  { id: 'energetic-sunrise', name: 'شروق مفعم', nameEn: 'Energetic Sunrise', primary: '#7209B7', accent: '#F72585', bg: '#F9F4FF' },
  { id: 'lemon-spark', name: 'شرارة ليمون', nameEn: 'Lemon Spark', primary: '#F94144', accent: '#F9C74F', bg: '#FFF8EE' },
  { id: 'fresh-spring', name: 'ربيع منعش', nameEn: 'Fresh Spring', primary: '#84BC9C', accent: '#F49E4C', bg: '#F5FAF0' },
  { id: 'spring-bloom', name: 'تفتّح الربيع', nameEn: 'Spring Bloom', primary: '#C5CAE9', accent: '#A06FD9', bg: '#FCFBFF' },
  { id: 'summer-coast', name: 'ساحل الصيف', nameEn: 'Summer Coast', primary: '#003049', accent: '#F77F00', bg: '#EAF7FB' },
  { id: 'summer-sorbet', name: 'سوربيه الصيف', nameEn: 'Summer Sorbet', primary: '#FF99C8', accent: '#C2A8E8', bg: '#FBFDFD' },
  { id: 'autumn-harvest', name: 'حصاد الخريف', nameEn: 'Autumn Harvest', primary: '#7F4F24', accent: '#D4A373', bg: '#F6F1E7' },
  { id: 'crisp-autumn', name: 'خريف قشيب', nameEn: 'Crisp Autumn', primary: '#9C2A2A', accent: '#E8A33D', bg: '#FBF4E9' },
  { id: 'winter-frost', name: 'صقيع الشتاء', nameEn: 'Winter Frost', primary: '#0077B6', accent: '#FFB703', bg: '#F2FBFF' },
  { id: 'winter-gray', name: 'رمادي الشتاء', nameEn: 'Winter Gray', primary: '#212529', accent: '#EF6C57', bg: '#F8F9FA' },
  { id: 'tech-saas', name: 'تقني أزرق', nameEn: 'Tech SaaS Blue', primary: '#1E40AF', accent: '#10B981', bg: '#F4F7FA' },
  { id: 'saas-mint', name: 'نعناعي SaaS', nameEn: 'SaaS Mint', primary: '#15803D', accent: '#F59E0B', bg: '#F3FBF5' },
  { id: 'food-warm', name: 'طعام دافئ', nameEn: 'Food / Restaurant Warm', primary: '#D62828', accent: '#F4A261', bg: '#FFF4EC' },
  { id: 'cafe-roast', name: 'تحميص القهوة', nameEn: 'Cafe Roast', primary: '#6B4226', accent: '#D4A373', bg: '#FBF5EA' },
  { id: 'healthcare-calm', name: 'صحي هادئ', nameEn: 'Healthcare Calm', primary: '#1976D2', accent: '#26A69A', bg: '#F2F8FE' },
  { id: 'wellness-sage', name: 'ميرمية العافية', nameEn: 'Wellness Sage', primary: '#558B2F', accent: '#F0B429', bg: '#F6FAF1' },
  { id: 'finance-trust', name: 'ثقة مالية', nameEn: 'Finance Trust', primary: '#1E3A5F', accent: '#C9A961', bg: '#F6F3EA' },
  { id: 'crypto-neo', name: 'كريبتو نيو', nameEn: 'Crypto Neo', primary: '#F0B90B', accent: '#22C55E', bg: '#0F1115' },
  { id: 'fashion-mono', name: 'موضة أحادية', nameEn: 'Fashion Mono', primary: '#171717', accent: '#9A7B4F', bg: '#F5F5F5' },
  { id: 'beauty-nude', name: 'جمال طبيعي', nameEn: 'Beauty Nude', primary: '#A0826D', accent: '#BC6C25', bg: '#FFF8F1' },
  { id: 'retro-mustard', name: 'خردل 70s', nameEn: '70s Mustard', primary: '#B8860B', accent: '#2F6F4F', bg: '#FDF6E3' },
  { id: 'retro-avocado', name: 'أفوكادو 70s', nameEn: '70s Avocado', primary: '#6B8E23', accent: '#D4A017', bg: '#F8F7EA' },
  { id: 'neons-80s', name: 'نيون 80s', nameEn: '80s Neon', primary: '#FFBE0B', accent: '#00F5FF', bg: '#120821' },
  { id: 'miami-sunset', name: 'غروب ميامي', nameEn: 'Miami Sunset', primary: '#C44569', accent: '#F8B500', bg: '#FFF7F0' },
  { id: 'y2k-pastel', name: 'باستيل Y2K', nameEn: 'Y2K Pastel', primary: '#B8C0FF', accent: '#B388EB', bg: '#FBFBFF' },
  { id: 'y2k-cyber', name: 'سايبر Y2K', nameEn: 'Y2K Cyber', primary: '#FF61D2', accent: '#00B8CC', bg: '#FFF5FB' },
  { id: 'modern-minimal', name: 'معاصر مينمال', nameEn: 'Modern Minimal', primary: '#27272A', accent: '#E5484D', bg: '#FAFAFA' },
  { id: 'scandi-soft', name: 'سكاندي هادئ', nameEn: 'Scandi Soft', primary: '#5D4037', accent: '#C08552', bg: '#FAF7F2' },
  { id: 'deep-ocean', name: 'محيط عميق', nameEn: 'Deep Ocean', primary: '#0077B6', accent: '#FFB703', bg: '#EAF6FB' },
  { id: 'coastal-sea', name: 'بحر ساحلي', nameEn: 'Coastal Sea', primary: '#264653', accent: '#E9C46A', bg: '#F2F7F5' },
  { id: 'forest-pine', name: 'صنوبر الغابة', nameEn: 'Forest Pine', primary: '#2D6A4F', accent: '#DDA15E', bg: '#F2F7F0' },
  { id: 'misty-woodland', name: 'غابة ضبابية', nameEn: 'Misty Woodland', primary: '#3A5A40', accent: '#B08968', bg: '#F0F4EA' },
  { id: 'sunset-glow', name: 'وهج الغروب', nameEn: 'Sunset Glow', primary: '#FF7B00', accent: '#3D348B', bg: '#FFF5EC' },
  { id: 'tropical-sunset', name: 'غروب استوائي', nameEn: 'Tropical Sunset', primary: '#7209B7', accent: '#FF6B35', bg: '#FBF4FF' },
  { id: 'desert-sand', name: 'رمال الصحراء', nameEn: 'Desert Sand', primary: '#A0522D', accent: '#D9A021', bg: '#F7F0E5' },
  { id: 'mountain-slate', name: 'سلويت الجبال', nameEn: 'Mountain Slate', primary: '#354F52', accent: '#D4A96A', bg: '#F0F4F2' },
  { id: 'dark-default', name: 'وضع داكن', nameEn: 'Dark Mode Default', primary: '#334155', accent: '#38BDF8', bg: '#0F172A' },
  { id: 'inky-plum', name: 'بنفسجي حبري', nameEn: 'Inky Plum', primary: '#3C096C', accent: '#FFC300', bg: '#12082A' },
  { id: 'charcoal-wine', name: 'فحم نبيذي', nameEn: 'Charcoal Wine', primary: '#6B2C2C', accent: '#E0B58A', bg: '#F6EFE7' },
  { id: 'soft-cream', name: 'كريمي ناعم', nameEn: 'Soft Cream', primary: '#B08968', accent: '#4A7C59', bg: '#FFFDF6' },
  { id: 'light-sky', name: 'سماء فاتحة', nameEn: 'Light Sky', primary: '#0EA5E9', accent: '#FFB703', bg: '#EFF9FF' },
  { id: 'dusty-pastel', name: 'باستيل مترب', nameEn: 'Dusty Pastel', primary: '#B89B9B', accent: '#A7BFA5', bg: '#F6ECE8' },
]