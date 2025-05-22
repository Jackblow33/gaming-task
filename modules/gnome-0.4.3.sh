
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
    input_file="/home/$USR/debian/pkgs-tools/tasksel_pkgs.list"
    sudo apt-get install -y $(cat "$input_file") || handle_error
    # wireplumber dir and permissions
    sudo mkdir -p /home/$USR/.local/state/wireplumber || check
    sudo chown -R $USR:$USR /home/$USR/.local/state/wireplumber || check
    # Gnome keyring daemon setup configuration
    source /home/$USR/debian/gnome-keyring-setup.sh
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
   source /home/$USR/debian/gnome-extensions.sh || handle_error
}


rm_unused_dep() {
    # REMOVE UNUSED DEPENDENCIES
    apt autoremove -y || handle_error
}


network_edit() {
    echo "Configuring NetworkManager..."
    sed -i "s/managed=false/managed=true/" /etc/NetworkManager/NetworkManager.conf || handle_error
}

stage_2_installer() {
    stage_2="/etc/systemd/system/stage-2-installer.service"
    cat << EOF > "$stage_2" || { echo "Failed at line 65"; handle_error; }
[Unit]
Description=Stage 2 custom installer script
After=reboot.target
After=graphical.target

[Service]
ExecStart=/usr/bin/kgx -- /home/jack/debian/extras.sh
Type=oneshot
RemainAfterExit=yes

[Install]
WantedBy=graphical.target
EOF

    # Enable the service
    systemctl enable stage-2-installer.service || { echo "Failed at line 81"; handle_error; }

    # Check if the reboot.target and graphical.target have been reached
    if systemctl is-active reboot.target && systemctl is-active graphical.target; then
        # If both targets are active, start the service
        systemctl start stage-2-installer.service || { echo "Failed at line 86"; handle_error; }
    else
        # If either target is not active, wait for both to become active before starting the service
        systemctl wait-for-active reboot.target
        systemctl wait-for-active graphical.target
        systemctl start stage-2-installer.service || { echo "Failed at line 91"; handle_error; }
    fi
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
# stage_2_installer # POS not working!
timer_stop


# apt list --installed
