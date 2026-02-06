# EmiROS Makefile
# Build system for Raspberry Pi 5 Linux Distribution

BUILDROOT_VERSION ?= 2024.02
BUILDROOT_DIR ?= buildroot-$(BUILDROOT_VERSION)
BUILDROOT_URL ?= https://buildroot.org/downloads/buildroot-$(BUILDROOT_VERSION).tar.gz
CONFIG_FILE = configs/emiros_rpi5_defconfig
OUTPUT_DIR = output
IMAGE = $(OUTPUT_DIR)/images/sdcard.img

.PHONY: all download configure build clean distclean qemu flash help

all: build

help:
	@echo "EmiROS Build System"
	@echo "==================="
	@echo ""
	@echo "Available targets:"
	@echo "  download   - Download Buildroot"
	@echo "  configure  - Configure Buildroot with EmiROS config"
	@echo "  build      - Build EmiROS image"
	@echo "  clean      - Clean build artifacts"
	@echo "  distclean  - Remove everything including Buildroot"
	@echo "  qemu       - Run EmiROS in QEMU"
	@echo "  flash      - Flash image to SD card (requires DEVICE=/dev/sdX)"
	@echo "  help       - Show this help message"
	@echo ""
	@echo "Quick Start:"
	@echo "  make download configure build"
	@echo "  make qemu"

download:
	@echo "Downloading Buildroot $(BUILDROOT_VERSION)..."
	@if [ ! -d $(BUILDROOT_DIR) ]; then \
		wget -c $(BUILDROOT_URL) && \
		tar xf buildroot-$(BUILDROOT_VERSION).tar.gz && \
		rm buildroot-$(BUILDROOT_VERSION).tar.gz; \
	else \
		echo "Buildroot already downloaded"; \
	fi

configure: download
	@echo "Configuring Buildroot with EmiROS defconfig..."
	@cp $(CONFIG_FILE) $(BUILDROOT_DIR)/configs/
	@make -C $(BUILDROOT_DIR) O=$(PWD)/$(OUTPUT_DIR) emiros_rpi5_defconfig

build:
	@echo "Building EmiROS..."
	@./scripts/build.sh

clean:
	@echo "Cleaning build artifacts..."
	@if [ -d $(OUTPUT_DIR) ]; then \
		make -C $(BUILDROOT_DIR) O=$(PWD)/$(OUTPUT_DIR) clean; \
	fi

distclean:
	@echo "Removing all build artifacts and Buildroot..."
	@rm -rf $(OUTPUT_DIR) $(BUILDROOT_DIR)

qemu:
	@echo "Running EmiROS in QEMU..."
	@./scripts/run-qemu.sh

flash:
	@echo "Flashing EmiROS to SD card..."
	@if [ -z "$(DEVICE)" ]; then \
		echo "Error: DEVICE not specified. Usage: make flash DEVICE=/dev/sdX"; \
		exit 1; \
	fi
	@sudo ./scripts/flash-sd.sh $(DEVICE)
