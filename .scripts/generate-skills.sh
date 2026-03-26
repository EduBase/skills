#!/bin/bash
# EduBase Skills Generator
# Simple script to create skill files automatically.

# Iterate through all SKILL.md files and generate corresponding .skill files from skill files
find . -type f -name "SKILL.md" | while read -r skill_md; do
  skill_dir=$(dirname "$skill_md")
  skill_filename="$(basename "$skill_dir" .md).skill"
  echo "Generating $skill_filename from ${skill_md:2}"
  cd "$skill_dir" || exit
  zip -FS -q -r "$skill_filename" . -x ".*" -x "$skill_filename"
  cd - > /dev/null || exit
done
