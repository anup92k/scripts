#!/bin/bash

# NMAP scanning in order to display
# how many equipements are connected
# to the network

# Limitations :
# The regex does not validate
# completely the IP address format
# IP address such as 333.444.555.666
# will be accepted but CIDR mask must
# stay beetween 0 and 32

function call_for_help {
	echo -e "usage:\t $(basename $0)\t <network/CIDR>"
	echo -e "exemple: $(basename $0) 192.168.1.0/24"
	exit 0
}

function nmap_check {
	# Call : nmap network
	# This function only return result (last line)
	functioncommand=$($1 -sP -n $2 | tail -n 1)
	
	# if command failed, exit with 1
	if [ $? -ne 0 ] ; then
		exit 1
	fi
	
	echo $functioncommand
	exit 0
}


NMAP=$(which nmap)

# Continue if only one argument is provided
if [ $# -ne 1 ] ; then
	call_for_help
	exit 4
fi

# Check
if [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/([0-9]|[1-2][0-9]|3[0-2])$ ]]; then
	NETWORK_TESTED=$1
else
	call_for_help
	exit 4
fi

# Call Nmap
NMAP_RESULT=$(nmap_check $NMAP $NETWORK_TESTED)

if [ $? -ne 0 ] ; then
	echo "NMAP Failed"
	exit 3
fi

## Debug output
#echo $NMAP_RESULT

# Parsing info
# hosts up

HOST_UP=$(echo $NMAP_RESULT | cut -d'(' -f2 | cut -d')' -f1 | awk {'print $1'})
NMAP_DURATION=$(echo $NMAP_RESULT | rev |  awk {'print $1" "$2'} | rev | awk {'print $1'})

## Debug output
#echo $HOST_UP
## Debug output
#echo $NMAP_DURATION


echo -n "$HOST_UP hosts on $NETWORK_TESTED"
echo -n "|"
echo "hosts=${HOST_UP} scantime=${NMAP_DURATION}s"

exit 0
