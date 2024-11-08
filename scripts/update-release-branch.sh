#!/bin/bash
source "${BASH_SOURCE%/*}/github-setup.sh"

git checkout -b release

# install and run commitizen: https://commitizen-tools.github.io/commitizen/
export PATH="/root/.local/bin:$PATH"
pip install --user -U Commitizen
release_body=$(cz bump --dry-run --changelog)
cz bump --yes
bump_status=$?

# if we have a bump, commit, update/create PR
if [[ $bump_status -eq 0 ]]
then
  commit_msg=$(git log -1 --pretty=%B | sed 's/chore: r/R/g')
  git push origin release --force --tags
  pr_exists=$(gh pr view release --json 'state' --jq '.state == "OPEN"')
  if [[ $pr_exists == 'true' ]]
  then
    gh pr edit \
    --title "$commit_msg" \
    --body "## :robot: This is an automated release PR
$release_body
## security considerations
Noted in individual PRs
"
  else
    gh pr create \
    --title "$commit_msg" \
    --body "## :robot: This is an automated release PR
$release_body
## security considerations
Noted in individual PRs
" \
    --base main \
    --head release
  fi
else
  echo "no update to the release"
fi
