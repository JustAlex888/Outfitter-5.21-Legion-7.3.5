# Installation

## Requirements

- World of Warcraft **Legion 7.3.5**
- Interface **70300**

This build is not intended for modern Retail/BfA clients.

## Install

1. Exit World of Warcraft.
2. Back up your current `Interface/AddOns/Outfitter` folder if desired.
3. Extract the release ZIP directly into:

   `World of Warcraft/Interface/AddOns/`

4. Confirm the final path is:

   `World of Warcraft/Interface/AddOns/Outfitter/Outfitter.toc`

5. Start the game and enable Outfitter.

## Updating from an older Outfitter

Do **not** delete your WTF/SavedVariables by default.

The compatibility branch preserves:

- `gOutfitter_Settings`
- `gOutfitter_GlobalSettings`
- existing outfit data
- slash commands and normal Outfitter profile/settings architecture

Replace only the `Interface/AddOns/Outfitter` addon folder.

## UI language test/override

The addon can temporarily force its own UI strings without changing the WoW client locale:

- `/outfitter lang en` — English Outfitter UI
- `/outfitter lang ru` — Russian Outfitter UI
- `/outfitter lang auto` — follow the WoW client locale

These commands reload the UI.

## Reset bars

- `/outfitter reset bar` — reset main Outfit Bar position
- `/outfitter reset accessorybar` — reset Accessory Bar position
