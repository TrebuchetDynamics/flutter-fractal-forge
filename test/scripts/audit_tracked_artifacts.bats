#!/usr/bin/env bats

setup() {
  export TMP_TEST_DIR
  TMP_TEST_DIR="$(mktemp -d)"
  export PROJECT_UNDER_TEST="$TMP_TEST_DIR/project"

  mkdir -p \
    "$PROJECT_UNDER_TEST/scripts" \
    "$PROJECT_UNDER_TEST/play-console-upload" \
    "$PROJECT_UNDER_TEST/android"
  cp "$BATS_TEST_DIRNAME/../../scripts/audit-tracked-artifacts.sh" \
    "$PROJECT_UNDER_TEST/scripts/audit-tracked-artifacts.sh"
  chmod +x "$PROJECT_UNDER_TEST/scripts/audit-tracked-artifacts.sh"

  cd "$PROJECT_UNDER_TEST"
  git init -q
}

teardown() {
  rm -rf "$TMP_TEST_DIR"
}

@test "passes when generated Play upload artifacts are untracked" {
  printf 'fake aab\n' > play-console-upload/app.aab
  printf 'fake sha\n' > play-console-upload/app.aab.sha256
  printf 'play-console-upload/app.aab\n' > play-console-upload/LATEST_AAB.txt

  # An empty index and unusual benign tracked paths must both stay clean.
  run scripts/audit-tracked-artifacts.sh
  [ "$status" -eq 0 ]
  [[ "$output" == *"No tracked local/generated/secret artifacts found."* ]]

  for directory in 'unicodé' $'tab\tdir' 'quote"dir' $'line\ndir'; do
    mkdir -p "$directory"
    printf 'FAKE=fixture\n' > "$directory/.env"
    printf 'benign fixture\n' > "$directory/notes.txt"
    git add -- "$directory/notes.txt"
  done

  for quoting in default true false; do
    if [[ "$quoting" != default ]]; then
      git config --local core.quotePath "$quoting"
    fi
    run scripts/audit-tracked-artifacts.sh

    [ "$status" -eq 0 ]
    [[ "$output" == *"No tracked local/generated/secret artifacts found."* ]]
  done
}

@test "matches literal tracked paths and prints one escaped record per offender" {
  local directory filename quoting expected line count
  local -a offenders=()
  for directory in 'unicodé' $'tab\tdir' 'quote"dir' $'line\ndir'; do
    mkdir -p "$directory"
    for filename in .env upload.jks generated.log; do
      printf 'FAKE=fixture\n' > "$directory/$filename"
      offenders+=("$directory/$filename")
    done
  done
  git add -- "${offenders[@]}"

  for quoting in default true false; do
    if [[ "$quoting" != default ]]; then
      git config --local core.quotePath "$quoting"
    fi
    run scripts/audit-tracked-artifacts.sh

    [ "$status" -eq 1 ]
    [[ "$output" == *"Tracked local/generated/secret artifacts found:"* ]]
    [[ "$output" != *"No tracked local/generated/secret artifacts found."* ]]
    for filename in "${offenders[@]}"; do
      printf -v expected '  %q' "$filename"
      [[ $'\n'"$output"$'\n' == *$'\n'"$expected"$'\n'* ]]
    done
    count=0
    for line in "${lines[@]}"; do
      if [[ "$line" == '  '* ]]; then
        count=$((count + 1))
      fi
    done
    [ "$count" -eq "${#offenders[@]}" ]
  done
}

@test "fails closed when Git cannot enumerate the index, even after partial output" {
  cd "$TMP_TEST_DIR"
  run "$PROJECT_UNDER_TEST/scripts/audit-tracked-artifacts.sh"

  [ "$status" -ne 0 ]
  [[ "$output" == *"Unable to enumerate tracked files"* ]]
  [[ "$output" != *"No tracked local/generated/secret artifacts found."* ]]

  mkdir -p "$TMP_TEST_DIR/bin"
  printf '%s\n' '#!/usr/bin/env bash' \
    'if [[ "$FAKE_GIT_PARTIAL" == true ]]; then' \
    '  printf "partial/notes.txt\0partial/.env\0"' \
    'fi' \
    'exit 73' > "$TMP_TEST_DIR/bin/git"
  chmod +x "$TMP_TEST_DIR/bin/git"
  cd "$PROJECT_UNDER_TEST"

  for partial in false true; do
    run env PATH="$TMP_TEST_DIR/bin:$PATH" FAKE_GIT_PARTIAL="$partial" \
      scripts/audit-tracked-artifacts.sh

    [ "$status" -ne 0 ]
    [[ "$output" == *"Unable to enumerate tracked files"* ]]
    [[ "$output" != *"No tracked local/generated/secret artifacts found."* ]]
  done
}

@test "fails when generated Play upload artifacts are tracked" {
  printf 'fake aab\n' > play-console-upload/app.aab
  printf 'fake info\n' > play-console-upload/LATEST_BUILD_INFO.txt
  git add play-console-upload/app.aab play-console-upload/LATEST_BUILD_INFO.txt

  run scripts/audit-tracked-artifacts.sh

  [ "$status" -eq 1 ]
  [[ "$output" == *"play-console-upload/app.aab"* ]]
  [[ "$output" == *"play-console-upload/LATEST_BUILD_INFO.txt"* ]]
}

@test "fails when secret-like local config is tracked" {
  mkdir -p android/app
  printf 'TOKEN=fake\n' > .env
  printf 'storePassword=fake\n' > android/key.properties
  printf 'storePassword=fake\n' > android/app/key.properties
  git add .env android/key.properties android/app/key.properties

  run scripts/audit-tracked-artifacts.sh

  [ "$status" -eq 1 ]
  [[ "$output" == *".env"* ]]
  [[ "$output" == *"android/key.properties"* ]]
  [[ "$output" == *"android/app/key.properties"* ]]
}

@test "fails when signing or service account files are tracked" {
  printf 'fake key\n' > upload.jks
  printf 'fake pem\n' > upload.pem
  printf '{"client_email":"fake"}\n' > play-service-account.json
  printf '{"project_info":{}}\n' > google-services.json
  printf '<plist></plist>\n' > GoogleService-Info.plist
  git add \
    upload.jks \
    upload.pem \
    play-service-account.json \
    google-services.json \
    GoogleService-Info.plist

  run scripts/audit-tracked-artifacts.sh

  [ "$status" -eq 1 ]
  [[ "$output" == *"upload.jks"* ]]
  [[ "$output" == *"upload.pem"* ]]
  [[ "$output" == *"play-service-account.json"* ]]
  [[ "$output" == *"google-services.json"* ]]
  [[ "$output" == *"GoogleService-Info.plist"* ]]
}
