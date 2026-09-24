#!/bin/bash
set -euo pipefail

# Images a container uses are never touched by prune, and three days leaves
# yesterday's generation to roll back to.
docker image prune --all --force --filter until=__KEEP_HOURS__h

# A replaced container can leave its anonymous volume behind, which for the
# fastcgi image is a localisation cache that grew to 1.8 GB. Only anonymous
# volumes are taken: their names are 64 hex digits, so a named volume that
# happens to be unattached, such as sitemap between containers, is left alone.
docker volume ls --quiet --filter dangling=true |
  grep -E '^[0-9a-f]{64}$' |
  xargs -r docker volume rm

df -h / | tail -1
docker system df
