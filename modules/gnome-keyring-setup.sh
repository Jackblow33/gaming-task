#!/bin/bash

# gnome-keyring-setup.sh
# 2025-05-19

# sudo apt install -y dbus-x11
# Create the service file
service_file() {
cat << EOF | sudo tee /etc/systemd/system/gnome-keyring-daemon.service || handle_error
[Unit]
Description=GNOME Keyring Daemon
After=dbus.service

[Service]
Type=dbus
BusName=org.gnome.keyring
ExecStart=/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg
Restart=on-failure

[Install]
WantedBy=graphical.target
EOF
#sudo nano /etc/systemd/system/gnome-keyring-daemon.service
}

# Create folder and set permissions
folder_and_permission() {
mkdir -p /home/$USR/.local || handle_error
sudo chown -R $USR:$USR /home/$USR/.local || handle_error
}

# Reload systemd daemon and enable the service
keyring_daemon() {
sudo systemctl daemon-reload || handle_error
sudo systemctl start gnome-keyring-daemon || handle_error
sudo systemctl enable gnome-keyring-daemon.service || handle_error
sudo systemctl status gnome-keyring-daemon.service
}

# Main script execution
service_file
# folder_and_permission
# keyring_daemon


# NOTE:
# Ensure the gnome-keyring-daemon is running in a graphical environment: If you are running a desktop environment like GNOME, make sure the gnome-keyring-daemon is started correctly within that environment.
# Use an alternative keyring solution: If you don't need the full GNOME Keyring functionality, you can consider using a simpler keyring solution that doesn't require a graphical environment,
# such as the command-line tool pass or the libsecret library.

# OR Disable the gnome-keyring-daemon service: If you don't need the GNOME Keyring functionality, you can disable the gnome-keyring-daemon service by running the following commands:
# sudo systemctl disable gnome-keyring-daemon.service
# sudo systemctl stop gnome-keyring-daemon.service
# This will prevent the service from starting automatically and resolve the error.
