-- stargum.nvim
-- A bubblegum × space colorscheme forked from Neovim's bundled `elflord`:
-- glaring nebula pinks and electric cyans over a black deep-space background,
-- with muted gold borders. The highlight logic below is shared; each variant
-- supplies its own palette table.
--
-- The palette is a full semantic contract — see lua/stargum/palettes/stargum.lua
-- for the canonical key list. The core drives the editor base (Normal, syntax,
-- line numbers, cursorline, …) from the palette so each variant fully owns its
-- look rather than inheriting elflord's neon-primary defaults. elflord is still
-- loaded first as a base so the long tail of minor groups has sane (and, fitting
-- this theme, already-vivid) defaults.

local M = {}

local function hl(name, opts)
	vim.api.nvim_set_hl(0, name, opts)
end

-- Apply the shared stargum highlight set on top of elflord, using `p` (a
-- palette table) for colors and registering under colorscheme `name`.
function M.apply(name, p)
	-- Inherit elflord as the base, then layer our overrides on top.
	vim.cmd("hi clear")
	if vim.fn.exists("syntax_on") == 1 then
		vim.cmd("syntax reset")
	end
	vim.cmd.runtime("colors/elflord.vim")
	vim.g.colors_name = name

	-- `border` is stargum's signature: float borders and window separators all
	-- read in a muted gold. Falls back to fg_muted so a variant can opt out.
	local border = p.border or p.fg_muted

	-- ── Editor base ─────────────────────────────────────────────────────────
	-- Drive the main surfaces + gutter from the palette so the background tone
	-- follows the variant (elflord hardcodes Normal to cyan-on-black).
	hl("Normal", { fg = p.fg_normal, bg = p.bg })
	hl("NormalNC", { link = "Normal" })
	hl("EndOfBuffer", { fg = p.comment, bg = p.bg })
	hl("NonText", { fg = p.fg_muted, bg = p.bg })
	hl("Conceal", { fg = p.fg_muted })
	hl("SpecialKey", { fg = p.fg_muted }) -- elflord's glaring cyan whitespace/listchars markers
	hl("ColorColumn", { bg = p.bg_colorcolumn })
	hl("CursorLine", { bg = p.bg_cursorline })
	hl("CursorColumn", { bg = p.bg_cursorline })
	hl("CursorLineNr", { link = "CursorLine" }) -- subdue elflord's bold-yellow current line number
	hl("LineNr", { fg = p.comment })
	hl("SignColumn", { fg = p.preproc })
	hl("FoldColumn", { fg = p.preproc })
	hl("Folded", { fg = p.func, bg = p.bg_dim })
	hl("WinSeparator", { fg = border })
	hl("VertSplit", { fg = border })
	hl("Directory", { fg = p.variable })
	-- Cursor block: `cursor` sets the block color, `cursor_text` the glyph under
	-- it (falls back to bg = a dark cut-out). This drives the in-editor block AND,
	-- via ghostty-mirror, the terminal cursor-color/cursor-text.
	hl("Cursor", { fg = p.cursor_text or p.bg, bg = p.cursor or p.string })

	-- Selection / search — elflord uses a grey Visual and reverse-video IncSearch;
	-- set solid palette colors so they read correctly on any background. fg_visual
	-- is OPTIONAL: omit it (the default does) so the selection only sets a bg and
	-- the selected text keeps its per-token syntax colors instead of flattening to
	-- one color. Set it only for a light selection that needs dark text.
	hl("Visual", { fg = p.fg_visual, bg = p.bg_visual })
	hl("Search", { fg = p.bg, bg = p.variable })
	hl("IncSearch", { fg = p.bg, bg = p.func })
	hl("CurSearch", { link = "IncSearch" })

	-- ── Core syntax ─────────────────────────────────────────────────────────
	-- elflord links String/Number/Boolean/Float→Constant, Keyword/Label→Statement,
	-- Typedef/Structure/StorageClass→Type, so setting those parents is enough.
	-- Unlike zaibatsu, elflord does NOT link Function→Identifier (Function is a
	-- standalone white group) and gives Operator a glaring pure-red — both off
	-- our palette, so set them explicitly below.
	hl("Comment", { fg = p.comment })
	hl("Constant", { fg = p.string })
	hl("Identifier", { fg = p.variable })
	hl("Function", { fg = p.func })
	hl("Statement", { fg = p.keyword })
	-- elflord links Conditional→Repeat and leaves Repeat a standalone white (it
	-- does NOT fold into Statement), so if/else/for/while would go white. Pull the
	-- whole keyword family back onto `keyword`.
	hl("Repeat", { fg = p.keyword })
	hl("Conditional", { fg = p.keyword })
	hl("Operator", { fg = p.fg })
	hl("Type", { fg = p.type })
	hl("Special", { fg = p.special })
	hl("PreProc", { fg = p.preproc })

	-- ── Surfaces zaibatsu leaves bright/white ───────────────────────────────
	-- Statusline: tone down zaibatsu's bright white statusline. Optional
	-- `bg_statusline` lets a variant give the bar its own surface (falls back to
	-- bg_active), and `fg_statusline` its own text color (falls back to fg_bright)
	-- — e.g. dark text on a bright bar.
	hl("StatusLine", { fg = p.fg_statusline or p.fg_bright, bg = p.bg_statusline or p.bg_active })
	hl("StatusLineNC", { fg = p.fg_dim, bg = p.bg_dim })

	-- ── Terminal (ANSI) palette ─────────────────────────────────────────────
	-- Drive all 16 g:terminal_color_* from the palette so every variant exposes
	-- a complete, stargum-owned ANSI set. Slot 0 (ANSI black) is lifted to bg_dim
	-- so :terminal borders (lazygit, etc.) keep contrast against the editor bg.
	-- The default maps standard ANSI slots to their closest semantic palette
	-- entry; a palette may override any slot via its `ansi` table (keyed 0–15,
	-- partial is fine). Each shipped variant defines a full `ansi` so its terminal
	-- hues stay recognizable even though the syntax palette is anchored on one
	-- hue family.
	local ansi = {
		[0] = p.bg_dim,    -- black (lifted off bg for visible borders)
		[1] = p.type,      -- red
		[2] = p.special,   -- green
		[3] = p.string,    -- yellow
		[4] = p.preproc,   -- blue
		[5] = p.module,    -- magenta
		[6] = p.key,       -- cyan
		[7] = p.fg,        -- white
		[8] = p.fg_muted,  -- bright black
		[9] = p.keyword,   -- bright red
		[10] = p.func,     -- bright green
		[11] = p.accent,   -- bright yellow
		[12] = p.match,    -- bright blue
		[13] = p.constant, -- bright magenta
		[14] = p.variable, -- bright cyan
		[15] = p.fg_bright, -- bright white
	}
	if p.ansi then
		ansi = vim.tbl_extend("force", ansi, p.ansi)
	end
	for i = 0, 15 do
		vim.g["terminal_color_" .. i] = ansi[i]
	end

	-- Floats (LSP hover, diagnostics, plugin popups, snacks, etc.)
	hl("NormalFloat", { fg = p.fg, bg = p.bg_float })
	hl("FloatBorder", { fg = border, bg = p.bg_float })
	hl("FloatTitle", { fg = p.accent, bg = p.bg_float, bold = true })

	-- Completion popup (LSP, nvim-cmp, blink)
	hl("Pmenu", { fg = p.fg, bg = p.bg_float })
	hl("PmenuSel", { fg = p.accent, bg = p.bg_active, bold = true })
	hl("PmenuKind", { fg = p.fg_muted, bg = p.bg_float })
	hl("PmenuKindSel", { fg = p.fg_muted, bg = p.bg_active })
	hl("PmenuExtra", { fg = p.fg_muted, bg = p.bg_float })
	hl("PmenuExtraSel", { fg = p.fg_muted, bg = p.bg_active })
	hl("PmenuMatch", { fg = p.match, bg = p.bg_float, bold = true })
	hl("PmenuMatchSel", { fg = p.match, bg = p.bg_active, bold = true })
	hl("PmenuSbar", { bg = p.bg_dim })
	hl("PmenuThumb", { bg = p.fg_muted })

	hl("VisualNOS", { fg = p.fg, bg = p.bg_active })
	hl("WildMenu", { fg = p.accent, bg = p.bg_active, bold = true })
	hl("TabLine", { fg = p.fg_dim, bg = p.bg_dim })
	hl("TabLineSel", { fg = p.accent, bg = p.bg_active, bold = true })
	hl("TabLineFill", { bg = p.bg_inactive })
	hl("WinBar", { fg = p.fg, bg = p.bg_winbar })
	hl("WinBarNC", { fg = p.fg_muted, bg = p.bg_inactive })
	hl("MsgArea", { fg = p.fg, bg = p.bg })

	-- Message-area prompts (hit-enter "Press ENTER…", :messages, mode indicator).
	-- zaibatsu's bright cyan/green are tuned for a dark bg and leak through on
	-- light variants; drive them from the palette.
	hl("MoreMsg", { fg = p.variable })
	hl("Question", { fg = p.special })
	hl("ModeMsg", { fg = p.bg, bg = p.special })
	hl("WarningMsg", { fg = p.keyword })

	-- WhichKey-style overlays (covers folke/which-key.nvim and snacks variants).
	hl("WhichKeyFloat", { bg = p.bg_float })
	hl("WhichKeyBorder", { fg = border, bg = p.bg_float })

	-- MatchParen: zaibatsu uses reverse video which obscures the cursor.
	hl("MatchParen", { fg = p.accent, bg = p.bg_active, bold = true })

	-- ── Treesitter ──────────────────────────────────────────────────────────
	-- Distinguish object keys from value identifiers (JSON, JS/TS, Lua tables, etc.).
	hl("@variable.member", { fg = p.key })
	hl("@property", { fg = p.key })
	-- Elixir atoms / map keys (`:foo`, `%{key: val}`).
	hl("@string.special.symbol", { fg = p.key })

	-- Function/method calls + declarations. Distinct from variables, strings,
	-- keys, keywords. Covers JS/TS + Elixir.
	hl("@function", { fg = p.func })
	hl("@function.call", { fg = p.func })
	hl("@function.method", { fg = p.func })
	hl("@function.method.call", { fg = p.func })

	-- Module / namespace names — bold. Elixir modules, TS classes &
	-- constructors all share this styling.
	hl("@module", { fg = p.module, bold = true })
	hl("@constructor", { fg = p.module, bold = true })

	-- Capitalized JSX component tags (`<Foo/>`). The tsx grammar captures these
	-- as `@tag`; mirror the @lsp.type.class/namespace → module styling so the
	-- color is stable with or without LSP.
	hl("@tag", { fg = p.module, bold = true })

	-- Elixir constants (module attributes like `@foo`) — kept in the theme's
	-- secondary accent so it doesn't compete with module names.
	hl("@constant.elixir", { fg = p.constant })

	-- ── LSP semantic tokens ─────────────────────────────────────────────────
	-- These override treesitter once the server attaches; keep our colors
	-- stable across pre-/post-LSP transitions.
	hl("@lsp.type.property", { fg = p.key })
	hl("@lsp.type.function", { fg = p.func })
	hl("@lsp.type.method", { fg = p.func })
	hl("@lsp.type.module", { fg = p.module, bold = true })
	hl("@lsp.type.namespace", { fg = p.module, bold = true })
	hl("@lsp.type.class", { fg = p.module, bold = true })
	hl("@lsp.type.enumMember", { link = "@variable.member" })
	hl("@lsp.typemod.enumMember.readonly", { link = "@variable.member" })

	-- ── Diagnostics ─────────────────────────────────────────────────────────
	-- Base fg colors read on the black editor (virtual text, floats, underlines).
	-- elflord/Neovim leaves DiagnosticError a pure-red that vanishes elsewhere.
	local diag = {
		Error = p.diag_error or p.keyword,
		Warn = p.diag_warn or p.accent,
		Info = p.diag_info or p.type,
		Hint = p.diag_hint or p.comment,
	}
	for sev, color in pairs(diag) do
		hl("Diagnostic" .. sev, { fg = color })
		hl("DiagnosticVirtualText" .. sev, { fg = color })
		hl("DiagnosticUnderline" .. sev, { sp = color, undercurl = true })
		hl("DiagnosticFloating" .. sev, { fg = color, bg = p.bg_float })
		-- Sign groups are reused by the default statusline's vim.diagnostic.status()
		-- ("E:17 …"). Red doesn't read on the bright-pink StatusLine, and a bg here
		-- would paint a disruptive segment on the bar. So the signs take the
		-- statusline's near-white text (no bg): the count blends into the bar and
		-- reads, at the cost of severity color in the (black) signcolumn —
		-- virtual-text and underlines above keep the vivid per-severity hues.
		hl("DiagnosticSign" .. sev, { fg = p.fg_statusline or p.fg_bright })
	end
end

-- Convenience loader: `require("stargum").load("stargum")` loads the palette
-- from `stargum.palettes.stargum` and applies it. The default variant is named
-- `stargum`; any other variant applies as `stargum-<variant>`.
function M.load(variant)
	variant = variant or "stargum"
	local p = require("stargum.palettes." .. variant)
	local name = (variant == "stargum") and "stargum" or ("stargum-" .. variant)
	M.apply(name, p)
end

return M
