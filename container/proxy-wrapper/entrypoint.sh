#!/bin/bash
set -euo pipefail

SS_CLIENT_CONFIG_FILE="$HOME/.config/shadowsocks/client.json"

if [[ -f "$SS_CLIENT_CONFIG_FILE" ]]; then
    ss-nat \
        -s $(jq -r '.server' "$SS_CLIENT_CONFIG_FILE") \
        -l $(jq -r '.local_port' "$SS_CLIENT_CONFIG_FILE") \
        -o
else
    echo "$SS_CLIENT_CONFIG_FILE not found"
    exit 1
fi

exec "$@"
