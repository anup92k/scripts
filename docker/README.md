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
  docker-compose --file "$i" pull --quiet
  docker-compose --file "$i" up --detach --remove-orphans --quiet-pull
done

docker image prune --force
```

If you use `update_dc_containers.sh`, 
don't forget to update thoses variables in the script :

* `DC_FOLDERS`
* `GOTIFY_URL`
* `GOTIFY_TOKEN`

And optionally :

* `GOTIFY_TITLE`