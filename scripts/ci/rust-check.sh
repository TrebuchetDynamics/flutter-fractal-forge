#!/usr/bin/env bash
# Nonpublishing checks. Provision the pinned toolchain and dependencies separately.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT/rust"

PINNED_VERSION="$(awk -F '"' '/^channel = / { print $2 }' rust-toolchain.toml)"
if [[ -z "$PINNED_VERSION" || "$(rustc --version)" != "rustc $PINNED_VERSION "* ]]; then
  echo "rust-check: expected Rust $PINNED_VERSION on PATH; this script does not install toolchains" >&2
  exit 1
fi

cargo fmt --all -- --check
cargo clippy --workspace --all-targets --locked --offline -- -D warnings
cargo test --workspace --locked --offline
