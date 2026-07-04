#!/usr/bin/env bats

setup() {
  export TMP_TEST_DIR
  TMP_TEST_DIR="$(mktemp -d)"
  export PROJECT_UNDER_TEST="$TMP_TEST_DIR/project"
  export FAKE_HOME="$TMP_TEST_DIR/home"
  export FAKE_FLUTTER_LOG="$TMP_TEST_DIR/flutter.log"

  mkdir -p \
    "$PROJECT_UNDER_TEST/scripts" \
    "$PROJECT_UNDER_TEST/android" \
    "$PROJECT_UNDER_TEST/android/app/src/main/java/io/flutter/plugins" \
    "$FAKE_HOME/.local/bin"

  cp "$BATS_TEST_DIRNAME/../../scripts/build-play-console.sh" \
    "$PROJECT_UNDER_TEST/scripts/build-play-console.sh"

  cat > "$PROJECT_UNDER_TEST/pubspec.yaml" <<'YAML'
name: fake_fractal_forge
version: 1.2.3+38
YAML

  cat > "$PROJECT_UNDER_TEST/android/key.properties" <<'EOF_KEY'
storePassword=store-secret
keyPassword=key-secret
keyAlias=upload
storeFile=upload-keystore.jks
EOF_KEY
  : > "$PROJECT_UNDER_TEST/android/upload-keystore.jks"

  cat > "$FAKE_HOME/.local/bin/keytool" <<'EOF_KEYTOOL'
#!/usr/bin/env bash
printf 'Certificate fingerprints:\n'
printf '         SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD\n'
EOF_KEYTOOL
  chmod +x "$FAKE_HOME/.local/bin/keytool"

  cat > "$FAKE_HOME/.local/bin/flutter" <<'EOF_FLUTTER'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "${FAKE_FLUTTER_LOG:?}"
if [[ "$1 $2 $3" == "build appbundle --release" ]]; then
  if [[ "${FAKE_FLUTTER_FAIL_BUILD:-0}" == "1" ]]; then
    printf 'fake flutter build failed\n' >&2
    exit 42
  fi
  bundle_dir="$PWD/build/app/outputs/bundle/release"
  mkdir -p "$bundle_dir"
  printf 'fake-aab:%s\n' "$*" > "$bundle_dir/app-release.aab"
fi
exit 0
EOF_FLUTTER
  chmod +x "$FAKE_HOME/.local/bin/flutter"
}

teardown() {
  rm -rf "$TMP_TEST_DIR"
}

run_script() {
  env \
    HOME="$FAKE_HOME" \
    FAKE_FLUTTER_LOG="$FAKE_FLUTTER_LOG" \
    PLAY_UPLOAD_CERT_SHA1="AABBCCDDEEFF00112233445566778899AABBCCDD" \
    "$PROJECT_UNDER_TEST/scripts/build-play-console.sh" "$@"
}

@test "help exits before requiring release credentials" {
  rm -f "$PROJECT_UNDER_TEST/android/key.properties"

  run "$PROJECT_UNDER_TEST/scripts/build-play-console.sh" --help

  [ "$status" -eq 0 ]
  [[ "$output" == *"Build a signed Android App Bundle"* ]]
}

@test "auto build uses pubspec build number and forces no-pub" {
  run run_script --skip-pub-get --output-dir "$PROJECT_UNDER_TEST/out" --build-name 1.2.0

  [ "$status" -eq 0 ]
  grep -q -- 'build appbundle --release --build-name 1.2.0' "$FAKE_FLUTTER_LOG"
  grep -q -- '--no-pub' "$FAKE_FLUTTER_LOG"
  grep -q -- '--build-number=38' "$FAKE_FLUTTER_LOG"
  grep -q '^buildNumber=38$' "$PROJECT_UNDER_TEST/out/LATEST_BUILD_INFO.txt"
  test -f "$PROJECT_UNDER_TEST/out/LATEST_AAB.txt"
  test -f "$PROJECT_UNDER_TEST/out/LAST_BUILD_NUMBER.txt"
}

@test "auto build increments from previous output marker" {
  mkdir -p "$PROJECT_UNDER_TEST/out"
  printf '41\n' > "$PROJECT_UNDER_TEST/out/LAST_BUILD_NUMBER.txt"

  run run_script --skip-pub-get --output-dir "$PROJECT_UNDER_TEST/out"

  [ "$status" -eq 0 ]
  grep -q -- '--build-number=42' "$FAKE_FLUTTER_LOG"
  grep -q '^42$' "$PROJECT_UNDER_TEST/out/LAST_BUILD_NUMBER.txt"
}

@test "explicit build number wins and is forwarded without auto increment" {
  mkdir -p "$PROJECT_UNDER_TEST/out"
  printf '41\n' > "$PROJECT_UNDER_TEST/out/LAST_BUILD_NUMBER.txt"

  run run_script --skip-pub-get --output-dir "$PROJECT_UNDER_TEST/out" --build-number 77

  [ "$status" -eq 0 ]
  grep -q -- 'build appbundle --release --build-number 77' "$FAKE_FLUTTER_LOG"
  grep -q -- '--no-pub' "$FAKE_FLUTTER_LOG"
  ! grep -q -- '--build-number=42' "$FAKE_FLUTTER_LOG"
  grep -q '^buildNumber=77$' "$PROJECT_UNDER_TEST/out/LATEST_BUILD_INFO.txt"
}

@test "GeneratedPluginRegistrant is restored if sanitizer command mutates then fails" {
  registrant="$PROJECT_UNDER_TEST/android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java"
  cat > "$registrant" <<'JAVA'
package io.flutter.plugins;
public final class GeneratedPluginRegistrant {
  public static void registerWith() {
    dev.flutter.plugins.integration_test.IntegrationTestPlugin();
  }
}
JAVA

  cat > "$FAKE_HOME/.local/bin/sed" <<'EOF_SED'
#!/usr/bin/env bash
if [[ "$1" == "-i" ]]; then
  /usr/bin/sed -i "$2" "$3"
  exit 1
fi
exec /usr/bin/sed "$@"
EOF_SED
  chmod +x "$FAKE_HOME/.local/bin/sed"

  run run_script --skip-pub-get --output-dir "$PROJECT_UNDER_TEST/out"

  [ "$status" -ne 0 ]
  grep -q 'dev.flutter.plugins.integration_test.IntegrationTestPlugin()' "$registrant"
}
