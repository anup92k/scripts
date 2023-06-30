#!/usr/bin/env bash

# Stock arguments
file_to_check=$1
json_filter=$2
expected_value=$3

# Nagios output
OK=0
WARN=1
CRIT=2
UNK=3

# <-- Sanity checks
if [[ ! $(which jq) ]]; then
    echo "jq not found"
    exit $UNK
fi

if [[ $# -ne 3 ]]; then
    echo "3 arguments needed"
    exit $UNK
fi

if [[ ! -f $file_to_check ]]; then
    echo "File ${file_to_check} not found"
    exit $UNK
fi
# Sanity checks -->

# Run check
result=$(jq -r "${json_filter}" "${file_to_check}")

if [[ $result == "null" ]]; then
    echo "Filter ${json_filter} is empty"
    exit $WARN
fi

if [[ $result != $expected_value ]]; then
    echo "Unexpected value"
    exit $CRIT
fi

echo "OK"
exit $OK