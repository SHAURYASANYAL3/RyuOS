#!/bin/bash
set -e

cd "$(dirname "$0")/../config/live-build"

echo "[*] Starting RyuOS ISO build..."
echo "[*] This will take 15-20 minutes on first run"

sudo lb clean --all
sudo lb config
sudo lb build 2>&1 | tee build.log

if [ -f "live-image-amd64.iso" ]; then
    echo "[+] Build successful!"
    echo "[+] ISO: $(pwd)/live-image-amd64.iso"
else
    echo "[-] Build failed. Check build.log"
    exit 1
fi
