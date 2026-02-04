#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/complex-modifications"
TARGET_DIR="$HOME/.config/karabiner/assets/complex_modifications"
KARABINER_CLI="/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"

FILES=(
  00-simple-mods.json
  01-cursor.json
  02-home_row_mods-cags.json
  03-hyper-220ms.json
  04-meh-220ms.json
)

# Lint all files before copying any
for file in "${FILES[@]}"; do
  src="$SOURCE_DIR/$file"
  if [[ ! -f "$src" ]]; then
    echo "ERROR: Source file not found: $src"
    exit 1
  fi
  echo "Linting $file..."
  if ! "$KARABINER_CLI" --lint-complex-modifications "$src"; then
    echo "ERROR: Lint failed for $file — aborting."
    exit 1
  fi
done

# Build combined file to out directory
OUT_DIR="$SCRIPT_DIR/out"
mkdir -p "$OUT_DIR"

OUT_FILE="$OUT_DIR/karabiner-cags.json"
python3 -c "
import json, sys
rules = []
for path in sys.argv[1:]:
    with open(path) as f:
        rules.append(json.load(f))
combined = {'title': 'CAGS Home Row Mods + Navigation', 'rules': rules}
with open('$OUT_FILE', 'w') as f:
    json.dump(combined, f, indent=2)
    f.write('\n')
" "${FILES[@]/#/$SOURCE_DIR/}"

echo "Built ${#FILES[@]} rules → $OUT_FILE"

# Draw keymap SVG
uvx --from keymap-drawer keymap draw "$SCRIPT_DIR/keymap.yaml" -o "$OUT_DIR/keymap.svg"
echo "Generated $OUT_DIR/keymap.svg"

# Install to Karabiner if --install flag is passed
if [[ "${1:-}" == "--install" ]]; then
  mkdir -p "$TARGET_DIR"
  cp "$OUT_FILE" "$TARGET_DIR/karabiner-cags.json"
  echo "Installed → $TARGET_DIR/karabiner-cags.json"
  echo "Enable rules in Karabiner-Elements Preferences → Complex Modifications → Add rule."
fi
