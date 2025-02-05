# Build settings
KAS := kas
KAS_OPTS ?=
PARALLEL_JOBS ?= $(shell nproc)
BUILD_TIMESTAMP := $(shell date '+%Y%m%d_%H%M%S')
VERSION := 1.0.0

# Logging
LOG_DIR := logs
$(shell mkdir -p $(LOG_DIR))

# Yocto kas build settings
KAS := kas
KAS_OPTS ?=

# Define available kas configuration files
KAS_CONFIGS = kas/kas-raspberrypi0-2w-64.yaml kas/kas-raspberrypi2.yaml kas/kas-raspberrypi4.yaml kas/kas-raspberrypi-armv7.yaml kas/kas-raspberrypi-cm3.yaml kas/kas-raspberrypi.yaml kas/kas-raspberrypi0.yaml kas/kas-raspberrypi3.yaml kas/kas-raspberrypi5.yaml kas/kas-raspberrypi-armv8.yaml kas/kas-raspberrypi-cm.yaml

# Set default configuration, can be overridden via CFG variable
ifeq ($(CFG),)
	KAS_CONF := kas/kas-raspberrypi.yaml
else
	KAS_CONF := $(CFG)
endif

# Validate configuration: warns if chosen CFG is not in KAS_CONFIGS
validate-config:
	@echo "Validating configuration: $(KAS_CONF)"
	@if echo "$(KAS_CONFIGS)" | grep -q -w "$(KAS_CONF)"; then \
		echo "Configuration valid."; \
	else \
		echo "Warning: $(KAS_CONF) is not among the allowed configurations."; \
	fi

# Default target: show help then build
all: help build 

build: validate-config
	@echo "$(BLUE)Starting build with configuration: $(KAS_CONF)$(NC)"
	@echo "$(YELLOW)Build started at: $$(date)$(NC)"
	@echo "$(YELLOW)Using $(PARALLEL_JOBS) parallel jobs$(NC)"
	$(KAS) build $(KAS_CONF) $(KAS_OPTS)  --parallel-jobs=$(PARALLEL_JOBS) 2>&1 | tee $(LOG_DIR)/build_$(BUILD_TIMESTAMP).log
	@echo "$(GREEN)Build completed at: $$(date)$(NC)"

shell: validate-config
	@echo "$(BLUE)Opening shell with configuration: $(KAS_CONF)$(NC)"
	$(KAS) shell $(KAS_CONF) $(KAS_OPTS) 

# Enhanced status reporting
status:
	@echo "$(BLUE)Build System Status:$(NC)"
	@echo "$(YELLOW)Version: $(VERSION)$(NC)"
	@echo "$(YELLOW)Available configurations: $(words $(KAS_CONFIGS))$(NC)"
	@echo "$(YELLOW)Current configuration: $(KAS_CONF)$(NC)"
	@echo "$(YELLOW)Parallel jobs: $(PARALLEL_JOBS)$(NC)"
	@echo "$(YELLOW)Build logs: $(LOG_DIR)$(NC)"

menu:
	@echo "$(BLUE)╔════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║           Build System Menu            ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════╝$(NC)"
	@echo "$(YELLOW)Available targets:$(NC)"
	@echo "1. make build - Build with current configuration"
	@echo "2. make shell - Open shell with current configuration"
	@echo "3. make status - Show build system status"
	@echo "4. make clean - Clean build artifacts"
	@echo "5. make list-configs - List available configurations"
	@echo "$(YELLOW)Individual board targets:$(NC)"
	@echo "$(GREEN)Build targets:$(NC)"
	@$(foreach conf,$(KAS_CONFIGS),echo "  make build-$(basename $(notdir $(conf:kas-%.yaml=%)))";)
	@echo "$(GREEN)Shell targets:$(NC)"
	@$(foreach conf,$(KAS_CONFIGS),echo "  make shell-$(basename $(notdir $(conf:kas-%.yaml=%)))";)

