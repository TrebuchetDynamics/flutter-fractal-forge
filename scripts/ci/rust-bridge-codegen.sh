#!/usr/bin/env bash
# Deterministic owned-output generation; provisioning is deliberately separate.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"
: "${AUTOWORK_CACHE:?set the isolated execution cache}"
export CARGO_HOME="${CARGO_HOME:-$AUTOWORK_CACHE/cargo-1.95.0}"
GENERATOR="${FRB_CODEGEN:-$AUTOWORK_CACHE/flutter-rust-bridge-2.13.0/bin/flutter_rust_bridge_codegen}"
[[ "$("$GENERATOR" --version)" == "flutter_rust_bridge_codegen 2.13.0" ]] || {
  echo "rust-bridge-codegen: expected codegen 2.13.0" >&2; exit 1;
}
grep -qx 'flutter_rust_bridge = "=2.13.0"' rust/crates/fractal-bridge/Cargo.toml
grep -qx '  flutter_rust_bridge: 2.13.0' packages/fractal_engine_bridge/pubspec.yaml
# Validate both resolved locks, not just manifest intent.
python3 - <<'PY'
import pathlib, re, tomllib
lock = tomllib.loads(pathlib.Path("rust/Cargo.lock").read_text())
assert [p["version"] for p in lock["package"] if p["name"] == "flutter_rust_bridge"] == ["2.13.0"]
dart = pathlib.Path("pubspec.lock").read_text()
assert re.search(r'^  flutter_rust_bridge:\n(?:^    .*\n)*?^    version: "2\.13\.0"$', dart, re.M)
PY
"$GENERATOR" generate --config-file flutter_rust_bridge.yaml
