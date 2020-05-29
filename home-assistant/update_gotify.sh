#!/bin/bash

# 1. Upgrade HA
# 2. Check HA config
# 3. Restart HA


HADIR="/home/homeassistant/.homeassistant"
HAVENV="/srv/homeassistant/bin/activate"
GOTIFYURL="https://gotify.blablabla.mu"
GOTIFYTOKEN="Az3rTy" # Your token here

TITLE="HA Update"

DATE=$(date +%F_%H-%M)
source $HAVENV

# Do you have cURL ?
if [[ $(command -v curl >/dev/null 2>&1) ]]; then
  echo "FATAL ERROR: This script require cURL !"
  exit 1
fi

# Do you have jq ?
if [[ $(command -v jq >/dev/null 2>&1) ]]; then
  echo "FATAL ERROR: This script require jQuery (jq) !"
  exit 1
fi

# Test Gotify server connexion (health check)
curl_http_result=$(curl "${GOTIFYURL}/health?token=${GOTIFYTOKEN}" --output /dev/null --silent --write-out %{http_code})
if [[ $? -ne 0 ]]; then
  echo "FATAL ERROR: cURL health check command failed !"
  exit 2
fi
# Check HTTP return code ("200" is OK)
if [[ $curl_http_result -ne 200 ]]; then
  echo -e "FATAL ERROR: API call failed ! Return code is $curl_http_result instead of 200."
  exit 3
fi


# Remove old update log file
find $HADIR -type f -name "*-update-log.txt" -exec rm -f '{}' \;


# 1. Upgrade HA

MESSAGE="▶️ Started from $(hass --version) to $(curl --silent -L https://pypi.python.org/pypi/homeassistant/json | jq .info.version | sed 's/\"//g')"
curl "${GOTIFYURL}/message?token=${GOTIFYTOKEN}" -F "title=${TITLE}" -F "message=${MESSAGE}" -F "priority=8"

echo "----------------- HA Update -----------------" | tee $HADIR/$DATE-update-log.txt

set -o pipefail # Get non-zero status of the pipeline if it append
pip3 install --upgrade homeassistant | tee --append $HADIR/$DATE-update-log.txt
if [ $? -ne 0 ]; then
  MESSAGE="❌ Failed ! Please refer back to log file $DATE-update-log.txt"
  curl "${GOTIFYURL}/message?token=${GOTIFYTOKEN}" -F "title=${TITLE}" -F "message=${MESSAGE}" -F "priority=10"
  exit 4
fi
set +o pipefail


MESSAGE="✅ Finished"
curl "${GOTIFYURL}/message?token=${GOTIFYTOKEN}" -F "title=${TITLE}" -F "message=${MESSAGE}" -F "priority=8"


echo "---------------------------------------------" | tee --append $HADIR/$DATE-update-log.txt
echo "---------------------------------------------" | tee --append $HADIR/$DATE-update-log.txt


# 2. Check HA config

set -o pipefail
hass --script check_config | tee --append $HADIR/$DATE-update-log.txt
if [ $? -ne 0 ]; then
  MESSAGE="❌ Checking configuration failed ! Please refer back to log file $DATE-update-log.txt"
  curl "${GOTIFYURL}/message?token=${GOTIFYTOKEN}" -F "title=${TITLE}" -F "message=${MESSAGE}" -F "priority=10"
  exit 5
fi
set +o pipefail

MESSAGE="✅ Checking config OK"
curl "${GOTIFYURL}/message?token=${GOTIFYTOKEN}" -F "title=${TITLE}" -F "message=${MESSAGE}" -F "priority=8"


echo "---------------------------------------------" | tee --append $HADIR/$DATE-update-log.txt
echo "---------------------------------------------" | tee --append $HADIR/$DATE-update-log.txt


# 3. Restart HA

MESSAGE="🔄 Restarting Home Assistant"
curl "${GOTIFYURL}/message?token=${GOTIFYTOKEN}" -F "title=${TITLE}" -F "message=${MESSAGE}" -F "priority=8"



set -o pipefail
sudo systemctl restart home-assistant@homeassistant.service | tee --append $HADIR/$DATE-update-log.txt
if [ $? -ne 0 ]; then
  MESSAGE="❌ Errors while restarting ! Please refer back to log file $DATE-update-log.txt"
  curl "${GOTIFYURL}/message?token=${GOTIFYTOKEN}" -F "title=${TITLE}" -F "message=${MESSAGE}" -F "priority=10"
  exit 6
fi
set +o pipefail

# Not needed since I have an HA automation that already notified when HA (re)start :
#MESSAGE="☑️ Finished update to $(hass --version)"
#curl "${GOTIFYURL}/message?token=${GOTIFYTOKEN}" -F "title=${TITLE}" -F "message=${MESSAGE}" -F "priority=8"
