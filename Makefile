################################################################################
# Raspberry Pi KAS Build System
# Version: 1.0.0
# Last Updated: 2024
#
# Purpose: Automated build system for Raspberry Pi images using kas
# Dependencies: kas, make, bash
################################################################################

# Enable parallel builds
MAKEFLAGS += --jobs

# Tool definitions with version checks
KAS ?= kas
KAS_VERSION := $(shell $(KAS) --version 2>/dev/null)
KAS_DIR = kas
KAS_OPTS ?=
BUILD_TIME := $(shell date +%Y%m%d-%H%M%S)
LOG_DIR = logs

# Add after tool definitions
SDK_DIR = sdk
SDK_OPTS ?=
IMAGE_DIR = images
IMAGE_OPTS ?=
IMAGE_BUILD_DIR = build/tmp/deploy/images
SDK_BUILD_DIR = build/tmp/deploy/sdk

# Add new directories and tools
DOCKER_DIR = sdk-docker
VERIFY_DIR = verify
EXTRACT_DIR = extract
SHA256SUM = sha256sum
BZCAT = bzcat

# Check if kas is installed
ifeq ($(shell which $(KAS) 2>/dev/null),)
$(error "$(KAS) not found. Please install kas first")
endif

# Create log directory
$(shell mkdir -p $(LOG_DIR))

# Define board variants
BOARDS := raspberrypi0-2w-64 raspberrypi2 raspberrypi4 raspberrypi-armv7 raspberrypi-cm3 \
		  raspberrypi raspberrypi0 raspberrypi3 raspberrypi5 raspberrypi-armv8 raspberrypi-cm

# Generate targets dynamically with logging
define generate_board_targets
build-$(1): check-deps
	@echo "Starting build for $(1) at $$(date)"
	@mkdir -p $(LOG_DIR)/$(1)
	@mkdir -p $(IMAGE_DIR)/$(1)
	$(KAS) build $(KAS_DIR)/kas-$(1).yaml $(KAS_OPTS) 2>&1 | tee $(LOG_DIR)/$(1)/build-$(BUILD_TIME).log
	@echo "Build completed for $(1) at $$(date)"

shell-$(1): check-deps
	@echo "Opening shell for $(1)"
	$(KAS) shell $(KAS_DIR)/kas-$(1).yaml $(KAS_OPTS)
endef

# Add after board variants definition
# Generate SDK targets dynamically with logging

define generate_sdk_targets
sdk-$(1): check-deps build-$(1)
	@echo "Generating SDK for $(1) at $$(date)"
	@mkdir -p $(LOG_DIR)/$(1) $(SDK_DIR)/$(1)
	$(KAS) build $(KAS_DIR)/kas-$(1).yaml $(KAS_OPTS) -c populate_sdk  2>&1 | tee $(LOG_DIR)/$(1)/sdk-$(BUILD_TIME).log
	@echo "SDK generation completed for $(1) at $$(date)"

sdk-shell-$(1): check-deps
	@echo "Opening SDK shell for $(1)"
	$(KAS) shell $(KAS_DIR)/kas-$(1).yaml $(KAS_OPTS) -c populate_sdk 
endef

define copy_sdk_targets
copy-sdk-$(1): check-deps sdk-$(1)
	@echo "Copying SDK for $(1) at $$(date)"
	@mkdir -p $(LOG_DIR)/$(1)
	@mkdir -p $(SDK_DIR)/$(1)
	@echo "Copying SDK files for $(1)..."
	@if ! find -L "$(SDK_BUILD_DIR)/" -name "*$(1)-toolchain*.sh" -type f -exec cp --preserve=all {} "$(SDK_DIR)/$(1)/" \; 2>&1 | tee "$(LOG_DIR)/$(1)/copy-$(BUILD_TIME).log"; then \
		echo "Error copying files"; \
		exit 1; \
	fi
	@echo "SDK copy completed for $(1) at $$(date)"
endef

define copy_images_targets
copy-images-$(1): check-deps
	@echo "Copying images for $(1) at $$(date)"
	@mkdir -p $(LOG_DIR)/$(1)
	@mkdir -p $(IMAGE_DIR)/$(1)
	@echo "Copying image files for $(1)..."
	@if ! find -L "$(IMAGE_BUILD_DIR)/$(1)" -name "*.rootfs.wic.bz2" -type f -exec cp  {} "$(IMAGE_DIR)/$(1)/" \; 2>&1 | tee "$(LOG_DIR)/$(1)/copy-$(BUILD_TIME).log"; then \
		echo "Error copying files"; \
		exit 1; \
	fi
	@echo "Image copy completed for $(1) at $$(date)"
endef



# Add new target definitions
define generate_verify_targets
verify-$(1): copy-images-$(1)
	@echo "Verifying images for $(1) at $$(date)"
	@mkdir -p $(VERIFY_DIR)/$(1)
	@cd $(IMAGE_DIR)/$(1) && \
	for img in *.wic.bz2; do \
		$(SHA256SUM) $$img > $(VERIFY_DIR)/$(1)/$$img.sha256; \
	done
	@echo "Verification completed for $(1)"
