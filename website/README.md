# Keber landing page

Marketing site for [Keber](https://github.com/golobitch/keber), an independent, open-source, read-only macOS app for browsing TigerBeetle clusters.

It's a static [Astro](https://astro.build) site styled with Tailwind CSS v4.

## Development

Requires Node 20 or later.

```sh
npm install          # install dependencies
npm run dev          # dev server at http://localhost:4321/keber/
npm run build        # static build into dist/
npm run preview      # serve the dist/ build at http://localhost:4321/keber/
```

The site is configured for its GitHub Pages address, `https://golobitch.github.io/keber/`. That's why it's served under `/keber/` locally too. To host it elsewhere, override both values at build time:

```sh
SITE_URL=https://example.com BASE_PATH=/ npm run build
```

Links to public files and pages go through `withBase()` in `src/lib/url.ts`, so they keep working under any base path.

## Deploying

The site lives in the `website/` folder of the [keber](https://github.com/golobitch/keber) repo. The `pages` workflow there builds it and deploys `dist/` to GitHub Pages on every push to `main` that touches `website/`. It can also be run by hand from the Actions tab.

## Layout

```
src/pages/index.astro         page composition
src/components/sections/      Hero, Features, ReadOnly, Compatibility, OpenSource
src/components/elements/      Navbar, Footer
src/utils/data.ts             links, nav items and feature copy
src/lib/url.ts                base-path aware links
src/assets/                   app screenshot and icon (optimized at build time)
public/                       favicons and Open Graph image
```

Page copy should stay in line with the app's [README](https://github.com/golobitch/keber#readme).

## Credits

Based on the [AgenceX Astro theme](https://github.com/uno-forge-hub/agency-landing-page-Astrojs) by John Kat, used under the MIT License. See [LICENCE.md](LICENCE.md).

## Icons

`public/favicon.svg` and `public/safari-pinned-tab.svg` are the web versions of the app icon in
`scripts/icon.svg`; the PNGs, `favicon.ico` and the maskable icons are rendered from them. The
manifest's paths are relative, so it works under `/keber/` and at a domain root alike.
