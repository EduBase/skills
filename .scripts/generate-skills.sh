#!/bin/bash
# Create skill files automatically
export TZ=UTC

# Iterate through all SKILL.md files and generate corresponding .skill files from skill files
find . -type f -name "SKILL.md" | while read -r skill_md; do
  skill_dir=$(dirname "$skill_md")
  skill_filename="$(basename "$skill_dir" .md).skill"
  echo "Generating $skill_filename from ${skill_md:2}"
  cd "$skill_dir" || exit 1
  last_modified=$(git ls-files -z . | xargs -0 -I{} -- git log -1 --date=format-local:"%Y%m%d%H%M" --format="%ad" -- '{}' | sort -r | head -n 1)
  echo "Using last modification timestamp: $last_modified (UTC)"
  find . -type f -exec touch -a -m -t "$last_modified" '{}' \+ || echo "Failed to set timestamps for $skill_filename"
  find . -type f | sort | zip -FS -X -D -r -q -9 -A --compression-method deflate "$skill_filename.new" -@ -x ".*" -x "$skill_filename*"
  touch -a -m -t "$last_modified" "$skill_filename.new"
  if [ ! -f "$skill_filename" ]; then
    echo "Creating $skill_filename"
    mv "$skill_filename.new" "$skill_filename"
  elif [[ $(md5sum "$skill_filename.new" | awk '{print $1}') == $(md5sum "$skill_filename" 2>/dev/null | awk '{print $1}') ]]; then
    echo "No changes detected for $skill_filename, skipping update"
    rm -f "$skill_filename.new"
  else
    mv "$skill_filename.new" "$skill_filename"
    echo "Updated $skill_filename"
  fi
  cd - > /dev/null || exit 1
done
