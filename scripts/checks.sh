#!/usr/bin/env bash
# Shared check commands used by both .github/workflows/ci.yml and the
# .githooks/pre-commit hook, so the two never drift apart.
#
# Usage: scripts/checks.sh [flake-check|fmt|lint|dead|all]

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

flake_check() {
  nix flake check --no-build --show-trace
}

fmt_check() {
  nix shell nixpkgs#nixfmt -c sh -c \
    'find . -name "*.nix" ! -path "./.git/*" | xargs nixfmt --check'
}

lint_check() {
  nix run nixpkgs#statix -- check .
}

dead_check() {
  nix run nixpkgs#deadnix -- --fail .
}

case "${1:-all}" in
  flake-check) flake_check ;;
  fmt) fmt_check ;;
  lint) lint_check ;;
  dead) dead_check ;;
  all)
    flake_check
    fmt_check
    lint_check
    dead_check
    ;;
  *)
    echo "Unknown check: ${1:-}" >&2
    echo "Usage: $0 [flake-check|fmt|lint|dead|all]" >&2
    exit 1
    ;;
esac
