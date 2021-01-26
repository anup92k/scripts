#!/bin/bash

# Gotify parameters (if not using configuration file)
GOTIFY_URL="https://gotify.blablabla.mu"
GOTIFY_TOKEN="Az3rTy"
# Tag to see in log file
LOGGER_TITLE="power-notify"

# Configuration file
FILE_CONF="/etc/gotify-notify.conf"
# Get servername
SERVER_NAME=$(uname -n)

# Handling configuration file (if present)
if [[ -f "${FILE_CONF}" ]]; then
  GOTIFY_URL=$(grep "server-url=" $FILE_CONF | cut -d'=' -f2)
  GOTIFY_TOKEN=$(grep "access-token=" $FILE_CONF | cut -d'=' -f2)
fi

# Testing correct number of argument
if [ $# -ne 1 ]; then
  echo "Not argument provided, use option '-h' for help"
  logger -t $LOGGER_TITLE "Not argument provided"
  exit 1
fi

option=$1

case $option in
  up)
    GOTIFY_TITLE="⬆️ $SERVER_NAME started"
    GOTIFY_MESSAGE="System just boot up"
    ;;
  down)
    GOTIFY_TITLE="⬇️ $SERVER_NAME is shutting down"
    GOTIFY_MESSAGE="System is going to shutdown"
    ;;
  -h)
    echo  "Usage :"
    echo  "$(basename $0) [up|down|-h]"
    echo  "up : for booting up"
    echo  "down : for shuting down"
    echo  "-h : display this help"
    echo  ""
    exit 0
    ;;
  \?)
    echo "invalid $option argument, use option '-h' for help"
    logger -t $LOGGER_TITLE "invalid $option argument"
    exit 2
    ;;
esac

# Gotify Checks
## Do you have cURL ?
if [[ $(command -v curl >/dev/null 2>&1) ]]; then
  logger -t $LOGGER_TITLE "FATAL ERROR: This script require cURL !"
  exit 3
fi
# Test Gotify server connexion (health check)
curlHttpResult=$(curl "${GOTIFY_URL}/health?token=${GOTIFY_TOKEN}" --output /dev/null --silent --write-out %{http_code})
if [[ $? -ne 0 ]]; then
  logger -t $LOGGER_TITLE "FATAL ERROR: cURL health check command failed !"
  exit 4
fi
# Check HTTP return code ("200" is OK)
if [[ $curlHttpResult -ne 200 ]]; then
  logger -t $LOGGER_TITLE "FATAL ERROR: API call failed ! Return code is $curlHttpResult instead of 200."
  exit 5
fi


# Notify power state
curl "${GOTIFY_URL}/message?token=${GOTIFY_TOKEN}" \
     -F "title=${GOTIFY_TITLE}" \
     -F "message=${GOTIFY_MESSAGE}" \
     -F "priority=8" \
     --output /dev/null --silent

exit 0
