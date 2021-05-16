## Backup scripts

This series of scripts are made to Rsync specified 
folder with Rsync. It send notification using 
[Gotify](https://gotify.net) with cURL.

In scripts whose names are singular, 
don't forget to update thoses variables :

* `GOTIFY_URL` (unnecessary if using configuration file : see below)
* `GOTIFY_TOKEN` (unnecessary if using configuration file : see below)

I run those scripts with scheduled tasks on my 
Synology NAS. This is why you can see some weird stuff 
like `export LANG=en_US.UTF-8` (to send emojis correctly) 
and the path `/volume1`
Since it's in Bash, it should work on Linux (tested also on Ubuntu).

In my implementation, I run `backups.sh` one day of the week 
and `snapshots.sh` the next day.

Further explanation 
[here](https://www.scrample.xyz/sauvegarde-avec-rsync/) 
(but in french) with the original Telegram based notifications scripts.


### Configuration file (optional)

Copy `gotify-notify.conf` to the `/etc/` folder or be lazy :
```
wget https://raw.githubusercontent.com/anup92k/scripts/master/backups/gotify-notify.conf -O /etc/gotify-notify.conf
```

Don't forget to update it with your personnal credentials !


### Rsync

The `backup.sh` script is called trough `backups.sh`.
Every backups result in a text log file which need to be kept 
in order to do the snapshot.


### Snapshot

Making a snapshot is implemented by just doing a 
tarball of the "rsynced" folder.

The `snapshot.sh` script is called trough `snapshots.sh`.

*This script also remove Snapshots which are more than 90 days old.*