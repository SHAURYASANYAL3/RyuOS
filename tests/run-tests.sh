#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

log_info() { echo -e "\033[1;34m[*]\033[0m $1"; }
log_success() { echo -e "\033[1;32m[+]\033[0m $1"; }
log_error() { echo -e "\033[1;31m[-]\033[0m $1" >&2; }

log_info "Running RyuOS Test Suite..."

# 1. Check Directory Structure
log_info "Validating directory structure..."
for dir in branding build config docs hooks packages scripts src tests tools .github; do
    if [ ! -d "$HOST_DIR/$dir" ]; then
        log_error "Missing required directory: $dir"
        exit 1
    fi
done
log_success "Directory structure is valid."

# 2. Lint Shell Scripts (Requires shellcheck)
log_info "Linting shell scripts..."
if command -v shellcheck >/dev/null 2>&1; then
    shellcheck "$HOST_DIR/scripts/"*.sh "$HOST_DIR/tests/"*.sh "$HOST_DIR/hooks/"*.chroot
    log_success "Shell scripts passed linting."
else
    log_info "shellcheck not installed. Skipping linting test."
fi

# 3. Validate boot/package optimization guardrails
log_info "Validating boot/package optimization guardrails..."
PKG_LIST="$HOST_DIR/packages/ryuos.list"
if grep -Ev '^\s*(#|$)' "$PKG_LIST" | grep -Eq '^(live-config|live-config-systemd|surf|pcmanfm|picom|plymouth|plymouth-themes|papirus-icon-theme)\b'; then
    log_error "Banned boot/bloat package found in packages/ryuos.list."
    exit 1
fi
if ! grep -q -- '--apt-recommends false' "$HOST_DIR/config/live-build/auto/config"; then
    log_error "live-build must keep APT recommends disabled for the low-RAM profile."
    exit 1
fi
if grep -q 'components' "$HOST_DIR/config/live-build/auto/config"; then
    log_error "live-config components boot path is still enabled."
    exit 1
fi
log_success "Optimization guardrails are valid."

# 4. Test C Compilation (RyuShell & sys-monitor)
log_info "Testing C compilation..."
if command -v make >/dev/null 2>&1 && command -v gcc >/dev/null 2>&1; then
    cd "$HOST_DIR"
    make tools
    if [ ! -x "$HOST_DIR/build-artifacts/ryush" ] || [ ! -x "$HOST_DIR/build-artifacts/sys-monitor" ]; then
        log_error "C binaries failed to compile."
        exit 1
    fi
    log_success "C binaries compiled successfully."
else
    log_info "make or gcc not installed. Skipping compilation test."
fi

log_success "All validation tests passed!"
exit 0
