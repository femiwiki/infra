#!/bin/bash
set -euo pipefail

# Step 3 of femiwiki/femiwiki#645: run the given image's update.php against the
# given schema, with the settings of the fastcgi container now serving.
image='__IMAGE__'
target='__TARGET__'

fastcgi=$(docker ps --quiet --filter name=fastcgi- | head -1)
env_file=$(mktemp)
hotfix=$(mktemp)
trap 'rm -f "$env_file" "$hotfix"' EXIT
# Inside the window the serving fastcgi is read-only, and update.php has to write.
docker exec "$fastcgi" env | grep -E '^(WG_|SSM_SECRETS=|AWS_REGION=|TZ=)' | grep -vE '^(WG_DB_NAME|WG_READ_ONLY)=' >"$env_file"
echo "WG_DB_NAME=$target" >>"$env_file"
docker exec "$fastcgi" cat /a/Hotfix.php >"$hotfix"

# Only update.php runs: no php-fpm, cron or job runner, so nothing is served and
# no mail goes out.
start=$(date +%s)
docker run --rm --network host --env-file "$env_file" \
  --volume "$hotfix:/a/Hotfix.php:ro" --entrypoint bash "$image" -c '
set -euo pipefail
set -a
WG_DB_PASSWORD="$(chamber read -q mysql/users/mediawiki password)"
WG_SECRET_KEY="$(chamber read -q mediawiki site_key)"
set +a
cp -f /a/LocalSettings.php /srv/femiwiki.com/LocalSettings.php
php /srv/femiwiki.com/maintenance/run.php update --quick
'
echo "Updated $target with $image in $(($(date +%s) - start)) s"
