#!/bin/bash

set -eo pipefail

# Help message
show_help() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] TOOL [TOOL...]

Install rust tools with optional cross-compilation.

Options:
    -a, --arch     Target architecture (amd64, arm64, arm) for cross-compilation
    -h, --help     Show this help message

Arguments:
    TOOL    One or more Rust tools to install (e.g., typos-cli ripgrep fd-find)
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h | --help)
      show_help
      exit 0
      ;;
    -a | --arch)
      ARCH="$2"
      shift 2
      ;;
    -*)
      echo "Unknown option $1"
      show_help
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

# Check if we have tools to install
if [[ $# -eq 0 ]]; then
  echo "Error: No tools specified"
  show_help
  exit 1
fi

# If no arch specified, just do a normal install
if [[ -z ${ARCH} ]]; then
  cargo install "$@"
  exit 0
fi

# Set up cross-compilation
case "${ARCH}" in
  "amd64")
    RUST_TARGET="x86_64-unknown-linux-gnu"
    ;;
  "arm64")
    RUST_TARGET="aarch64-unknown-linux-gnu"
    export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc
    ;;
  "arm" | "arm/v7")
    RUST_TARGET="armv7-unknown-linux-gnueabihf"
    export CARGO_TARGET_ARMV7_UNKNOWN_LINUX_GNUEABIHF_LINKER=arm-linux-gnueabihf-gcc
    ;;
  *)
    echo "Error: Unsupported architecture: ${ARCH}"
    exit 1
    ;;
esac

mkdir -p ~/.cargo &&
  echo '[target.aarch64-unknown-linux-gnu]' >>~/.cargo/config &&
  echo 'linker = "aarch64-linux-gnu-gcc"' >>~/.cargo/config &&
  echo 'rustflags = ["-C", "target-feature=+crt-static"]' >>~/.cargo/config &&
  echo '[target.armv7-unknown-linux-gnueabihf]' >>~/.cargo/config &&
  echo 'linker = "arm-linux-gnueabihf-gcc"' >>~/.cargo/config &&
  echo 'rustflags = ["-C", "target-feature=+crt-static"]' >>~/.cargo/config

apt-get update && apt-get install -y --no-install-recommends \
  gcc-aarch64-linux-gnu \
  g++-aarch64-linux-gnu \
  gcc-arm-linux-gnueabihf \
  g++-arm-linux-gnueabihf &&
  rm -rf /var/lib/apt/lists/*

echo "Installing rust target: ${RUST_TARGET} for ${ARCH}"
rustup target add "${RUST_TARGET}"
RUSTFLAGS="-C target-feature=+crt-static" cargo install --target "${RUST_TARGET}" "$@"
