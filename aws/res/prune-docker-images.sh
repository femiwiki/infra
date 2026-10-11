#!/bin/bash
set -euo pipefail

# Keep the newest tags of each repository. rm refuses an image a container
# uses, so the running one and a rollback target stay whatever their age.
for repository in $(docker image ls | awk 'NR > 1 && $1 != "<none>" { print $1 }' | sort -u); do
  docker image ls "$repository" |
    awk -v keep=__KEEP_RECENT__ 'NR > 1 + keep && $2 != "<none>" { print $1 ":" $2 }' |
    while read -r image; do
      docker image rm "$image" || true
    done
done
docker image prune --force

# A replaced container can leave its anonymous volume behind, which for the
# fastcgi image is a localisation cache that grew to 1.8 GB. Only anonymous
# volumes are taken: their names are 64 hex digits, so a named volume that
# happens to be unattached, such as sitemap between containers, is left alone.
# grep exits 1 when nothing matches, which under pipefail turns a run with no
# orphans to remove into a failed association, so the match is allowed to be
# empty.
docker volume ls --quiet --filter dangling=true |
  { grep -E '^[0-9a-f]{64}$' || true; } |
  xargs -r docker volume rm

df -h / | tail -1
docker system df
