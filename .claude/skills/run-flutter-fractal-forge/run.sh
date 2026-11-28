#!/usr/bin/env bash
# Drive the real Flutter Fractal Forge Linux app under Xvfb and save screenshots.
# Usage (from the repo root):
#   .claude/skills/run-flutter-fractal-forge/run.sh OUT_DIR 'STEPS'
# STEPS: see driver_test.dart (shot:/search:/open:/set:/wait:/back, `;`-separated).
set -u
out=$(realpath -m "${1:?OUT_DIR required}")
steps=${2:-shot:catalog}
skill_dir=$(dirname "$(realpath "$0")")
target=integration_test/zz_run_skill_driver_test.dart

[ -f pubspec.yaml ] && [ -d integration_test/helpers ] || {
  echo "run from the flutter-fractal-forge repo root" >&2; exit 2; }
mkdir -p "$out"
cp "$skill_dir/driver_test.dart" "$target"
trap 'rm -f "$target"' EXIT

# 1280x720 matches the Linux runner's default window, so the screenshot is the app.
timeout "${RUN_TIMEOUT:-1700}" xvfb-run -a -s "-screen 0 1280x720x24" \
  flutter test "$target" -d linux \
  --dart-define=FORCE_GPU_RENDER=true \
  --dart-define=CAPTURE_DIR="$out" \
  --dart-define=STEPS="$steps" \
  --reporter expanded > "$out/run.log" 2>&1
code=$?
echo "exit=$code" >> "$out/run.log"
grep -E '^(STEP|CAPTURE)|All tests passed|Some tests failed|\[E\]' "$out/run.log"
echo "exit=$code log=$out/run.log"
exit "$code"
