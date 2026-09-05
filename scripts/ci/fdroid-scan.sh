#!/usr/bin/env bash
set -euo pipefail
source scripts/ci/identity.sh
scan_root="$(mktemp -d)"
trap 'rm -rf "$scan_root"' EXIT
git clone --depth=1 https://gitlab.com/fdroid/fdroiddata.git "$scan_root"
cp release-artifacts/fdroid/fdroiddata/metadata/com.trebuchetdynamics.fractal.forge.yml "$scan_root/metadata/"
rm -f "$scan_root/config.yml"
cd "$scan_root"
fdroid lint --force-yamllint com.trebuchetdynamics.fractal.forge
base_code="$RELEASE_BUILD_NUMBER"
fdroid scanner --exit-code \
  "com.trebuchetdynamics.fractal.forge:$((base_code * 10 + 1))" \
  "com.trebuchetdynamics.fractal.forge:$((base_code * 10 + 2))" \
  "com.trebuchetdynamics.fractal.forge:$((base_code * 10 + 3))"
