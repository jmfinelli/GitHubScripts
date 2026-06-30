#!/usr/bin/env bash
# Deletes workflow runs for a GitHub repository using GH CLI
# Usage:
#   ./delete-gh-runs.sh [owner/repo] [--pr <number>]
#
# Examples:
#   ./delete-gh-runs.sh myorg/myrepo
#   ./delete-gh-runs.sh myorg/myrepo --pr 123

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
    RUN_IDS=$(gh run list --repo "$REPO" --limit 500 --json databaseId,event,headBranch \
      -q ".[] | select(.event == \"pull_request\" and .headBranch == \"$HEAD_BRANCH\") | .databaseId")
  else
    # Get all workflow runs
    RUN_IDS=$(gh run list --repo "$REPO" --limit 500 --json databaseId -q '.[].databaseId')
  fi

  if [ -z "$RUN_IDS" ]; then
    echo "✅ No more runs to delete."
    break
  fi

  TOTAL=$(echo "$RUN_IDS" | wc -l | tr -d ' ')
  echo "📊 Found $TOTAL runs to delete in this batch"
  COUNT=0

  echo "$RUN_IDS" | while read -r RUN_ID; do
    if [ -n "$RUN_ID" ]; then
      COUNT=$((COUNT + 1))
      echo "🗑️  [$COUNT/$TOTAL] Deleting run ID: $RUN_ID"
      for attempt in 1 2 3; do
        if gh run delete "$RUN_ID" --repo "$REPO" 2>/dev/null; then
          break
        fi
        echo "⚠️  Attempt $attempt failed for $RUN_ID, retrying in $((attempt * 5))s..."
        sleep $((attempt * 5))
      done
      sleep 0.3
    fi
  done
done

