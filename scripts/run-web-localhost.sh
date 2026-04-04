#!/bin/bash
set -e

# Flutter Fractal Forge - Run Web on Localhost
# Usage: ./scripts/run-web-localhost.sh [options]
#
# Options:
#   --port PORT             Port to serve on (default: 8080)
#   --mode debug|profile|release
#                           Build mode (default: debug)
#   --dart-define KEY=VAL   Pass a dart-define; may be repeated
#   --no-open               Don't auto-open browser
#   --help                  Show this help

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Configuration ─────────────────────────────────────────────────────────────
PORT=8080
BUILD_MODE="debug"
AUTO_OPEN=true
DART_DEFINES=()

# ── Argument parsing ─────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case $1 in
        --port)
            PORT="$2"; shift 2 ;;
        --mode)
            BUILD_MODE="$2"; shift 2
            [[ "$BUILD_MODE" =~ ^(debug|profile|release)$ ]] || {
                echo "Unknown mode: $BUILD_MODE (use debug|profile|release)"; exit 1; }
            ;;
        --dart-define)
            DART_DEFINES+=("--dart-define=$2"); shift 2 ;;
        --dart-define=*)
            DART_DEFINES+=("$1"); shift ;;
        --no-open)
            AUTO_OPEN=false; shift ;;
        --help|-h)
            sed -n '/^# Options:/,/^[^#]/{ /^# /{ s/^# //; p } }' "$0"
            exit 0
            ;;
        *) shift ;;
    esac
done

# ── Colors ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── Helpers ───────────────────────────────────────────────────────────────────
info()    { echo -e "${CYAN}  $*${NC}"; }
ok()      { echo -e "${GREEN}✓ $*${NC}"; }
warn()    { echo -e "${YELLOW}⚠ $*${NC}"; }
fail()    { echo -e "${RED}✗ $*${NC}"; exit 1; }

# ── Prerequisite checks ──────────────────────────────────────────────────────
command -v flutter &>/dev/null || fail "flutter not found in PATH"

# ── Detect Chrome / Chromium ─────────────────────────────────────────────────
if [[ -z "$CHROME_EXECUTABLE" ]]; then
    for candidate in google-chrome google-chrome-stable chromium-browser chromium; do
        if command -v "$candidate" &>/dev/null; then
            export CHROME_EXECUTABLE="$(command -v "$candidate")"
            break
        fi
    done
    [[ -n "$CHROME_EXECUTABLE" ]] || fail "No Chrome or Chromium found. Set CHROME_EXECUTABLE."
    info "Using browser: $CHROME_EXECUTABLE"
fi

echo -e "${GREEN}${BOLD}=== Flutter Fractal Forge – Web (localhost:${PORT}) ===${NC}"
info "mode=${BUILD_MODE}  port=${PORT}"
echo ""

cd "$PROJECT_ROOT"

# ── Build flutter run command ─────────────────────────────────────────────────
FLUTTER_ARGS=(
    "-d" "chrome"
    "--$BUILD_MODE"
    "--web-port" "$PORT"
    "--web-hostname" "localhost"
)

[[ "$AUTO_OPEN" == false ]] && FLUTTER_ARGS+=("--no-web-browser-launch")

FLUTTER_ARGS+=("${DART_DEFINES[@]}")

info "flutter run ${FLUTTER_ARGS[*]}"
echo ""

# ── Run ───────────────────────────────────────────────────────────────────────
flutter run "${FLUTTER_ARGS[@]}"

echo ""
ok "Web session ended"
