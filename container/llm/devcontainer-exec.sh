#!/bin/bash

ssh -t -o StrictHostKeyChecking=accept-new -o LogLevel=QUIET $SSH_CLIENT_DEST "bash -ic 'cd $SSH_CLIENT_WORKDIR; $@'"
