#!/bin/bash

send_report() {
    local ip_address="$1"
    local report="$2"
    local command="$3"
    local timestamp="$4"

    local json_payload='{"Report": "'"$report"'", "IP Address": "'"$ip_address"'", "Command": "'"$command"'", "Timestamp": "'"$timestamp"'"}'

    curl -X POST -H "Content-Type: application/json" -d "$json_payload" http://"$ip_address"/api/command
}

monitor_commands() {
    sudo auditctl -a always,exit -F arch=b64 -S execve

    log_file="/var/log/abnormal_commands.log"

    declare -A abnormal_commands

    while true; do
        sudo auditctl -w /bin -p x -k monitor_binaries
        sudo auditctl -w /usr/bin -p x -k monitor_binaries
        sudo auditctl -w /usr/sbin -p x -k monitor_binaries
        sudo auditctl -w /sbin -p x -k monitor_binaries
        sudo auditctl -w /usr/local/bin -p x -k monitor_binaries
        sudo auditctl -w /etc/shadow -p rwxa -k monitor_etc_shadow
        sudo auditctl -w /etc/passwd -p rwxa -k monitor_etc_passwd
        sudo auditctl -w /etc/sudoers -p rwxa -k monitor_etc_sudoers
        sudo auditctl -w /bin/su -p x -k monitor_su

        latest_command=$(ausearch -i -sc execve | tail -n 1 | awk -F'"' '{print $2}')
        timestamp=$(date +"%Y-%m-%d %T")

        if [[ ! "$latest_command" =~ ^/bin/|^/usr/bin/|^/usr/sbin/|^/sbin/|^/usr/local/bin/|^/etc/shadow|^/etc/passwd|^/etc/sudoers|^/bin/su ]]; then
            echo "$timestamp - Abnormal command execution: $latest_command" >> "$log_file"

            if [[ -n "${abnormal_commands[$latest_command]}" ]]; then
                abnormal_commands["$latest_command"]=$((abnormal_commands["$latest_command"] + 1))
            else
                abnormal_commands["$latest_command"]=1
            fi

            if [[ ${abnormal_commands["$latest_command"]} -ge 2 ]]; then
                ip_addr=$(ifconfig | grep -oE 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -oE '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | tail -n 1)
                send_report "$ip_addr" "Abnormal command detected: $latest_command" "$latest_command" "$timestamp"
                echo "There anomoly $latest_command"
                unset abnormal_commands["$latest_command"]
            fi
        fi

        sleep 1
    done
}

monitor_commands

