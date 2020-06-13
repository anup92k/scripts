#!/bin/bash
export LANG=en_US.UTF-8

# Gotify parameters
GOTIFY_URL="https://gotify.blablabla.mu"
GOTIFY_TOKEN="Az3rTy" # Your token here

# Handling options
while getopts "S:b:h" option
do
    case $option in
        S)
            serverName=$OPTARG
            ;;
        b)
            backupStorage=$OPTARG
            ;;
        h)
            echo    "Usage :"
            echo -n "$(basename $0) "
            echo -n "-S [Server Name] "
            echo -n "-b [Backup Storage] "
            echo    ""
            exit 0
            ;;
        :)
            echo "Argument needed for $OPTARG"
            exit 2
            ;;
        \?)
            echo "$OPTARG : invalid option"
            exit 3
            ;;
    esac
done


backupDirectory="$backupStorage/$serverName/backup"
snapshotDirectory="$backupStorage/$serverName/snapshot"

# Testing correct number of argument
if [ $# -ne 4 ]; then
    echo "Not right number of argument"
    echo "Use option '-h' for help"
    exit 1
fi


# Gotify Checks
## Do you have cURL ?
if [[ $(command -v curl >/dev/null 2>&1) ]]; then
  echo "FATAL ERROR: This script require cURL !"
  exit 2
fi
# Test Gotify server connexion (health check)
curlHttpResult=$(curl "${GOTIFY_URL}/health?token=${GOTIFY_TOKEN}" --output /dev/null --silent --write-out %{http_code})
if [[ $? -ne 0 ]]; then
  echo "FATAL ERROR: cURL health check command failed !"
  exit 3
fi
# Check HTTP return code ("200" is OK)
if [[ $curlHttpResult -ne 200 ]]; then
  echo -e "FATAL ERROR: API call failed ! Return code is $curlHttpResult instead of 200."
  exit 4
fi

# Gotify messages title
GOTIFY_TITLE="💾 $serverName Snapshot"

# Test if the backup directory exist
if [ ! -d $backupDirectory ]; then
  message="❌ Directory $backupDirectory does not exist"
  curl "${GOTIFY_URL}/message?token=${GOTIFY_TOKEN}" \
       -F "title=${GOTIFY_TITLE}" \
       -F "message=${message}" \
       -F "priority=8" \
       --output /dev/null --silent
  exit 4
fi

# Find backup stats file (stop at first result : should be only one)
backupFile=$(find $backupDirectory -type f -name backup-*.txt -print -quit)

# Test if the backup file exist
if [ -z "$backupFile" ]; then
  message="❌ Backup file in $backupDirectory does not exist"
  curl "${GOTIFY_URL}/message?token=${GOTIFY_TOKEN}" \
       -F "title=${GOTIFY_TITLE}" \
       -F "message=${message}" \
       -F "priority=8" \
       --output /dev/null --silent
  exit 5
fi

# Get the date of the backup (written in the file name)
backupDate=$(basename $backupFile | cut -d'-' -f2- | cut -d'.' -f1)

# Notify snapshot start
message="▶️ Making snapshot of $backupDate backup"
curl "${GOTIFY_URL}/message?token=${GOTIFY_TOKEN}" \
     -F "title=${GOTIFY_TITLE}" \
     -F "message=${message}" \
     -F "priority=8" \
     --output /dev/null --silent

# Making snapshot
mkdir -p $snapshotDirectory
cd $backupDirectory
tar --warning='no-file-ignored' -czf $snapshotDirectory/snapshot-$backupDate.tgz *
if [ $? -ne 0 ]; then
  message="❌ Tar task for $backupDirectory of $backupDate failed"
  curl "${GOTIFY_URL}/message?token=${GOTIFY_TOKEN}" \
       -F "title=${GOTIFY_TITLE}" \
       -F "message=${message}" \
       -F "priority=8" \
       --output /dev/null --silent
  exit 6
fi

tarFileSize=$(du -h $snapshotDirectory/snapshot-$backupDate.tgz | awk '{print $1}')

# Telegram finished notification with rsync stats as attachement
$NOTIFY --success --text "$serverName snapshot of $backupDate completed with a file of $tarFileSize"
message="☑️ Finished snapshot of $backupDate with a file of $tarFileSize"
curl "${GOTIFY_URL}/message?token=${GOTIFY_TOKEN}" \
     -F "title=${GOTIFY_TITLE}" \
     -F "message=${message}" \
     -F "priority=8" \
     --output /dev/null --silent

# Delete backup older than 3 months
find $snapshotDirectory -mtime +90 -type f -exec rm -f '{}' \;

