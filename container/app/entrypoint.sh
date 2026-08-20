#!/bin/bash
set -euo pipefail

PAT_FILE="/run/secrets/github-token"
GITCONFIG_D="/home/developer/gitconfig.d"
GITCONFIG="/home/developer/.gitconfig"

sudo /usr/local/sbin/docker-init.sh

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

exec "$@"
