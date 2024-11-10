#!/bin/bash

# 1. Upgrade HA
# 2. Check HA config
# 3. Restart HA


DATE=$(date +%F_%H-%M)
HADIR="/home/homeassistant/.homeassistant"
NOTIFY=$(which telegram-notify)
source /srv/homeassistant/bin/activate


# Do you have jq ?
if [[ $(command -v jq >/dev/null 2>&1) ]]; then
  echo "FATAL ERROR: This script require jQuery (jq) !"
  exit 1
fi

if [[ -z $NOTIFY ]]; then
    echo "Telegram Notification (telegram-notify) not available"
    exit 1
fi

# Make telegram notification on the HA group
NOTIFY="$NOTIFY --config $HADIR/.telegram-notify.conf"

# Remove old update log file
find $HADIR -type f -name "*-update-log.txt" -exec rm -f '{}' \;


# 1. Upgrade HA

$NOTIFY --icon 25B6 --text "Update started from $(hass --version) to $(curl --silent -L https://pypi.python.org/pypi/homeassistant/json | jq .info.version | sed 's/\"//g')"
echo "----------------- HA Update -----------------" | tee $HADIR/$DATE-update-log.txt

set -o pipefail # Get non-zero status of the pipeline if it append
pip3 install --upgrade homeassistant | tee --append $HADIR/$DATE-update-log.txt
if [ $? -ne 0 ]; then
    $NOTIFY --error --title "Update failed !" --text "Please refer back to log file" --document "$HADIR/$DATE-update-log.txt"
    exit 2
fi
set +o pipefail

$NOTIFY --success --text "Update finished"

echo "---------------------------------------------" | tee --append $HADIR/$DATE-update-log.txt
echo "---------------------------------------------" | tee --append $HADIR/$DATE-update-log.txt


# 2. Check HA config

set -o pipefail
hass --script check_config | tee --append $HADIR/$DATE-update-log.txt
if [ $? -ne 0 ]; then
    $NOTIFY --error --title "Checking configuration failed !" --text "Please refer back to log file" --document "$HADIR/$DATE-update-log.txt"
    exit 3
fi
set +o pipefail

$NOTIFY --success --text "Checking config OK"

echo "---------------------------------------------" | tee --append $HADIR/$DATE-update-log.txt
echo "---------------------------------------------" | tee --append $HADIR/$DATE-update-log.txt


# 3. Restart HA

$NOTIFY --icon 1F504 --text "Restarting Home Assistant"
set -o pipefail
sudo systemctl restart home-assistant@homeassistant.service | tee --append $HADIR/$DATE-update-log.txt
if [ $? -ne 0 ]; then
    $NOTIFY --error --title "Errors while restarting !" --text "Please refer back to log file" --document "$HADIR/$DATE-update-log.txt"
    exit 3
fi
set +o pipefail

# Not needed since an HA automation already notified HA (re)start
# $NOTIFY --success --text "Update to $(hass --version) finished" --document "$HADIR/$DATE-update-log.txt"

