#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/complex-modifications"
TARGET_DIR="$HOME/.config/karabiner/assets/complex_modifications"
KARABINER_CLI="/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"

FILES=(
  00-move-escape.json
  01-home_row_mods-cags.json
  02-home_row_mods-disable.json
  03-hyper.json
  04-meh.json
  05-cursor.json
  06-cursor-disable.json
  07-numpad.json
  08-numbpad-disable.json
  09-grave-disable.json
  10-sympad.json
  11-funcpad.json
  12-funcpad-disable.json
  13-thumbs.json
  14-tab-disable.json
  15-delete-disable.json
  16-caps-word.json
)

# Rule order in combined JSON: cursor/numpad/sympad/funcpad first (track physical keys), then 00/01, then home_row_mods-disable/cursor-disable/numbpad-disable, then HRM/Hyper/Meh, thumbs
COMBINE_ORDER=(
  16-caps-word.json
  00-move-escape.json
  13-thumbs.json
  14-tab-disable.json
  # 15-delete-disable.json
  11-funcpad.json
  # 12-funcpad-disable.json
  05-cursor.json
  # 06-cursor-disable.json
  07-numpad.json
  # 08-numbpad-disable.json
  09-grave-disable.json
  10-sympad.json
  01-home_row_mods-cags.json
  02-home_row_mods-disable.json
  03-hyper.json
  04-meh.json
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
    echo "ERROR: Lint failed for $file - aborting."
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
        rule = json.load(f)
    if rule.get('manipulators'):
        rules.append(rule)
combined = {'title': 'CAGS Home Row Mods + Navigation', 'rules': rules}
with open('$OUT_FILE', 'w') as f:
    json.dump(combined, f, indent=2)
    f.write('\n')
" "${COMBINE_ORDER[@]/#/$SOURCE_DIR/}"

echo "Built ${#COMBINE_ORDER[@]} rules -> $OUT_FILE"

# Draw keymap SVG
uvx --from keymap-drawer keymap draw "$SCRIPT_DIR/keymap.yaml" -o "$OUT_DIR/keymap.svg"
echo "Generated $OUT_DIR/keymap.svg"

# Install to Karabiner if --install flag is passed
if [[ "${1:-}" == "--install" ]]; then
  mkdir -p "$TARGET_DIR"
  cp "$OUT_FILE" "$TARGET_DIR/karabiner-cags.json"
  echo "Installed -> $TARGET_DIR/karabiner-cags.json"
  echo "Enable rules in Karabiner-Elements Preferences -> Complex Modifications -> Add rule."
else
  echo "Not installed. Target: $TARGET_DIR/karabiner-cags.json"
  echo "Run with --install to copy."
fi
