#!/bin/bash

# Check if the user provided a repository parameter
if [ -z "$1" ]; then
  echo "Error: No repository specified."
  echo "Usage: $0 <owner/repo>"
  echo "Example: $0 jmfinelli/narayana"
  exit 1
fi

REPO=$1

echo "WARNING: This will permanently delete up to 1000 issues in '$REPO'."
echo "Starting deletion process..."

# Execute the gh command using the provided repository parameter
gh issue list --repo "$REPO" --state all --limit 1000 --json url --jq '.[].url' | xargs -I {} gh issue delete {} --yes

# Check if the command was successful
if [ $? -eq 0 ]; then
  echo "Done! Issues in '$REPO' have been deleted."
else
  echo "Process finished, but there may have been errors. Make sure you have admin rights to this repository."
fi
