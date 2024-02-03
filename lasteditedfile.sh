#!/bin/bash

log_file="/var/log/recently_edited_files.log"

time_frame=60

find / -type f -mmin -$time_frame -exec stat --format="%y %n" {} \; >> "$log_file"

