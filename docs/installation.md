# Installing EmiROS

This guide covers testing EmiROS in QEMU and installing it on a Raspberry Pi 5.

## Testing with QEMU

Before flashing to an SD card, test EmiROS in QEMU.

### Prerequisites

Install QEMU:
```bash
sudo apt-get install qemu-system-aarch64
```

### Running in QEMU

```bash
make qemu
```

Or run the script directly:
```bash
./scripts/run-qemu.sh
```

### QEMU Features

- **Display**: SDL window showing XFCE desktop
- **Network**: Port forwarding from host port 8080 to guest port 80
- **Web Dashboard**: http://localhost:8080
- **Console**: Serial output in terminal

### VNC Mode

To run with VNC instead of SDL:

```bash
./scripts/run-qemu.sh --vnc
```

Connect with VNC client to `localhost:5900`.

### Exiting QEMU

Press `Ctrl+A` then `X` to quit.

## Flashing to SD Card

### Prerequisites

- Raspberry Pi 5
- MicroSD card (16GB or larger recommended)
- SD card reader
- Built EmiROS image (`output/images/sdcard.img`)

### Warning

⚠️ **This will erase all data on the SD card!**

### Flash Steps

1. Insert SD card into your computer

2. Identify the device:
```bash
lsblk
```

Look for your SD card (usually `/dev/sdX` or `/dev/mmcblkX`)

3. Flash the image:
```bash
make flash DEVICE=/dev/sdX
```

Replace `/dev/sdX` with your actual device.

Or use the script directly:
```bash
sudo ./scripts/flash-sd.sh /dev/sdX
```

4. Wait for flashing to complete

5. Safely remove the SD card

### First Boot

1. Insert SD card into Raspberry Pi 5
2. Connect HDMI cable to monitor
3. Connect keyboard and mouse (USB)
4. Connect Ethernet cable (optional but recommended)
5. Connect power supply

The Pi will boot and you should see:
- Boot messages on console
- XFCE desktop environment loads automatically
- Login is automatic (root user)

### Post-Installation

After first boot:

1. **Check network**:
```bash
ip addr show eth0
```

2. **Access web dashboard**:
   - Find your IP address
   - Open browser: http://YOUR_PI_IP/

3. **Change root password** (recommended):
```bash
passwd
```

## Network Configuration

### DHCP (Default)

EmiROS uses DHCP by default on eth0.

### Static IP

Edit `/etc/network/interfaces`:

```bash
nano /etc/network/interfaces
```

Change to:
```
auto eth0
iface eth0 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1
```

Restart networking:
```bash
/etc/init.d/S10network restart
```

## SSH Access

EmiROS includes Dropbear SSH server:

```bash
ssh root@YOUR_PI_IP
```

Default password: `emiros` (change this!)

## Troubleshooting

### No Display

1. Check HDMI cable
2. Try different HDMI port
3. Edit `boot/config.txt` on SD card

### No Network

1. Check Ethernet cable
2. Check DHCP server
3. Try static IP configuration

### Web Dashboard Not Working

1. Check httpd is running:
```bash
ps | grep httpd
```

2. Restart web server:
```bash
/etc/init.d/S80httpd restart
```

### XFCE Not Starting

1. Check X11 logs:
```bash
cat /var/log/Xorg.0.log
```

2. Manually start X:
```bash
startx
```

## Next Steps

- [Customize XFCE](xfce-customization.md)
- [Set up hosting](hosting.md)
