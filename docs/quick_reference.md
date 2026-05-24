# RyuOS Quick Reference

## Build

```bash
make setup
make tools
make iso
```

Output:

```text
iso/ryuos-cli.iso
```

## Test

```bash
./scripts/qemu-test.sh iso/ryuos-cli.iso 1024 --vnc
./scripts/qemu-test.sh iso/ryuos-cli.iso 512 --text
```

Login:

```text
live / live
root / root
```

## Runtime Metrics

Run these inside the live VM:

```bash
systemd-analyze
systemd-analyze blame | head -20
free -h
ps -e --no-headers | wc -l
ryu-benchmark
sys-monitor
```

## Optimization Guardrails

Default profile rules:

- Keep `live-config` off the package list and boot command line.
- Keep `--apt-recommends false`.
- Keep the GUI stack Openbox + nodm + tint2 + LXTerminal + rofi.
- Avoid browser/file-manager stacks in the base image unless a measured use case justifies them.
- Do not enable compositors, portals, policykit, GVFS, or accessibility daemons by default.

## Common Files

```text
packages/ryuos.list                         Package list
config/live-build/auto/config               live-build profile
hooks/*.chroot                              Build-time tuning hooks
config/live-build/includes.chroot/etc/skel  Default user GUI/shell config
scripts/build-iso.sh                        Native ISO build entry point
scripts/qemu-test.sh                        QEMU smoke test entry point
tests/run-tests.sh                          Repo validation guardrails
```

## Common Fixes

```bash
# Clean root-owned live-build state
make clean

# Rebuild tools only
make tools

# Retry ISO build from scratch
make clean && make iso

# Reject a bad ISO quickly
test -s iso/ryuos-cli.iso && file iso/ryuos-cli.iso
```
