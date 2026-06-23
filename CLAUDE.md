# stargum.nvim — repo guide

A **bubblegum × space** colorscheme forked from Neovim's bundled `zaibatsu`:
nebula pinks and electric cyans over a deep-space indigo background, with muted
**gold borders**. Cybernetic/neon energy without going full synthwave.

The default colorscheme is `stargum`. Built as a family (same architecture as
sibling repo `scintilla.nvim`) so sub-variants (e.g. a light variant) can be
added later as `stargum-<variant>`.

- Repo: https://github.com/piacsek/stargum.nvim
- Aesthetic anchor: nebula gradient pink ↔ cyan with violet in between, gold edge.

## Architecture

- `lua/stargum/init.lua` — shared core. `M.apply(name, palette)` loads zaibatsu
  as a base, then drives the editor base (Normal, core syntax, line numbers,
  cursorline, selection, search), surfaces (floats, statusline, tabs, popups),
  treesitter and LSP groups from the palette. `M.load(variant)` requires
  `stargum.palettes.<variant>` and applies it — the default variant `stargum`
  applies as colorscheme `stargum`; any other applies as `stargum-<variant>`.
- `lua/stargum/palettes/<variant>.lua` — a palette table. Every palette must
  define the full semantic key contract (see `stargum.lua` for the canonical
  list: surfaces, text, syntax, accents). Optional keys: `cursor` (overrides the
  `Cursor` block color, else derives from `string`), `bg_statusline` (a dedicated
  StatusLine background, else `bg_active`), and `ansi` (a 0–15-keyed table
  overriding `g:terminal_color_*`).
- `colors/stargum.lua` — one line: `require("stargum").load("stargum")`.

Adding a variant = a new palette file + a one-line colors file. No core changes.

## The gold border (signature)

stargum's defining trait vs. scintilla: a dedicated **`border`** palette key
routes `FloatBorder`, `WinSeparator`, `VertSplit`, and WhichKey borders to a
**muted gold** (`#c9a45a` in the default) — not too bright, not too dark. It
falls back to `fg_muted` if a variant omits it, but every stargum variant should
keep a gold (or gold-family) edge — it's the brand. Adjust hue per variant's
background, never drop it to gray.

## Palette philosophy

Each variant must be **diverse** (not monochromatic) AND feel **seamless with
its background**. The working principle (inherited from scintilla): **analogous
harmony anchored on the background's hue, plus a complementary pop for relief and
token separation.**

stargum's default: a **violet-pink core** (keyword = bubblegum pink, func =
orchid, module = violet, special = pink) anchored on the indigo/violet
background, with **cyan as the cool relief** (type = electric cyan, string =
mint-cyan, key = pale cyan). The gold lives only on borders + the gold ANSI/UI
slots, so it reads as structure, not syntax.

When the core drives a group from the palette, dark-on-light tricks only work on
light surfaces — `fg_visual` exists so each variant sets selected-text color
explicitly (the default puts dark plum text on a bright bubblegum selection).
Keep UI-accent colors legible as foreground on dark selected backgrounds.

### Light variants (future)

The core's color math is background-agnostic, so a **light** variant just inverts
which palette roles are pale vs. deep — no core changes. In a light palette:
- **Every syntax + UI-accent color must be deep/saturated** — each is used either
  as a foreground on a light surface or as the dark backdrop behind the light
  `bg` (`Search`→`variable`, `IncSearch`→`func`, `Cursor`→`cursor`). Pale syntax
  would vanish in both roles. Only surfaces, `comment`, `fg_muted`, `fg_dim` go
  light.
- **`fg_bright` is the *darkest* text**, not the lightest — it's the statusline
  foreground on the light `bg_active`.
- **Pin `ansi[0]` to a dark color** — the core lifts slot 0 to `bg_dim` for
  dark-variant terminal-border contrast, but on a light variant `bg_dim` is pale
  and would make terminal "black" invisible.
- The gold `border` likely needs to deepen so it reads on a light surface.

The Ghostty port (`port-nvim-theme-to-ghostty` skill, `&background=light` prefers
`<name>-light`) and delta/lazygit theming key off the `-light` suffix.

## Terminal (ANSI) palette

The core sets **all 16** `g:terminal_color_0..15` so every variant exposes a
complete, stargum-owned ANSI palette to `:terminal` and to anything mirroring it
(e.g. ghostty-mirror). Slot 0 (ANSI black) is always lifted to `bg_dim` so
`:terminal` borders stay visible. The core default maps each ANSI slot to its
closest semantic key, but because the syntax palette is anchored on one hue
family it can't supply a believable red/green/blue across the board — so every
shipped variant defines a full `ansi = { [1]=…, … [15]=… }` table (omit `[0]`)
with hand-tuned, recognizable ANSI hues (error-red, success-green) that read in a
terminal even on a pink-violet theme. ANSI changes don't affect the README
gallery (those render syntax, not `:terminal`), but they do change generated
Ghostty theme files — regenerate via the mirror after editing.

## Hard rules

- Each palette owns its own syntax hues — there is no shared syntax module.
- **Keep the gold border.** See "The gold border" above.
- **Keep this file current.** Whenever we agree on a new convention or guideline,
  add it here in the same change.

## Verifying a change

Headless render of any variant:

```sh
nvim --headless --clean --cmd "set rtp+=$PWD" -c "colorscheme stargum" \
  -c "redir => m | for g in ['Normal','Statement','Type','@function','@module','FloatBorder','Visual','PmenuSel'] | silent exe 'hi '.g | endfor | redir END | echo m" \
  -c "qa"
```

Confirm: syntax categories are distinct, `FloatBorder` is gold, `Visual`
selected-text is readable, and the UI accent reads on dark selections.

## Ghostty port

Port to Ghostty via the `port-nvim-theme-to-ghostty` skill once a palette
changes. Ghostty theme files live in `~/dotfiles/ghostty-themes/`, named after
the nvim colorscheme. Switching the nvim colorscheme writes `theme = <name>` to
`~/.config/ghostty/theme-current` and reloads Ghostty (logic in
`piacsek/ghostty-mirror.nvim`). Add a `-light` variant file if/when a light
background is built.

## Install / dev loop

Develop in `~/projects/stargum.nvim`. Consumed via `vim.pack` from
`piacsek/stargum.nvim`; the installed copy lives at
`~/.local/share/nvim/site/pack/core/opt/stargum.nvim`. After pushing, the
installed clone can be fast-forwarded (`git fetch && git checkout <sha>`) —
`vim.pack.update()` opens a confirmation buffer that must be `:w`-saved to apply.
