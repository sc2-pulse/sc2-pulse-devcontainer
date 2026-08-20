FROM maven:3.9.11-eclipse-temurin-17-noble

ARG UID=1000
ARG GID=1000
ARG GH_VERSION=2.97.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        tree \
        jq \
        socat \
        python3 \
        sudo \
    && curl -sSL https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.deb -o /tmp/gh.deb \
    && dpkg -i /tmp/gh.deb \
    && rm -rf /tmp/gh.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN userdel -r ubuntu \
    && groupadd --gid "$GID" developer \
    && useradd --uid "$UID" --gid "$GID" --create-home --shell /bin/bash developer \
    && sudo -u developer gpg --list-keys \
    && sudo -u developer mkdir -p /home/developer/.local/share/podman \
    && echo "developer ALL=(root) NOPASSWD: /usr/local/sbin/docker-init.sh" > /etc/sudoers.d/developer \
    && chmod 440 /etc/sudoers.d/developer

COPY container/app/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
COPY --chmod=755 container/app/docker-init.sh /usr/local/sbin/docker-init.sh
COPY --chown=developer:developer container/app/home/developer /home/developer

USER developer
WORKDIR /workspaces/sc2-pulse
