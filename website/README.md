# Keber landing page

Marketing site for [Keber](https://github.com/golobitch/keber), an independent, open-source, read-only macOS app for browsing TigerBeetle clusters.

It's a static [Astro](https://astro.build) site styled with Tailwind CSS v4.

## Development

Requires Node 20 or later.

```sh
npm install          # install dependencies
npm run dev          # dev server at http://localhost:4321/
npm run build        # static build into dist/
npm run preview      # serve the dist/ build at http://localhost:4321/
```

The site is configured for its own domain, `https://keber.io`, and is served from the root. To host it under a subpath instead, override both values at build time:

```sh
SITE_URL=https://golobitch.github.io BASE_PATH=/keber npm run build
```

Links to public files and pages go through `withBase()` in `src/lib/url.ts`, so they keep working under any base path.

## Deploying

The site lives in the `website/` folder of the [keber](https://github.com/golobitch/keber) repo. The `pages` workflow there builds it and deploys `dist/` to GitHub Pages on every push to `main` that touches `website/`. It can also be run by hand from the Actions tab.

GitHub Pages serves it at `keber.io`. The domain is set in the repository's **Settings → Pages → Custom domain**; a CNAME file in `public/` would do nothing, because deploys made by a workflow ignore it. DNS for the apex points at GitHub Pages:

| Type | Name | Value |
| --- | --- | --- |
| A | `@` | `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153` |
| AAAA | `@` | `2606:50c0:8000::153`, `2606:50c0:8001::153`, `2606:50c0:8002::153`, `2606:50c0:8003::153` |
| CNAME | `www` | `golobitch.github.io` |

The old `golobitch.github.io` address redirects here once the custom domain is set.

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
