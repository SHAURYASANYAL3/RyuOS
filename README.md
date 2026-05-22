# RyuOS: Ultra-Lightweight Custom Linux Distribution

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/SHAURYASANYAL3/RyuOS)](https://github.com/SHAURYASANYAL3/RyuOS/stargazers)

A custom, extremely lightweight, developer-focused Linux distribution built entirely from scratch. Optimized to run on practically any PC or laptop, with a base CLI version capable of booting seamlessly with highly constrained hardware (128MB RAM targets).

## Features

- 🚀 **Lightning Fast Boot**: Boots directly into a custom shell in seconds.
- 📦 **Ultra Minimal Footprint**: ~300MB ISO, highly stripped initramfs environment.
- 🐚 **Custom RyuShell**: A bespoke C-based terminal shell (`ryush`) set as the default login.
- 📊 **Custom System Tools**: Includes a native C-based `sys-monitor` for hardware telemetry.
- 🧠 **Smart Initramfs Tuning**: Uses `MODULES=most` with temporary heavy driver stripping and `gzip` compression to achieve successful boots in <1GB RAM scenarios while preserving `live-boot` integration.
- 🎨 **Custom Branding**: Distinctive boot sequence and custom Message of the Day (MOTD) ASCII art.
- 🛠️ **Developer Ready**: Comes pre-configured with `python3`, `git`, `gcc`, `make`, `htop`, `nano`, and essential networking utilities (`curl`, `wget`, `iproute2`).

## Quick Start

### 1. Download the Latest ISO
Download the `ryuos-cli.iso` from the `ISO/` directory or the latest release page (once published).

### 2. Boot in QEMU (Recommended for Testing)
Run the provided script to test it locally. (Requires QEMU installed):
```bash
# Boot with 1GB RAM in graphical mode (or VNC)
./scripts/qemu-test.sh ISO/ryuos-cli.iso 1024
```
_Note: If you run into memory lockups during initramfs decompression, allocate at least 1024MB RAM._

### 3. Login
- **Username:** `user`
- **Password:** `live`

## Architecture

RyuOS is built in layers using Debian `live-build`:

```
GRUB2 (Bootloader)
    ↓
Linux 6.1 Kernel (Debian Bookworm base)
    ↓
systemd (Init System - heavily stripped)
    ↓
RyuShell (`ryush` - Default User Shell)
    ↓
User Environment (Custom C tools, Python3, Git)
```

## Building from Source

### Prerequisites
- Debian or Ubuntu host (or WSL2 running Debian/Ubuntu)
- At least 4GB RAM to execute the build
- ~10GB free disk space
- `live-build`, `debootstrap`, `squashfs-tools`, `syslinux-utils`, `qemu-system-x86`

### Build Steps
```bash
git clone https://github.com/SHAURYASANYAL3/RyuOS.git
cd RyuOS
./scripts/build-iso.sh
```

The compiled ISO will be placed in the `ISO/` directory as `ryuos-cli.iso`.

### Custom Development
If you modify the custom C tools in `src/`, they will be automatically recompiled and injected into the live filesystem during the build process thanks to `scripts/build-tools.sh`.

## Directory Structure

```
RyuOS/
├── config/            # Debian live-build configurations & hooks
│   └── live-build/    # Package lists, custom initramfs hooks
├── ISO/               # Directory for built ISO artifacts
├── scripts/           # Build scripts (`build-iso.sh`, `qemu-test.sh`)
├── src/               # Custom C applications (RyuShell, sys-monitor)
├── README.md          # This file
└── Makefile           # Project makefile
```

## Author

**SHAURYASANYAL3**
Built with passion for systems programming, operating system design, and lightweight computing.

## License

MIT License - see [LICENSE](LICENSE)
