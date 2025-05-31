#!/bin/bash

# enable-apparmor.sh
# 2025-05-31
# https://wiki.debian.org/AppArmor/HowToUse

# Add additional profiles:
sudo apt install apparmor-profiles-extra apparmor-utils auditd

# Enable AppArmor
sudo mkdir -p /etc/default/grub.d
echo 'GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT apparmor=1 security=apparmor"' \ | sudo tee /etc/default/grub.d/apparmor.cfg
sudo update-grub
#sudo reboot


# Checks

# Inspect current state (should return Y if enable)
#cat /sys/module/apparmor/parameters/enabled

# List all loaded AppArmor profiles for applications and processes and detail their status (enforced, complain, unconfined):
#sudo aa-status

# List running executables which are currently confined by an AppArmor profile:
#ps auxZ | grep -v '^unconfined'

# List of processes with tcp or udp ports that do not have AppArmor profiles loaded:
# Provided by apparmor-utils
#sudo aa-unconfined
#sudo aa-unconfined --paranoid

# Enabling profiles
# Debian packages that install profiles to /etc/apparmor.d/ automatically enable them (complain mode).
# Other profiles need to be copied to this directory and manually set to complain or enforce mode.

# For example to install an "extra" profile from the /usr/share/apparmor/extra-profiles/ directory provided by apparmor-profiles and set it to complain mode:


# list available profiles
#ls /usr/share/apparmor/extra-profiles/

# install the profile
#sudo cp /usr/share/apparmor/extra-profiles/usr.bin.example /etc/apparmor.d/

# set the profile to complain mode
#sudo aa-complain /etc/apparmor.d/usr.bin.example
# To set a profile to enforce mode, use aa-enforce instead of aa-complain.
# Beware though: many profiles are not up-to-date and will break functionality in enforce mode, be ready to debug!


# Debug
# AppArmor logs can be found in the systemd journal, in /var/log/syslog and /var/log/kern.log (and /var/log/audit.log when auditd is installed).
