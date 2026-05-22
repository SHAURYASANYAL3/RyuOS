# RyuOS Quick Reference

## Initial Setup (Day 1)

```bash
# WSL2 (in Debian)
wsl -l -v
wsl --set-default Debian

# Install tools
sudo apt update && sudo apt upgrade -y
sudo apt install -y live-build live-boot live-config build-essential \
  bison flex libssl-dev libelf-dev libncurses-dev \
  qemu-system-x86 git gcc g++ python3 python3-pip

# Setup project
mkdir -p ~/projects && cd ~/projects
mkdir ryuos && cd ryuos

# Initialize repo
bash /home/claude/init-ryuos-repo.sh

# GitHub setup
git init
git remote add origin https://github.com/YOUR_USERNAME/ryuos.git
git branch -M main
git add .
git commit -m "Initial commit: RyuOS structure and documentation"
git push -u origin main
```

## Build & Test Cycle

```bash
# Build ISO (15-20 min first time)
./scripts/build-iso.sh

# Test in QEMU
./scripts/qemu-test.sh

# QEMU keyboard shortcuts
Ctrl+Alt+G  → Release mouse capture
Ctrl+C      → Quit QEMU
Ctrl+Alt+1  → Console
Ctrl+Alt+2  → Monitor
```

## Git Workflow

```bash
# Feature branch
git checkout -b feature/custom-kernel

# Make changes...
# Build and test...

# Commit with message
git add .
git commit -m "feat: Add custom kernel optimization

- Disable unused drivers
- Enable CONFIG_PREEMPT
- Boot time: 18s → 12s"

# Push and PR
git push origin feature/custom-kernel
# Create PR on GitHub

# Merge to main
git checkout main
git pull
git merge feature/custom-kernel
git push
```

## Kernel Customization

```bash
# Download kernel
cd config/kernel
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.6.tar.xz
tar xf linux-6.6.tar.xz
cd linux-6.6

# Configure
cp /boot/config-$(uname -r) .config
make menuconfig  # Interactive, or:
./scripts/config --disable DEBUG_INFO
make oldconfig

# Build
time make -j$(nproc) bzImage
time make -j$(nproc) modules

# Test (in QEMU before integrating)
qemu-system-x86_64 -kernel arch/x86_64/boot/bzImage -m 2048 -enable-kvm

# Integrate into ISO
cp arch/x86_64/boot/bzImage ../../live-build/includes.chroot/boot/vmlinuz-ryuos
cd ../../
./scripts/build-iso.sh
```

## Live-build Configuration

```bash
# Quick add package
cd config/live-build
sudo lb config --packages "vim python3 htop"

# Add custom files
mkdir -p includes.chroot/etc/myconfig
cp file.conf includes.chroot/etc/myconfig/

# Add startup script
cat > hooks/custom.chroot << 'EOF'
#!/bin/bash
echo "Custom setup"
EOF
chmod +x hooks/custom.chroot

# Rebuild
sudo lb clean
sudo lb build
```

## Debugging

```bash
# Check build logs
tail -f config/live-build/build.log

# Look for errors/warnings
grep -i "error\|warning" config/live-build/build.log | head -20

# Test specific component
qemu-system-x86_64 -cdrom config/live-build/live-image-amd64.iso -m 2048 -boot d -no-reboot

# Measure boot time (from inside QEMU)
systemd-analyze
systemd-analyze blame
```

## Release Process

```bash
# Tag release
git tag -a v0.2 -m "Add custom branding"

# Push tags
git push origin --tags

# Create GitHub release
# 1. Go to GitHub repo → Releases
# 2. "Create a release"
# 3. Select tag v0.2
# 4. Add description
# 5. Upload ISO from ISO_OUTPUT/

# Copy ISO for release
cp config/live-build/live-image-amd64.iso \
   ISO_OUTPUT/ryuos-$(git describe --tags --always).iso
```

## Performance Measurement

