import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    host: '0.0.0.0',
    port: 5000,
    proxy: {
      '/api/scan-receipt': {
        target: 'http://localhost:3001',
        changeOrigin: true
      },
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true
      }
    },
    allowedHosts: true
  }
})
