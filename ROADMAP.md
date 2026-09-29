# Roadmap

Where Keber is going, roughly in order. Dates are intentions, not promises. Each item becomes
issues when it's next; `good first issue` and `help wanted` are the ones open for anyone.

## Now — late 2026

- **Zero-setup demo.** "Try without a cluster" in the app and `keber --demo` in the terminal: a
  TigerBeetle replica started on loopback with sample data, so Keber can be tried in thirty seconds.
- **TigerBeetle release bot.** A pull request for every new stable TigerBeetle release, tested by CI
  against that server. *(Done.)*
- **Private networks.** Reaching a cluster behind an SSH bastion, which is how most production
  clusters, TigerBeetle Cloud's included, are reached.
- **Decoders.** Read `user_data` the way your system writes it: UUID, ULID, packed integers, text,
  timestamps. Search accepts the decoded form.

## Next — first half of 2027

- **Tail mode.** A live view of new transfers matching a filter, like `tail -f` for a ledger.
- **Copy as code.** Any filter, account or transfer as a literal for Go, Rust, TypeScript, Java,
  .NET or Python.
- **Tables that behave like Finder's.** Column choice and order remembered per screen, copy rows
  as TSV, drag rows out as CSV or JSON.
- **Services menu.** Select an id anywhere on the Mac and open it in Keber.
- **Several TigerBeetle releases at once.** Connect to clusters on different releases from one app,
  each through its own `tb_client`.
- **Connections as documents, window tabs, and full state restoration.**

## Later — second half of 2027

- **Dev mode.** Opt-in, separate, for local and dev clusters only: compose transfers, see the result
  code before sending, and fork a slice of a cluster into a throwaway local one. The read-only
  guarantee stays exactly as it is for everything else.
- **Chart of accounts.** Name accounts and groups, so screens read "Customer omnibus · EUR" rather
  than an id.
- **Period and as-of reports, reconciliation against a statement, and audit evidence packs.**

## Ideas

Widgets and a menu bar extra, App Intents and Spotlight, on-device natural-language queries. Open
an issue with the feature form if one of these, or something else, would make Keber more useful to
you.
