#!/usr/bin/env bash
set -euo pipefail

# Multi-platform release orchestrator for Flutter Fractal Forge.
#
# Usage:
#   scripts/release.sh <stage> [<stage> ...] [--yes]
#   scripts/release.sh all [--yes]
#
# Stages:
#   android    Build + upload an AAB to Google Play via
#              scripts/build-upload-playstore.sh
#   linux      flutter build linux --release, packaged as a tarball
#              (runs directly on this machine)
#   windows    Dispatch .github/workflows/windows-release-build.yml on a
#              windows-latest runner and download its artifact. Flutter's
#              Windows target cannot be cross-compiled from Linux, so this
#              stage requires the `gh` CLI and network access to GitHub.
#   github     Tag the release and create a GitHub Release, attaching
#              whatever build artifacts are already staged in
#              release-artifacts/ (run android/linux/windows first)
#   website    Build the Flutter web app and deploy it to the
#              flutter-fractal-forge Cloudflare Pages project
#              (fractal.trebuchetdynamics.com) via `wrangler pages deploy`
#   fdroid     Not implemented -- see TODO below. Exits 0 without doing
#              anything so `all` isn't blocked by it.
#   all        android, linux, windows, github, website in that order
#              (fdroid is intentionally excluded from `all`)
#
# Flags:
#   --yes      Actually perform anything that publishes or reaches outside
#              this machine: the Play Store upload, pushing a git tag,
#              creating the GitHub Release, and dispatching the windows/
#              website GitHub Actions workflows. Without --yes, every such
#              step prints what it WOULD do and stops before doing it.
#              Local build/package steps (flutter build linux, tarring,
#              checksums) always run -- they're local and reversible.
#
# Environment:
#   FLUTTER_BIN            Path to the flutter binary
#                          (default: /home/xel/flutter/bin/flutter)
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

FLUTTER_BIN="${FLUTTER_BIN:-/home/xel/flutter/bin/flutter}"
ARTIFACT_DIR="${RELEASE_ARTIFACT_DIR:-release-artifacts}"
CLOUDFLARE_PAGES_PROJECT="${CLOUDFLARE_PAGES_PROJECT:-flutter-fractal-forge}"
CONFIRMED=0
STAGES=()

log() { echo "[release] $*"; }
die() { echo "[release] ERROR: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "$1 not found"; }

usage() {
  sed -n '3,40p' "$SCRIPT_DIR/$(basename "$0")" | sed 's/^# \{0,1\}//'
}

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

for arg in "$@"; do
  case "$arg" in
    --yes) CONFIRMED=1 ;;
    --dry-run) CONFIRMED=0 ;;
    --help|-h) usage; exit 0 ;;
    all) STAGES+=(android linux windows github website) ;;
    android|linux|windows|github|website|fdroid) STAGES+=("$arg") ;;
    *) die "Unknown argument: $arg (see --help)" ;;
  esac
done

