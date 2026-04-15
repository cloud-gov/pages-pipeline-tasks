load "helpers/repo"

setup() {
  export PRODUCT_NAME=""
}

teardown() {
  rm -f slackrelease.md
  rm -rf "$TEST_DIR"
}

@test "script generates slackrelease.md for pages-core" {
  setup_fake_repo pages-core-repo
  run bash "$BATS_TEST_DIRNAME/../scripts/get-changelog-version.sh"

  [ "$status" -eq 0 ]
  [ -f slackrelease.md ]

  echo "___________ slackrelease.md" >&3
  cat slackrelease.md >&3
  
  grep -q ":tada: New cloud.gov Pages Core Release :tada:" slackrelease.md
  grep -q "https://github.com/cloud-gov/pages-core/releases/tag/0.21.0" slackrelease.md

  grep -q "*Added*" slackrelease.md
  grep -q "• create workshop site build flow 4856" slackrelease.md
  grep -q "• feat: create workshop oauth flow 4855" slackrelease.md
  grep -q "• Update app to Node v22 and update the dependencies" slackrelease.md
  grep -q "• Add site delete webhook for publisher site" slackrelease.md

  grep -q "*Fixed*" slackrelease.md
  grep -q "• branch with an invalid name should create an invalid build #2375" slackrelease.md
  grep -q "• remove deprecated component" slackrelease.md
  grep -q "• force patched version of fast-xml-parser" slackrelease.md
  grep -q "• set node value in Docker" slackrelease.md
  grep -q "• include screen reader text and update 404 test to expect updated login string" slackrelease.md
  grep -q "• adjust slightly navigation text style" slackrelease.md
  grep -q "• Audit and fix dependencies #4845" slackrelease.md
  grep -q "• Publisher endpoint host environment variable" slackrelease.md
  grep -q "• Use the correct bound route service domain by env" slackrelease.md

  grep -q "*Maintenance*" slackrelease.md
  grep -q "• Remove deprecated security-considerations automation files" slackrelease.md
  grep -q "• update to use new branding logos" slackrelease.md
  grep -q "• update color palette" slackrelease.md
  grep -q "• update styling to revise color palette" slackrelease.md
  grep -q "• update admin-client node engine" slackrelease.md
  grep -q "• update favicons with new pages logo" slackrelease.md
  grep -q "• update styles and menus" slackrelease.md
}

@test "script generates slackrelease.md for pages-editor" {
  setup_fake_repo pages-editor-repo
  run bash "$BATS_TEST_DIRNAME/../scripts/get-changelog-version.sh"

  [ "$status" -eq 0 ]
  [ -f slackrelease.md ]

  echo "___________ slackrelease.md" >&3
  cat slackrelease.md >&3

  grep -q ":tada: New cloud.gov Pages Editor Release :tada:" slackrelease.md
  grep -q "https://github.com/cloud-gov/pages-editor/releases/tag/0.4.0" slackrelease.md

  grep -q "*Added*" slackrelease.md"
  grep -q "• Add layout type to collection types for list or card grid view" slackrelease.md
  grep -q "• Refine ATU package and dashboard" slackrelease.md
  grep -q "• add active state to admin nav links" slackrelease.md
  grep -q "• **ci**: Add access tests to SiteAuth collection and ATU package" slackrelease.md
  grep -q "• Add site ATU package for managers to download" slackrelease.md
  grep -q "• Add site auth global collection to manage ATU" slackrelease.md
  grep -q "• Add site compliance ATU Package and compliance section" slackrelease.md
  grep -q "• Add site compliance ATU docs page" slackrelease.md
  grep -q "• Add side nav collection to collection entries and pages" slackrelease.md
  grep -q "• Add collection type edit link in type card" slackrelease.md
  grep -q "• Add build site hook on record unpublish or delete" slackrelease.md

  grep -q "*Fixed*" slackrelease.md
  grep -q "• call headers with await" slackrelease.md
  grep -q "• typescript errors" slackrelease.md
  grep -q "• Table heading width to allow the first heading to expand based on content" slackrelease.md

  grep -q "*Maintenance*" slackrelease.md" slackrelease.md
  grep -q "• replace merged Nav components" slackrelease.md
  grep -q "• Remove security considerations action" slackrelease.md
}

