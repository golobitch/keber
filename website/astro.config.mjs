// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from "@tailwindcss/vite";

// https://astro.build/config
export default defineConfig({
  // Published on GitHub Pages at https://keber.io, a custom domain on the repository's Pages settings.
  // Override with SITE_URL and BASE_PATH to host elsewhere (e.g. BASE_PATH=/keber under a subpath).
  site: process.env.SITE_URL || 'https://keber.io',
  base: process.env.BASE_PATH || '/',
  vite: {
    plugins: [tailwindcss()],
  },
});
