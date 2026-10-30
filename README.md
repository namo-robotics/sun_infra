# sun_infra

Shared development infrastructure for Sun repositories. The first template shares
devcontainer configuration while each project keeps its Dockerfile, dependencies,
build commands, and release policy. All infrastructure targets Ubuntu 26.04;
CI and publishing use the explicit `ubuntu-26.04` runner label.

## Sun development template

Source: [`src/sun-dev`](src/sun-dev).
After publishing, the template reference is:
`ghcr.io/namo-robotics/sun_infra/sun-dev:0.1.2`.

The template inherits the image’s default user and supplies UID matching, an isolated
persistent ccache volume, cache ownership setup, Sun/C++ editor extensions, and
formatter settings. It does not install Sun: the project's image must provide
the compiler, language server, and required native dependencies.

The Dockerfile must use Ubuntu 26.04, declare `USER ubuntu`, and provide
home `/home/ubuntu`, Bash, and
passwordless sudo. Startup checks the OS version before configuring the cache.
The existing Dockerfiles in `sun_gobject`, `sun_ui`,
`sun_accent_popup`, and `sun_video_editor` meet that user/setup contract.
The default build context is the project root and Dockerfile is `../Dockerfile`
relative to `.devcontainer`. Both paths and the display name are template options.

## Apply the published template

Install the CLI with `npm install --prefix tmp/cli @devcontainers/cli@0.80.2`.
For a project without an existing `.devcontainer` directory, run from its root:

```sh
./tmp/cli/node_modules/.bin/devcontainer templates apply \
  --workspace-folder . \
  --template-id ghcr.io/namo-robotics/sun_infra/sun-dev:0.1.2 \
  --template-args '{"name":"Sun Project"}'
```

For an existing project, apply into a temporary directory first and review the
generated `.devcontainer` files before merging them. Preserve project-specific
ports, networking, Docker build targets, workspace paths, and startup steps.
Commands in the `postCreateCommand` object run independently; combine dependent
steps in one script instead of relying on object entry ordering.

Templates copy files; they do not provide live inheritance or automatically
propagate updates. Record the applied template version in project documentation.
To update, render the newer version in a temporary directory and review its diff
against the project's configuration.

The template includes host bind mounts for `~/.codex`, `~/.claude`, `~/.ssh`,
and `~/.config/gh`, matching the Sun projects' common setup. These mounts are
read-write and share those tools' configuration and credentials with the container.
Before opening the container, create missing directories on the host:

```sh
mkdir -p ~/.codex ~/.claude ~/.ssh ~/.config/gh
```

The common extensions include Sun Language, clangd, LLDB DAP, CMake Tools,
Claude Code, and ChatGPT.
Compiler updates stay explicit; startup does not download a new mutable `dev`
release. The template does not set fixed build/test worker counts. Project build
scripts should choose at most half the available cores, with a minimum of one.
Existing project-local worker settings still need review when adopting it.

## Validate locally

Run from this repository's root with Python 3, Bash, Node.js, and Docker available:

```sh
npm install --prefix tmp/cli @devcontainers/cli@0.80.2
python3 scripts/prepare-smoke-test.py
bash -n src/sun-dev/.devcontainer/post-create.sh test/smoke.sh
tmp/cli/node_modules/.bin/devcontainer read-configuration --workspace-folder build/smoke > build/configuration.json
tmp/cli/node_modules/.bin/devcontainer up --workspace-folder build/smoke
tmp/cli/node_modules/.bin/devcontainer exec --workspace-folder build/smoke bash smoke.sh
```

The fixture verifies the user, cache mount permissions, and startup hook using a
minimal Ubuntu 26.04 image. It does not build or test the Sun compiler or GTK libraries.
The fixture substitutes empty directories under `build/smoke-host-home` for the
host bind mounts, so tests do not use personal configuration or credentials.
Remove the test container after use with `docker rm -f <container-id>` using the
ID reported by `devcontainer up`; remove its test cache volume when no longer needed.

## Publish

Increment `version` in the template metadata for each template release, then run
the **Publish templates** workflow on `main`. It validates and smoke-tests the
template before publishing the OCI template artifact to GHCR. No PRs or generated
documentation commits are created. On first publication, check the GHCR package's
visibility and make it public so consumers can download it anonymously; a public
source repository alone does not guarantee a public package.

The initial migration candidates are `sun_gobject` and `sun_ui`. The compiler,
server, and DDS projects require review of their specialized setup before adoption.
