#!/bin/bash

DISK_IMAGE="/var/images/image$(date +'%Y-%m-%d_%H-%M-%S').dd"
CASE_PATH="/var/case/case$(date +'%Y-%m-%d_%H-%M-%S')"
EXPORT_PATH="/var/autopsy/export$(date +'%Y-%m-%d_%H-%M-%S')"

mkdir -p "$CASE_PATH"
mkdir -p "$EXPORT_PATH"

ftkimager /dev/sda1 "$DISK_IMAGE" --e01 --compress 9 --verify
autopsy -c "$CASE_PATH" -d "$DISK_IMAGE" -e
autopsy -c "$CASE_PATH" -m
autopsy -c "$CASE_PATH" -e "$EXPORT_PATH"

echo "Data exported to $EXPORT_PATH"
