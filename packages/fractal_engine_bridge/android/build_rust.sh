#!/usr/bin/env bash
set -euo pipefail
root="$1" ndk="$2" mode="$3" output="$4" platforms="$5"
profile=debug
profile_args=()
if [[ "$mode" != debug ]]; then
  profile=release
  profile_args=(--release)
fi
toolchain="$ndk/toolchains/llvm/prebuilt/linux-x86_64/bin"
[[ -d "$toolchain" ]] || { echo "Missing Linux Android NDK toolchain: $toolchain" >&2; exit 1; }
cd "$root/rust"
# This directory belongs to this build mode; never retain another ABI revision.
rm -rf -- "$output/armeabi-v7a" "$output/arm64-v8a" "$output/x86_64"
IFS=, read -ra targets <<< "$platforms"
for platform in "${targets[@]}"; do
  case "$platform" in
    android-arm) target=armv7-linux-androideabi; clang=armv7a-linux-androideabi24-clang; abi=armeabi-v7a ;;
    android-arm64) target=aarch64-linux-android; clang=aarch64-linux-android24-clang; abi=arm64-v8a ;;
    android-x64) target=x86_64-linux-android; clang=x86_64-linux-android24-clang; abi=x86_64 ;;
    *) echo "Unsupported Rust Android target: $platform" >&2; exit 1 ;;
  esac
  key="${target^^}"
  key="${key//-/_}"
  env "CARGO_TARGET_${key}_LINKER=$toolchain/$clang" \
    "CC_${target//-/_}=$toolchain/$clang" "AR_${target//-/_}=$toolchain/llvm-ar" \
    cargo build --manifest-path "$root/rust/crates/fractal-bridge/Cargo.toml" \
    --target-dir "$output/../cargo-target" --target "$target" \
    --locked --offline "${profile_args[@]}"
  mkdir -p "$output/$abi"
  cp "$output/../cargo-target/$target/$profile/libfractal_bridge.so" "$output/$abi/"
done
