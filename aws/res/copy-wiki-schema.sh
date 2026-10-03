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

# 1.43 serves the copy under its own name, which is its wiki ID, and Flow and
# OAuth match these columns against the wiki ID. See femiwiki/femiwiki#645.
for col in flow_workflow.workflow_wiki flow_ext_ref.ref_src_wiki flow_wiki_ref.ref_src_wiki \
  flow_revision.rev_user_wiki flow_revision.rev_mod_user_wiki flow_revision.rev_edit_user_wiki \
  flow_tree_revision.tree_orig_user_wiki \
  oauth_registered_consumer.oarc_wiki oauth_accepted_consumer.oaac_wiki; do
  table=${col%%.*} column=${col#*.}
  rows=$(mysql -N "$target" -e "SET SESSION sql_log_bin=0; UPDATE \`$table\` SET \`$column\` = '$target' WHERE \`$column\` = 'femiwiki'; SELECT ROW_COUNT();")
  echo "$col: $rows rows to $target"
done
