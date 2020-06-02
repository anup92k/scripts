#!/bin/bash
export LANG=en_US.UTF-8

# Gotify parameters
GOTIFY_URL="https://gotify.blablabla.mu"
GOTIFY_TOKEN="Az3rTy" # Your token here

# Handling options
while getopts "S:H:b:d:h" option
do
    case $option in
        S)
            serverName=$OPTARG
            ;;
        H)
            serverIP=$OPTARG
            ;;
        b)
            backupStorage=$OPTARG
            ;;
        d)
            serverDirectory=$OPTARG
            ;;
        h)
            echo    "Usage :"
            echo -n "$(basename $0) "
            echo -n "-S [Server Name] "
            echo -n "-H [Hostname or IP address] "
            echo -n "-b [Backup Storage] "
            echo -n "-d [Directories to Save] "
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

# Testing correct number of argument
if [ $# -ne 8 ]; then
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
GOTIFY_TITLE="🔄 $serverName Rsync"


currentDate=$(date +%F)
backupDirectory="$backupStorage/$serverName/backup"

mkdir -p $backupDirectory
if [ $? -ne 0 ]; then
  message="Error making backup."
  message+="Cannot create directory $backupDirectory"
  curl "${GOTIFY_URL}/message?token=${GOTIFY_TOKEN}" \
       -F "title=${GOTIFY_TITLE}" \
       -F "message=${message}" \
       -F "priority=8" \
       --output /dev/null --silent
    exit 5
fi


# Remove old backup log
rm -f $backupDirectory/backup-*.txt

# Notify Rsync start
message="▶️ Started"
curl "${GOTIFY_URL}/message?token=${GOTIFY_TOKEN}" \
     -F "title=${GOTIFY_TITLE}" \
     -F "message=${message}" \
     -F "priority=8" \
     --output /dev/null --silent


# Rsync (￢‿￢ )
rsync --archive --stats --human-readable --relative --delete -e ssh \
      root@$serverIP:{$serverDirectory} $backupDirectory | tee $backupDirectory/backup-$currentDate.txt


# Notify finished with Rsync log
message="$(echo "☑️ Finished"; tail -n 14 $backupDirectory/backup-$currentDate.txt)"
curl "${GOTIFY_URL}/message?token=${GOTIFY_TOKEN}" \
     -F "title=${GOTIFY_TITLE}" \
     -F "message=${message}" \
     -F "priority=8" \
     --output /dev/null --silent


exit 0
