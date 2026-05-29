#!/bin/bash

# Check if the user provided a repository parameter
if [ -z "$1" ]; then
  echo "Error: No repository specified."
  echo "Usage: $0 <owner/repo>"
  echo "Example: $0 jmfinelli/narayana"
  exit 1
fi

REPO=$1

echo "WARNING: This will permanently delete up to 1000 labels in '$REPO'."
echo "Starting label deletion process..."

# Execute the gh command to list labels and delete them one by one
gh label list --repo "$REPO" --limit 1000 --json name --jq '.[].name' | xargs -I {} gh label delete "{}" --repo "$REPO" --yes

# Check if the command was successful
if [ $? -eq 0 ]; then
  echo "Done! All labels in '$REPO' have been deleted."
else
  echo "Process finished, but there may have been errors. Make sure you have the correct permissions."
fi
