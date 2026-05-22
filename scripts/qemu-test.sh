#!/bin/bash
# Boot RyuOS ISO in QEMU (WSLg GUI, terminal, or VNC)
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# Prefer ~/ryuos-cli.iso (ext4) — copies on /mnt/d/ may be root-owned or read-only
if [ -f "${HOME}/ryuos-cli.iso" ]; then
    ISO_PATH="${HOME}/ryuos-cli.iso"
else
    ISO_PATH="${PROJECT_DIR}/ISO/ryuos-cli.iso"
fi
MEM_SIZE="1024"
DISPLAY_MODE="auto"   # auto | gui | text | vnc
KERNEL_APPEND=""

usage() {
    echo "Usage: $0 [ISO_PATH] [RAM_MB] [--gui|--text|--vnc|--rescue]"
    echo ""
    echo "  --gui    Force graphical window (needs WSLg / X server)"
    echo "  --text   Boot inside this terminal (no window needed)"
    echo "  --vnc    Listen on 127.0.0.1:5900 — connect with a VNC viewer on Windows"
    echo "  --rescue Skip login — drops straight to root shell (broken ISO workaround)"
    echo ""
    echo "Examples:"
    echo "  $0"
    echo "  $0 ISO/ryuos-cli.iso 2048"
    echo "  $0 ISO/ryuos-cli.iso 2048 --text"
}

while [ $# -gt 0 ]; do
    case "$1" in
        --gui)  DISPLAY_MODE="gui" ;;
        --text) DISPLAY_MODE="text" ;;
        --vnc)    DISPLAY_MODE="vnc" ;;
        --rescue) KERNEL_APPEND="boot=live init=/bin/bash rw" ;;
        -h|--help) usage; exit 0 ;;
        *)
            if [ -f "$1" ]; then
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

if [ ! -f "$ISO_PATH" ]; then
    echo "[-] ISO not found: $ISO_PATH"
    echo "[-] Build first: ./scripts/build-iso.sh  (or: ./scripts/finish-iso.sh)"
    exit 1
fi

if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
    echo "[-] qemu-system-x86_64 not found. Run: sudo apt install -y qemu-system-x86"
    exit 1
fi

# WSLg: Ubuntu often starts without DISPLAY set even when GUI is available
setup_wslg_display() {
    if [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
        return 0
    fi
    if [ -S /tmp/.X11-unix/X0 ]; then
        export DISPLAY=:0
        echo "[+] WSLg detected — set DISPLAY=:0"
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
    echo "[-] KVM not available — software emulation (slower, first boot may take 2–5 min)."
    KVM_OPTS=("-cpu" "max")
fi

DISPLAY_OPTS=()
case "$DISPLAY_MODE" in
    gui)
        setup_wslg_display
        if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
            echo "[-] No graphical display. Use --text or --vnc, or run from Windows Terminal with WSLg."
            exit 1
        fi
        DISPLAY_OPTS=("-vga" "std")
        echo "[*] Graphical mode — QEMU window should appear on your Windows desktop."
        ;;
    text)
        DISPLAY_OPTS=("-display" "curses" "-vga" "std")
        echo "[*] Terminal mode — boot output appears here."
        echo "[*] Exit QEMU: Ctrl+A, then X"
        ;;
    vnc)
        DISPLAY_OPTS=("-vga" "std" "-display" "vnc=127.0.0.1:0")
        echo "[*] VNC mode — on Windows, open a VNC viewer to: 127.0.0.1:5900"
        echo "[*] (TigerVNC / RealVNC / built-in Remote Desktop won't work — use a VNC client)"
        ;;
    auto)
        setup_wslg_display
        if [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
            DISPLAY_OPTS=("-vga" "std")
            echo "[+] Graphical mode (WSLg) — check your Windows taskbar for a QEMU window."
        else
            DISPLAY_OPTS=("-display" "curses" "-vga" "std")
            echo "[*] No GUI display found — using terminal mode."
            echo "[*] Exit QEMU: Ctrl+A, then X  |  For a window: $0 --gui"
        fi
        ;;
esac

echo "[*] Booting: $ISO_PATH"
echo "[*] RAM: ${MEM_SIZE}MB — Stop: close QEMU window, or Ctrl+C here"
if [ -n "$KERNEL_APPEND" ]; then
    echo "[*] Rescue mode: no login required (root shell via init=/bin/bash)"
fi

QEMU_ARGS=(
    -cdrom "$ISO_PATH"
    -m "$MEM_SIZE"
    "${KVM_OPTS[@]}"
    -boot d
    "${DISPLAY_OPTS[@]}"
    "-netdev" "user,id=net0" "-device" "virtio-net-pci,netdev=net0"
)

if [ -n "$KERNEL_APPEND" ]; then
    QEMU_ARGS+=(-append "$KERNEL_APPEND")
fi

qemu-system-x86_64 "${QEMU_ARGS[@]}"
