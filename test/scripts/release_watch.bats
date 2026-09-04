#!/usr/bin/env bats

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  export WATCH_ATTEMPTS="$BATS_TEST_TMPDIR/attempts"
  printf '0' > "$WATCH_ATTEMPTS"
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
  cat > "$BATS_TEST_TMPDIR/bin/gh" <<'MOCK'
#!/bin/sh
attempt=$(cat "$WATCH_ATTEMPTS")
attempt=$((attempt + 1))
printf '%s' "$attempt" > "$WATCH_ATTEMPTS"
[ "$attempt" -gt "${FAIL_UNTIL:-2}" ] || exit 1
printf 'completed\tsuccess\thttps://github.com/example/actions/runs/123\n'
MOCK
  chmod +x "$BATS_TEST_TMPDIR/bin/gh"
  # Source the real polling function without executing release stages.
  sed -n '/^watch_github_run() {$/,/^}$/p' "$REPO_ROOT/scripts/release.sh" > "$BATS_TEST_TMPDIR/watch.sh"
}

@test "CI watcher recovers from transient API failures" {
  run bash -c 'source "$1"; log() { echo "$*"; }; die() { echo "$*"; exit 1; }; watch_github_run 123 test 0' _ "$BATS_TEST_TMPDIR/watch.sh"
  [ "$status" -eq 0 ]
  [ "$(cat "$WATCH_ATTEMPTS")" = 3 ]
  [[ "$output" == *completed/success* ]]
}

@test "CI watcher stops after four consecutive API failures" {
  export FAIL_UNTIL=99
  run bash -c 'source "$1"; log() { echo "$*"; }; die() { echo "$*"; exit 1; }; watch_github_run 123 test 0' _ "$BATS_TEST_TMPDIR/watch.sh"
  [ "$status" -eq 1 ]
  [ "$(cat "$WATCH_ATTEMPTS")" = 4 ]
  [[ "$output" == *"after 4 attempts"* ]]
}
