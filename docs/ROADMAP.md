# RyuOS Development Roadmap

This document outlines the strategic vision and upcoming milestones for the RyuOS project. 

## Phase 1: Foundation (Completed ✅)
- **Goal**: Build a bare-minimum, bootable ISO from scratch based on Debian Bookworm.
- **Milestones**:
  - Setup `live-build` configuration.
  - Optimize initramfs (`MODULES=most` with heavy driver stripping) for <1GB RAM boot support.
  - Implement a basic C-based shell (`ryush`).
  - Implement a custom C-based hardware monitor (`sys-monitor`).
  - Establish Makefile and CI/CD pipelines.

## Phase 2: Core Developer Tooling (Current 🔄)
- **Goal**: Expand the native command-line utilities and improve developer ergonomics.
- **Milestones**:
  - Add standard library functions to `ryush` (piping, redirections).
  - Pre-configure an advanced dotfile setup (`.bashrc`, `.vimrc`) for the `user` profile.
  - Expand `sys-monitor` to show disk I/O and network telemetry.
  - Implement basic automated test suites (`tests/run-tests.sh`).

## Phase 3: Graphical Environment (Planned ⏳)
- **Goal**: Introduce an extremely lightweight GUI while maintaining the low-resource footprint.
- **Milestones**:
  - Integrate a minimal Wayland compositor (e.g., Sway or Labwc) or X11 WM (e.g., Openbox).
  - Create a custom C-based status bar and application launcher.
  - Ensure the entire GUI system operates within a 2GB RAM budget.

## Phase 4: AI Assistant Integration (Experimental 🧪)
- **Goal**: Introduce local, terminal-based AI tooling for systems administration.
- **Milestones**:
  - Provide a lightweight CLI tool to interact with cloud LLMs (via API) directly from `ryush`.
  - Explore compiling small, highly quantized local models (e.g., Llama 3 8B) for native execution if hardware allows.

---

## Long-term Vision & Priorities
1. **Maintainability**: Ensure code remains readable, heavily documented, and standard.
2. **Minimalism**: Avoid feature creep. Every package added to the ISO must justify its size.
3. **Reproducibility**: Ensure anyone can clone the repo and compile the exact same ISO with a single `make iso` command.
