#!/usr/bin/env bats

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  OUTPUT_DIR="$BATS_TEST_TMPDIR/fdroid-output"
  COMMIT="$(git -C "$REPO_ROOT" rev-parse HEAD)"
  BUILT_APK="$REPO_ROOT/build/app/outputs/flutter-apk/app-release.apk"
  if [[ -f "$BUILT_APK" ]]; then
    cp "$BUILT_APK" "$BATS_TEST_TMPDIR/original-app-release.apk"
  fi
  for abi in armeabi-v7a arm64-v8a x86_64; do
    split_apk="$REPO_ROOT/build/app/outputs/flutter-apk/app-$abi-release.apk"
    if [[ -f "$split_apk" ]]; then
      cp "$split_apk" "$BATS_TEST_TMPDIR/original-app-$abi-release.apk"
    fi
  done
}

teardown() {
  if [[ -f "$BATS_TEST_TMPDIR/original-app-release.apk" ]]; then
    mkdir -p "$(dirname "$BUILT_APK")"
    cp "$BATS_TEST_TMPDIR/original-app-release.apk" "$BUILT_APK"
  else
    rm -f "$BUILT_APK"
  fi
  for abi in armeabi-v7a arm64-v8a x86_64; do
    split_apk="$REPO_ROOT/build/app/outputs/flutter-apk/app-$abi-release.apk"
    original="$BATS_TEST_TMPDIR/original-app-$abi-release.apk"
    if [[ -f "$original" ]]; then
      mkdir -p "$(dirname "$split_apk")"
      cp "$original" "$split_apk"
    else
      rm -f "$split_apk"
    fi
  done
}

@test "metadata-only mode produces an official fdroiddata recipe bound to the release commit" {
  run "$REPO_ROOT/scripts/build-fdroid.sh" \
    --metadata-only \
    --version=1.1.96 \
    --build-number=96 \
    --commit="$COMMIT" \
    --output-dir="$OUTPUT_DIR"

  [ "$status" -eq 0 ]
  metadata="$OUTPUT_DIR/fdroiddata/metadata/com.trebuchetdynamics.fractal.forge.yml"
  [ -f "$metadata" ]
  grep -Fq 'RepoType: git' "$metadata"
  [ "$(grep -Fc 'versionName: 1.1.96' "$metadata")" -eq 3 ]
  grep -Fq 'versionCode: 961' "$metadata"
  grep -Fq 'versionCode: 962' "$metadata"
  grep -Fq 'versionCode: 963' "$metadata"
  grep -Fq "commit: $COMMIT" "$metadata"
  grep -Fq 'flutter@stable' "$metadata"
  grep -Fq 'flutterVersion=$(sed' "$metadata"
  grep -Fq 'git -C $$flutter$$ checkout -f $flutterVersion' "$metadata"
  grep -Fq 'ndk: r28c' "$metadata"
  grep -Fq 'AllowedAPKSigningKeys: 8d5f69b91dd44476ceaad141f1fa9f6abeccdfa20cd3f7bcdfe709df623878fd' "$metadata"
  grep -Fq 'fractal-forge-android-armeabi-v7a-v%v.apk' "$metadata"
  grep -Fq 'fractal-forge-android-arm64-v8a-v%v.apk' "$metadata"
  grep -Fq 'fractal-forge-android-x86_64-v%v.apk' "$metadata"
  grep -Fq 'CurrentVersionCode: 963' "$metadata"
  grep -Fq -- "- '%c * 10 + 3'" "$metadata"
  grep -Fq 'UpdateCheckMode: Tags' "$metadata"
  grep -Fq "version_name=\$(sed -n 's/^versionName=//p' fdroid/version.properties)" "$metadata"
  grep -Fq 'export PUB_CACHE="$(pwd)/.pub-cache"' "$metadata"
  grep -Fq -- '- docs/qa/fractal-audits' "$metadata"
  ! grep -Fq 'PUB_CACHE=\"' "$metadata"
  ! grep -Fq -- '--build-name=1.1.96' "$metadata"
  ! grep -Fq -- '- node_modules' "$metadata"
  ! grep -Fq -- '- opensource' "$metadata"
  archive="$OUTPUT_DIR/fractal-forge-fdroiddata-v1.1.96.tar.gz"
  [ -f "$archive" ]
  ! grep -Fq "$OUTPUT_DIR/" "$archive.sha256"
}

