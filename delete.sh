#!/usr/bin/env bash
# Deletes all workflow runs for a GitHub repository using GH CLI
# Usage: ./delete-gh-runs.sh [owner/repo]

REPO=${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}

echo "Fetching runs for $REPO..."

# Paginate through all workflow runs
while true; do
  RUN_IDS=$(gh run list --repo "$REPO" --limit 100 --json databaseId -q '.[].databaseId')
  
  if [ -z "$RUN_IDS" ]; then
    echo "✅ No more runs to delete."
    break
  fi

  echo "$RUN_IDS" | while read -r RUN_ID; do
    if [ -n "$RUN_ID" ]; then
      echo "🗑️ Deleting run ID: $RUN_ID"
      gh run delete "$RUN_ID" --repo "$REPO"
    fi
  done
done

