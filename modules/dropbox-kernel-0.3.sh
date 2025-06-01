#!/bin/bash

# dropbox-kernel-0.3.sh
# 2025-05-20


# My precompiled dropbox Haswell kernel 6.14.3-tkg-bore  (all modules compiled)
# To update the kernel version simply edit following variables: DROPBOX_FOLDER_PATH & FOLDER_NAME

USR=$(logname)
DOWNLOAD_DIR="/home/$USR/kernels"

# Function to handle errors
handle_error() {
    echo "Error occurred in the script. Exiting."
    sleep 2
    exit 1
}


dl_kernel() {
    # Dropbox public folder link of: Haswell kernel 6.14.3-tkg-bore
    DROPBOX_FOLDER_PATH="https://www.dropbox.com/scl/fo/wu8ffjknu506i1ehachss/AHrRWSPCewap_ZEhvXcvQQo?rlkey=eb6clwlaeh9843v39afdbitzb&st=tp72906w&dl=1"

    # Create the download directory if it doesn't exist
    mkdir -p "$DOWNLOAD_DIR" || { echo "Failed at line 26"; handle_error; }
    sudo chmod 777 "$DOWNLOAD_DIR" || { echo "Failed at line 27"; handle_error; }

    # Use curl to download the folder and extract the original file name
    sudo apt install -y curl
    FOLDER_NAME=$(curl -L "$DROPBOX_FOLDER_PATH" | grep -oP '(?<=name=").*(?=".zip)')
    DOWNLOAD_PATH="$DOWNLOAD_DIR/$FOLDER_NAME"
    mkdir -p "$DOWNLOAD_PATH" || handle_error || { echo "Failed at line 33"; handle_error; }

    # Download the folder contents using curl
    curl -L "$DROPBOX_FOLDER_PATH" -o "$DOWNLOAD_PATH/$FOLDER_NAME.zip" || { echo "Failed at line 36"; handle_error; }
}


extract_kernel() {
    # Extract the downloaded ZIP file
    sudo apt-get install -y p7zip-full
    sudo 7z x /home/$USR/kernels/$FOLDER_NAME/$FOLDER_NAME.zip -o/home/$USR/kernels/$FOLDER_NAME/ || { echo "Failed at line 43"; handle_error; }

    # Check if the extraction was successful
    if [ -d "/home/$USR/kernels/$FOLDER_NAME" ]; then
        echo "Files downloaded and extracted to: /home/$USR/kernels/$FOLDER_NAME"
    else
        echo "Failed to extract the files. Exiting."
        handle_error
    fi
}



install_kernel() {
    # Install dependencie
    sudo apt install -y dkms || { echo "Failed at line 58"; handle_error; }
    # Change to the download directory
    cd "/home/$USR/kernels/$FOLDER_NAME" || { echo "Failed at line 60"; handle_error; }

    # Check if there are any .deb files in the directory
    if [ "$(ls -1 *.deb 2>/dev/null | wc -l)" -gt 0 ]; then
        # Install the kernel packages using dpkg
        for deb_file in *.deb; do
            sudo dpkg -i "$deb_file" || { echo "Failed at line 66"; handle_error; }
            #cd "/home/$USR" || { echo "Failed at line 65"; handle_error; }
        done
        
        # Update the initramfs
        #sudo update-initramfs -u || { echo "Failed at line 71"; handle_error; }
        # Update the grub configuration
        sudo update-grub || { echo "Failed at line 73"; handle_error; }

        # Uncomment to reboot the system and load the new kernel
        #echo "Kernel installation complete. Rebooting the system..."
        #sudo reboot
    else
        echo "No .deb files found in the extracted directory. Exiting."
        handle_error
    fi
}



# Main script execution
dl_kernel
extract_kernel
install_kernel
