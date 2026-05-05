## Learned User Preferences

- For libraries CurseForge (or similar) installs under `Interface\AddOns\<LibName>`, satisfy `HewwoAddon\libs\` by creating directory symlinks **from** `HewwoAddon\libs\<LibName>` **to** that shared folder; do **not** move or replace the canonical `AddOns\<LibName>` tree with a link into `HewwoAddon\libs` (breaks other addons / managers).
- Keep incremental transcript processing via `.cursor/hooks/state/continual-learning-index.json` when running continual-learning memory updates.

## Learned Workspace Facts

- **Hewwo Addon** is a World of Warcraft **retail** UI addon in this folder; addon Lua is MIT-licensed; `libs/` is gitignored and README documents vendoring or symlink setup.
- Shared dependencies (e.g. Ace3, LibDBIcon-1.0) are often installed once under `...\Interface\AddOns\`; this project’s `.toc` can load them via `libs\` using symlinks from `HewwoAddon\libs\` to those paths.
- Public Git repo: `https://github.com/graffhyrum/HewwoAddon`.