[[ ${#STAGES[@]} -gt 0 ]] || die "No stage selected (see --help)"

mkdir -p "$ARTIFACT_DIR"

guarded() {
  # guarded <description...> -- prints what would happen and returns 1
  # (caller should skip the real action) unless --yes was passed.
  if [[ "$CONFIRMED" -eq 1 ]]; then
    return 0
  fi
  log "DRY RUN (pass --yes to actually do this): $*"
  return 1
}

pubspec_version() {
  awk -F': *' '/^version:/ { print $2; exit }' "$PROJECT_ROOT/pubspec.yaml"
}

# Prefer the version actually used for the last Play Store upload (set by the
# android stage) so linux/windows/github artifacts line up with what shipped,
# even though build-upload-playstore.sh does not write this back to
# pubspec.yaml -- it only passes --build-name/--build-number at build time.
release_version() {
  local info="play-console-upload/LATEST_BUILD_INFO.txt"
  if [[ -f "$info" ]]; then
    local name build
    name="$(awk -F= '$1=="versionName" {print $2}' "$info")"
    build="$(awk -F= '$1=="buildNumber" {print $2}' "$info")"
    if [[ -n "$name" && -n "$build" ]]; then
      echo "$name"
      return
    fi
  fi
  pubspec_version
}

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

stage_android() {
  log "=== android: build + upload to Google Play ==="
  if ! guarded "run scripts/build-upload-playstore.sh (uploads a real AAB to Google Play)"; then
    return 0
  fi
  "$SCRIPT_DIR/build-upload-playstore.sh"
  log "android stage complete: $(release_version)"
}

stage_linux() {
  log "=== linux: build + package release bundle ==="
  need tar
  "$FLUTTER_BIN" build linux --release

  local bundle_dir
  bundle_dir="$(find build/linux -maxdepth 3 -type d -path '*/release/bundle' | head -n1)"
  [[ -n "$bundle_dir" ]] || die "Linux release bundle not found under build/linux"

  local version archive
  version="$(release_version)"
  archive="$ARTIFACT_DIR/fractal-forge-linux-x64-v${version//+/-}.tar.gz"

  # The version is embedded in the filename, so without this, tarballs from
  # earlier releases (any version) pile up in ARTIFACT_DIR and the github
  # stage attaches all of them -- stale and current -- to the new release.
  rm -f "$ARTIFACT_DIR"/fractal-forge-linux-x64-v*.tar.gz*

  tar -czf "$archive" -C "$(dirname "$bundle_dir")" "$(basename "$bundle_dir")"
  sha256sum "$archive" | tee "$archive.sha256"
  log "linux stage complete: $archive"
}

stage_windows() {
  log "=== windows: dispatch CI build, download artifact ==="
  need gh
  if ! guarded "dispatch .github/workflows/windows-release-build.yml on a windows-latest runner"; then
    return 0
  fi

  local before after run_id
  before="$(gh run list --workflow=windows-release-build.yml --limit 1 --json databaseId -q '.[0].databaseId // empty')"
  gh workflow run windows-release-build.yml -f confirm_windows_build=build-windows-release

  log "Waiting for the dispatched run to appear..."
  for _ in $(seq 1 30); do
    after="$(gh run list --workflow=windows-release-build.yml --limit 1 --json databaseId -q '.[0].databaseId // empty')"
    [[ -n "$after" && "$after" != "$before" ]] && break
    sleep 2
  done
  [[ -n "$after" && "$after" != "$before" ]] || die "Timed out waiting for the windows-release-build run to start"
  run_id="$after"

  log "Watching run $run_id (this builds Flutter for Windows, expect several minutes)..."
  gh run watch "$run_id" --exit-status

  rm -f "$ARTIFACT_DIR/fractal-forge-windows-x64.zip"
  gh run download "$run_id" -n windows-build -D "$ARTIFACT_DIR"
  log "windows stage complete: $ARTIFACT_DIR/fractal-forge-windows-x64.zip"
}

stage_github() {
  log "=== github: tag + release ==="
  need git
  need gh

  local version tag notes
  version="$(release_version)"
  tag="v${version//+/-}"

  if git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
    log "Tag $tag already exists locally; skipping tag creation."
  elif ! guarded "create and push git tag $tag"; then
    return 0
  else
    git tag "$tag"
    git push origin "$tag"
  fi

  notes="$(changelog_notes "$version")"
  [[ -n "$notes" ]] || notes="Fractal Forge $version"

  local assets=()
  shopt -s nullglob
  assets+=("$ARTIFACT_DIR"/*.tar.gz "$ARTIFACT_DIR"/*.tar.gz.sha256 "$ARTIFACT_DIR"/*.zip)
  shopt -u nullglob

  if ! guarded "create GitHub Release $tag with ${#assets[@]} attached asset(s): ${assets[*]:-none}"; then
    return 0
  fi

  if gh release view "$tag" >/dev/null 2>&1; then
    log "Release $tag already exists; uploading/replacing assets only."
    if [[ ${#assets[@]} -gt 0 ]]; then
      gh release upload "$tag" "${assets[@]}" --clobber
    fi
  else
    gh release create "$tag" "${assets[@]}" \
      --title "Fractal Forge $version" \
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

  local token="${CLOUDFLARE_API_TOKEN:-}"
  if [[ -z "$token" && -f "$PROJECT_ROOT/.env" ]]; then
    token="$(
      set -a
      # shellcheck disable=SC1091
      source "$PROJECT_ROOT/.env"
      set +a
      echo "${CLOUDFLARE_API_TOKEN:-$CLOUDFLARE_API_KEY}"
    )"
  fi
  [[ -n "$token" ]] || die "No CLOUDFLARE_API_TOKEN/CLOUDFLARE_API_KEY available (set one, or add it to .env)"

  local commit_hash commit_message
  commit_hash="$(git rev-parse HEAD)"
  commit_message="$(git log -1 --pretty=%s)"

  CLOUDFLARE_API_TOKEN="$token" wrangler pages deploy build/web \
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
  "stage_$stage"
done

log "Done: ${STAGES[*]}"
