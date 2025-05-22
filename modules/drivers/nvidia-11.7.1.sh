#!/bin/bash

#!/bin/bash

# 2025-05-22
SH_VER="nvidia-11.7.1.sh"
# WORKING, close to stable

# nvidia.sh - Script to install NVIDIA drivers on Debian 13 - Trixie & Sid. Untested on Stable but might work.
# Linux kernel 6.11 and beyond required

USR=$(logname)
NV_VER="570.133.07"  # Default Nvidia Driver version
driver_dir="$SH_PATH/drivers/NVIDIA-drivers-archives"
TIMESTAMP=$(date +%Y%m%d.%R)


# Display the NVIDIA driver installation warning!
display_nvidia_warning() {
    local MESSAGE="To blacklist nouveau driver, the file: /etc/modprobe.d/blacklist-nouveau.conf gonna be created.\n\n\n\
To fix some power management issues, the file: /etc/modprobe.d/nvidia-power-management.conf gonna be created.\n\n\n\
nvidia-drm.modeset=1 gonna be added to grub at line: GRUB_CMDLINE_LINUX_DEFAULT in /etc/default.\n\n\n\
And of course you're gonna taint your kernel with the nvidia proprietary driver!!!\n\n\n\
Would you like to continue? Yes or No."

    # Display the message in a yes/no dialog
    if (whiptail --title "NVIDIA Driver Installation Warning" --yesno "$MESSAGE" 24 70); then
        echo "User chose to continue."
        # Add commands here to create the files and modify grub if needed
    else
        echo "User chose not to continue."
        exit 1
    fi
}


# Function to handle errors
handle_error() {
    echo "Error occurred in the script. Exiting."
    exit 1
}

timer_start() {
    BEGIN=$(date +%s)
}

timer_stop() {
    NOW=$(date +%s)
    DIFF=$((NOW - BEGIN))
    MINS=$((DIFF / 60))
    SECS=$((DIFF % 60))
    echo "Time elapsed: $MINS:$(printf %02d $SECS)"
}

# Update package list and install necessary packages
install_dependencies() {
    apt update && apt install -y linux-headers-$(uname -r) gcc make acpid dkms libvulkan1 libglvnd-core-dev pkg-config wget || handle_error  #libglvnd0 libglvnd-dev libc-dev
    # apt-get purge nvidia-*    # Purge debian nvidia driver packages
    # 32 bit libraries
    dpkg --add-architecture i386 && apt update || handle_error
    # Minimmal
    apt-get install -y libc6:i386 libgl1-mesa-dri:i386 libx11-6:i386 || handle_error
    # Extras
    #apt-get install libc6:i386 libgl1:i386 libgtk2.0-dev:i386 libgtk-3-dev:i386 libglu1-mesa:i386 libsm6:i386 libxext6:i386 libxfixes3:i386 libxi6:i386 libxmu6:i386 libxrender1:i386 libxxf86vm1:i386
    #    apt install -y nvidia-driver-libs:i386  #libgl1-nvidia-glx:i386    #(32 bit with debian pkg driver???)
}

# Download NVIDIA driver
download_nvidia_driver() {
    driver_file="NVIDIA-Linux-x86_64-${NV_VER}.run"
    driver_path="$driver_dir/$driver_file"

    # Check if the driver directory exists, if not, create it
    if [ ! -d "$driver_dir" ]; then
        mkdir -p "$driver_dir"
        chmod 777 "$driver_dir"
    fi

    # Check if the driver file already exists in the directory
    if [ -f "$driver_path" ]; then
        echo "The driver file '$driver_file' already exists in '$driver_dir'. Skipping download."
    else
        wget "https://us.download.nvidia.com/XFree86/Linux-x86_64/${NV_VER}/${driver_file}" -P "$driver_dir" || { echo "Error downloading the driver file"; exit 1; }
    fi
}


# Install NVIDIA driver
install_nvidia_driver() {
    if [ -f "$driver_path" ]; then
        chmod +x "$driver_path"
        sh "$driver_path" || { echo "Installation aborted or script have failed to load the Nvidia installer."; exit 1; }
    else
        echo "The driver file '$driver_file' does not exist in '$driver_dir'."
        exit 1
    fi
}


