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

-- Mix two "#rrggbb" colors: `alpha` of `fg` over `bg`. Used to derive subtle
-- bg-only tints (diff rows, LSP references, heading bands) from the palette so
-- variants don't have to hand-tune a dozen near-background surfaces.
local function blend(fg, bg, alpha)
	local function rgb(hex)
		return tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
	end
	local fr, fg_, fb = rgb(fg)
	local br, bg_, bb = rgb(bg)
	local function mix(a, b)
		return math.floor(a * alpha + b * (1 - alpha) + 0.5)
	end
	return string.format("#%02x%02x%02x", mix(fr, br), mix(fg_, bg_), mix(fb, bb))
end
M.blend = blend

-- The palette contract. A missing key would silently produce a wrong group
-- (nil fg/bg), so fail loudly instead.
M.required_keys = {
	"bg", "bg_float", "bg_inactive", "bg_dim", "bg_active", "bg_winbar",
	"bg_cursorline", "bg_colorcolumn", "bg_visual",
	"fg_normal", "fg", "fg_muted", "fg_dim", "fg_bright",
	"comment", "string", "variable", "keyword", "type", "special", "preproc",
	"func", "module", "key", "constant",
	"accent", "match",
}

local function validate(variant, p)
	local missing = {}
	for _, k in ipairs(M.required_keys) do
		if p[k] == nil then
			missing[#missing + 1] = k
		end
	end
	if #missing > 0 then
		error(("stargum: palette '%s' is missing required keys: %s"):format(variant, table.concat(missing, ", ")))
	end
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

	-- Bg-only tints derived from a palette color over `bg`. The same alpha reads
	-- roughly twice as strong on a light background (a deep color mixed into
	-- white darkens fast), so halve it there — keeps token contrast on the tint.
	local function lum(hex)
		local function ch(i)
			local c = tonumber(hex:sub(i, i + 1), 16) / 255
			return c <= 0.03928 and c / 12.92 or ((c + 0.055) / 1.055) ^ 2.4
		end
		return 0.2126 * ch(2) + 0.7152 * ch(4) + 0.0722 * ch(6)
	end
	local light_bg = lum(p.bg) > 0.5
	local function tint(color, alpha)
		return blend(color, p.bg, light_bg and alpha * 0.5 or alpha)
	end

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
	-- Search matches: a tinted surface with bright text (`bg_search`, falls back to
	-- `bg_active`; `fg_search` falls back to `fg_bright`) instead of dark text on a
	-- light syntax color, which inverted the dark theme into pale blobs. The match
	-- under the cursor (CurSearch/IncSearch) is a bold block in the brand pink with
	-- a light glyph (`bg_search_cur` / `fg_search_cur`, falling back to
	-- `accent` / `bg`) so it is unmistakably "the current one".
	hl("Search", { fg = p.fg_search or p.fg_bright, bg = p.bg_search or p.bg_active })
	hl("IncSearch", { fg = p.fg_search_cur or p.bg, bg = p.bg_search_cur or p.accent, bold = true })
	hl("CurSearch", { link = "IncSearch" })
	hl("QuickFixLine", { link = "Visual" }) -- quickfix selection reads as the selection tone, not elflord's default

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

	-- ── Surfaces elflord leaves bright/white ────────────────────────────────
	-- Statusline: tone down elflord's bright white statusline. Optional
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

	-- Completion popup (LSP, nvim-cmp, blink). The selected row uses `bg_visual`
	-- (the magenta-plum selection color) rather than bg_active: a different HUE
	-- from the violet popup makes the selection obvious where a same-hue brightness
	-- bump read as too subtle, and it unifies the selection identity with Visual.
	hl("Pmenu", { fg = p.fg, bg = p.bg_float })
	hl("PmenuSel", { fg = p.fg_bright, bg = p.bg_visual, bold = true })
	hl("PmenuKind", { fg = p.fg_muted, bg = p.bg_float })
	hl("PmenuKindSel", { fg = p.fg_bright, bg = p.bg_visual })
	hl("PmenuExtra", { fg = p.fg_muted, bg = p.bg_float })
	hl("PmenuExtraSel", { fg = p.fg_bright, bg = p.bg_visual })
	hl("PmenuMatch", { fg = p.match, bg = p.bg_float, bold = true })
	hl("PmenuMatchSel", { fg = p.accent, bg = p.bg_visual, bold = true })
	hl("PmenuSbar", { bg = p.bg_dim })
	hl("PmenuThumb", { bg = p.fg_muted })

	hl("VisualNOS", { fg = p.fg, bg = p.bg_active })
	hl("WildMenu", { fg = p.accent, bg = p.bg_active, bold = true })
	hl("TabLine", { fg = p.fg_dim, bg = p.bg_dim })
	hl("TabLineSel", { fg = p.accent, bg = p.bg_visual, bold = true }) -- the selection surface, like PmenuSel; accent reads on it in both variants
	hl("TabLineFill", { bg = p.bg_inactive })
	hl("WinBar", { fg = p.fg, bg = p.bg_winbar })
	hl("WinBarNC", { fg = p.fg_muted, bg = p.bg_inactive })
	hl("MsgArea", { fg = p.fg, bg = p.bg })

	-- Message-area prompts (hit-enter "Press ENTER…", :messages, mode indicator).
	-- elflord's bright cyan/green are tuned for a dark bg and leak through on
	-- light variants; drive them from the palette. ModeMsg is plain colored text,
	-- not a dark-on-pastel block.
	hl("MoreMsg", { fg = p.variable })
	hl("Question", { fg = p.special })
	hl("ModeMsg", { fg = p.special, bold = true })
	hl("WarningMsg", { fg = p.keyword })

	-- WhichKey-style overlays (covers folke/which-key.nvim and snacks variants).
	hl("WhichKeyFloat", { bg = p.bg_float })
	hl("WhichKeyBorder", { fg = border, bg = p.bg_float })

	-- MatchParen: elflord uses reverse video which obscures the cursor. A faint
	-- accent tint (not bg_active, which the light variant's Search sits on).
	hl("MatchParen", { fg = p.accent, bg = tint(p.accent, 0.3), bold = true })

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

	-- ── More elflord leaks ──────────────────────────────────────────────────
	-- elflord ships pure-primary blocks for these (blue-on-yellow Todo, white on
	-- #ff0000 Error, a light-green StatusLineTerm, pure-magenta Title, primary
	-- Spell undercurls, white-fg Diff rows). Pull every one onto the palette.
	local red = p.diag_error or (p.ansi and p.ansi[1]) or p.keyword
	local green = (p.ansi and p.ansi[2]) or p.string
	local blue = (p.ansi and p.ansi[4]) or p.preproc
	hl("Todo", { fg = p.accent, bold = true })
	hl("Error", { fg = red, bold = true })
	hl("ErrorMsg", { fg = red })
	hl("Title", { fg = p.accent, bold = true })
	hl("Underlined", { fg = p.type, underline = true })
	hl("StatusLineTerm", { link = "StatusLine" })
	hl("StatusLineTermNC", { link = "StatusLineNC" })
	hl("TermCursor", { link = "Cursor" })
	hl("SpellBad", { sp = red, undercurl = true })
	hl("SpellCap", { sp = p.diag_warn or p.accent, undercurl = true })
	hl("SpellRare", { sp = p.diag_info or p.type, undercurl = true })
	hl("SpellLocal", { sp = p.diag_hint or p.comment, undercurl = true })
	hl("DiagnosticDeprecated", { sp = p.fg_muted, strikethrough = true })
	hl("DiagnosticUnnecessary", { fg = p.fg_muted })

	-- Diff: bg-only tints derived from the ANSI red/green/blue so the syntax
	-- colors stay visible inside changed hunks (elflord forces a white fg).
	-- Optional palette overrides: bg_diff_add / bg_diff_change / bg_diff_delete.
	local diff_add = p.bg_diff_add or tint(green, 0.22)
	local diff_change = p.bg_diff_change or tint(blue, 0.2)
	local diff_delete = p.bg_diff_delete or tint(red, 0.22)
	hl("DiffAdd", { bg = diff_add })
	hl("DiffChange", { bg = diff_change })
	hl("DiffDelete", { fg = blend(red, p.bg, 0.7), bg = diff_delete }) -- fg = the `---` filler glyph
	hl("DiffText", { bg = tint(blue, 0.35), bold = true })
	hl("Added", { fg = green })
	hl("Changed", { fg = blue })
	hl("Removed", { fg = red })
	hl("diffAdded", { link = "Added" })
	hl("diffChanged", { link = "Changed" })
	hl("diffRemoved", { link = "Removed" })
	hl("GitSignsAdd", { fg = green })
	hl("GitSignsChange", { fg = blue })
	hl("GitSignsDelete", { fg = red })
	hl("GitSignsCurrentLineBlame", { link = "Comment" })

	-- LSP: references/snippets/signature must NOT look like a Visual selection.
	local ref = tint(p.type, 0.18)
	hl("LspReferenceText", { bg = ref })
	hl("LspReferenceRead", { bg = ref })
	hl("LspReferenceWrite", { bg = tint(p.type, 0.3) })
	hl("LspSignatureActiveParameter", { fg = p.accent, bold = true })
	hl("LspInlayHint", { fg = p.fg_muted, italic = true })
	hl("SnippetTabstop", { bg = tint(p.func, 0.25) })
	hl("ComplMatchIns", { fg = p.match })

	-- ── Treesitter: builtins, punctuation, tags ─────────────────────────────
	hl("@variable.builtin", { fg = p.constant, italic = true }) -- self/this/arguments
	hl("@type.builtin", { fg = p.type })
	hl("@punctuation.bracket", { fg = p.fg_dim })
	hl("@punctuation.delimiter", { fg = p.fg_dim })
	hl("@tag.attribute", { fg = p.key })
	hl("@tag.delimiter", { fg = p.fg_dim })

	-- ── Markup (markdown, help) ─────────────────────────────────────────────
	-- A six-step heading ramp (pink → orchid → cyan → teal → gold → pale cyan);
	-- render-markdown.nvim gets the same ramp with a faint band behind each.
	local headings = { p.accent, p.func, p.type, p.string, p.module, p.key }
	hl("@markup.heading", { fg = p.accent, bold = true })
	for i, c in ipairs(headings) do
		hl("@markup.heading." .. i, { fg = c, bold = true })
		hl("RenderMarkdownH" .. i, { fg = c, bold = true })
		hl("RenderMarkdownH" .. i .. "Bg", { bg = tint(c, 0.15) })
	end
	hl("@markup.link", { fg = p.key })
	hl("@markup.link.label", { fg = p.key })
	hl("@markup.link.url", { fg = p.type, underline = true })
	hl("@markup.raw", { fg = p.string })              -- inline code
	hl("@markup.raw.block", { fg = p.fg })            -- fenced blocks (injections color them)
	hl("@markup.list", { fg = p.accent })
	hl("@markup.quote", { fg = p.fg_dim, italic = true })
	hl("RenderMarkdownCode", { bg = p.bg_float })
	hl("RenderMarkdownCodeInline", { fg = p.string, bg = p.bg_dim })
	hl("RenderMarkdownBullet", { fg = p.accent })
	hl("RenderMarkdownQuote", { fg = p.fg_dim })
	hl("RenderMarkdownDash", { fg = border })
	hl("RenderMarkdownTableHead", { fg = p.key })
	hl("RenderMarkdownTableRow", { fg = p.fg_dim })

	-- ── Plugins ─────────────────────────────────────────────────────────────
	-- Pickers: gold border, float surface, PmenuSel-style selection, `match` hits.
	hl("TelescopeNormal", { fg = p.fg, bg = p.bg_float })
	hl("TelescopeBorder", { fg = border, bg = p.bg_float })
	hl("TelescopePromptBorder", { fg = border, bg = p.bg_float })
	hl("TelescopeTitle", { fg = p.accent, bold = true })
	hl("TelescopePromptPrefix", { fg = p.accent })
	hl("TelescopeSelection", { fg = p.fg_bright, bg = p.bg_visual, bold = true })
	hl("TelescopeSelectionCaret", { fg = p.accent, bg = p.bg_visual })
	hl("TelescopeMatching", { fg = p.match, bold = true })
	hl("SnacksPickerMatch", { fg = p.match, bold = true })
	hl("SnacksPickerListCursorLine", { bg = p.bg_visual })
	hl("SnacksPickerPreviewCursorLine", { bg = p.bg_cursorline })
	hl("SnacksPickerDir", { fg = p.fg_muted })
	hl("SnacksPickerPrompt", { fg = p.accent })
	-- Indent guides: barely-there lines, scope in the muted text tone.
	hl("IblIndent", { fg = p.bg_dim })
	hl("IblScope", { fg = p.fg_muted })
	hl("SnacksIndent", { fg = p.bg_dim })
	hl("SnacksIndentScope", { fg = p.fg_muted })

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
	validate(variant, p)
	local name = (variant == "stargum") and "stargum" or ("stargum-" .. variant)
	M.apply(name, p)
end

return M
