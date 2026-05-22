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
