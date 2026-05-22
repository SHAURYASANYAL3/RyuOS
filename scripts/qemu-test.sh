#!/bin/bash
ISO_PATH="${1:-../config/live-build/live-image-amd64.iso}"

if [ ! -f "$ISO_PATH" ]; then
    echo "[-] ISO not found: $ISO_PATH"
    exit 1
fi

echo "[*] Booting RyuOS in QEMU..."
echo "[*] To exit: Ctrl+C or close window"

qemu-system-x86_64 \
    -cdrom "$ISO_PATH" \
    -m 2048 \
    -enable-kvm \
    -boot d \
    -cpu host
