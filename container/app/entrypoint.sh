#!/bin/bash
set -euo pipefail

SSH_AUTHORIZED_KEYS="$HOME/.ssh/authorized_keys"
SSH_AUTHORIZED_KEYS_D="$SSH_AUTHORIZED_KEYS.d"
PAT_FILE="/run/secrets/github-token"
GITCONFIG_D="/home/developer/gitconfig.d"
GITCONFIG="/home/developer/.gitconfig"

sudo /usr/local/sbin/docker-init.sh

# Preserve docker shell env for SSH
while IFS='=' read -r name value; do
    [[ "$name" =~ ^(BASH_FUNC_|UID|EUID|PPID|SHELLOPTS) ]] && continue

    printf 'export %s=%s\n' "$name" "$(printf '%q' "$value")"

done < <(printenv) >> ~/.bashrc

if [[ "$SSH_SERVER_ENABLED" == "true" ]]; then
    ssh-keygen -q -t ed25519 -N "" -f ~/.ssh/id_ed25519
    cat ~/.ssh/id_ed25519.pub >> "$SSH_AUTHORIZED_KEYS"
    for file in $SSH_AUTHORIZED_KEYS_D/*; do
        if [[ -f "$file" ]]; then
            cat $file >> "$SSH_AUTHORIZED_KEYS"
            echo "Authorized SSH keys $file"
        fi
    done
fi

if [[ -d "$GITCONFIG_D" ]]; then
    for file in $GITCONFIG_D/*; do
        if [[ -f "$file" ]]; then
            echo "Gitconfig $file"
            echo -e "\n[include]\n    path = $file" >> "$GITCONFIG"
        fi
    done
fi

if [[ -f "$PAT_FILE" ]]; then
    echo "Github PAT $PAT_FILE"
    gh auth login --with-token < "$PAT_FILE"
    gh auth setup-git
fi

exec "$@"
