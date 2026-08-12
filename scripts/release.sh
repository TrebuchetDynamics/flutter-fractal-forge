#!/usr/bin/env bash
set -euo pipefail

# Multi-platform release orchestrator for Flutter Fractal Forge.
#
# Usage:
#   scripts/release.sh <stage> [<stage> ...] [--publish=<version>]
#   scripts/release.sh all [--publish=<version>]
#
# Stages:
#   android    Convenience stage: build + verify Android artifacts, generate
#              Android-only evidence, then upload the AAB to Google Play.
#   android-build
#              Build and verify the AAB and ABI-specific APKs without upload.
#              `all` uses this so every platform build and final evidence pass
#              before the first publication step.
#   play       Verify final release evidence and upload its exact AAB to Play.
#   linux      flutter build linux --release, packaged as a tarball
#              (runs directly on this machine)
#   windows    Dispatch .github/workflows/windows-release-build.yml on a
#              windows-latest runner and download its artifact. Flutter's
#              Windows target cannot be cross-compiled from Linux, so this
#              stage requires the `gh` CLI and network access to GitHub.
#   evidence   Generate checksums, a CycloneDX SBOM, third-party notices, and
#              a release manifest bound to the staged artifacts.
#   github     Tag the release and create a GitHub Release, attaching
#              only artifacts and evidence verified by the current release
#              manifest (run build stages and evidence first)
#   website    Build the Flutter web app and deploy it to the
#              flutter-fractal-forge Cloudflare Pages project
#              (fractal.trebuchetdynamics.com) via `wrangler pages deploy`
#   fdroid     Not implemented -- see TODO below. Exits 0 without doing
#              anything so `all` isn't blocked by it.
#   all        android-build, linux, windows, evidence, GitHub, website, then
#              Play. Every artifact and final evidence gate completes before
#              publication starts (fdroid is intentionally excluded).
#
# Flags:
#   --dry-run  Do not publish or reach outside this machine. Prints what it
#              WOULD do and skips Play Store upload, git tag push, GitHub
#              Release creation, Windows workflow dispatch, and Wrangler deploy.
#   --publish=<version>  Permit publishing only when <version> exactly matches
#                        the resolved release version. Without this confirmation,
#                        every network action is a dry run.
#   --build-number=NUMBER  Required with --publish for invocations that do not
#                          include the Android stage.
#
# Environment:
#   FLUTTER_BIN            Path to the flutter binary
#                          (default: flutter)
#   RELEASE_ARTIFACT_DIR   Where built artifacts are staged
#                          (default: release-artifacts)
#   CLOUDFLARE_PAGES_PROJECT  Wrangler --project-name for the website stage
#                          (default: flutter-fractal-forge)
#   CLOUDFLARE_API_TOKEN   Wrangler auth. If unset, the website stage falls
#                          back to CLOUDFLARE_API_KEY sourced from .env in
#                          the project root (legacy Cloudflare Global API
#                          Key, which this project's .env already has).
#
# TODO(fdroid): F-Droid has no "upload your APK" API. The official F-Droid
# catalog builds and signs from source on F-Droid's own servers after a
# one-time metadata-recipe PR to the fdroiddata repo -- that's not a
# repeatable release step. A self-hosted F-Droid repo (fdroidserver's
# `fdroid build/update/deploy`) IS repeatable, but needs its own signing key
# and a static hosting destination. Pick one before scripting this stage.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

FLUTTER_BIN="${FLUTTER_BIN:-flutter}"
ARTIFACT_DIR="${RELEASE_ARTIFACT_DIR:-release-artifacts}"
FINAL_DEVICE_EVIDENCE_DIR="$ARTIFACT_DIR/final-device-gate"
CLOUDFLARE_PAGES_PROJECT="${CLOUDFLARE_PAGES_PROJECT:-flutter-fractal-forge}"
PLAY_TRACK="${PLAY_TRACK:-internal}"
PLAY_RELEASE_STATUS="${PLAY_RELEASE_STATUS:-draft}"
CONFIRMED=0
PUBLISH_VERSION=""
PUBLISH_BUILD_NUMBER=""
DRY_RUN_FORCED=0
STAGES=()
RESOLVED_ANDROID_VERSION=""
RESOLVED_ANDROID_BUILD_NUMBER=""
RESOLVED_RELEASE_VERSION=""

