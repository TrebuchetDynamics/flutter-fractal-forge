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
fdroid_bin="${FDROID_BIN:-fdroid}"
artifact_dir="${RELEASE_ARTIFACT_DIR:-release-artifacts}"
metadata_source="$artifact_dir/fdroid/fdroiddata/metadata/com.trebuchetdynamics.fractal.forge.yml"
[[ -f "$metadata_source" && ! -L "$metadata_source" ]] || {
  echo 'F-Droid app metadata must be a regular file' >&2; exit 1;
}
work_root="$(mktemp -d "${TMPDIR:-.}/fdroid-scan.XXXXXX")"
work_root="$(cd "$work_root" && pwd -P)"
trap 'rm -rf "$work_root"' EXIT
fetch_root="$work_root/upstream"
scan_root="$work_root/public"
git clone --depth=1 https://gitlab.com/fdroid/fdroiddata.git "$fetch_root"
support="$fetch_root/srclibs/flutter.yml"
categories="$fetch_root/config/categories.yml"
for input in "$support" "$categories"; do
  [[ -f "$input" && ! -L "$input" ]] || {
    echo 'F-Droid support metadata must be a regular file' >&2; exit 1;
  }
done
# Mount only the declared public inputs, not unrelated metadata or Git internals.
mkdir -p "$scan_root/metadata" "$scan_root/srclibs" "$scan_root/config"
cp -P -- "$metadata_source" "$scan_root/metadata/"
cp -P -- "$support" "$scan_root/srclibs/"
cp -P -- "$categories" "$scan_root/config/"
for icon in "$fetch_root"/config/category_*.png; do
  [[ -f "$icon" && ! -L "$icon" ]] || {
    echo 'F-Droid category icons must be regular files' >&2; exit 1;
  }
  cp -P -- "$icon" "$scan_root/config/"
done
cd "$scan_root"
"$fdroid_bin" lint --force-yamllint com.trebuchetdynamics.fractal.forge
base_code="$RELEASE_BUILD_NUMBER"
scan_output="$work_root/scanner-output.log"
"$fdroid_bin" scanner --exit-code \
  "com.trebuchetdynamics.fractal.forge:$((base_code * 10 + 1))" \
  "com.trebuchetdynamics.fractal.forge:$((base_code * 10 + 2))" \
  "com.trebuchetdynamics.fractal.forge:$((base_code * 10 + 3))" | tee "$scan_output"
# The pinned scanner ignores --exit-code for source preparation/scan problems.
python3 - "$scan_output" <<'PY'
from pathlib import Path
import re
import sys

text = Path(sys.argv[1]).read_text(errors='replace')
summaries = re.findall(r'^([0-9]+) problems found\s*$', text, re.MULTILINE)
lines = [line.strip() for line in text.splitlines() if line.strip()]
if summaries != ['0'] or not lines or lines[-1] != '0 problems found':
    raise SystemExit('F-Droid source scanner did not confirm a clean scan')
PY
