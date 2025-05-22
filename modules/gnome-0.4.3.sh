
#!/bin/bash

# gnome-0.4.3.sh
# Date modified: 2025-05-21

# Check if the installation was successful
check() {
if [ $? -ne 0 ]; then
    echo "Command fail. Press Enter to continue."
    read -s
fi
}

update_upgrade() {
    # Update package list and upgrade installed packages
    echo "Updating package list and upgrading installed packages..."
    sudo apt update && sudo apt upgrade -y || handle_error
}

# Minimal Gnome packages installation & settings
install_desktop_environment() {
    input_file="/home/$USR/gaming-task/lists/tasksel_pkgs.list"
    sudo apt-get install -y $(cat "$input_file") || handle_error
    # wireplumber dir and permissions
    sudo mkdir -p /home/$USR/.local/state/wireplumber || check
    sudo chown -R $USR:$USR /home/$USR/.local/state/wireplumber || check
    # Gnome keyring daemon setup configuration
    source $SH_PATH/gnome-keyring-setup.sh
}


kate() {
   echo "Installing Kate text editor..."
   apt install -y kate || handle_error
   apt purge -y systemsettings
}


brave_browser() {
   echo "Installing Brave browser..."
   source /home/$USR/debian/brave.sh || handle_error
}



gnome_extensions() {
   source $SH_PATH/gnome-extensions.sh || handle_error
}


rm_unused_dep() {
    # REMOVE UNUSED DEPENDENCIES
    apt autoremove -y || handle_error
}


network_edit() {
    echo "Configuring NetworkManager..."
    sed -i "s/managed=false/managed=true/" /etc/NetworkManager/NetworkManager.conf || handle_error
}


# Main script execution
root_check
timer_start
update_upgrade
install_desktop_environment
gnome_extensions
#brave_browser     # Moved to stage 2 install      # move this to post installation with: libavcodec-extra vlc
kate
network_edit
rm_unused_dep
timer_stop


# apt list --installed
