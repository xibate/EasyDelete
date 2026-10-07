<div align="center">

<img src=".github/icon.png" alt="Easy Delete icon" width="128">

# Easy Delete

**Stop typing “DELETE”. Just click Yes.**

[![CurseForge downloads](https://img.shields.io/curseforge/dt/96313?logo=curseforge&label=CurseForge&color=F16436)](https://www.curseforge.com/wow/addons/easy-delete)
[![Latest release](https://img.shields.io/github/v/release/xibate/EasyDelete?label=release)](https://github.com/xibate/EasyDelete/releases/latest)

</div>

---

Deleting a valuable item in World of Warcraft makes you type the word **DELETE** into the confirmation box every time. Easy Delete removes that step: the text box is hidden, the **Yes** button is ready to click, and the item you are about to destroy is shown in its place, so you can still see what you are getting rid of.

## Features

- **One click to delete.** No more typing “DELETE” for rare, epic or quest items.
- **See what you delete.** The item link appears in the confirmation popup instead of the empty text box.
- **Every version of the game.** One download works on Retail, all Classic flavors and WoW Forever.
- **Zero setup.** No options, no slash commands, no saved variables. Install it and it works.
- **Tiny and lightweight.** A single small Lua file that only wakes up when a delete popup opens.

## Supported game versions

| Game version | Patch | TOC file |
| --- | --- | --- |
| Retail (Midnight) | 12.1.0 | `EasyDelete.toc` |
| WoW Forever | 1.60.1 | `EasyDelete_Camelot.toc` |
| Mists of Pandaria Classic | 5.5.4 | `EasyDelete_Mists.toc` |
| Wrath of the Lich King Classic / Titan | 3.4.5 / 3.80.2 | `EasyDelete_Wrath.toc` |
| Burning Crusade Anniversary | 2.5.6 | `EasyDelete_TBC.toc` |
| Classic Era | 1.15.9 | `EasyDelete_Vanilla.toc` |

The game automatically loads the right `.toc` file for the client you are playing on.

## Installation

**With the CurseForge app (recommended):** search for **Easy Delete** and click *Install*. Updates arrive automatically.

**Manually:**

1. Download the latest `EasyDelete-vX.Y.zip` from [CurseForge](https://www.curseforge.com/wow/addons/easy-delete/files) or [GitHub Releases](https://github.com/xibate/EasyDelete/releases/latest).
2. Extract it into your AddOns folder, for example:
   - `World of Warcraft\_retail_\Interface\AddOns\`
   - `World of Warcraft\_classic_era_\Interface\AddOns\`
3. You should end up with `Interface\AddOns\EasyDelete\EasyDelete.toc`.
4. Restart the game or type `/reload`.

## How it works

When you drag an item out of your bags to destroy it, the game fires `DELETE_ITEM_CONFIRM` and opens its confirmation popup. If that popup is asking you to type “DELETE”, Easy Delete:

1. hides the text box,
2. enables the **Yes** button, and
3. shows the item link where the text box used to be.

Nothing else in the game is changed, and the item is only deleted when you click **Yes** yourself.

## Localization

The addon name is translated in the AddOns list for English, German, Spanish (EU and LatAm), French, Italian, Korean, Brazilian Portuguese, Russian, and Simplified and Traditional Chinese.

## For maintainers: releasing a new version

Releases are fully automated by [`.github/workflows/release.yml`](.github/workflows/release.yml) using the [BigWigs packager](https://github.com/BigWigsMods/packager):

1. Merge your changes into `master`.
2. Create a release (or push a tag) starting with `v`, for example `v3.1`.
   - `v3.1` is uploaded as a **release**, `v3.1-beta1` as a **beta** and `v3.1-alpha1` as an **alpha**.
3. The workflow builds `EasyDelete-v3.1.zip`, uploads it to CurseForge for every game version found in the `.toc` files, and attaches it to the GitHub release.

The workflow needs a repository secret named `CF_API_KEY` that holds a [CurseForge API token](https://legacy.curseforge.com/account/api-tokens).

After a game patch, update the `## Interface:` line in the matching `.toc` file before tagging a new release.

## Credits

Made by **Xibate** and **Zynx**.

Found a bug or have an idea? [Open an issue](https://github.com/xibate/EasyDelete/issues).
