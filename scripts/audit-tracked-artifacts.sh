#!/usr/bin/env bash
set -euo pipefail

# Fails if local/generated/secret-like artifacts are tracked by git.
# This complements .gitignore: ignored files that are already tracked still need
# an explicit `git rm --cached` cleanup.

pattern='(^|/)\.claude|(^|/)\.claude-flow|(^|/)\.pi|(^|/)\.swarm|(^|/)\.superpowers|(^|/)\.mcp\.json$|(^|/)\.flutter-plugins(-dependencies)?$|(^|/)\.vscode/|maestro_reports|__pycache__|\.pyc$|\.bak$|\.log$|android/key\.properties$|android/(.*/)?build/'

mapfile -t offenders < <(git ls-files | grep -E "$pattern" || true)

if (( ${#offenders[@]} > 0 )); then
  printf 'Tracked local/generated/secret artifacts found:\n' >&2
  printf '  %s\n' "${offenders[@]}" >&2
  printf '\nRemove from the index with git rm --cached (or git rm for generated junk) and keep .gitignore updated.\n' >&2
  exit 1
fi

printf 'No tracked local/generated/secret artifacts found.\n'
