#!/bin/bash

# Define the log file path
LOG_FILE="/path/to/checksum_log.txt"

# Define important files and their checksums
declare -A important_files=(
    ["/path/to/file1.txt"]="checksum1"
    ["/path/to/file2.txt"]="checksum2"
    ["/path/to/file3.txt"]="checksum3"
    # Add more files as needed
)

# Function to compare checksums
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

# Iterate through important files and check their checksums
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

