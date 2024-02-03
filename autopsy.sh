#!/bin/bash

# Define paths
AUTOPSY_CLI="/path/to/autopsy-cli"
CASE_PATH="/path/to/case"
DISK_IMAGE="/path/to/disk_image.dd"
EXPORT_PATH="/path/to/exported_files"

# Create a new case
$AUTOPSY_CLI -c "$CASE_PATH" -d "$DISK_IMAGE" -e

# Run analysis
$AUTOPSY_CLI -c "$CASE_PATH" -m

# Export data
$AUTOPSY_CLI -c "$CASE_PATH" -e "$EXPORT_PATH"

echo "Data exported to $EXPORT_PATH"

