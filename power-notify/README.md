## Gotify notification at boot and shutdown

The purpose of this script is to get a notification 
at system boot and shutdown using 
[Gotify](https://gotify.net) with cURL.

I'm using `systemd` to get this running as a service.


### Installation
#### Configuration file (optional)

Copy `gotify-notify.conf` to the `/etc/` folder or be lazy :
```
wget https://raw.githubusercontent.com/anup92k/scripts/master/power-notify/gotify-notify.conf -O /etc/gotify-notify.conf
```

Don't forget to update it with your personnal credentials !


#### Script
```
wget https://raw.githubusercontent.com/anup92k/scripts/master/power-notify/power-notify.sh -O /usr/local/sbin/power-notify.sh
chmod u+x /usr/local/sbin/power-notify.sh
```

If you are not using the configuration file,
don't forget to update thoses variables :

* `GOTIFY_URL`
* `GOTIFY_TOKEN`


#### Activation

This service description make the script run at boot 
after the server is online.  
This way, it's gonna be called before stopping the 
network when shuting down.

```
[Unit]
Description=Power Notify
After=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/sbin/power-notify.sh up
ExecStop=/usr/local/sbin/power-notify.sh down

[Install]
WantedBy=multi-user.target
```

Copy the content above as `/etc/systemd/system/power-notify.service` or :
```
wget https://raw.githubusercontent.com/anup92k/scripts/master/power-notify/power-notify.service -O /etc/systemd/system/power-notify.service
```

Then, reload configuration file :
```
systemctl daemon-reload
```

Enable the service :
```
systemctl enable power-notify.service
```

Start the service to see if it works :
```
systemctl start power-notify.service
```

As `RemainAfterExit` is set to yes, 
`systemctl status power-notify.service` should 
give you an active state.


### Troubleshooting

Since this script is run as a service, errors 
are logged using `logger`. This mean you can check 
for failure in your log file (`tail /var/log/syslog`).

You can change the log tag editing the variable `LOGGER_TITLE` 
(set as `power-notify` by default).