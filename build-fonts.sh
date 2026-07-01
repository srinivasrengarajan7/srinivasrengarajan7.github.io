#!/usr/bin/env bash
#
# build-fonts.sh
#
# Converts the Baskervaldx OpenType fonts into WOFF2 files for the web,
# and places them in ./fonts/ with the names style.css expects.
#
# WHERE TO GET THE SOURCE .otf FILES
# -----------------------------------
# Option 1 (you have TeX Live installed locally):
#   find "$(kpsewhich -var-value TEXMFDIST)" -iname "*baskervaldx*.otf"
#   (or search TEXMFLOCAL / TEXMFHOME the same way if not found there)
#
# Option 2 (no local TeX Live):
#   Download the package zip from CTAN:
#   https://ctan.org/pkg/baskervaldx
#   The .otf files are inside fonts/opentype/public/baskervaldx/ in the zip.
#
# Once you've found them, there should be four weights/styles: Regular,
# Italic, Bold, and Bold Italic. The exact filenames vary by package
# version — list the directory and adjust the SRC_* variables below to
# match what you actually find, then run this script.
#
# Usage:
#   1. Edit the four SRC_* paths below
#   2. chmod +x build-fonts.sh
#   3. ./build-fonts.sh

set -euo pipefail

# ---- EDIT THESE FOUR PATHS to point at your actual .otf files ----
SRC_REGULAR="/usr/share/texmf-dist/fonts/opentype/public/baskervaldx/Baskervaldx-Reg.otf"
SRC_ITALIC="/usr/share/texmf-dist/fonts/opentype/public/baskervaldx/Baskervaldx-Ita.otf"
SRC_BOLD="/usr/share/texmf-dist/fonts/opentype/public/baskervaldx/Baskervaldx-Bol.otf"
SRC_BOLDITALIC="/usr/share/texmf-dist/fonts/opentype/public/baskervaldx/Baskervaldx-BolIta.otf"
# --------------------------------------------------------------------

OUT_DIR="fonts"
mkdir -p "$OUT_DIR"

if ! python3 -c "import fontTools" 2>/dev/null; then
  echo "fonttools is required. Install it with:"
  echo "  pip install fonttools brotli"
  exit 1
fi

convert () {
  local src="$1"
  local out_name="$2"

  if [ ! -f "$src" ]; then
    echo "Skipping (not found): $src"
    return
  fi

  python3 -m fontTools.ttLib.woff2 compress -o "${OUT_DIR}/${out_name}.woff2" "$src"
  echo "Built: ${OUT_DIR}/${out_name}.woff2"
}

convert "$SRC_REGULAR"    "Baskervaldx-Regular"
convert "$SRC_ITALIC"     "Baskervaldx-Italic"
convert "$SRC_BOLD"       "Baskervaldx-Bold"
convert "$SRC_BOLDITALIC" "Baskervaldx-BoldItalic"

echo
echo "Done. Check the fonts/ directory, then commit and push it along with style.css."
