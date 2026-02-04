#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p out
uvx --from keymap-drawer keymap draw keymap.yaml -o out/keymap.svg
echo "Generated out/keymap.svg"
