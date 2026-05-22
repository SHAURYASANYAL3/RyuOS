#!/bin/bash

echo "[*] Cleaning build artifacts..."

cd "$(dirname "$0")/.."

# Clean live-build
cd config/live-build
sudo lb clean --all

# Clean kernel builds
cd ../kernel
rm -rf linux-6.6/arch/x86_64/boot/bzImage
rm -rf *.o *.ko

echo "[+] Cleanup complete"
