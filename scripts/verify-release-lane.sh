#!/usr/bin/env bash
set -euo pipefail

FLUTTER_BIN="${FLUTTER_BIN:-/home/xel/flutter/bin/flutter}"

cd "$(dirname "$0")/.."

"$FLUTTER_BIN" analyze
"$FLUTTER_BIN" test --reporter compact
"$FLUTTER_BIN" build apk --release
scripts/release-proof.sh >/tmp/ff_release_proof_verify.log
python3 - <<'PY'
import json, sys
from pathlib import Path
p = Path('build/release_proof.json')
if not p.exists():
    print('ERROR: missing build/release_proof.json', file=sys.stderr)
    sys.exit(2)
proof = json.loads(p.read_text())
if not proof.get('runtime_checks', {}).get('fractal_render_audit_marker', False):
    print('ERROR: fractal_render_audit_marker=false', file=sys.stderr)
    sys.exit(3)
print('runtime_check=fractal_render_audit_marker:true')
print(f"proof_test_passed={proof['tests']['passed']}")
print(f"proof_test_failed={proof['tests']['failed']}")
print(f"proof_test_skipped={proof['tests']['skipped']}")
PY

APK="build/app/outputs/flutter-apk/app-release.apk"
echo "artifact_path=$APK"
echo "artifact_size=$(du -h "$APK" | cut -f1)"
echo "artifact_sha256=$(sha256sum "$APK" | awk '{print $1}')"
