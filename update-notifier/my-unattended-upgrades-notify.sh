#!/bin/bash

# Send Gotify notifications about
# ubuntu pending updates

# Gotify parameters (if not using configuration file)
GOTIFY_URL="https://gotify.blablabla.mu"
GOTIFY_TOKEN="Az3rTy"
# Tag to see in log file
LOGGER_TITLE="my-unattended-upgrades-notify"

# Configuration file
FILE_CONF="/etc/gotify-notify.conf"

# Handling configuration file (if present)
if [[ -f "${FILE_CONF}" ]]; then
  GOTIFY_URL=$(grep "server-url=" $FILE_CONF | cut -d'=' -f2)
  GOTIFY_TOKEN=$(grep "access-token=" $FILE_CONF | cut -d'=' -f2)
fi

# Server info
server_name=$(uname -n)
updates_available=$(sudo apt update | grep packages | cat -d "." -f1)
release=$(lsb_release -d | cut -d$'\t' -f2)


# Handle no updates
if [[ -z "$updates_available" ]]; then
  updates_available="No updates available."
fi


# Processing notification content
## Title
title="$server_name ($release)"

## Message
message="$updates_available"

# Finally cURLing !
curl_http_result=$(curl "${GOTIFY_URL}/message?token=${GOTIFY_TOKEN}" -F "title=${title}" -F "message=${message}" -F "priority=5" --output /dev/null --silent --write-out %{http_code})
if [[ $? -ne 0 ]]; then
  logger -t $LOGGER_TITLE "FATAL ERROR: cURL command failed !"
  exit 1
fi

# Check HTTP return code ("200" is OK)
if [[ $curl_http_result -ne 200 ]]; then
  logger -t $LOGGER_TITLE "FATAL ERROR: API call failed ! Return code is $curl_http_result instead of 200."
  exit 2
fi

logger -t $LOGGER_TITLE "Notification sent"

exit 0
