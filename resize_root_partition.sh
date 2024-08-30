#!/bin/bash

# Check for root user
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit 1
fi

# Detect the operating system
if [[ -f /etc/redhat-release ]]; then
  OS="redhat"
elif [[ -f /etc/lsb-release ]]; then
  OS=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
else
  echo "Unsupported OS"
  exit 1
fi

echo "Detected OS: $OS"

# Install necessary packages based on the OS
case "$OS" in
  "redhat"|"centos")
    yum install -y gdisk
    ;;
  "ubuntu"|"debian")
    apt-get update
    apt-get install -y gdisk
    ;;
  *)
    echo "Unsupported OS"
    exit 1
    ;;
esac

# Retrieve current root partition
ROOT_PARTITION=$(df | grep -w / | awk '{print $1}')
echo "Root partition is: $ROOT_PARTITION"

# Retrieve LVM physical volume information
LVM_PARTITION=$(pvs --noheadings -o pv_name | awk '{print $1}' | head -n 1)
echo "Original LVM partition is: $LVM_PARTITION"

# Find a new disk to use as temporary LVM
NEW_LVM_DISK=$(lsblk -lp | grep disk | grep -v $(basename $ROOT_PARTITION) | awk '{print $1}' | head -n 1)
echo "New LVM disk is: $NEW_LVM_DISK"

# Get root disk without partition number
ROOT_DISK=$(echo $ROOT_PARTITION | sed 's/[0-9]*$//')
echo "Root disk is: $ROOT_DISK"

# Display current block devices and LVM information
lsblk
pvdisplay
vgs
lvs

# Partition the new disk
echo -e "n\np\n1\n\n\nw" | fdisk $NEW_LVM_DISK

# Get the new partition
NEW_LVM_PARTITION=$(lsblk -lp | grep part | grep $(basename $NEW_LVM_DISK) | awk '{print $1}')
echo "New LVM partition is: $NEW_LVM_PARTITION"

# Create physical volume on the new partition
pvcreate $NEW_LVM_PARTITION

# Extend the volume group to include the new partition
vgextend vgroot $NEW_LVM_PARTITION

# Move data from the old LVM partition to the new partition
echo "############### Please wait around 20 minutes"
pvmove $LVM_PARTITION $NEW_LVM_PARTITION

# Remove the old LVM partition from the volume group
vgreduce vgroot $LVM_PARTITION
pvremove $LVM_PARTITION

# Display updated block devices and LVM information
pvdisplay
lsblk

# Delete the original LVM partition
PART_NUMBER=$(echo $LVM_PARTITION | grep -o '[0-9]*$')
echo -e "p\nd\n$PART_NUMBER\np\nw" | fdisk $ROOT_DISK

# Reload the partition table
partprobe
lsblk

# Resize the root partition (extend to 100GB)
echo "############## Resizing root partition (extend to 100GB): $ROOT_PARTITION"
ROOT_PART_NUMBER=$(echo $ROOT_PARTITION | grep -o '[0-9]*$')
echo -e "p\nd\n$ROOT_PART_NUMBER\nn\np\n$ROOT_PART_NUMBER\n\n+100G\np\nw" | fdisk $ROOT_DISK

# Reload the partition table
partprobe
lsblk

# Recreate the original LVM partition
echo -e "p\nn\np\n$PART_NUMBER\n\n\np\nw" | fdisk $ROOT_DISK

# Reload the partition table
partprobe
lsblk

# Recreate the physical volume on the original partition
echo y | pvcreate $LVM_PARTITION -ff
vgextend vgroot $LVM_PARTITION
vgreduce vgroot --removemissing

# Move data back to the original LVM partition
echo "############### Please wait around 20 minutes"
pvmove $NEW_LVM_PARTITION $LVM_PARTITION
vgreduce vgroot $NEW_LVM_PARTITION
pvremove $NEW_LVM_PARTITION
vgreduce vgroot --removemissing

# Display final block device and LVM information
lsblk
echo "###### Root partition has been extended successfully. Please detach the additional disk."
