#!/usr/bin/env bats

setup() {
  PROJECT="$BATS_TEST_TMPDIR/project"
  mkdir -p "$PROJECT/scripts/ci" "$PROJECT/fdroid" "$PROJECT/test/scripts" "$PROJECT/bin" "$PROJECT/rust"
  cp "$BATS_TEST_DIRNAME/../../scripts/ci/offline-gate.sh" "$PROJECT/scripts/ci/offline-gate.sh"
  printf 'name: fixture\nversion: 1.2.3+45\n' > "$PROJECT/pubspec.yaml"
  printf 'lock\n' > "$PROJECT/pubspec.lock"
  printf 'rust lock\n' > "$PROJECT/rust/Cargo.lock"
  printf '9.9.9\n' > "$PROJECT/fdroid/flutter.version"
  printf '@test "placeholder" { true; }\n' > "$PROJECT/test/scripts/example.bats"

  export CALLS="$BATS_TEST_TMPDIR/calls.log"
  : > "$CALLS"
  export FAKE_FAIL_STAGE="${FAKE_FAIL_STAGE:-}"

  cat > "$PROJECT/bin/flutter" <<'EOF_FLUTTER'
#!/usr/bin/env bash
if [[ "${1:-}" == "--version" ]]; then
  printf 'Flutter 9.9.9 • channel [user-branch]\n'
  exit 0
fi
printf 'flutter %s\n' "$*" >> "${CALLS:?}"
if [[ -n "${FAKE_FAIL_STAGE:-}" && "${1:-} ${2:-}" == *"$FAKE_FAIL_STAGE"* ]]; then
  printf 'simulated %s failure\n' "$FAKE_FAIL_STAGE" >&2
  exit 42
fi
EOF_FLUTTER

  cat > "$PROJECT/bin/python3" <<'EOF_PY'
#!/usr/bin/env bash
if [[ "${1:-}" != "-m" ]]; then exec /usr/bin/python3 "$@"; fi
printf 'python %s\n' "$*" >> "${CALLS:?}"
if [[ "${FAKE_FAIL_STAGE:-}" == "python" ]]; then exit 43; fi
EOF_PY

  cat > "$PROJECT/bin/bats" <<'EOF_BATS'
#!/usr/bin/env bash
printf 'bats %s\n' "$*" >> "${CALLS:?}"
if [[ "${FAKE_FAIL_STAGE:-}" == "bats" ]]; then exit 44; fi
EOF_BATS

  cat > "$PROJECT/bin/cargo" <<'EOF_CARGO'
#!/usr/bin/env bash
printf 'cargo %s\n' "$*" >> "${CALLS:?}"
if [[ "${FAKE_FAIL_STAGE:-}" == "cargo-${1:-}" ]]; then exit 45; fi
if [[ "${FAKE_FAIL_STAGE:-}" == "rust-lock" ]]; then printf 'drift\n' >> rust/Cargo.lock; fi
EOF_CARGO
  export PATH="$PROJECT/bin:$PATH"
  chmod +x "$PROJECT/bin/flutter" "$PROJECT/bin/python3" "$PROJECT/bin/bats" "$PROJECT/bin/cargo"
}

run_gate() {
  cd "$PROJECT"
  run "$PROJECT/scripts/ci/offline-gate.sh" \
    --flutter-bin "$PROJECT/bin/flutter" \
    --python-bin "$PROJECT/bin/python3" \
    --bats-bin "$PROJECT/bin/bats" \
    --log-dir "$BATS_TEST_TMPDIR/logs" "$@"
}

