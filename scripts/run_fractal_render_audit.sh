#!/usr/bin/env bash
set -euo pipefail

# Catalog-wide GPU render-health audit.
#
# Environment controls are forwarded to the integration test:
#   CATALOG_THUMB_LIMIT=5        # smoke subset
#   CATALOG_THUMB_OFFSET=20      # pagination
#   CATALOG_THUMB_ONLY=mandelbrot,julia
#   STRICT_CATALOG_THUMBS=true   # fail on render-health warnings
#
# Output report:
#   build/test_output/catalog_thumbs_seeded/thumbnail_report.json

device="${1:-linux}"

flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d "$device" -r expanded
