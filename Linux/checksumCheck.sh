#!/bin/bash

LOG_FILE="/var/log/checksum_log.txt"

declare -A important_files=(
    ["/etc/shadow"]="checksum1"
    ["/etc/passwd"]="checksum2"
    ["/etc/hosts"]="checksum3"
)

compare_checksum() {
    file="$1"
    expected_checksum="$2"
    current_checksum=$(md5sum "$file" | awk '{print $1}')

    if [ "$current_checksum" = "$expected_checksum" ]; then
        echo "Checksum for $file matches the expected checksum."
    else
        echo "Checksum for $file does not match the expected checksum."
    fi
}

while IFS= read -r line; do
    checksum=$(echo "$line" | awk '{print $1}')
    filename=$(echo "$line" | awk '{print $2}')
    time_checked=$(echo "$line" | awk '{print $3}')

    if [ -f "$filename" ]; then
        if [ "${important_files[$filename]}" = "$checksum" ]; then
            echo "File: $filename (Last checked: $time_checked)"
            compare_checksum "$filename" "$checksum"
        else
            echo "Checksum mismatch for $filename (Last checked: $time_checked)"
        fi
    else
        echo "File $filename not found."
    fi
done < "$LOG_FILE"

