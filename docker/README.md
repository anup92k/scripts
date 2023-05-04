## Docker related scripts
### Updates Docker Compose container

Basically, this script found all Docker Compose files,
pulls images based on them and re-run the containers.

Because I may wanna cron this script,
I added Gotify notifications to this.

If you just want a simple script :
```bash
#!/usr/bin/env bash

composeConfig=$(find . -type f -name "docker-compose.yml" -o -name "docker-compose.yaml" | xargs echo)

for i in $composeConfig; do
  cd $(dirname -- $i)
  docker compose pull --quiet
  docker compose up --detach --remove-orphans --quiet-pull
done

docker image prune --force
```

If you use `update_dc_containers.sh`, 
don't forget to update thoses variables in the script :

* `DC_FOLDERS`
* `GOTIFY_URL` (unnecessary if using configuration file : see below)
* `GOTIFY_TOKEN` (unnecessary if using configuration file : see below)

And optionally :

* `GOTIFY_TITLE`

Update (2021-12-28) :  
If you run this script using any argument 
(ex : `update_dc_containers.sh lol`), 
it will only work on the current directory

Update (2023-02-18) :  
Make it work in directory so file like `docker-compose.override.yml` 
will be processed too.

Update (2023-05-04) :  
Update to Compose V2.


### Configuration file (optional)

Copy `gotify-notify.conf` to the `/etc/` folder or be lazy :
```
wget https://raw.githubusercontent.com/anup92k/scripts/master/docker/gotify-notify.conf -O /etc/gotify-notify.conf
```

Don't forget to update it with your personnal credentials !
