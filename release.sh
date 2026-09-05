#!/usr/bin/env bash
# Detect the next patch, commit release metadata, push, then release through GitLab.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
exec python3 scripts/gitlab_release.py "$@"
