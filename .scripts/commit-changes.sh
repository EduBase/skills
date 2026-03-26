#!/bin/bash
# Push changes to the repository and create a new tag if there are any changes

git config --local user.name "github-actions[bot]"
git config --local user.email "github-actions[bot]@users.noreply.github.com"
git add .
if [ -z "$(git status --porcelain)" ]; then
  echo "changed=false" >> "$GITHUB_OUTPUT"
  exit 0
fi
git commit -m "Update skills"
PREVIOUS_VERSION=$(git describe --tags --abbrev=0)
echo "old_tag=$PREVIOUS_VERSION" >> "$GITHUB_OUTPUT"
VERSION=$(echo "$PREVIOUS_VERSION" | awk -F. '{OFS="."; $NF+=1; print $0}')
echo "new_tag=$VERSION" >> "$GITHUB_OUTPUT"
echo "Creating tag $VERSION based on previous tag $PREVIOUS_VERSION"
git tag -a "$VERSION" -m "Update skills to version $VERSION"
git push --atomic origin main "$VERSION"
echo "changed=true" >> "$GITHUB_OUTPUT"
