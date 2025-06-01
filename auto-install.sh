#!/bin/bash

# auto-install-0.1.sh
# Date modified: 2025-06-01

# VARIABLES
USR=$(logname)
SH_PATH="/home/$USR/gaming-task"
TIMESTAMP=$(date +%Y%m%d.%R)
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'  # No color

# Root_check
root_check() {
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi
}

timer_start() {
    BEGIN=$(date +%s)
}

timer_stop() {
    NOW=$(date +%s)
    DIFF=$((NOW - BEGIN))
    MINS=$((DIFF / 60))
    SECS=$((DIFF % 60))
    echo "                                                                                         Time elapsed: $MINS:$(printf %02d $SECS)"; echo "";
}

# Handle errors
handle_error() {
    echo "Error occurred in the script. Exiting."
    exit 1
}

# Grant read, write, and execute permissions recursively to the root, user and others. Use at your own risk!!!
set_permission() {
    echo"Setting permissions"
    chmod -R 777 $SH_PATH || { echo "auto-install Fail at line 44"; handle_error; }
}

# Log system specs in /home/$USR/debian/LOGS
system_log() {
echo "Logging system specs"
source "$SH_PATH/LOGS/syslog.sh" || { echo "auto-install fail at line 50"; handle_error; }
}

nv_check() {
    echo "Checking for Nvidia GPU"
    source "$SH_PATH/modules/drivers/nv-check.sh" || { echo "auto-install fail at line 55"; handle_error; }
}



install_gnome() {
    echo "Installing Gnome desktop environment"
    source "$SH_PATH/modules/gnome-0.4.3.sh" || { echo "auto-install fail at line 62"; handle_error; }
}
# TODO Works only on AMD gpu, mod check to look for AMD instead. Off by default
launch_gnome() {
    if [ -f "$SH_PATH/modules/drivers/nv-installed" ]; then
        echo "NVIDIA driver is installed, skipping GNOME enable and start steps."
        rm "$SH_PATH/modules/drivers/nv-installed" || { echo "auto-install fail at line 68"; handle_error; }
    else
        sudo systemctl enable gdm || { echo "auto-install fail at line 70"; handle_error; }
        sudo systemctl start gdm || { echo "auto-install fail at line 71"; handle_error; }
    fi
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
        timer_stop
        sleep 1
    done

    # Reboot the system if Ctrl+C was not pressed
    echo "Rebooting system..."
    reboot
}


# Main script execution
root_check
timer_start
set_permission
system_log
nv_check
install_gnome
#launch_gnome
countdown_reboot
