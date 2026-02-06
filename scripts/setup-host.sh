#!/bin/bash
# EmiROS Host Setup Script
# Sets up Raspberry Pi OS to host EmiROS via QEMU
# Run this on the Raspberry Pi 5 running PiOS

set -e

echo "================================"
echo "EmiROS Host Setup for PiOS"
echo "================================"
echo ""
echo "This script will configure your Raspberry Pi 5 (running PiOS)"
echo "to host EmiROS in QEMU with web access on emiralpkayikci.com"
echo ""

# Check if running on Raspberry Pi
if [ ! -f /proc/device-tree/model ]; then
    echo "Warning: This doesn't appear to be a Raspberry Pi"
fi

# Update system
echo "Updating system..."
sudo apt-get update

# Install QEMU
echo "Installing QEMU..."
sudo apt-get install -y qemu-system-arm qemu-system-aarch64 qemu-utils

# Create EmiROS directory
EMIROS_DIR="/opt/emiros"
echo "Creating EmiROS directory at $EMIROS_DIR..."
sudo mkdir -p "$EMIROS_DIR"

# Copy EmiROS image (assumes it's in current directory)
if [ -f "output/images/sdcard.img" ]; then
    echo "Copying EmiROS image..."
    sudo cp output/images/sdcard.img "$EMIROS_DIR/"
else
    echo "Warning: EmiROS image not found. You'll need to copy it manually."
fi

# Create QEMU launch script
echo "Creating QEMU launch script..."
cat > /tmp/start-emiros.sh << 'EOF'
#!/bin/bash
# EmiROS QEMU Launch Script for PiOS Host

IMAGE="/opt/emiros/sdcard.img"
QEMU="qemu-system-aarch64"

$QEMU \
    -M raspi3b \
    -cpu cortex-a72 \
    -smp 4 \
    -m 1G \
    -drive file=$IMAGE,format=raw,if=sd \
    -netdev user,id=net0,hostfwd=tcp::80-:80 \
    -device virtio-net-pci,netdev=net0 \
    -vnc :0 \
    -serial stdio \
    -daemonize \
    -pidfile /var/run/emiros-qemu.pid

echo "EmiROS started in QEMU"
echo "Web dashboard: http://localhost:80"
echo "VNC: localhost:5900"
EOF

sudo mv /tmp/start-emiros.sh "$EMIROS_DIR/start-emiros.sh"
sudo chmod +x "$EMIROS_DIR/start-emiros.sh"

# Create systemd service
echo "Creating systemd service..."
sudo tee /etc/systemd/system/emiros-qemu.service > /dev/null << EOF
[Unit]
Description=EmiROS QEMU Virtual Machine
After=network.target

[Service]
Type=forking
ExecStart=$EMIROS_DIR/start-emiros.sh
PIDFile=/var/run/emiros-qemu.pid
Restart=on-failure
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
echo "Enabling EmiROS service..."
sudo systemctl daemon-reload
sudo systemctl enable emiros-qemu.service

# Configure iptables for port forwarding
echo "Configuring firewall..."
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 5900 -j ACCEPT

# Make iptables rules persistent
if command -v iptables-save &> /dev/null; then
    sudo apt-get install -y iptables-persistent
    sudo netfilter-persistent save
fi

echo ""
echo "================================"
echo "Setup completed!"
echo "================================"
echo ""
echo "Next steps:"
echo "  1. Start EmiROS: sudo systemctl start emiros-qemu"
echo "  2. Check status: sudo systemctl status emiros-qemu"
echo "  3. Configure DNS to point emiralpkayikci.com to this Pi's IP"
echo "  4. Access web dashboard: http://emiralpkayikci.com"
echo ""
echo "Your Raspberry Pi public IP:"
curl -s ifconfig.me || echo "Unable to detect"
echo ""
