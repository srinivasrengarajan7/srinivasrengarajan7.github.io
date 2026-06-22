#!/usr/bin/env bash
#
# sync-nav.sh
#
# Single source of truth for the nav bar is nav.html (just the bare
# <nav>...</nav> block, no class="current" on any link). This script
# copies that block into every *.html file in the current directory,
# replacing whatever <nav>...</nav> block is already there, and adds
# class="current" to whichever link matches that page's own filename.
#
# Usage:
#   1. Edit nav.html (add/remove/rename links, reorder, etc.)
#   2. Run:  ./sync-nav.sh
#   3. Every page's nav is now in sync. Commit and push as usual.
#
# Re-running this script is always safe (idempotent).

set -euo pipefail

if ! command -v perl >/dev/null 2>&1; then
  echo "Error: this script requires perl, which was not found on PATH." >&2
  exit 1
fi

TEMPLATE="nav.html"

if [ ! -f "$TEMPLATE" ]; then
  echo "Error: $TEMPLATE not found in this directory." >&2
  exit 1
fi

export NAV_TEMPLATE
NAV_TEMPLATE=$(cat "$TEMPLATE")

shopt -s nullglob
changed_count=0
unchanged_count=0

for f in *.html; do
  [ "$f" == "$TEMPLATE" ] && continue   # don't sync the template into itself

  before_hash=$(md5sum "$f" | cut -d' ' -f1)

  # Step 1: swap this file's <nav>...</nav> block for the template
  perl -0777 -pi -e '
    BEGIN { $tmpl = $ENV{"NAV_TEMPLATE"}; }
    s{<nav>.*?</nav>}{$tmpl}s;
  ' "$f"

  # Step 2: mark the link matching this filename as current
  perl -0777 -pi -e '
    my $page = "'"$f"'";
    s{<a href="\Q$page\E">([^<]+)</a>}{<a href="$page" class="current">$1</a>};
  ' "$f"

  after_hash=$(md5sum "$f" | cut -d' ' -f1)

  if [ "$before_hash" != "$after_hash" ]; then
    echo "Synced:     $f"
    changed_count=$((changed_count + 1))
  else
    echo "Unchanged:  $f"
    unchanged_count=$((unchanged_count + 1))
  fi
done

echo
echo "Done. ${changed_count} file(s) synced, ${unchanged_count} unchanged."
