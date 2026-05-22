# RyuOS Architecture & Design Decisions

This document outlines the high-level architecture of RyuOS and the rationale behind critical engineering decisions.

## Build Architecture

RyuOS uses Debian's `live-build` framework. However, the repository abstracts away the complex `config/live-build/` tree by storing components modularly in the root directory:
- `hooks/`: Shell scripts injected into the chroot during build.
- `packages/`: Defines standard APT packages to install.
- `src/`: Custom C tools that are compiled and dynamically injected.

The `Makefile` orchestrates this by copying everything into the correct staging structure before calling `lb build`.

## The Initramfs Optimization Hack

**The Problem**: Decompressing a modern Linux 6.x initramfs into a 128MB RAM environment frequently causes a kernel panic (`System is deadlocked on memory`).
Setting `MODULES=dep` breaks Live ISO booting because the filesystem relies on overlay and loop mounts. Setting `MODULES=list` (and defining only essential modules) strips out Debian `live-boot` integration logic required to actually mount the squashfs `/`.

**The Solution**: RyuOS employs an experimental build hook (`hooks/01-low-ram-opts.chroot`).
1. We set `MODULES=most` and `COMPRESS=gzip` to ensure `live-boot` functions properly without the massive RAM overhead of `xz` decompression.
2. Before `update-initramfs` runs in the build chroot, we temporarily **move** heavy drivers (`drivers/gpu`, `sound`, `net/wireless`) completely out of `/lib/modules/`.
3. The initramfs is generated. It includes all necessary core drivers but excludes the multi-megabyte graphics and audio stacks, keeping the generated `initrd` file under 25MB.
4. After generation, the heavy drivers are moved back into `/lib/modules/` so they remain available on the final booted system.

## RyuShell (`ryush`) Fallback Mechanism

By default, RyuOS sets the login shell to `/usr/local/bin/ryush`. 
Because custom C shells can theoretically segfault or crash, RyuOS relies on the native systemd `getty` configurations. If `ryush` crashes on `tty1`, standard Linux fallback behavior allows the user to switch to `tty2` (Ctrl+Alt+F2) to access a standard login prompt.
