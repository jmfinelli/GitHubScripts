#!/usr/bin/env bash
# Deletes workflow runs for a GitHub repository using GH CLI
# Usage:
#   ./delete-gh-runs.sh [owner/repo] [--pr <number>]
#
# Examples:
#   ./delete.sh myorg/myrepo
#   ./delete.sh myorg/myrepo --pr 123

set -e

REPO=""
PR_NUMBER=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --pr)
      PR_NUMBER="$2"
      shift 2
      ;;
    *)
      REPO="$1"
      shift
      ;;
  esac
done

# Default repo if not provided
REPO=${REPO:-$(gh repo view --json jmfinelli -q .jmfinelli)}

echo "🔍 Target repository: $REPO"
if [ -n "$PR_NUMBER" ]; then
  echo "🔍 Filtering by PR number: #$PR_NUMBER"
fi

# If PR specified, get its head branch name
if [ -n "$PR_NUMBER" ]; then
  HEAD_BRANCH=$(gh pr view "$PR_NUMBER" --repo "$REPO" --json headRefName -q .headRefName 2>/dev/null || true)
  if [ -z "$HEAD_BRANCH" ]; then
    echo "❌ Could not find PR #$PR_NUMBER in $REPO"
    exit 1
  fi
  echo "📎 PR #$PR_NUMBER is from branch '$HEAD_BRANCH'"
fi

echo "Fetching runs for $REPO..."

while true; do
  if [ -n "$PR_NUMBER" ]; then
    # Filter workflow runs triggered by pull requests and matching branch
    RUN_IDS=$(gh run list --repo "$REPO" --limit 100 --json databaseId,event,headBranch \
      -q ".[] | select(.event == \"pull_request\" and .headBranch == \"$HEAD_BRANCH\") | .databaseId")
  else
    # Get all workflow runs
    RUN_IDS=$(gh run list --repo "$REPO" --limit 100 --json databaseId -q '.[].databaseId')
  fi

  if [ -z "$RUN_IDS" ]; then
    echo "✅ No more runs to delete."
    break
  fi

  echo "$RUN_IDS" | while read -r RUN_ID; do
    if [ -n "$RUN_ID" ]; then
      echo "🗑️  Deleting run ID: $RUN_ID"
      gh run delete "$RUN_ID" --repo "$REPO"
    fi
  done
done

