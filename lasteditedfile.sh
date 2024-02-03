#!/bin/bash

# Log file to store recently edited files
log_file="/var/log/recently_edited_files.log"

# Time frame in minutes to consider for recently edited files
time_frame=60

# Find files modified within the specified time frame and log them
find / -type f -mmin -$time_frame -exec stat --format="%y %n" {} \; >> "$log_file"

