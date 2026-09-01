#!/bin/bash
set -euo pipefail

PODMAN_SOCK="/run/podman/podman.sock"
PODMAN_UID=$(stat -c '%u' "$PODMAN_SOCK")
PODMAN_SOCK_OVERRIDE_DIR="/home/developer/.local/share/podman"
PODMAN_SOCK_OVERRIDE="$PODMAN_SOCK_OVERRIDE_DIR/podman.sock"

getent passwd $PODMAN_UID &>/dev/null || useradd -u $PODMAN_UID -M -s /usr/sbin/nologin podman
socat \
    UNIX-LISTEN:"$PODMAN_SOCK_OVERRIDE",user=developer,group=developer,mode=600,fork,unlink-early,su=$PODMAN_UID \
    UNIX-CONNECT:"$PODMAN_SOCK" &
echo "Podman socket $PODMAN_SOCK_OVERRIDE"

if [[ "$SSH_SERVER_ENABLED" == "true" ]]; then
    mkdir -p /run/sshd
    chmod 0755 /run/sshd
    ssh-keygen -A
    /usr/sbin/sshd
    echo "SSH server started";
fi
