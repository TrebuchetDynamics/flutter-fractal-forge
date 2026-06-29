#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Deploy the Flutter web preview to Cloudflare Pages with Wrangler.

Usage:
  scripts/deploy-cloudflare-pages.sh [options] [-- <extra wrangler args>]

Options:
  --project-name NAME   Cloudflare Pages project name.
                        Default: $CLOUDFLARE_PAGES_PROJECT, $CLOUDFLARE_PROJECT_NAME,
                        or the repository directory name.
  --branch NAME         Pages deployment branch.
                        Default: $CLOUDFLARE_PAGES_BRANCH or the current git branch.
  --base-href HREF      Flutter web base href. Default: $BASE_HREF or /.
  --build-dir DIR       Directory to build and deploy. Default: $BUILD_DIR or build/web.
  --skip-build          Deploy the existing build directory without running flutter build.
  --dry-run             Build and validate only; print the Wrangler command.
  -h, --help            Show this help.

Environment:
  FLUTTER_BIN           Flutter binary to use. Defaults to /home/xel/flutter/bin/flutter,
                        then falls back to PATH.
  WRANGLER_BIN          Wrangler command to use. Defaults to wrangler, then npx --yes wrangler.
  CLOUDFLARE_API_TOKEN  Optional for CI. Locally, an existing `wrangler login` also works.

First-time Cloudflare setup, if the Pages project does not already exist:
  wrangler pages project create <project-name> --production-branch main

Examples:
  scripts/deploy-cloudflare-pages.sh --project-name flutter-fractal-forge
  CLOUDFLARE_PAGES_PROJECT=flutter-fractal-forge scripts/deploy-cloudflare-pages.sh
  scripts/deploy-cloudflare-pages.sh --dry-run -- --commit-dirty=true
EOF
}

die() {
  echo "error: $*" >&2
  exit 1
}

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"

