# Building EmiROS

This guide explains how to build EmiROS from source.

## Prerequisites

### Build Host Requirements

You need a Linux system (Ubuntu 20.04+ or similar) with the following installed:

```bash
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    git \
    wget \
    cpio \
    unzip \
    rsync \
    bc \
    libssl-dev \
    libncurses5-dev \
    device-tree-compiler \
    qemu-system-arm \
    qemu-system-aarch64
```

### Disk Space

- At least 10GB of free disk space for Buildroot and build artifacts
- Additional 2GB for output images

## Build Steps

### 1. Clone the Repository

```bash
git clone https://github.com/emiralpK/emiros.git
cd emiros
```

### 2. Download Buildroot

```bash
make download
```

This will download Buildroot 2024.02.

### 3. Configure Build

```bash
make configure
```

This applies the EmiROS defconfig to Buildroot.

### 4. Build the Image

```bash
make build
```

**Note:** The first build takes 30 minutes to 2 hours depending on your system and internet connection. Subsequent builds are much faster.

Build progress will be shown in the terminal. The build process:
- Downloads all required packages
- Compiles the Linux kernel
- Builds X11 and XFCE packages
- Creates the root filesystem
- Generates the bootable SD card image

### 5. Build Output

After successful build, you'll find the image at:

```
output/images/sdcard.img
```

## Customizing the Build

### Modifying Packages

To add or remove packages:

1. Enter Buildroot menuconfig:
```bash
cd buildroot-2024.02
make O=../output menuconfig
```

2. Make your changes in the menu interface

3. Save the configuration:
```bash
make O=../output savedefconfig
cp ../output/defconfig ../configs/emiros_rpi5_defconfig
```

### Modifying the Kernel

To customize the kernel configuration:

```bash
cd buildroot-2024.02
make O=../output linux-menuconfig
```

Save the kernel config to `configs/kernel.config`.

### Modifying Root Filesystem

Edit files in `rootfs_overlay/` - these are copied directly into the root filesystem during build.

## Troubleshooting

### Build Fails

1. Check build logs in `output/build/`
2. Ensure all prerequisites are installed
3. Try cleaning and rebuilding:
```bash
make clean
make build
```

### Out of Disk Space

Clean old builds:
```bash
make distclean
```

This removes everything including Buildroot itself.

## Next Steps

After building:
- [Test with QEMU](installation.md#testing-with-qemu)
- [Flash to SD card](installation.md#flashing-to-sd-card)
- [Set up hosting](hosting.md)
