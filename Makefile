# Tool definitions
KAS ?= kas
KAS_DIR = kas
KAS_OPTS ?=

# Check if kas is installed
ifeq ($(shell which $(KAS) 2>/dev/null),)
$(error "$(KAS) not found. Please install kas first")
endif

# Define board variants
BOARDS := raspberrypi0-2w-64 raspberrypi2 raspberrypi4 raspberrypi-armv7 raspberrypi-cm3 \
		  raspberrypi raspberrypi0 raspberrypi3 raspberrypi5 raspberrypi-armv8 raspberrypi-cm

# Generate targets dynamically
define generate_board_targets
build-$(1):
	$(KAS) build $(KAS_DIR)/kas-$(1).yaml $(KAS_OPTS)

shell-$(1):
	$(KAS) shell $(KAS_DIR)/kas-$(1).yaml $(KAS_OPTS)
endef

$(foreach board,$(BOARDS),$(eval $(call generate_board_targets,$(board))))

build-all: $(addprefix build-,$(BOARDS))

clean:
	rm -rf build tmp

.DEFAULT_GOAL := help

.PHONY: build-all clean $(foreach board,$(BOARDS),build-$(board) shell-$(board))

help:
	@echo "Usage: make [target] [KAS_OPTS='<options>']"
	@echo "Targets:"
	@echo "  build-<board>  - Build specific board (see list below)"
	@echo "  shell-<board>  - Open shell for specific board"
	@echo "  build-all      - Build all boards"
	@echo "  clean          - Reset kas build output"
	@echo ""
	@echo "Available boards:"
	@for board in $(BOARDS); do echo "  $$board"; done