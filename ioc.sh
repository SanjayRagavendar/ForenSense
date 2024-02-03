#!/bin/bash

# Define variables
LOG_DIR="/var/log/"
OUTPUT_DIR="/ForenSense"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Function to analyze logs for IOCs
analyze_logs_for_iocs() {
    echo "Analyzing logs for IOCs..."

    # Look for suspicious IP addresses in network logs
    grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" $LOG_DIR/*.log | sort -u > "$OUTPUT_DIR/suspicious_ip_addresses.txt"

    # Look for suspicious domain names in DNS logs
    grep -E -o "([a-zA-Z0-9]+\.){1,3}[a-zA-Z]{2,6}" $LOG_DIR/*.log | sort -u > "$OUTPUT_DIR/suspicious_domain_names.txt"

    # Look for file hashes in system logs
    grep -E -o "\b[0-9a-f]{32}\b" $LOG_DIR/*.log | sort -u > "$OUTPUT_DIR/suspicious_file_hashes.txt"

    echo "IOC analysis completed."
}


# Main function
main() {
    analyze_logs_for_iocs
}

# Execute main function
main