@test "pipeline rejects a release identity absent from the tracked F-Droid marker" {
  run "$REPO_ROOT/scripts/build-fdroid.sh" \
    --metadata-only \
    --version=1.1.97 \
    --build-number=97 \
    --commit="$COMMIT" \
    --output-dir="$OUTPUT_DIR"

  [ "$status" -ne 0 ]
  [[ "$output" == *"fdroid/version.properties does not match 1.1.97+97"* ]]
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
printf '%s\n' lib/armeabi-v7a/libapp.so
SH
  chmod +x "$tools/aapt" "$tools/apksigner" "$tools/unzip"
  touch "$BATS_TEST_TMPDIR/app-release.apk"

  run env PATH="$tools:$PATH" "$REPO_ROOT/scripts/verify-fdroid-apk.sh" \
    "$BATS_TEST_TMPDIR/app-release.apk" 1.1.93 93 armeabi-v7a

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
  for abi in armeabi-v7a arm64-v8a x86_64; do
    printf 'deterministic unsigned %s apk fixture\n' "$abi" > "build/app/outputs/flutter-apk/app-$abi-release.apk"
  done
  exit 0
fi
exit 64
SH
  cat >"$tools/aapt" <<'SH'
#!/usr/bin/env bash
case "$*" in
  *armeabi-v7a*) code=961 ;;
  *arm64-v8a*) code=962 ;;
  *x86_64*) code=963 ;;
  *) exit 64 ;;
esac
echo "package: name='com.trebuchetdynamics.fractal.forge' versionCode='$code' versionName='1.1.96'"
SH
  cat >"$tools/apksigner" <<'SH'
#!/usr/bin/env bash
exit 1
SH
  cat >"$tools/unzip" <<'SH'
#!/usr/bin/env bash
case "$*" in
  *armeabi-v7a*) abi=armeabi-v7a ;;
  *arm64-v8a*) abi=arm64-v8a ;;
  *x86_64*) abi=x86_64 ;;
  *) exit 64 ;;
esac
printf 'lib/%s/libapp.so\n' "$abi"
SH
  chmod +x "$tools/flutter" "$tools/aapt" "$tools/apksigner" "$tools/unzip"

  run env PATH="$tools:$PATH" "$REPO_ROOT/scripts/build-fdroid.sh" \
    --flutter-bin="$tools/flutter" \
    --version=1.1.96 \
    --build-number=96 \
    --commit="$COMMIT" \
    --output-dir="$OUTPUT_DIR"

  [ "$status" -eq 0 ]
  for abi in armeabi-v7a arm64-v8a x86_64; do
    apk="$OUTPUT_DIR/fractal-forge-fdroid-v1.1.96-$abi-unsigned.apk"
    [ -f "$apk" ]
    [ -f "$apk.provenance" ]
    ! grep -Fq "$OUTPUT_DIR/" "$apk.sha256"
    grep -Fq 'unsigned=true' "$apk.provenance"
    grep -Fq "abi=$abi" "$apk.provenance"
    grep -Fq "commit=$COMMIT" "$apk.provenance"
  done
}

@test "Gradle assigns monotonic version codes to ABI split outputs" {
  gradle="$REPO_ROOT/android/app/build.gradle.kts"
  grep -Fq 'import com.android.build.gradle.internal.api.ApkVariantOutputImpl' "$gradle"
  grep -Fq '"armeabi-v7a" to 1' "$gradle"
  grep -Fq '"arm64-v8a" to 2' "$gradle"
  grep -Fq '"x86_64" to 3' "$gradle"
  grep -Fq 'versionCodeOverride = variant.versionCode * 10 + abiVersionCode' "$gradle"
}

@test "release orchestrator exposes an official F-Droid source-build stage" {
  run "$REPO_ROOT/scripts/release.sh" fdroid --dry-run

  [ "$status" -eq 0 ]
  [[ "$output" == *"fdroid: official catalog source-build readiness"* ]]
  [[ "$output" == *"DRY RUN: build unsigned reproducible ABI APKs"* ]]
  [[ "$output" != *"not implemented"* ]]
  grep -Fq -- '--split-per-abi' "$REPO_ROOT/scripts/release.sh"
  grep -Fq 'repro_root=/tmp/fractal-forge-reproducible' "$REPO_ROOT/scripts/release.sh"
}

@test "tag workflow performs the same reproducible source build in CI" {
  workflow="$REPO_ROOT/.github/workflows/fdroid-source-build.yml"
  [ -f "$workflow" ]
  grep -Fq "flutter-version: '3.44.6'" "$workflow"
  grep -Fq 'scripts/build-fdroid.sh' "$workflow"
  grep -Fq -- '--reproducible' "$workflow"
  grep -Fq 'scanner --exit-code' "$workflow"
  grep -Fq 'base_code * 10 + 3' "$workflow"
  grep -Fq 'release-artifacts/fdroid' "$workflow"
  grep -Fq 'actions/upload-artifact@' "$workflow"
}
