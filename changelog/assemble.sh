#!/bin/sh
# Run the one changelog tool, whity-core's scripts/changelog-assemble.php, on the
# repository in the current folder (WHIT-1057). Run it from the repository root:
#
#   curl -fsSL https://raw.githubusercontent.com/whity-org/.github/main/changelog/assemble.sh | sh
#   curl -fsSL https://raw.githubusercontent.com/whity-org/.github/main/changelog/assemble.sh | sh -s -- --check
#
# Without --check it folds changelog.d/ into CHANGELOG.md's [Unreleased] and
# deletes the fragments, the release step.
set -eu

ref="${WHITY_CHANGELOG_REF:-develop}"
base="https://raw.githubusercontent.com/whity-org/whity-core/${ref}/scripts"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/lib"
curl -fsSL "$base/changelog-assemble.php" -o "$tmp/changelog-assemble.php"
curl -fsSL "$base/lib/changelog-fragments.php" -o "$tmp/lib/changelog-fragments.php"
php "$tmp/changelog-assemble.php" "--root=$(pwd)" "$@"
