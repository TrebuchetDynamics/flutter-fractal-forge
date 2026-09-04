#!/usr/bin/env bats

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  export RELEASE_ARTIFACT_DIR="$BATS_TEST_TMPDIR/artifacts"
  mkdir -p "$RELEASE_ARTIFACT_DIR"
  export FLUTTER_BIN="$BATS_TEST_TMPDIR/forbidden-flutter"
  printf '#!/bin/sh\necho BUILD_WAS_INVOKED >&2\nexit 99\n' > "$FLUTTER_BIN"
  chmod +x "$FLUTTER_BIN"
}

@test "all dry-run neither builds nor removes existing release evidence" {
  existing="$RELEASE_ARTIFACT_DIR/fractal-forge-release-evidence-vold.tar.gz"
  printf 'keep this artifact\n' > "$existing"
  run "$REPO_ROOT/scripts/release.sh" all --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" != *BUILD_WAS_INVOKED* ]]
  [[ "$output" == *"DRY RUN: build and package the Linux release bundle"* ]]
  [[ "$output" == *"DRY RUN: dispatch unsigned Apple builds"* ]]
  [[ "$output" == *"DRY RUN: generate and verify release evidence"* ]]
  [ "$(cat "$existing")" = 'keep this artifact' ]
  [ ! -e "$RELEASE_ARTIFACT_DIR/evidence" ]
}

@test "Apple dry-run requires no build identity or signing credentials" {
  run "$REPO_ROOT/scripts/release.sh" apple --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"not App Store-ready"* ]]
}
