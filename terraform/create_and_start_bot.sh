#! /usr/bin/env bash

set -euxo pipefail

TOKEN=$(tctl bots add terraform --roles=terraform --format=json | jq -r '.token_id')
tbot start \
   --destination-dir=/opt/machine-id \
   --token="$TOKEN" \
   --auth-server=teleport.sudia.me:443 \
   --join-method=token
