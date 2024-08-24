## Gotify Nagios
### Description

This plugin was made in order to send Nagios notification
using [Gotify](https://gotify.net) with cURL.

```
Usage: gotify_nagios.sh [-h|--help] [-v|--version] <token> <url> <object_type> <notification_type> <state> <host_name> <description> <output>
        <token>: Gotify app token
        <url>: Gotify URL
        <object_type>: 'Host' or 'Service'
        -h, --help: Prints help
        -v, --version: Prints version
```

Some testing example :
```bash
./gotify_nagios.sh MYTOKEN https://gotify.example.com Host "PROBLEM" "UNREACHABLE" "GoogleDNS" "8.8.8.8" "Host check timed out after 30.04 seconds"
./gotify_nagios.sh MYTOKEN https://gotify.example.com Service "RECOVERY" "OK" "MyServer" "Wordpress" "HTTP OK: HTTP/1.1 200 OK - 30978 bytes in 0.095 second response time"
```

Which result in :  
![](example_result.png)


### Configuration
#### Contact

This is my contact definition :
```
define contact {
    contact_name                    gotify_group
    host_notification_commands      notify-host-by-gotify
    service_notification_commands   notify-service-by-gotify
    host_notifications_enabled      1
    service_notifications_enabled   1
    service_notification_period     24x7
    host_notification_period        24x7
    service_notification_options    w,u,c,r
    host_notification_options       d,u,r
}
```

Which is part of the default contact group :
```
define contactgroup {
    contactgroup_name       admins
    alias                   Nagios Administrators
    members                 gotify_group
}
```

#### Resource

I stored my token and my Gotify server's URL in macros 
in the resource file `resource.cfg` like this example :

```
# Gotify
## API token
$USER15$=Az3rtY
## URL
$USER16$=https://gotify.example.com
```


#### Command

My commands are defined as below :
```
define command {
    command_name     notify-host-by-gotify
    command_line     $USER1$/gotify_nagios.sh $USER15$ $USER16$ Host "$NOTIFICATIONTYPE$" "$HOSTSTATE$" "$HOSTNAME$" "$HOSTADDRESS$" "$HOSTOUTPUT$"
}

define command {
    command_name     notify-service-by-gotify
    command_line     $USER1$/gotify_nagios.sh $USER15$ $USER16$ Service "$NOTIFICATIONTYPE$" "$SERVICESTATE$" "$HOSTNAME$" "$SERVICEDESC$" "$SERVICEOUTPUT$"
}
```

It's important that `Host` and `Service` are exactly written this way 
because the script check for one of theses exact value.  
*I made it like that because I may build differents notification template 
which is not the case by now.*


### Installation

As you can see from the commands, I stored this script in the Nagios scripts directory.

So, you may install it this way :
```bash
wget https://raw.githubusercontent.com/anup92k/scripts/master/nagios-plugins/gotify_nagios/gotify_nagios.sh
sudo cp gotify_nagios.sh /usr/local/nagios/libexec
sudo chown nagios:nagios /usr/local/nagios/libexec/gotify_nagios.sh
sudo chmod u+x /usr/local/nagios/libexec/gotify_nagios.sh
```

Don't forget to test it manually with the `nagios` user.


### Customisation

You may want to change the icons I choose for the notifications.  
Do do that, search for "emoji" in the script content and change them !
