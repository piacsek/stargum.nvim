# stargum.nvim — repo guide

A **bubblegum × space** colorscheme forked from Neovim's bundled `elflord`:
glaring nebula pinks and electric cyans over a black deep-space background, with
muted **gold borders**. Full-tilt cybernetic neon.

The default colorscheme is `stargum`. Built as a family (same architecture as
sibling repo `scintilla.nvim`) so sub-variants (e.g. a light variant) can be
added later as `stargum-<variant>`.

- Repo: https://github.com/piacsek/stargum.nvim
- Aesthetic anchor: nebula gradient pink ↔ cyan with violet in between, gold edge.

## Architecture

- `lua/stargum/init.lua` — shared core. `M.apply(name, palette)` loads elflord
  as a base, then drives the editor base (Normal, core syntax, line numbers,
  cursorline, selection, search), surfaces (floats, statusline, tabs, popups),
  treesitter and LSP groups from the palette. `M.load(variant)` requires
  `stargum.palettes.<variant>` and applies it — the default variant `stargum`
  applies as colorscheme `stargum`; any other applies as `stargum-<variant>`.
- `lua/stargum/palettes/<variant>.lua` — a palette table. Every palette must
  define the full semantic key contract (see `stargum.lua` for the canonical
  list: surfaces, text, syntax, accents). Optional keys: `cursor` (overrides the
  `Cursor` block color, else derives from `string`), `cursor_text` (the glyph
  under the cursor — must contrast the block: light on a dark cursor, dark on a
  light one; falls back to `bg`), `bg_statusline` (a dedicated
  StatusLine background, else `bg_active`), `fg_statusline` (StatusLine text,
  else `fg_bright` — e.g. dark text on a bright bar), `diag_error`/`diag_warn`/
  `diag_info`/`diag_hint` (diagnostic fg colors; fall back to keyword/accent/
  type/comment), and `ansi` (a 0–15-keyed table overriding `g:terminal_color_*`).

### Diagnostics on the pink statusline

