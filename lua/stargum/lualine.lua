-- lualine theme, derived from a stargum palette.
--
-- lualine's `theme = "auto"` first looks for `lua/lualine/themes/<colors_name>.lua`
-- on the runtimepath and only falls back to deriving colors from highlight
-- groups when none exists. The derivation is ugly for stargum: it takes the mode
-- block from `PmenuSel`'s bg (our `bg_visual`), lightens it 10% into a muddy
-- tone, then force-darkens the text for contrast. So each variant ships a
-- theme built from its own palette instead.
--
-- Layout (globalstatus or not):
--   a/z  mode + location blocks: the palette's `cursor` color with `cursor_text`
--        on it (the cursor pair already guarantees contrast), one color per mode.
--   b/y  `bg_active` with the mode color as text.
--   c/x  the brand bar: `bg_statusline` / `fg_statusline`, same as StatusLine.
--   inactive: StatusLineNC (`bg_dim` / `fg_dim`).
local M = {}

---@param variant string palette module name under stargum.palettes
---@return table lualine theme
function M.theme(variant)
	local p = require("stargum.palettes." .. variant)

	local block_fg = p.cursor_text or p.bg
	local bar = { bg = p.bg_statusline or p.bg_active, fg = p.fg_statusline or p.fg_bright }

	local function mode(color)
		return {
			a = { bg = color, fg = block_fg, gui = "bold" },
			b = { bg = p.bg_active, fg = color },
			c = bar,
		}
	end

	return {
		normal = mode(p.cursor or p.module),
		insert = mode(p.string),
		visual = mode(p.func),
		replace = mode(p.diag_error or p.keyword),
		command = mode(p.module), -- gold, not `type`: the cyan cursor already owns normal mode
		terminal = mode(p.key),
		inactive = {
			a = { bg = p.bg_dim, fg = p.fg_dim, gui = "bold" },
			b = { bg = p.bg_dim, fg = p.fg_dim },
			c = { bg = p.bg_dim, fg = p.fg_dim },
		},
	}
end

return M
