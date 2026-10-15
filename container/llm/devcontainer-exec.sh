#!/bin/bash

ssh -o StrictHostKeyChecking=accept-new -o LogLevel=QUIET $SSH_CLIENT_DEST bash -s << EOF
cd $(printf '%q' "$SSH_CLIENT_WORKDIR") || exit
{
$*
} </dev/null
EOF
