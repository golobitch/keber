#!/usr/bin/env bash
# Creates or updates every label in .github/labels.tsv on the repository.
#
#   scripts/sync-labels.sh                 against the repository gh is pointed at
#   REPO=golobitch/keber scripts/sync-labels.sh
#
# Additive: a label that is on GitHub but not in the file is left alone, so renaming one here
# leaves the old one behind to delete by hand. Needs gh, authenticated with issues:write.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
repo=(); [ -n "${REPO:-}" ] && repo=(--repo "$REPO")

while IFS=$'\t' read -r name colour description; do
  case "$name" in ''|'#'*) continue ;; esac
  gh label create "$name" --color "$colour" --description "$description" --force "${repo[@]}"
  echo "label: $name"
done < .github/labels.tsv
