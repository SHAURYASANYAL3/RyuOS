#!/bin/bash
# Compile RyuOS custom tools into includes.chroot for live-build
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BIN_DIR="$HOST_DIR/config/live-build/includes.chroot/usr/local/bin"

if ! command -v gcc >/dev/null 2>&1; then
    echo "[-] gcc not found. Install build-essential first."
    exit 1
fi

mkdir -p "$BIN_DIR"

echo "[*] Building ryush..."
gcc -O2 -Wall -Wextra -Wno-unused-parameter \
    -o "$BIN_DIR/ryush" "$HOST_DIR/src/shell/ryush.c"

echo "[*] Building sys-monitor..."
gcc -O2 -Wall -Wextra \
    -o "$BIN_DIR/sys-monitor" "$HOST_DIR/src/tools/sys-monitor.c"

chmod +x "$BIN_DIR/ryush" "$BIN_DIR/sys-monitor"
echo "[+] Tools installed to $BIN_DIR"
