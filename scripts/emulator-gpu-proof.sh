#!/usr/bin/env bash
set -euo pipefail

ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-/usr/lib/android-sdk}"
export ANDROID_SDK_ROOT
export PATH="${FLUTTER_HOME:+$FLUTTER_HOME/bin:}$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$PATH"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="${1:-agent_test_logs/gpu_proof}"
STAMP="$(date +%Y%m%d_%H%M%S)"
RUN_DIR="$OUT_DIR/$STAMP"
mkdir -p "$RUN_DIR"

LOG_FILE="$RUN_DIR/flutter_test.log"
SUMMARY_JSON="$RUN_DIR/evidence_summary.json"

echo "[gpu-proof] run_dir=$RUN_DIR"

ensure_emulator() {
  local serial="emulator-5554"
  if ! adb devices | awk 'NR>1 {print $1}' | grep -qx "$serial"; then
    echo "[gpu-proof] emulator-5554 not detected, booting fractal_test AVD..."
    nohup emulator -avd fractal_test -no-audio -gpu swiftshader_indirect >"$RUN_DIR/emulator.log" 2>&1 &
  fi

  echo "[gpu-proof] waiting for adb device..."
  adb wait-for-device >/dev/null

  echo "[gpu-proof] waiting for boot completion..."
  local boot=""
  for _ in $(seq 1 120); do
    boot="$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' || true)"
    if [[ "$boot" == "1" ]]; then
      break
    fi
    sleep 2
  done
  if [[ "$boot" != "1" ]]; then
    echo "[gpu-proof] ERROR: emulator boot did not complete in time" >&2
    exit 2
  fi
  echo "[gpu-proof] emulator ready"
}

ensure_emulator

python3 - "$RUN_DIR" "$LOG_FILE" <<'PY'
import base64
import re
import subprocess
import sys
from pathlib import Path

run_dir = Path(sys.argv[1])
log_file = Path(sys.argv[2])

png_re = re.compile(r"\[evidence\] frame_png fractal=(\S+) b64=(\S+)")

cmd = [
    "flutter",
    "test",
    "integration_test/emulator_gpu_proof_test.dart",
    "-d",
    "emulator-5554",
]

with log_file.open("w", encoding="utf-8", errors="replace") as log:
    proc = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    )

    assert proc.stdout is not None
    for line in proc.stdout:
      print(line, end="")
      log.write(line)
      log.flush()

      m = png_re.search(line)
      if not m:
          continue
      fractal = m.group(1)
      b64 = m.group(2)
      shot_path = run_dir / f"gpu_proof_{fractal}.png"
      shot_path.write_bytes(base64.b64decode(b64))
      print(f"[gpu-proof] frame_png_saved fractal={fractal} path={shot_path}")
      log.write(f"[gpu-proof] frame_png_saved fractal={fractal} path={shot_path}\n")
      log.flush()

    code = proc.wait()
    if code != 0:
      raise SystemExit(code)
PY

python3 - "$RUN_DIR" "$LOG_FILE" "$SUMMARY_JSON" <<'PY'
import json
import re
import sys
from pathlib import Path
from PIL import Image, ImageStat

run_dir = Path(sys.argv[1])
log_file = Path(sys.argv[2])
summary_path = Path(sys.argv[3])

NON_BLACK_THRESHOLD = 0.02
LUMA_VARIANCE_THRESHOLD = 150.0

fractals = ["mandelbrot", "burning_ship", "tricorn"]

FALLBACK_REMEDIATION = {
    "gpu_health_check_failed": "Inspect gpu_health stats for low nonBlackRatio/flat histogram; verify shader uniform layout and health probe behavior.",
    "forced_cpu_mode": "Set renderer backend mode to auto before running proof.",
    "emulator_guard": "Run with --dart-define=SKIP_EMULATOR_GUARD=true for emulator GPU validation.",
    "deep_zoom_precision_cpu": "Use shallower zoom for GPU proof or accept CPU fallback for deep zoom precision protection.",
}

lines = log_file.read_text(errors="replace").splitlines()

capture_re = re.compile(r"\[evidence\] capture_ready fractal=(\S+) catalog=(\S+) screenshot=(\S+) tsMs=(\d+) tsIso=(\S+)")
backend_re = re.compile(r"\[renderer\] backend_decision backend=(\w+) reason=(\S+) module=(\S+) detail=(.*)")
health_re = re.compile(r"\[renderer\] gpu_health module=(\S+) nonBlackRatio=(\S+) .* backendSwitchesDuringProbe=(\d+) .*")

