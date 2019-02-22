#!/bin/sh

# Download rclone
wget https://github.com/ncw/rclone/releases/download/v1.45/rclone-v1.45-linux-386.zip -O rclone.zip > /dev/null 2>&1

# extract rclone to 'rclone' directory
mkdir -p rclone
unzip -j -d rclone rclone.zip > /dev/null 2>&1

# install rclone
mv rclone/rclone /usr/local/bin

# cleanup
rm -rf rclone rclone.zip
