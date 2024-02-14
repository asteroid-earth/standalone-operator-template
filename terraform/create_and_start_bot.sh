#! /usr/bin/env bash

set -euxo pipefail

TOKEN=$(tctl bots add terraform --roles=terraform --format=json | jq -r '.token_id')
tbot start \
   --destination-dir=/opt/machine-id \
   --token="$TOKEN" \
   --auth-server=teleport.sudia.me:443 \
   --join-method=token

# if you're testing this locally you can use this, but I recommend using CI/CD, here's an example action
