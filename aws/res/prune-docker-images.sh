#!/bin/bash
set -euo pipefail

# Images a container uses are never touched by prune, and three days leaves
# yesterday's generation to roll back to.
docker image prune --all --force --filter until=__KEEP_HOURS__h

df -h / | tail -1
docker system df
