#!/usr/bin/env sh

if [ $# -eq 0 ]; then
  >&2 echo "Requires 1 argument with the Splunk hostname"
  exit 1
fi

echo "Reloading Splunk server: $1"

curl -k -Ss -u admin:"$SPLUNK_PASSWORD" "https://${1}:8089/services/apps/local/_reload"