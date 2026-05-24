.PHONY: help setup tools iso docker-iso test clean lint

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
	@printf "  $(GREEN)make iso$(RESET)       - Build the RyuOS ISO natively (creates $(ISO_PATH))\n"
	@printf "  $(GREEN)make docker-iso$(RESET)- Build the ISO safely inside a privileged Docker container\n"
	@printf "  $(GREEN)make test$(RESET)      - Test the compiled ISO in QEMU (1GB RAM, VNC)\n"
	@printf "  $(GREEN)make lint$(RESET)      - Lint all shell scripts using shellcheck\n"
	@printf "  $(GREEN)make clean$(RESET)     - Clean build artifacts and ISO directory\n"

setup:
	@printf "$(YELLOW)[*] Setting up build environment...$(RESET)\n"
	@bash scripts/setup-build-env.sh

tools:
	@printf "$(YELLOW)[*] Building custom tools...$(RESET)\n"
	@$(MAKE) -C src

iso:
	@printf "$(YELLOW)[*] Building RyuOS ISO natively...$(RESET)\n"
	@bash scripts/build-iso.sh

docker-iso:
	@printf "$(YELLOW)[*] Building RyuOS ISO in Docker container...$(RESET)\n"
	@docker build -t ryuos-builder .
	@docker run --rm --privileged -v $(PWD):/project ryuos-builder /bin/bash -c "cd /project && make iso"

test:
	@printf "$(YELLOW)[*] Testing ISO in QEMU...$(RESET)\n"
	@bash scripts/qemu-test.sh $(ISO_PATH) 1024 --vnc

lint:
	@printf "$(YELLOW)[*] Linting scripts...$(RESET)\n"
	@shellcheck -e SC1091 scripts/*.sh tests/*.sh hooks/*.chroot 2>/dev/null || (echo "shellcheck failed or not installed. Run 'sudo apt install shellcheck'" && exit 1)
	@printf "$(GREEN)[+] Linting passed!$(RESET)\n"

clean:
	@printf "$(YELLOW)[*] Cleaning build artifacts...$(RESET)\n"
	@bash scripts/cleanup.sh

.DEFAULT_GOAL := help
