#!/usr/bin/env bash
# Pull new images based on Docker Compose files

# Directory containing folders of all Docker Compose files
DC_FOLDERS="/root/docker"
# Gotify parameters
GOTIFY_URL="https://gotify.blablabla.mu"
GOTIFY_TOKEN="Az3rTy" # Your token here
# Gotify messages title
GOTIFY_TITLE="🐳 Updates"

# Configuration file
FILE_CONF="/etc/gotify-notify.conf"

# Handling configuration file (if present)
if [[ -f "${FILE_CONF}" ]]; then
  GOTIFY_URL=$(grep "server-url=" $FILE_CONF | cut -d'=' -f2)
  GOTIFY_TOKEN=$(grep "access-token=" $FILE_CONF | cut -d'=' -f2)
fi

# Gotify Checks
## Do you have cURL ?
if [[ $(command -v curl >/dev/null 2>&1) ]]; then
  echo "FATAL ERROR: This script require cURL !"
  exit 1
fi
# Test Gotify server connexion (health check)
curlHttpResult=$(curl "${GOTIFY_URL}/health?token=${GOTIFY_TOKEN}" --output /dev/null --silent --write-out %{http_code})
if [[ $? -ne 0 ]]; then
  echo "FATAL ERROR: cURL health check command failed !"
  exit 2
fi
# Check HTTP return code ("200" is OK)
if [[ $curlHttpResult -ne 200 ]]; then
  echo -e "FATAL ERROR: API call failed ! Return code is $curlHttpResult instead of 200."
  exit 3
fi


# Temp out file
outputFile="$(mktemp)"

# Allow working only into the current folder
# if any argument is used to run the script
if [[ $# -ne 0 ]]; then
  DC_FOLDERS="."
fi

# Find Docker Compose files
composeConfig=$(find $DC_FOLDERS -type f -name "docker-compose.yml" -o -name "docker-compose.yaml" | xargs echo)
if [[ -z "$composeConfig" ]]; then
  message="No Docker Compose files found in $DC_FOLDERS"
  curl "${GOTIFY_URL}/message?token=${GOTIFY_TOKEN}" \
       -F "title=${GOTIFY_TITLE}" \
       -F "message=${message}" \
       -F "priority=8" \
       --output /dev/null --silent
  exit 4
fi


# Processing updates
message="▶️ Starting"
curl "${GOTIFY_URL}/message?token=${GOTIFY_TOKEN}" \
     -F "title=${GOTIFY_TITLE}" \
     -F "message=${message}" \
     -F "priority=8" \
     --output /dev/null --silent

for i in $composeConfig; do
  # Go to folder location
  cd $(dirname -- $i)
  # Pull current Docker Compose images
  docker-compose pull --quiet
  # Builds, (re)creates, starts containers
  ## Run containers in the background
  ## Remove containers for services not defined in the Compose file.
  ## Pull without printing progress information
  docker-compose up --detach --remove-orphans --quiet-pull
done

# Remove all dangling images
## Do not prompt for confirmation
docker image prune --force | tee $outputFile

# Sending result to Gotify
curl "${GOTIFY_URL}/message?token=${GOTIFY_TOKEN}" \
     -F "title=${GOTIFY_TITLE}" \
     -F "message=$(cat $outputFile)" \
     -F "priority=8" \
     --output /dev/null --silent

rm $outputFile