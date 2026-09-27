# Third-party notices

Outfitter 5.21 includes embedded libraries from several authors/projects. This compatibility branch preserves those bundled libraries and their in-file notices unless a Legion compatibility change is explicitly documented.

## Outfitter / MC2 libraries

The following bundled MC2 libraries include MIT license files in their upstream Outfitter 5.21 directories:

- MC2AddonLib — Copyright 2018 John Stephen — MIT
- MC2DebugLib — Copyright 2018 John Stephen — MIT
- MC2EventLib — Copyright 2018 John Stephen — MIT
- MC2SchedulerLib — Copyright 2018 John Stephen — MIT
- MC2UIElementsLib — Copyright 2018 John Stephen — MIT
- MC2ItemLinkLib — Copyright 2018 Mundocani — MIT
- MC2ItemStatsLib — Copyright 2018 Mundocani — MIT
- MC2TooltipLib — Copyright 2018 Mundocani — MIT

Their original `LICENSE` files remain in the corresponding library folders.

## LibStub

`Libraries/LibStub.lua` states that LibStub is placed in the public domain and credits Kaelten, Cladhaire, ckknight, Mikk, Ammo, Nevcairiel and joshborke.

## CallbackHandler-1.0

`Libraries/CallbackHandler-1.0.lua` is an embedded Ace3 callback library. Historical project metadata identifies CallbackHandler-1.0 as BSD-licensed. The bundled source is preserved from official Outfitter 5.21.

Project reference: https://www.curseforge.com/wow/addons/callbackhandler

## LibDataBroker-1.1

`Libraries/LibDataBroker-1.1.lua` is preserved from official Outfitter 5.21 and is not modified by this compatibility project.

The LibDataBroker project page is marked “All Rights Reserved”, but the project’s own documentation explicitly instructs addon authors to **hard-embed LDB in their addon** rather than treating it as a standalone no-lib dependency. This release follows that documented embedding model and does not redistribute LibDataBroker as a standalone product.

Project/source references:
- https://github.com/tekkub/libdatabroker-1-1
- https://www.wowace.com/projects/libdatabroker-1-1

## LibBabble

- `LibBabble-3.0.lua` states that LibBabble-3.0 is placed in the public domain; credit: ckknight.
- `LibBabble-SubZone-3.0.lua` declares MIT.
- `LibBabble-Inventory-3.0.lua` declares MIT.

The original headers are preserved.

## LibTipHooker-1.1

`Libraries/LibTipHooker-1.1.lua` identifies:

- Author: Whitetooth
- License: GNU LGPL v3

The source is distributed in Lua source form and its original header is preserved. Copies of LGPL v3 and GPL v3 are included in `LICENSES/`.

## LibDropdown

`Libraries/LibDropdown-1.0.lua` is the Outfitter-bundled modified dropdown library (`LibDropdownMC-1.0`). The original LibDropdown project is published under the MIT license; the Outfitter-specific modifications are part of the upstream Outfitter 5.21 source line.

Project reference: https://www.curseforge.com/wow/addons/libdropdown-1-0

## UTF-8 library

`Libraries/UTF8/utf8.lua` contains a BSD-style redistribution notice:

- Copyright 2006–2007 Kyle Smith

The full original copyright, conditions and disclaimer remain embedded in the source file and are redistributed unchanged.

## Scope

This notice is informational and does not replace the license text or copyright notice embedded in each third-party component. If a bundled component has its own license text or header, that original text controls that component.
