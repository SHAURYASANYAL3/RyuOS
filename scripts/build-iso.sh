#!/bin/bash
# Build RyuOS ISO — mirrors to ext4 (WSL home) to avoid NTFS live-build issues
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WSL_BUILD_DIR="${RYUOS_BUILD_DIR:-$HOME/ryuos-build}"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

ensure_isohybrid() {
    if command -v isohybrid >/dev/null 2>&1; then
        return 0
    fi
    echo "[*] Installing syslinux-utils (provides isohybrid)..."
    run_root apt-get update -qq
    run_root apt-get install -y syslinux-utils syslinux genisoimage
    if ! command -v isohybrid >/dev/null 2>&1; then
        echo "[-] isohybrid not found. Run: sudo apt install -y syslinux-utils"
        exit 1
    fi
    echo "[+] isohybrid ready: $(command -v isohybrid)"
}

find_iso_file() {
    local dir="$1"
    local candidate f
    for candidate in \
        live-image-amd64.hybrid.iso \
        live-image-amd64.iso \
        binary/live-image-amd64.hybrid.iso \
        binary/live-image-amd64.iso \
        binary.hybrid.iso \
        binary.iso; do
        if [ -f "$dir/$candidate" ]; then
            echo "$dir/$candidate"
            return 0
        fi
    done
    f=$(find "$dir" -maxdepth 3 -name '*.iso' -type f 2>/dev/null | head -1)
    if [ -n "$f" ]; then
        echo "$f"
        return 0
    fi
    return 1
}

if grep -qi microsoft /proc/version 2>/dev/null; then
    echo "[*] WSL detected — build dir: $WSL_BUILD_DIR"
else
    echo "[*] Native Linux — build dir: $WSL_BUILD_DIR"
fi

ensure_isohybrid

echo "[*] Compiling custom tools..."
bash "$SCRIPT_DIR/build-tools.sh"

echo "[*] Preparing build environment (removing old root-owned files with sudo)..."
run_root rm -rf "$WSL_BUILD_DIR"
mkdir -p "$WSL_BUILD_DIR"

echo "[*] Mirroring project files..."
cp -R "$HOST_DIR"/. "$WSL_BUILD_DIR"/
# Project copy on /mnt/* must be owned by you
if [[ "$HOST_DIR" == /mnt/* ]]; then
    run_root chown -R "$(whoami):$(whoami)" "$WSL_BUILD_DIR" 2>/dev/null || true
fi

cd "$WSL_BUILD_DIR/config/live-build"

mkdir -p config/hooks config/includes.chroot config/package-lists
[ -d includes.chroot ] && cp -R includes.chroot/. config/includes.chroot/
[ -d hooks ] && cp -R hooks/. config/hooks/
chmod +x config/hooks/*.chroot 2>/dev/null || true

echo "[*] Running live-build configuration..."
run_root lb clean --all
run_root lb config

echo "[*] Starting live-build compile (cached stages make reruns faster)..."
run_root lb build 2>&1 | tee build.log
BUILD_EXIT=${PIPESTATUS[0]}

ISO_FILE=""
if ISO_FILE=$(find_iso_file "$(pwd)"); then
    :
else
    ISO_FILE=""
fi

if [ -n "$ISO_FILE" ]; then
    if [ "$BUILD_EXIT" -ne 0 ] && grep -q 'isohybrid: not found' build.log 2>/dev/null; then
        echo "[*] Applying isohybrid (missed during live-build)..."
        run_root isohybrid "$ISO_FILE" || true
        BUILD_EXIT=0
    elif [[ "$ISO_FILE" != *hybrid* ]]; then
        run_root isohybrid "$ISO_FILE" 2>/dev/null || true
    fi

    cp build.log "$HOST_DIR/build.log" 2>/dev/null || run_root cp build.log "$HOST_DIR/build.log" 2>/dev/null || true
    copy_iso_to_project "$ISO_FILE" "$HOST_DIR"
    exit 0
fi

cp build.log "$HOST_DIR/build.log" 2>/dev/null || true
echo "[-] Build failed (exit $BUILD_EXIT). No ISO found. See build.log"
exit 1
