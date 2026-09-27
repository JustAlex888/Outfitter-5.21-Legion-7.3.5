# Changelog

## 1.0.0 — 2026-09-27

First public Legion 7.3.5 compatibility release based on official **Outfitter 5.21**.

### Legion compatibility

- Returned addon metadata to Interface 70300.
- Added Legion-compatible fallbacks around map/zone APIs used by 5.21.
- Re-enabled the legacy zone-name map already present in upstream 5.21.
- Adapted shapeshift API handling to Legion's return signature.
- Added `C_Calendar` → `CalendarGetDate` fallback where needed.
- Preserved 5.21 Equipment Manager and MC2 custom-event fixes.
- Fixed the confirmed title-menu crash when `GetTitleName()` returns nil/empty.

### Outfit Bar / specialization visibility

- Added display-only specialization filtering for Outfit Bar icons.
- Supports one or more specs per outfit.
- Missing/empty specialization assignment means all specs.
- Filtering never auto-equips an outfit.

### Accessories / trinket sets

- Added dedicated Accessories sets containing only `Trinket0Slot` and `Trinket1Slot`.
- Only one Accessories set is active at a time.
- Clicking the active Accessories set again removes the overlay and restores trinkets from the base complete outfit.
- Added an independent Accessory Bar.
- Main Outfit Bar and Accessory Bar have independent visibility, position, size, opacity, combat opacity, orientation, lock and background settings.
- Accessory Bar defaults to 100% scale.
- Right-click the drag handle to open/close per-bar settings.
- Settings dialog closes on outside click while retaining normal slider interaction and Escape-to-close.

### UI

- Hidden legacy partial-outfit category from the normal user-facing list while preserving its data.
- Widened the main Outfitter window for current RU labels.
- Renamed `Odds 'n ends` in ruRU to `Вещи, не входящие ни в один комплект`.
- Added separate static `Patch Author / Автор патча` page.
- Preserved the original Outfitter animated credits page and original authorship.

### Localization

- Expanded/fixed ruRU UI strings.
- Fixed mixed RU/EN context-menu labels when using the explicit language override.
- Added English specialization names for explicit EN mode on ruRU clients.
- Added `/outfitter lang en`, `/outfitter lang ru`, `/outfitter lang auto`.

### Data compatibility

- SavedVariables names unchanged.
- Existing outfits preserved.
- Existing slash commands/profile architecture preserved.
