#!/bin/bash

# syslog.sh

# Set the log file path
LOG_DIR="$SH_PATH/LOGS"
LOG_FILE="$LOG_DIR/system.log"

# System Information
echo "System Information" | tee -a "$LOG_FILE"
echo "  Operating System              $(lsb_release -d | cut -f2)" | tee -a "$LOG_FILE"
echo "  Kernel                        $(uname -r)" | tee -a "$LOG_FILE"
echo "  Model                         $(dmidecode -s system-product-name)" | tee -a "$LOG_FILE"
echo "  Motherboard                   $(dmidecode -s baseboard-product-name)" | tee -a "$LOG_FILE"
echo "  BIOS                          $(dmidecode -s bios-version)" | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

# CPU Information
echo "CPU Information" | tee -a "$LOG_FILE"
echo "  Name                          $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)" | tee -a "$LOG_FILE"
echo "  Topology                      $(lscpu | grep 'CPU(s)' | head -n1 | cut -d':' -f2 | xargs)" | tee -a "$LOG_FILE"
echo "  Identifier                    $(lscpu | grep 'Model' | cut -d':' -f2 | xargs)" | tee -a "$LOG_FILE"
echo "  Base Frequency                $(lscpu | grep 'CPU MHz' | cut -d':' -f2 | xargs) GHz" | tee -a "$LOG_FILE"
echo "  L1 Instruction Cache          $(lscpu | grep 'L1i' | cut -d':' -f2 | xargs)" | tee -a "$LOG_FILE"
echo "  L1 Data Cache                 $(lscpu | grep 'L1d' | cut -d':' -f2 | xargs)" | tee -a "$LOG_FILE"
echo "  L2 Cache                      $(lscpu | grep 'L2' | cut -d':' -f2 | xargs)" | tee -a "$LOG_FILE"
echo "  L3 Cache                      $(lscpu | grep 'L3' | cut -d':' -f2 | xargs)" | tee -a "$LOG_FILE"
echo "  Instruction Sets              $(lscpu | grep 'Flags' | cut -d':' -f2 | xargs)" | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

# Memory Information
echo "Memory Information" | tee -a "$LOG_FILE"
echo "  Size                          $(free -h | grep Mem | awk '{print $2}')" | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"
