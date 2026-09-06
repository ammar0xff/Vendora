/// <reference types="vitest/config" />
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  build: { sourcemap: !process.env.CI },
  test: {
    environment: 'jsdom',
    exclude: ['e2e/**', 'node_modules/**'],
  },
  plugins: [
    react(),
    tailwindcss(),
    ...(process.env.CI
      ? [{
          name: 'pwa-register-stub',
          resolveId(id) { if (id === 'virtual:pwa-register') return id },
          load(id) {
            if (id !== 'virtual:pwa-register') return undefined
            return 'export const registerSW = () => ({ updateSW: undefined })'
          },
        }]
      : [VitePWA({
          registerType: 'autoUpdate',
          workbox: {
            globPatterns: ['**/*.{js,css,html,ico,png,svg}'],
            navigateFallback: '/index.html',
            navigateFallbackDenylist: [/\/api\//],
            runtimeCaching: [
              {
                urlPattern: /^\/api\/(?:products|categories|subcategories|stock\/warehouses|wallets|safes|settings|customers|users|collections|financial-categories|shifts\/current|reports)(?:\?.*)?$/,
                handler: 'StaleWhileRevalidate',
                options: {
                  cacheName: 'api-cache',
                  expiration: { maxEntries: 100, maxAgeSeconds: 60 * 60 * 24 },
                },
              },
              {
                urlPattern: /^\/api\/stock\/balance\/bulk$/,
                handler: 'NetworkFirst',
                options: {
                  cacheName: 'stock-cache',
                  expiration: { maxEntries: 50, maxAgeSeconds: 60 * 5 },
                },
              },
              {
                urlPattern: /^\/api\/products\/barcode\//,
                handler: 'NetworkFirst',
                options: {
                  cacheName: 'barcode-cache',
                  expiration: { maxEntries: 200, maxAgeSeconds: 60 * 60 },
                },
              },
              {
                urlPattern: /^\/uploads\//,
                handler: 'CacheFirst',
                options: {
                  cacheName: 'uploads-cache',
                  expiration: { maxEntries: 50, maxAgeSeconds: 60 * 60 * 24 * 30 },
                },
              },
            ],
          },
        })]),
  ],
  server: {
    proxy: process.env.CI ? undefined : {
      '/api': { target: process.env.VITE_API_TARGET || 'http://localhost:8000', rewrite: (p) => p.replace(/^\/api/, '') },
    },
  },
})
