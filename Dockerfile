FROM maven:3.9.11-eclipse-temurin-17-noble

ARG UID=10001
ARG GID=10001
ARG GH_VERSION=2.97.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        tree \
        jq \
        python3 \
        gosu \
    && curl -sSL https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.deb -o /tmp/gh.deb \
    && dpkg -i /tmp/gh.deb \
    && rm -rf /tmp/gh.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid "$GID" developer \
    && useradd --uid "$UID" --gid "$GID" --create-home --shell /bin/bash developer \
    && gosu developer gpg --list-keys

COPY container/app/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
COPY --chown=developer:developer container/app/home/developer /home/developer

USER developer
WORKDIR /workspaces/sc2-pulse
