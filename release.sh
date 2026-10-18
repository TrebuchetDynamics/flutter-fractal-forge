#!/usr/bin/env bash
# Detect the next patch, commit release metadata, push, then release through GitLab.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
for argument in "$@"; do
  if [[ "$argument" == --best-effort ]]; then
    exec python3 scripts/release_platform_lanes.py "$@"
  fi
done
exec python3 scripts/gitlab_release.py "$@"
