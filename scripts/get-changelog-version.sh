#!/bin/bash

set -e

version=$(cat .git/ref)

repository_url=$(awk '/\[remote "origin"\]/{found=1} found && /url/{print $3; exit}' .git/config | sed 's/\.git$//')

repo_name=$(echo "$repository_url" | sed -E 's#.*/##; s#.*:##')

product_name=$(echo "$repo_name" | awk -F'[-_]' '{
  for (i=1;i<=NF;i++) {
    $i = toupper(substr($i,1,1)) substr($i,2)
  }
  print $0
}')

awk -v version="$version" '/^## / { if (p) { exit }; if ($2 == version) { p=1; next } } p && NF' CHANGELOG.md > releaselog.md

cat releaselog.md | sed -E 's/### (.*)/\n*\1*/g' | sed -E 's/^-/•/g' > templog.md

## this is left in for use in the core pipeline but nowhere else
echo ":tada: New cloud.gov $product_name Release :tada:

$repository_url/releases/tag/$version
$(cat templog.md)
" > slackrelease.md

