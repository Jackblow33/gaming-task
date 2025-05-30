#!/bin/bash

# extras.sh
# 2025-05-30

# VARIABLES
USR=$(logname)
SH_PATH="/home/$USR/gaming-task" # TODO correct SH_PATH to enable path into gnome-0.4.3.sh. Should be SH_PATH="/home/$USR/gaming-task"
TIMESTAMP=$(date +%Y%m%d.%R)
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'  # No color

# PACKAGES TO INSTALL
INSTALL_PKGS=(
    'fastfetch'
    'gparted'
    'timeshift'
    'vlc'
)

# Function to handle errors
handle_error() {
    echo "Error occurred in the script. Exiting."
    sleep 2
    exit 1
}

# User check. If root, script will exit
user_check() {
if [[ $EUID -eq 0 ]]; then
    echo "This script should be executed as user with root previlege!! Exiting......."
    exit 1
fi
}

update_upgrade() {
    # Update package list and upgrade installed packages
    echo "Updating package list and upgrading installed packages..."
    sudo apt update && sudo apt upgrade -y || { echo "Failed to update-upgrade"; handle_error; }
}

brave_browser() {
    #source /home/$USER/debian/brave.sh
    sudo systemctl daemon-reload
    sudo systemctl start gnome-keyring-daemon
    sudo systemctl enable gnome-keyring-daemon.service
    # sudo systemctl status gnome-keyring-daemon.service
    sudo chown -R $USR:$USR /home/$USR/.local

    # Install brave
    sudo apt install -y curl || handle_error
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg || handle_error
    sudo echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list || handle_error
    sudo apt update -y || handle_error
    sudo apt install -y brave-browser || handle_error
}



install_pkg() {
    for PKG in "${INSTALL_PKGS[@]}"; do
        echo "INSTALLING: ${PKG}"
        sudo apt install "$PKG" -y || { echo "Failed to install $PKG"; handle_error; }
    done
}

install_qemu_kvm() {
    echo "Installing qemu-kvm..."
    source "$SH_PATH/modules/qemu-kvm-0.6.sh"
}


fastfetch_tweak() {
    # Check if the .bashrc file exists
    if [ -f "/home/$USER/.bashrc" ]; then
        # Check if the 'fastfetch' command is already in the .bashrc file
        if ! grep -q "fastfetch" "/home/$USER/.bashrc"; then
            # Add the 'fastfetch' command to the end of the .bashrc file
            echo "fastfetch" >> /home/$USER/.bashrc || { echo "Fail to write fastfetch line into the .bashrc file."; handle_error; }
            echo "fastfetch has been added to the .bashrc file."
        else
            echo "fastfetch is already in the .bashrc file."
        fi
    else
        echo "The .bashrc file does not exist."
    fi

}

# Pin apps to favorites ## DO NOT EXECUTE AS ROOT !!!
pin_apps() {
    # List
    # gsettings get org.gnome.shell favorite-apps

    # List results
    # ['org.gnome.Nautilus.desktop', 'org.gnome.Console.desktop', 'org.kde.kate.desktop', 'brave-browser.desktop']

    # Pin aps
    gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'org.gnome.Console.desktop', 'org.kde.kate.desktop', 'brave-browser.desktop']"
}

# Right click create new text file in Gnome Nautilus
r_click() {
touch ~/Templates/New\ Text\ File.txt
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
    sudo reboot
}

# Main script execution
user_check
update_upgrade
brave_browser
install_pkg
#install_qemu_kvm
fastfetch_tweak
pin_apps
r_click
countdown_reboot
