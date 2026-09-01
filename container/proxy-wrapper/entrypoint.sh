#!/bin/bash
set -euo pipefail

SS_CLIENT_CONFIG_FILE="$HOME/.config/shadowsocks/client.json"

if [[ -f "$SS_CLIENT_CONFIG_FILE" ]]; then
    ss-nat -s "$SS_SERVER_ADDRESS" -l 1080 -o
else
    echo "$SS_CLIENT_CONFIG_FILE not found"
    exit 1
fi

exec "$@"
