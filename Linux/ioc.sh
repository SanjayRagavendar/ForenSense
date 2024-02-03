#!/bin/bash

LOG_DIR="/var/log/"
OUTPUT_DIR="/ForenSense"

mkdir -p "$OUTPUT_DIR"

analyze_logs_for_iocs() {
    echo "Analyzing logs for IOCs..."

    suspicious_ips=$(grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" $LOG_DIR/*.log | sort -u)
    suspicious_domains=$(grep -E -o "([a-zA-Z0-9]+\.){1,3}[a-zA-Z]{2,6}" $LOG_DIR/*.log | sort -u)
    suspicious_hashes=$(grep -E -o "\b[0-9a-f]{32}\b" $LOG_DIR/*.log | sort -u)

    if [ -n "$suspicious_ips" ] || [ -n "$suspicious_domains" ] || [ -n "$suspicious_hashes" ]; then
        echo "Found suspicious entities. Running additional script..."
        ./checksumCheck.sh
        ./script.sh
        ./autopsy.sh
        
        else
        echo "No suspicious entities found."
    fi
}

main() {
    analyze_logs_for_iocs

}

main
