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
	bg_visual      = "#fff0a5", -- light-yellow selection (highlighter)
	fg_visual      = "#2b0a22", -- dark plum text — required: the neon syntax/text would vanish on light yellow (so dark selected text is flat, by design)
	bg_statusline  = "#ff45c0", -- bright bubblegum status bar (the brand, full-width)
	fg_statusline  = "#fff4fb", -- near-white text on the bright pink bar

	-- Text — soft white with a faint violet tint so it reads as "space," not gray.
	fg_normal      = "#f0eaff",
	fg             = "#dcd6ec",
	fg_muted       = "#7d7298",
	fg_dim         = "#a79cc2",
	fg_bright      = "#f9f5ff",

	-- Syntax — GLARING neon violet/pink core with electric-cyan relief
	-- (string/type/key carry the cool side; keyword/func/module/special carry the
	-- pink-violet side). Pushed near the gamut edge to match elflord's intensity.
	comment        = "#847aa6", -- muted violet-grey (recessive, but readable on black)
	string         = "#00ffc8", -- glaring spring cyan-green (literals/numbers/booleans)
	variable       = "#e3baff", -- bright lavender (frequent token, stays legible)
	keyword        = "#ff1493", -- glaring deep hot pink (Statement/Keyword — pops hardest)
	type           = "#00e5ff", -- glaring electric cyan (the cybernetic edge)
	special        = "#ff5cd2", -- bright pink
	preproc        = "#5c7cff", -- electric periwinkle blue

	-- Syntax accents
	func           = "#f23bff", -- glaring magenta-orchid (functions)
	module         = "#ffd84a", -- glaring gold-yellow (bold modules/classes/tags) — the yellow accent
	key            = "#4df3ff", -- glaring pale cyan (atoms / map keys / properties)
	constant       = "#d68cff", -- bright violet (Elixir module attrs)

	-- UI accents
	cursor         = "#ffd84a", -- gold-yellow block cursor (matches the module/class accent)
	cursor_text    = "#1a0820", -- deep-plum glyph: dark enough to read on the yellow block
	accent         = "#ff2fb0", -- glaring bubblegum (primary UI accent — pink is the star)
	match          = "#00ffd5", -- glaring cyan (completion match — cool relief)
	border         = "#d2ab5a", -- muted gold (float borders + window separators)

	-- Diagnostics — vivid fg that reads on the black editor; the core gives the
	-- *sign* groups a black bg so the diagnostic counts in the (pink) statusline
	-- render as readable dark-backed segments instead of red-on-pink.
	diag_error     = "#ff2d6a", -- red
	diag_warn      = "#ffb02e", -- amber (distinct from the gold-yellow modules)
	diag_info      = "#00e5ff", -- cyan
	diag_hint      = "#7fdcc0", -- muted teal

	-- Terminal ANSI palette — hand-tuned so red/green/blue read correctly in
	-- :terminal even though the syntax palette is anchored on the pink-violet
	-- family. Slot 0 lifts to bg_dim via the core. Vivid to match the theme.
	ansi = {
		[1] = "#ff2d6a", [2] = "#00ffa0", [3] = "#ffcf3d", [4] = "#5c7cff",
		[5] = "#ff1493", [6] = "#00e5ff", [7] = "#dcd6ec", [8] = "#847aa6",
		[9] = "#ff5c87", [10] = "#4dffc0", [11] = "#ffe066", [12] = "#8aa0ff",
		[13] = "#ff5cd2", [14] = "#5cf3ff", [15] = "#f9f5ff",
	},
}
