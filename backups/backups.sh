#!/bin/bash

# Server "Tapion" backup
/volume1/BackupStorage/backup.sh \
-S Tapion \
-H tapion.konatz.dbz \
-b "/volume1/BackupStorage" \
-d "/etc,/home/nagios,/opt,/root,/usr/lib,/usr/local,/var/lib,/var/log,/var/www"

# Server "Bubbles" backup
/volume1/BackupStorage/backup.sh \
-S Bubbles \
-H 192.168.92.17 \
-b "/volume1/BackupStorage" \
-d "/etc,/home/homeassistant,/home/nagios,/opt,/root,/srv/esphome/config,/usr/lib,/usr/local,/var/lib,/var/log,/var/www"
