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
chunks_dir="${CATALOG_AUDIT_CHUNKS_DIR:-/tmp/flutter_fractal_forge_catalog_audit_chunks}"
strict_catalog_thumbs="${STRICT_CATALOG_THUMBS:-false}"

prepare_shader_output_dirs() {
  while IFS= read -r dir; do
    mkdir -p "build/flutter_assets/$dir" "build/unit_test_assets/$dir"
  done < <(find shaders -type d | sort)
  while IFS= read -r shader; do
    : >"build/flutter_assets/${shader}.spirv.temp"
    : >"build/unit_test_assets/${shader}.spirv.temp"
  done < <(find shaders -name '*.frag' -type f | sort)
}

run_flutter_test() {
  local backup status old_ifs
  backup=$(mktemp)
  cp pubspec.yaml "$backup"
  prepare_shader_output_dirs
  if [[ -n "${CATALOG_AUDIT_SHADER_ASSETS:-}" ]]; then
    old_ifs="$IFS"
    IFS=',' read -r -a shader_assets <<< "$CATALOG_AUDIT_SHADER_ASSETS"
    IFS="$old_ifs"
    python3 scripts/research/doctor/patch_pubspec_shaders.py \
      pubspec.yaml "${shader_assets[@]}"
  fi
  set +e
  CATALOG_AUDIT_FAST="${CATALOG_AUDIT_FAST:-true}" \
    CATALOG_SKIP_SHADER_PREFLIGHT="${CATALOG_SKIP_SHADER_PREFLIGHT:-true}" \
    flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart \
      -d "$device" \
      --dart-define=FORCE_GPU_RENDER=true \
      -r expanded
  status=$?
  set -e
  cp "$backup" pubspec.yaml
  rm -f "$backup"
  return "$status"
}

if [[ -n "${CATALOG_THUMB_LIMIT:-}" || -n "${CATALOG_THUMB_OFFSET:-}" || -n "${CATALOG_THUMB_ONLY:-}" ]]; then
  run_flutter_test
  exit 0
fi

if [[ "${CATALOG_AUDIT_RESUME:-false}" != "true" ]]; then
  rm -rf "$chunks_dir"
  rm -f "$report"
fi
mkdir -p "$chunks_dir"

if [[ ! -f "$chunks_dir/catalog.json" ]]; then
  (
    unset CATALOG_THUMB_ONLY CATALOG_THUMB_LIMIT CATALOG_THUMB_OFFSET
    export CATALOG_THUMB_LIST_ONLY=true
    export STRICT_CATALOG_THUMBS=false
    export CATALOG_AUDIT_SHADER_ASSETS=shaders/legacy/escape_time/mandel_step_smooth.frag
    run_flutter_test
  )
  cp "$report" "$chunks_dir/catalog.json"
fi

if [[ ! -f "$chunks_dir/batches.txt" ]]; then
python3 - "$chunks_dir/catalog.json" "$chunks_dir/batches.txt" "$batch_size" <<'PY'
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
fi

batch=0
while IFS= read -r ids; do
  [[ -n "$ids" ]] || continue
  id_count=$(python3 - "$ids" <<'PY'
import sys
print(len([p for p in sys.argv[1].split(',') if p]))
PY
)
  retry_done=$(find "$chunks_dir" -maxdepth 1 -name "batch_${batch}_*.json" 2>/dev/null | wc -l)
  if [[ -f "$chunks_dir/batch_${batch}.json" || "$retry_done" -ge "$id_count" ]]; then
    echo "[fractal-audit] batch=$batch already complete; skipping"
    batch=$((batch + 1))
    continue
  fi
  echo "[fractal-audit] batch=$batch ids=$ids"
  assets=$(python3 scripts/research/doctor/catalog_audit_assets_for_ids.py \
    "$chunks_dir/catalog.json" "$ids")
  (
    unset CATALOG_THUMB_LIMIT CATALOG_THUMB_OFFSET CATALOG_THUMB_LIST_ONLY
    export CATALOG_THUMB_ONLY="$ids"
    export CATALOG_AUDIT_SHADER_ASSETS="$assets"
    export STRICT_CATALOG_THUMBS=false
    run_flutter_test
  )
  mkdir -p "$chunks_dir"
  retry_count=$(python3 - "$report" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
print(len(data.get('failed', [])) + len(data.get('qualityWarnings', [])))
PY
)
  if [[ "$retry_count" -gt 0 && "$ids" == *,* ]]; then
    echo "[fractal-audit] batch=$batch had $retry_count failures/warnings; retrying individually"
    IFS=',' read -r -a retry_ids <<< "$ids"
    retry=0
    for single_id in "${retry_ids[@]}"; do
      (
        unset CATALOG_THUMB_LIMIT CATALOG_THUMB_OFFSET CATALOG_THUMB_LIST_ONLY
        export CATALOG_THUMB_ONLY="$single_id"
        export CATALOG_AUDIT_SHADER_ASSETS="$(python3 scripts/research/doctor/catalog_audit_assets_for_ids.py "$chunks_dir/catalog.json" "$single_id")"
        export STRICT_CATALOG_THUMBS=false
        run_flutter_test
      )
      mkdir -p "$chunks_dir"
      cp "$report" "$chunks_dir/batch_${batch}_${retry}.json"
      retry=$((retry + 1))
    done
  else
    cp "$report" "$chunks_dir/batch_${batch}.json"
  fi
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
def batch_key(path):
    return tuple(int(part) for part in path.stem.split('_')[1:])

chunks = sorted(chunks_dir.glob('batch_*.json'), key=batch_key)
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

if [[ "$strict_catalog_thumbs" == "true" ]]; then
  python3 - "$report" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
failed = len(data.get('failed', []))
skipped = len(data.get('skipped', []))
warnings = len(data.get('qualityWarnings', []))
if failed or skipped or warnings:
    raise SystemExit(f'STRICT_CATALOG_THUMBS rejects failed={failed} skipped={skipped} warnings={warnings}')
PY
fi
