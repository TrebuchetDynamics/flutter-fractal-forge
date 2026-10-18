#!/usr/bin/env bash
set -euo pipefail
if [[ "${RELEASE_LOCAL_STAGE:-}" == 1 ]]; then
  [[ "${RELEASE_COMMIT:-}" == "$(git rev-parse HEAD)" &&
     "${RELEASE_VERSION:-}" =~ ^[0-9]+\.[0-9]+\.[1-9][0-9]*$ &&
     "${RELEASE_BUILD_NUMBER:-}" == "${RELEASE_VERSION##*.}" ]] || {
    echo 'Local F-Droid scan identity mismatch' >&2; exit 1;
  }
else
  source scripts/ci/identity.sh
fi
artifact_dir="${RELEASE_ARTIFACT_DIR:-release-artifacts}"
scan_root="$(mktemp -d "${TMPDIR:-.}/fdroid-scan.XXXXXX")"
trap 'rm -rf "$scan_root"' EXIT
git clone --depth=1 https://gitlab.com/fdroid/fdroiddata.git "$scan_root"
cp "$artifact_dir/fdroid/fdroiddata/metadata/com.trebuchetdynamics.fractal.forge.yml" "$scan_root/metadata/"
rm -f "$scan_root/config.yml"
cd "$scan_root"
fdroid lint --force-yamllint com.trebuchetdynamics.fractal.forge
base_code="$RELEASE_BUILD_NUMBER"
fdroid scanner --exit-code \
  "com.trebuchetdynamics.fractal.forge:$((base_code * 10 + 1))" \
  "com.trebuchetdynamics.fractal.forge:$((base_code * 10 + 2))" \
  "com.trebuchetdynamics.fractal.forge:$((base_code * 10 + 3))"
