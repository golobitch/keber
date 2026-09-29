#!/usr/bin/env bash
# Opens the first batch of contributor issues: small, scoped, each with a "Done when" checklist.
#
#   scripts/open-starter-issues.sh             against the repository gh is pointed at
#   REPO=golobitch/keber scripts/open-starter-issues.sh
#   DRY_RUN=1 scripts/open-starter-issues.sh   print what it would open
#
# Safe to run twice: an issue whose title already exists, open or closed, is skipped. Syncs the
# labels first, since every issue here uses them. Needs gh, authenticated with issues:write.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
repo=(); [ -n "${REPO:-}" ] && repo=(--repo "$REPO")

if [ -z "${DRY_RUN:-}" ]; then
  scripts/sync-labels.sh >/dev/null
fi

opened=0 skipped=0
issue() {  # title, comma-separated labels; the body comes on stdin
  local title="$1" labels="$2" body
  body="$(cat)"
  if [ -n "${DRY_RUN:-}" ]; then
    printf '\n=== %s  [%s]\n%s\n' "$title" "$labels" "$body"
    opened=$((opened + 1))
    return
  fi
  # The search is fuzzy; the exact comparison is what decides.
  if gh issue list "${repo[@]}" --state all --limit 200 --search "in:title \"$title\"" \
      --json title --jq '.[].title' | grep -Fxq -- "$title"; then
    echo "exists: $title"
    skipped=$((skipped + 1))
    return
  fi
  gh issue create "${repo[@]}" --title "$title" --label "$labels" --body "$body"
  opened=$((opened + 1))
}

issue "A light theme for the terminal UI" "good first issue,agent-ready,feature,area: cli" <<'EOF'
All ten themes that ship with `keber` are dark or defer to the terminal. People who work in a light
terminal have nothing to pick.

**Where to look**
- `cli/keber/themes/`: one file per theme; `nord.theme` is a good one to copy.
- `cli/keber/src/theme/preset.rs`: the table of presets, and the test that checks every role is
  readable against the theme's own background (3:1).
- `cli/README.md#themes`: the list of names.

**Done when**
- [ ] A light preset ships, for example `solarized-light` or `catppuccin-latte`, using that
      palette's official colours.
- [ ] Flags keep their meaning: pending is yellow, posted green, voided and closed red, linked
      purple, history blue.
- [ ] `cargo test` passes, including the contrast test, and `keber --list-themes` shows it.
- [ ] The README lists it.
EOF

issue "keber --version" "good first issue,agent-ready,feature,area: cli" <<'EOF'
There is no quick way to ask the terminal UI what it is; `--help` doesn't say.

**Where to look:** `cli/keber/src/main.rs` (`parse_options` and `HELP`).

**Done when**
- [ ] `keber --version` prints `keber <version> (tb_client <version>)` and exits 0.
- [ ] It works with no cluster running, like `--help`.
- [ ] `--help` lists it, and a test covers the output.
EOF

issue "Copy the selected id in the terminal UI" "good first issue,agent-ready,feature,area: cli" <<'EOF'
In the macOS app every id has Copy and Copy as Hex. In the terminal UI you select the id with the
mouse, which breaks across wrapped columns and over SSH.

**Idea:** `y` copies the selected row's id with an OSC 52 escape, which most terminals honour
locally and over SSH, and which needs no clipboard crate.

**Where to look:** `cli/keber/src/main.rs` (key handling), `cli/keber/src/ui/overlay.rs` (the `?`
help), `cli/keber/src/app.rs` (`status`, for the footer message).

**Done when**
- [ ] `y` on an account or transfer row copies its id as decimal; the footer says what was copied.
- [ ] The sequence is built by a small function with a unit test; no new dependency.
- [ ] `?` and `cli/README.md#keys` list it.
EOF

issue "Show user_data_128 as a UUID in the Raw tab" "good first issue,agent-ready,feature,area: app" <<'EOF'
Many systems keep a UUID in `user_data_128`. Keber shows it as a 39-digit decimal, which nobody can
match against their logs.

**Where to look:** `ui/Sources/TBKit/Export.swift` (`rawDescription`, which the Raw tab shows),
`ui/Sources/TBKit/U128.swift` (formatting), `ui/Tests/TBKitTests/`.

**Done when**
- [ ] A TBKit function formats a `UInt128` as a UUID: its 32 hex digits, most significant first,
      grouped 8-4-4-4-12, as Python's `uuid.UUID(int=…)` does.
- [ ] The Raw tab of accounts and transfers shows a `user_data_128 (uuid)` line under the decimal
      one, only when the value is non-zero.
- [ ] Tests cover zero, `UInt128.max`, and a known UUID.
EOF

issue "Export as NDJSON" "good first issue,agent-ready,feature,area: app" <<'EOF'
JSON exports wrap all rows in one array, which is awkward to stream into `jq -c`, DuckDB or a log
pipeline. Newline-delimited JSON, one object per line, is the usual answer.

