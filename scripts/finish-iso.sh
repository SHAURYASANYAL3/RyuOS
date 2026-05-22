#!/bin/bash
# Finish/copy ISO without a full rebuild
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="${RYUOS_BUILD_DIR:-$HOME/ryuos-build}/config/live-build"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

if ! command -v isohybrid >/dev/null 2>&1; then
    echo "[*] Installing syslinux-utils..."
    run_root apt-get update -qq
    run_root apt-get install -y syslinux-utils
fi

ISO=""
for candidate in \
    "$BUILD_DIR/live-image-amd64.hybrid.iso" \
    "$BUILD_DIR/live-image-amd64.iso" \
    "$BUILD_DIR/chroot/binary.hybrid.iso" \
    "$BUILD_DIR/binary/live-image-amd64.hybrid.iso"; do
    if [ -f "$candidate" ]; then
        ISO="$candidate"
        break
    fi
done

if [ -z "$ISO" ]; then
    ISO=$(find "$BUILD_DIR" -maxdepth 4 -name '*.iso' -type f 2>/dev/null | head -1)
fi

if [ -z "$ISO" ]; then
    echo "[-] No ISO under $BUILD_DIR — run ./scripts/build-iso.sh"
    exit 1
fi

echo "[*] Found ISO: $ISO"
if [[ "$ISO" != *hybrid* ]]; then
    run_root isohybrid "$ISO" 2>/dev/null || true
fi

copy_iso_to_project "$ISO" "$HOST_DIR"
echo "[*] Test: ./scripts/qemu-test.sh"
