-- Contrast audit for a stargum variant. Run headless:
--   nvim --headless --clean --cmd "set rtp+=$PWD" -l samples/contrast.lua [variant]
-- Reports every fg/bg pairing the theme emits that falls under the WCAG ratio
-- thresholds below, plus each syntax token against every bg-only surface
-- (Visual, Search, CursorLine, Pmenu, diff rows) it may be painted over.
-- Exits 1 when anything fails so it can gate a release.
local variant = _G.arg and _G.arg[1] or "stargum"
local name = variant == "stargum" and "stargum" or ("stargum-" .. variant)
vim.cmd.colorscheme(name)
local p = require("stargum.palettes." .. variant)

local function lum(hex)
	local function ch(i)
		local c = tonumber(hex:sub(i, i + 1), 16) / 255
		return c <= 0.03928 and c / 12.92 or ((c + 0.055) / 1.055) ^ 2.4
	end
	return 0.2126 * ch(2) + 0.7152 * ch(4) + 0.0722 * ch(6)
end
local function ratio(a, b)
	local la, lb = lum(a), lum(b)
	if la < lb then la, lb = lb, la end
	return (la + 0.05) / (lb + 0.05)
end
local function hex(n)
	return n and string.format("#%06x", n) or nil
end
local function get(g)
	local h = vim.api.nvim_get_hl(0, { name = g, link = false })
	return hex(h.fg), hex(h.bg)
end

-- Thresholds (WCAG): 4.5 for text you read (popup rows, cursor glyph, search
-- text); 3.0 for UI chrome, bold accents, secondary text (bars, tabs, borders,
-- line numbers, comments) and for syntax tokens painted over a tinted surface.
local MIN_TOKEN = 3.0
local MIN = {
	Cursor = 4.5, Search = 4.5, Pmenu = 4.5, PmenuSel = 4.5, WinBar = 4.5, TelescopeSelection = 4.5,
	StatusLine = 3.0, StatusLineNC = 3.0, IncSearch = 3.0, PmenuMatch = 3.0, PmenuMatchSel = 3.0, TabLine = 3.0,
	TabLineSel = 3.0, WinBarNC = 3.0, MatchParen = 3.0, FloatBorder = 3.0, FloatTitle = 3.0, LineNr = 3.0,
	Comment = 3.0, Folded = 3.0, RenderMarkdownCodeInline = 3.0,
}
local fails, rows = 0, {}
local function check(label, fg, bg, min)
	local r = ratio(fg, bg)
	local ok = r >= min
	if not ok then fails = fails + 1 end
	rows[#rows + 1] = string.format("%s %-42s %s on %s  %.2f (min %.1f)", ok and "ok  " or "FAIL", label, fg, bg, r, min)
end

-- 1. Groups that set both fg and bg (blocks, bars, selections with text).
for _, g in ipairs({ "Cursor", "IncSearch", "Search", "StatusLine", "StatusLineNC", "PmenuSel", "PmenuMatchSel",
	"Pmenu", "PmenuMatch", "TabLineSel", "TabLine", "WinBar", "WinBarNC", "MatchParen", "FloatBorder", "FloatTitle",
	"TelescopeSelection", "RenderMarkdownCodeInline", "LineNr", "Comment", "Folded" }) do
	local fg, bg = get(g)
	local nfg, nbg = get("Normal")
	fg, bg = fg or nfg, bg or nbg
	check(g, fg, bg, MIN[g] or 4.5)
end

-- 2. Every syntax token on every bg-only surface it can be painted over.
-- Comments recede by design, so they are only held to the threshold on the
-- surfaces they live on permanently (editor, selection, cursorline, popups),
-- not on transient tints (diff hunks, LSP references, snippet stops).
local tokens = { "comment", "string", "variable", "keyword", "type", "special", "preproc", "func", "module", "key", "constant", "fg_normal" }
local permanent = { Normal = true, Visual = true, CursorLine = true, Pmenu = true, NormalFloat = true }
for _, surface in ipairs({ "Normal", "Visual", "CursorLine", "Pmenu", "NormalFloat", "DiffAdd", "DiffChange", "DiffDelete", "DiffText",
	"LspReferenceText", "LspReferenceWrite", "SnippetTabstop", "RenderMarkdownH1Bg", "RenderMarkdownCode" }) do
	local _, bg = get(surface)
	bg = bg or select(2, get("Normal"))
	for _, t in ipairs(tokens) do
		if t ~= "comment" or permanent[surface] then
			check(t .. " on " .. surface, p[t], bg, MIN_TOKEN)
		end
	end
end

table.sort(rows, function(a, b) return a:sub(1, 4) == "FAIL" and b:sub(1, 4) ~= "FAIL" end)
for _, r in ipairs(rows) do
	if r:sub(1, 4) == "FAIL" or vim.env.CONTRAST_VERBOSE then print(r) end
end
print(string.format("%s: %d pairings checked, %d below threshold", name, #rows, fails))
os.exit(fails > 0 and 1 or 0)
