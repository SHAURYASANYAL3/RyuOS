.PHONY: help setup tools build test clean docs

help:
	@echo "RyuOS Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  make setup     - Setup build environment"
	@echo "  make tools     - Compile ryush and sys-monitor"
	@echo "  make build     - Build ISO"
	@echo "  make test      - Test ISO in QEMU"
	@echo "  make docs      - Build documentation"
	@echo "  make clean     - Clean build artifacts"
	@echo ""

tools:
	@echo "[*] Building custom tools..."
	@bash scripts/build-tools.sh

setup:
	@echo "[*] Setting up build environment..."
	@bash scripts/setup-build-env.sh

build:
	@echo "[*] Building RyuOS ISO..."
	@bash scripts/build-iso.sh

test:
	@echo "[*] Testing ISO in QEMU..."
	@bash scripts/qemu-test.sh

docs:
	@echo "[*] Building documentation..."
	@echo "Docs are in markdown format in docs/"

clean:
	@echo "[*] Cleaning build artifacts..."
	@bash scripts/cleanup.sh

.DEFAULT_GOAL := help
