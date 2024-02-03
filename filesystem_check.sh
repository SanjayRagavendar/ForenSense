#!/bin/bash

# Run fsck on the specified file system
check_filesystem() {
    filesystem="$1"
    
    echo "Checking file system: $filesystem"
    
    # Run fsck with appropriate options
    fsck -n "$filesystem"
    
    # Check the exit status of fsck
    if [ $? -eq 0 ]; then
        echo "No file system errors detected."
    else
        echo "File system errors found. Please review and fix manually."
    fi
}

# Example usage: Check the root file system ("/")
check_filesystem "/"
