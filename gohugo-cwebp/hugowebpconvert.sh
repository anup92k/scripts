#!/bin/bash

# Created by :        Anup92k
# Date (YYYY-MM-DD) : 2021-05-04
# Last update :       2021-05-04

# Purpose :
## Convert images used in Hugo posts
## into WebP format and update thoses contents

# Hugo root path (where `content` and `static` are)
HUGO_ROOT="/my/root/path/to/hugo"

# Conversion parameters
CONVERT_PARAM="-m 6 -mt -quiet"

# Not using temp file because keeping them
# should be usefull
true > failed.txt
true > error.txt
true > toberemove.txt

while read line
do
  POST="${HUGO_ROOT}/$(echo $line | awk '{print $1}')"
  IMG="${HUGO_ROOT}/static$(echo $line | awk '{print $2}')"
  IMG_POST_LINK="$(echo $line | awk '{print $2}')"

  # Test if post really exist
  if [[ (-f "${POST}") ]]; then
    echo "ok" > /dev/null

    IMG_WEBP="${IMG%.*}.webp"

    # If webp file does not already exist
    # (case of same images used multiple time)
    if [[ ! -f "$IMG_WEBP" ]]; then
      CONVERT_PROGRAM="cwebp"
      ## GIF file should be converted using gif2webp
      if [ "$(file $IMG | cut -d':' -f2- | grep -c 'GIF')" -ne 0 ]; then
        CONVERT_PROGRAM="gif2webp"
      fi
      # Converting image to webp format
      $CONVERT_PROGRAM $CONVERT_PARAM $IMG -o $IMG_WEBP
    fi

    # Test if converted file exist
    if [[ -f $IMG_WEBP ]]; then
      # Store post webp content link
      IMG_WEBP_POST_LINK="${IMG_POST_LINK%.*}.webp"

      # Replace content
      sed -i "s@$IMG_POST_LINK@$IMG_WEBP_POST_LINK@g" $POST

      # Add link to remove old image
      echo $IMG >> toberemove.txt
    else
      echo "ERROR : cwebp for $IMG"
      echo -e "\t $IMG_WEBP unreachable"
      echo "$IMG" >> failed.txt
    fi

  else
    echo "ERROR : $POST or $IMG does not exist !"
    echo "$POST $IMG" >> error.txt
  fi

done < list.txt


# Remove old file
for oldfile in $(cat toberemove.txt | sort -u); do
  rm $oldfile
done

echo "#######################"
echo "# ERROR testing files #"
echo ""
cat error.txt
echo "#######################"
echo ""

echo "#######################"
echo "# FAIL convert files  #"
echo ""
cat failed.txt
echo "#######################"
echo ""