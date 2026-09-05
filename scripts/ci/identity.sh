#!/usr/bin/env bash
# Source in each release job, including native runners.
set -euo pipefail
[[ "${GITLAB_CI:-}" == true && "${CI_COMMIT_REF_PROTECTED:-}" == true ]] || {
  echo 'Releases require a protected GitLab ref' >&2; exit 1;
}
[[ "${RELEASE_COMMIT:-}" =~ ^[0-9a-f]{40}$ && "$RELEASE_COMMIT" == "$CI_COMMIT_SHA" &&
   "$RELEASE_COMMIT" == "$(git rev-parse HEAD)" ]] || { echo 'Release commit mismatch' >&2; exit 1; }
[[ "${RELEASE_VERSION:-}" =~ ^[0-9]+\.[0-9]+\.[1-9][0-9]*$ &&
   "${RELEASE_BUILD_NUMBER:-}" =~ ^[1-9][0-9]*$ &&
   "${RELEASE_VERSION##*.}" == "$RELEASE_BUILD_NUMBER" ]] || { echo 'Release version mismatch' >&2; exit 1; }
grep -Fxq "versionName=$RELEASE_VERSION" fdroid/version.properties
grep -Fxq "versionCode=$RELEASE_BUILD_NUMBER" fdroid/version.properties
[[ "${RELEASE_MODE:-}" == prepare || "${RELEASE_MODE:-}" == publish ]] || exit 1
# A published tag may be retried, but it must never be moved to different code.
if git rev-parse --verify "refs/tags/v$RELEASE_VERSION" >/dev/null 2>&1; then
  [[ "$(git rev-list -n1 "v$RELEASE_VERSION")" == "$RELEASE_COMMIT" ]] || {
    echo 'Existing release tag points to different code' >&2; exit 1;
  }
else
  latest_tag="$(git tag --list "v${RELEASE_VERSION%.*}.*" --sort=-version:refname |
    sed -n '/^v[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$/ {p;q;}')"
  latest_build="${latest_tag##*.}"
  [[ -z "$latest_tag" ]] || (( RELEASE_BUILD_NUMBER > latest_build )) || {
    echo "Release build must be newer than $latest_tag" >&2; exit 1;
  }
fi
