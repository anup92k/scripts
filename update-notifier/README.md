## Gotify notification about updates

The purpose of this script is to get a notification 
about available updates using 
[Gotify](https://gotify.net) with cURL.


### Installation
#### Configuration file (optional)

Copy `gotify-notify.conf` to the `/etc/` folder or be lazy :
```
wget https://raw.githubusercontent.com/anup92k/scripts/master/update-notifier/gotify-notify.conf -O /etc/gotify-notify.conf
```

Don't forget to update it with your personnal credentials !


#### Script
```
wget https://raw.githubusercontent.com/anup92k/scripts/master/update-notifier/my-unattended-upgrades-notify.sh -O /usr/local/sbin/my-unattended-upgrades-notify.sh
chmod u+x /usr/local/sbin/my-unattended-upgrades-notify.sh
```

If you are not using the configuration file,
don't forget to update thoses variables :

* `GOTIFY_URL`
* `GOTIFY_TOKEN`


#### Cron

I run this script every day at 8 o'clock on my servers using `sudo crontab -e`.

Here is my definition :
```
0 8 * * * /usr/local/sbin/my-unattended-upgrades-notify.sh
```
