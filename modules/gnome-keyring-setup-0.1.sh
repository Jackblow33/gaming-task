#!/bin/bash

# gnome-keyring-setup-0.1.sh
# 2023-05-19

# Check if the script is run with sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo privileges."
   exit 1
fi

# Create the service file
create_service_file() {
cat << EOF > /etc/systemd/system/gnome-keyring-daemon.service
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
}

# Create folder and set permissions
create_folder_and_permissions() {
  local user=$(logname)
  mkdir -p "/home/$user/.local"
  chown -R "$user:$user" "/home/$user/.local"
}

# Reload systemd daemon and enable the service
manage_keyring_daemon() {
  systemctl daemon-reload
  systemctl start gnome-keyring-daemon
  systemctl enable gnome-keyring-daemon.service
  systemctl status gnome-keyring-daemon.service
}

# Main script execution
create_service_file
create_folder_and_permissions
manage_keyring_daemon
