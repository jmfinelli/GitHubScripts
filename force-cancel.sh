OWNER=$1
REPO=$2
RUN_ID=$3

gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/OWNER/REPO/actions/runs/RUN_ID/force-cancel
