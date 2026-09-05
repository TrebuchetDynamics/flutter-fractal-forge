#!/usr/bin/env bash
# All release execution happens in GitLab; this entry point only submits/watches.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
exec python3 scripts/gitlab_release.py "$@"
