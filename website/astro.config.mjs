// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from "@tailwindcss/vite";

// https://astro.build/config
export default defineConfig({
  // Published on GitHub Pages at https://golobitch.github.io/keber/.
  // Override with SITE_URL and BASE_PATH to host elsewhere (BASE_PATH=/ for a domain root).
  site: process.env.SITE_URL || 'https://golobitch.github.io',
  base: process.env.BASE_PATH || '/keber',
  vite: {
    plugins: [tailwindcss()],
  },
});
