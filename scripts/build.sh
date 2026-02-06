#!/bin/bash
# EmiROS Build Script
# Builds the complete EmiROS image for Raspberry Pi 5

set -e

BUILDROOT_VERSION="${BUILDROOT_VERSION:-2024.02}"
BUILDROOT_DIR="buildroot-${BUILDROOT_VERSION}"
OUTPUT_DIR="output"
CONFIG="emiros_rpi5_defconfig"

echo "================================"
echo "EmiROS Build Script"
echo "================================"
echo ""

# Check if buildroot exists
if [ ! -d "$BUILDROOT_DIR" ]; then
    echo "Error: Buildroot not found. Run 'make download' first."
    exit 1
fi

# Check if output directory is configured
if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Error: Build not configured. Run 'make configure' first."
    exit 1
fi

# Start build
echo ""
echo "Starting build process..."
echo "This may take a while (30 minutes to 2 hours depending on your system)..."
echo ""

# Get absolute path for OUTPUT_DIR
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_ABS="$PROJECT_DIR/$OUTPUT_DIR"

# Build with Buildroot using absolute path
make -C "$BUILDROOT_DIR" O="$OUTPUT_ABS" all

echo ""
echo "================================"
echo "Build completed successfully!"
echo "================================"
echo ""
echo "Output image: $OUTPUT_DIR/images/sdcard.img"
echo ""
echo "Next steps:"
echo "  - Test with QEMU: make qemu"
echo "  - Flash to SD card: make flash DEVICE=/dev/sdX"
echo ""