# Enhanced clean target
clean:
	@echo "$(RED)Cleaning build artifacts...$(NC)"
	$(KAS) reset
	@echo "$(RED)Cleaning logs...$(NC)"
	rm -rf $(LOG_DIR)/*
	@echo "$(GREEN)Clean completed$(NC)"

info:
	@echo "Using configuration: $(KAS_CONF)"
	@echo "Additional kas options: $(KAS_OPTS)"

help:
	@echo "Usage: make [target] [CFG=<config_file>] [KAS_OPTS='<options>']"
	@echo "Targets:"
	@echo "  all            - Show help and build"
	@echo "  build          - Build using kas with the given configuration"
	@echo "  clean          - Reset kas build output"
	@echo "  list-configs   - List available kas configuration files"
	@echo "  info           - Show current configuration and options"
	@echo "  validate-config- Check if selected configuration is allowed"

list-configs:
	@echo "Available kas configuration files:"
	@echo $(KAS_CONFIGS)

build-raspberrypi0-2w-64:
	$(KAS) build kas/kas-raspberrypi0-2w-64.yaml $(KAS_OPTS) 

shell-raspberrypi0-2w-64:
	$(KAS) shell kas/kas-raspberrypi0-2w-64.yaml $(KAS_OPTS) 

build-raspberrypi2:
	$(KAS) build kas/kas-raspberrypi2.yaml $(KAS_OPTS) 

shell-raspberrypi2:
	$(KAS) shell kas/kas-raspberrypi2.yaml $(KAS_OPTS) 

build-raspberrypi4:
	$(KAS) build kas/kas-raspberrypi4.yaml $(KAS_OPTS) 

shell-raspberrypi4:
	$(KAS) shell kas/kas-raspberrypi4.yaml $(KAS_OPTS) 

build-raspberrypi-armv7:
	$(KAS) build kas/kas-raspberrypi-armv7.yaml $(KAS_OPTS) 

shell-raspberrypi-armv7:
	$(KAS) shell kas/kas-raspberrypi-armv7.yaml $(KAS_OPTS) 

build-raspberrypi-cm3:
	$(KAS) build kas/kas-raspberrypi-cm3.yaml $(KAS_OPTS) 

shell-raspberrypi-cm3:
	$(KAS) shell kas/kas-raspberrypi-cm3.yaml $(KAS_OPTS) 

build-raspberrypi:
	$(KAS) build kas/kas-raspberrypi.yaml $(KAS_OPTS) 

shell-raspberrypi:
	$(KAS) shell kas/kas-raspberrypi.yaml $(KAS_OPTS) 

build-raspberrypi0:
	$(KAS) build kas/kas-raspberrypi0.yaml $(KAS_OPTS) 

shell-raspberrypi0:
	$(KAS) shell kas/kas-raspberrypi0.yaml $(KAS_OPTS) 

build-raspberrypi3:
	$(KAS) build kas/kas-raspberrypi3.yaml $(KAS_OPTS) 

shell-raspberrypi3:
	$(KAS) shell kas/kas-raspberrypi3.yaml $(KAS_OPTS) 

build-raspberrypi5:
	$(KAS) build kas/kas-raspberrypi5.yaml $(KAS_OPTS) 

shell-raspberrypi5:
	$(KAS) shell kas/kas-raspberrypi5.yaml $(KAS_OPTS) 

build-raspberrypi-armv8:
	$(KAS) build kas/kas-raspberrypi-armv8.yaml $(KAS_OPTS) 

shell-raspberrypi-armv8:
	$(KAS) shell kas/kas-raspberrypi-armv8.yaml $(KAS_OPTS) 

build-raspberrypi-cm:
	$(KAS) build kas/kas-raspberrypi-cm.yaml $(KAS_OPTS) 

shell-raspberrypi-cm:
	$(KAS) shell kas/kas-raspberrypi-cm.yaml $(KAS_OPTS) 

.PHONY: all build clean info help list-configs validate-config status menu $(foreach conf,$(KAS_CONFIGS),build-$(basename $(notdir $(conf:kas-%.yaml=%))) shell-$(basename $(notdir $(conf:kas-%.yaml=%))))
