#!/usr/bin/env bash
#
# update-dates.sh
#
# Updates the "Last updated" <time> tag in the footer of every .html file
# in the current directory to today's date, formatted as dd-mm-yyyy.
#
# Usage:
#   ./update-dates.sh
#
# Run this from the directory containing your .html files (e.g. the root
# of your academic-site repo).

set -euo pipefail

# Display date: dd-mm-yyyy (what the visitor sees)
DATE_DISPLAY=$(date +%d-%m-%Y)

# Machine-readable date for the datetime="" attribute (ISO 8601, yyyy-mm-dd)
DATE_ATTR=$(date +%Y-%m-%d)

shopt -s nullglob
html_files=(*.html)

if [ ${#html_files[@]} -eq 0 ]; then
  echo "No .html files found in this directory."
  exit 0
fi

updated_count=0
skipped_count=0

for f in "${html_files[@]}"; do
  if grep -q '<time datetime="[^"]*">[^<]*</time>' "$f"; then
    # -i.bak works identically on GNU sed (Linux) and BSD sed (macOS)
    sed -i.bak -E "s|<time datetime=\"[^\"]*\">[^<]*</time>|<time datetime=\"${DATE_ATTR}\">${DATE_DISPLAY}</time>|g" "$f"
    rm -f "${f}.bak"
    echo "Updated:  $f"
    updated_count=$((updated_count + 1))
  else
    echo "Skipped:  $f  (no <time datetime=\"...\">...</time> tag found)"
    skipped_count=$((skipped_count + 1))
  fi
done

echo
echo "Done. ${updated_count} file(s) updated to ${DATE_DISPLAY}, ${skipped_count} skipped."
