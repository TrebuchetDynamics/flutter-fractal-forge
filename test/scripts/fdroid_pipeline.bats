#!/usr/bin/env bats

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  OUTPUT_DIR="$BATS_TEST_TMPDIR/fdroid-output"
  COMMIT="$(git -C "$REPO_ROOT" rev-parse HEAD)"
  BUILT_APK="$REPO_ROOT/build/app/outputs/flutter-apk/app-release.apk"
  if [[ -f "$BUILT_APK" ]]; then
    cp "$BUILT_APK" "$BATS_TEST_TMPDIR/original-app-release.apk"
  fi
}

teardown() {
  if [[ -f "$BATS_TEST_TMPDIR/original-app-release.apk" ]]; then
    mkdir -p "$(dirname "$BUILT_APK")"
    cp "$BATS_TEST_TMPDIR/original-app-release.apk" "$BUILT_APK"
  else
    rm -f "$BUILT_APK"
  fi
}

@test "metadata-only mode produces an official fdroiddata recipe bound to the release commit" {
  run "$REPO_ROOT/scripts/build-fdroid.sh" \
    --metadata-only \
    --version=1.1.95 \
    --build-number=95 \
    --commit="$COMMIT" \
    --output-dir="$OUTPUT_DIR"

  [ "$status" -eq 0 ]
  metadata="$OUTPUT_DIR/fdroiddata/metadata/com.trebuchetdynamics.fractal.forge.yml"
  [ -f "$metadata" ]
  grep -Fq 'RepoType: git' "$metadata"
  grep -Fq 'versionName: 1.1.95' "$metadata"
  grep -Fq 'versionCode: 95' "$metadata"
  grep -Fq "commit: $COMMIT" "$metadata"
  grep -Fq 'flutter@3.44.6' "$metadata"
  grep -Fq 'ndk: r28c' "$metadata"
  grep -Fq 'UpdateCheckMode: Tags' "$metadata"
  grep -Fq "version_name=\$(sed -n 's/^versionName=//p' fdroid/version.properties)" "$metadata"
  grep -Fq 'export PUB_CACHE="$(pwd)/.pub-cache"' "$metadata"
  grep -Fq -- '- docs/qa/fractal-audits' "$metadata"
  ! grep -Fq 'PUB_CACHE=\"' "$metadata"
  ! grep -Fq -- '--build-name=1.1.95' "$metadata"
  ! grep -Fq -- '- node_modules' "$metadata"
  ! grep -Fq -- '- opensource' "$metadata"
  archive="$OUTPUT_DIR/fractal-forge-fdroiddata-v1.1.95.tar.gz"
  [ -f "$archive" ]
  ! grep -Fq "$OUTPUT_DIR/" "$archive.sha256"
}

@test "pipeline rejects a release identity absent from the tracked F-Droid marker" {
  run "$REPO_ROOT/scripts/build-fdroid.sh" \
    --metadata-only \
    --version=1.1.96 \
    --build-number=96 \
    --commit="$COMMIT" \
    --output-dir="$OUTPUT_DIR"

  [ "$status" -ne 0 ]
  [[ "$output" == *"fdroid/version.properties does not match 1.1.96+96"* ]]
}

@test "F-Droid APK verifier rejects an upstream-signed package" {
  tools="$BATS_TEST_TMPDIR/tools"
  mkdir -p "$tools"
  cat >"$tools/aapt" <<'SH'
#!/usr/bin/env bash
echo "package: name='com.trebuchetdynamics.fractal.forge' versionCode='93' versionName='1.1.93'"
SH
  cat >"$tools/apksigner" <<'SH'
#!/usr/bin/env bash
exit 0
SH
  cat >"$tools/unzip" <<'SH'
#!/usr/bin/env bash
printf '%s\n' lib/armeabi-v7a/libapp.so lib/arm64-v8a/libapp.so lib/x86_64/libapp.so
SH
  chmod +x "$tools/aapt" "$tools/apksigner" "$tools/unzip"
  touch "$BATS_TEST_TMPDIR/app-release.apk"

  run env PATH="$tools:$PATH" "$REPO_ROOT/scripts/verify-fdroid-apk.sh" \
    "$BATS_TEST_TMPDIR/app-release.apk" 1.1.93 93

  [ "$status" -ne 0 ]
  [[ "$output" == *"F-Droid APK must be unsigned"* ]]
}

@test "full pipeline builds and stages an unsigned source artifact with provenance" {
  tools="$BATS_TEST_TMPDIR/build-tools"
  mkdir -p "$tools"
  cat >"$tools/flutter" <<'SH'
#!/usr/bin/env bash
if [[ "${1:-}" == "--version" ]]; then
  echo 'Flutter 3.44.6 • channel stable'
  exit 0
fi
if [[ "${1:-}" == "pub" && "${2:-}" == "get" ]]; then
  exit 0
fi
if [[ "${1:-}" == "build" && "${2:-}" == "apk" ]]; then
  mkdir -p build/app/outputs/flutter-apk
  printf 'deterministic unsigned apk fixture\n' > build/app/outputs/flutter-apk/app-release.apk
  exit 0
fi
exit 64
SH
  cat >"$tools/aapt" <<'SH'
#!/usr/bin/env bash
echo "package: name='com.trebuchetdynamics.fractal.forge' versionCode='95' versionName='1.1.95'"
SH
  cat >"$tools/apksigner" <<'SH'
#!/usr/bin/env bash
exit 1
SH
  cat >"$tools/unzip" <<'SH'
#!/usr/bin/env bash
printf '%s\n' lib/armeabi-v7a/libapp.so lib/arm64-v8a/libapp.so lib/x86_64/libapp.so
SH
  chmod +x "$tools/flutter" "$tools/aapt" "$tools/apksigner" "$tools/unzip"

  run env PATH="$tools:$PATH" "$REPO_ROOT/scripts/build-fdroid.sh" \
    --flutter-bin="$tools/flutter" \
    --version=1.1.95 \
    --build-number=95 \
    --commit="$COMMIT" \
    --output-dir="$OUTPUT_DIR"

  [ "$status" -eq 0 ]
  apk="$OUTPUT_DIR/fractal-forge-fdroid-v1.1.95-unsigned.apk"
  [ -f "$apk" ]
  [ -f "$apk.provenance" ]
  ! grep -Fq "$OUTPUT_DIR/" "$apk.sha256"
  grep -Fq 'unsigned=true' "$apk.provenance"
  grep -Fq "commit=$COMMIT" "$apk.provenance"
}

@test "release orchestrator exposes an official F-Droid source-build stage" {
  run "$REPO_ROOT/scripts/release.sh" fdroid --dry-run

  [ "$status" -eq 0 ]
  [[ "$output" == *"fdroid: official catalog source-build readiness"* ]]
  [[ "$output" == *"DRY RUN: build an unsigned reproducible APK"* ]]
  [[ "$output" != *"not implemented"* ]]
}

@test "tag workflow performs the same reproducible source build in CI" {
  workflow="$REPO_ROOT/.github/workflows/fdroid-source-build.yml"
  [ -f "$workflow" ]
  grep -Fq "flutter-version: '3.44.6'" "$workflow"
  grep -Fq 'scripts/build-fdroid.sh' "$workflow"
  grep -Fq -- '--reproducible' "$workflow"
  grep -Fq 'scanner --exit-code' "$workflow"
  grep -Fq 'release-artifacts/fdroid' "$workflow"
  grep -Fq 'actions/upload-artifact@' "$workflow"
}
