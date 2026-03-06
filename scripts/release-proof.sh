#!/usr/bin/env bash
set -euo pipefail

FLUTTER_BIN="${FLUTTER_BIN:-/home/xel/flutter/bin/flutter}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

ANALYZE_LOG="build/analyze.log"
TEST_MACHINE_LOG="build/test_machine.jsonl"
RUNTIME_LOG="build/runtime_path.log"
BUILD_LOG="build/build_release.log"
PROOF_JSON="build/release_proof.json"
APK="build/app/outputs/flutter-apk/app-release.apk"

mkdir -p build

"$FLUTTER_BIN" analyze | tee "$ANALYZE_LOG"
"$FLUTTER_BIN" test --machine > "$TEST_MACHINE_LOG"
"$FLUTTER_BIN" test --reporter compact test/fractal_render_audit_test.dart | tee "$RUNTIME_LOG"
grep -q "Audit complete\. .*passed variance check\." "$RUNTIME_LOG"
"$FLUTTER_BIN" build apk --release | tee "$BUILD_LOG"

python3 - <<'PY'
import json
from pathlib import Path

root = Path('.').resolve()
test_log = root / 'build/test_machine.jsonl'
runtime_log = root / 'build/runtime_path.log'
apk = root / 'build/app/outputs/flutter-apk/app-release.apk'

passed = failed = skipped = 0
def iter_events(obj):
    if isinstance(obj, list):
        for item in obj:
            yield from iter_events(item)
    elif isinstance(obj, dict):
        yield obj

for line in test_log.read_text().splitlines():
    if not line.strip():
        continue
    parsed = json.loads(line)
    for evt in iter_events(parsed):
        if evt.get('type') != 'testDone':
            continue
        result = evt.get('result')
        hidden = evt.get('hidden', False)
        if hidden:
            continue
        if result == 'success':
            passed += 1
        elif result == 'failure':
            failed += 1
        elif result == 'skipped':
            skipped += 1

import hashlib
sha = hashlib.sha256(apk.read_bytes()).hexdigest()
size = apk.stat().st_size

runtime_ok = 'Audit complete.' in runtime_log.read_text() and 'passed variance check.' in runtime_log.read_text()

proof = {
    'analyze_issues': 0,
    'tests': {'passed': passed, 'failed': failed, 'skipped': skipped},
    'runtime_checks': {
        'fractal_render_audit_marker': runtime_ok,
    },
    'artifact': {
        'path': str(apk.relative_to(root)),
        'size_bytes': size,
        'sha256': sha,
    }
}
(root / 'build/release_proof.json').write_text(json.dumps(proof, indent=2) + '\n')
print(json.dumps(proof, indent=2))
PY

echo "release_proof=$PROOF_JSON"
