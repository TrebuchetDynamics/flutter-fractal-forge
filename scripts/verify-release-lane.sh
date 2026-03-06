#!/usr/bin/env bash
set -euo pipefail

FLUTTER_BIN="${FLUTTER_BIN:-/home/xel/flutter/bin/flutter}"

cd "$(dirname "$0")/.."

# Canonical gate: release-proof executes analyze + tests + build + runtime checks.
scripts/release-proof.sh >/tmp/ff_release_proof_verify.log
python3 - <<'PY'
import json, sys
from pathlib import Path
p = Path('build/release_proof.json')
if not p.exists():
    print('ERROR: missing build/release_proof.json', file=sys.stderr)
    sys.exit(2)
proof = json.loads(p.read_text())
if proof.get('analyze_issues', 1) != 0:
    print(f"ERROR: analyze_issues={proof.get('analyze_issues')}", file=sys.stderr)
    sys.exit(3)
if proof.get('tests', {}).get('failed', 1) != 0:
    print(f"ERROR: proof_test_failed={proof.get('tests', {}).get('failed')}", file=sys.stderr)
    sys.exit(4)
if not proof.get('runtime_checks', {}).get('fractal_render_audit_marker', False):
    print('ERROR: fractal_render_audit_marker=false', file=sys.stderr)
    sys.exit(5)
artifact = Path(proof.get('artifact', {}).get('path', ''))
if not artifact.exists():
    print(f"ERROR: artifact_missing={artifact}", file=sys.stderr)
    sys.exit(6)
import hashlib
actual_sha = hashlib.sha256(artifact.read_bytes()).hexdigest()
if actual_sha != proof.get('artifact', {}).get('sha256'):
    print('ERROR: artifact_sha_mismatch', file=sys.stderr)
    sys.exit(7)
if artifact.stat().st_size != int(proof.get('artifact', {}).get('size_bytes', -1)):
    print('ERROR: artifact_size_mismatch', file=sys.stderr)
    sys.exit(8)
print('runtime_check=fractal_render_audit_marker:true')
print('artifact_proof_match=true')
print(f"proof_test_passed={proof['tests']['passed']}")
print(f"proof_test_failed={proof['tests']['failed']}")
print(f"proof_test_skipped={proof['tests']['skipped']}")
PY

APK="build/app/outputs/flutter-apk/app-release.apk"
echo "artifact_path=$APK"
echo "artifact_size=$(du -h "$APK" | cut -f1)"
echo "artifact_sha256=$(sha256sum "$APK" | awk '{print $1}')"
