#!/bin/bash
set -e

echo "[*] Setting up RyuOS build environment..."

# Check for required tools
echo "[*] Checking prerequisites..."
for cmd in git gcc make apt; do
    if ! command -v $cmd &> /dev/null; then
        echo "[-] $cmd not found. Please install first."
        exit 1
    fi
done

echo "[*] Installing build dependencies..."
sudo apt update -q

# Install live-build
if ! command -v lb &> /dev/null; then
    sudo apt install -y live-build live-boot live-config debootstrap
fi

# Install kernel build tools
if ! command -v gcc &> /dev/null; then
    sudo apt install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev
fi

# Install QEMU
if ! command -v qemu-system-x86_64 &> /dev/null; then
    sudo apt install -y qemu-system-x86
fi

echo "[+] Build environment ready!"
echo ""
echo "Next steps:"
echo "  1. Review config/live-build/auto/config"
echo "  2. Run: ./scripts/build-iso.sh"
echo "  3. Test: ./scripts/qemu-test.sh"
