FROM debian:trixie-slim

ARG UID=1000
ARG GID=1000

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        shadowsocks-libev \
        iputils-ping \
        iptables \
        ipset \
        kmod \
        netcat-openbsd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid "$GID" ss \
    && useradd --uid "$UID" --gid "$GID" --create-home --shell /bin/bash ss \
    && mkdir -p /home/ss/.config/shadowsocks \
    && chown -R ss:ss /home/ss

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["ss-redir", "-c" ,"/home/ss/.config/shadowsocks/client.json"]

USER ss
