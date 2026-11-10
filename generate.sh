#!/usr/bin/env bash
# Generates docs/**/*.html from src/**/*.md.
#
# Requires pandoc (https://pandoc.org). Run from anywhere: ./generate.sh
# The generated HTML is committed, so GitHub Pages (served from /docs) needs no build.
# Never edit the generated spec pages in docs/; edit the Markdown in src/.
set -euo pipefail
cd "$(dirname "$0")"

command -v pandoc >/dev/null || { echo "generate.sh: pandoc is required (brew install pandoc)" >&2; exit 1; }

count=0
while IFS= read -r md; do
  rel="${md#src/}"                 # spec/namespace/0.1/index.md
  out="docs/${rel%.md}.html"
  dir="$(dirname "$rel")"
  # Path back to the site root: "" for src/index.md, "../../" for src/a/b/index.md
  root=""
  if [ "$dir" != "." ]; then
    depth=$(awk -F/ '{print NF}' <<<"$dir")
    for ((i = 0; i < depth; i++)); do root="../$root"; done
  fi
  mkdir -p "$(dirname "$out")"
  pandoc --from gfm+yaml_metadata_block --to html5 --no-highlight --wrap=none \
    --lua-filter tools/md-links.lua \
    --template tools/template.html \
    --variable "root=$root" --variable "source=$md" \
    "$md" --output "$out"
  count=$((count + 1))
done < <(find src -name '*.md' | sort)

echo "generated $count page(s) in docs/"
