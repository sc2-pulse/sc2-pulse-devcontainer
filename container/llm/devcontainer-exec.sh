#!/bin/bash

ssh -o StrictHostKeyChecking=accept-new -o LogLevel=QUIET $SSH_CLIENT_DEST "bash -c 'cd $SSH_CLIENT_WORKDIR; $@'"
