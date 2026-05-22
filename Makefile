.PHONY: help setup tools iso test clean lint

# Default variables
ISO_DIR := iso
ISO_NAME := ryuos-cli.iso
ISO_PATH := $(ISO_DIR)/$(ISO_NAME)

# ANSI Colors
CYAN := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RESET := \033[0m

help:
	@printf "$(CYAN)RyuOS Build System$(RESET)\n"
	@printf "Available targets:\n"
	@printf "  $(GREEN)make setup$(RESET)     - Setup build environment dependencies (requires root)\n"
	@printf "  $(GREEN)make tools$(RESET)     - Compile ryush and sys-monitor locally\n"
	@printf "  $(GREEN)make iso$(RESET)       - Build the RyuOS ISO (creates $(ISO_PATH))\n"
	@printf "  $(GREEN)make test$(RESET)      - Test the compiled ISO in QEMU (1GB RAM, VNC)\n"
	@printf "  $(GREEN)make lint$(RESET)      - Lint all shell scripts using shellcheck\n"
	@printf "  $(GREEN)make clean$(RESET)     - Clean build artifacts and ISO directory\n"

setup:
	@printf "$(YELLOW)[*] Setting up build environment...$(RESET)\n"
	@bash scripts/setup-build-env.sh

tools:
	@printf "$(YELLOW)[*] Building custom tools...$(RESET)\n"
	@bash scripts/build-tools.sh

iso:
	@printf "$(YELLOW)[*] Building RyuOS ISO...$(RESET)\n"
	@bash scripts/build-iso.sh

test:
	@printf "$(YELLOW)[*] Testing ISO in QEMU...$(RESET)\n"
	@bash scripts/qemu-test.sh $(ISO_PATH) 1024 --vnc

lint:
	@printf "$(YELLOW)[*] Linting scripts...$(RESET)\n"
	@shellcheck scripts/*.sh tests/*.sh 2>/dev/null || (echo "shellcheck failed or not installed. Run 'sudo apt install shellcheck'" && exit 1)
	@printf "$(GREEN)[+] Linting passed!$(RESET)\n"

clean:
	@printf "$(YELLOW)[*] Cleaning build artifacts...$(RESET)\n"
	@bash scripts/cleanup.sh

.DEFAULT_GOAL := help
