#!/bin/bash

# 2025-05-22
# install-3.0.6.sh

# VARIABLES
USR=$(logname)
SH_PATH="/home/$USR/gaming-task" # TODO correct SH_PATH to enable path into gnome-0.4.3.sh. Should be SH_PATH="/home/$USR/gaming-task"
TIMESTAMP=$(date +%Y%m%d.%R)
KERNEL="6.14.3-tkg-bore"
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'  # No color

# Functions
timer_start() {
    BEGIN=$(date +%s)
}

# Functions
timer_stop() {
    NOW=$(date +%s)
    DIFF=$((NOW - BEGIN))
    MINS=$((DIFF / 60))
    SECS=$((DIFF % 60))
    echo "Time elapsed: $MINS:$(printf %02d $SECS)"
}

# Function to handle errors
handle_error() {
    echo "Error occurred in the script. Exiting."
    sleep 2
    exit 1
}

# Function reboot countdown 10sec.
countdown_reboot() {
    local countdown_time=10

    # Function to handle Ctrl+C signal
    handle_sigint() {
        echo "Countdown interrupted. Exiting..."
        exit 0
    }

    # Trap the Ctrl+C signal and call the handle_sigint function
    trap handle_sigint SIGINT

    # Countdown loop
    for ((i=$countdown_time; i>0; i--)); do
        clear
        echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
        echo "                                                                                      Rebooting in $i seconds. Press Ctrl+C to cancel."
        sleep 1
    done

    # Reboot the system if Ctrl+C was not pressed
    echo "Rebooting system..."
    reboot
}

# Root check
root_check() {
if [ "$EUID" -ne 0 ]; then
  echo "This script must be executed as root!! Exiting......."
  exit 1
fi
}


# User check. If root, script will exit
user_check() {
if [[ $EUID -eq 0 ]]; then
    echo "This script should be executed as user with root previlege!! Exiting......."
    exit 1
fi
}

# Grant read, write, and execute permissions recursively to the root, user and others. Use at your own risk!!!
set_permission() {
    echo"Setting permissions"
    chmod -R 777 $SH_PATH
}

# Log system specs in /home/$USR/debian/LOGS
system_log() {
echo "Logging system specs"
source /home/$USR/gaming-task/LOGS/syslog.sh
}

# Function to display the menu
display_menu() {
    local menu_choice
    menu_choice=$(whiptail --title "Base Gnome installation & extra programs" --checklist "Make your selection:" 20 80 6 \
        "Install custom TKG kernel $KERNEL from dropbox" "" OFF \
        "Install NVIDIA driver" "" OFF \
        "Install WiFi BCM4360" "" OFF \
        "Install Gnome" "" ON \
        "Install Qemu-Kvm virtualization" "" OFF \
        "Reboot system" "" ON 3>&1 1>&2 2>&3)

    # Execute the selected options in sequence

    if [[ $menu_choice == *"Install custom TKG kernel $KERNEL from dropbox"* ]]; then
        echo "Installing custom kernel $KERNEL from Dropbox..."
        # source "$SH_PATH/kernel-install.sh"
        source "$SH_PATH/modules/dropbox-kernel-0.3.sh"
    fi
    
    if [[ $menu_choice == *"Install NVIDIA driver"* ]]; then
        echo "Installing NVIDIA driver $NV_VER..."
        source "$SH_PATH/modules/drivers/nvidia-11.7.1.sh"
    fi

    if [[ $menu_choice == *"Install WiFi BCM4360"* ]]; then
        echo "Installing WiFi BCM4360..."
        source "$SH_PATH/modules/drivers/wifi-bcm43xx-0.1.sh"
    fi

    if [[ $menu_choice == *"Install Gnome"* ]]; then
        echo "Installing Gnome..."
        # source "$SH_PATH/pkgs-tools/alpha-debian-gnome.sh" (STABLE)
        source "$SH_PATH/modules/gnome-0.4.3.sh"
    fi


    if [[ $menu_choice == *"Install Qemu-Kvm virtualization"* ]]; then
        echo "Installing qemu-kvm..."
        source "$SH_PATH/modules/qemu-kvm-0.6.sh"
    fi

    if [[ $menu_choice == *"Reboot system"* ]]; then
        echo "Rebooting system..."
        countdown_reboot
    fi
}


# Main script execution
root_check
set_permission
system_log
display_menu