@test "runs the documented stages in order and preserves the lockfile" {
  run_gate --json
  [ "$status" -eq 0 ]
  [[ "$output" == *'"verdict": "passed"'* ]] || [[ "$output" == *'"verdict":"passed"'* ]]
  [[ "$output" == *'"lock_unchanged": true'* ]] || [[ "$output" == *'"lock_unchanged":true'* ]]

  mapfile -t calls < <(cat "$CALLS")
  [ "${calls[0]}" = "flutter pub get --offline --enforce-lockfile" ]
  [ "${calls[1]}" = "cargo fmt --manifest-path rust/Cargo.toml --all -- --check" ]
  [ "${calls[2]}" = "cargo clippy --manifest-path rust/Cargo.toml --workspace --all-targets --locked --offline -- -D warnings" ]
  [ "${calls[3]}" = "cargo test --manifest-path rust/Cargo.toml --workspace --locked --offline" ]
  [ "${calls[4]}" = "flutter analyze --no-pub" ]
  [ "${calls[5]}" = "flutter test --no-pub" ]
  [ "${calls[6]}" = "python -m pytest test/research test/scripts -q" ]
  [[ "${calls[7]}" == bats\ test/scripts/* ]]

  [ -f "$BATS_TEST_TMPDIR/logs/offline-gate.json" ]
  [ -f "$BATS_TEST_TMPDIR/logs/flutter-tests.log" ]
  [[ "$output" == *'"rust_lock_unchanged": true'* ]]
  export FAKE_FAIL_STAGE="rust-lock"
  : > "$CALLS"
  run_gate --json
  [ "$status" -eq 1 ]
  [[ "$output" == *'"rust_lock_unchanged": false'* ]]
  ! grep -q '^flutter analyze' "$CALLS"
}

@test "Cargo failures and a missing executable fail closed before Flutter checks" {
  for stage in fmt clippy test; do
    export FAKE_FAIL_STAGE="cargo-$stage"
    : > "$CALLS"
    run_gate --json
    [ "$status" -eq 1 ]
    [[ "$output" == *"\"failed_stage\": \"cargo-$stage\""* ]]
    ! grep -q '^flutter analyze' "$CALLS"
  done
  # A PATH-only missing command must not fall back to the real host cargo.
  rm "$PROJECT/bin/cargo"
  mkdir "$PROJECT/without-cargo"
  for tool in bash dirname basename mkdir tr grep head sha256sum awk timeout tail python3; do
    ln -s "$(command -v "$tool")" "$PROJECT/without-cargo/$tool"
  done
  local original_path="$PATH"
  export PATH="$PROJECT/without-cargo"
  run_gate --json
  [ "$status" -eq 1 ]
  [[ "$output" == *'"failed_stage": "cargo-fmt"'* ]]
  export PATH="$original_path"
}

@test "a failing stage stops later stages and reports the failed stage" {
  export FAKE_FAIL_STAGE="test"
  run_gate --json
  [ "$status" -eq 1 ]

  run grep -q '"failed_stage": "flutter-tests"' "$BATS_TEST_TMPDIR/logs/offline-gate.json"
  [ "$status" -eq 0 ]
  run grep -q '^python ' "$CALLS"
  [ "$status" -ne 0 ]
  run grep -q '^bats ' "$CALLS"
  [ "$status" -ne 0 ]
}

@test "reports the failing script stage without hiding the exit" {
  export FAKE_FAIL_STAGE="bats"
  run_gate --json
  [ "$status" -eq 1 ]
  run grep -q '"failed_stage": "bats-tests"' "$BATS_TEST_TMPDIR/logs/offline-gate.json"
  [ "$status" -eq 0 ]
}

@test "refuses an SDK that does not match fdroid/flutter.version" {
  printf '3.47.9\n' > "$PROJECT/fdroid/flutter.version"
  run_gate --json
  [ "$status" -eq 2 ]
  [[ "$output" == *"does not match pinned 3.47.9"* ]]
  [ ! -s "$CALLS" ]
}

@test "refuses a log directory inside the checkout" {
  cd "$PROJECT"
  run "$PROJECT/scripts/ci/offline-gate.sh" \
    --flutter-bin "$PROJECT/bin/flutter" \
    --log-dir "$PROJECT/logs"
  [ "$status" -eq 2 ]
  [[ "$output" == *"must live outside the checkout"* ]]
  [ ! -s "$CALLS" ]
}
