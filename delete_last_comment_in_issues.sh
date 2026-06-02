#!/bin/bash

# Check if exactly 2 arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <owner> <repo>"
    echo "Example: $0 octocat Hello-World"
    exit 1
fi

OWNER=$1
REPO=$2

echo "Targeting repository: $OWNER/$REPO"
echo "========================================"

# Fetch the numbers of all open issues for the specified repo
ISSUES=$(gh issue list -R "$OWNER/$REPO" --limit 1000 --json number --jq '.[].number')

for ISSUE_NUM in $ISSUES; do
  echo "Checking issue #$ISSUE_NUM..."

  # Fetch all comments for the issue and store the JSON in a variable
  COMMENTS_JSON=$(gh api "repos/$OWNER/$REPO/issues/$ISSUE_NUM/comments")

  # Extract the ID of the last comment
  # Using `// empty` in jq ensures it returns blank instead of "null" if no comments exist
  LAST_COMMENT_ID=$(echo "$COMMENTS_JSON" | jq -r '.[-1].id // empty')

  if [ -n "$LAST_COMMENT_ID" ]; then
    # Extract the actual text (body) of the last comment
    LAST_COMMENT_BODY=$(echo "$COMMENTS_JSON" | jq -r '.[-1].body')
    
    echo " -> Found last comment ID: $LAST_COMMENT_ID"
    echo " -> Comment text:"
    
    # Print the comment text, indenting each line by 6 spaces for readability
    echo "$LAST_COMMENT_BODY" | sed 's/^/      /'
    
    echo " -> Deleting..."
    
    # THE DESTRUCTIVE COMMAND: Remove the '#' below to actually delete the comment
    gh api -X DELETE "repos/$OWNER/$REPO/issues/comments/$LAST_COMMENT_ID" > /dev/null
    
    # Uncomment the line below if you uncomment the deletion command above
    echo " -> Deleted."
  else
    echo " -> No comments found on issue #$ISSUE_NUM."
  fi
  
  # Print a separator between issues for easier reading
  echo "----------------------------------------"
done

echo "Done."
