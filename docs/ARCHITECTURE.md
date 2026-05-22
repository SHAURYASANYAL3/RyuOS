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
