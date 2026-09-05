#!/usr/bin/env bash
# Source to install the canonical SDK independently of third-party image tags.
set -euo pipefail
git config --global --add safe.directory "$CI_PROJECT_DIR"
apt-get update -qq
apt-get install -y --no-install-recommends bats clang cmake ninja-build pkg-config libgtk-3-dev python3-venv unzip
version="$(cat fdroid/flutter.version)"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || exit 1
export FLUTTER_ROOT="/opt/fractal-forge-flutter-$version"
git clone --depth 1 --branch "$version" https://github.com/flutter/flutter.git "$FLUTTER_ROOT"
export PATH="$FLUTTER_ROOT/bin:$PATH"
export FLUTTER_BIN="$FLUTTER_ROOT/bin/flutter"
flutter config --no-analytics
flutter --version --machine | python3 -c 'import json,sys; assert json.load(sys.stdin)["frameworkVersion"] == sys.argv[1]' "$version"
