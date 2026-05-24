# RyuOS Development Roadmap

## Phase 1: Foundation (Completed)

- Build a minimal Debian Bookworm live ISO.
- Add the live-build configuration and modular hook/package/include layout.
- Optimize initramfs generation for low-memory boot support.
- Implement `ryush` and `sys-monitor`.
- Establish Makefile, CI, and QEMU test entry points.

## Phase 2: Fast Lightweight Workstation (Current)

- Keep `live-config` off the boot path.
- Keep APT recommends disabled in the default profile.
- Reduce package bloat from browser, file-manager, portal, accessibility, and policykit stacks.
- Track boot time, idle RAM, process count, and ISO size after each release build.
- Preserve Openbox, nodm, tint2, LXTerminal, and rofi as the lightweight GUI baseline.

## Phase 3: Native Tooling

- Add piping and redirection support to `ryush`.
- Expand `sys-monitor` with disk I/O and network telemetry.
- Add a boot/RAM benchmark smoke test that can be run from QEMU.
- Add package-manifest diff tooling for release audits.

## Phase 4: Optional Experiments

- Explore a custom C status bar only if tint2 becomes a measurable bottleneck.
- Explore terminal-first AI/API utilities as optional packages, not default boot-path dependencies.
- Evaluate alternate kernels or initramfs compression only with measured boot and RAM data.

## Long-Term Priorities

1. Maintainability: simple scripts, documented hooks, reproducible builds.
2. Minimalism: every default package must justify its size and runtime process cost.
3. Low-end compatibility: prioritize QEMU and older x86_64 machines over visual effects.
4. Measurement: no optimization is considered done until it has a build or runtime metric.
