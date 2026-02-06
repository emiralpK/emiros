#!/bin/bash
# EmiROS SD Card Flash Script
# Flash EmiROS image to SD card

set -e

OUTPUT_DIR="output"
IMAGE="$OUTPUT_DIR/images/sdcard.img"

echo "================================"
echo "EmiROS SD Card Flash Utility"
echo "================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root"
    echo "Usage: sudo $0 /dev/sdX"
    exit 1
fi

# Check device argument
if [ -z "$1" ]; then
    echo "Error: No device specified"
    echo "Usage: sudo $0 /dev/sdX"
    echo ""
    echo "Available devices:"
    lsblk -d -o NAME,SIZE,TYPE | grep disk
    exit 1
fi

DEVICE="$1"

# Verify device exists
if [ ! -b "$DEVICE" ]; then
    echo "Error: Device $DEVICE does not exist"
    exit 1
fi

# Check if image exists
if [ ! -f "$IMAGE" ]; then
    echo "Error: Image not found at $IMAGE"
    echo "Please build the image first: make build"
    exit 1
fi

# Warning
echo "WARNING: This will erase ALL data on $DEVICE"
echo ""
lsblk "$DEVICE"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "Flashing image to $DEVICE..."
echo ""

# Unmount any mounted partitions
umount ${DEVICE}* 2>/dev/null || true

# Flash image
dd if="$IMAGE" of="$DEVICE" bs=4M status=progress conv=fsync

# Sync
sync

echo ""
echo "================================"
echo "Flash completed successfully!"
echo "================================"
echo ""
echo "You can now safely remove the SD card and insert it into your Raspberry Pi 5."
echo ""
