#!/usr/bin/env bats

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  TEST_REPO="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$TEST_REPO"
  git -C "$TEST_REPO" init -q
  git -C "$TEST_REPO" config user.email test@example.com
  git -C "$TEST_REPO" config user.name Test
  printf 'version: 1.1.0+38\n' >"$TEST_REPO/pubspec.yaml"
  git -C "$TEST_REPO" add pubspec.yaml
  git -C "$TEST_REPO" commit -qm initial
  git -C "$TEST_REPO" tag v1.1.90

  resolver="$({
    awk '
      /^resolve_upcoming_android_version\(\)/ { capture=1 }
      capture { print }
      capture && /^}/ { exit }
    ' "$REPO_ROOT/scripts/release.sh"
  })"
}

@test "defaults to the release after the latest numeric tag" {
  run bash -c '
    set -euo pipefail
    cd "$1"
    die() { echo "$*" >&2; return 1; }
    eval "$2"
    PUBLISH_BUILD_NUMBER=
    resolve_upcoming_android_version
    printf "%s+%s" "$RESOLVED_ANDROID_VERSION" "$RESOLVED_ANDROID_BUILD_NUMBER"
  ' _ "$TEST_REPO" "$resolver"

  [ "$status" -eq 0 ]
  [ "$output" = "1.1.91+91" ]
}

@test "accepts an explicitly confirmed gap for a consumed untagged version" {
  run bash -c '
    set -euo pipefail
    cd "$1"
    die() { echo "$*" >&2; return 1; }
    eval "$2"
    PUBLISH_BUILD_NUMBER=92
    resolve_upcoming_android_version
    printf "%s+%s" "$RESOLVED_ANDROID_VERSION" "$RESOLVED_ANDROID_BUILD_NUMBER"
  ' _ "$TEST_REPO" "$resolver"

  [ "$status" -eq 0 ]
  [ "$output" = "1.1.92+92" ]
}

@test "rejects a confirmed build at or behind the latest tag" {
  run bash -c '
    set -euo pipefail
    cd "$1"
    die() { echo "$*" >&2; return 1; }
    eval "$2"
    PUBLISH_BUILD_NUMBER=90
    resolve_upcoming_android_version
  ' _ "$TEST_REPO" "$resolver"

  [ "$status" -ne 0 ]
  [[ "$output" == *"must be newer than v1.1.90"* ]]
}
