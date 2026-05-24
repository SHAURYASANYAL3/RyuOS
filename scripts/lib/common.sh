# Shared helpers for RyuOS build scripts (source, do not execute)

run_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

# Copy ISO to ~/ryuos-cli.iso (always writable) and the project iso/ folder.
copy_iso_to_project() {
    local src="$1"
    local host_dir="$2"
    local user
    user="$(whoami)"
    local home_iso="${HOME}/ryuos-cli.iso"

    if [ ! -f "$src" ]; then
        echo "[-] ISO not found: $src"
        return 1
    fi

    echo "[*] Installing ISO to $home_iso ..."
    run_root cp "$src" "$home_iso"
    run_root chown "$user:$user" "$home_iso" 2>/dev/null || chmod 644 "$home_iso" 2>/dev/null || true

    if [[ "$host_dir" == /mnt/* ]]; then
        mkdir -p "$host_dir/iso" 2>/dev/null || run_root mkdir -p "$host_dir/iso"
        run_root rm -f "$host_dir/iso/ryuos-cli.iso" 2>/dev/null || true
        echo "[*] Copying ISO to Windows project folder..."
        run_root cp "$home_iso" "$host_dir/iso/ryuos-cli.iso"
        run_root chmod 666 "$host_dir/iso/ryuos-cli.iso" 2>/dev/null || true
        echo "[+] Windows copy: $host_dir/iso/ryuos-cli.iso"
    else
        mkdir -p "$host_dir/iso"
        cp "$home_iso" "$host_dir/iso/ryuos-cli.iso"
        echo "[+] Project copy: $host_dir/iso/ryuos-cli.iso"
    fi

    echo "[+] Primary ISO (use for QEMU): $home_iso"
    du -h "$home_iso" | awk '{print "[+] Size: " $1}'
}
