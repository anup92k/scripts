## Check Wi-Fi channel
### Description

This plugin was made in order to scan for 
the channels used by my SSID.  
My Wi-Fi router is provided by my ISP, 
I couldn't find a way to get these info from it.  
My Nagios server got a none used Wireless card, 
so I took advantage of it with this script.

To make sure this script may work for you, 
try manually the `iwlist` command :
```bash
sudo iwlist <INTERFACE> scanning essid <MY_SSID>
```

### Output
#### Nagios Web Interface

This is a exemple of the output of this script :
> Channels 11, 56


#### Performance data

The value `CELL24` is for the 2,4 GHz band and
`CELL5` for the 5 GHz band.
> CELL24=11, CELL5=56

### Configuration
#### Command

My command is defined as below :
```
define command {
    command_name    my_check_wifichannels
    command_line    $USER1$/my_check_wifichannels.sh $ARG1$ $ARG2$
}
```

#### Service

The service is defined with `wlan0` as the wireless scanning interface 
and `My_SSID` as the SSID I'm scanning (my SSID :wink:).

```
define service {
    use                             generic-service-with-perf
    host_name                       Sadara
    service_description             Wi-Fi Channels
    check_period                    24x7
    check_interval                  60
    max_check_attempts              3
    retry_interval                  1
    notifications_enabled           1
    notification_options            w,u,c,r
    notification_interval           0
    notification_period             24x7
    check_command                   my_check_wifichannels!wlan0!My_SSID
    icon_image                      wifi.png
}
```

