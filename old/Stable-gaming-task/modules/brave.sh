#!/bin/bash

# Brave web browser install. Debian, Ubuntu, Mint - 2025-05-19

USR=$(logname)

######gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg
# Reload systemd daemon and enable the service
sudo systemctl daemon-reload
sudo systemctl start gnome-keyring-daemon
sudo systemctl enable gnome-keyring-daemon.service
# sudo systemctl status gnome-keyring-daemon.service
sudo chown -R $USR:$USR /home/$USR/.local

# Install brave
sudo apt install -y curl
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
sudo echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update -y
sudo apt install -y brave-browser

# Keyring quirk fix
# apt purge -y gnome-keyring && apt autoremove -y
# sed -i 's|/usr/bin/brave-browser-stable|/usr/bin/brave-browser-stable --password-store=gnome|g' /usr/share/applications/brave-browser.desktop
