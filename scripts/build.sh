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

# Copy rootfs overlay
echo "Preparing rootfs overlay..."
if [ -d "rootfs_overlay" ]; then
    cp -r rootfs_overlay/* "$OUTPUT_DIR/target/" 2>/dev/null || true
fi

# Copy boot files
echo "Preparing boot configuration..."
if [ -d "boot" ]; then
    mkdir -p "$OUTPUT_DIR/images/boot"
    cp boot/* "$OUTPUT_DIR/images/boot/" 2>/dev/null || true
fi

# Start build
echo ""
echo "Starting build process..."
echo "This may take a while (30 minutes to 2 hours depending on your system)..."
echo ""

# Build with Buildroot
make -C "$BUILDROOT_DIR" O="$PWD/$OUTPUT_DIR" all

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
