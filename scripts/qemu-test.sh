#!/bin/bash
# Boot RyuOS ISO in QEMU (WSLg GUI, terminal, or VNC)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -s "${HOME}/ryuos-cli.iso" ]; then
    ISO_PATH="${HOME}/ryuos-cli.iso"
elif [ -s "${PROJECT_DIR}/iso/ryuos-cli.iso" ]; then
    ISO_PATH="${PROJECT_DIR}/iso/ryuos-cli.iso"
else
    ISO_PATH="${PROJECT_DIR}/ISO/ryuos-cli.iso"
fi

MEM_SIZE="2048"
DISPLAY_MODE="auto"   # auto | gui | text | vnc
KERNEL_APPEND=""

usage() {
    echo "Usage: $0 [ISO_PATH] [RAM_MB] [--gui|--text|--vnc|--rescue]"
    echo ""
    echo "  --gui     Force graphical window (needs WSLg / X server)"
    echo "  --text    Boot inside this terminal (no window needed)"
    echo "  --vnc     Listen on 127.0.0.1:5900; connect with a VNC viewer"
    echo "  --rescue  Skip login and drop to a root shell"
    echo ""
    echo "Examples:"
    echo "  $0"
    echo "  $0 iso/ryuos-cli.iso 1024 --vnc"
    echo "  $0 iso/ryuos-cli.iso 512 --text"
}

while [ $# -gt 0 ]; do
    case "$1" in
        --gui) DISPLAY_MODE="gui" ;;
        --text) DISPLAY_MODE="text" ;;
        --vnc) DISPLAY_MODE="vnc" ;;
        --rescue) KERNEL_APPEND="boot=live init=/bin/bash rw" ;;
        -h|--help) usage; exit 0 ;;
        *)
            if [ -s "$1" ] || [[ "$1" == *.iso ]]; then
                ISO_PATH="$1"
            elif [[ "$1" =~ ^[0-9]+$ ]]; then
                MEM_SIZE="$1"
            else
                echo "[-] Unknown argument: $1"
                usage
                exit 1
            fi
            ;;
    esac
    shift
done

if [ ! -s "$ISO_PATH" ]; then
    echo "[-] ISO not found or empty: $ISO_PATH"
    echo "[-] Build first: ./scripts/build-iso.sh"
    exit 1
fi

if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
    echo "[-] qemu-system-x86_64 not found. Run: sudo apt install -y qemu-system-x86"
    exit 1
fi

setup_wslg_display() {
    if [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
        return 0
    fi
    if [ -S /tmp/.X11-unix/X0 ]; then
        export DISPLAY=:0
        echo "[+] WSLg detected; set DISPLAY=:0"
    fi
    if [ -S /mnt/wslg/runtime-dir/wayland-0 ]; then
        export WAYLAND_DISPLAY=wayland-0
        export XDG_RUNTIME_DIR=/mnt/wslg/runtime-dir
    fi
}

KVM_OPTS=()
if [ -c /dev/kvm ] && [ -r /dev/kvm ] && [ -w /dev/kvm ]; then
    echo "[+] KVM acceleration enabled."
    KVM_OPTS=("-enable-kvm" "-cpu" "host")
else
    echo "[-] KVM not available; software emulation will be slower."
    KVM_OPTS=("-cpu" "max")
fi

DISPLAY_OPTS=()
case "$DISPLAY_MODE" in
    gui)
        setup_wslg_display
        if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
            echo "[-] No graphical display. Use --text or --vnc."
            exit 1
        fi
        DISPLAY_OPTS=("-vga" "std")
        echo "[*] Graphical mode selected."
        ;;
    text)
        DISPLAY_OPTS=("-display" "curses" "-vga" "std")
        echo "[*] Terminal mode selected. Exit QEMU with Ctrl+A, then X."
        ;;
    vnc)
        DISPLAY_OPTS=("-vga" "std" "-display" "vnc=127.0.0.1:0")
        echo "[*] VNC mode selected. Connect to 127.0.0.1:5900."
        ;;
    auto)
        setup_wslg_display
        if [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
            DISPLAY_OPTS=("-vga" "std")
            echo "[+] Graphical mode selected automatically."
        else
            DISPLAY_OPTS=("-display" "curses" "-vga" "std")
            echo "[*] No GUI display found; using terminal mode."
            echo "[*] Exit QEMU with Ctrl+A, then X."
        fi
        ;;
esac

if [ ! -f "ryuos-storage.qcow2" ]; then
    echo "[*] Creating 10GB persistent virtual drive..."
    qemu-img create -f qcow2 ryuos-storage.qcow2 10G
fi

echo "[*] Booting: $ISO_PATH"
echo "[*] RAM: ${MEM_SIZE}MB"
if [ -n "$KERNEL_APPEND" ]; then
    echo "[*] Rescue mode enabled."
fi

QEMU_ARGS=(
    -cdrom "$ISO_PATH"
    -m "$MEM_SIZE"
    "${KVM_OPTS[@]}"
    -boot d
    "${DISPLAY_OPTS[@]}"
    "-netdev" "user,id=net0" "-device" "virtio-net-pci,netdev=net0"
    "-drive" "file=ryuos-storage.qcow2,format=qcow2,if=virtio"
)

if [ -n "$KERNEL_APPEND" ]; then
    QEMU_ARGS+=(-append "$KERNEL_APPEND")
fi

qemu-system-x86_64 "${QEMU_ARGS[@]}"
