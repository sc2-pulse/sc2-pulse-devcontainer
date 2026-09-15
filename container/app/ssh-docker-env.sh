#!/bin/bash
set -euo pipefail

while IFS= read -r -d '' var; do
    export "$var"
done < /proc/1/environ

exec bash -c "$SSH_ORIGINAL_COMMAND"
