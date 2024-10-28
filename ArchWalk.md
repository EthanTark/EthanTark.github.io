# Arch Linux Installation Guide

This document provides a guide for installing Arch Linux using the live system booted from an installation medium created from an official installation image.

## System Requirements

- **Architecture**: x86_64-compatible machine
- **RAM**: Minimum 512 MiB
- **Disk Space**: Less than 2 GiB for a basic installation
- **Internet Connection**: Required for package retrieval

## 1. Pre-installation

### 1.2 Verify Signature

- **With GnuPG**:

  **`gpg --keyserver-options auto-key-retrieve --verify archlinux-version-x86_64.iso.sig`**

  **`pacman-key -v archlinux-version-x86_64.iso.sig`**

### 1. Pre-Install

Create the iso or whatever you have onto the VM.

### 1.5 Console Keyboard Layout and Font

**`localectl list-keymaps`**

For Keyboard layout ex:
**`loadkeys de-latin1`**

Console fonts are located - /usr/share/kbd/consolefonts/
Can be set with setfont, omitting the path and file extension. 
Ex: large font suitable for HiDPI screens, run:
**`setfont ter-132b`**

### 1.6 Verify Boot Mode

To verify the boot mode, check the UEFI bitness:
**`cat /sys/firmware/efi/fw_platform_size`**

Return 64, the system is booted in UEFI mode with a 64-bit x64 UEFI.
Return 32, the system is booted in UEFI mode with a 32-bit IA32 UEFI, limiting boot loader choice to systemd-boot and GRUB.
File does not exist - system may be booted in BIOS (or CSM) mode. (Most Likely this mode)

### 1.7 Internet

- To check that network interface is enabled and listed
  **`ip link`**

Configure network:

DHCP: Should just work
Static IP address: Follow Network configuration#Static IP address.

Verify the connection with ping:
**`ping archlinux.org`**

### 1.8 System Clock

Should auto fix if in live environment.
Use timedatectl to ensure the system clock is synchronized:
**`timedatectl`**

### 1.9 Partition the Disks

Should be something like `/dev/sda`. To identify, use `lsblk` or `fdisk`:

**`fdisk -l`**

Use a partitioning tool fdisk.
**`fdisk /dev/the_disk_to_be_partitioned`**

### 1.9.1 Layout

Use the MBR layout with BIOS.
If it is UEFI not BIOS use GPT layout.
Comment: Had a problem with this make sure to do MBR with the BIOS, GPT does not work with BIOS!

## MBR

swap - /dev/swap_part - Linux swap - 4 GiB
/(root) - /dev/root_part - Linux - 23 GiB
Comment: They probably have names like sda1 and sda2.

### 1.10 Format the Partitions

- Create an Ext4 file system on `/dev/root_partition`:
  **`mkfs.ext4 /dev/root_partition`**

For swap, initialize it with mkswap:
**`mkswap /dev/swap_partition`**

If created an EFI system partition, format it to FAT32 using mkfs.fat:
**`mkfs.fat -F 32 /dev/efi_system_partition`**

### 1.11 Mount File Systems

Mount `/mnt`. For Example: `/dev/root_partition`:

**`mount /dev/root_partition /mnt`**

For UEFI systems:
**`mount --mkdir /dev/efi_system_partition /mnt/boot`**

If swap:
**`swapon /dev/swap_partition`**

## 2. Install

### 2.1 Install Essential Packages
Comment: Be very careful with this part if mirror list is emtpy re pop it or restart
Check if mirror list is ok, if not fix it. Use command:
**`/etc/pacman.d/mirrorlist`**

Use:
**`pacstrap -K /mnt base linux linux-firmware`**

## Config System

### 3.1 Fstab

Generate the `fstab` file:
**`genfstab -U /mnt >> /mnt/etc/fstab`**

Check and edit /mnt/etc/fstab if needed.

### 3.2 Chroot

Enter the new system: