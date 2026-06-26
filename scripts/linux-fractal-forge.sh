#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLUTTER_BIN="${FLUTTER_BIN:-/home/xel/flutter/bin/flutter}"
PID_FILE="${PID_FILE:-/tmp/fractal-forge-mobile-linux.pid}"
LOG_LINK="${LOG_FILE:-/tmp/fractal-forge-mobile-linux.log}"
DISPLAY_VALUE="${DISPLAY:-:0}"
MODE="${1:-restart}"

stop_app() {
  if [[ -f "$PID_FILE" ]]; then
    kill "$(cat "$PID_FILE")" 2>/dev/null || true
  fi
  pkill -f "$ROOT_DIR/build/linux/.*/flutter_fractals" 2>/dev/null || true
}

case "$MODE" in
  stop)
    stop_app
    rm -f "$PID_FILE"
    echo "stopped"
    ;;
  status)
    [[ -f "$PID_FILE" ]] && ps -p "$(cat "$PID_FILE")" -o pid,stat,cmd || true
    pgrep -af "$ROOT_DIR/build/linux/.*/flutter_fractals|flutter_tools.snapshot run -d linux" || true
    ;;
  start|restart)
    [[ "$MODE" == "restart" ]] && stop_app
    mkdir -p "$(dirname "$LOG_LINK")"
    LOG_REAL="/tmp/fractal-forge-mobile-linux-$(date +%s).log"
    ln -sf "$LOG_REAL" "$LOG_LINK"
    cd "$ROOT_DIR"
    DISPLAY="$DISPLAY_VALUE" \
    FRACTAL_FORGE_MOBILE_SCREENSHOT=1 \
    PATH="/home/xel/.local/bin:$PATH" \
      nohup "$FLUTTER_BIN" run -d linux >"$LOG_REAL" 2>&1 &
    echo $! > "$PID_FILE"
    echo "started pid=$(cat "$PID_FILE") display=$DISPLAY_VALUE size=720x1280 log=$LOG_LINK"
    echo "stop: $0 stop"
    ;;
  *)
    echo "usage: $0 [start|restart|stop|status]" >&2
    exit 2
    ;;
esac