captures = {}
for idx, line in enumerate(lines):
    m = capture_re.search(line)
    if m:
        captures[m.group(1)] = {
            "line": idx,
            "catalogId": m.group(2),
            "screenshotToken": m.group(3),
            "tsMs": int(m.group(4)),
            "tsIso": m.group(5),
        }

results = []
errors = []

def remediation_for(reason):
    return FALLBACK_REMEDIATION.get(reason, "Review backend_decision detail and renderer policy path for this reason token.")

for fractal in fractals:
    image_path = run_dir / f"gpu_proof_{fractal}.png"
    if not image_path.exists():
        errors.append(f"missing screenshot: {image_path.name}")
        continue

    img = Image.open(image_path).convert("RGB")
    w, h = img.size
    pixels = list(img.getdata())
    non_black = sum(1 for r, g, b in pixels if (r + g + b) > 0)
    non_black_ratio = non_black / (w * h)
    variance = ImageStat.Stat(img.convert("L")).var[0]

    cap = captures.get(fractal)
    if not cap:
        errors.append(f"missing capture marker for {fractal}")
        cap_line = len(lines) - 1
        ts_iso = None
        catalog_id = None
    else:
        cap_line = cap["line"]
        ts_iso = cap["tsIso"]
        catalog_id = cap["catalogId"]

    backend_line = None
    backend = None
    for i in range(cap_line, -1, -1):
        m = backend_re.search(lines[i])
        if m and m.group(3) == fractal:
            backend_line = lines[i]
            backend = {
                "backend": m.group(1),
                "reason": m.group(2),
                "module": m.group(3),
                "detail": m.group(4),
            }
            break

    health_line = None
    health = None
    start = max(0, cap_line - 220)
    end = min(len(lines), cap_line + 220)
    for i in range(end - 1, start - 1, -1):
        m = health_re.search(lines[i])
        if m and m.group(1) == fractal:
            health_line = lines[i]
            health = {
                "module": m.group(1),
                "gpuHealthNonBlackRatio": float(m.group(2)),
                "backendSwitchesDuringProbe": int(m.group(3)),
            }
            break

    pass_non_black = non_black_ratio >= NON_BLACK_THRESHOLD
    pass_luma = variance >= LUMA_VARIANCE_THRESHOLD
    pass_backend = backend is not None and backend["backend"] == "gpu"
    pass_health = health is not None

    fallback = None
    if backend and backend["backend"] != "gpu":
        fallback = {
            "reason": backend["reason"],
            "detail": backend["detail"],
            "remediation": remediation_for(backend["reason"]),
        }

    verdict = pass_non_black and pass_luma and pass_backend and pass_health

    result = {
        "fractal": fractal,
        "screenshot": str(image_path),
        "timestampIso": ts_iso,
        "catalogId": catalog_id,
        "moduleId": fractal,
        "backendDecisionLog": backend_line,
        "healthLog": health_line,
        "imageStats": {
            "nonBlackRatio": non_black_ratio,
            "lumaVariance": variance,
            "thresholds": {
                "minNonBlackRatio": NON_BLACK_THRESHOLD,
                "minLumaVariance": LUMA_VARIANCE_THRESHOLD,
            },
            "passNonBlack": pass_non_black,
            "passLumaVariance": pass_luma,
        },
        "fallback": fallback,
        "verdict": "PASS" if verdict else "FAIL",
    }
    results.append(result)
    (run_dir / f"evidence_bundle_{fractal}.json").write_text(json.dumps(result, indent=2))

summary = {
    "runDir": str(run_dir),
    "logFile": str(log_file),
    "thresholds": {
        "minNonBlackRatio": NON_BLACK_THRESHOLD,
        "minLumaVariance": LUMA_VARIANCE_THRESHOLD,
    },
    "results": results,
    "errors": errors,
}
summary_path.write_text(json.dumps(summary, indent=2))
print(json.dumps(summary, indent=2))

if errors or any(r["verdict"] != "PASS" for r in results):
    raise SystemExit(2)
PY

echo "[gpu-proof] summary=$SUMMARY_JSON"