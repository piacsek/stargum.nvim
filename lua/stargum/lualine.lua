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
--   a/z  mode + location blocks: one palette color per mode as the bg, with the
--        text picked per block by luminance — `cursor_text` on a dark block (the
--        deep-cyan cursor), `bg` on a light one (teal/orchid/gold) — so every
--        mode block keeps contrast regardless of which way the cursor pair goes.
--   b/y  `bg_active` with the mode color as text.
--   c/x  the brand bar: `bg_statusline` / `fg_statusline`, same as StatusLine.
--   inactive: StatusLineNC (`bg_dim` / `fg_dim`).
local M = {}

---@param variant string palette module name under stargum.palettes
---@return table lualine theme
function M.theme(variant)
	local p = require("stargum.palettes." .. variant)

	local bar = { bg = p.bg_statusline or p.bg_active, fg = p.fg_statusline or p.fg_bright }

	local function lum(hex)
		local function ch(i)
			local c = tonumber(hex:sub(i, i + 1), 16) / 255
			return c <= 0.03928 and c / 12.92 or ((c + 0.055) / 1.055) ^ 2.4
		end
		return 0.2126 * ch(2) + 0.7152 * ch(4) + 0.0722 * ch(6)
	end
	-- Pick whichever of the two text candidates contrasts more with the block.
	local light_text = p.fg_bright
	local dark_text = p.bg
	if lum(light_text) < lum(dark_text) then
		light_text, dark_text = dark_text, light_text
	end
	local function block_fg(color)
		return lum(color) > 0.18 and dark_text or light_text
	end

	local function mode(color)
		return {
			a = { bg = color, fg = block_fg(color), gui = "bold" },
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
