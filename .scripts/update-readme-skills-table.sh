#!/bin/bash
# Regenerate the skills table in README.md from SKILL.md frontmatter.
# Looks for <!-- SKILLS_TABLE_START --> and <!-- SKILLS_TABLE_END --> markers
# and replaces everything between them with an auto-generated markdown table.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
README="$REPO_ROOT/README.md"

# Verify the markers exist in the README
if ! grep -q "<!-- SKILLS_TABLE_START -->" "$README" || ! grep -q "<!-- SKILLS_TABLE_END -->" "$README"; then
  echo "Error: README.md is missing SKILLS_TABLE_START / SKILLS_TABLE_END markers." >&2
  exit 1
fi

# Build the table into a temp file
TABLE_FILE=$(mktemp)
trap 'rm -f "$TABLE_FILE" "$README.tmp"' EXIT

# GitHub base URL for raw file downloads
GITHUB_RAW_BASE="https://github.com/EduBase/skills/raw/main"

# Write table header (with download column)
echo "| Skill | Description | Download link|" > "$TABLE_FILE"
echo "|-------|-------------|----------|" >> "$TABLE_FILE"

# Find all SKILL.md files, extract name and description, and append a row per skill
find "$REPO_ROOT" -maxdepth 2 -name "SKILL.md" -not -path '*/\.*' | sort | while read -r skill_md; do
  skill_dir=$(dirname "$skill_md")
  folder=$(basename "$skill_dir")

  # Extract name and description from YAML frontmatter using a single awk pass
  eval "$(awk '
    /^---$/ { block++; next }
    block > 1 { exit }
    block == 1 && /^name:/ {
      val = $0; sub(/^name:[[:space:]]*/, "", val)
      printf "name=%s\n", val
    }
    block == 1 && /^description:/ {
      sub(/^description:[[:space:]]*>?[[:space:]]*/, "")
      if (length($0) > 0) desc = $0
      capture = 1
      next
    }
    block == 1 && capture && /^[[:space:]]/ {
      sub(/^[[:space:]]+/, "")
      desc = desc " " $0
      next
    }
    block == 1 && capture {
      capture = 0
    }
    END {
      # Remove trailing whitespace from description
      gsub(/[[:space:]]+$/, "", desc)
      # Keep only the first sentence (up to the first period followed by a space or end)
      if (match(desc, /\. /)) desc = substr(desc, 1, RSTART)
      else if (match(desc, /\.$/)) desc = substr(desc, 1, RSTART)
      # Remove leading whitespace
      gsub(/^[[:space:]]+/, "", desc)
      # Escape single quotes for shell safety
      gsub(/'\''/, "'\''\\'\'''\''", desc)
      printf "description='\''%s'\''\n", desc
    }
  ' "$skill_md")"

  # Build download link to the .skill file
  download_link="$GITHUB_RAW_BASE/$folder/$folder.skill"
  echo "| **[$name]($folder/)** | $description | [⬇ .skill]($download_link) |" >> "$TABLE_FILE"
done

# Rebuild README: keep everything outside the markers, insert the table between them
awk '
  /<!-- SKILLS_TABLE_START -->/ { print; skip=1; next }
  /<!-- SKILLS_TABLE_END -->/   { skip=0; print ""; print $0; next }
  !skip { print }
' "$README" > "$README.tmp"

# Now insert the table content after the START marker
awk -v tablefile="$TABLE_FILE" '
  /<!-- SKILLS_TABLE_START -->/ {
    print
    print ""
    while ((getline line < tablefile) > 0) print line
    next
  }
  { print }
' "$README.tmp" > "$README"

echo "Skills table in README.md updated successfully."
