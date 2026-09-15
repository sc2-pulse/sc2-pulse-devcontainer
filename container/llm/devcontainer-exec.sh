#!/bin/bash

ssh -o StrictHostKeyChecking=accept-new -o LogLevel=QUIET $SSH_CLIENT_DEST bash -s "$SSH_CLIENT_WORKDIR" "$@" << 'EOF'
cd "$1" && shift
"$@"
EOF
