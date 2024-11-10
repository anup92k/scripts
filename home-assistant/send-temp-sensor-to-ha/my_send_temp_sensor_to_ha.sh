#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Script to send MotherBoard temp data to HomeAssistant
# ------------------------------------------------------------------------------

# This script is using
# https://github.com/anup92k/scripts/tree/master/nagios-plugins/check_sensors
# to get the datas

# Configuration file
MY_CONFIG_FILE="/etc/my_send_temp_sensor_to_ha.conf"

HA_API_SUBPATH="api/states"

# Handling configuration file (must be present)
if [[ -f "${MY_CONFIG_FILE}" ]]; then
    # Load config file
    . ${MY_CONFIG_FILE}
else
    echo "Cannot access config file on : ${MY_CONFIG_FILE}"
    exit 1
fi

# Get sensor value
sensorValue="0"
checkReturnValue="3"
tempValue="none"

sensorValue=$($CHECK_SENSORS_SCRIPT $CHECK_SENSORS_ARGS)
checkReturnValue=$?

# If return value is not 3, get correct result
if [[ $checkReturnValue -ne "3" ]]; then
    # Get result from perfdata
    tempValue=$(echo $sensorValue | cut -d '|' -f2 | cut -d '=' -f2 | tr -d '°C')
fi

# Send data to HA
curl -s -H "Authorization: Bearer ${HA_TOKEN}" -X POST ${HA_BASE_URL}/${HA_API_SUBPATH}/sensor.${SENSOR_NAME} -d \
     "{\"state\": \"${tempValue}\",   \"attributes\": {\"device_class\":\"temperature\",\"unit_of_measurement\": \"°C\"}}" 
curlReturnValue=$?

if [[ $curlReturnValue -ne "0" ]]; then
    echo "cURL failed : code $curlReturnValue"
    exit 2
fi

exit 0
