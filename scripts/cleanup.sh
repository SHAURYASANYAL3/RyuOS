#!/bin/bash
# Remove build artifacts (uses sudo for root-owned live-build files)
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WSL_BUILD_DIR="${RYUOS_BUILD_DIR:-$HOME/ryuos-build}"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

echo "[*] Cleaning build artifacts..."

if [ -d "$PROJECT_DIR/config/live-build" ] && command -v lb >/dev/null 2>&1; then
    cd "$PROJECT_DIR/config/live-build"
    run_root lb clean --all 2>/dev/null || true
fi

run_root rm -rf "$WSL_BUILD_DIR" 2>/dev/null || true
run_root rm -f "$PROJECT_DIR/ISO/ryuos-cli.iso" 2>/dev/null || true
run_root rm -f "$HOME/ryuos-cli.iso" 2>/dev/null || true
rm -f "$PROJECT_DIR/build.log" 2>/dev/null || true

echo "[+] Cleanup complete"
