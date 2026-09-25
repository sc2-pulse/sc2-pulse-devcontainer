## sc2pulse dev container
This is an opinionated container config of dev environment for the [sc2-pulse](https://github.com/sc2-pulse/sc2-pulse) project.

The containers provide an isolated environment with basic tools
* jdk
* maven
* git
* gh
* std cli tools
* isolated nested podman for testcontainers

## How to
* Compose up
* Connect to the `sc2pulse-dev-app` container directly, via vscode remote connection, or w/e.
* Do stuff
* Disconnect
* Compose down

The intended container manager is rootless podman. It should be compatible with rootful docker, although it's not tested and you will have to match container uid/gid via build args if your host uid/gid is not 1000.

The intended working dir is `/workspaces/sc2-pulse`. You can clone a repository there, e.g. `git clone https://github.com/sc2-pulse/sc2-pulse.git /workspaces/sc2-pulse`.

## Provided utils
* `/run/secrets/github-token`. When provided, the PAT is used via `gh` as an auth provider. Can be used to drop github privileges to required minimum.
* `/home/developer/gitconfig.d`. All files in this directory will be included in gitconfig. Can be used to passthrough a host config.
* `SSH_SERVER_ENABLED` env var. Enables an optional SSH server when set to `true`. Use `/home/developer/.ssh/authorized_keys.d` dir to mount your authorized keys files. Can be used for remote execution without exposing a host container socket.
* [tun2socks wrapper container](container/proxy-wrapper). Add a `PROXY` env var(see [proxy models](https://github.com/xjasonlyu/tun2socks/wiki/Proxy-Models)) and replace the `network` block of the target container with `network_mode: "service:sc2pulse-dev-proxy"`. Useful if you have some complex networking on the host and you want to tunnel specific containers there without dealing with more complex stuff such as VPNs or rootless namespace networking.

## Passthrough
`compose.passthrough.yaml` provides a host config passthrough example for git and gpg.

## vscode devcontainer
Although it's not a standard devcontainer managed by vscode, you can still connect to `sc2pulse-dev-app` container via remote connection in vscode. You can also use [named-container-config.json](vscode/named-container-config.json). Keep in mind that vscode only reads this config at initialization. You will need to pre-create the config file before connecting. You can also connect, wait for vscode to initialize the server, `ctrl + shift + p` `Open Named Container Configuration File`, paste the config there, compose down, remove vscode related container volumes, compose up and reconnect. This will force vscode to read the config.

## LLM
A CLI LLM agent can be installed directly in the dev container locally, or it can connect to the dev container remotely via container exec or SSH.

### Containers
[LLM container config](container/llm) provides containerized agents that connect to the dev container via SSH.
* Generate SSH keys. Mount them under `/home/llm/.ssh` in the llm container, and mount the public key on `/home/developer/.ssh/authorized_keys.d/llm` in the dev container.
* Merge [container/llm/compose.yaml](container/llm/compose.yaml), it's the base agent container config. Merge agent specific config such as `compose.codex.yaml`.
* Connect to the `sc2pulse-dev-llm` container and launch the agent, e.g. `codex`.