**Where to look:** `ui/Sources/TBKit/ExportWriters.swift` (`ExportFormat` and the writers),
`ui/Sources/TBExplorer/ExportPanel.swift` (the format picker), `ui/Tests/TBKitTests/ExportTests.swift`.

**Done when**
- [ ] `ExportFormat.ndjson` writes one JSON object per row per line, with the same fields as JSON,
      128-bit values as strings, and `.ndjson` as the extension.
- [ ] The save panel offers it, and the choice is remembered like the others.
- [ ] Tests parse each line of an export back and check the exact values survive.
EOF

issue "A 404 page for keber.io" "good first issue,agent-ready,feature,area: website" <<'EOF'
A path that doesn't exist on keber.io returns an empty 404. It should look like the rest of the site
and point back home.

**Where to look:** `website/src/pages/` (Astro routes), `website/wrangler.jsonc` (`assets`).

**Done when**
- [ ] `website/src/pages/404.astro` uses the site's layout and links to `/`.
- [ ] `wrangler.jsonc` sets `"not_found_handling": "404-page"` under `assets`.
- [ ] With `npm run cf:dev`, `/nope` returns status 404 with that page.
EOF

issue "Lint the workflows with actionlint" "good first issue,agent-ready,area: release" <<'EOF'
The workflows carry most of the release process, and a typo in one is found only when a tag is
pushed.

**Done when**
- [ ] A CI job runs `actionlint` on pull requests that touch `.github/workflows/`.
- [ ] `.github/actionlint.yaml` declares the `xcode-27` runner label `ci.yml` uses, so it isn't
      reported as unknown.
- [ ] It passes on main, including the shellcheck findings actionlint reports.
EOF

issue "Record the terminal UI for its README" "good first issue,docs,area: cli" <<'EOF'
`cli/README.md` describes the terminal UI in words only. A short recording would show k9s-style
navigation better than any paragraph.

**Done when**
- [ ] A recording under 30 seconds, made against `make tb-up`'s dev cluster: accounts, open one, its
      transfers, `b` for balance history, `:theme`.
- [ ] Made with a scriptable tool such as VHS, with its tape file committed, so it can be re-recorded
      when the UI changes.
- [ ] Embedded near the top of `cli/README.md`, under 2 MB.
EOF

issue "Keyboard Shortcuts in the Help menu" "good first issue,feature,area: app" <<'EOF'
The app has shortcuts for most of what it does (⌘K, ⌘F, ⌘[, ⌘], ⇧⌘E…), but the only way to find
them is to open every menu.

**Where to look:** `ui/Sources/TBExplorer/HelpCommands.swift`, and the menus in
`ui/Sources/TBExplorer/TBExplorerApp.swift`.

**Done when**
- [ ] Help → Keyboard Shortcuts opens a small window listing every shortcut, grouped by menu.
- [ ] The list says which shortcuts need a connection.
EOF

issue "Open an id from anywhere with the Services menu" "help wanted,feature,area: app" <<'EOF'
An id shows up in a Slack message, a log line or a stack trace. Getting it into Keber means copying
it, switching apps and pressing ⌘K.

**Idea:** a macOS service, *Open in Keber*, for selected text. It parses the selection as a decimal
or `0x` hex id and opens Go to ID with it, in the connected cluster.

**Done when**
- [ ] `NSServices` in `Info.plist` declares the service for plain text.
- [ ] The selection is parsed with the same rules as Go to ID; anything else shows an explanation.
- [ ] It never connects: with no connection, the id waits, like a `keber://` link does.
- [ ] `ui/README.md` describes it.
EOF

issue "Zero-setup demo: try Keber without a cluster" "help wanted,feature,area: app,area: cli" <<'EOF'
Most people who find Keber don't have a TigerBeetle cluster at hand, so they can't try it.

**Design**
- TigerBeetle is one self-contained binary. The demo starts it on `127.0.0.1` on a free port, with a
  data file Keber owns, and connects to it like any saved connection. Nothing listens beyond
  loopback, and the replica stops with Keber.
- Terminal UI: `keber --demo` uses `tigerbeetle` from `PATH`, or downloads the pinned release
  (`Vendor/tigerbeetle/VERSION`) once into `~/.cache/keber` and verifies it.
- App: the binary ships inside Keber.app, signed and notarized with it. It needs the
  `network.server` entitlement, and a helper that inherits the sandbox.
- Seeding: Keber itself never writes. The seeder, like `ui/Tools/tb-seed` today, is a separate
  program that only writes to the replica the demo just started.

**Done when (first step: the terminal UI)**
- [ ] `keber --demo` starts, seeds and connects to a local replica, and stops it on quit.
- [ ] A second `--demo` reuses the data file; `--demo --reset` starts fresh.
- [ ] No create operation appears under `cli/`: the seeding lives in its own binary.
EOF

echo
echo "opened $opened, skipped $skipped"
