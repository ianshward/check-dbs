#!/bin/sh

MYSQL="$(which mysql)"
GREP="$(which grep)"
DIR='/var/aegir/config/vhost.d'

DBS="$($MYSQL -Bse 'show databases')"

# Print header
echo "site | db name | last node | last comment"
echo "--- | --- | --- | ---"

for db in $DBS; do
  if [ $db != 'mysql' ] && [ $db != 'information_schema' ]; then
    local COMMENT="$($MYSQL -Bse "SELECT timestamp FROM $db.comments ORDER BY timestamp DESC LIMIT 1")"
    local NODE="$($MYSQL -Bse "SELECT changed FROM $db.node ORDER BY changed DESC LIMIT 1")"
    if [ "$COMMENT" != "" ] && [ "$NODE" != "" ]; then
      # Determine name of site
      local SITE="$($GREP -rinl $db $DIR)"
      echo "$SITE | $db | $(date -d @$NODE) | $(date -d @$COMMENT)"
    fi
  fi
done
