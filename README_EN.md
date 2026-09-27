# Outfitter 5.21 — Legion 7.3.5

A compatibility branch of **Outfitter 5.21** for **World of Warcraft Legion 7.3.5 / Interface 70300**.

Original Outfitter was developed by **John Stephen / Mundocani**. This branch does not claim authorship of the original project. It is based on the official Outfitter 5.21 source and contains documented Legion compatibility fixes and additional quality-of-life features.

**Compatibility patch author:** JustAlex888  
**Original author:** John Stephen / Mundocani  
**Upstream:** https://github.com/Mundocani/Outfitter — tag `5.21`  
**Original license:** MIT

## Changes

### Legion 7.3.5 compatibility

- restored `Interface 70300` compatibility;
- Legion fallbacks around map/zone and calendar APIs;
- Legion-compatible shapeshift API handling;
- fixed the confirmed menu crash when `GetTitleName()` returns `nil`;
- retained useful Equipment Manager and custom-event fixes from official 5.21.

### Specialization filtering for Outfit Bar

An outfit can be assigned to one or more specializations.

The filter changes **visibility only**. It never auto-equips an outfit.

Legacy outfits without specialization assignments remain visible for all specs.

### Accessories sets

A dedicated set type was added for the two trinket slots:

- only `Trinket0Slot` and `Trinket1Slot` are stored;
- only one Accessories set is active at a time;
- clicking the active Accessories set again removes the overlay and restores the base complete outfit's trinkets;
- no need to duplicate every complete outfit just to use another trinket pair.

### Independent Accessory Bar

The Accessory Bar is independent from the main Outfit Bar:

- position;
- scale;
- opacity;
- combat opacity;
- horizontal/vertical layout;
- position lock;
- background;
- visibility.

Right-click a grey drag handle to open bar settings. Right-click again, press `Esc`, or click outside the dialog to close it.

### UI and localization

- expanded/fixed ruRU localization;
- improved the unused-equipment category label;
- legacy partial outfits are preserved in data but hidden from the normal primary list;
- added a separate Patch Author page;
- preserved the original animated Outfitter author/credits page;
- fixed mixed RU/EN action labels in context menus.

Outfitter-only localization override commands:

```text
/outfitter lang en
/outfitter lang ru
/outfitter lang auto
```

These commands reload the UI and do not change the WoW client locale.

## Installation

1. Exit WoW.
2. Extract the release ZIP into `World of Warcraft/Interface/AddOns/`.
3. Confirm this file exists:
   `Interface/AddOns/Outfitter/Outfitter.toc`.
4. Do not delete WTF/SavedVariables by default.

See [INSTALL.md](INSTALL.md).

## SavedVariables compatibility

Unchanged:

- `gOutfitter_Settings`;
- `gOutfitter_GlobalSettings`;
- addon folder name `Outfitter`;
- existing slash commands;
- normal Outfitter settings architecture.

## Screenshots

### Russian UI

![Outfitter 5.21 Legion 1.0 — Russian UI](docs/screenshots/outfitter-ru.png)

### English UI

![Outfitter 5.21 Legion 1.0 — English UI](docs/screenshots/outfitter-en.png)

> Note: user-created outfit names, item names, and other game-provided data follow the WoW client locale and may remain in the client language even when the Outfitter UI override is set to English.

## Attribution and licenses

The original Outfitter project remains credited to its original author. The compatibility project only claims its own patch modifications.

- [ATTRIBUTION.md](ATTRIBUTION.md)
- [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)
- [LICENSE](LICENSE)

The original upstream MIT file is also preserved unchanged at `Outfitter/LICENSE`.

## Limitations

Target: **WoW Legion 7.3.5 / Interface 70300**. Modern Retail/Classic/BfA compatibility is not claimed.

See [KNOWN_LIMITATIONS.md](KNOWN_LIMITATIONS.md).