```bash
# Boot time (from QEMU output)
# Count seconds from GRUB splash to login prompt

# ISO size
ls -lh config/live-build/live-image-amd64.iso

# Kernel size
ls -lh config/kernel/linux-6.6/arch/x86_64/boot/bzImage

# Package count
ls -1 config/live-build/chroot/var/lib/apt/lists/*Packages | wc -l
```

## Common Issues & Fixes

| Issue | Solution |
|-------|----------|
| Build hangs | Ctrl+C, run `sudo lb clean`, retry |
| Network timeout | Check internet, retry build |
| Disk full | `sudo lb clean`, check disk space |
| ISO doesn't boot | Check ISO integrity: `file *.iso` |
| QEMU window stuck | Ctrl+Alt+G to release mouse, Ctrl+C to quit |
| Permission denied | Use `sudo` for live-build commands |

## Testing Checklist

- [ ] ISO builds without errors
- [ ] ISO boots in QEMU
- [ ] System reaches login prompt
- [ ] Basic tools work (ls, cd, cat, vim)
- [ ] Networking works (ping, wget)
- [ ] Can run python3, gcc, git
- [ ] Custom branding visible in GRUB
- [ ] Boot time acceptable (<20s)

## Files You'll Edit Most

```
config/live-build/auto/config         ← Live-build settings
config/kernel/linux-6.6/.config       ← Kernel config
config/live-build/includes.chroot/... ← System files
docs/README.md                         ← Main docs
scripts/*.sh                           ← Build scripts
```

## Key Milestones

| Week | Goal | Output |
|------|------|--------|
| 1 | Setup, learn | Working environment |
| 2 | Bootable ISO | v0.1 release |
| 3 | Branding | v0.2 release |
| 4-5 | Kernel | v0.3 release |
| 6 | Lightweight | v0.4 release |
| 7-10 | Tools | v0.5 release |
| 11-14 | Advanced | v0.9 release |
| 15-16 | Polish | v1.0 release |

## Learning Resources

- [Linux Kernel Documentation](https://www.kernel.org/doc/)
- [Debian Live Manual](https://live-team.pages.debian.net/live-manual/)
- [GRUB2 Manual](https://www.gnu.org/software/grub/manual/)
- [systemd Documentation](https://systemd.io/)

## One-Liners

```bash
# Full build from scratch
sudo lb clean && ./scripts/build-iso.sh && ./scripts/qemu-test.sh

# Count what's in ISO
sudo chroot config/live-build/chroot dpkg -l | wc -l

# Find largest packages
cd config/live-build/chroot/var/lib/apt/lists
grep ^Package <(zcat *Packages.gz) | sort | uniq | head -10

# Measure kernel size
du -sh config/kernel/linux-6.6

# Check systemd boot performance
sudo systemd-analyze plot > boot-timeline.svg
```

## Emergency Commands

```bash
# Kill stuck QEMU
pkill -9 qemu-system

# Unmount stuck mounts
sudo umount -l config/live-build/chroot/proc
sudo umount -l config/live-build/chroot/sys
sudo umount -l config/live-build/chroot/dev

# Reset live-build state
sudo lb clean --all
rm -rf config/live-build/{binary,cache,chroot}

# Force rebuild everything
./scripts/cleanup.sh && ./scripts/build-iso.sh
```

## Progress Tracking

Mark completion:
```bash
# Week 1 ✓
# Week 2 ✓
# Week 3 [IN PROGRESS] - Working on custom branding
# Week 4 ⏳ Upcoming: Kernel compilation
```

## Getting Help

1. **Build Error?** → Read `config/live-build/build.log`
2. **Git Issue?** → `git status`, `git log --oneline -10`
3. **QEMU Problem?** → Boot with `-no-reboot` to see final error
4. **Kernel Issue?** → Consult [KERNEL.md](docs/KERNEL.md)

---

**Last Updated:** Week 1  
**Current Phase:** Foundation (v0.1-0.4)  
**Next Milestone:** Bootable ISO (Week 2)
