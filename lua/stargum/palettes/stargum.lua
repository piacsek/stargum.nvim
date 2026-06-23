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
	-- Surfaces — pure-black space. The interactive surfaces lift just off black
	-- toward violet so accents sit alive against them without graying the void.
	bg             = "#000000",
	bg_float       = "#120a1f",
	bg_inactive    = "#0a0712",
	bg_dim         = "#1c1230",
	bg_active      = "#2c1c48", -- selection/menu surface; `accent` reads on it
	bg_winbar      = "#0f0a1c",
	bg_cursorline  = "#140e24",
	bg_colorcolumn = "#1f0f38",
	bg_visual      = "#ff5fc4", -- vivid bubblegum selection (punchy, on-brand)
	fg_visual      = "#1a0418", -- near-black plum text on the bright pink selection
	bg_statusline  = "#ff45c0", -- bright bubblegum status bar (the brand, full-width)
	fg_statusline  = "#fff4fb", -- near-white text on the bright pink bar

	-- Text — soft white with a faint violet tint so it reads as "space," not gray.
	fg_normal      = "#f0eaff",
	fg             = "#dcd6ec",
	fg_muted       = "#7d7298",
	fg_dim         = "#a79cc2",
	fg_bright      = "#f9f5ff",

	-- Syntax — vivid violet/pink core with bright cyan relief (string/type/key
	-- carry the cool side; keyword/func/module/special carry the pink-violet side).
	comment        = "#776d9a", -- muted violet-grey (recessive, still legible)
	string         = "#69eccb", -- bright mint-cyan (literals/numbers/booleans)
	variable       = "#dcc6ff", -- lavender (frequent token, stays calm near text)
	keyword        = "#ff2fa8", -- vivid hot bubblegum (Statement/Keyword — pops)
	type           = "#48dcff", -- bright electric cyan (the cybernetic edge)
	special        = "#ff77d4", -- bright pink
	preproc        = "#86a4ff", -- periwinkle blue

	-- Syntax accents
	func           = "#ef79ff", -- bright orchid (functions pop violet-pink)
	module         = "#bd84ff", -- violet (bold modules/classes/tags)
	key            = "#8df0ff", -- bright pale cyan (atoms / map keys / properties)
	constant       = "#ccaaff", -- light violet (Elixir module attrs)

	-- UI accents
	cursor         = "#ef79ff", -- bright orchid block cursor (in-family with the core)
	accent         = "#ff45c0", -- vivid bubblegum (primary UI accent — pink is the star)
	match          = "#46ece6", -- bright cyan (completion match — cool relief)
	border         = "#d2ab5a", -- muted gold (float borders + window separators)

	-- Terminal ANSI palette — hand-tuned so red/green/blue read correctly in
	-- :terminal even though the syntax palette is anchored on the pink-violet
	-- family. Slot 0 lifts to bg_dim via the core.
	ansi = {
		[1] = "#ff4f7f", [2] = "#5fe0ad", [3] = "#d2ab5a", [4] = "#86a4ff",
		[5] = "#ff2fa8", [6] = "#48dcff", [7] = "#dcd6ec", [8] = "#7d7298",
		[9] = "#ff7aa2", [10] = "#69eccb", [11] = "#f4cf78", [12] = "#a6bcff",
		[13] = "#ff77d4", [14] = "#7ff2ff", [15] = "#f9f5ff",
	},
}