Neovim 0.12's default statusline embeds `vim.diagnostic.status()` ("E:17 …"),
colored with the `DiagnosticSign*` groups. Red doesn't read on the bright-pink
`bg_statusline`, and giving the sign groups a bg paints a disruptive segment on
the bar (`%#group#` applies the group's bg). So the core sets `DiagnosticSign*`
to `{ fg = fg_statusline }` (near-white, no bg): the count blends into the bar
and reads. Trade-off: the (black) signcolumn signs are near-white too, losing
per-severity color there — but `DiagnosticVirtualText*` / `DiagnosticUnderline*`
keep the vivid `diag_*` hues, so inline severity color is preserved. This is a
deliberate consequence of the bright bar; revisit if `bg_statusline` ever goes
dark (then vivid `diag_*` signs read fine and the override can be dropped).
- `colors/stargum.lua` — one line: `require("stargum").load("stargum")`.

Adding a variant = a new palette file + a one-line colors file. No core changes.

## Base: elflord (and its quirks the core must neutralize)

stargum forks Neovim's bundled `elflord` (was `zaibatsu` originally). elflord's
neon-primary palette suits the glaring look, but its group structure differs —
the core explicitly fixes these, so don't remove those lines:

- **`Function` is standalone white**, NOT linked to `Identifier` (zaibatsu linked
  it). Core sets `Function = func`.
- **`Operator` is a glaring pure-red `#ff0000`.** Core sets `Operator = fg` so
  `=`, `=>`, `|>` aren't red.
- **`Conditional → Repeat`, and `Repeat` is standalone white** (does NOT fold
  into `Statement`), so `if/else/for/while` would render white. Core sets both
  `Repeat` and `Conditional` to `keyword`.
- **`SpecialKey` is glaring cyan** (whitespace/listchars). Core sets it to
  `fg_muted`.
- What still works like zaibatsu: `String/Number/Boolean/Float → Constant`,
  `Keyword/Label → Statement`, `Typedef/Structure/StorageClass → Type` — so
  setting those parents from the palette is enough.

If you ever change the base again, re-audit which legacy groups the new base
leaves unlinked or off-palette and neutralize them here.

## The gold border (signature)

stargum's defining trait vs. scintilla: a dedicated **`border`** palette key
routes `FloatBorder`, `WinSeparator`, `VertSplit`, and WhichKey borders to a
**muted gold** (`#d2ab5a` in the default) — not too bright, not too dark. It
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

`fg_visual` is **optional** and the default omits it: with no fg override the
Visual selection only sets `bg_visual`, so selected text keeps its per-token
syntax colors instead of flattening to one flat color. This means `bg_visual`
must be a dark, low-saturation surface the vivid syntax hues read on (the default
is a dark violet `#3d2c5a`) — a bright selection bg would swallow same-hue tokens.
Only set `fg_visual` for a light selection that genuinely needs dark text.

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

- **Never patch downloaded/installed library code** (anything under
  `~/.local/share/nvim/site/pack/.../opt/`, including sibling repos like
  `ghostty-mirror.nvim`). It's read-only from stargum's perspective — changes
  there get clobbered on update and aren't tracked. Achieve the result through
  config the user owns (e.g. ghostty-mirror's per-theme `overrides` in
  `~/dotfiles/nvim/lua/core/plugins.lua`) or, if a real library feature is
  missing, raise it as a change to that repo separately — don't edit the
  installed copy in place.
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

## Sample screenshots (README gallery)

The README's Showcase section has a `###` sub-section per variant — a flower/star
emoji + `` `stargum[-<variant>]` `` heading, then a two-column `tsx | ex` table
holding `samples/screenshots/<variant>-tsx.png` and `<variant>-ex.png`, each
`samples/showcase.*` rendered with treesitter highlighting. **Whenever a change
visibly alters the theme** (a palette edit, a new variant, or any shared-core
change that shifts colors), regenerate the gallery so the README stays truthful:

```sh
samples/render.sh            # all variants (auto-discovered from palettes/)
samples/render.sh stargum    # only the named ones
```

The script drives `nvim :TOhtml` → headless Google Chrome → ImageMagick (no live
GUI screenshot). The default palette `stargum` renders as colorscheme `stargum`;
other variants render as `stargum-<variant>`. When you **add a variant**, also add
a `###` sub-section to the README. When you **add a syntax construct worth
showing**, extend the two `showcase.*` files (keep them exercising the full set:
modules, functions, keys/atoms, strings, types, constants, numbers, comments) and
re-run. Commit the regenerated PNGs alongside the palette change.

## Ghostty port

Port to Ghostty via the `port-nvim-theme-to-ghostty` skill once a palette
changes. Ghostty theme files live in `~/dotfiles/ghostty-themes/`, named after
the nvim colorscheme. Switching the nvim colorscheme writes `theme = <name>` to
`~/.config/ghostty/theme-current` and reloads Ghostty (logic in
`piacsek/ghostty-mirror.nvim`). Add a `-light` variant file if/when a light
background is built.

**ghostty-mirror caches the generated theme** at `~/.config/ghostty/themes/
<name>` (and tmux at `~/.config/tmux/themes/<name>.conf`) and **does NOT
regenerate it on a plain `:colorscheme`** — it reuses the cached file. So a
palette change to any mirrored surface (`Normal`, `Cursor`, `Visual`, `bg`, or
any `terminal_color_*`/`ansi`) silently does NOT reach the terminal until you
regenerate. After such a change, run **`:ThemeToGhostty`** (and `:ThemeToTmux`)
to rewrite the cache from live highlights and reload — or headless:

```sh
nvim --headless -c "colorscheme stargum" -c "ThemeToGhostty" -c "qa"
```

(`:ThemeCacheClear` deletes all generated theme files if you want a clean
regen.) The README gallery is unaffected — it renders syntax, not `:terminal`.

## Install / dev loop

Develop in `~/projects/stargum.nvim`. Consumed via `vim.pack` from
`piacsek/stargum.nvim`; the installed copy lives at
`~/.local/share/nvim/site/pack/core/opt/stargum.nvim`. After pushing, the
installed clone can be fast-forwarded (`git fetch && git checkout <sha>`) —
`vim.pack.update()` opens a confirmation buffer that must be `:w`-saved to apply.
