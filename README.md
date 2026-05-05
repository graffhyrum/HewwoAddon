# HewwoAddon

World of Warcraft **retail** UI add-on: movable summary frame, toggles for cast and currency tracking, and a minimap data broker button.

## Features

- **Main window**: character name / level, total successful casts (optional), aggregated gold/silver/copper from loot text (optional). Slash: `/hewwoaddon` or `/hewwo`.
- **Settings**: checkboxes for cast tracking and currency tracking. Slash: `/hs`.
- **Minimap**: broker entry — left-click opens main frame, right-click opens settings (`Settings.lua` uses LibDataBroker + LibDBIcon).

## Requirements

- Retail client matching `## Interface: 120005` in [`HewwoAddon.toc`](HewwoAddon.toc) (bump `.toc` when Blizzard updates the addon API slot).
- Local **`libs/`** tree (see below). This repository **does not** ship `libs/`; those libraries have their **own licenses** when you vendor them.

## Libraries (`libs/`)

Create `libs/` inside the add-on folder and install:

| Path | Purpose |
|------|--------|
| `libs/Ace3/AceAddon-3.0/AceAddon-3.0.lua` | Ace addon bootstrap |
| `libs/Ace3/AceDB-3.0/AceDB-3.0.lua` | Minimap button position DB |
| `libs/LibDBIcon-1.0/` | Minimap icon (load via `embeds.xml` — pulls its own embed dependencies such as LibDataBroker) |

Typical sources: [WoWAce](https://www.wowace.com/) / CurseForge packages for **Ace3** and **LibDBIcon-1.0**. Lay out folders so paths match [`HewwoAddon.toc`](HewwoAddon.toc).

## Development / quick setup (Windows)

Scripted setup is **Windows-only** (retail WoW).

**Layout:** Install add-ons under `<wow-install-folder>\_retail_\Interface\AddOns\` as **sibling folders** — for example `HewwoAddon\`, `Ace3\`, and `LibDBIcon-1.0\` next to each other.

**Optional dev tools:** [just](https://github.com/casey/just) (runs the recipes in this repo’s `justfile`) and **Git** (for `just update`). Symlink creation needs **Developer Mode** or an elevated PowerShell session; see [Enable developer mode on Windows](https://learn.microsoft.com/en-us/windows/apps/get-started/enable-developer-mode).

From a shell in the `HewwoAddon` folder:

| Command | What it does |
|---------|----------------|
| `just setup` | Creates `libs\` and **directory symlinks** with **relative targets** `..\..\Ace3` and `..\..\LibDBIcon-1.0` (resolved from `HewwoAddon\libs\` up to `AddOns\`, then into each library). Implementation: [`scripts/hewwo-libs.ps1`](scripts/hewwo-libs.ps1). |
| `just update` | `git pull --ff-only`, then `just setup`. |
| `just check` | Verifies `libs\Ace3\AceAddon-3.0\AceAddon-3.0.lua` and `libs\LibDBIcon-1.0\embeds.xml` exist. |

**Without `just`:** Create the same symlinks manually (or copy trees into `libs\` if you accept duplication). The relative link layout matches `just setup`.

## Install

1. Install **Ace3** and **LibDBIcon-1.0** under `_retail_\Interface\AddOns\` (see table above), then populate `HewwoAddon\libs\` via `just setup` or equivalent symlinks.
2. Ensure the `HewwoAddon` folder lives under `_retail_\Interface\AddOns\`.
3. Enable **Hewwo Addon** on the character select **AddOns** list.

## Blizzard policy & disclaimer

Add-ons must follow Blizzard's requirements, including:

- Distributed **free**, no charges for functionality.
- Code **visible** (not hidden or obfuscated).
- No in-game solicitation of donations; no disruptive or disallowed behaviour per policy.

Official references:

- [UI Add-On Development Policy (US)](https://us.forums.blizzard.com/en/wow/t/ui-add-on-development-policy/24534)
- [WoW User Interface Add-On Development Policy (EU)](https://eu.forums.blizzard.com/en/wow/t/wow-user-interface-add-on-development-policy/1642)
- [Blizzard Legal](https://www.blizzard.com/legal/)

This project is **not** affiliated with Blizzard Entertainment. WoW®, World of Warcraft®, and Blizzard marks are theirs. Users are responsible for complying with the game’s Terms of Use, EULA, and add-on policy.

## License

Original Lua in this repo is under the [MIT License](LICENSE). Third-party code under `libs/` is excluded from this repo and remains under its upstream licenses when you install it.
