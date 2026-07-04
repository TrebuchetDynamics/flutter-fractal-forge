#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${1:-/tmp/fractal_music_preview_review}"
NO_PLAY="${2:-}"
GENERATOR="$ROOT/scripts/generate-fractal-music-previews.sh"
MANIFEST="$OUT_DIR/manifest.json"
REVIEW="$OUT_DIR/listening-review.md"

"$GENERATOR" "$OUT_DIR"

python3 - "$MANIFEST" <<'PY'
import json
import sys
from pathlib import Path

manifest_path = Path(sys.argv[1])
manifest = json.loads(manifest_path.read_text())
failed = {
    name: metrics
    for name, metrics in manifest.items()
    if metrics.get('health') != 'pass' or metrics.get('issues')
}
if failed:
    print(json.dumps(failed, indent=2), file=sys.stderr)
    sys.exit(1)
print(f'preview manifest health pass: {len(manifest)} files')
PY

cat > "$REVIEW" <<EOF_REVIEW
# Fractal Music Listening Review

- Date:
- Reviewer:
- Device/output:
- Preview directory: $OUT_DIR
- Manifest: $MANIFEST

## Results

| Preview | Pass? | Notes |
|---|---|---|
EOF_REVIEW

if [[ "$NO_PLAY" == "--no-play" || "${FRACTAL_MUSIC_NO_PLAY:-}" == "1" ]]; then
  for wav in "$OUT_DIR"/*.wav; do
    printf '| `%s` | pending |  |\n' "$(basename "$wav")" >> "$REVIEW"
  done
  echo "$REVIEW"
  exit 0
fi

player=()
if command -v paplay >/dev/null 2>&1; then
  player=(paplay)
elif command -v aplay >/dev/null 2>&1; then
  player=(aplay)
elif command -v ffplay >/dev/null 2>&1; then
  player=(ffplay -nodisp -autoexit -loglevel error)
elif command -v play >/dev/null 2>&1; then
  player=(play -q)
else
  echo "No audio player found (paplay, aplay, ffplay, or play)." >&2
  echo "Generated WAVs are in: $OUT_DIR" >&2
  exit 1
fi

for wav in "$OUT_DIR"/*.wav; do
  name="$(basename "$wav")"
  echo
  echo "Preview: $name"
  read -r -p "Press Enter to play, or type s to skip: " action
  if [[ "$action" == "s" ]]; then
    printf '| `%s` | skipped |  |\n' "$name" >> "$REVIEW"
    continue
  fi
  "${player[@]}" "$wav"
  read -r -p "Pass? [y/N]: " pass
  read -r -p "Notes: " notes
  if [[ "$pass" =~ ^[Yy]$ ]]; then
    result="yes"
  else
    result="no"
  fi
  notes="${notes//|/\/}"
  printf '| `%s` | %s | %s |\n' "$name" "$result" "$notes" >> "$REVIEW"
done

echo
echo "Wrote listening review: $REVIEW"
