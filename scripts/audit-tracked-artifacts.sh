#!/usr/bin/env bash
set -euo pipefail

# Fails if local/generated/secret-like artifacts are tracked by git.
# This complements .gitignore: ignored files that are already tracked still need
# an explicit `git rm --cached` cleanup.

pattern='(^|/)\.claude|(^|/)\.claude-flow|(^|/)\.pi|(^|/)\.swarm|(^|/)\.superpowers|(^|/)\.mcp\.json$|(^|/)\.env(\..*)?$|(^|/)\.flutter-plugins(-dependencies)?$|(^|/)\.vscode/|(^|/)\.pytest_cache/|maestro_reports|__pycache__|\.pyc$|\.bak$|\.log$|\.(jks|keystore|p12|pfx|pem)$|(^|/)google-services\.json$|(^|/)GoogleService-Info\.plist$|(^|/)play-service-account\.json$|android/(.*/)?key\.properties$|android/(.*/)?build/|^playwright-report/|^test/results/|^screenshots/|^release-artifacts/|^reports/|play-console-upload/.*\.aab(\.sha256)?$|play-console-upload/(LATEST_AAB|LATEST_BUILD_INFO|LAST_BUILD_NUMBER)\.txt$'

mapfile -t offenders < <(git ls-files | grep -E "$pattern" || true)

if (( ${#offenders[@]} > 0 )); then
  printf 'Tracked local/generated/secret artifacts found:\n' >&2
  printf '  %s\n' "${offenders[@]}" >&2
  printf '\nRemove from the index with git rm --cached (or git rm for generated junk) and keep .gitignore updated.\n' >&2
  exit 1
fi

printf 'No tracked local/generated/secret artifacts found.\n'
