# Building RyuOS

## Quick Build

```bash
make setup
make tools
make iso
```

The ISO is written to `iso/ryuos-cli.iso`.

## Prerequisites

RyuOS is built on a Debian or Ubuntu host, including WSL2 when live-build can run with the required privileges.

Recommended host resources:

- 4 GB RAM
- 4 CPU cores
- 20 GB free disk space
- Working network access to Debian mirrors

Manual dependency install:

```bash
sudo apt update
sudo apt install -y \
  live-build debootstrap squashfs-tools \
  syslinux-utils syslinux genisoimage \
  build-essential gcc make git \
  qemu-system-x86
```

## Build Flow

The top-level build script compiles the custom C tools, mirrors the modular repo layout into a temporary live-build tree, injects hooks/package lists/includes, and then runs `lb build`.

```bash
./scripts/build-iso.sh
```

The temporary build tree defaults to `${HOME}/ryuos-build`. Override it with:

```bash
RYUOS_BUILD_DIR=/path/to/build ./scripts/build-iso.sh
```

## Fast-Boot Profile

The default profile is tuned for a lightweight Openbox live workstation:

- APT recommends are disabled with `--apt-recommends false`.
- `live-config` is excluded; the `live` user is created at build time.
- The boot command line avoids `components` and `splash`.
- `memtest86+` is disabled to reduce image size.
- Heavy desktop daemons such as GVFS, polkit, udisks, portals, and accessibility bridges are purged or masked.

## Testing

```bash
./scripts/qemu-test.sh iso/ryuos-cli.iso 1024 --vnc
```

Login credentials:

- User: `live`
- Password: `live`
- Root password: `root`

Useful smoke checks inside the VM:

```bash
systemd-analyze
free -h
ps -e --no-headers | wc -l
ryu-benchmark
sys-monitor
```

## Troubleshooting

If the build fails with a network error, clean and retry:

```bash
make clean
make iso
```

If QEMU reports the ISO is missing or empty, rebuild. The scripts now reject zero-byte ISO artifacts rather than treating them as successful builds.

If live-build cannot find `isohybrid`, install `syslinux-utils` on the host and rebuild:

```bash
sudo apt install -y syslinux-utils
make iso
```