endef

define generate_extract_targets
extract-$(1): verify-$(1)
	@echo "Extracting images for $(1) at $$(date)"
	@mkdir -p $(EXTRACT_DIR)/$(1)
	@cd $(IMAGE_DIR)/$(1) && \
	for img in *.wic.bz2; do \
		echo "Extracting $$img..."; \
		$(BZCAT) $$img > $(EXTRACT_DIR)/$(1)/$${img%.bz2} || exit 1; \
	done
	@echo "Extraction completed for $(1)"
endef

define generate_docker_targets
docker-$(1): copy-sdk-$(1) 
	@echo "Building Docker image for $(1) at $$(date)"
	@mkdir -p $(DOCKER_DIR)
	@cp $(SDK_DIR)/$(1)/*-toolchain*.sh $(DOCKER_DIR)/sdk.sh
	@docker build -t $(1)-app-builder $(DOCKER_DIR)
endef

$(foreach board,$(BOARDS),$(eval $(call generate_board_targets,$(board))))
$(foreach board,$(BOARDS),$(eval $(call generate_sdk_targets,$(board))))
$(foreach board,$(BOARDS),$(eval $(call copy_sdk_targets,$(board))))
$(foreach board,$(BOARDS),$(eval $(call copy_images_targets,$(board))))
$(foreach board,$(BOARDS),$(eval $(call generate_verify_targets,$(board))))
$(foreach board,$(BOARDS),$(eval $(call generate_extract_targets,$(board))))
$(foreach board,$(BOARDS),$(eval $(call generate_docker_targets,$(board))))

# Main targets
.DEFAULT_GOAL := help

build-all: check-deps $(addprefix build-,$(BOARDS))
	@echo "=== All board builds completed at $$(date) ==="

copy-all-images: check-deps $(addprefix copy-images-,$(BOARDS))
	@echo "=== All images copied at $$(date) ==="

copy-all-sdks: check-deps $(addprefix copy-sdk-,$(BOARDS))
	@echo "=== All SDKs copied at $$(date) ==="

sdk-all: check-deps
	@echo "=== Starting SDK generation for all boards at $(BUILD_TIME) ==="
	@mkdir -p $(SDK_DIR)
	@for board in $(BOARDS); do \
		echo "--- Building SDK for $$board ---"; \
		mkdir -p $(LOG_DIR)/$$board $(SDK_DIR)/$$board; \
		if ! $(MAKE) sdk-$$board; then \
			echo "ERROR: SDK build failed for $$board"; \
			exit 1; \
		fi; \
	done
	@echo "=== SDK generation completed for all boards at $$(date) ==="

verify-all: $(addprefix verify-,$(BOARDS))
	@echo "=== All image verifications completed ==="

extract-all: $(addprefix extract-,$(BOARDS))
	@echo "=== All image extractions completed ==="

docker-all: $(addprefix docker-,$(BOARDS))
	@echo "=== All Docker images built ==="

clean:
	rm -rf build tmp
	rm -rf $(LOG_DIR)
	rm -rf $(SDK_DIR)
	rm -rf $(VERIFY_DIR)
	rm -rf $(EXTRACT_DIR)
	rm -rf $(IMAGE_DIR)

check-deps:
	@echo "Checking dependencies..."
	@echo "KAS version: $(KAS_VERSION)"
	@if [ ! -d "$(KAS_DIR)" ]; then echo "Error: $(KAS_DIR) directory not found"; exit 1; fi

debug:
	@echo "Build System Information:"
	@echo "KAS: $(KAS)"
	@echo "KAS Version: $(KAS_VERSION)"
	@echo "KAS Directory: $(KAS_DIR)"
	@echo "Make Flags: $(MAKEFLAGS)"
	@echo "Build Time: $(BUILD_TIME)"

# Update .PHONY
.PHONY: build-all clean check-deps debug info copy-all-images copy-all-sdks \
	verify-all extract-all docker-all \
	$(foreach board,$(BOARDS),build-$(board) shell-$(board) sdk-$(board) sdk-shell-$(board) \
	copy-images-$(board) copy-sdk-$(board) verify-$(board) extract-$(board) docker-$(board))

help:
	@echo "╔════════════════════════════════════════════════════════════════╗"
	@echo "║                 Raspberry Pi KAS Build System                   ║"
	@echo "║                      Version: 1.0.1                            ║"
	@echo "╚════════════════════════════════════════════════════════════════╝"
	@echo
	@echo "Usage: make [target] [KAS_OPTS='<options>']"
	@echo
	@echo "Main targets:"
	@echo "  build-<board>     - Build specific board image"
	@echo "  shell-<board>     - Open shell for specific board"
	@echo "  build-all        - Build all board images"
	@echo "  copy-images-<board> - Copy images for specific board"
	@echo "  copy-sdk-<board>   - Copy SDK for specific board"
	@echo "  copy-all-images   - Copy all board images"
	@echo "  copy-all-sdks     - Copy all board SDKs"
	@echo "  clean            - Remove build artifacts and logs"
	@echo "  debug            - Show build system information"
	@echo "  info             - Display detailed system information"
	@echo
	@echo "SDK targets:"
	@echo "  sdk-<board>      - Generate SDK for specific board"
	@echo "  sdk-shell-<board> - Open SDK shell for specific board"
	@echo "  sdk-all         - Generate SDKs for all boards"
	@echo
	@echo "Docker targets:"
	@echo "  docker-<board>    - Build Docker image with SDK for specific board"
	@echo "  docker-all       - Build Docker images for all boards"
	@echo
	@echo "Verification targets:"
	@echo "  verify-<board>   - Generate checksums for specific board images"
	@echo "  verify-all      - Generate checksums for all board images"
	@echo
	@echo "Extraction targets:"
	@echo "  extract-<board>  - Extract compressed images for specific board"
	@echo "  extract-all     - Extract compressed images for all boards"
	@echo
	@echo "Available boards:"
	@for board in $(BOARDS); do \
		printf "  %-15s%s\n" "$$board" "- Build for $$board"; \
	done
	@echo
	@echo "Directories:"
	@echo "  Build logs:      $(LOG_DIR)/<board>/build-$(BUILD_TIME).log"
	@echo "  SDK output:      $(SDK_DIR)/<board>"
	@echo "  Images:          $(IMAGE_DIR)/<board>"
	@echo
	@echo "Examples:"
	@echo "  make build-raspberrypi4              # Build RPi 4 image"
	@echo "  make sdk-raspberrypi4               # Generate RPi 4 SDK"
	@echo "  make info                           # Show system information"
	@echo "  make build-all                      # Build all images"

info:
	@echo "=== System Information ==="
	@echo "Host System:"
	@echo "  OS:           $$(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')"
	@echo "  Kernel:       $$(uname -r)"
	@echo "  Architecture: $$(uname -m)"
	@echo "  Hostname:     $$(hostname)"
	@echo
	@echo "Hardware Information:"
	@echo "  CPU Model:    $$(grep "model name" /proc/cpuinfo | head -n1 | cut -d: -f2 | sed 's/^[ \t]*//')"
	@echo "  CPU Cores:    $$(nproc)"
	@echo "  CPU MHz:      $$(grep "cpu MHz" /proc/cpuinfo | head -n1 | cut -d: -f2 | sed 's/^[ \t]*//')"
	@echo "  Total Memory: $$(free -h | awk '/^Mem:/ {print $$2}')"
	@echo "  Free Memory:  $$(free -h | awk '/^Mem:/ {print $$4}')"
	@echo "  Swap Total:   $$(free -h | awk '/^Swap:/ {print $$2}')"
	@echo "  Swap Free:    $$(free -h | awk '/^Swap:/ {print $$4}')"
	@echo
	@echo "Build Environment:"
	@echo "  Make:        $$(make --version | head -n1)"
	@echo "  GCC:         $$(gcc --version 2>/dev/null | head -n1 || echo 'Not found')"
	@echo "  KAS:         $(KAS_VERSION)"
	@echo "  Python:      $$(python3 --version 2>/dev/null || echo 'Not found')"
	@echo "  Git:         $$(git --version 2>/dev/null || echo 'Not found')"
	@echo "  Docker:      $$(docker --version 2>/dev/null || echo 'Not found')"
	@echo "  Podman:      $$(podman --version 2>/dev/null || echo 'Not found')"
	@echo "  QEMU:        $$(qemu-system-aarch64 --version 2>/dev/null | head -n1 || echo 'Not found')"
	@echo
	@echo "Network Information:"
	@echo "  IP Address:   $$(hostname -I | awk '{print $$1}')"
	@echo "  DNS Servers:  $$(cat /etc/resolv.conf | grep nameserver | awk '{print $$2}' | tr '\n' ' ')"
	@echo
	@echo "Build Configuration:"
	@echo "  KAS_DIR:     $(KAS_DIR)"
	@echo "  LOG_DIR:     $(LOG_DIR)"
	@echo "  SDK_DIR:     $(SDK_DIR)"
	@echo "  IMAGE_DIR:   $(IMAGE_DIR)"
	@echo
	@echo "Available Boards:"
	@echo "  Total:       $$(echo $(BOARDS) | wc -w)"
	@for board in $(BOARDS); do \
		echo "  - $$board"; \
	done
	@echo
	@echo "Storage Information:"
	@echo "  Mount Point: $$(df -h . | awk 'NR==2 {print $$6}')"
	@echo "  Filesystem:  $$(df -Th . | awk 'NR==2 {print $$2}')"
	@echo "  Total Space: $$(df -h . | awk 'NR==2 {print $$2}')"
	@echo "  Used Space:  $$(df -h . | awk 'NR==2 {print $$3}')"
	@echo "  Free Space:  $$(df -h . | awk 'NR==2 {print $$4}')"
	@echo "  Use%:        $$(df -h . | awk 'NR==2 {print $$5}')"
	@echo
	@echo "System Load:"
	@echo "  Load Average: $$(uptime | awk -F'load average:' '{print $$2}')"
	@echo "  Uptime:       $$(uptime -p)"