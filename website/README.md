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

The site is served from Cloudflare at `https://keber.io`: a Worker with static assets and no
script, configured in [`wrangler.jsonc`](wrangler.jsonc). The `website` workflow in
`.github/workflows/website.yml` builds it, adds the signed apt repository under `dist/apt`, and
runs `wrangler deploy` on every push to `main` that touches `website/`. It can also be run by hand
from the Actions tab, and a cli release dispatches it so the apt repository picks up the new
packages.

`www.keber.io` is a second Worker, [`www-redirect/`](www-redirect), that answers every request
with a 301 to the same path on `keber.io`. The site's Worker cannot do it itself: a request that
matches a file is served before any script would run.

A pull request that touches `website/` gets a preview instead of a deploy: the workflow uploads a
version of the Worker under the alias `pr-<number>` and comments its `workers.dev` URL on the pull
request. `keber.io` keeps serving `main`. Previews have no `/apt`, and pull requests from forks get
none, because they get no secrets.

### One-time setup

1. **Secrets.** Add `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` to the repository's Actions
   secrets. Make the token from the *Edit Cloudflare Workers* template, limited to your account and
   the `keber.io` zone. The account ID is on the right of the zone's Overview page.
2. **DNS.** Nothing to add by hand. The custom domains in the two wrangler configs create the
   records and certificates for `keber.io` and `www.keber.io` on the first deploy. Delete any
   records already on those two names first (for example GitHub Pages' A and CNAME records),
   because a custom domain will not take a hostname that already has one.
3. **GitHub Pages.** Turn it off under Settings → Pages once `keber.io` serves from Cloudflare.

### Locally

```sh
npm run cf:dev       # build, then serve dist/ the way Cloudflare will, at http://localhost:8787
```

Deploy from CI, not from a laptop: a local `wrangler deploy` publishes `dist/` without the apt
repository and takes `/apt` offline until the next CI deploy.

## Layout

```
src/pages/index.astro         page composition
src/components/sections/      Hero, Features, ReadOnly, Compatibility, OpenSource
src/components/elements/      Navbar, Footer
src/utils/data.ts             links, nav items and feature copy
src/lib/url.ts                base-path aware links
src/assets/                   app screenshot and icon (optimized at build time)
public/                       favicons, web manifest, Open Graph image, _headers
wrangler.jsonc                the keber Worker: dist/ as static assets on keber.io
www-redirect/                 the keber-www Worker: www.keber.io → keber.io
```

Page copy should stay in line with the app's [README](https://github.com/golobitch/keber#readme).

## Credits

Based on the [AgenceX Astro theme](https://github.com/uno-forge-hub/agency-landing-page-Astrojs) by John Kat, used under the MIT License. See [LICENCE.md](LICENCE.md).

## Icons

`public/favicon.svg` and `public/safari-pinned-tab.svg` are the web versions of the app icon in
`scripts/icon.svg`; the PNGs, `favicon.ico` and the maskable icons are rendered from them. The
manifest's paths are relative, so it works under `/keber/` and at a domain root alike.
