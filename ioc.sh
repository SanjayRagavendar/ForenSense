#!/bin/bash

LOG_DIR="/var/log/"
OUTPUT_DIR="/ForenSense"

mkdir -p "$OUTPUT_DIR"

analyze_logs_for_iocs() {
    echo "Analyzing logs for IOCs..."

    grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" $LOG_DIR/*.log | sort -u > "$OUTPUT_DIR/suspicious_ip_addresses.txt"

    grep -E -o "([a-zA-Z0-9]+\.){1,3}[a-zA-Z]{2,6}" $LOG_DIR/*.log | sort -u > "$OUTPUT_DIR/suspicious_domain_names.txt"

    grep -E -o "\b[0-9a-f]{32}\b" $LOG_DIR/*.log | sort -u > "$OUTPUT_DIR/suspicious_file_hashes.txt"

    echo "IOC analysis completed."
}


main() {
    analyze_logs_for_iocs
}

main
