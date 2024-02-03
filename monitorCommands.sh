#!/bin/bash

# Function to send report to the specified IP address
send_report() {
    local ip_address="$1"
    local report="$2"
    local command="$3"
    local timestamp="$4"

    # Construct JSON payload with additional data
    local json_payload='{"Report": "'"$report"'", "IP Address": "'"$ip_address"'", "Command": "'"$command"'", "Timestamp": "'"$timestamp"'"}'

    # Send report using curl with JSON payload
    curl -X POST -H "Content-Type: application/json" -d "$json_payload" http://"$ip_address"/api/command
}

# Main function to monitor command executions
monitor_commands() {
    # Start monitoring command executions using auditd
    sudo auditctl -a always,exit -F arch=b64 -S execve

    # Log file to store abnormal command executions
    log_file="/var/log/abnormal_commands.log"

    # Array to store abnormal commands
    declare -A abnormal_commands

    while true; do
        # Wait for the next audit event
        sudo auditctl -w /bin -p x -k monitor_binaries
        sudo auditctl -w /usr/bin -p x -k monitor_binaries
        sudo auditctl -w /usr/sbin -p x -k monitor_binaries
        sudo auditctl -w /sbin -p x -k monitor_binaries
        sudo auditctl -w /usr/local/bin -p x -k monitor_binaries
        sudo auditctl -w /etc/shadow -p rwxa -k monitor_etc_shadow
        sudo auditctl -w /etc/passwd -p rwxa -k monitor_etc_passwd
        sudo auditctl -w /etc/sudoers -p rwxa -k monitor_etc_sudoers
        sudo auditctl -w /bin/su -p x -k monitor_su

        # Get the latest executed command
        latest_command=$(ausearch -i -sc execve | tail -n 1 | awk -F'"' '{print $2}')
        timestamp=$(date +"%Y-%m-%d %T")

        # Check if the command is abnormal
        if [[ ! "$latest_command" =~ ^/bin/|^/usr/bin/|^/usr/sbin/|^/sbin/|^/usr/local/bin/|^/etc/shadow|^/etc/passwd|^/etc/sudoers|^/bin/su ]]; then
            # Log abnormal command execution
            echo "$timestamp - Abnormal command execution: $latest_command" >> "$log_file"

            # Count the number of times the command has been executed
            if [[ -n "${abnormal_commands[$latest_command]}" ]]; then
                abnormal_commands["$latest_command"]=$((abnormal_commands["$latest_command"] + 1))
            else
                abnormal_commands["$latest_command"]=1
            fi

            # Check if the command has been executed more than once
            if [[ ${abnormal_commands["$latest_command"]} -ge 2 ]]; then
                ip_addr=$(ifconfig | grep -oE 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -oE '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | tail -n 1)
                # Send report to the specified IP address with additional data
                send_report "$ip_addr" "Abnormal command detected: $latest_command" "$latest_command" "$timestamp"
                echo "There anomoly $latest_command"
                # Clear abnormal command count
                unset abnormal_commands["$latest_command"]
            fi
        fi

        # Sleep for 1 second before checking again
        sleep 1
    done
}

# Execute the main function
monitor_commands

