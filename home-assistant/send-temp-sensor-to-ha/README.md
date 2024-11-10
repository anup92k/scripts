## Send temperature sensor to HA

### Purpose

This script is made to send `sensors` data to Home Assistant

My goal is to buil a virtual thermostat in HA in order to cool my server using
an external fan plugged into a USB relay.

It use my [Nagios script](https://github.com/anup92k/scripts/tree/master/nagios-plugins/check_sensors)

### Usage

- Edit and put `my_send_temp_sensor_to_ha.conf` into `/etc/my_send_temp_sensor_to_ha.conf`
- Copy the script and try to run it manually

- Cron this script !