# Blacklist Nouveau driver
blacklist_nouveau() {
# Check if the /etc/modprobe.d/nvidia-installer-disable-nouveau.conf have already been created by nvidia installer
if [ -f "/etc/modprobe.d/nvidia-installer-disable-nouveau.conf" ]; then
    echo "File /etc/modprobe.d/nvidia/installer-disable-nouveau.conf already exists"
else
    # Check if the blacklist entries are in blacklist-nouveau.conf, if not add them
    if ! grep -q "blacklist nouveau" "/etc/modprobe.d/blacklist-nouveau.conf"; then
        echo "blacklist nouveau" | sudo tee -a "/etc/modprobe.d/blacklist-nouveau.conf"
    fi
    if ! grep -q "options nouveau modeset=0" "/etc/modprobe.d/blacklist-nouveau.conf"; then
        echo "options nouveau modeset=0" | sudo tee -a "/etc/modprobe.d/blacklist-nouveau.conf"
    fi
    echo "Nouveau driver has been blacklisted. System have to be reboot later on for the changes to take effect"
fi
}


# Add grub entries including iommu used by qemu-kvm virtualization
edit_grub_config() {
# Copy before editing /etc/default/grub file.
    sudo cp /etc/default/grub /etc/default/grub.BAK_OG_$TIMESTAMP || handle_error
# Disable original GRUB_CMDLINE_LINUX_DEFAULT line.
    sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT/#GRUB_CMDLINE_LINUX_DEFAULT/' /etc/default/grub || handle_error
# Add a new GRUB_CMDLINE_LINUX_DEFAULT with options: nvidia-drm.modeset=1        # and intel_iommu=on_(use for virtualisation)
                  #OLD  #echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet nvidia-drm.modeset=1 intel_iommu=on"' | sudo tee -a /etc/default/grub || handle_error   # Add argument "splash" To enable boot splash screen
    echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet nvidia-drm.modeset=1"' | sudo tee -a /etc/default/grub || handle_error   # Add argument "splash" To enable boot splash screen
# Update the GRUB configuration
    update-grub || handle_error
              
# Checking the kernel boot arguments added to command line
    # cat /proc/cmdline

}


# Fix Gnome for NVIDIA
fix_gnome_for_nvidia() {
    ln -sf /dev/null /etc/udev/rules.d/61-gdm.rules || handle_error
}

# Fix NVIDIA graphical glitches after waking from sleep
fix_nvidia_power_management() {
    local config_file="/etc/modprobe.d/nvidia-power-management.conf"
    if ! grep -q "# This file was generated by jackblow33 ${SH_VER} custom installer script" "$config_file"; then
        echo "# This file was generated by jackblow33 ${SH_VER} custom installer script" >> "$config_file"
    fi
    if ! grep -q 'options nvidia NVreg_PreserveVideoMemoryAllocations=1' "$config_file"; then
        echo 'options nvidia NVreg_PreserveVideoMemoryAllocations=1' >> "$config_file"
    fi
    if ! grep -q '#NVreg_TemporaryFilePath=/var/tmp' "$config_file"; then
        echo '#NVreg_TemporaryFilePath=/var/tmp' >> "$config_file"
    fi
}

# Nvidia drm modesetting
nvidia_drm_modeset() {
local config_file="/etc/modprobe.d/nvidia-graphics-drivers-kms.conf"
    if ! grep -q "# This file was generated by jackblow33 ${SH_VER} custom installer script" "$config_file"; then
        echo "# This file was generated by jackblow33 ${SH_VER} custom installer script" >> "$config_file"
    fi
    if ! grep -q '# Set value to 0 to disable modesetting' "$config_file"; then
        echo '# Set value to 0 to disable modesetting' >> "$config_file"
    fi
    if ! grep -q 'options nvidia-drm modeset=1' "$config_file"; then
        echo 'options nvidia-drm modeset=1' >> "$config_file"
    fi
}
# Enable necessary services
enable_nvidia_services() {
    for service in nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service; do
        systemctl enable "$service" || handle_error
    done
}

# Update initramfs
update_initramfs() {
    update-initramfs -u || handle_error
}

# Main script execution
display_nvidia_warning
timer_start
install_dependencies
download_nvidia_driver
install_nvidia_driver
blacklist_nouveau
# edit_grub_config
fix_gnome_for_nvidia  # kde also btw
fix_nvidia_power_management
nvidia_drm_modeset
enable_nvidia_services
# update_initramfs
timer_stop
# clear

# Clear the screen and notify the user
#clear
#echo -e "\n\n\nInstallation completed! Press Enter to continue..."
#read

# Uncomment to reboot automaticaly at the end of the installation
# shutdown -r now

# Optional checks
# sudo cat /sys/module/nvidia_drm/parameters/modeset
# sudo cat /proc/driver/nvidia/params | grep "PreserveVideoMemoryAllocations"
# lsmod | grep nouveau || echo 'Nouveau NVIDIA driver have been blacklisted'
# glxinfo | egrep "OpenGL vendor|OpenGL renderer*"
# lspci -nn | egrep -i "3d|display|vga"
# nvidia-smi
