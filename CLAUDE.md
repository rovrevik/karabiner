# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Karabiner-Elements complex modification configs for macOS keyboard customization, targeting the **Apple Magic Keyboard (USB-C)** — the compact variant without Touch ID or numeric keypad ([MXCL3LL/A](https://www.apple.com/shop/product/mxcl3ll/a/magic-keyboard-usb-c-us-english)). The system implements CAGS home row mods, Hyper/Meh modifiers, and cursor navigation — mirroring a ZMK Corne split keyboard layout on a standard keyboard.

## User Terminology
- **HRM / home row mods** = CAGS order: A=Ctrl, S=Alt, D=Cmd(Gui), F=Shift / J=Shift, K=Cmd, L=Alt, ;=Ctrl
- **Hyper** = lower pinkies (Z and /) — Shift+Cmd+Opt+Ctrl on hold (pinky timing)
- **Meh** = lower ring fingers (X and .) — Shift+Opt+Ctrl on hold (ring timing)

## File Structure

All configs live in `complex-modifications/`. Files are numbered to indicate intended rule ordering in the Karabiner profile (earlier rules take priority):

| File | Purpose |
|------|---------|
| `00-simple.json` | Caps→Escape, escape→disabled only |
| `01-home_row_mods-cags.json` | CAGS home row mods: A=Ctrl, S=Alt, D=Cmd, F=Shift (left); J=Shift, K=Cmd, L=Alt, ;=Ctrl (right). Per-finger hold thresholds derived from ZMK companion config (`corne.keymap`). Includes all simultaneous multi-key modifier combos |
| `02-home_row_mods-disable.json` | Disables physical modifier keys: left_control, left_command, right_command, right_option, left_shift, right_shift |
| `03-hyper.json` | Z and / → Hyper (Shift+Cmd+Opt+Ctrl) on hold (pinky timing from ZMK) |
| `04-meh.json` | X and . → Meh (Shift+Opt+Ctrl) on hold (ring timing from ZMK) |
| `05-cursor.json` | Physical left_option + right-hand keys for vim-style navigation (J, K, L, ; → arrows, M, . / → Home/PgDn/PgUp/End). Uses a variable to distinguish physical left_option from home-row-mod S |
| `06-cursor-disable.json` | Disables physical arrow keys: up, down, left, right (cursor layer provides HJKL navigation) |
| `07-numpad.json` | Physical left_command (tap: tab) + keys for numpad layer (brackets, numbers). Uses variable `physical_left_command` to distinguish from home-row-mod D |
| `08-numbpad-disable.json` | Disables physical number row: \`, 1–0, -, = |
| `09-sympad.json` | Physical right_command (tap: spacebar) + keys for symbol layer (symbols, punctuation). Uses variable `physical_right_command` to distinguish from home-row-mod K |
| `10-funcpad.json` | Left_option + right_command (both held) → F1–F12: 7 8 9 0→F7–F10, J K L ;→F4–F6 F12, M , . N→F1–F3 F11 |
| `11-funcpad-disable.json` | Disables physical F1–F12 (same pattern as numbpad-disable for number row) |
| `12-thumbs.json` | Thumb-key rules: left_control→escape, left_option tap→backspace/hold→cursor, left_command tap→tab/hold→numpad, right_command tap→return/hold→sympad, space→return |
| `13-thumbs-disable.json` | Disables physical keys in the thumb area. Empty by default; add manipulators as needed |

Additional files:
- `apple-magic-keyboard.json` — QMK-format physical keyboard layout definition (used by keymap-drawer for visualization)
- `keymap.yaml` — keymap-drawer layer definitions that produce `keymap.svg` (see note below)
- `build.sh` — Lints, combines configs into `out/karabiner-cags.json`, and draws `out/keymap.svg`. Pass `--install` to also copy to Karabiner.
- `out/` — Build artifacts (gitignored). Contains `karabiner-cags.json` and `keymap.svg`.

The combined JSON is built with **rule order** 14, 00, 12, 13, 10, 11, 05, 06, 07, 08, 09, 01, 02, 03, 04 (see `COMBINE_ORDER` in `build.sh`). Cursor/numpad/sympad key manipulators are evaluated before 02 disables left_command/right_command.

### Why `keymap.yaml` is manually maintained

`keymap.yaml` is a hand-authored file, not generated from the Karabiner JSON configs. While the information overlaps, auto-generating it would be non-trivial: Karabiner configs describe *transformations* (from → to manipulator rules with conditions), while keymap-drawer describes *state* (what each key does on each layer in a positional grid). Translating between the two requires understanding the semantics of each manipulator — parsing tap/hold behavior from `to_if_alone`/`to_if_held_down`, inferring disabled keys, and reconstructing layers from `variable_if` conditions. Given that the layout rarely changes, maintaining `keymap.yaml` by hand is simpler than building a generator.

## Dependencies

- **Karabiner-Elements** — provides `karabiner_cli` at `/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli`
- **python3** — used by `build.sh` to combine JSON configs
- **uv** (`uvx`) — runs `keymap-drawer` for SVG generation without a persistent install

## Adding a New Config File

When adding a new `complex-modifications/*.json` file, it must also be added to the `FILES` array in `build.sh` — that array is the source of truth for which configs are linted, combined, and installed.

## Commands

**Build (lint + combine + draw):**
```
./build.sh
```
Lints all config files with `karabiner_cli --lint-complex-modifications`, combines them into `out/karabiner-cags.json`, and draws `out/keymap.svg` via `keymap-drawer`. If any lint fails, nothing is built.

**Build and install:**
```
./build.sh --install
```
Builds as above, then copies `out/karabiner-cags.json` to `~/.config/karabiner/assets/complex_modifications/`. Enable rules in Karabiner-Elements Preferences → Complex Modifications → Add rule.

**Lint a single file manually:**
```
"/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli" --lint-complex-modifications complex-modifications/<file>.json
```

## Physical Bottom Row

The Magic Keyboard compact bottom row (left to right): **Fn, Control, Option, Command, Space, Command, Option, Left, Up/Down, Right**. After applying these configs:

- **Fn** — untouched (not remappable by Karabiner)
- **Control, Command (both), Option (right), Shift (both)** — disabled (all modifiers provided by home row mods instead)
- **Option (left)** — cursor layer activation (hold for vim-style nav on right hand)
- **Space** — unchanged
- **Arrow keys** — disabled (cursor layer provides HJKL/arrows and M,./→Home/PgDn/PgUp/End)

## Karabiner JSON Format

Each file contains a single JSON object with `"description"` and `"manipulators"` array. Key patterns used:

- **Tap vs hold**: `to_if_alone` for tap output, `to_if_held_down` for modifier activation, `to_delayed_action` for cancellation handling
- **Timing**: `basic.to_if_held_down_threshold_milliseconds` sets per-finger hold thresholds derived from the ZMK companion config (`corne.keymap` tapping-term values)
- **Variable tracking**: `set_variable` / `variable_if` conditions to track physical key state (used in cursor.json to distinguish physical left_option from home-row-mod S)
- **Modifier passthrough**: `"optional": ["any"]` allows combining with other held modifiers

## Companion Config

This config is designed alongside a ZMK Corne keyboard config at `../keyboardhoarders-zmk-config-corne/config/`. Both share the same CAGS modifier philosophy and Hyper/Meh placement (Z/X left, ./slash right). The ZMK config extends further with full layer management (cursor, numpad, symbols, function keys, mouse).
