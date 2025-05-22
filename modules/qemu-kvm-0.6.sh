#!/bin/bash

# qemu-kvm installer - Debian - supports both Intel and AMD virtualization
# Mostly based on: https://github.com/daveprowse/virtualization/blob/main/kvm/kvm-install-debian-12/kvm-install-debian-12.md

# Copy before editing /etc/default/grub
GRUB_FILE="/etc/default/grub"
cp $GRUB_FILE $GRUB_FILE.$TIMESTAMP || error_handler

# Check if Intel or AMD virtualization is enabled
VIRTUALIZATION=$(lscpu | grep Virtualization)

if [[ $VIRTUALIZATION == *"VT-x"* ]]; then
  echo "Intel virtualization (VT-x) is enabled."
  GRUB_PARAM="intel_iommu=on"
elif [[ $VIRTUALIZATION == *"AMD-V"* ]]; then
  echo "AMD virtualization (AMD-V) is enabled."
  GRUB_PARAM="amd_iommu=on"
else
  echo ""; echo ""; echo "";
  echo "Virtualization is not enabled."
  echo 'Virtualization have to be enable trough your bios first.'
  echo "Press Enter to exit"
  read
fi

# Search for the line: GRUB_CMDLINE_LINUX_DEFAULT="quiet*
GRUB_LINE=$(grep -E '^GRUB_CMDLINE_LINUX_DEFAULT="quiet' "$GRUB_FILE")

# Check if the line was found
if [ -z "$GRUB_LINE" ]; then
  echo "Error: Could not find the GRUB_CMDLINE_LINUX_DEFAULT line in $GRUB_FILE."  || error_handler
fi

# Check if the virtualization argument is already present
if grep -q "$GRUB_PARAM" <<< "$GRUB_LINE"; then
  echo "The $GRUB_PARAM argument is already present in the GRUB_CMDLINE_LINUX_DEFAULT line."
fi

# Append the virtualization argument to the line
NEW_GRUB_LINE="${GRUB_LINE%\"} $GRUB_PARAM\""
echo "Updating the GRUB_CMDLINE_LINUX_DEFAULT line in $GRUB_FILE:"
echo "  Old line: $GRUB_LINE"
echo "  New line: $NEW_GRUB_LINE"

# Update the GRUB_CMDLINE_LINUX_DEFAULT line in the file
sed -i "s|$GRUB_LINE|$NEW_GRUB_LINE|" "$GRUB_FILE"
echo "Successfully updated the GRUB_CMDLINE_LINUX_DEFAULT line in $GRUB_FILE."

# Update the GRUB configuration
update-grub || error_handler
echo "GRUB configuration updated successfully."

apt update
apt install -y qemu-kvm qemu-utils libvirt-daemon-system libvirt-clients virtinst virt-manager || error_handler

#Enable libvirtd
systemctl --now enable libvirtd || error_handler

# Add the user to the necessary groups
echo "Adding user $USR to the required groups..."
usermod -aG libvirt $USR
usermod -aG kvm $USR
usermod -aG disk $USR
# usermod -aG input $USR
# usermod -aG libvirt-qemu $USR
echo "User $USR has been added to the required groups."
# Apply the changes without reboot
#newgrp libvirt
#newgrp kvm
#newgrp disk


# Set Virsh to autostart whenever the system is rebooted
sudo virsh net-autostart default || error_handler

# Restarting the libvirtd service
systemctl restart libvirtd || error_handler

# Set proper permission for /dev/kvm
#chmod 666 /dev/kvm



# Extra checks  ####################################################
# Let's view our virsh network:
# virsh net-list

# #Run the following command to view the various components that should run in KVM:
# sudo virt-host-validate
# It is normal to have freezer FAIL and secure guest support WARN. Qemu related lines have to be green

# Check the service status:
# systemctl status libvirtd

#Check QEMU and Virsh versions:
#kvm --version
##Check that the KVM modules are loaded correctly.
#lsmod | grep kvm
#read -p "Press enter, libvirtd should be enabled now"


#lsmod | grep kvm should return:
#Sample results:
#dpro@smauggy:~$ lsmod | grep kvm
#kvm_intel             380928  0
#kvm                  1142784  1 kvm_intel
#read -p "Press enter to start"

#echo '##Cpu core count##'
#egrep -c '(vmx|svm)' /proc/cpuinfo

#echo 'Check if virtualisation is enable in bios  #Intel Cpu should read: Virtualization: VT-x'
#lscpu | grep Virtualization

# Check the service status:
# systemctl status libvirtd || error_handler








