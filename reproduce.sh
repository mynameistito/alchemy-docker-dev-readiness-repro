#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mode="${1:-daemon}"
case "$mode" in
  daemon) fixture="$PWD/fixtures" ;;
  spawn) fixture="$PWD/fixtures/spawn" ;;
  *) echo "Usage: bash reproduce.sh [daemon|spawn]" >&2; exit 2 ;;
esac
chmod +x "$fixture/docker"
export PATH="$fixture:$PATH"
# This affects only this process tree; the real Docker daemon is untouched.
exec bun run dev
