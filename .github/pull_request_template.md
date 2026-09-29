<!-- One concern per pull request. Link the issue it closes, if there is one. -->

## What and why

Closes #

## How I checked it

<!-- Delete what doesn't apply. -->
- [ ] `make test` (macOS app, needs the dev cluster: `make tb-up`)
- [ ] `make cli-test`, plus `cargo fmt --check` and `cargo clippy --all-targets -- -D warnings` in `cli/`
- [ ] `npm run build` in `website/`
- [ ] Screenshot or `keber --dump …` output for anything you can see

## Invariants

<!-- AGENTS.md explains each one. -->
- [ ] Nothing new calls `create_accounts` or `create_transfers`
- [ ] Ids, amounts and user_data stay exact integers end to end
- [ ] No new dependency, or the reason for one is above
- [ ] READMEs updated where behaviour changed
- [ ] Commits follow `type(scope): summary`, one concern each
