#!/usr/bin/env bash
# Moves Keber to another TigerBeetle release, or checks that every pin agrees.
#
#   scripts/bump-tigerbeetle.sh 0.17.10              vendor the client, then rewrite every pin
#   scripts/bump-tigerbeetle.sh --pins-only 0.17.10  rewrite the pins, keep the vendored client
#   scripts/bump-tigerbeetle.sh --check              fail if a pin disagrees with the vendored VERSION
#
# Vendor/tigerbeetle/VERSION is the single source of truth: the Makefile reads it, and every file
# listed in PINS below repeats it for a reader or a compiler. The release bot
# (.github/workflows/tigerbeetle-release.yml) runs this on macOS, because `make vendor` repacks
# the archives with Apple's libtool and lipo; --pins-only and --check run anywhere.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

VERSION_FILE=Vendor/tigerbeetle/VERSION

# Every file that names the pinned release. A new one belongs here, or --check cannot see it.
PINS=(
  ui/Sources/TBKit/TBClient.swift
  cli/tbclient/src/client.rs
  README.md
  ui/README.md
  website/src/components/sections/Compatibility.astro
  website/src/components/sections/Hero.astro
)

die() { echo "bump-tigerbeetle: $*" >&2; exit 1; }
is_release() { [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; }

current="$(tr -d '[:space:]' < "$VERSION_FILE")"
is_release "$current" || die "$VERSION_FILE holds '$current', not a release like 0.17.9"

check() {
  local expected="$1" failed=0
  for file in "${PINS[@]}"; do
    if ! grep -qF "$expected" "$file"; then
      echo "::error file=$file::does not mention TigerBeetle $expected" >&2
      failed=1
    fi
  done
  [ "$failed" = 0 ] || die "pins disagree with $VERSION_FILE ($expected); run: scripts/bump-tigerbeetle.sh --pins-only $expected"
  echo "every pin names TigerBeetle $expected"
}

# Replaces the old release with the new one wherever it stands alone, so 0.17.9 never matches
# inside 0.17.90 or 10.17.9.
rewrite_pins() {
  local old="$1" new="$2" pattern
  pattern="$(printf '%s' "$old" | sed 's/\./\\./g')"
  for file in "${PINS[@]}"; do
    sed -E -i.bak "s/(^|[^0-9.])${pattern}([^0-9]|\$)/\1${new}\2/g" "$file"
    rm -f "$file.bak"
  done
}

case "${1:-}" in
  --check)
    check "$current"
    ;;
  --pins-only)
    new="${2:-}"
    is_release "$new" || die "which release? e.g. --pins-only 0.17.10"
    [ "$new" != "$current" ] || die "already on $new"
    rewrite_pins "$current" "$new"
    echo "$new" > "$VERSION_FILE"
    check "$new"
    ;;
  -h|--help|"")
    sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'
    ;;
  *)
    new="$1"
    is_release "$new" || die "'$new' is not a release like 0.17.10"
    [ "$new" != "$current" ] || die "already on $new"
    [ "$(uname -s)" = Darwin ] || die "vendoring needs macOS (libtool, lipo); use --pins-only elsewhere"
    make vendor TB_VERSION="$new"
    rewrite_pins "$current" "$new"
    check "$new"
    ;;
esac
