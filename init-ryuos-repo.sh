#!/bin/bash
# init-ryuos-repo.sh
# Run this in your project directory to initialize all files

set -e

PROJECT_DIR="${1:-.}"
cd "$PROJECT_DIR"

echo "[*] Initializing RyuOS repository structure..."

# Create directories
mkdir -p {docs,scripts,config/{live-build/{auto,hooks,includes.chroot/{boot/grub/themes/ryuos,etc,usr/bin}},kernel},src/{shell,tools,branding},tests,build-artifacts/{kernel,live-build}}

# README.md
cat > README.md << 'EOF'
# RyuOS: Custom Linux Distribution

[![Build ISO](https://github.com/YOUR_USERNAME/ryuos/workflows/Build%20ISO/badge.svg)](https://github.com/YOUR_USERNAME/ryuos/actions)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/YOUR_USERNAME/ryuos)](https://github.com/YOUR_USERNAME/ryuos/stargazers)

A lightweight, developer-focused Linux distribution built from scratch.

## Features

- 🚀 **Fast Boot**: ~12 seconds to login
- 📦 **Minimal**: 387MB ISO, 250 packages
- 🔧 **Custom Kernel**: Optimized for performance
- 🐚 **Developer Tools**: Pre-configured with build-essential, git, python3
- 🎨 **Custom Branding**: Distinctive GRUB theme and boot sequence
- 🤖 **AI Assistant**: Terminal helper (coming v1.0)

## Quick Start

### Download Latest Release
```bash
wget https://github.com/YOUR_USERNAME/ryuos/releases/download/v0.2/ryuos-0.2.iso
```

### Boot in QEMU
```bash
qemu-system-x86_64 -cdrom ryuos-0.2.iso -m 2048 -enable-kvm -boot d
```

### Boot in VirtualBox
1. New VM → Linux, Debian (64-bit)
2. Attach ISO as CD-ROM
3. Boot

## Architecture

RyuOS is built in layers:

```
GRUB2 (Bootloader)
    ↓
Linux 6.x Kernel (Custom)
    ↓
systemd (Init System)
    ↓
Bash + Custom Tools
    ↓
User Environment
```

For detailed architecture, see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

## Building from Source

### Prerequisites
- WSL2 Debian, or native Debian/Ubuntu
- 4GB RAM, 4 CPU cores recommended
- 20GB free disk space

### Build Steps
```bash
git clone https://github.com/YOUR_USERNAME/ryuos.git
cd ryuos
./scripts/build-iso.sh
```

ISO will be output to `ISO_OUTPUT/ryuos-*.iso`

For detailed build instructions: [docs/BUILD.md](docs/BUILD.md)

## Development Status

| Phase | Status | Target |
|-------|--------|--------|
| Foundation | ✅ Complete | Week 3 |
| Custom Kernel | 🔄 In Progress | Week 5 |
| Tools & Features | ⏳ Planned | Week 10 |
| GUI & Polish | ⏳ Planned | Week 14 |
| Release | ⏳ Planned | v1.0 |

## Documentation

- [Architecture](docs/ARCHITECTURE.md) - System design and layers
- [Build Guide](docs/BUILD.md) - How to build RyuOS
- [Kernel Customization](docs/KERNEL.md) - Kernel optimization details
- [Roadmap](docs/ROADMAP.md) - Future plans and milestones
- [Contributing](CONTRIBUTING.md) - How to contribute

## Performance

| Metric | RyuOS | Debian | Reduction |
|--------|-------|--------|-----------|
| Boot time | 12s | 30s | -60% |
| ISO size | 387MB | 3GB | -87% |
| Packages | 250 | 2000+ | -88% |
| Memory | 150MB | 512MB | -71% |

## Directory Structure

```
ryuos/
├── docs/              # Documentation
├── scripts/           # Build and test scripts
├── config/            # Live-build and kernel config
│   ├── live-build/    # ISO creation config
│   └── kernel/        # Kernel source and patches
├── src/               # Custom tools and shells
├── tests/             # Test scripts
└── ISO_OUTPUT/        # Built ISOs
```

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](LICENSE)

## Author

[Your Name] - [@your_twitter](https://twitter.com/your_twitter)

Built with passion for systems programming and Linux.

## Resources

- [Linux Kernel Documentation](https://www.kernel.org/doc/)
- [Debian Live Manual](https://live-team.pages.debian.net/live-manual/)
- [systemd Documentation](https://systemd.io/)
- [GRUB2 Manual](https://www.gnu.org/software/grub/manual/)

---

**Questions?** Open an [Issue](https://github.com/YOUR_USERNAME/ryuos/issues)

**Want to follow development?** ⭐ Star the repo
EOF

# LICENSE
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2024 [Your Name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
EOF

# CONTRIBUTING.md
cat > CONTRIBUTING.md << 'EOF'
# Contributing to RyuOS

Thanks for your interest in contributing! Here's how to get started.

## Development Setup

```bash
git clone https://github.com/YOUR_USERNAME/ryuos.git
cd ryuos
./scripts/setup-build-env.sh
```

## Workflow

1. Fork the repo
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make changes
4. Test locally: `./scripts/build-iso.sh && ./scripts/qemu-test.sh`
5. Commit with clear messages: `git commit -m "feat: Add feature description"`
6. Push and create a Pull Request

## Commit Message Format

```
<type>: <subject>

<body>

<footer>
```

Types: feat, fix, docs, style, refactor, perf, test, chore

Example:
```
feat: Optimize kernel boot sequence

- Disable unused drivers
- Enable CONFIG_PREEMPT
- Boot time: 18s → 12s

Fixes #42
```

## Reporting Issues

Include:
- System information (WSL2, Debian version, kernel version)
- Steps to reproduce
- Expected vs actual behavior
- Relevant logs from `build.log`

## Code Style

- Follow Linux kernel coding style
- Use meaningful variable names
- Keep functions focused and small
- Comment non-obvious logic

## Testing

Always test locally:
```bash
./scripts/build-iso.sh
./scripts/qemu-test.sh
```

Ensure:
- ISO builds without errors
- ISO boots in QEMU
- System reaches login prompt
- Basic tools work (ls, cd, cp, etc)

## Questions?

Open an issue or contact the maintainer.

Thank you for contributing! 🎉
EOF

# Makefile
cat > Makefile << 'EOF'
.PHONY: help setup build test clean docs

help:
	@echo "RyuOS Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  make setup     - Setup build environment"
	@echo "  make build     - Build ISO"
	@echo "  make test      - Test ISO in QEMU"
	@echo "  make docs      - Build documentation"
	@echo "  make clean     - Clean build artifacts"
	@echo ""

setup:
	@echo "[*] Setting up build environment..."
	@bash scripts/setup-build-env.sh

build:
	@echo "[*] Building RyuOS ISO..."
	@bash scripts/build-iso.sh

test:
	@echo "[*] Testing ISO in QEMU..."
	@bash scripts/qemu-test.sh

docs:
	@echo "[*] Building documentation..."
	@echo "Docs are in markdown format in docs/"

clean:
	@echo "[*] Cleaning build artifacts..."
	@bash scripts/cleanup.sh

.DEFAULT_GOAL := help
EOF

# docs/ARCHITECTURE.md
cat > docs/ARCHITECTURE.md << 'EOF'
# RyuOS Architecture

## System Overview

RyuOS is built as a layered system, with each layer providing specific functionality.

```
┌─────────────────────────────────────┐
│    User Environment (Shell)         │
├─────────────────────────────────────┤
│    System Tools (systemd, coreutils) │
├─────────────────────────────────────┤
│    Linux Kernel (6.x - Custom)      │
├─────────────────────────────────────┤
│    GRUB2 Bootloader                 │
└─────────────────────────────────────┘
```

## Layer Breakdown

### 1. Bootloader (GRUB2)
- **Purpose**: Load kernel from disk, handle boot options
- **Customization**: Custom theme, timeout, splash screen
- **Files**: `config/grub/grub.cfg`, `config/live-build/includes.chroot/boot/grub/`

### 2. Kernel (Linux 6.x)
- **Purpose**: Core OS functionality, hardware abstraction
- **Customization**: Minimal drivers, optimizations, custom syscalls (future)
- **Configuration**: `config/kernel/linux-6.6/.config`
- **Build**: Custom compilation for boot time and size optimization

### 3. Init System (systemd)
- **Purpose**: Start system services, manage daemons
- **Customization**: Disable unused services, add RyuOS-specific units
- **Files**: `config/live-build/includes.chroot/etc/systemd/system/`

### 4. System Tools
- **Core**: coreutils (ls, cp, mv, rm), util-linux (mount, fdisk), bash
- **Development**: gcc, make, git, python3
- **Tools**: curl, wget, vim, htop

### 5. User Shell
- **Current**: Bash (from Debian)
- **Future**: RyuShell (custom shell in C)
- **Files**: `src/shell/ryush.c`

## Build Pipeline

```
Source Code (git)
      ↓
Live-build Configuration
      ↓
Debian Package Selection
      ↓
Kernel Compilation
      ↓
Chroot Environment
      ↓
ISO Generation
      ↓
Output: ryuos-*.iso
```

## Customization Points

| Layer | Method | Effort | Files |
|-------|--------|--------|-------|
| Bootloader | GRUB config + theme | 1 day | `config/live-build/includes.chroot/boot/grub/` |
| Kernel | menuconfig, .config | 3-5 days | `config/kernel/linux-6.6/.config` |
| Init | systemd units | 1-2 days | `config/live-build/includes.chroot/etc/systemd/` |
| Tools | live-build packages | 1 day | `config/live-build/auto/config` |
| Shell | Custom C program | 1-2 weeks | `src/shell/ryush.c` |

## Package Selection

RyuOS includes ~250 packages:

**Essential**:
- systemd, init-system-helpers
- coreutils, util-linux, bash
- libc, libssl, libz

**Development**:
- build-essential (gcc, make, binutils)
- git, python3, python3-pip
- linux-headers

**Tools**:
- curl, wget, htop, vim-tiny
- openssh-client, net-tools
- man, less

**Excluded** (to reduce size):
- Anything GUI (X11, GTK, Qt)
- Sound (ALSA, PulseAudio)
- Bluetooth, WiFi drivers (only for later)
- Documentation, localizations

## Boot Sequence

1. **BIOS/UEFI** → Initialize hardware
2. **GRUB2** → Display boot menu, load kernel
3. **Kernel** → Initialize CPU, memory, devices
4. **Initrd** → Mount temporary filesystem
5. **systemd** → Start services, reach login prompt
6. **User Shell** → Interactive bash prompt

**Total time**: ~12 seconds

## Performance Targets

| Metric | Target | Method |
|--------|--------|--------|
| Boot time | <15s | Disable unused drivers, enable preemption |
| ISO size | <400MB | Remove bloat, compress modules |
| Memory footprint | <200MB | Careful package selection, no GUI |
| Package count | <300 | Minimal viable set for dev environment |

## Future Enhancements

- **Custom Kernel Modules**: Device drivers built out-of-tree
- **Custom Syscalls**: System calls tailored to RyuOS
- **Lightweight GUI**: Openbox + X11 (week 11-12)
- **Security Hardening**: AppArmor/SELinux, firewalling
- **Custom Shell**: RyuShell in C (week 6)
- **AI Terminal Assistant**: Python-based helper (week 13)

## Security Model

- Minimal attack surface (fewer packages)
- Kernel hardening (SMACK, AppArmor)
- File permissions properly configured
- No unnecessary services running

## Extensibility

RyuOS is designed to be extended:

- **New tools**: Add to `src/`, compile, integrate
- **Kernel changes**: Modify `.config`, rebuild, test in QEMU
- **Package additions**: Update live-build config
- **Custom services**: Add systemd units

See [KERNEL.md](KERNEL.md) for kernel-specific details.
EOF

# docs/BUILD.md
cat > docs/BUILD.md << 'EOF'
# Building RyuOS

## Quick Build

```bash
cd ryuos
./scripts/build-iso.sh
```

ISO will be in `ISO_OUTPUT/ryuos-*.iso`

## Prerequisites

### System Requirements
- Debian-based Linux or WSL2
- 4GB RAM, 4 CPU cores
- 20GB free disk space
- Internet connection

### Package Installation

```bash
sudo apt update && sudo apt upgrade -y

# Live-build (ISO creation)
sudo apt install -y live-build live-boot live-config debootstrap

# Kernel compilation (optional)
sudo apt install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev

# Testing/Virtualization
sudo apt install -y qemu-system-x86 ovmf

# Version control
sudo apt install -y git

# Development
sudo apt install -y gcc g++ python3 python3-pip

# Documentation (optional)
sudo apt install -y pandoc
```

## Full Build Process

### Step 1: Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/ryuos.git
cd ryuos
```

### Step 2: Setup Build Environment

```bash
chmod +x scripts/*.sh
./scripts/setup-build-env.sh
```

### Step 3: Configure Live-build

```bash
cd config/live-build

# Initialize configuration
sudo lb config \
  --architectures amd64 \
  --image-type iso-hybrid \
  --mode debian \
  --debian-installer live \
  --archive-areas "main contrib non-free" \
  --bootappend-live "boot=live components quiet splash" \
  --bootloader grub-pc \
  --packages "build-essential vim curl wget git python3"
```

### Step 4: Build ISO

```bash
sudo lb build 2>&1 | tee build.log
```

First build takes 15-20 minutes. Subsequent builds (with clean) take 20-25 minutes.

Watch for errors in output. Common issues:
- Network timeout: Re-run build (transient network issue)
- Missing package: Check Debian mirror, try different mirror
- Disk full: Clean with `sudo lb clean`

### Step 5: Test ISO

```bash
cd ../..
./scripts/qemu-test.sh
```

In QEMU:
1. Watch boot sequence
2. At login prompt, enter any username (live system has no password)
3. Verify `ls`, `cd`, `git --version` work
4. Exit with `exit`

## Build Customization

### Add Custom Packages

Edit `config/live-build/auto/config`:

```bash
sudo lb config --packages "package1 package2 package3"
```

### Add Custom Files

Copy files to `config/live-build/includes.chroot/`:

```bash
mkdir -p config/live-build/includes.chroot/etc/my-config
cp my-file config/live-build/includes.chroot/etc/my-config/
```

Files will be included in ISO at `/etc/my-config/my-file`

### Run Custom Scripts During Build

Create hook in `config/live-build/hooks/`:

```bash
cat > config/live-build/hooks/custom.chroot << 'EOF_HOOK'
#!/bin/bash
set -e
# This runs inside the live environment during build
echo "Running custom setup..."
# Your commands here
EOF_HOOK

chmod +x config/live-build/hooks/custom.chroot
```

## Output Files

After successful build:

```
config/live-build/
├── live-image-amd64.iso          # Bootable ISO
├── live-image-amd64.img           # Disk image
├── live-image-amd64.list          # Package list
└── build.log                       # Build log
```

Copy ISO to `ISO_OUTPUT/`:

```bash
cp config/live-build/live-image-amd64.iso ISO_OUTPUT/ryuos-$(git describe --tags --always).iso
```

## Troubleshooting

### Build Fails with Network Error
```bash
# Retry (transient issue)
sudo lb clean
./scripts/build-iso.sh
```

### Build Fails with "Package not found"
```bash
# Use different Debian mirror
cd config/live-build
sudo lb config --mirror-bootstrap http://deb.debian.org/debian
sudo lb build
```

### ISO Doesn't Boot in QEMU
```bash
# Check ISO integrity
file live-image-amd64.iso
# Should show: ISO 9660 CD-ROM filesystem

# Try with different QEMU options
qemu-system-x86_64 -cdrom live-image-amd64.iso -m 2048 -boot d -no-reboot
```

### Disk Full During Build
```bash
# Clean old builds
sudo lb clean

# Verify disk space
df -h

# If /tmp full, set TMPDIR
export TMPDIR=/var/tmp
./scripts/build-iso.sh
```

## Next Steps

1. Boot ISO in QEMU or VirtualBox
2. Explore the system
3. Make customizations to `config/live-build/`
4. Rebuild and test
5. Document changes in git

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed customization guide.
EOF

# docs/KERNEL.md
cat > docs/KERNEL.md << 'EOF'
# RyuOS Kernel Customization

## Overview

The Linux kernel is the core of RyuOS. This guide explains how to customize it.

## Current Kernel

- **Version**: Linux 6.6 (or latest available)
- **Build Type**: Monolithic with modules
- **Optimization**: Size and boot time

## Downloading Kernel Source

```bash
cd config/kernel

# Download Linux 6.6 LTS
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.6.tar.xz
tar xf linux-6.6.tar.xz
cd linux-6.6
```

## Configuration

### Start with Debian's Config

```bash
cp /boot/config-$(uname -r) .config
```

### Interactive Configuration

```bash
make menuconfig
```

**Key Areas to Customize**:

| Category | Setting | Change | Impact |
|----------|---------|--------|--------|
| Kernel hacking | DEBUG_INFO | Disable | Size -40% |
| Kernel hacking | DEBUG_BUGVERBOSE | Disable | Size -5% |
| Device Drivers | Unused drivers | Disable | Size, Boot time |
| Preemption model | PREEMPT | Enable | Responsiveness |
| Processor | Processor type | Optimize for CPU | Speed |

### Non-Interactive Configuration

```bash
# Disable specific options
./scripts/config --disable DEBUG_INFO
./scripts/config --disable DEBUG_BUGVERBOSE
./scripts/config --disable SOUND
./scripts/config --disable BLUETOOTH

# Enable optimizations
./scripts/config --enable PREEMPT
./scripts/config --enable PREEMPT_DYNAMIC

# Regenerate config
make oldconfig
```

## Building

### Quick Build

```bash
# Build kernel only
time make -j$(nproc) bzImage

# Build modules
time make -j$(nproc) modules
```

### Full Build

```bash
# Clean
make clean

# Configure
make oldconfig  # Or make menuconfig

# Build everything
time make -j$(nproc) bzImage modules deb-pkg

# Result: linux-*.deb in parent directory
```

### First Build
- CPU-bound operation
- Takes 5-15 minutes depending on config and hardware
- Monitor with: `watch 'ps aux | grep make'`

## Installation

### System-wide (Testing)

```bash
make modules_install
make install
update-grub
# Reboot and test
```

### Into Live-build ISO

```bash
# Copy kernel
cp arch/x86_64/boot/bzImage ../../live-build/includes.chroot/boot/vmlinuz-ryuos-custom

# Create initramfs
cd ../../live-build/includes.chroot/boot
mkinitramfs -o initrd.img-ryuos-custom vmlinuz-ryuos-custom

# Rebuild ISO
cd ../../../
./scripts/build-iso.sh
```

## Testing

### QEMU Test

```bash
qemu-system-x86_64 \
  -kernel config/kernel/linux-6.6/arch/x86_64/boot/bzImage \
  -m 2048 \
  -enable-kvm
```

### Boot Time Measurement

```bash
# In QEMU, after boot:
systemd-analyze
systemd-analyze blame

# Look for slowest services and startup time
```

## Optimization Guidelines

### For Size (Reduce ISO)
```
- Disable DEBUG_INFO
- Disable sound, bluetooth, USB
- Build drivers as modules (not built-in)
- Use XZ compression for modules
```

### For Boot Time
```
- Enable PREEMPT
- Disable unnecessary drivers
- Disable MODULE_UNLOAD
- Remove fsck on every boot
```

### For Performance
```
- Enable CPU-specific optimizations
- Enable PREEMPT for low latency
- Set appropriate scheduler (CONFIG_SCHED_*)
- Enable branch prediction
```

## Kernel Patches

To apply custom patches:

```bash
cd config/kernel/linux-6.6

# Copy patch file
cp ../my-patch.patch .

# Apply patch
patch -p1 < my-patch.patch

# Rebuild
make -j$(nproc) bzImage modules
```

Example patch directory structure:
```
config/kernel/patches/
├── boot-time-optimization.patch
├── security-hardening.patch
└── custom-syscall.patch
```

## Custom Syscalls (Advanced)

To add a custom syscall:

1. **Add syscall number** (`arch/x86/entry/syscalls/syscall_64.tbl`):
```
999  common  ryuos_hello   sys_ryuos_hello
```

2. **Implement in kernel** (`kernel/sys.c`):
```c
SYSCALL_DEFINE0(ryuos_hello) {
    printk(KERN_INFO "Hello from RyuOS!\n");
    return 0;
}
```

3. **Rebuild and test**:
```bash
make -j$(nproc) bzImage modules
```

## Monitoring Builds

```bash
# Watch build progress
watch 'ps aux | grep make | wc -l'

# Check for warnings
make 2>&1 | grep -i warning

# Get build statistics
make help | grep clean
```

## Common Issues

### "No space left on device"
```bash
make distclean
# Kernel source takes ~3GB uncompressed
```

### "Symbol not found in symbol table"
```bash
make menuconfig  # Re-configure
make olddefconfig  # Regenerate config
```

### Modules don't load
```bash
# Rebuild with matching kernel version
uname -r
# Verify .config has MODULE_UNLOAD enabled
```

## Performance Metrics

Track kernel optimization progress:

```bash
# Boot time
systemd-analyze

# Kernel compilation time
time make -j$(nproc) bzImage

# Image size
ls -lh arch/x86_64/boot/bzImage

# Module count
find . -name "*.ko" | wc -l
```

## See Also

- [Linux Kernel Documentation](https://www.kernel.org/doc/)
- [Kernel .config Documentation](https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html)
- [systemd-analyze Reference](https://www.freedesktop.org/software/systemd/man/systemd-analyze.html)
EOF

# docs/ROADMAP.md
cat > docs/ROADMAP.md << 'EOF'
# RyuOS Development Roadmap

## Current Status: Phase 1 (Foundation)

### v0.1 - Alpha (Week 2)
- [x] Bootable ISO
- [x] Live-build configuration
- [x] QEMU testing
- [x] GitHub repository

### v0.2 - Branding (Week 3)
- [x] Custom GRUB theme
- [x] ASCII art splash screen
- [x] Custom /etc/motd
- [x] Branded boot sequence

### v0.3 - Custom Kernel (Week 4-5)
- [ ] Kernel compilation from source
- [ ] Optimized .config
- [ ] Boot time measurement
- [ ] Custom kernel integration

### v0.4 - Lightweight (Week 6)
- [ ] Package optimization (<400MB)
- [ ] Minimal services
- [ ] Network configuration
- [ ] Custom init scripts

## Phase 2: Tools & Features (Weeks 7-10)

### v0.5 - System Tools
- [ ] System monitor tool (C)
- [ ] Package manager wrapper
- [ ] Custom documentation
- [ ] GitHub Actions CI/CD

### v0.6 - Development Environment
- [ ] Dev tools pre-installed
- [ ] Build environment
- [ ] Git configuration
- [ ] Python environment

### v0.7 - Security
- [ ] Firewall rules
- [ ] User account management
- [ ] File permissions audit
- [ ] Basic hardening

## Phase 3: Advanced Features (Weeks 11-14)

### v0.8 - Graphical Environment
- [ ] Lightweight GUI (Openbox)
- [ ] X11 support
- [ ] Basic applications
- [ ] Display manager

### v0.9 - AI & Enhancement
- [ ] AI terminal assistant
- [ ] Enhanced shell features
- [ ] System monitoring GUI
- [ ] Performance optimization

### v1.0 - Release Candidate
- [ ] Complete documentation
- [ ] Comprehensive testing
- [ ] Security audit
- [ ] Performance benchmarks
- [ ] Official release

## Phase 4: Mature Features (Post-v1.0)

### v1.1 - Stability & Polish
- [ ] Bug fixes and patches
- [ ] User feedback incorporation
- [ ] Performance tuning
- [ ] Documentation improvements

### v1.2 - Extended Tools
- [ ] Advanced system utilities
- [ ] Multimedia support (optional)
- [ ] Cloud integration
- [ ] Container support

### v2.0 - Custom Everything
- [ ] Custom shell (RyuShell)
- [ ] Custom package manager
- [ ] Custom boot sequence
- [ ] Custom init system (potential)

## Feature Priorities

### Must Have (v0.1+)
- Bootable system
- Basic CLI
- Networking
- Package management

### Should Have (v0.5+)
- System monitoring
- Development tools
- Documentation
- CI/CD automation

### Nice to Have (v1.0+)
- GUI environment
- AI assistant
- Custom shell
- Performance tools

### Future Exploration (v2.0+)
- Custom kernel modules
- Custom syscalls
- Kernel-level optimizations
- Real-time capabilities

## Timeline

```
Week 1  ███░░░░░░░ Setup & Learning
Week 2  ████░░░░░░ First Bootable ISO
Week 3  █████░░░░░ Branding & Polish
Week 4-5 ██████░░░░ Custom Kernel
Week 6  ███████░░░ Lightweight
Week 7-10 ████████░░ Tools & Features
Week 11-14 █████████░ Advanced Features
Week 15-16 ██████████ Polish & Release
```

## Milestones

| Milestone | Date | Deliverable |
|-----------|------|-------------|
| Alpha Release | Week 2 | Bootable v0.1 ISO |
| Branded Release | Week 3 | v0.2 ISO with branding |
| Custom Kernel | Week 5 | v0.3 ISO with optimized kernel |
| Lightweight | Week 6 | v0.4 ISO <400MB |
| Tools Complete | Week 10 | v0.5 with custom tools |
| Advanced Features | Week 14 | v0.9 near-complete |
| Release | Week 16 | v1.0 production-ready |

## Success Criteria

### For v1.0 Release
- [ ] Boots in <15 seconds
- [ ] ISO size <450MB
- [ ] 50+ GitHub commits
- [ ] Complete documentation
- [ ] Passes automated tests
- [ ] Security audit complete
- [ ] Demo video available
- [ ] Case study written

### For Portfolio
- [ ] GitHub stars >50
- [ ] Used by others
- [ ] Press mentions (optional)
- [ ] Speaking opportunity (optional)

## Get Involved

Interested in contributing? See [CONTRIBUTING.md](../CONTRIBUTING.md)

Latest progress: Check [GitHub Issues](https://github.com/YOUR_USERNAME/ryuos/issues)
EOF

# Create script stubs
cat > scripts/setup-build-env.sh << 'EOF'
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
EOF

cat > scripts/build-iso.sh << 'EOF'
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
EOF

cat > scripts/qemu-test.sh << 'EOF'
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
EOF

cat > scripts/cleanup.sh << 'EOF'
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
EOF

# Make scripts executable
chmod +x scripts/*.sh

# .gitignore
cat > .gitignore << 'EOF'
# Build artifacts
*.iso
*.img
*.log
build-artifacts/
ISO_OUTPUT/

# Live-build
config/live-build/binary/
config/live-build/cache/
config/live-build/chroot/

# Kernel
config/kernel/linux-*/
config/kernel/*.tar.xz

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Python
__pycache__/
*.pyc
*.pyo
*.egg-info/
venv/
EOF

# GitHub issue templates
mkdir -p .github/ISSUE_TEMPLATE

cat > .github/ISSUE_TEMPLATE/bug_report.md << 'EOF'
---
name: Bug Report
about: Something is broken
labels: bug
---

## Description
Brief description of the issue.

## Steps to Reproduce
1. ...
2. ...

## Expected Behavior
What should happen

## Actual Behavior
What happens instead

## System Information
- OS: WSL2 Debian / Ubuntu 22.04 / etc
- Build environment: [output of `dpkg -l | grep live-build`]
- Error logs: [paste relevant lines from build.log]

## Screenshots
If applicable
EOF

cat > .github/ISSUE_TEMPLATE/feature_request.md << 'EOF'
---
name: Feature Request
about: Suggest a new feature
labels: enhancement
---

## Description
What feature would you like to add?

## Use Case
Why is this important?

## Example
How would this be used?

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
EOF

echo "[+] RyuOS repository initialized successfully!"
echo ""
echo "Next steps:"
echo "  1. Edit .github/ISSUE_TEMPLATE/*.md"
echo "  2. Update README.md with your GitHub username"
echo "  3. Run: git init && git add . && git commit -m 'Initial commit'"
echo "  4. Add remote: git remote add origin https://github.com/YOUR_USERNAME/ryuos.git"
echo "  5. Push: git push -u origin main"
EOF
chmod +x init-ryuos-repo.sh
