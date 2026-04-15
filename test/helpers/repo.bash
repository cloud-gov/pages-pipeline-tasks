setup_fake_repo() {

  local fixture="${1:-default}"

  TEST_DIR="$(mktemp -d)"
  export TEST_DIR

  rsync -a "$BATS_TEST_DIRNAME/fixtures/$fixture/" "$TEST_DIR/repo/"

  mv "$TEST_DIR/repo/git" "$TEST_DIR/repo/.git"

  cd "$TEST_DIR/repo"
}