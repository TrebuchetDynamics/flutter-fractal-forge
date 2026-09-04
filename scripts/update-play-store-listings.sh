#!/usr/bin/env bash
set -euo pipefail
# Text and images are validated and published together. Default: stage/discard.
# See docs/store_listing/README.md for prerequisites, manifests and receipts.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$SCRIPT_DIR/play_store_listing.py" "$@"
