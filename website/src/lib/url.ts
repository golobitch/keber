/**
 * Prefixes a site path with the configured `base` (`/` on keber.io, or e.g. `/keber` under a subpath),
 * so links and public assets resolve both at the domain root and under a subpath.
 */
export function withBase(path = ""): string {
  const base = import.meta.env.BASE_URL.replace(/\/$/, "");
  return `${base}/${path.replace(/^\//, "")}`;
}
