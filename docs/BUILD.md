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
