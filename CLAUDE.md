# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Karabiner-Elements complex modification configs for macOS keyboard customization. The system implements CAGS home row mods, Hyper/Meh modifiers, and cursor navigation — mirroring a ZMK Corne split keyboard layout on a standard keyboard.

## File Structure

All configs live in `complex-modifications/`. Files are numbered to indicate intended rule ordering in the Karabiner profile (earlier rules take priority):

| File | Purpose |
|------|---------|
| `00-simple-mods.json` | Caps→Escape, disable physical keys (escape, left_control, left_command, right_command, right_option, arrow keys) |
| `01-cursor.json` | Physical left_option + right-hand keys for vim-style navigation (JKLD→arrows, M,./ →Home/PgDn/PgUp/End). Uses a variable to distinguish physical left_option from home-row-mod S |
| `02-home_row_mods-cags.json` | CAGS home row mods: A=Ctrl, S=Alt, D=Cmd, F=Shift (left); J=Shift, K=Cmd, L=Alt, ;=Ctrl (right). Includes all simultaneous multi-key modifier combos |
| `03-hyper-220ms.json` | Z and / → Hyper (Shift+Cmd+Opt+Ctrl) on 220ms hold |
| `04-meh-220ms.json` | X and . → Meh (Shift+Opt+Ctrl) on 220ms hold |

`karabiner-actions/` contains alternative/experimental configs (R/U as Meh, different timing variants) sourced from the Erlendms karabiner-actions repo.

## Karabiner JSON Format

Each file contains a single JSON object with `"description"` and `"manipulators"` array. Key patterns used:

- **Tap vs hold**: `to_if_alone` for tap output, `to_if_held_down` for modifier activation, `to_delayed_action` for cancellation handling
- **Timing**: `basic.to_if_held_down_threshold_milliseconds` sets hold threshold (220ms for Hyper/Meh)
- **Variable tracking**: `set_variable` / `variable_if` conditions to track physical key state (used in cursor.json to distinguish physical left_option from home-row-mod S)
- **Modifier passthrough**: `"optional": ["any"]` allows combining with other held modifiers

## Companion Config

This config is designed alongside a ZMK Corne keyboard config at `../keyboardhoarders-zmk-config-corne/config/`. Both share the same CAGS modifier philosophy and Hyper/Meh placement (Z/X left, ./slash right). The ZMK config extends further with full layer management (cursor, numpad, symbols, function keys, mouse).
