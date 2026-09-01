FROM debian:trixie-slim

ARG UID=1000
ARG GID=1000
ARG INSTALL_SCRIPT_URL

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        openssh-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid "$GID" llm \
    && useradd --uid "$UID" --gid "$GID" --create-home --shell /bin/bash llm

COPY devcontainer-exec.sh /usr/local/bin/devcontainer-exec
RUN mkdir -p /workspaces/sc2-pulse && chown llm:llm /workspaces/sc2-pulse
WORKDIR /workspaces/sc2-pulse

USER llm
RUN mkdir ~/.ssh && chmod 700 ~/.ssh
RUN curl -fsSL "$INSTALL_SCRIPT_URL" | sh \
    && grep "PATH" ~/.profile >> ~/.bashrc
