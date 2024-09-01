#!/bin/bash

# Author : Anup SUNGUM

# This script will parse `sensors` command result
# and compare it with the warning and critical value.
# To make is simple, the decimal are truncated !

# $1 :: line filter
# $2 :: matching n's value (when filter got multiple result)
# $3 :: arg position on line
# $4 :: Warning level
# $5 :: Critical level

# Sanity check
if [ "$#" -ne "5" ];then
    echo "UNKNOWN - Expected 5 argument but got $#"
    exit 3
fi

# Put args in vars
filter="$1"
matchValue="$2"
argPos="$3"
warnLevel="$4"
critLevel="$5"

# Get the value
value=$(sensors | grep -m $matchValue $filter | tail -n 1 | awk '{print $"'"$argPos"'"}' | tr -d '+°C' | cut -d '.' -f1)

# Above critical ?
result=$(echo $value - $critLevel | bc)
if [ "$result" -gt "0" ]; then
    echo "CRITICAL - ${value}°C is over ${critLevel}°C|temp=${value}°C"
    exit 2
fi

# Above warning ?
result=$(echo $value - $warnLevel | bc)
if [ "$result" -gt "0" ]; then
    echo "WARNING - ${value}°C is over ${warnLevel}°C|temp=${value}°C"
    exit 1
fi

# Not critical or warning => OK
echo "OK - ${value}°C|temp=${value}°C"
exit 0
