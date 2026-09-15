-- stargum: bubblegum × space. Nebula pinks and electric cyans over a deep-space
-- indigo background, with muted gold borders — cybernetic/neon energy without
-- going full synthwave. The syntax core is anchored on the violet-pink family
-- (analogous to the background) with cyan as the complementary relief, the way
-- amethyst's cyan plays against purple in scintilla.
--
-- Palette key contract (every variant must define all of these):
--   Surfaces:  bg bg_float bg_inactive bg_dim bg_active bg_winbar
--              bg_cursorline bg_colorcolumn bg_visual
--   Text:      fg_normal (editor text)  fg (UI text)  fg_muted fg_dim fg_bright
--   Syntax:    comment string variable keyword type special preproc
--              func module key constant
--   Accents:   accent (primary UI)  match (completion match)  border (gold borders)
-- Optional keys: cursor, cursor_text, ansi, bg_statusline/fg_statusline (a
--   dedicated StatusLine surface; fall back to bg_active/fg_bright), and the
--   search pair bg_search/fg_search (Search; fall back to bg_active/fg_bright)
--   + bg_search_cur/fg_search_cur (CurSearch/IncSearch; fall back to accent/bg).
--   `border` falls back to fg_muted if omitted, but stargum's whole point is the
--   gold edge — keep it.

return {
	-- Surfaces — near-black violet-charcoal space. Lifted off pure #000 to ease
	-- eye strain (pure black haloes under the glaring neon); still deep enough
	-- that the tokens pop. Interactive surfaces lift further toward violet.
	bg             = "#14101e",
	bg_float       = "#1c1330",
	bg_inactive    = "#100c19",
	bg_dim         = "#241a3c",
	bg_active      = "#4a3672", -- selection/menu surface; clearly lifted off bg_float so PmenuSel/TabLineSel read; `accent` reads on it
	bg_winbar      = "#181126",
	bg_cursorline  = "#1f1738",
	bg_colorcolumn = "#1f0f38",
	bg_visual      = "#4b1e43", -- deep magenta-plum selection (bg-only; brand-pink family, dark enough that the neon tokens read through it; hue-distinct from the teal Search and the violet menus)
	bg_search      = "#1b5a68", -- search-match tint: deep teal (the cool relief), bright text on it; a different hue from the gold Visual and the violet menus
	bg_search_cur  = "#c94b8c", -- the match under the cursor: brand-pink block, a touch deeper than the statusline so the light glyph holds
	fg_search_cur  = "#fff4fb", -- light glyph on the pink block (no dark cut-out)
	bg_statusline  = "#d4589e", -- softened bubblegum status bar (the brand, full-width)
	fg_statusline  = "#fff4fb", -- near-white text on the pink bar

	-- Text — soft white with a faint violet tint so it reads as "space," not gray.
	fg_normal      = "#f0eaff",
	fg             = "#dcd6ec",
	fg_muted       = "#7d7298",
	fg_dim         = "#a79cc2",
	fg_bright      = "#f9f5ff",

	-- Syntax — softened (muted) neon violet/pink core with cyan relief
	-- (string/type/key carry the cool side; keyword/func/module/special carry the
	-- pink-violet side). Pulled back from the gamut edge so it's easy on the eyes
	-- while keeping the bubblegum × space identity.
	comment        = "#7d7398", -- muted violet-grey (recessive, but readable)
	string         = "#5fd1ab", -- soft teal-green (literals/numbers/booleans)
	variable       = "#cdb6e2", -- soft lavender (frequent token, stays legible)
	keyword        = "#e76aa3", -- rose-pink (Statement/Keyword — pops, not glaring)
	type           = "#5fc4d8", -- soft cyan (the cybernetic edge)
	special        = "#db86c0", -- soft pink
	preproc        = "#7d92dd", -- muted periwinkle blue

	-- Syntax accents
	func           = "#c98ad4", -- soft orchid (functions)
	module         = "#dcbb63", -- soft gold (bold modules/classes/tags) — the yellow accent
	key            = "#8ad4de", -- soft pale cyan (atoms / map keys / properties)
	constant       = "#c29fda", -- soft violet (Elixir module attrs)

	-- UI accents
	cursor         = "#107b95", -- deep electric-cyan block cursor: deep enough that a LIGHT glyph holds 4.6:1 (the bright #5fc4d8 forced a black glyph, which read as black-on-cyan)
	cursor_text    = "#fff4fb", -- light glyph on the cyan block — the character under the cursor reads like normal text
	accent         = "#d96aa4", -- softened bubblegum (primary UI accent — pink is the star)
	match          = "#62ccb4", -- soft cyan (completion match — cool relief)
	border         = "#d2ab5a", -- muted gold (float borders + window separators)

	-- Diagnostics — toned fg that reads on the editor bg; the core gives the
	-- *sign* groups the statusline fg so the diagnostic counts in the (pink)
	-- statusline render readably instead of red-on-pink.
	diag_error     = "#e05f7c", -- red
	diag_warn      = "#d9a256", -- amber (distinct from the gold modules)
	diag_info      = "#5fc4d8", -- cyan
	diag_hint      = "#79c4ad", -- muted teal

	-- Terminal ANSI palette — hand-tuned so red/green/blue read correctly in
	-- :terminal even though the syntax palette is anchored on the pink-violet
	-- family. Slot 0 lifts to bg_dim via the core. Toned to match the theme.
	ansi = {
		[1] = "#e05f7c", [2] = "#5fcf9e", [3] = "#d9b85f", [4] = "#7d92dd",
		[5] = "#e76aa3", [6] = "#5fc4d8", [7] = "#dcd6ec", [8] = "#847aa6",
		[9] = "#e87f9b", [10] = "#7fd9bc", [11] = "#e6cd83", [12] = "#a0b0e8",
		[13] = "#db86c0", [14] = "#8ad4de", [15] = "#f9f5ff",
	},
}
