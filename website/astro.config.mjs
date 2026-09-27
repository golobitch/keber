// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from "@tailwindcss/vite";

// https://astro.build/config
export default defineConfig({
  // Served from Cloudflare at https://keber.io; see wrangler.jsonc and .github/workflows/website.yml.
  // Override with SITE_URL and BASE_PATH to host elsewhere (e.g. BASE_PATH=/keber under a subpath).
  site: process.env.SITE_URL || 'https://keber.io',
  base: process.env.BASE_PATH || '/',
  vite: {
    plugins: [tailwindcss()],
  },
});
