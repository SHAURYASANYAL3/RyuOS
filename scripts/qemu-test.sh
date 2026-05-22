#!/bin/bash
# scripts/qemu-test.sh - Run RyuOS in QEMU inside WSL (supporting WSLg GUI)
set -e

ISO_PATH="${1:-/mnt/d/quests/side_quest-1/ISO/ryuos-cli.iso}"
MEM_SIZE="${2:-128}"

if [ ! -f "$ISO_PATH" ]; then
    echo "[-] ISO not found: $ISO_PATH"
    echo "[-] Make sure you build it first using: ./scripts/build-iso.sh"
    exit 1
fi

echo "[*] Booting RyuOS in QEMU with ${MEM_SIZE}MB RAM..."
echo "[*] To exit: Close the QEMU window or press Ctrl+C in terminal."

# Check if KVM is available
KVM_OPTS=""
if [ -c /dev/kvm ] && [ -w /dev/kvm ]; then
    echo "[+] KVM acceleration detected. Using KVM."
    KVM_OPTS="-enable-kvm -cpu host"
else
    echo "[-] KVM acceleration NOT available. Running in emulation mode (slower)."
    KVM_OPTS="-cpu max"
fi

qemu-system-x86_64 \
    -cdrom "$ISO_PATH" \
    -m "$MEM_SIZE" \
    $KVM_OPTS \
    -boot d \
    -vga std \
    -net nic -net user
