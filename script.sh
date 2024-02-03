#!/bin/bash

# Log directory
LOG_DIR="/var/log/ForenSense"

# Log file names
TCPDUMP_LOG="$LOG_DIR/tcpdump_log_$(date +'%Y-%m-%d_%H-%M-%S').txt"
AUDIT_LOG="$LOG_DIR/audit_log_$(date +'%Y-%m-%d_%H-%M-%S').txt"
SYSTEM_INFO_LOG="$LOG_DIR/system_info_$(date +'%Y-%m-%d_%H-%M-%S').txt"

touch "$TCPDUMP_LOG"
touch "$AUDIT_LOG"
touch "$SYSTEM_INFO_LOG"

# Capture recent network traffic using tcpdump
echo "### Recent Network Traffic ###" > "$TCPDUMP_LOG"
tcpdump -i wlan0 -c 10000 -n -e -q -tttt -l 'not port 22' | \
while read -r line; do
    fields=($(echo "$line" | awk '{print $1, $3, $5, $6, $7, $8, $11, $12, $14, $16, $18, $20, $22, $24, $26, $28, $30, $32, $34, $36, $38, $40, $42, $44, $46, $48, $50, $52, $54, $56, $58, $60, $62, $64, $66, $68, $70, $72, $74, $76, $78, $80}'))
    formatted_data=$(IFS=,; echo "${fields[*]}")
    echo "$formatted_data" >> "$TCPDUMP_LOG"
done

# Log recently accessed files' metadata using auditd
echo "### Recently Accessed Files' Metadata ###" > "$AUDIT_LOG"
ausearch -i -ts recent >> "$AUDIT_LOG"  # Adjust time range as needed

# Log system information
echo "### System Information ###" > "$SYSTEM_INFO_LOG"
echo "Hostname: $(hostname)" >> "$SYSTEM_INFO_LOG"
echo "Date: $(date)" >> "$SYSTEM_INFO_LOG"
echo "Uptime: $(uptime)" >> "$SYSTEM_INFO_LOG"
echo "CPU Info:" >> "$SYSTEM_INFO_LOG"
echo "$(lscpu)" >> "$SYSTEM_INFO_LOG"
echo "Memory Info:" >> "$SYSTEM_INFO_LOG"
echo "$(free -h)" >> "$SYSTEM_INFO_LOG"
echo "Disk Usage:" >> "$SYSTEM_INFO_LOG"
echo "$(df -h)" >> "$SYSTEM_INFO_LOG"
echo "Running Processes:" >> "$SYSTEM_INFO_LOG"

# Define essential processes
essential_processes=("init" "systemd" "sshd" "cron" "rsyslog" "bash" "ssh")

# Display log file paths
echo "Logs saved to:"
echo "$TCPDUMP_LOG"
echo "$AUDIT_LOG"
echo "$SYSTEM_INFO_LOG"

# Send logs to API
API_URL="http://192.168.0.1:5000/api/logs"  
curl -X POST -F "tcpdump_log=@$TCPDUMP_LOG" -F "audit_log=@$AUDIT_LOG" -F "system_info_log=@$SYSTEM_INFO_LOG" "$API_URL"

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Terminate all connections
iptables -F
iptables -P INPUT DROP
iptables -P OUTPUT DROP
echo "All connections terminated."

# Kill non-essential processes
while read -r line; do
    process_name=$(echo "$line" | awk '{print $1}')
    if [[ ! " ${essential_processes[@]} " =~ " $process_name " ]]; then
        pid=$(echo "$line" | awk '{print $2}')
        echo "Killing non-essential process: $process_name (PID: $pid)"
        kill -9 "$pid"  # Kill the process by PID
    fi
done < <(ps aux | awk '{print $11, $2}' | tail -n +2)

