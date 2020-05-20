## Check Wi-Fi channel
### Description

This plugin was made in order to to display
how many equipements are connected 
to my network.

This script requiere the nagios user to be 
able to run `nmap`.

### Output
#### Nagios Web Interface

This is a exemple of the output of this script :
> 17 hosts on 192.168.92.0/24 


#### Performance data

* `hosts` : available hosts
* `scantime` : NMAP scan time

Exemple :
> hosts=17 scantime=7.91s

### Configuration
#### Command

My command is defined as below :
```
define command {
    command_name    check_hostsonnetwork
    command_line    $USER1$/my_check_hostsonnetwork.sh $ARG1$
}
```

#### Service

The service is defined with the network as an argument.
```
define service {
    use                             generic-service-with-perf
    host_name                       Namek
    service_description             Hosts on network
    check_period                    24x7
    check_interval                  60
    max_check_attempts              3
    retry_interval                  1
    notifications_enabled           1
    notification_options            w,u,c,r
    notification_interval           0
    notification_period             24x7
    check_command                   check_hostsonnetwork!192.168.92.0/24
    icon_image                      network.png
}

```

