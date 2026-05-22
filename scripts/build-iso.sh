#!/bin/bash
# scripts/build-iso.sh - Wrapper to run build in WSL ext4 filesystem to avoid NTFS issues
set -e

# Determine directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WSL_BUILD_DIR="/root/ryuos-build"

# Verify we are running inside WSL/Linux
if ! grep -q -i microsoft /proc/version; then
    echo "[-] This script is optimized to run inside WSL."
    # We will still proceed if run on native Linux
fi

echo "[*] Preparing WSL build environment in $WSL_BUILD_DIR..."
# Ensure the build directory is clean and exists
rm -rf "$WSL_BUILD_DIR"
mkdir -p "$WSL_BUILD_DIR"

# Copy repository contents to WSL ext4 filesystem
echo "[*] Mirroring files to WSL ext4 to avoid NTFS mount limitations..."
cp -R "$HOST_DIR"/* "$WSL_BUILD_DIR"/

# Change to the live-build directory inside WSL build dir
cd "$WSL_BUILD_DIR/config/live-build"

echo "[*] Running live-build configuration..."
lb clean --all
lb config

echo "[*] Starting live-build compile (this can take 10-20 mins on first run)..."
lb build 2>&1 | tee build.log

# Check if the build was successful
if [ -f "live-image-amd64.iso" ]; then
    echo "[+] Build successful inside WSL!"
    
    # Ensure the output directory on Windows host exists
    mkdir -p "$HOST_DIR/ISO"
    
    # Copy the finished ISO and log back to Windows host
    cp live-image-amd64.iso "$HOST_DIR/ISO/ryuos-cli.iso"
    cp build.log "$HOST_DIR/build.log"
    
    echo "[+] Copied ISO to: $HOST_DIR/ISO/ryuos-cli.iso"
    echo "[+] Copied build log to: $HOST_DIR/build.log"
else
    # Copy build log back for troubleshooting even if failed
    if [ -f build.log ]; then
        cp build.log "$HOST_DIR/build.log" || true
    fi
    echo "[-] Build failed. Check build.log in host."
    exit 1
fi
