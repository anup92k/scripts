#!/bin/bash

# This script use 'iwlist' to scan for
# wireless cells about the provided SSID.
#
# The result is rendered as a list of channels
# and as performance data :
#   "CELL24" for a 2,4 GHz cell
#   "CELL5"  for a 5   GHz cell
#
# Return state :
# OK
#   if iwlist run successfully
# UNKNOWN
#   if it fail (does not removed temp files)
#   check '/tmp/*wifichannel' files
#
# Argument :
# $1 :: Wireless interface
# $2 :: SSID
# exemple :
#   my_check_wifichannels.sh wlan0 My_SSID


IWLIST=$(which iwlist)

# Temporary files
IWLIST_RESULT="$(mktemp --suffix="wifichannel")"
PARSING_RESULT="$(mktemp --suffix="wifichannel")"
CHANNEL_LIST="$(mktemp --suffix="wifichannel")"
CHANNEL_PERFDATA="$(mktemp --suffix="wifichannel")"

function ssid_check {
	# $1 :: 'iwlist' command
	# $2 :: wireless interface
	# $3 :: SSID
	# sudo iwlist INTERFACE scanning essid MY_SSID
    sudo $1 $2 scanning essid $3 > $IWLIST_RESULT

    # if command failed, exit with 1
    if [ $? -ne 0 ] ; then
    	exit 1
    fi

    exit 0
}

function parsing_data {
    # ssid_check result in STDIN
    # output format "mac essid frq chn qual lvl enc"

    # Parsing method found on
    # https://stackoverflow.com/a/25395290/11699038
    # (modified)
    while IFS= read -r line; do
        ## test line contenst and parse as required
        [[ "$line" =~ Cell ]] && { cell=${line##*ll }; cell=${cell%% *}; }
        [[ "$line" =~ Address ]] && mac=${line##*ss: }
        [[ "$line" =~ \(Channel ]] && { chn=${line##*nel }; chn=${chn:0:$((${#chn}-1))}; }
        [[ "$line" =~ Frequen ]] && { frq=${line##*ncy:}; frq=${frq%% *}; }
        [[ "$line" =~ Quality ]] && { 
            qual=${line##*ity=}
            qual=${qual%% *}
            lvl=${line##*evel=}
            lvl=${lvl%% *}
        }
        [[ "$line" =~ Encrypt ]] && enc=${line##*key:}
        [[ "$line" =~ ESSID ]] && {
            essid=${line##*ID:}
            echo "$cell $mac $essid $frq $chn $qual $lvl $enc"  # output after ESSID
        }
    
    done < $1
}

function extract_data {
    # $1 :: parsing_data file
	
    while IFS= read -r line; do
        cell_channel=$(echo $line | awk {'print $5'})
        echo -n $cell_channel", " >> $CHANNEL_LIST

        # 2.4 GHz ( channel ∈ ];15] )
        if [ $cell_channel -le 14 ]; then
            channel_group="24"
        # 5 GHz ( channel ∈ [32;165] )
        elif [ "$cell_channel" -ge 32 ] && [ "$cell_channel" -le 165 ]; then
            channel_group="5"
        # error case : return "N-" followed by cell number
        else
            channel_group="N-$(echo $line | awk {'print $1'})"
        fi
        echo -n "CELL"$channel_group"="$cell_channel", " >> $CHANNEL_PERFDATA
    done < $1

    # Remove last ","
    sed -i '$ s/..$//' $CHANNEL_LIST
    sed -i '$ s/..$//' $CHANNEL_PERFDATA

    echo "Channels "$(cat $CHANNEL_LIST)"|"$(cat $CHANNEL_PERFDATA)
}

function remove_temp_files {
    for i in $@ ; do
        rm $i
    done
}

iwlist_result=$(ssid_check $IWLIST $1 $2)
if [ $? -ne 0 ] ; then
	echo "iwlist failed"
	exit 3
fi

parsing_data $IWLIST_RESULT | grep $2 > $PARSING_RESULT
script_result=$(extract_data $PARSING_RESULT)

remove_temp_files $IWLIST_RESULT $PARSING_RESULT $CHANNEL_LIST $CHANNEL_PERFDATA

echo $script_result

exit 0