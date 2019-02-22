#!/bin/sh

# check if unzip exist
# shellcheck disable=SC1091
. /etc/os-release

echo "checking if unzip is installed ..."
if ! command -v unzip
then
  case "${ID}" in
    "alpine")
      apk add unzip > /dev/null 2>&1
      ;;
    "debian")
      apt-get update -y > /dev/null 2>&1
      apt-get install unzip -y > /dev/null 2>&1
      ;;
    *)
      echo "I don't know this distribution ..."
      exit 1
      ;;
  esac
fi

# Download rclone
wget https://github.com/ncw/rclone/releases/download/v1.45/rclone-v1.45-linux-386.zip -O rclone.zip > /dev/null 2>&1

# extract rclone to 'rclone' directory
mkdir -p rclone
unzip -j -d rclone rclone.zip > /dev/null 2>&1

# install rclone
mv rclone/rclone /usr/local/bin

# cleanup
rm -rf rclone rclone.zip
