#!/bin/bash

# nv-check.sh
# 2025-05-30

# Check if NVIDIA GPU is present
if lspci | grep -i "nvidia" > /dev/null; then
    echo "NVIDIA GPU detected."

    # Display Whiptail yes/no dialog
    if whiptail --title "NVIDIA Driver Installation" --yesno "An NVIDIA GPU has been detected. Would you like to install the NVIDIA proprietary driver?" 10 60; then
        source /home/$USR/gaming-task/modules/drivers/nvidia-11.7.1.sh
    else
        echo "NVIDIA driver installation skipped."
    fi
else
    echo "No NVIDIA GPU detected."
fi
