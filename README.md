# sun_infra

Shared development image and devcontainer template for Sun projects.

## Development image

Ubuntu 26.04, Linux amd64, LLVM/Clang 20, and common build tools.
Includes the complete `x86_64-linux-musl` toolchain from musl.cc for Sun's default
static linkage, including the C++ runtime. It is installed under `/opt/cross`
with its `bin` directory on `PATH`.
Includes the `ubuntu` user and passwordless sudo. Projects install Sun and
their own GTK, media, and other application dependencies.

```dockerfile
FROM ghcr.io/namo-robotics/sun-dev:ubuntu26.04-llvm20
USER root
# Install Sun and project dependencies.
USER ubuntu
WORKDIR /workspaces/my-project
```

[Image CI](.github/workflows/dev-image.yml) tests pull requests and publishes
on `main`. Manual runs refresh packages without cached layers. Tags are
`ubuntu26.04-llvm20` and `sha-<commit>`; pin a digest for reproducible builds.
Make the GHCR package public after its first publication.

```sh
docker build --check images/dev
docker build -t sun-infra-dev:local images/dev
docker run --rm -i sun-infra-dev:local bash < test/dev-image.sh
```

## Devcontainer template

Adds editor settings, UID matching, and a persistent ccache volume to a project's
Dockerfile. Requires Ubuntu 26.04, `USER ubuntu`, and passwordless sudo.

From the destination project:

```sh
mkdir -p ~/.codex ~/.claude ~/.ssh ~/.config/gh
npm install --prefix tmp/cli @devcontainers/cli@0.80.2
tmp/cli/node_modules/.bin/devcontainer templates apply \
  --workspace-folder . \
  --template-id ghcr.io/namo-robotics/sun_infra/sun-dev:0.1.2 \
  --template-args '{"name":"Sun Project"}'
```

The template mounts those host directories read-write. For an existing
`.devcontainer`, apply to a temporary directory and merge the changes.

See [template CI](.github/workflows/ci.yml) for validation commands.
To publish, bump [the template version](src/sun-dev/devcontainer-template.json)
and run **Publish templates** on `main`. Make its GHCR package public after the
first publication. Template updates must be applied to each project explicitly.
