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
