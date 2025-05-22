#!/bin/bash

#2025-04-24

# Execute as root
# Script to install Broadcom drivers for iMac BCM4360 and other models - check wiki
# Source: https://wiki.debian.org/wl

# Start timer
timer_start

# Backup the original sources.list file
#cp /etc/apt/sources.list "/etc/apt/sources_$TIMESTAMP.list"

# Add the non-free contrib repository to the sources.list file        ####### ADD check if present + automate for sid vs trixie
#echo "Adding non-free contrib repository to sources.list..."
#echo "deb http://deb.debian.org/debian/ trixie non-free contrib" >> /etc/apt/sources.list || handle_error

# Update package lists
echo -e "${YELLOW}Updating package lists...${NC}"
apt update

# Install
echo -e "${YELLOW}Installing Broadcom drivers and kernel headers...${NC}"
apt-get install -y linux-headers-$(unamer -r) broadcom-sta-dkms || handle_error

# Unload conflicting modules
echo -e "${YELLOW}Unloading conflicting modules...${NC}"
modprobe -r b44 b43 b43legacy ssb brcmsmac bcma || handle_error

# Load the Broadcom driver
# echo -e "${GREEN}Loading Broadcom driver...${NC}"
# modprobe -r wl && modprobe wl || handle_error

# Check if the user is running GNOME then load Broadcom driver.
  if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
    modprobe -r wl && modprobe wl
  else
    echo "Skipping loading Broadcom driver as condition is not met."
  fi

# Stop timer
timer_stop

# Pause
#echo -e "\n\nInstallation completed! Press Enter to continue..."
#read -r

# Optional: Uncomment the following line to check DKMS modules
# echo "Checking DKMS modules..."
# dkms status

# Optional: Uncomment the following lines to check for the presence of wl.ko
# echo "Checking for wl.ko module..."
# find /lib/modules/$(uname -r)/updates -name "wl.ko"

# Old installation method (commented out)
# cd /home/$USER/Downloads
# sudo wget http://http.us.debian.org/debian/pool/non-free/b/broadcom-sta/broadcom-sta-dkms_6.30.223.271-26_amd64.deb
# sudo apt install linux-image-amd64 linux-headers-amd64 wireless-tools broadcom-sta-dkms
