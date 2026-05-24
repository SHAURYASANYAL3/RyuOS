# RyuOS Maintainer Guide

RyuOS is a Debian live-build based distribution tuned for a lightweight Openbox workstation. The repository is intentionally modular: package choices live in `packages/`, build-time mutations live in `hooks/`, and filesystem overlays live in `config/live-build/includes.chroot/`.

## Architecture

```text
Debian live-build
  -> live-boot
  -> systemd
  -> nodm autologin
  -> Openbox session
  -> tint2 + LXTerminal + rofi
  -> RyuOS native tools
```

The default boot path avoids `live-config`. The live user and GUI defaults are built into the image, which removes the expensive service that normally rewrites live-session state on each boot.

## Build Lifecycle

1. `make tools` compiles `ryush` and `sys-monitor` into `build-artifacts/`.
2. `scripts/build-iso.sh` creates a temporary live-build tree under `${RYUOS_BUILD_DIR:-$HOME/ryuos-build}`.
3. Hooks, package lists, compiled tools, and includes are copied into that tree.
4. `lb config` and `lb build` produce the ISO.
5. The validated non-empty ISO is copied to `iso/ryuos-cli.iso`.

## Package Policy

Default packages should support one of these goals:

- Boot the live system.
- Run Openbox, tint2, LXTerminal, and rofi.
- Provide terminal-first development basics.
- Support measurement, debugging, or low-memory operation.

Avoid default packages that pull browser engines, desktop portals, automounters, policy agents, accessibility daemons, compositors, or large icon themes without measured need.

## Boot Optimization Policy

Use these rules when changing boot behavior:

- Keep `--apt-recommends false`.
- Keep `components`, `splash`, and `live-config` off the default boot path.
- Mask wait-online services unless a feature explicitly depends on them.
- Prefer build-time user/session setup over runtime mutation.
- Keep initramfs changes measurable and reversible.

## Release Smoke Test

Inside QEMU:

```bash
systemd-analyze
systemd-analyze blame | head -20
free -h
ps -e --no-headers | wc -l
ryu-benchmark
sys-monitor
```

From the host:

```bash
du -h iso/ryuos-cli.iso
./tests/run-tests.sh
```

Record ISO size, boot time, idle RAM, process count, and any service regressions before tagging a release.
