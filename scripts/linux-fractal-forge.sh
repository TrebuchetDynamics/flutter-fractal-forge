#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLUTTER_BIN="${FLUTTER_BIN:-/home/xel/flutter/bin/flutter}"
PID_FILE="${PID_FILE:-/tmp/fractal-forge-linux.pid}"
LOG_LINK="${LOG_FILE:-/tmp/fractal-forge-linux.log}"
DISPLAY_VALUE="${DISPLAY:-:0}"
MODE="restart"
WINDOW_WIDTH=""
WINDOW_HEIGHT=""
FULLSCREEN=1

usage() {
  echo "usage: $0 [--mobile|--tablet7|--tablet10|--feature] [start|restart|stop|status]" >&2
}

for arg in "$@"; do
  case "$arg" in
    --mobile)
      WINDOW_WIDTH=720; WINDOW_HEIGHT=1280; FULLSCREEN=0 ;;
    --tablet7)
      WINDOW_WIDTH=800; WINDOW_HEIGHT=1280; FULLSCREEN=0 ;;
    --tablet10)
      WINDOW_WIDTH=1920; WINDOW_HEIGHT=1200; FULLSCREEN=0 ;;
    --feature)
      WINDOW_WIDTH=1024; WINDOW_HEIGHT=500; FULLSCREEN=0 ;;
    start|restart|stop|status)
      MODE="$arg" ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      usage; exit 2 ;;
  esac
done

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
    LOG_REAL="/tmp/fractal-forge-linux-$(date +%s).log"
    ln -sf "$LOG_REAL" "$LOG_LINK"
    cd "$ROOT_DIR"
    env_cmd=(
      DISPLAY="$DISPLAY_VALUE"
      FRACTAL_FORGE_ISSUES_DIR="$ROOT_DIR/issues"
      PATH="/home/xel/.local/bin:$PATH"
      FRACTAL_FORGE_FULLSCREEN="$FULLSCREEN"
    )
    if [[ -n "$WINDOW_WIDTH" ]]; then
      env_cmd+=(
        FRACTAL_FORGE_WINDOW_WIDTH="$WINDOW_WIDTH"
        FRACTAL_FORGE_WINDOW_HEIGHT="$WINDOW_HEIGHT"
      )
    fi
    nohup env "${env_cmd[@]}" "$FLUTTER_BIN" run -d linux >"$LOG_REAL" 2>&1 &
    echo $! > "$PID_FILE"
    if [[ "$FULLSCREEN" == 1 ]]; then
      echo "started pid=$(cat "$PID_FILE") display=$DISPLAY_VALUE size=fullscreen log=$LOG_LINK"
    else
      echo "started pid=$(cat "$PID_FILE") display=$DISPLAY_VALUE size=${WINDOW_WIDTH}x${WINDOW_HEIGHT} log=$LOG_LINK"
    fi
    echo "stop: $0 stop"
    ;;
  *)
    usage
    exit 2
    ;;
esac
