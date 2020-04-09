#!/usr/bin/env bash
#set -v

# Last boot time (%Y-%m-%d %H:%M)
BOOTDATE=$(date -r /proc/1 '+%F %R')
if [ $? -ne 0 ]; then
    echo "Unable to retrieve boot date"
    exit 3
fi

# Uptime in seconds
UPTIME=$(cat /proc/uptime | awk '{print $1}')
if [ $? -ne 0 ]; then
    echo "Unable to retrieve uptime"
    exit 3
fi

# Uptime Human Readable
UPTIMEHR=$(eval "echo $(date -ud "@$UPTIME" +'$((%s/3600/24)) days %H hours %M minutes')")
if [ $? -ne 0 ]; then
    echo "Unable to convert uptime"
    exit 3
fi

# Write result
echo "Server is up for $UPTIMEHR from $BOOTDATE|uptime=${UPTIME}s"
exit 0