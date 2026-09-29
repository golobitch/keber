# AGENTS.md

Instructions for coding agents working in this repository, and a short tour for anyone else in a
hurry. [CONTRIBUTING.md](CONTRIBUTING.md) is the longer version for people.

Keber is a read-only explorer for [TigerBeetle](https://tigerbeetle.com) clusters, with two front
ends over one vendored C client: a native macOS app (SwiftUI) and a terminal UI (Rust, ratatui).
The landing page at keber.io lives here too.

## Map

| Path | What it is |
| --- | --- |
| `ui/Sources/TBKit/` | Swift client over `tb_client`: wire encoding, queries, chains, export, deep links. No UI. |
| `ui/Sources/TBExplorer/` | The SwiftUI app. The Xcode target keeps its first name, `TBExplorer`. |
| `ui/Tests/TBKitTests/` | Swift Testing suites; `IntegrationTests` need a seeded cluster. |
| `ui/Tools/tb-seed/` | Seeds the dev cluster. **The only code allowed to write to a cluster.** |
| `cli/tbclient/` | Rust client over `tb_client`, the counterpart of TBKit. |
| `cli/keber/` | The terminal UI. `src/tests.rs` renders frames and asserts on them. |
| `Vendor/tigerbeetle/` | `tb_client.h`, the static libraries, and `VERSION`, the pinned release. |
| `website/` | Astro site, served from Cloudflare with wrangler. |
| `scripts/` | Dev cluster, TigerBeetle bump, apt repository, release notes, labels, icon source. |
| `.github/workflows/` | CI, releases, the website deploy, the TigerBeetle release bot. |

## Commands

| What | Command | Needs |
| --- | --- | --- |
| Start a seeded dev cluster on 127.0.0.1:3000 | `make tb-up` | macOS (the seeder is Swift) |
| App: open in Xcode | `make open` | macOS 15, Xcode 16.3+, `brew install xcodegen` |
| App: unit and integration tests | `make test` | the dev cluster |
| TUI: run against the dev cluster | `make cli-run` | Rust (the version is pinned in `cli/rust-toolchain.toml`) |
| TUI: tests, format, lint | `cd cli && cargo test && cargo fmt --check && cargo clippy --all-targets -- -D warnings` | Rust |
| TUI: render one frame without a terminal | `cd cli && cargo run -q -- --dump accounts` | a cluster |
| Website: build | `cd website && npm ci && npm run build` | Node 20+ |
| Every TigerBeetle pin agrees | `scripts/bump-tigerbeetle.sh --check` | bash |

On Linux you can build and test the terminal UI and the website. The Rust integration tests skip
themselves without `TB_ADDRESS`, and seeding a cluster needs macOS. Anything under `ui/` needs
macOS and Xcode; if you cannot run it, say so in the pull request, and CI builds it on two Xcodes.

## Rules

Each of these is enforced by CI or by review. A change that breaks one will not be merged.

1. **Read-only.** Nothing under `ui/Sources` or `cli/` may call `create_accounts` or
   `create_transfers`; CI greps for both. `ui/Tools/tb-seed` is the only writer, and it exists for
   the dev cluster. A feature that needs writes is a design discussion first, not a pull request.
2. **Exact numbers.** Ids, amounts and `user_data` are `UInt128`/`u128` (or `UInt64`/`UInt32`) from
   the wire to the screen. No `Double`/`f64` except the balance chart's plot, whose readout and
   tables still show the exact value. JSON exports write 128-bit values as strings.
3. **The wire format is decoded by hand.** Swift cannot import `__uint128_t` fields, so TBKit reads
   the structs at the byte offsets in `tb_client.h`, and `WireTests` pins them. Change both
   together, and the Rust side too.
4. **Links name a place, never how to reach it.** A `keber://` link carries a kind, an id and the
   cluster id. It carries no addresses, and opening one never connects. `tb-explorer://` must keep
   opening.
5. **TigerBeetle lives in `Vendor/tigerbeetle/VERSION`.** Don't edit version constants or tables by
   hand. `scripts/bump-tigerbeetle.sh x.y.z` moves everything, and a bot opens those pull requests.
6. **Names users already have stay.** The bundle id `com.golobitch.tb-explorer`, the
   `tb-explorer` Application Support folder, and the `~/.config/tb-tui` fallback are where people's
   saved connections and themes live.
7. **Few dependencies.** The terminal UI depends on `ratatui` and `crossterm` on purpose, and the
   app on Apple's SDKs and the vendored `tb_client` alone. A new dependency needs a reason in the
   pull request.
8. **The terminal UI writes one file:** `~/.config/keber/config`. The app writes only inside its
   sandbox container, and to files the user picked in a save panel.

## Style

- **Commits:** `type(scope): summary` — `feat`, `fix`, `docs`, `refactor`, `test`, `build`, `ci`,
  `chore`; scopes like `ui`, `cli`, `links`, `export`, `website`, `release`. One concern per
  commit, and a body that says why. Add `!` and a `BREAKING CHANGE:` footer when users have to do
  something. The release notes are generated from these.
- **Comments say why.** What the code does is in the code; the reason it does it that way, the case
  it guards against, and the bug that taught us are what belong in a comment.
- **Prose** uses British spelling (colour, licence). Identifiers follow their APIs (`Color`,
  `--no-color`).
- **Tests** sit beside what they test: Swift in `ui/Tests/TBKitTests`, Rust in a `tests` module or
  in `cli/keber/src/tests.rs` for rendering. A bug fix comes with the test that would have caught it.
- **User-facing change?** Update the README that describes it: `README.md`, `ui/README.md`,
  `cli/README.md` or `website/README.md`.

## Working on an issue

- Issues labelled `agent-ready` have a *Done when* checklist; build against it and tick it off in
  the pull request. `good first issue` ones say where to start.
- One issue per pull request. Say which one it closes, and what you could and could not run.
- Don't bump versions, tag releases, edit `docs/RELEASING.md`'s procedures, or deploy the website
  from a laptop; a local `wrangler deploy` publishes the site without its apt repository.
- Don't touch secrets, and don't add workflow steps that send data anywhere new.
