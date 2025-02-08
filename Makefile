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
	$(KAS) build $(KAS_DIR)/kas-$(1).yaml $(KAS_OPTS) 2>&1 | tee $(LOG_DIR)/$(1)/build-$(BUILD_TIME).log
	@echo "Build completed for $(1) at $$(date)"

shell-$(1): check-deps
	@echo "Opening shell for $(1)"
	$(KAS) shell $(KAS_DIR)/kas-$(1).yaml $(KAS_OPTS)
endef


# Add after board variants definition
# Generate SDK targets dynamically with logging
define generate_sdk_targets
sdk-$(1): check-deps
	@echo "Generating SDK for $(1) at $$(date)"
	@mkdir -p $(LOG_DIR)/$(1) $(SDK_DIR)/$(1)
	$(KAS) build $(KAS_DIR)/kas-$(1).yaml $(KAS_OPTS) -c 'bitbake -c populate_sdk core-image-minimal' 2>&1 | tee $(LOG_DIR)/$(1)/sdk-$(BUILD_TIME).log
	@echo "SDK generation completed for $(1) at $$(date)"

sdk-shell-$(1): check-deps
	@echo "Opening SDK shell for $(1)"
	$(KAS) shell $(KAS_DIR)/kas-$(1).yaml $(KAS_OPTS) -c 'bitbake -c populate_sdk core-image-minimal'
endef


$(foreach board,$(BOARDS),$(eval $(call generate_board_targets,$(board))))

$(foreach board,$(BOARDS),$(eval $(call generate_sdk_targets,$(board))))

# Main targets
.DEFAULT_GOAL := help

build-all: check-deps $(addprefix build-,$(BOARDS))
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

clean:
	rm -rf build tmp
	rm -rf $(LOG_DIR)
	rm -rf $(LOG_DIR)
	rm -rf $(SDK_DIR)

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

# Add to .PHONY
.PHONY: build-all clean check-deps debug \
	$(foreach board,$(BOARDS),build-$(board) shell-$(board) sdk-$(board) sdk-shell-$(board))

help:
	@echo "Raspberry Pi KAS Build System"
	@echo "Version: 1.0.0"
	@echo ""
	@echo "Usage: make [target] [KAS_OPTS='<options>']"
	@echo ""
	@echo "Main targets:"
	@echo "  build-<board>  - Build specific board image"
	@echo "  shell-<board>  - Open shell for specific board"
	@echo "  build-all      - Build all board images"
	@echo "  clean          - Remove build artifacts and logs"
	@echo "  debug          - Show build system information"
	@echo ""
	@echo "Available boards:"
	@for board in $(BOARDS); do echo "  $$board"; done
	@echo ""
	@echo "Build logs are stored in: $(LOG_DIR)/<board>/build-timestamp.log"
	@echo "  sdk-<board>    - Generate SDK for specific board"
	@echo "  sdk-shell-<board> - Open SDK shell for specific board"