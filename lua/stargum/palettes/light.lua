-- stargum-light: the daylit nebula. A near-white, faintly-pink "bubblegum cloud"
-- background with DEEP, saturated syntax — the same bubblegum × space identity as
-- the dark default, inverted. Pink keywords, teal/cyan relief, deep-gold modules,
-- and the signature gold border (deepened so it reads on the light surface). The
-- statusline keeps a pink bar (lighter pink + dark text here).
--
-- Light-variant rules (see CLAUDE.md "Light variants"):
--   * Every syntax + UI-accent color is deep/saturated — each is used either as a
--     fg on a light surface or as the dark backdrop behind the light `bg`
--     (Search→bg_active, IncSearch→accent, Cursor→cursor). Pale would vanish in both.
--   * Only surfaces, comment, fg_muted, fg_dim go light.
--   * fg_statusline is set (dark) so it reads on the pink bar AND so the
--     DiagnosticSign* groups (which take fg_statusline) read on the light gutter.
--   * ansi[0]/[8] are dark (foreground-ish); [7]/[15] light (background-ish).

return {
	-- Surfaces — near-white, faint bubblegum tint.
	bg             = "#fff4fb",
	bg_float       = "#fbe7f3",
	bg_inactive    = "#f6ecf2",
	bg_dim         = "#f0dcea",
	bg_active      = "#edbcdf", -- selection/menu surface; deep enough to read against the pale popup bg; deep `accent` reads on it
	bg_winbar      = "#fbe7f3",
	bg_cursorline  = "#fce8f4",
	bg_colorcolumn = "#f6d7ec",
	bg_visual      = "#fff0a5", -- light-yellow selection; deep syntax shows through and stays readable
	-- fg_visual omitted: selected text keeps its per-token (deep) syntax colors.
	bg_statusline  = "#f7d4e8", -- soft light-pink bar (diamond-style: a subtle surface, not a loud color)
	fg_statusline  = "#1a0614", -- darkest plum text on the soft bar; also colors the diagnostic counts

	-- Text — deep plum (dark) on the light surfaces; muted tones stay mid/light.
	fg_normal      = "#2b0a22", -- editor text
	fg             = "#3a1530", -- UI text
	fg_muted       = "#8c7d9e", -- recessive (comments-adjacent UI)
	fg_dim         = "#6b5266", -- StatusLineNC fg on the light bg_dim
	fg_bright      = "#1a0614", -- darkest text (per the light-variant convention)

	-- Syntax — DEEP neon, readable on the light bg. Pink-violet core, teal/cyan relief.
	comment        = "#847596", -- mid grey-violet (recessive, still legible on light)
	string         = "#008a63", -- deep teal-green (literals/numbers/booleans)
	variable       = "#6a3a86", -- deep plum-violet (frequent token, calm but dark)
	keyword        = "#d80082", -- deep hot bubblegum (Statement/Keyword — pops hardest)
	type           = "#007a94", -- deep electric cyan (the cybernetic edge; deep enough to hold 4.5:1 on the light bg)
	special        = "#c61f88", -- deep pink
	preproc        = "#3f4fd0", -- deep periwinkle blue

	-- Syntax accents
	func           = "#ad1fce", -- deep magenta-orchid (functions)
	module         = "#9a6a00", -- deep gold (bold modules/classes/tags) — the yellow accent, light-side
	key            = "#0a7aa8", -- deep cyan (atoms / map keys / properties)
	constant       = "#7d33c4", -- deep violet (Elixir module attrs)

	-- UI accents
	cursor         = "#007a94", -- deep electric-cyan block cursor (cyan like the dark variant; reads on the light bg)
	cursor_text    = "#fff4fb", -- light glyph (= bg) on the deep-cyan block
	accent         = "#e00080", -- deep bubblegum (primary UI accent)
	match          = "#007a94", -- deep cyan (completion match — cool relief)
	border         = "#a87c1f", -- deepened gold (float borders + window separators) — reads on light

	-- Diagnostics — deep fg that reads on the light editor (virtual text, floats).
	-- DiagnosticSign* take fg_statusline (dark plum), readable on both the light
	-- gutter and the pink statusline.
	diag_error     = "#d11149", -- deep red
	diag_warn      = "#b5651d", -- burnt orange (distinct from the gold modules)
	diag_info      = "#0091ad", -- cyan
	diag_hint      = "#2e8a72", -- teal

	-- Terminal ANSI palette — light-theme convention: dark slots (0,8) read as
	-- foreground, light slots (7,15) serve as background. Colors 1–6/9–14 are deep
	-- enough to read on the light terminal bg.
	ansi = {
		[0] = "#2b0a22", [1] = "#d6006e", [2] = "#008a63", [3] = "#a87400",
		[4] = "#3f4fd0", [5] = "#d80082", [6] = "#0091ad", [7] = "#c9b3c2",
		[8] = "#847596", [9] = "#e0148c", [10] = "#0a9c72", [11] = "#bf8500",
		[12] = "#4f5fe0", [13] = "#c61f88", [14] = "#0aa3c2", [15] = "#fff4fb",
	},
}
