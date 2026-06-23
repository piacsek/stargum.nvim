#!/bin/zsh
# Regenerate the README screenshot gallery for every stargum variant.
#
# For each variant it renders samples/showcase.tsx and samples/showcase.ex with
# treesitter highlighting (nvim :TOhtml -> headless Chrome -> PNG) and trims the
# margins, writing samples/screenshots/<variant>-tsx.png and -<variant>-ex.png
# (the README arranges them in a tsx | ex table, one row per variant).
#
# The default variant `stargum` loads as colorscheme `stargum`; any other
# variant loads as `stargum-<variant>` (mirrors lua/stargum/init.lua's M.load).
#
# Requirements (all already present on the dev machine):
#   - nvim 0.12+ with the tsx/typescript/elixir treesitter parsers installed
#   - nvim-treesitter on the pack path (for the highlight queries)
#   - Google Chrome (headless render) and ImageMagick (`magick`)
#
# Usage:
#   samples/render.sh                 # all variants
#   samples/render.sh stargum         # only the named variants
set -e

REPO="${0:A:h:h}"                       # repo root (this file is samples/render.sh)
OUT="$REPO/samples/screenshots"
SITE="$HOME/.local/share/nvim/site"
TS="$SITE/pack/core/opt/nvim-treesitter"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
SCALE=2                                  # 2 = retina; drop to 1 for smaller files

# Variants default to every palette in lua/stargum/palettes/.
if (( $# )); then
  variants=("$@")
else
  variants=(${REPO}/lua/stargum/palettes/*.lua(:t:r))
fi

mkdir -p "$OUT"

render() {  # <variant> <file> <lang> <out.png>
  local variant="$1" file="$2" lang="$3" out="$4"
  local html="/tmp/sg_${variant}_${lang}.html"
  local ft=$( [ "$lang" = tsx ] && echo typescriptreact || echo elixir )
  # The default palette `stargum` is the bare colorscheme name; others prefix.
  local scheme=$( [ "$variant" = stargum ] && echo stargum || echo "stargum-$variant" )

  nvim --clean --headless \
    --cmd "set rtp+=$SITE" --cmd "set rtp+=$TS" --cmd "set rtp+=$REPO" \
    --cmd "set termguicolors" \
    -c "edit $REPO/samples/$file" \
    -c "set filetype=$ft" \
    -c "colorscheme $scheme" \
    -c "packadd nvim.tohtml" \
    -c "lua vim.treesitter.start(0, '$lang')" \
    -c "TOhtml" -c "write! $html" -c "qa!"

  "$CHROME" --headless=new --disable-gpu --hide-scrollbars \
    --force-device-scale-factor=$SCALE --window-size=900,1400 \
    --screenshot="$out" --default-background-color=00000000 \
    "file://$html" >/dev/null 2>&1

  # Trim the uniform bg margin, then re-pad evenly in the bg color.
  local bg=$(magick "$out" -format '%[pixel:p{0,0}]' info:)
  magick "$out" -bordercolor "$bg" -border 1 -fuzz 1% -trim +repage \
    -bordercolor "$bg" -border 28 "$out"
}

for v in $variants; do
  render "$v" showcase.tsx tsx    "$OUT/$v-tsx.png"
  render "$v" showcase.ex  elixir "$OUT/$v-ex.png"
  echo "wrote $OUT/$v-tsx.png and $OUT/$v-ex.png"
done
