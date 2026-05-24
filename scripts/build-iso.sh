#!/bin/bash
# Build RyuOS ISO — Professional build script with strict error handling
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WSL_BUILD_DIR="${RYUOS_BUILD_DIR:-$HOME/ryuos-build}"
ISO_OUTPUT_DIR="${HOST_DIR}/iso"
LEGACY_ISO_OUTPUT_DIR="${HOST_DIR}/ISO"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

log_info() { echo -e "\033[1;34m[*]\033[0m $1"; }
log_success() { echo -e "\033[1;32m[+]\033[0m $1"; }
log_error() { echo -e "\033[1;31m[-]\033[0m $1" >&2; }

ensure_isohybrid() {
    if command -v isohybrid >/dev/null 2>&1; then
        return 0
    fi
    log_info "Installing syslinux-utils (provides isohybrid)..."
    run_root apt-get update -qq
    run_root apt-get install -y syslinux-utils syslinux genisoimage
    if ! command -v isohybrid >/dev/null 2>&1; then
        log_error "isohybrid not found. Run: sudo apt install -y syslinux-utils"
        exit 1
    fi
    log_success "isohybrid ready: $(command -v isohybrid)"
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
        if [ -s "$dir/$candidate" ]; then
            echo "$dir/$candidate"
            return 0
        fi
    done
    f=$(find "$dir" -maxdepth 3 -name '*.iso' -type f -size +0c 2>/dev/null | head -1)
    if [ -n "$f" ]; then
        echo "$f"
        return 0
    fi
    return 1
}

if grep -qi microsoft /proc/version 2>/dev/null; then
    log_info "WSL detected — build dir: $WSL_BUILD_DIR"
else
    log_info "Native Linux — build dir: $WSL_BUILD_DIR"
fi

ensure_isohybrid

log_info "Compiling custom tools (RyuShell, sys-monitor)..."
make -C "$HOST_DIR/src"

log_info "Preparing build environment..."
run_root rm -rf "$WSL_BUILD_DIR"
mkdir -p "$WSL_BUILD_DIR"
rm -f "$ISO_OUTPUT_DIR/ryuos-cli.iso" "$LEGACY_ISO_OUTPUT_DIR/ryuos-cli.iso" 2>/dev/null || true

log_info "Mirroring core configurations to build directory..."
mkdir -p "$WSL_BUILD_DIR/config/live-build"
cp -R "$HOST_DIR/config/live-build/." "$WSL_BUILD_DIR/config/live-build/"

if [[ "$HOST_DIR" == /mnt/* ]]; then
    run_root chown -R "$(whoami):$(whoami)" "$WSL_BUILD_DIR" 2>/dev/null || true
fi

cd "$WSL_BUILD_DIR/config/live-build"

# Inject modular components into live-build structure
log_info "Injecting hooks, packages, and branding into live-build..."
mkdir -p config/hooks config/package-lists config/includes.chroot/etc config/includes.chroot/usr/local/bin

# Copy Hooks
if [ -d "$HOST_DIR/hooks" ]; then
    cp -R "$HOST_DIR/hooks/"*.chroot config/hooks/ 2>/dev/null || true
    chmod +x config/hooks/*.chroot 2>/dev/null || true
fi

# Copy Package Lists
if [ -d "$HOST_DIR/packages" ]; then
    cp -R "$HOST_DIR/packages/"* config/package-lists/ 2>/dev/null || true
fi

# Copy Custom Tools (from src/ compilation)
if [ -d "$HOST_DIR/build-artifacts" ]; then
    cp -R "$HOST_DIR/build-artifacts/"* config/includes.chroot/usr/local/bin/ 2>/dev/null || true
    chmod +x config/includes.chroot/usr/local/bin/* 2>/dev/null || true
fi

# Copy custom filesystem includes
if [ -d "$HOST_DIR/config/live-build/includes.chroot" ]; then
    cp -a "$HOST_DIR/config/live-build/includes.chroot/"* config/includes.chroot/ 2>/dev/null || true
fi

log_info "Running live-build configuration..."
run_root lb clean --all
run_root lb config

log_info "Starting live-build compile..."
set +e
run_root lb build 2>&1 | tee build.log
BUILD_EXIT=${PIPESTATUS[0]}
set -e

ISO_FILE=""
if ISO_FILE=$(find_iso_file "$(pwd)"); then
    :
else
    ISO_FILE=""
fi

mkdir -p "$ISO_OUTPUT_DIR"

if [ -n "$ISO_FILE" ]; then
    if [ ! -s "$ISO_FILE" ]; then
        cp build.log "$HOST_DIR/build.log" 2>/dev/null || true
        log_error "Build produced an empty ISO: $ISO_FILE"
        exit 1
    fi

    if [ "$BUILD_EXIT" -ne 0 ] && grep -q 'isohybrid: not found' build.log 2>/dev/null; then
        log_info "Applying isohybrid (missed during live-build)..."
        run_root isohybrid "$ISO_FILE" || true
        BUILD_EXIT=0
    elif [[ "$ISO_FILE" != *hybrid* ]]; then
        run_root isohybrid "$ISO_FILE" 2>/dev/null || true
    fi

    cp build.log "$HOST_DIR/build.log" 2>/dev/null || run_root cp build.log "$HOST_DIR/build.log" 2>/dev/null || true
    
    # Copy ISO to output directory
    log_info "Copying ISO to $ISO_OUTPUT_DIR/ryuos-cli.iso"
    cp "$ISO_FILE" "$ISO_OUTPUT_DIR/ryuos-cli.iso" 2>/dev/null || run_root cp "$ISO_FILE" "$ISO_OUTPUT_DIR/ryuos-cli.iso"
    if [ ! -s "$ISO_OUTPUT_DIR/ryuos-cli.iso" ]; then
        log_error "Copied ISO is empty: $ISO_OUTPUT_DIR/ryuos-cli.iso"
        exit 1
    fi
    
    log_success "Build completed successfully!"
    exit 0
fi

cp build.log "$HOST_DIR/build.log" 2>/dev/null || true
log_error "Build failed (exit $BUILD_EXIT). No ISO found. See build.log"
exit 1
