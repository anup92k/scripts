#!/bin/bash

# Created by :        Anup92k
# Date (YYYY-MM-DD) : 2021-05-13
# Last update :       2021-05-15

# Purpose :
## Render Octolapse result images locally
## 
## 

# Metadata file
META_DATA_FILE="metadata.csv"
# Conversion parameters
FFMPEG_PARAM=(-c:v libx265 -crf 18 -vf "format=yuv420p" -tag:v hvc1)
# Change the value to "on" to see the debug 
_DEBUG="off"


# Debug function
function DEBUG(){
 [ "$_DEBUG" == "on" ] && $@
}

# Check if ffmpeg is installed
if [[ $(dpkg-query -W -f='${Status}' ffmpeg 2>/dev/null | grep -c "ok installed") -eq 0 ]]; then
  echo "Package ffmpeg not found"
  exit 1
fi

# Check if the metadata file exist
if [[ ! -f "$META_DATA_FILE" ]]; then
  echo "No MetaData file found in : $(pwd)"
  exit 2
fi

# Check if the metadata images really exist
IMG_LIST=$(cat $META_DATA_FILE | cut -d',' -f2)
for i in $IMG_LIST; do
  DEBUG echo "Testing $i"
  if [[ ! -f "$i" ]]; then
    echo "File $i provided in the metadata does not exist !"
    exit 3
  fi
done

# Store common part of the images names
COMMON_NAME=$(cat $META_DATA_FILE | cut -d',' -f2 | grep -zoP '\A(.*)(?=.*?\n\1)' | tr '\0' '\n')

DEBUG echo "###############"
DEBUG echo "$IMG_LIST"
DEBUG echo "###############"
DEBUG echo "Common part of file list : $COMMON_NAME"

# Initialize output name
OUTPUT_NAME=$COMMON_NAME

# Loop to remove multiple "0" at the end of the common name
while [[ "${OUTPUT_NAME: -1}" = "0" ]]; do
  OUTPUT_NAME=${OUTPUT_NAME%?}
  DEBUG echo "While loop --> Trimmed OUTPUT_NAME : $OUTPUT_NAME"
done

DEBUG echo "Trimmed common part of file list : $OUTPUT_NAME"

echo "#### FMPEG ####"

# The commented command does not work : process only 10 images on my tests.
# May be related to the max characters for the input list.
# ffmpeg -pattern_type glob -i "${COMMON_NAME}*.jpg" -c:v libx265 -crf 18 -vf "format=yuv420p" -tag:v hvc1 $OUTPUT_NAME

# Running ffmpeg !
ffmpeg -pattern_type glob -i "*.jpg" "${FFMPEG_PARAM[@]}" ${OUTPUT_NAME}.mp4
if [[ $? -eq 0 ]]; then
  echo "###############"
  echo "Timelapse done ! See ${OUTPUT_NAME}.mp4"
fi


