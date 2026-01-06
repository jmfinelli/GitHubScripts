# This script was found [here](https://www.eliostruyf.com/monitor-github-actions-storage-usage-script/)

if ! gh auth status > /dev/null 2>&1; then
  echo "Please authenticate with the GitHub CLI using 'gh auth login'."
  exit 1
fi
if [ -z "$1" ]; then
  echo "Usage: $0 <owner>"
  echo "Example: $0 owner"
  exit 1
fi

OWNER=$1
echo "Is the owner an organization or a user? (org/user)"
read -r OWNER_TYPE

if [[ "$OWNER_TYPE" != "org" && "$OWNER_TYPE" != "user" ]]; then
  echo "Invalid input. Please specify 'org' or 'user'."
  exit 1
fi

echo "Fetching repositories for owner: $OWNER"

PAGE=1
TOTAL_ARTIFACT_SIZE=0
TOTAL_CACHE_SIZE=0

while true; do
  if [ "$OWNER_TYPE" == "org" ]; then
    REPOS_RESPONSE=$(gh api -H "Accept: application/vnd.github+json" \
      "/orgs/$OWNER/repos?type=all&per_page=100&page=$PAGE")
  else
    REPOS_RESPONSE=$(gh api -H "Accept: application/vnd.github+json" \
      "/users/$OWNER/repos?type=all&per_page=100&page=$PAGE")
  fi

  REPOS=$(echo "$REPOS_RESPONSE" | jq -r '.[].full_name')
  if [ -z "$REPOS" ]; then
    break
  fi

  echo "Repositories on page $PAGE:"
  echo "$REPOS"

  for REPO in $REPOS; do
    echo "Processing repository: $REPO"
    REPO_PAGE=1
    REPO_ARTIFACT_SIZE=0

    while true; do
      RESPONSE=$(gh api -H "Accept: application/vnd.github+json" \
        "/repos/$REPO/actions/artifacts?per_page=100&page=$REPO_PAGE")
      SIZES=$(echo "$RESPONSE" | jq '.artifacts[].size_in_bytes' 2>/dev/null)
      if [ -z "$SIZES" ]; then
        break
      fi

      for SIZE in $SIZES; do
        REPO_ARTIFACT_SIZE=$((REPO_ARTIFACT_SIZE + SIZE))
      done
      HAS_NEXT_PAGE=$(echo "$RESPONSE" | jq '.artifacts | length == 100')
      if [ "$HAS_NEXT_PAGE" != "true" ]; then
        break
      fi

      REPO_PAGE=$((REPO_PAGE + 1))
    done
    CACHE_RESPONSE=$(gh api -H "Accept: application/vnd.github+json" \
      "/repos/$REPO/actions/cache/usage")

    REPO_CACHE_SIZE=$(echo "$CACHE_RESPONSE" | jq '.active_caches_size_in_bytes // 0')
    TOTAL_ARTIFACT_SIZE=$((TOTAL_ARTIFACT_SIZE + REPO_ARTIFACT_SIZE))
    TOTAL_CACHE_SIZE=$((TOTAL_CACHE_SIZE + REPO_CACHE_SIZE))
    REPO_ARTIFACT_SIZE_GB=$(echo "scale=2; $REPO_ARTIFACT_SIZE / 1024 / 1024 / 1024" | bc)
    REPO_CACHE_SIZE_GB=$(echo "scale=2; $REPO_CACHE_SIZE / 1024 / 1024 / 1024" | bc)

    echo "Total artifact size for $REPO: $REPO_ARTIFACT_SIZE_GB GB"
    echo "Total cache size for $REPO: $REPO_CACHE_SIZE_GB GB"
  done
  HAS_NEXT_PAGE=$(echo "$REPOS_RESPONSE" | jq 'length == 100')
  if [ "$HAS_NEXT_PAGE" != "true" ]; then
    break
  fi

  PAGE=$((PAGE + 1))
done
TOTAL_ARTIFACT_SIZE_GB=$(echo "scale=2; $TOTAL_ARTIFACT_SIZE / 1024 / 1024 / 1024" | bc)
TOTAL_CACHE_SIZE_GB=$(echo "scale=2; $TOTAL_CACHE_SIZE / 1024 / 1024 / 1024" | bc)

echo "========================================"
echo "Total artifact size across all repositories: $TOTAL_ARTIFACT_SIZE_GB GB"
echo "Total cache size across all repositories: $TOTAL_CACHE_SIZE_GB GB"
