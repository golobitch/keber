# Contributing to Keber

Thanks for looking. Keber is small, and a good first contribution can be a theme, a flag, a test, or
a sentence in a README that confused you.

## Where to start

- Issues labelled [`good first issue`](https://github.com/golobitch/keber/labels/good%20first%20issue)
  are small and say where in the code to look.
- [`help wanted`](https://github.com/golobitch/keber/labels/help%20wanted) ones are bigger and open
  for anyone to take.
- [`ROADMAP.md`](ROADMAP.md) is where the project is going.
- Found a bug? **Help → Report a Bug…** in the app, or `keber --report` in a terminal, opens an issue
  with the versions filled in.

Comment on an issue before you start, so two people don't build the same thing. For anything
bigger than an issue describes, open one first and talk it through.

## Setting up

Everything runs from the repository root.

**The terminal UI** needs Rust; `cli/rust-toolchain.toml` pins the version, and `rustup` installs it
the first time you build.

```sh
make cli-test                   # its tests; the integration ones skip without a cluster
cd cli && cargo run -- --help
```

**The macOS app** needs macOS 15, Xcode 16.3 or later, and XcodeGen (`brew install xcodegen`). The
Xcode project is generated from `ui/project.yml` and not committed.

```sh
make tb-up      # download TigerBeetle, then format, start and seed a cluster on 127.0.0.1:3000
make open       # generate the project and open it; ⌘R connects the Debug build to the cluster
make test       # unit and integration suites
```

**The website** needs Node 20 or later: `cd website && npm ci && npm run dev`.

`make tb-stop` stops the dev cluster and `make tb-reset` throws its data away; the next `tb-up`
seeds a fresh one. The seed data is described in [`ui/README.md`](ui/README.md#development).

## The rules

Keber never writes to a cluster, keeps every id and amount exact, and decodes TigerBeetle's wire
format by hand. Those and the other rules a change is reviewed against are in
[AGENTS.md → Rules](AGENTS.md#rules). They're written for coding agents, and they're the same for
people.

## Pull requests

- One concern per pull request, linked to its issue.
- Commits are `type(scope): summary` (`feat(cli): …`, `fix(export): …`, `docs: …`), each one
  coherent on its own, with a body that says why. The release notes are built from them.
- Say how you checked it. The template has the usual commands; if you couldn't run something, for
  example the Swift suites on Linux, say so and CI will.
- New behaviour comes with a test, and a user-facing change with the README line that describes it.

CI runs the Swift suites on two Xcode versions against a real cluster, the Rust suites on macOS and
Linux, and a check that nothing calls TigerBeetle's create operations.

## Coding agents

Agents are welcome to take `agent-ready` issues, which carry a *Done when* checklist. The
instructions they read are in [AGENTS.md](AGENTS.md); `CLAUDE.md` points there too. A pull request
opened by an agent is reviewed like anyone's, and the person who asked the agent is the one we talk to.

## Security

Please don't open public issues for security problems. [SECURITY.md](SECURITY.md) says how to report
them privately.

## Licence

Keber is MIT licensed. By contributing, you agree that your contribution is too.
