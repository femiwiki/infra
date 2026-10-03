#!/bin/bash
set -euo pipefail

# Step 2 of femiwiki/femiwiki#645. CREATE DATABASE fails if the schema already
# exists, so a second run cannot copy over a schema 1.46 is already using.
target='__TARGET__'
mysql -e "CREATE DATABASE \`$target\`; GRANT ALL PRIVILEGES ON \`$target\`.* TO 'mediawiki'@'%';"

# The copy stays out of the binary log, which would otherwise grow by the size
# of the schema. --single-transaction reads without locking femiwiki.
start=$(date +%s)
{
  echo 'SET SESSION sql_log_bin=0;'
  mariadb-dump --single-transaction --quick --hex-blob --routines --triggers femiwiki
} | mysql "$target"
echo "Copied femiwiki to $target in $(($(date +%s) - start)) s"

mysql -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$target'"
