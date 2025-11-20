#!/bin/bash
# Script to delete GitHub Actions artifacts from a specified repository
# Usage: ./delete_artifacts.sh org/repo
# Requires: GitHub CLI (gh) and jq
# Make sure you are logged in via `gh auth login`

# Check if repository argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <repository>"
  echo "Example: $0 my-org/my-repo"
  exit 1
fi

REPO="$1"

echo "======================================"
echo "Processing repository: $REPO"

# Fetch artifact IDs using jq
ARTIFACT_IDS=$(gh api /repos/"$REPO"/actions/artifacts --paginate | jq -r '.artifacts[].id')

if [ -z "$ARTIFACT_IDS" ]; then
  echo "No artifacts to delete."
else
  echo "Found artifacts: "
  echo "$ARTIFACT_IDS"
  for ID in $ARTIFACT_IDS; do
    echo "Deleting artifact ID: $ID"
    gh api -X DELETE /repos/"$REPO"/actions/artifacts/$ID --silent
    sleep 1  # Avoid hitting API rate limits
  done
fi

echo "All done!"

