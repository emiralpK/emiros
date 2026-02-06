#!/bin/bash
# EmiROS QEMU Test Script
# Run EmiROS in QEMU for testing (aarch64)

set -e

OUTPUT_DIR="output"
IMAGE="$OUTPUT_DIR/images/sdcard.img"
KERNEL="$OUTPUT_DIR/images/Image"
DTB="$OUTPUT_DIR/images/bcm2712-rpi-5-b.dtb"

echo "================================"
echo "EmiROS QEMU Test Environment"
echo "================================"
echo ""

# Check if image exists
if [ ! -f "$IMAGE" ]; then
    echo "Error: Image not found at $IMAGE"
    echo "Please build the image first: make build"
    exit 1
fi

# QEMU parameters
QEMU_SYSTEM="qemu-system-aarch64"
MACHINE="raspi3b"  # Use raspi3b as closest available machine
MEMORY="1G"
CPU="cortex-a72"
SMP="4"

# Network configuration
NET_DEVICE="user,hostfwd=tcp::8080-:80"

# Graphics configuration
GRAPHICS="-device virtio-gpu-pci -display sdl,gl=on"
VNC_PORT=""

# Check for VNC mode
if [ "$1" == "--vnc" ]; then
    GRAPHICS="-vnc :0"
    VNC_PORT=":0 (port 5900)"
    echo "VNC mode enabled - connect to localhost:5900"
fi

echo "Configuration:"
echo "  Machine: $MACHINE"
echo "  Memory: $MEMORY"
echo "  CPU: $CPU (${SMP} cores)"
echo "  Image: $IMAGE"
echo "  Network: Port forwarding 8080 -> 80"
if [ -n "$VNC_PORT" ]; then
    echo "  Display: VNC $VNC_PORT"
else
    echo "  Display: SDL with OpenGL"
fi
echo ""
echo "Web Dashboard: http://localhost:8080"
echo "Press Ctrl+A then X to quit QEMU"
echo ""
echo "Starting QEMU..."
echo ""

# Check if QEMU is installed
if ! command -v $QEMU_SYSTEM &> /dev/null; then
    echo "Error: $QEMU_SYSTEM not found"
    echo "Please install QEMU: sudo apt-get install qemu-system-arm"
    exit 1
fi

# Run QEMU
$QEMU_SYSTEM \
    -M $MACHINE \
    -cpu $CPU \
    -smp $SMP \
    -m $MEMORY \
    -drive file=$IMAGE,format=raw,if=sd \
    -netdev $NET_DEVICE,id=net0 \
    -device virtio-net-pci,netdev=net0 \
    $GRAPHICS \
    -serial stdio \
    -no-reboot \
    || echo "QEMU exited"
