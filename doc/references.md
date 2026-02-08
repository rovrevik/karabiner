- [Erlendms Karabiner actions - Home row mods](https://github.com/Erlendms/karabiner-actions)
- [rovrevik ZMK keymap](https://github.com/rovrevik/keyboardhoarders-zmk-config-corne/blob/master/config/corne.keymap)

## Comparison: this repo vs Erlendms home row mods (CAGS)

Relevant Erlendms file: [home_row_mods-ct_o_c_s.json](https://github.com/Erlendms/karabiner-actions/blob/main/actions/home_row_mods-ct_o_c_s.json) — same CAGS mapping (A=Ctrl, S=Option, D=Command, F=Shift left; J/K/L/; mirrored right).

### Same

- **Mapping**: Identical CAGS (Ctrl, Alt/Option, Cmd, Shift) and mirror on the right hand.
- **Combo coverage**: Same simultaneous rules — all four keys, all three-key subsets, and all two-key pairs with `simultaneous_options.key_down_order: "strict"`, and same modifier outputs for each combo.
- **Tap/hold structure**: Single-key rules use `to_if_alone` (letter), `to_if_held_down` (modifier), and `to_delayed_action` with `to_if_canceled` / `to_if_invoked` (vk_none). Both use `halt: true` on the single-key `to_if_alone` and `to_if_held_down` so the key/modifier is consumed.

### Differences

| Aspect | This repo (`01-home_row_mods-cags.json`) | Erlendms (`home_row_mods-ct_o_c_s.json`) |
|--------|------------------------------------------|-------------------------------------------|
| **Hold threshold** | Per-key `basic.to_if_held_down_threshold_milliseconds` (per finger, derived from ZMK `corne.keymap` tapping-term). | No `parameters` — uses Karabiner’s global “To if held down” threshold Same value for every HRM key. |
| **F key on cancel** | `to_if_canceled`: `[{"halt": true, "key_code": "f"}]` — cancelling the hold outputs F with halt. | `to_if_canceled`: `[{"key_code": "f"}]` — no halt. |
| **Description** | `01-home_row_mods-cags` | `Home row mods - ctrl, opt, cmd, shift` |

### Summary

Your config is a **superset** of Erlendms’ CAGS home row mods: same logical mapping and same simultaneous-modifier combos, plus per-finger hold timings (faster toward index finger) and a different cancel behavior for F. Erlendms keeps one global threshold and documents that users should tune it in Karabiner-Elements; you bake in ZMK-aligned timings so behaviour is consistent without touching the global setting.
