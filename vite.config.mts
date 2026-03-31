import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import ReactPlugin from '@vitejs/plugin-react'
import { fileURLToPath, URL } from 'node:url'

export default defineConfig({
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./app/javascript', import.meta.url)),
    },
  },
  plugins: [
    RubyPlugin(),
    ReactPlugin(),
  ],
})
