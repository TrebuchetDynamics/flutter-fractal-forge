#!/usr/bin/env bash
set -euo pipefail

# Catalog-wide render-health audit.
# Full coverage is default. Internally uses isolated batches to avoid the
# Flutter/Linux repeated-FragmentProgram false "asset not found" failure.
#
# Output report:
#   build/test_output/catalog_thumbs_seeded/thumbnail_report.json

# ponytail: isolated batches avoid Flutter/Linux shader-load false negatives
# during all-catalog sweeps.
device="${1:-linux}"
out_dir="build/test_output/catalog_thumbs_seeded"
report="$out_dir/thumbnail_report.json"
batch_size="${CATALOG_AUDIT_BATCH_SIZE:-8}"
chunks_dir="$out_dir/chunks_$$"

run_flutter_test() {
  CATALOG_AUDIT_FAST="${CATALOG_AUDIT_FAST:-true}" \
    CATALOG_SKIP_SHADER_PREFLIGHT="${CATALOG_SKIP_SHADER_PREFLIGHT:-true}" \
    flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart \
      -d "$device" \
      --dart-define=FORCE_GPU_RENDER=true \
      -r expanded
}

if [[ -n "${CATALOG_THUMB_LIMIT:-}" || -n "${CATALOG_THUMB_OFFSET:-}" || -n "${CATALOG_THUMB_ONLY:-}" ]]; then
  run_flutter_test
  exit 0
fi

rm -rf "$out_dir"/chunks_*
mkdir -p "$chunks_dir"
rm -f "$report"

(
  unset CATALOG_THUMB_ONLY CATALOG_THUMB_LIMIT CATALOG_THUMB_OFFSET
  export CATALOG_THUMB_LIST_ONLY=true
  run_flutter_test
)
cp "$report" "$chunks_dir/catalog.json"

python3 - "$report" "$chunks_dir/batches.txt" "$batch_size" <<'PY'
import json, sys
report, out, batch_size = sys.argv[1], sys.argv[2], int(sys.argv[3])
entries = json.load(open(report)).get('selectedEntries', [])
if batch_size <= 0:
    batch_size = len(entries) or 1
with open(out, 'w') as f:
    for i in range(0, len(entries), batch_size):
        f.write(','.join(e['moduleId'] for e in entries[i:i + batch_size]) + '\n')
print(f'[fractal-audit] catalog entries={len(entries)} batch_size={batch_size}')
PY

batch=0
while IFS= read -r ids; do
  [[ -n "$ids" ]] || continue
  echo "[fractal-audit] batch=$batch ids=$ids"
  (
    unset CATALOG_THUMB_LIMIT CATALOG_THUMB_OFFSET CATALOG_THUMB_LIST_ONLY
    export CATALOG_THUMB_ONLY="$ids"
    run_flutter_test
  )
  cp "$report" "$chunks_dir/batch_${batch}.json"
  batch=$((batch + 1))
done < "$chunks_dir/batches.txt"

python3 - "$chunks_dir" "$report" "$batch_size" <<'PY'
import json, sys
from collections import Counter
from pathlib import Path
chunks_dir = Path(sys.argv[1])
out = Path(sys.argv[2])
batch_size = int(sys.argv[3])
catalog = json.loads((chunks_dir / 'catalog.json').read_text())
chunks = sorted(chunks_dir.glob('batch_*.json'), key=lambda p: int(p.stem.split('_')[1]))
reports = [json.loads(path.read_text()) for path in chunks]
merged = dict(catalog)
list_keys = ['renderMetrics','mathOracle','generated','failed','skipped','qualityWarnings','performance','flutterErrors','launchVisualMetrics']
for key in list_keys:
    merged[key] = [item for report in reports for item in report.get(key, [])]
merged['selectedCount'] = len(catalog.get('selectedEntries', []))
merged['isolatedBatches'] = True
merged['batchSize'] = batch_size
merged['batchReports'] = [str(path) for path in chunks]
metrics = merged.get('renderMetrics', [])
verdicts = Counter(metric.get('verdict') for metric in metrics)
thresholds = {}
for report in reports:
    thresholds = report.get('renderHealthSummary', {}).get('thresholds') or thresholds
def max_ratio(key):
    return max((float(metric.get(key, 0) or 0) for metric in metrics), default=0.0)
merged['renderHealthSummary'] = {
    'selectedCount': merged['selectedCount'],
    'evaluated': len(metrics),
    'pass': verdicts.get('pass', 0),
    'allBlack': verdicts.get('all-black', 0),
    'mostlyBlack': verdicts.get('mostly-black', 0),
    'transparent': verdicts.get('transparent', 0),
    'lowColor': verdicts.get('low-color', 0),
    'flat': verdicts.get('flat', 0),
    'blank': verdicts.get('blank', 0),
    'maxBlackPixelRatio': max_ratio('blackPixelRatio'),
    'maxTransparentPixelRatio': max_ratio('transparentPixelRatio'),
    'thresholds': thresholds,
}
oracle = merged.get('mathOracle', [])
oracle_counts = Counter(item.get('verdict') for item in oracle)
merged['mathOracleSummary'] = {
    'selectedCount': merged['selectedCount'],
    'evaluated': len(oracle),
    'pass': oracle_counts.get('pass', 0),
    'fail': oracle_counts.get('fail', 0),
    'skipped': oracle_counts.get('skipped', 0),
}
out.write_text(json.dumps(merged, indent=2) + '\n')
print(f'[fractal-audit] merged {len(chunks)} batches -> {out}')
print('[fractal-audit] generated={generated} failed={failed} skipped={skipped} warnings={warnings}'.format(
    generated=len(merged.get('generated', [])),
    failed=len(merged.get('failed', [])),
    skipped=len(merged.get('skipped', [])),
    warnings=len(merged.get('qualityWarnings', [])),
))
PY