project_name="${CLOUDFLARE_PAGES_PROJECT:-${CLOUDFLARE_PROJECT_NAME:-$(basename "${repo_root}")}}"
branch="${CLOUDFLARE_PAGES_BRANCH:-}"
base_href="${BASE_HREF:-/}"
build_dir="${BUILD_DIR:-build/web}"
skip_build="${SKIP_BUILD:-0}"
dry_run="${DRY_RUN:-0}"
extra_wrangler_args=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-name)
      [[ $# -ge 2 ]] || die "--project-name requires a value"
      project_name="$2"
      shift 2
      ;;
    --branch)
      [[ $# -ge 2 ]] || die "--branch requires a value"
      branch="$2"
      shift 2
      ;;
    --base-href)
      [[ $# -ge 2 ]] || die "--base-href requires a value"
      base_href="$2"
      shift 2
      ;;
    --build-dir)
      [[ $# -ge 2 ]] || die "--build-dir requires a value"
      build_dir="$2"
      shift 2
      ;;
    --skip-build)
      skip_build="1"
      shift
      ;;
    --dry-run)
      dry_run="1"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      extra_wrangler_args+=("$@")
      break
      ;;
    *)
      die "unknown option: $1"
      ;;
  esac
done

[[ -n "${project_name}" ]] || die "project name is empty; set CLOUDFLARE_PAGES_PROJECT or pass --project-name"
if [[ "${base_href}" != "/" && ! "${base_href}" =~ ^/.*/$ ]]; then
  die "base href must be '/' or start and end with '/'; got: ${base_href}"
fi

if [[ -z "${branch}" ]]; then
  branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  if [[ -z "${branch}" || "${branch}" == "HEAD" ]]; then
    branch="main"
  fi
fi

if [[ "${skip_build}" != "1" ]]; then
  flutter_bin="${FLUTTER_BIN:-/home/xel/flutter/bin/flutter}"
  if [[ ! -x "${flutter_bin}" ]]; then
    flutter_bin="$(command -v flutter || true)"
  fi
  [[ -n "${flutter_bin}" ]] || die "flutter not found; set FLUTTER_BIN"

  echo "Building Flutter web release with base href '${base_href}' into '${build_dir}'..."
  rm -rf "${build_dir}"
  flutter_build_cmd=(
    "${flutter_bin}" build web
    --release
    --no-wasm-dry-run
    --base-href "${base_href}"
  )
  if [[ "${build_dir}" != "build/web" ]]; then
    flutter_build_cmd+=(--output "${build_dir}")
  fi
  "${flutter_build_cmd[@]}"

  asset_version="$(git rev-parse --short HEAD 2>/dev/null || date +%s)-$(date +%s)"
  ASSET_VERSION="${asset_version}" BUILD_DIR="${build_dir}" python3 - <<'PY'
import os
from pathlib import Path

version = os.environ['ASSET_VERSION']
build_dir = Path(os.environ['BUILD_DIR'])
index = build_dir / 'index.html'
bootstrap = build_dir / 'flutter_bootstrap.js'

if index.exists():
    text = index.read_text()
    text = text.replace('src="flutter_bootstrap.js"', f'src="flutter_bootstrap.js?v={version}"')
    index.write_text(text)

if bootstrap.exists():
    text = bootstrap.read_text()
    text = text.replace('"mainJsPath":"main.dart.js"', f'"mainJsPath":"main.dart.js?v={version}"')
    bootstrap.write_text(text)

print('web_asset_version', {'version': version})
PY
else
  echo "Skipping Flutter build; deploying existing '${build_dir}'."
fi

[[ -d "${build_dir}" ]] || die "build directory missing: ${build_dir}"
[[ -f "${build_dir}/index.html" ]] || die "Flutter entrypoint missing: ${build_dir}/index.html"
if [[ ! -f "${build_dir}/landing.html" ]]; then
  echo "warning: ${build_dir}/landing.html missing; only the Flutter app entrypoint will be deployed" >&2
fi

if [[ -f "web/.well-known/assetlinks.json" ]]; then
  assetlinks_path="${build_dir}/.well-known/assetlinks.json"
  [[ -f "${assetlinks_path}" ]] || die "assetlinks.json missing in deploy output; rebuild before deploying ${build_dir}"
  python3 - "${assetlinks_path}" <<'PY'
import json
import sys

path = sys.argv[1]
expected_package = 'com.trebuchetdynamics.fractal.forge'
expected_fingerprint = '05:F0:5E:0A:BB:9F:6E:05:36:1B:8F:E8:D0:4C:8C:F4:A2:9E:BA:46:FC:EF:A9:DE:FD:B2:09:03:ED:5E:A7:5A'
expected_relations = {
    'delegate_permission/common.handle_all_urls',
    'delegate_permission/common.get_login_creds',
}

with open(path, encoding='utf-8') as fh:
    data = json.load(fh)

for statement in data if isinstance(data, list) else []:
    target = statement.get('target', {})
    relations = set(statement.get('relation', []))
    fingerprints = set(target.get('sha256_cert_fingerprints', []))
    if (
        target.get('namespace') == 'android_app'
        and target.get('package_name') == expected_package
        and expected_fingerprint in fingerprints
        and expected_relations.issubset(relations)
    ):
        print('assetlinks_ok', {'path': path, 'package': expected_package})
        break
else:
    raise SystemExit(f'{path} does not contain the expected Android Digital Asset Links statement')
PY
fi

wrangler_cmd=()
if [[ -n "${WRANGLER_BIN:-}" ]]; then
  # Allow WRANGLER_BIN='npx --yes wrangler' for CI images without a global install.
  # shellcheck disable=SC2206
  wrangler_cmd=(${WRANGLER_BIN})
elif command -v wrangler >/dev/null 2>&1; then
  wrangler_cmd=(wrangler)
elif command -v npx >/dev/null 2>&1; then
  wrangler_cmd=(npx --yes wrangler)
else
  die "wrangler not found; install it with 'npm install -g wrangler' or set WRANGLER_BIN"
fi

if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
  echo "No CLOUDFLARE_API_TOKEN set; Wrangler will use an existing login if available." >&2
fi

deploy_cmd=(
  "${wrangler_cmd[@]}"
  pages deploy "${build_dir}"
  --project-name "${project_name}"
  --branch "${branch}"
)

commit_hash="$(git rev-parse HEAD 2>/dev/null || true)"
commit_message="$(git log -1 --pretty=%s 2>/dev/null || true)"
if [[ -n "${commit_hash}" ]]; then
  deploy_cmd+=(--commit-hash "${commit_hash}")
fi
if [[ -n "${commit_message}" ]]; then
  deploy_cmd+=(--commit-message "${commit_message}")
fi
if [[ ${#extra_wrangler_args[@]} -gt 0 ]]; then
  deploy_cmd+=("${extra_wrangler_args[@]}")
fi

echo "Deploying '${build_dir}' to Cloudflare Pages project '${project_name}' on branch '${branch}'."
printf 'Wrangler command:'
printf ' %q' "${deploy_cmd[@]}"
printf '\n'

if [[ "${dry_run}" == "1" ]]; then
  echo "Dry run complete; deployment was not started."
  exit 0
fi

"${deploy_cmd[@]}"