log() { echo "[release] $*"; }
die() { echo "[release] ERROR: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "$1 not found"; }

android_build_tool() {
  local tool="$1" root candidate
  local candidates=()
  for root in "${ANDROID_SDK_ROOT:-}" "${ANDROID_HOME:-}" /usr/lib/android-sdk; do
    [[ -n "$root" && -d "$root/build-tools" ]] || continue
    shopt -s nullglob
    for candidate in "$root"/build-tools/*/"$tool"; do
      [[ -x "$candidate" ]] && candidates+=("$candidate")
    done
    shopt -u nullglob
  done
  if [[ ${#candidates[@]} -gt 0 ]]; then
    printf '%s\n' "${candidates[@]}" | sort -V | tail -n1
    return
  fi
  command -v "$tool" || die "Android build tool not found: $tool"
}

normalize_sha1() {
  tr -d ':[:space:]' | tr '[:lower:]' '[:upper:]'
}

expected_upload_sha1() {
  local fingerprint_file="$PROJECT_ROOT/android/play-upload-cert-sha1.txt"
  [[ -f "$fingerprint_file" ]] ||
    die "Expected upload certificate fingerprint is missing: $fingerprint_file"
  normalize_sha1 < "$fingerprint_file"
}

verify_android_apk() {
  local apk="$1" expected_abi="$2" expected_version="$3" expected_build="$4"
  local aapt apksigner badging zip_entries native_entries native_abis certs actual_sha1 expected_sha1
  aapt="$(android_build_tool aapt)"
  apksigner="$(android_build_tool apksigner)"
  certs="$("$apksigner" verify --print-certs "$apk")" ||
    die "APK signature verification failed: $apk"
  actual_sha1="$(
    awk -F': ' '/Signer #1 certificate SHA-1 digest:/ { print $2; exit }' <<< "$certs" |
      normalize_sha1
  )"
  expected_sha1="$(expected_upload_sha1)"
  [[ -n "$actual_sha1" && "$actual_sha1" == "$expected_sha1" ]] ||
    die "APK signing certificate does not match the pinned upload certificate: $apk"
  badging="$("$aapt" dump badging "$apk")" || die "APK metadata inspection failed: $apk"
  grep -Fq "package: name='com.trebuchetdynamics.fractal.forge'" <<< "$badging" ||
    die "APK package name does not match com.trebuchetdynamics.fractal.forge: $apk"
  grep -Fq "versionCode='$expected_build'" <<< "$badging" ||
    die "APK versionCode does not match $expected_build: $apk"
  grep -Fq "versionName='$expected_version'" <<< "$badging" ||
    die "APK versionName does not match $expected_version: $apk"
  zip_entries="$(unzip -Z1 "$apk")" || die "APK ZIP inventory failed: $apk"
  native_entries="$(awk '/^lib\/[^/]+\/[^/]+[.]so$/ { print }' <<< "$zip_entries")"
  grep -Fxq "lib/$expected_abi/libapp.so" <<< "$native_entries" ||
    die "APK is missing lib/$expected_abi/libapp.so: $apk"
  native_abis="$(cut -d/ -f2 <<< "$native_entries" | sort -u)"
  [[ "$native_abis" == "$expected_abi" ]] ||
    die "APK contains native libraries for unexpected ABI(s): $apk ($native_abis)"
}

ensure_bundletool() {
  local version=1.18.3
  local expected_sha256=a099cfa1543f55593bc2ed16a70a7c67fe54b1747bb7301f37fdfd6d91028e29
  local jar="${BUNDLETOOL_JAR:-$HOME/.cache/fractal-forge/bundletool-all-${version}.jar}"
  local download="${jar}.download"
  if [[ ! -f "$jar" || "$(sha256sum "$jar" | awk '{ print $1 }')" != "$expected_sha256" ]]; then
    mkdir -p "$(dirname "$jar")"
    rm -f "$download"
    curl -fL "https://github.com/google/bundletool/releases/download/${version}/bundletool-all-${version}.jar" \
      -o "$download"
    [[ "$(sha256sum "$download" | awk '{ print $1 }')" == "$expected_sha256" ]] || {
      rm -f "$download"
      die "bundletool checksum verification failed"
    }
    mv "$download" "$jar"
  fi
  printf '%s\n' "$jar"
}

verify_android_aab() {
  local aab="$1" expected_version="$2" expected_build="$3"
  local bundletool actual_version actual_build actual_package cert_info actual_sha1 expected_sha1
  bundletool="$(ensure_bundletool)"
  java -jar "$bundletool" validate --bundle="$aab" ||
    die "AAB structure validation failed: $aab"
  jarsigner -verify "$aab" >/dev/null || die "AAB signature verification failed: $aab"
  cert_info="$(keytool -printcert -jarfile "$aab")" ||
    die "Could not inspect AAB signing certificate: $aab"
  actual_sha1="$(awk -F': ' '/^[[:space:]]*SHA1:/ { print $2; exit }' <<< "$cert_info" | normalize_sha1)"
  expected_sha1="$(expected_upload_sha1)"
  [[ -n "$actual_sha1" && "$actual_sha1" == "$expected_sha1" ]] ||
    die "AAB signing certificate does not match the pinned upload certificate: $aab"
  actual_version="$(java -jar "$bundletool" dump manifest --bundle="$aab" \
    --xpath='/manifest/@android:versionName')"
  actual_build="$(java -jar "$bundletool" dump manifest --bundle="$aab" \
    --xpath='/manifest/@android:versionCode')"
  actual_package="$(java -jar "$bundletool" dump manifest --bundle="$aab" \
    --xpath='/manifest/@package')"
  [[ "$actual_version" == "$expected_version" ]] ||
    die "AAB versionName does not match $expected_version: $aab"
  [[ "$actual_build" == "$expected_build" ]] ||
    die "AAB versionCode does not match $expected_build: $aab"
  [[ "$actual_package" == "com.trebuchetdynamics.fractal.forge" ]] ||
    die "AAB package name does not match com.trebuchetdynamics.fractal.forge: $aab"
}

write_artifact_provenance() {
  local artifact="$1" version="$2" build_number="$3" commit="$4"
  local sidecar="${artifact}.provenance"
  {
    printf 'version=%s\n' "$version"
    printf 'build_number=%s\n' "$build_number"
    printf 'commit=%s\n' "$commit"
    printf 'sha256=%s\n' "$(sha256sum "$artifact" | awk '{ print $1 }')"
  } >"$sidecar"
}

verify_artifact_provenance() {
  local artifact="$1" expected_version="$2" expected_build="$3" expected_commit="$4"
  local sidecar="${artifact}.provenance"
  [[ -f "$sidecar" ]] || die "Missing artifact provenance: $sidecar"
  local version build commit checksum
  version="$(awk -F= '$1 == "version" { print substr($0, index($0, "=") + 1); exit }' "$sidecar")"
  build="$(awk -F= '$1 == "build_number" { print substr($0, index($0, "=") + 1); exit }' "$sidecar")"
  commit="$(awk -F= '$1 == "commit" { print substr($0, index($0, "=") + 1); exit }' "$sidecar")"
  checksum="$(awk -F= '$1 == "sha256" { print $2; exit }' "$sidecar")"
  [[ "$version" == "$expected_version" ]] || die "Artifact provenance version mismatch: $artifact"
  [[ "$build" == "$expected_build" ]] || die "Artifact provenance build mismatch: $artifact"
  [[ "$commit" == "$expected_commit" ]] || die "Artifact provenance commit mismatch: $artifact"
  [[ "$checksum" == "$(sha256sum "$artifact" | awk '{ print $1 }')" ]] ||
    die "Artifact provenance checksum mismatch: $artifact"
}

usage() {
  sed -n '3,44p' "$SCRIPT_DIR/$(basename "$0")" | sed 's/^# \{0,1\}//'
}

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

for arg in "$@"; do
  case "$arg" in
    --publish=*) PUBLISH_VERSION="${arg#--publish=}" ;;
    --build-number=*) PUBLISH_BUILD_NUMBER="${arg#--build-number=}" ;;
    --yes) die "--yes is unsafe; use --publish=<version>" ;;
    --dry-run) CONFIRMED=0; DRY_RUN_FORCED=1 ;;
    --help|-h) usage; exit 0 ;;
    all) STAGES+=(android_build linux windows evidence github website play) ;;
    android-build) STAGES+=(android_build) ;;
    android|play|linux|windows|evidence|github|website|fdroid) STAGES+=("$arg") ;;
    *) die "Unknown argument: $arg (see --help)" ;;
  esac
done

[[ ${#STAGES[@]} -gt 0 ]] || die "No stage selected (see --help)"

mkdir -p "$ARTIFACT_DIR"

guarded() {
  # guarded <description...> -- prints what would happen and returns 1
  # (caller should skip the real action) when --dry-run was passed.
  if [[ "$CONFIRMED" -eq 1 ]]; then
    return 0
  fi
  log "DRY RUN: $*"
  return 1
}

pubspec_version() {
  awk -F': *' '/^version:/ { print $2; exit }' "$PROJECT_ROOT/pubspec.yaml"
}

release_version() {
  local version
  version="${RESOLVED_RELEASE_VERSION:-$(pubspec_version)}"
  echo "${version%%+*}"
}

release_build_number() {
  local version
  if [[ -n "$RESOLVED_ANDROID_BUILD_NUMBER" ]]; then
    echo "$RESOLVED_ANDROID_BUILD_NUMBER"
    return
  fi
  version="$(pubspec_version)"
  [[ "$version" == *+* ]] || die "Release version '$version' has no build number"
  echo "${version##*+}"
}

release_build_name() {
  local version="$(release_version)"
  echo "${version%%+*}"
}

stage_selected() {
  local wanted="$1" stage
  for stage in "${STAGES[@]}"; do
    [[ "$stage" == "$wanted" ]] && return 0
  done
  return 1
}

verify_privacy_policy() {
  local policy="$PROJECT_ROOT/web/privacy-policy.html" phrase
  local required_phrases=(
    "Effective date: 2026-08-09"
    "does not include advertising, remote analytics, behavioral tracking, or a remote crash-reporting SDK"
    "bounded in-memory diagnostic buffer"
    "https://fractal.trebuchetdynamics.com/view"
    "repository issue tracker"
  )
  [[ -f "$policy" ]] || die "Deployed privacy policy is missing: $policy"
  for phrase in "${required_phrases[@]}"; do
    grep -Fq "$phrase" "$policy" ||
      die "Deployed privacy policy is out of sync with canonical policy: missing '$phrase'"
  done
}

# Resolve the exact Android artifact identity before the operator confirms a
# publish. The build is then pinned to these values so a previous
# LATEST_BUILD_INFO marker can never authorize a different upcoming version.
resolve_upcoming_android_version() {
  local resolved
  resolved="$("$SCRIPT_DIR/build-play-console.sh" --print-version)"
  RESOLVED_ANDROID_VERSION="$(awk -F= '$1=="versionName" {print $2}' <<< "$resolved")"
  RESOLVED_ANDROID_BUILD_NUMBER="$(awk -F= '$1=="buildNumber" {print $2}' <<< "$resolved")"
  [[ -n "$RESOLVED_ANDROID_VERSION" && -n "$RESOLVED_ANDROID_BUILD_NUMBER" ]] ||
    die "Could not resolve the upcoming Android version"
  RESOLVED_RELEASE_VERSION="$RESOLVED_ANDROID_VERSION"
}

preflight_publish() {
  need git
  [[ -z "$(git status --porcelain)" ]] ||
    die "Publishing requires a clean working tree"

  local branch remote_ref
  branch="$(git symbolic-ref --quiet --short HEAD)" ||
    die "Publishing from detached HEAD is not allowed"
  remote_ref="origin/$branch"
  git fetch --quiet origin "$branch"
  [[ "$(git rev-parse HEAD)" == "$(git rev-parse "$remote_ref")" ]] ||
    die "Local $branch is not synchronized with $remote_ref"

  log "Running mandatory release gates"
  "$FLUTTER_BIN" analyze
  "$FLUTTER_BIN" test
  rm -rf "$FINAL_DEVICE_EVIDENCE_DIR"
  mkdir -p "$FINAL_DEVICE_EVIDENCE_DIR"
  if [[ -n "$RESOLVED_ANDROID_VERSION" &&
        -n "$RESOLVED_ANDROID_BUILD_NUMBER" ]]; then
    "$SCRIPT_DIR/pre-release-gate.sh" \
      --build-name="$RESOLVED_ANDROID_VERSION" \
      --build-number="$RESOLVED_ANDROID_BUILD_NUMBER" \
      --log-dir "$FINAL_DEVICE_EVIDENCE_DIR"
  else
    "$SCRIPT_DIR/pre-release-gate.sh" \
      --log-dir "$FINAL_DEVICE_EVIDENCE_DIR"
  fi
}

if [[ -n "$PUBLISH_VERSION" && "$DRY_RUN_FORCED" -eq 0 ]]; then
  if stage_selected android || stage_selected android_build; then
    resolve_upcoming_android_version
    if [[ -n "$PUBLISH_BUILD_NUMBER" &&
          "$PUBLISH_BUILD_NUMBER" != "$RESOLVED_ANDROID_BUILD_NUMBER" ]]; then
      die "Confirmed build number does not match resolved Android build number"
    fi
  else
    [[ "$PUBLISH_BUILD_NUMBER" =~ ^[0-9]+$ ]] ||
      die "Non-Android publishing requires --build-number=NUMBER"
    RESOLVED_RELEASE_VERSION="$PUBLISH_VERSION"
    RESOLVED_ANDROID_VERSION="$PUBLISH_VERSION"
    RESOLVED_ANDROID_BUILD_NUMBER="$PUBLISH_BUILD_NUMBER"
  fi
  [[ "$PUBLISH_VERSION" == "$RESOLVED_RELEASE_VERSION" ]] ||
    die "Publish confirmation '$PUBLISH_VERSION' does not match release version '$RESOLVED_RELEASE_VERSION'"
  CONFIRMED=1
  preflight_publish
fi

changelog_notes() {
  local version="$1"
  # Headers look like "## [1.1.0+24] - 2026-02-25" -- match the version
  # prefix, not the whole line, since the date suffix varies.
  awk -v ver="## [$version]" '
    index($0, ver) == 1 { found=1; print; next }
    found && /^## \[/ { exit }
    found { print }
  ' "$PROJECT_ROOT/CHANGELOG.md"
}

watch_github_run() {
  local run_id="$1"
  local label="$2"
  local interval="${3:-10}"
  local started next_log last_status line status conclusion url now elapsed
  started="$(date +%s)"
  next_log=0
  last_status=""

  while true; do
    if ! line="$(gh run view "$run_id" --json status,conclusion,url -q '[.status, (.conclusion // ""), .url] | @tsv')"; then
      die "Could not read GitHub Actions run $run_id"
    fi
    IFS=$'\t' read -r status conclusion url <<< "$line"
    [[ -n "$status" ]] || die "GitHub Actions run $run_id returned no status"
    now="$(date +%s)"
    elapsed=$((now - started))

    if [[ "$status" != "$last_status" || "$now" -ge "$next_log" ]]; then
      log "$label run $run_id: $status${conclusion:+/$conclusion} (${elapsed}s elapsed) ${url:-}"
      last_status="$status"
      next_log=$((now + 60))
    fi

    if [[ "$status" == "completed" ]]; then
      if [[ "$conclusion" == "success" ]]; then
        return 0
      fi
      log "$label run $run_id failed; failed-step logs follow."
      gh run view "$run_id" --log-failed || true
      return 1
    fi

    sleep "$interval"
  done
}

stage_android_build() {
  log "=== android-build: build and verify without publication ==="
  if ! guarded "build and verify Android artifacts without uploading the AAB"; then
    return 0
  fi
  need curl
  need java
  need jarsigner
  need keytool
  need sha256sum
  need sort
  need unzip

  "$SCRIPT_DIR/build-play-console.sh" \
    --build-name="$RESOLVED_ANDROID_VERSION" \
    --build-number="$RESOLVED_ANDROID_BUILD_NUMBER"
  local built_name built_number
  built_name="$(awk -F= '$1=="versionName" {print $2}' play-console-upload/LATEST_BUILD_INFO.txt)"
  built_number="$(awk -F= '$1=="buildNumber" {print $2}' play-console-upload/LATEST_BUILD_INFO.txt)"
  [[ "$built_name" == "$RESOLVED_ANDROID_VERSION" &&
     "$built_number" == "$RESOLVED_ANDROID_BUILD_NUMBER" ]] ||
    die "Built Android identity '${built_name}+${built_number}' does not match confirmed '${RESOLVED_ANDROID_VERSION}+${RESOLVED_ANDROID_BUILD_NUMBER}'"

  local latest_aab staged_aab target_spec target abi artifact preflight_evidence
  local android_evidence_args=()
  latest_aab="$(tr -d '\r\n' < play-console-upload/LATEST_AAB.txt)"
  [[ -f "$latest_aab" ]] || die "Built AAB not found: $latest_aab"
  rm -f "$ARTIFACT_DIR"/fractal-forge-android-v*.aab
  staged_aab="$ARTIFACT_DIR/fractal-forge-android-v${RESOLVED_ANDROID_VERSION}.aab"
  cp "$latest_aab" "$staged_aab"
  verify_android_aab "$staged_aab" "$RESOLVED_ANDROID_VERSION" \
    "$RESOLVED_ANDROID_BUILD_NUMBER"
  write_artifact_provenance "$staged_aab" "$RESOLVED_ANDROID_VERSION" \
    "$RESOLVED_ANDROID_BUILD_NUMBER" "$(git rev-parse HEAD)"
  android_evidence_args+=(--artifact "$staged_aab")

  rm -f "$ARTIFACT_DIR"/fractal-forge-android-*-v*.apk
  for target_spec in \
    android-arm:armeabi-v7a \
    android-arm64:arm64-v8a \
    android-x64:x86_64; do
    target="${target_spec%%:*}"
    abi="${target_spec##*:}"
    "$FLUTTER_BIN" build apk --release --target-platform="$target" \
      --android-project-arg="release-abi=$abi" \
      --build-name="$RESOLVED_ANDROID_VERSION" \
      --build-number="$RESOLVED_ANDROID_BUILD_NUMBER"
    artifact="$ARTIFACT_DIR/fractal-forge-android-${abi}-v${RESOLVED_ANDROID_VERSION}.apk"
    cp build/app/outputs/flutter-apk/app-release.apk "$artifact"
    verify_android_apk "$artifact" "$abi" "$RESOLVED_ANDROID_VERSION" \
      "$RESOLVED_ANDROID_BUILD_NUMBER"
    write_artifact_provenance "$artifact" "$RESOLVED_ANDROID_VERSION" \
      "$RESOLVED_ANDROID_BUILD_NUMBER" "$(git rev-parse HEAD)"
    android_evidence_args+=(--artifact "$artifact")
  done

  preflight_evidence="$ARTIFACT_DIR/.android-preflight-evidence"
  rm -rf "$preflight_evidence"
  "$SCRIPT_DIR/generate_release_evidence.py" \
    --project-root "$PROJECT_ROOT" \
    --output-dir "$preflight_evidence" \
    --version "$RESOLVED_ANDROID_VERSION" \
    --build-number "$RESOLVED_ANDROID_BUILD_NUMBER" \
    "${android_evidence_args[@]}"
  "$SCRIPT_DIR/generate_release_evidence.py" \
    --verify "$preflight_evidence/release-manifest.json"
  rm -rf "$preflight_evidence"

  log "android-build stage complete: $(release_version)"
}

stage_play() {
  log "=== play: verify final evidence, then upload exact AAB ==="
  if ! guarded "verify final release evidence and upload its exact AAB to Google Play"; then
    return 0
  fi
  need git
  need python3

  local manifest staged_aab
  manifest="$ARTIFACT_DIR/evidence/release-manifest.json"
  [[ -f "$manifest" ]] ||
    die "Play publication requires final verified evidence: $manifest"
  "$SCRIPT_DIR/generate_release_evidence.py" --verify "$manifest"

  staged_aab="$ARTIFACT_DIR/fractal-forge-android-v${RESOLVED_ANDROID_VERSION}.aab"
  [[ -f "$staged_aab" ]] || die "Staged AAB not found: $staged_aab"
  verify_artifact_provenance "$staged_aab" "$RESOLVED_ANDROID_VERSION" \
    "$RESOLVED_ANDROID_BUILD_NUMBER" "$(git rev-parse HEAD)"
  verify_android_aab "$staged_aab" "$RESOLVED_ANDROID_VERSION" \
    "$RESOLVED_ANDROID_BUILD_NUMBER"

  PLAY_TRACK="$PLAY_TRACK" PLAY_RELEASE_STATUS="$PLAY_RELEASE_STATUS" \
    "$SCRIPT_DIR/build-upload-playstore.sh" --skip-build \
      --prebuilt-aab "$staged_aab" \
      --expected-version "$RESOLVED_ANDROID_VERSION" \
      --expected-build-number "$RESOLVED_ANDROID_BUILD_NUMBER"
  log "play stage complete: $(release_version)"
}

stage_android() {
  stage_android_build
  stage_evidence
  stage_play
}

stage_linux() {
  log "=== linux: build + package release bundle ==="
  need tar
  need git
  local version build_number commit
  version="$(release_version)"
  build_number="$(release_build_number)"
  commit="$(git rev-parse HEAD)"
  "$FLUTTER_BIN" build linux --release \
    --build-name="$(release_build_name)" \
    --build-number="$build_number" \
    --dart-define="RELEASE_VERSION=$version" \
    --dart-define="RELEASE_BUILD_NUMBER=$build_number" \
    --dart-define="RELEASE_COMMIT=$commit"

  local bundle_dir
  bundle_dir="$(find build/linux -maxdepth 3 -type d -path '*/release/bundle' | head -n1)"
  [[ -n "$bundle_dir" ]] || die "Linux release bundle not found under build/linux"

  local archive
  archive="$ARTIFACT_DIR/fractal-forge-linux-x64-v${version//+/-}.tar.gz"

  # The version is embedded in the filename, so without this, tarballs from
  # earlier releases (any version) pile up in ARTIFACT_DIR and the github
  # stage attaches all of them -- stale and current -- to the new release.
  rm -f "$ARTIFACT_DIR"/fractal-forge-linux-x64-v*.tar.gz*

  tar -czf "$archive" -C "$(dirname "$bundle_dir")" "$(basename "$bundle_dir")"
  sha256sum "$archive" | tee "$archive.sha256"
  write_artifact_provenance "$archive" "$version" "$build_number" \
    "$(git rev-parse HEAD)"
  log "linux stage complete: $archive"
}

stage_windows() {
  log "=== windows: dispatch CI build, download artifact ==="
  need gh
  need python3
  if ! guarded "dispatch .github/workflows/windows-release-build.yml on a windows-latest runner"; then
    return 0
  fi

  local before after run_id version build_number commit branch run_metadata
  version="$(release_build_name)"
  build_number="$(release_build_number)"
  commit="$(git rev-parse HEAD)"
  branch="$(git symbolic-ref --quiet --short HEAD)" ||
    die "Windows dispatch requires a branch"
  before="$(gh run list --workflow=windows-release-build.yml --commit "$commit" \
    --event workflow_dispatch --limit 1 --json databaseId -q '.[0].databaseId // empty')"
  gh workflow run windows-release-build.yml --ref "$branch" \
    -f confirm_windows_build=build-windows-release \
    -f release_version="$version" \
    -f release_build_number="$build_number" \
    -f release_commit="$commit"

  log "Waiting for the dispatched run to appear..."
  for _ in $(seq 1 30); do
    after="$(gh run list --workflow=windows-release-build.yml --commit "$commit" \
      --event workflow_dispatch --limit 1 --json databaseId -q '.[0].databaseId // empty')"
    [[ -n "$after" && "$after" != "$before" ]] && break
    sleep 2
  done
  [[ -n "$after" && "$after" != "$before" ]] || die "Timed out waiting for the windows-release-build run to start"
  run_id="$after"
  run_metadata="$(gh run view "$run_id" --json headSha,event -q '[.headSha, .event] | @tsv')"
  [[ "$run_metadata" == "$commit"$'\t'workflow_dispatch ]] ||
    die "Windows run $run_id identity mismatch: $run_metadata"

  log "Watching run $run_id (this builds Flutter for Windows, expect several minutes)..."
  watch_github_run "$run_id" "windows" 10

  rm -f "$ARTIFACT_DIR/fractal-forge-windows-x64.zip"
  rm -f "$ARTIFACT_DIR/windows-build-metadata.json"
  gh run download "$run_id" -n windows-build -D "$ARTIFACT_DIR"
  python3 - "$ARTIFACT_DIR/windows-build-metadata.json" \
    "$ARTIFACT_DIR/fractal-forge-windows-x64.zip" "$version" "$build_number" "$commit" <<'PY'
import hashlib, json, pathlib, sys
metadata_path, archive_path = map(pathlib.Path, sys.argv[1:3])
expected_version, expected_build, expected_commit = sys.argv[3:]
metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
expected = {"version": expected_version, "buildNumber": expected_build, "commit": expected_commit}
for key, value in expected.items():
    if str(metadata.get(key)) != value:
        raise SystemExit(f"Windows artifact {key} mismatch: {metadata.get(key)!r} != {value!r}")
actual_hash = hashlib.sha256(archive_path.read_bytes()).hexdigest()
if metadata.get("sha256") != actual_hash:
    raise SystemExit("Windows artifact SHA-256 does not match workflow metadata")
PY
  write_artifact_provenance "$ARTIFACT_DIR/fractal-forge-windows-x64.zip" \
    "$version" "$build_number" "$commit"
  log "windows stage complete: $ARTIFACT_DIR/fractal-forge-windows-x64.zip"
}

stage_evidence() {
  log "=== evidence: manifest + SBOM + notices + checksums ==="
  need python3
  local artifacts=() evidence_args=() relative_artifacts=() artifact version build_number info_version info_build_number evidence_bundle provenance_index=0 evidence_file evidence_name device_evidence_count=0
  rm -f "$ARTIFACT_DIR"/fractal-forge-release-evidence-v*.tar.gz
  shopt -s nullglob
  artifacts+=("$ARTIFACT_DIR"/*.aab "$ARTIFACT_DIR"/*.apk \
    "$ARTIFACT_DIR"/*.tar.gz "$ARTIFACT_DIR"/*.zip)
  shopt -u nullglob
  [[ ${#artifacts[@]} -gt 0 ]] || die "No staged release artifacts found in $ARTIFACT_DIR"
  for artifact in "${artifacts[@]}"; do
    evidence_args+=(--artifact "$artifact")
    relative_artifacts+=("${artifact#"$ARTIFACT_DIR"/}")
  done
  version="$(release_version)"
  build_number="$(release_build_number)"
  evidence_args+=(--build-number "$build_number")
  for artifact in "${artifacts[@]}"; do
    verify_artifact_provenance "$artifact" "$version" "$build_number" \
      "$(git rev-parse HEAD)"
    evidence_args+=(--evidence \
      "artifact-provenance-${provenance_index}=${artifact}.provenance")
    provenance_index=$((provenance_index + 1))
  done
  [[ -d "$FINAL_DEVICE_EVIDENCE_DIR" ]] ||
    die "Final device-gate evidence is missing: $FINAL_DEVICE_EVIDENCE_DIR"
  for evidence_file in "$FINAL_DEVICE_EVIDENCE_DIR"/*; do
    [[ -f "$evidence_file" ]] || continue
    evidence_name="$(basename "$evidence_file")"
    evidence_name="${evidence_name%.*}"
    evidence_args+=(--evidence \
      "device-gate-${evidence_name}=${evidence_file}")
    device_evidence_count=$((device_evidence_count + 1))
  done
  (( device_evidence_count > 0 )) ||
    die "Final device-gate evidence directory is empty: $FINAL_DEVICE_EVIDENCE_DIR"
  if compgen -G "$ARTIFACT_DIR/*.aab" >/dev/null; then
    [[ -f play-console-upload/LATEST_BUILD_INFO.txt ]] ||
      die "Android artifacts require LATEST_BUILD_INFO.txt"
    info_version="$(awk -F= '$1=="versionName" {print $2}' play-console-upload/LATEST_BUILD_INFO.txt)"
    info_build_number="$(awk -F= '$1=="buildNumber" {print $2}' play-console-upload/LATEST_BUILD_INFO.txt)"
    [[ "$info_version" == "$version" && "$info_build_number" == "$build_number" ]] ||
      die "Android artifact identity does not match release identity ${version}+${build_number}"
  fi
  rm -rf "$ARTIFACT_DIR/evidence"
  "$SCRIPT_DIR/generate_release_evidence.py" \
    --project-root "$PROJECT_ROOT" \
    --output-dir "$ARTIFACT_DIR/evidence" \
    --version "$version" \
    "${evidence_args[@]}"
  "$SCRIPT_DIR/generate_release_evidence.py" \
    --verify "$ARTIFACT_DIR/evidence/release-manifest.json"
  evidence_bundle="$ARTIFACT_DIR/fractal-forge-release-evidence-v${version//+/-}.tar.gz"
  tar -czf "$evidence_bundle" -C "$ARTIFACT_DIR" \
    "${relative_artifacts[@]}" evidence
  log "evidence stage complete: $ARTIFACT_DIR/evidence"
}

stage_github() {
  log "=== github: tag + release ==="
  if ! guarded "validate exact release evidence, create a tag, and publish a draft GitHub Release"; then
    return 0
  fi
  need git
  need gh
  need python3

  local version build_number commit tag notes manifest assets_output snapshot_dir snapshot_manifest
  local assets=()
  version="$(release_version)"
  build_number="$(release_build_number)"
  commit="$(git rev-parse HEAD)"
  tag="v${version//+/-}"

  manifest="$ARTIFACT_DIR/evidence/release-manifest.json"
  [[ -f "$manifest" ]] || die "GitHub release requires verified evidence: $manifest"
  snapshot_dir="$(mktemp -d "$ARTIFACT_DIR/.github-assets.XXXXXX")"
  trap "chmod -R u+w '$snapshot_dir' 2>/dev/null || true; rm -rf '$snapshot_dir'" EXIT
  assets_output="$(
    "$SCRIPT_DIR/generate_release_evidence.py" \
      --snapshot-assets "$manifest" \
      --snapshot-dir "$snapshot_dir" \
      --version "$version" \
      --build-number "$build_number" \
      --commit "$commit"
  )" || die "GitHub release evidence validation failed"
  mapfile -t assets <<< "$assets_output"
  [[ ${#assets[@]} -gt 0 ]] || die "Verified release manifest contains no assets"
  snapshot_manifest="$snapshot_dir/evidence/release-manifest.json"

  if git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
    [[ "$(git rev-list -n1 "$tag")" == "$commit" ]] ||
      die "Existing local tag $tag does not point to release commit $commit"
    local remote_tag_commit
    remote_tag_commit="$(git ls-remote origin "refs/tags/$tag" | awk 'NR == 1 { print $1 }')"
    if [[ -n "$remote_tag_commit" ]]; then
      [[ "$remote_tag_commit" == "$commit" ]] ||
        die "Existing remote tag $tag does not point to release commit $commit"
    else
      git push origin "$tag"
    fi
  else
    git tag "$tag"
    git push origin "$tag"
  fi

  notes="$(changelog_notes "$version")"
  [[ -n "$notes" ]] || notes="Fractal Forge $version"


  if ! guarded "create GitHub Release $tag with ${#assets[@]} attached asset(s): ${assets[*]:-none}"; then
    return 0
  fi

  if gh release view "$tag" >/dev/null 2>&1; then
    local existing_asset expected_asset matched existing_assets
    existing_assets="$(gh release view "$tag" --json assets --jq '.assets[].name')" ||
      die "Could not inspect existing release assets for $tag"
    while IFS= read -r existing_asset; do
      [[ -n "$existing_asset" ]] || continue
      matched=0
      for expected_asset in "${assets[@]}"; do
        if [[ "$existing_asset" == "$(basename "$expected_asset")" ]]; then
          matched=1
          break
        fi
      done
      (( matched == 1 )) ||
        die "Existing release $tag contains an asset absent from verified evidence: $existing_asset"
    done <<< "$existing_assets"
    log "Release $tag already exists; uploading/replacing verified assets only."
    "$SCRIPT_DIR/generate_release_evidence.py" --verify "$snapshot_manifest"
    gh release upload "$tag" "${assets[@]}" --clobber
  else
    "$SCRIPT_DIR/generate_release_evidence.py" --verify "$snapshot_manifest"
    gh release create "$tag" "${assets[@]}" \
      --title "Fractal Forge $version" \
      --draft \
      --notes "$notes"
  fi
  log "github stage complete: $tag"
}

stage_website() {
  log "=== website: build + deploy to Cloudflare Pages ($CLOUDFLARE_PAGES_PROJECT) ==="
  need wrangler
  if ! guarded "build the web app and run wrangler pages deploy build/web --project-name=$CLOUDFLARE_PAGES_PROJECT (deploys the live site at fractal.trebuchetdynamics.com)"; then
    return 0
  fi

  # Root-domain deploy, not the GitHub Pages "/flutter-fractal-forge/" subpath.
  "$SCRIPT_DIR/build-web-preview.sh" /

  local cloudflare_auth=()
  if [[ -n "${CLOUDFLARE_API_TOKEN:-}" ]]; then
    cloudflare_auth=(env CLOUDFLARE_API_TOKEN="$CLOUDFLARE_API_TOKEN")
  else
    if [[ -f "$PROJECT_ROOT/.env" ]]; then
      set -a
      # shellcheck disable=SC1091
      source "$PROJECT_ROOT/.env"
      set +a
    fi
    if [[ -n "${CLOUDFLARE_API_TOKEN:-}" ]]; then
      cloudflare_auth=(env CLOUDFLARE_API_TOKEN="$CLOUDFLARE_API_TOKEN")
    elif [[ -n "${CLOUDFLARE_API_KEY:-}" && -n "${CLOUDFLARE_EMAIL:-}" ]]; then
      cloudflare_auth=(env CLOUDFLARE_API_KEY="$CLOUDFLARE_API_KEY" CLOUDFLARE_EMAIL="$CLOUDFLARE_EMAIL")
    else
      die "Cloudflare auth requires CLOUDFLARE_API_TOKEN or both CLOUDFLARE_API_KEY and CLOUDFLARE_EMAIL"
    fi
  fi

  local commit_hash commit_message
  commit_hash="$(git rev-parse HEAD)"
  commit_message="$(git log -1 --pretty=%s)"

  "${cloudflare_auth[@]}" wrangler pages deploy build/web \
    --project-name="$CLOUDFLARE_PAGES_PROJECT" \
    --branch=main \
    --commit-hash="$commit_hash" \
    --commit-message="$commit_message"

  log "website stage complete: https://fractal.trebuchetdynamics.com"
}

stage_fdroid() {
  log "=== fdroid: not implemented ==="
  log "See the TODO(fdroid) comment at the top of this script -- decide"
  log "between the official F-Droid catalog (metadata PR, F-Droid builds it)"
  log "and a self-hosted fdroidserver repo (needs its own signing key +"
  log "static hosting) before scripting this stage."
}

for stage in "${STAGES[@]}"; do
  if [[ "$stage" == "website" ]]; then
    verify_privacy_policy
  fi
  "stage_$stage"
done

log "Done: ${STAGES[*]}"
