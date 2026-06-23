-- stargum: bubblegum × space. Nebula pinks and electric cyans over a deep-space
-- indigo background, with muted gold borders — cybernetic/neon energy without
-- going full synthwave. The syntax core is anchored on the violet-pink family
-- (analogous to the background) with cyan as the complementary relief, the way
-- amethyst's cyan plays against purple in scintilla.
--
-- Palette key contract (every variant must define all of these):
--   Surfaces:  bg bg_float bg_inactive bg_dim bg_active bg_winbar
--              bg_cursorline bg_colorcolumn bg_visual fg_visual
--   Text:      fg_normal (editor text)  fg (UI text)  fg_muted fg_dim fg_bright
--   Syntax:    comment string variable keyword type special preproc
--              func module key constant
--   Accents:   accent (primary UI)  match (completion match)  border (gold borders)
-- Optional keys: cursor, ansi, and bg_statusline (a dedicated StatusLine
--   background; falls back to bg_active when absent). `border` falls back to
--   fg_muted if omitted, but stargum's whole point is the gold edge — keep it.

return {
	-- Surfaces — deep-space indigo/violet, lifting toward a warmer violet on the
	-- interactive surfaces so accents sit alive against them.
	bg             = "#0d0a1f",
	bg_float       = "#171033",
	bg_inactive    = "#120c28",
	bg_dim         = "#241848",
	bg_active      = "#352458", -- selection/menu surface; `accent` reads on it
	bg_winbar      = "#1a1238",
	bg_cursorline  = "#1e1640",
	bg_colorcolumn = "#2a1450",
	bg_visual      = "#ffa6d9", -- bubblegum selection (punchy, on-brand)
	fg_visual      = "#240a24", -- dark plum text on the bright pink selection

	-- Text — soft white with a faint violet tint so it reads as "space," not gray.
	fg_normal      = "#ece6ff",
	fg             = "#d8d2e8",
	fg_muted       = "#7d7396",
	fg_dim         = "#a298bc",
	fg_bright      = "#f5f0ff",

	-- Syntax — violet/pink core with cyan relief (string/type/key carry the cool
	-- side; keyword/func/module/special carry the pink-violet side).
	comment        = "#736a93", -- muted violet-grey (recessive, still legible)
	string         = "#7fe3c9", -- mint-cyan (literals/numbers/booleans)
	variable        = "#d3c4f5", -- lavender (frequent token, stays calm near text)
	keyword        = "#ff6fc0", -- bubblegum pink (Statement/Keyword — pops)
	type           = "#57d6e8", -- electric cyan (the cybernetic edge)
	special        = "#ff96d8", -- lighter pink
	preproc        = "#7f9dff", -- periwinkle blue

	-- Syntax accents
	func           = "#e58bff", -- orchid (functions pop violet-pink)
	module         = "#b78bff", -- violet (bold modules/classes/tags)
	key            = "#9be0ee", -- pale cyan (atoms / map keys / properties)
	constant       = "#c6a6ff", -- light violet (Elixir module attrs)

	-- UI accents
	cursor         = "#e58bff", -- orchid block cursor (in-family with the core)
	accent         = "#ff8fd4", -- bubblegum (primary UI accent — pink is the star)
	match          = "#5fe6df", -- cyan (completion match — cool relief)
	border         = "#c9a45a", -- muted gold (float borders + window separators)

	-- Terminal ANSI palette — hand-tuned so red/green/blue read correctly in
	-- :terminal even though the syntax palette is anchored on the pink-violet
	-- family. Slot 0 lifts to bg_dim via the core.
	ansi = {
		[1] = "#ff5f87", [2] = "#5fd7a7", [3] = "#c9a45a", [4] = "#7f9dff",
		[5] = "#ff6fc0", [6] = "#57d6e8", [7] = "#d8d2e8", [8] = "#7d7396",
		[9] = "#ff87a8", [10] = "#7fe3c9", [11] = "#f0cd7a", [12] = "#9bb4ff",
		[13] = "#ff96d8", [14] = "#7fe9f4", [15] = "#f5f0ff",
	},
}
