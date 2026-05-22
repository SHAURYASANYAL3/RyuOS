---

name: RyuOS Development Guide
description: Project architecture, workflow, tooling, and Claude Code integration for RyuOS
metadata:
type: reference
---------------

# RyuOS Development Documentation (CLAUDE.md)

## Project Overview

RyuOS is a custom Linux-based operating system project focused on learning low-level systems engineering, Linux customization, ISO generation, virtualization workflows, and developer tooling integration.

The project aims to evolve from a lightweight custom live Linux environment into a fully customized developer-focused distribution with future support for:

* AI-assisted development workflows
* Custom shell utilities
* Lightweight desktop environments
* Security and performance tooling
* Automated ISO generation
* Advanced Linux customization

The project is designed as both:

1. A long-term systems programming learning journey
2. A resume-quality operating system engineering portfolio project

---

# Core Objectives

## Current Goals

* Build a bootable custom Linux ISO
* Create a lightweight developer environment
* Learn Linux internals and system architecture
* Automate ISO generation and testing workflows
* Build reproducible development pipelines

## Future Goals

* Custom package management utilities
* AI-powered development tooling
* Custom shell environment
* Lightweight desktop interface
* Performance optimization
* Security-focused tooling
* Kernel customization experiments

---

# Repository Structure

```text
RyuOS/
├── scripts/                # Build, cleanup, and automation scripts
├── config/                 # live-build configuration files
├── hooks/                  # Custom live-build hooks
├── packages/               # Additional package lists
├── overlays/               # Files copied directly into ISO
├── branding/               # Wallpapers, logos, themes, boot assets
├── kernel/                 # Kernel experiments and patches
├── tools/                  # Custom CLI utilities and helper programs
├── docs/                   # Documentation and development notes
├── tests/                  # Verification and testing scripts
├── iso/                    # Generated ISO output
├── build/                  # Temporary build artifacts
└── CLAUDE.md               # Project guidance and workflow documentation
```

---

# Development Environment

## Recommended Host Setup

* Windows 11 + WSL2
* Ubuntu 24.04 LTS inside WSL2
* QEMU or VirtualBox for testing
* VS Code for editing
* Git + GitHub for version control

## Recommended Storage Layout

```text
D:\
├── RyuOS\
├── WSL\
├── VM\
├── ISO\
└── Backups\
```

Avoid storing large VM images and ISO artifacts on the system drive whenever possible. Modern operating systems consume storage with the enthusiasm of black holes.

---

# Required Dependencies

Install all required build tools:

```bash
sudo apt update && sudo apt upgrade -y

sudo apt install \
debootstrap \
live-build \
xorriso \
squashfs-tools \
grub-pc-bin \
grub-efi-amd64-bin \
mtools \
qemu-system-x86 \
build-essential \
git \
curl \
wget \
make \
nasm \
python3 \
python3-pip -y
```

---

# Build Workflow

## 1. Initialize Build Environment

```bash
scripts/setup-build-env.sh
```

This prepares:

* live-build configuration
* package repositories
* overlays
* build directories

---

## 2. Build ISO

```bash
scripts/build-iso.sh
```

Generated ISOs are stored inside:

```text
iso/
```

---

## 3. Test Using QEMU

```bash
scripts/qemu-test.sh iso/ryuos.iso
```

Testing inside virtual machines prevents accidental damage to the host system. Bare-metal experimentation before validation is an ancient ritual usually followed by regret.

---

## 4. Cleanup Before Rebuilds

```bash
scripts/cleanup.sh
```

Always clean previous artifacts before rebuilding.

---

# Claude Code Integration

## Purpose

Claude Code is used as:

* development assistant
* systems programming mentor
* debugging helper
* architecture reviewer
* documentation assistant

The project intentionally combines human learning with AI-assisted engineering workflows.

---

# Claude Configuration

Project-specific settings:

```text
.claude/settings.json
```

May include:

* permission handling
* hooks
* command presets
* keybindings
* workflow automation

---

# Claude Memory Usage

Persistent memories are stored under:

```text
~/.claude/projects/<project-name>/memory/
```

Use memories for:

* architecture decisions
* recurring workflows
* debugging notes
* roadmap tracking

Do not store secrets, credentials, or tokens.

Humanity keeps inventing new ways to leak API keys. RyuOS does not need to contribute to that tradition.

---

# Recommended AI Workflow

## Preferred Workflow

```text
Understand concept
↓
Generate minimal implementation
↓
Review generated code
↓
Test in VM
↓
Debug failures
↓
Document findings
↓
Commit changes
```

Avoid generating large unreviewed codebases blindly.

---

# Development Conventions

## Code Style

* Keep implementations modular
* Prefer readability over premature optimization
* Document low-level logic clearly
* Maintain consistent naming conventions

## Git Workflow

Recommended commit style:

```text
feat: add ISO build automation
fix: resolve bootloader path issue
docs: update setup instructions
refactor: simplify package installation logic
```

Commits should explain *why* changes exist, not only *what* changed.

---

# Verification & Testing

## Validation Checklist

* ISO boots successfully
* Shell launches correctly
* Networking functions
* Overlay files copy correctly
* No missing dependencies
* Build scripts are reproducible

## Testing Tools

* QEMU
* VirtualBox
* Shell scripts
* Manual verification

---

# Security Practices

## Never Commit

* API keys
* Tokens
* Passwords
* SSH private keys
* `.env` secrets

## Verify Downloads

Whenever possible:

* use checksums
* validate signatures
* use official repositories

The internet is full of malware pretending to be productivity software. A deeply inspirational ecosystem.

---

# Long-Term Roadmap

## Phase 1

* Build reproducible live ISO
* Add branding and customization
* Configure lightweight desktop environment

## Phase 2

* Create custom shell utilities
* Add developer tooling
* Integrate AI-assisted workflows

## Phase 3

* Package management customization
* Performance tuning
* Security tooling

## Phase 4

* Kernel experimentation
* Custom modules
* Advanced Linux internals

---

# Recommended Learning Topics

* Linux internals
* Boot process
* Process management
* Memory management
* Bash scripting
* Makefiles
* Virtualization
* Filesystems
* Networking basics
* Kernel architecture

---

# Philosophy

RyuOS is not intended to compete with mainstream operating systems.

The project exists to:

* learn systems engineering deeply
* experiment freely
* build practical low-level development experience
* create a public engineering portfolio

Every operating system begins with:

* one terminal
* one broken build
* and one developer wondering why the bootloader exploded again.

That is normal.
