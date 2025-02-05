# Tool and environment configuration
KAS ?= kas
BUILD_DIR = build
KAS_CONFIG = kas/rpi-kas.yml
DOCKER_IMAGE = crops/poky
DOCKER_RUN = docker run -it --rm -v $(PWD):/work -w /work
SD_CARD ?= /dev/mmcblk0

# Make all targets .PHONY
.PHONY: all setup build clean menuconfig shell docker-build flash validate docs test docker-shell

# Default target
all: validate build

# Environment setup
setup: check-deps
	cd /tmp && git clone https://github.com/siemens/kas.git
	cd /tmp/kas && sudo pip3 install .
	kas --version
	sudo apt install yamllint -y  || true

# Build targets
build: check-config
	$(KAS) build $(KAS_CONFIG)

docker-build:
	$(DOCKER_RUN) $(DOCKER_IMAGE) kas build $(KAS_CONFIG)

# Cleanup
clean:
	$(KAS) clean $(KAS_CONFIG)
	rm -rf $(BUILD_DIR)
	docker system prune -f

# Development tools
menuconfig:
	$(KAS) menu config $(KAS_CONFIG)

shell:
	$(KAS) shell $(KAS_CONFIG)

docker-shell:
	$(DOCKER_RUN) $(DOCKER_IMAGE) bash

# Image management
flash: build
	@read -p "Are you sure you want to flash $(SD_CARD)? [y/N] " answer; \
	if [ "$$answer" = "y" ]; then \
		sudo dd if=$(BUILD_DIR)/tmp/deploy/images/*/*.wic of=$(SD_CARD) bs=4M status=progress; \
	fi

# Validation
check-deps:
	@which docker >/dev/null || (echo "Docker not found" && exit 1)
	@which git >/dev/null || (echo "Git not found" && exit 1)
	@which $(KAS) >/dev/null || (echo "KAS not found" && exit 1)

check-config:
	@test -f $(KAS_CONFIG) || (echo "$(KAS_CONFIG) not found" && exit 1)

validate:
	yamllint $(KAS_CONFIG)
	shellcheck scripts/*.sh || true

# Documentation
docs:
	mkdir -p docs
	kas dump $(KAS_CONFIG) > docs/config.md

# Testing
test:
	pytest tests/

# Help
help:
	@echo "Available targets:"
	@echo "  setup         - Install dependencies"
	@echo "  build        - Build Yocto image locally"
	@echo "  docker-build - Build in Docker container"
	@echo "  clean        - Clean all artifacts"
	@echo "  menuconfig   - Configure kernel"
	@echo "  shell        - Enter development shell"
	@echo "  docker-shell - Enter Docker shell"
	@echo "  flash        - Flash image to SD card"
	@echo "  validate     - Run validation checks"
	@echo "  docs         - Generate documentation"
	@echo "  test         - Run tests"