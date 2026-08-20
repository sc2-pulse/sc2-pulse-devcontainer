#!/bin/bash
set -euo pipefail

PAT_FILE="/run/secrets/github-token"
GITCONFIG_D="/home/developer/gitconfig.d"
GITCONFIG="/home/developer/.gitconfig"
PODMAN_SOCK="/run/podman/podman.sock"
PODMAN_SOCK_OVERRIDE_DIR="/home/developer/.local/share/podman"
PODMAN_SOCK_OVERRIDE="$PODMAN_SOCK_OVERRIDE_DIR/podman.sock"
PODMAN_UID=$(stat -c '%u' "$PODMAN_SOCK")

gosu developer mkdir -p "$PODMAN_SOCK_OVERRIDE_DIR";
getent passwd $PODMAN_UID &>/dev/null || useradd -u $PODMAN_UID -M -s /usr/sbin/nologin podman
socat \
    UNIX-LISTEN:"$PODMAN_SOCK_OVERRIDE",user=developer,group=developer,mode=600,fork,unlink-early,su=$PODMAN_UID \
    UNIX-CONNECT:"$PODMAN_SOCK" &
echo "Podman socket $PODMAN_SOCK_OVERRIDE"

GITCONFIG_D="$GITCONFIG_D" GITCONFIG="$GITCONFIG" PAT_FILE="$PAT_FILE" gosu developer bash << 'EOF'
    if [ -d "$GITCONFIG_D" ]; then
        for file in $GITCONFIG_D/*; do
            if [ -f "$file" ]; then
                echo "Gitconfig $file"
                echo -e "\n[include]\n    path = $file" >> "$GITCONFIG"
            fi
        done
    fi

    if [ -f "$PAT_FILE" ]; then
        echo "Github PAT $PAT_FILE"
        gh auth login --with-token < "$PAT_FILE"
        gh auth setup-git
    fi
EOF

exec gosu developer "$@"
